import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skoolinq_project/Services/dbservice.dart';
import 'package:skoolinq_project/Services/loading.dart';
import 'package:skoolinq_project/mentors/chatui.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isMentorSelected = true;
  TextEditingController searchController = TextEditingController();
  List<String> mentors = List.generate(10, (index) => 'Mentor ${index + 1}');
  List<String> students = List.generate(10, (index) => 'Student ${index + 1}');
  List<String> filteredMentors = [];
  List<String> filteredStudents = [];
  late Timer updateTimer; // Timer for simulated updates
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    filteredMentors = mentors;
    filteredStudents = students;

    // Update filtered list based on search input
    searchController.addListener(() {
      filterList();
    });

    // Simulate real-time updates
    updateTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _simulateNewJoiner();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    updateTimer.cancel();
    super.dispose();
  }

  // Filter the list based on the search query
  void filterList() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
      if (searchQuery.isEmpty) {
        filteredMentors = mentors;
        filteredStudents = students;
      } else {
        filteredMentors = mentors
            .where((mentor) =>
            mentor.toLowerCase().contains(searchQuery))
            .toList();
        filteredStudents = students
            .where((student) =>
            student.toLowerCase().contains(searchQuery))
            .toList();
      }
    });
  }

  // Simulate a new mentor or student joining
  void _simulateNewJoiner() {
    setState(() {
      if (isMentorSelected) {
        mentors.add('Mentor ${mentors.length + 1}');
        filteredMentors = mentors;
      } else {
        students.add('Student ${students.length + 1}');
        filteredStudents = students;
      }
    });
  }

  DBService dbService = DBService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    return StreamBuilder(
        stream: dbService.checkDocument(user!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Loading();

          DocumentSnapshot document = snapshot.data;
          Map<String, dynamic> mentor = document.data() as Map<String, dynamic>;
          return Scaffold(
            backgroundColor: Color(0xFF121212),
            appBar: AppBar(
              backgroundColor: Color(0xFF1A1A1A),
              title: Text(
                'Chats',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    showSearchDialog();
                  },
                ),
              ],
            ),
            body: StreamBuilder(
                stream: dbService.users(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Loading();
                  QuerySnapshot querySnapshot = snapshot.data;
                  List<DocumentSnapshot> documents = querySnapshot.docs;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search, color: Colors.white),
                              hintText: 'Search Users...',
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.5)),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> data = documents[index]
                                .data() as Map<String, dynamic>;

                            // Display a mentor/student based on requested/accepted status
                            return mentor['requested'].contains(data["uid"])
                                ? InkWell(
                              onTap: () async {
                                await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(user!.uid)
                                    .update({
                                  "requested": FieldValue.arrayRemove(
                                      [data["uid"]]),
                                  "accepted": FieldValue.arrayUnion(
                                      [data["uid"]]),
                                });
                                await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(data["uid"])
                                    .update({
                                  "accepted": FieldValue.arrayUnion(
                                      [user!.uid])
                                });
                                List docc = [data["uid"], user!.uid];
                                docc.sort();
                                String combinedString = docc.join("");
                                await FirebaseFirestore.instance
                                    .collection(combinedString);
                              },
                              child: buildListTile(
                                  data, "Requested", Icons.group),
                            )
                                : mentor["accepted"].contains(data["uid"])
                                ? InkWell(
                              onTap: () {
                                List docc = [data["uid"], user!.uid];
                                docc.sort();
                                String combinedString = docc.join("");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatUI(
                                        name: data["name"],
                                        groupName: combinedString),
                                  ),
                                );
                              },
                              child: buildListTile(
                                  data, "Accepted", Icons.group),
                            )
                                : SizedBox();
                          },
                        ),
                      ],
                    ),
                  );
                }),
          );
        });
  }

  // Widget to build each list item (mentor/student)
  Widget buildListTile(Map<String, dynamic> data, String status, IconData icon) {
    return Card(
      color: Colors.black.withOpacity(0.8),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,  // Adding elevation for a more dynamic effect
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          data["name"]!,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          "Status: $status",
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      ),
    );
  }

  // Show a dialog for searching users
  void showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF121212),
          title: Text("Search for Users", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              labelStyle: TextStyle(color: Colors.white),
              hintText: 'Enter name...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            style: TextStyle(color: Colors.white),
            onChanged: (value) {
              filterList();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
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
