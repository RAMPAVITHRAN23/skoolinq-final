/*
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
          backgroundColor: const Color(0xFF18191A),
          appBar: AppBar(
            elevation: 3,
            backgroundColor: const Color(0xFF242526),
            title: const Text(
              'Chats',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),

           */
/* actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: _showFilterDialog,
              ),
            ],*//*

          ),
          body: Column(
            children: [
             */
/* _buildSearchBar(),*//*

              Expanded(child: _buildChatList(user, mentor)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          hintText: 'Search users...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildChatList(User user, Map<String, dynamic> mentor) {
    return StreamBuilder(
      stream: dbService.users(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Loading();
        QuerySnapshot querySnapshot = snapshot.data;
        List<DocumentSnapshot> documents = querySnapshot.docs;

        // Exclude user's own profile and filter based on search query and selected filter
        List<DocumentSnapshot> filteredDocuments = documents.where((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          bool isNotUser = data["uid"] != user.uid;
          bool matchesSearchQuery = data["name"].toString().toLowerCase().contains(searchQuery);

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
            Map<String, dynamic> data = filteredDocuments[index].data() as Map<String, dynamic>;
            bool isRequested = mentor["requested"].contains(data["uid"]);
            bool isAccepted = mentor["accepted"].contains(data["uid"]);

            return data["role"] != "admin"
                ? _buildChatTile(user, data, isRequested, isAccepted)
                : const SizedBox();
          },
        );
      },
    );
  }

  Widget _buildChatTile(User user, Map<String, dynamic> data, bool isRequested, bool isAccepted) {
    return Card(
      color: const Color(0xFF242526),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Text(
            data["name"][0],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          data["name"],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          "Status: ${isRequested ? "Requested" : isAccepted ? "Accepted" : "None"}",
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        trailing: Chip(
          backgroundColor: isAccepted ? Colors.green : isRequested ? Colors.orange : Colors.grey,
          label: Text(
            data["role"],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () {
          if (isRequested) {
            _handleRequestTap(user, data);
          } else if (isAccepted) {
            _handleAcceptedTap(user, data);
          }
        },
      ),
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
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: ["All", "Requested", "Accepted"].map((filterOption) {
            return ListTile(
              title: Text(
                filterOption,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
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
*/
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
  List<Map<String, String>> groups = [
    {"name": "Student 1", "status": "Accepted"},
    {"name": "Student 2", "status": "Requested"},
    {"name": "Student 3", "status": "Accepted"},
  ];
  DBService dbService = DBService();

  @override
  Widget build(BuildContext context) {
    // Filter groups based on search query

    final user = Provider.of<User?>(context);
    return StreamBuilder(
        stream: dbService.checkDocument(user!.uid),
        builder: (context, snapshota) {
          if (!snapshota.hasData) return Loading();

          DocumentSnapshot document = snapshota.data;
          Map<String, dynamic> mentor = document.data() as Map<String, dynamic>;
          return Scaffold(
              backgroundColor: Color(0xFF202124),
              appBar: AppBar(
                backgroundColor: Color(0xFF202124),
                title: Text(
                  'Chats',
                  style: TextStyle(color: Colors.white),
                ),

              ),
              body: StreamBuilder(
                  stream: dbService.users(), builder: (context, snapshot) {
                if (!snapshot.hasData) return Loading();
                QuerySnapshot querySnapshot = snapshot.data;
                List<DocumentSnapshot> documents = querySnapshot.docs;

                return SingleChildScrollView(child: Column(
                  children: [
                    /* Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                          hintText: 'Search',
                          hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.2)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.black),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),*/
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data = documents[index]
                            .data() as Map<String, dynamic>;
                        print(data["uid"]);
                        return mentor['requested'].contains(data["uid"]) ?InkWell(
                            onTap:()async {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return  AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius
                                          .circular(12),
                                    ),
                                    title: Text(data["name"]),
                                    content: Text(
                                        'Do you want chat with this student'),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance.collection(
                                              "users").doc(user!.uid).update({
                                            "requested": FieldValue.arrayRemove(
                                                [data["uid"]]),
                                            "accepted": FieldValue.arrayUnion(
                                                [data["uid"]]),
                                          });
                                          await FirebaseFirestore.instance.collection(
                                              "users").doc(data["uid"]).update({
                                            "accepted": FieldValue.arrayUnion([user!.uid])
                                          });
                                          List docc = [data["uid"], user!.uid];
                                          docc.sort();

                                          // Combine all elements into a single string
                                          String combinedString = docc.join("");
                                          await FirebaseFirestore.instance.collection(
                                              combinedString);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Accept',
                                            style: TextStyle(
                                                color: Colors.blue)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('decline',
                                            style: TextStyle(
                                                color: Colors.red)),
                                      ),
                                    ],
                                  );
                                },
                              );

                            },
                            child:ListTile(
                              leading: Icon(Icons.group, color: Colors.white),
                              title: Text(
                                data["name"]!,
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                "Status: Requested",
                                style: TextStyle(color: Colors.white),
                              ),

                            )) : mentor["accepted"].contains(data["uid"])  ?  InkWell(
                            onTap: (){},
                            child:ListTile(
                              leading: Icon(Icons.group, color: Colors.white),
                              title: Text(
                                data["name"]!,
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                "Status: Accepted",
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                // Navigate to the chat screen when a group is tapped
                                List docc = [data["uid"], user!.uid];
                                docc.sort();

                                // Combine all elements into a single string
                                String combinedString = docc.join("");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ChatUI(name: data["name"], groupName: combinedString, uid: data["uid"],)
                                  ),
                                );
                              },
                            )) :
                        SizedBox() ;
                      },
                    ),

                  ],
                )
                );
              }
              )
          );
        }
    );
  }

  // Filter Dialog
  void _showFilterDialog() {
    showModalBottomSheet(
      backgroundColor: Color(0xFF393640),
      context: context,
      builder: (context) {
        return ListView(
          children: [
            ListTile(
              title: Text(
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
              title: Text(
                "View the Status",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                //  _showStatusDialog();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Status Dialog
  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF393640),
          title: Text(
            "Group Status",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: groups
                .map((group) =>
                ListTile(
                  title: Text(
                    group["name"]!,
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    group["status"]!,
                    style: TextStyle(color: Colors.white),
                  ),
                ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Close",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}