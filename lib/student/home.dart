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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedFilterIndex = 0;
  DBService dbService = DBService();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final user = Provider.of<User?>(context);

    return StreamBuilder(
      stream: dbService.checkDocument(user!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Loading();
        DocumentSnapshot documentSnapshots = snapshot.data;
        Map<String, dynamic> data = documentSnapshots.data() as Map<
            String,
            dynamic>;

        return StreamBuilder(
          stream: dbService.posts(),
          builder: (context, snapshots) {
            if (!snapshots.hasData) return Loading();

            QuerySnapshot querySnapshot = snapshots.data;
            List<DocumentSnapshot> documentSnapshot = querySnapshot.docs;

            return StreamBuilder(
              stream: dbService.Mentors(Class: int.parse(data["class"])),
              builder: (context, mentorSnapshot) {
                if (!mentorSnapshot.hasData) return Loading();

                QuerySnapshot mentorQuerySnapshot = mentorSnapshot.data;
                List<
                    DocumentSnapshot> mentorDocumentSnapshot = mentorQuerySnapshot
                    .docs;

                return Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    elevation: 4,
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0288D1), Color(0xFF01579B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(
                              "assets/avatar_${data["avatar"]}.jpg"),
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          "Welcome, ${data["name"]}!!",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                  ),
                  body: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(15),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Mentor Connect",
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Container(
                              height: screenHeight * 0.13,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: mentorDocumentSnapshot.length,
                                itemBuilder: (context, index) {
                                  Map<String,
                                      dynamic> mentors = mentorDocumentSnapshot[index]
                                      .data() as Map<String, dynamic>;
                                  return !data["accepted"].contains(
                                      mentors["uid"])
                                      ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: InkWell(
                                      onTap: () {
                                        print( mentors["requested"].contains(user!.uid));
                                        mentors["requested"].contains(user!.uid) ? Navigator.push(context, MaterialPageRoute(builder: (context)=>View_profile(uid: mentors["uid"]))) :
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return  AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius
                                                    .circular(12),
                                              ),
                                              title: Text('Request Mentor'),
                                              content: Text(
                                                  'Do you want to request this mentor?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () async {
                                                    await FirebaseFirestore
                                                        .instance.collection(
                                                        "users").doc(
                                                        mentors["uid"]).update({
                                                      "requested": FieldValue
                                                          .arrayUnion(
                                                          [user!.uid])
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Request',
                                                      style: TextStyle(
                                                          color: Colors.blue)),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Cancel',
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            child: Text(mentors["name"][0],
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            radius: screenWidth * 0.08,
                                            backgroundColor: Color(0xFF0288D1),
                                          ),
                                          SizedBox(height: 5),
                                          Text("${mentors['name'][0].toString().toUpperCase()+mentors["name"].substring(1).toString()}",
                                              style: TextStyle(
                                                  color: Colors.black)),
                                        ],
                                      ),
                                    ),
                                  )
                                      : SizedBox();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 2,
                        color: Colors.blue[800],
                        height: 20,
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              SizedBox(height: screenHeight * 0.02),
                              // Adds space between label and posts
                              Text(
                                "Posts",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              // Adds space between label and posts
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FilterButton(
                                    label: "ALL",
                                    isSelected: selectedFilterIndex == 0,
                                    onTap: () =>
                                        setState(() => selectedFilterIndex = 0),
                                  ),
                                  FilterButton(
                                    label: "POSTED BY ME",
                                    isSelected: selectedFilterIndex == 1,
                                    onTap: () =>
                                        setState(() => selectedFilterIndex = 1),
                                  ),
                                  FilterButton(
                                    label: "POSTED BY OTHERS",
                                    isSelected: selectedFilterIndex == 2,
                                    onTap: () =>
                                        setState(() => selectedFilterIndex = 2),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10,),
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: documentSnapshot.length,
                                  itemBuilder: (context, index) {
                                    Map<String,
                                        dynamic> datas = documentSnapshot[index]
                                        .data() as Map<String, dynamic>;
                                    if (selectedFilterIndex == 1 &&
                                        user.uid != datas["uid"])
                                      return SizedBox();
                                    if (selectedFilterIndex == 2 &&
                                        user.uid == datas["uid"])
                                      return SizedBox();
                                    return PostCard(
                                      docId: documentSnapshot[index].id,
                                      username: datas['postedBy'],
                                      content: datas["post"],
                                      postedBy:datas['uid'],
                                      img: datas["postImg"], likes: datas["likes"]!=null ? datas["likes"]:[], uid: user!.uid,np:data["posts"]!=null ? data["posts"]: 0
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget PostCard({required String username,
    required String docId,
    required String content,
    required String postedBy,
    required String img, required List likes, required String uid,required int np}) {
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
            InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => View_profile(uid:postedBy), // Replace with your profile screen
                  ),
                );
              },

              child:Row(
              children: [
                /*CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),*/
                SizedBox(width: 10),
                Text("${username}", style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
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
                  Text(likes.length == 0 ? "" : likes.length.toString()),
                  SizedBox(width: 3,),/* IconButton(
                      onPressed: () async {
                        if (liked) {
                          likes.remove(uid);
                          await FirebaseFirestore.instance.collection("posts")
                              .doc(docId)
                              .update({
                            "likes": FieldValue.arrayRemove([uid])
                          });
                        }
                        else {
                          likes.add(uid);
                          await FirebaseFirestore.instance.collection("posts")
                              .doc(docId)
                              .update({
                            "likes": FieldValue.arrayUnion([uid])
                          });
                        }
                      },
                      icon: Icon(Icons.thumb_up),
                      color: liked ? Colors.red : Colors.black),*/
                ]
                ),
                postedBy == uid ? IconButton(
                    onPressed: () async {
                      print('Hiiiiiiiiiiiiiiiiiiii');
                      print(np);
                      await FirebaseFirestore.instance.collection("posts").doc(
                          docId).delete();
                      await FirebaseFirestore.instance.collection("users").doc(postedBy).update({
                        "posts":np-1
                      });
                    },
                    icon: Icon(Icons.delete), color: Colors.black) : SizedBox()
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) {},
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 5),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF0288D1) : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
