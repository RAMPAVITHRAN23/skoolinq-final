import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skoolinq_project/Account/checkAuth.dart';
import 'package:skoolinq_project/Services/authService.dart';
import 'package:skoolinq_project/Services/dbservice.dart';
import 'package:skoolinq_project/Services/loading.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  DBService dbService = DBService();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: dbService.posts(),
      builder: (context, snapshots) {
        if (!snapshots.hasData) return Loading();

        QuerySnapshot querySnapshot = snapshots.data!;
        List<DocumentSnapshot> documentSnapshot = querySnapshot.docs;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade100, Colors.blue.shade300],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Header Row (Title & Logout Button)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "POSTS",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            backgroundColor: Colors.red.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => CheckAuth()),
                            );
                            await AuthService().SignOut();
                          },
                          icon: const Icon(Icons.exit_to_app, color: Colors.white),
                          label: const Text("Log Out",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Post List
                    ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      itemCount: documentSnapshot.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data =
                        documentSnapshot[index].data() as Map<String, dynamic>;

                        return PostCard(
                          docId: documentSnapshot[index].id,
                          username: data['postedBy'],
                          content: data["post"],
                          postedBy: data['uid'],
                          img: data["postImg"],
                          likes: data["likes"] ?? [],
                          uid: "admin",
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // PostCard Widget
  Widget PostCard({
    required String username,
    required String docId,
    required String content,
    required String postedBy,
    required String img,
    required List likes,
    required String uid,
  }) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Row
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Post Image (if available)
            if (img.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(img),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),

            const SizedBox(height: 10),

            // Post Content
            Text(
              content,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),

            const SizedBox(height: 10),

            // Actions Row (Delete Button)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection("posts")
                        .doc(docId)
                        .delete();
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
