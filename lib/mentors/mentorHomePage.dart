import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skoolinq_project/Account/intro.dart';
import 'package:skoolinq_project/Services/authService.dart';
import 'package:skoolinq_project/Services/dbservice.dart';
import 'package:skoolinq_project/Services/loading.dart';
import 'package:skoolinq_project/mentors/viewprofile.dart';

class MentorHomePage extends StatefulWidget {
  final VoidCallback onProfileNavigate;


  const MentorHomePage({required this.onProfileNavigate,super.key});

  @override
  State<MentorHomePage> createState() => _MentorHomePageState();
}

class _MentorHomePageState extends State<MentorHomePage> {
  TextEditingController postController = TextEditingController();
  int selectedFilterIndex = 0;
  DBService dbService = DBService();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    return StreamBuilder(
      stream: dbService.checkDocument(user!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Loading();
        DocumentSnapshot documentSnapshots = snapshot.data;
        Map<String, dynamic> data = documentSnapshots.data() as Map<String, dynamic>;

        // Calculate profile completion based on the available fields
        int profileCompletion = calculateProfileCompletion(data);

        // Determine the color for profile completion based on the percentage
        Color completionColor;
        if (profileCompletion == 100) {
          completionColor = Colors.green;
        } else if (profileCompletion >= 75) {
          completionColor = Colors.yellowAccent;
        } else if (profileCompletion >= 50) {
          completionColor = Colors.orange;
        } else {
          completionColor = Colors.red;
        }

        return StreamBuilder(
            stream: dbService.posts(),
            builder: (context, snapshots) {
              if (!snapshots.hasData) return Loading();

              QuerySnapshot querySnapshot = snapshots.data;
              List<DocumentSnapshot> documentSnapshot = querySnapshot.docs;

              return Scaffold(
                backgroundColor: Colors.blue[50], // Soft background color
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[400]!, Colors.blue[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  title: InkWell(

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        SizedBox(width: 10),
                        Text(
                          "Hello, ${data['name']}", // Dynamic welcome message with user's name
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  centerTitle: true,
                ),
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        "PROFILE COMPLETION",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed:widget.onProfileNavigate,
                        child:Card(
                        color: Colors.blue[200], // Soft background color for the profile completion container
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              LinearProgressIndicator(
                                value: profileCompletion / 100,
                                backgroundColor: Colors.grey[300],
                                color: completionColor,
                                minHeight: 10,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "${profileCompletion}% Profile Completed",
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "POSTS",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 10),
                      Row(
                        //spacing: 1,
                       // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FilterButton(
                            labels: "ALL",
                            isSelected: selectedFilterIndex == 0,
                            onTap: () => setState(() => selectedFilterIndex = 0),
                          ),
                          FilterButton(
                            labels: "POSTED BY ME",
                            isSelected: selectedFilterIndex == 1,
                            onTap: () => setState(() => selectedFilterIndex = 1),
                          ),
                          FilterButton(
                            labels: "POSTED BY OTHERS",
                            isSelected: selectedFilterIndex == 2,
                            onTap: () => setState(() => selectedFilterIndex = 2),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: documentSnapshot.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> datas =
                            documentSnapshot[index].data() as Map<String, dynamic>;
                            if (selectedFilterIndex == 0 ||
                                (selectedFilterIndex == 1 && user.uid == datas["uid"]) ||
                                (selectedFilterIndex == 2 && user.uid != datas["uid"])) {
                              return PostCard(
                                docId: documentSnapshot[index].id,
                                username: datas['postedBy'],
                                content: datas["post"],
                                postedBy:datas['uid'],
                                img: datas["postImg"], likes: datas["likes"]!=null ? datas["likes"]:[], uid: user!.uid,
                                np:data["posts"]!=null ? data["posts"] : 0
                              );
                            } else {
                              return SizedBox();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  int calculateProfileCompletion(Map<String, dynamic> data) {
    int filledFields = 0;
    List<String> profileFields = ['name', 'email', 'profilePic', 'bio'];

    // Count the filled fields in the profile
    for (var field in profileFields) {
      if (data[field] != null && data[field].toString().isNotEmpty) {
        filledFields++;
        print(filledFields);
      }
    }
    print(filledFields);

    // Calculate the percentage of profile completion
    return (filledFields / profileFields.length * 100).toInt();
  }

  // Filter Button with Modern Style
  Widget FilterButton({required String labels, required bool isSelected, required final VoidCallback onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal:1),
      child: InkWell(
        onTap: onTap,
        child: Chip(
          backgroundColor: isSelected ? Color(0xFF009688) : Colors.grey[300],
          label: Text(
            labels,
            style: TextStyle(color: isSelected ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  // Post Card with Modern Design
  Widget PostCard({required String username,
    required String docId,
    required String content,
    required String postedBy,
    required String img,required List likes,required String uid,required int np}) {
    bool liked=likes.contains(uid);
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
            InkWell(
            onTap: (){
              print(uid);
      Navigator.push(
      context,
      MaterialPageRoute(
      builder: (context) => View_profile(uid:postedBy), // Replace with your profile screen
      ),
      );
      },
          child: Row(
              children: [
               /* CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),*/
                SizedBox(width: 10),
                Text(username[0].toString().toUpperCase()+username.substring(1).toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ],
            ),
            ),
            SizedBox(height: 12),
            if (img != "" && img.isNotEmpty)
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
                  Text(likes.length==0? "":likes.length.toString()),
                  SizedBox(width: 3,),/*IconButton(
                    onPressed: ()async{
                      if(liked){
                        likes.remove(uid);
                        await FirebaseFirestore.instance.collection("posts").doc(docId).update({
                          "likes":FieldValue.arrayRemove([uid])
                        });
                      }
                      else{
                        likes.add(uid);
                        await FirebaseFirestore.instance.collection("posts").doc(docId).update({
                          "likes":FieldValue.arrayUnion([uid])
                        });
                      }
                    },
                    icon:Icon(Icons.thumb_up), color: liked ? Colors.red :Colors.black),*/
                ]
                ),
                postedBy==uid ? IconButton(
                    onPressed: () async{
                      await FirebaseFirestore.instance.collection("posts").doc(docId).delete();
                      await FirebaseFirestore.instance.collection("users").doc(postedBy).update({
                        "posts":np-1
                      });
                    },
                    icon:Icon(Icons.delete), color: Colors.black): SizedBox()
              ],
            ),
          ],
        ),
      ),
    );
  }
}
