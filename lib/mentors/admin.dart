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

          QuerySnapshot querySnapshot = snapshots.data;
          List<DocumentSnapshot> documentSnapshot = querySnapshot.docs;
          return Scaffold(
              body: SingleChildScrollView(
                  child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(height: 20,),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [Text(
                  "POSTS",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                  SizedBox(width: 40,),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 25),
                      backgroundColor: Colors.red[600], // Red button for log out
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CheckAuth()));
                      await AuthService().SignOut();
                    },
                    icon: const Icon(Icons.exit_to_app, color: Colors.white),
                    label: const Text(

                      "Log Out",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ]
                ),

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
                          postedBy:data['uid'],
                          img: data["postImg"], likes: data["likes"]!=null ? data["likes"]:[], uid: "admin",
                        );
                      }

    ),


              ],
            ),
          )));
        });
  }

  Widget PostCard(
      {required String username,
      required String docId,
      required String content,
      required String postedBy,
      required String img,
      required List likes,
      required String uid}) {
    bool liked = likes.contains(uid);
    return Card(
      elevation: 8,
      shadowColor: Colors.grey.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                SizedBox(width: 10),
                Text(username,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            if (img != null && img.isNotEmpty)
              Builder(
                builder: (context) {
                  try {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(base64Decode(img), fit: BoxFit.cover),
                    );
                  } catch (e) {
                    print("Error decoding image: $e");
                    return SizedBox.shrink();
                  }
                },
              )
            else
              SizedBox.shrink(),
            SizedBox(height: 10),
            Text(content, style: TextStyle(color: Colors.black)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Text(likes.length == 0 ? "" : likes.length.toString()),
                  SizedBox(
                    width: 3,
                  ),
                 /* IconButton(
                      onPressed: () async {
                        if (liked) {
                          likes.remove(uid);
                          await FirebaseFirestore.instance
                              .collection("posts")
                              .doc(docId)
                              .update({
                            "likes": FieldValue.arrayRemove([uid])
                          });
                        } else {
                          likes.add(uid);
                          await FirebaseFirestore.instance
                              .collection("posts")
                              .doc(docId)
                              .update({
                            "likes": FieldValue.arrayUnion([uid])
                          });
                        }
                      },
                      icon: Icon(Icons.thumb_up),
                      color: liked ? Colors.red : Colors.black),
                ]),*/

                     IconButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection("posts")
                              .doc(docId)
                              .delete();
                        },
                        icon: Icon(Icons.delete),
                        color: Colors.black)

              ],
            ),
          ],
        ),
    ]
      ),
      )
    );
  }
}
