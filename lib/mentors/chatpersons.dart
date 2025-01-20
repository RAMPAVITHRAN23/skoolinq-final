import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skoolinq_project/Services/dbservice.dart';
import 'package:skoolinq_project/Services/loading.dart';
import 'chatui.dart'; // Import the chat screen

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  String filter = "All"; // Filter to toggle between "All" and "Accepted"
  String searchQuery = ""; // Search input field value
  DBService dbService = DBService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    return StreamBuilder(
      stream: dbService.checkDocument(user!.uid),
      builder: (context, snapshota) {
        if (!snapshota.hasData) return Loading();

        DocumentSnapshot document = snapshota.data!;
        Map<String, dynamic> mentor = document.data() as Map<String, dynamic>;

        return Scaffold(
          backgroundColor: const Color(0xFF202124),
          appBar: AppBar(
            backgroundColor: const Color(0xFF202124),
            title: const Text(
              'Chats',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_alt, color: Colors.white),
                onPressed: _showFilterDialog,
              ),
            ],
          ),
          body: StreamBuilder(
            stream: dbService.users(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Loading();

              QuerySnapshot querySnapshot = snapshot.data!;
              List<DocumentSnapshot> documents = querySnapshot.docs;

              // Apply filters and search
              List<DocumentSnapshot> filteredDocs = documents.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = data["name"]?.toLowerCase() ?? "";
                final isAccepted =
                    mentor['accepted']?.contains(data["uid"]) ?? false;

                // Filter based on "Accepted" or "All"
                bool passesFilter = filter == "All" || isAccepted;

                // Search logic
                return passesFilter && name.contains(searchQuery.toLowerCase());
              }).toList();

              return Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: Colors.white),
                        hintText: 'Search Accepted Members',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  // Empty state message
                  if (filteredDocs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No members found.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data =
                        filteredDocs[index].data() as Map<String, dynamic>;

                        bool isRequested =
                            mentor['requested']?.contains(data["uid"]) ?? false;
                        bool isAccepted =
                            mentor['accepted']?.contains(data["uid"]) ?? false;

                        // Sort and create group name
                        List docc = [data["uid"], user.uid];
                        docc.sort();
                        String combinedString = docc.join("");

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Card(
                            color: const Color(0xFF393640),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Icon(
                                  Icons.group,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                data["name"] ?? '',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                isRequested
                                    ? "Requested"
                                    : isAccepted
                                    ? "Accepted"
                                    : "Not Connected",
                                style: TextStyle(
                                  color: isRequested
                                      ? Colors.orange
                                      : isAccepted
                                      ? Colors.greenAccent
                                      : Colors.grey,
                                ),
                              ),
                              onTap: () async {
                                if (isRequested) {
                                  // Accept the request
                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(user.uid)
                                      .update({
                                    "requested":
                                    FieldValue.arrayRemove([data["uid"]]),
                                    "accepted":
                                    FieldValue.arrayUnion([data["uid"]]),
                                  });
                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(data["uid"])
                                      .update({
                                    "accepted":
                                    FieldValue.arrayUnion([user.uid]),
                                  });
                                } else if (isAccepted) {
                                  // Navigate to chat screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatUI(
                                        name: data["name"],
                                        groupName: combinedString,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // Filter Dialog
  void _showFilterDialog() {
    showModalBottomSheet(
      backgroundColor: Colors.grey[800],
      context: context,
      builder: (context) {
        return ListView(
          children: [
            ListTile(
              title: const Text(
                "All",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() {
                  filter = "All";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text(
                "Accepted Members",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() {
                  filter = "Accepted";
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
