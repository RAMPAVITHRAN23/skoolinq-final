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
  String filter = "All";
  String searchQuery = "";
  DBService dbService = DBService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    return StreamBuilder(
      stream: dbService.checkDocument(user!.uid),
      builder: (context, snapshota) {
        if (!snapshota.hasData) return Loading();

        DocumentSnapshot document = snapshota.data;
        Map<String, dynamic> mentor = document.data() as Map<String, dynamic>;

        return Scaffold(
          backgroundColor: const Color(0xFF202124),
          appBar: AppBar(
            backgroundColor: const Color(0xFF202124),
            title: const Text(
              'Chats',
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: _showFilterDialog,
              ),
            ],
          ),
          body: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: dbService.users(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Loading();
                    QuerySnapshot querySnapshot = snapshot.data;
                    List<DocumentSnapshot> documents = querySnapshot.docs;

                    // Exclude user's own profile and filter based on search query and selected filter
                    List<DocumentSnapshot> filteredDocuments = documents.where((doc) {
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      bool isNotUser = data["uid"] != user.uid;
                      bool matchesSearchQuery = data["name"]
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery);

                      if (filter == "Requested") {
                        return isNotUser && matchesSearchQuery && mentor["requested"].contains(data["uid"]);
                      } else if (filter == "Accepted") {
                        return isNotUser && matchesSearchQuery && mentor["accepted"].contains(data["uid"]);
                      }
                      return isNotUser && matchesSearchQuery;
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredDocuments.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data = filteredDocuments[index]
                            .data() as Map<String, dynamic>;
                        bool isRequested = mentor["requested"].contains(data["uid"]);
                        bool isAccepted = mentor["accepted"].contains(data["uid"]);

                        return ListTile(
                          leading: const Icon(Icons.group, color: Colors.white),
                          title: Text(
                            data["name"],
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "Status: ${isRequested ? "Requested" : isAccepted ? "Accepted" : "None"}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            if (isRequested) {
                              // Handle "Requested" tap
                              _handleRequestTap(user, data);
                            } else if (isAccepted) {
                              // Handle "Accepted" tap
                              _handleAcceptedTap(user, data);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleRequestTap(User user, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "requested": FieldValue.arrayRemove([data["uid"]]),
      "accepted": FieldValue.arrayUnion([data["uid"]]),
    });
    await FirebaseFirestore.instance.collection("users").doc(data["uid"]).update({
      "accepted": FieldValue.arrayUnion([user.uid]),
    });
    List docc = [data["uid"], user.uid];
    docc.sort();
    String combinedString = docc.join("");
    await FirebaseFirestore.instance.collection(combinedString).doc();
  }

  void _handleAcceptedTap(User user, Map<String, dynamic> data) {
    List docc = [data["uid"], user.uid];
    docc.sort();
    String combinedString = docc.join("");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatUI(name: data["name"], uid: data["uid"], groupName: combinedString),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      backgroundColor: const Color(0xFF393640),
      context: context,
      builder: (context) {
        return ListView(
          children: ["All", "Requested", "Accepted"].map((filterOption) {
            return ListTile(
              title: Text(
                filterOption,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() {
                  filter = filterOption;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
