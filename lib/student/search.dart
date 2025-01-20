import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skoolinq_project/Services/dbservice.dart';
import 'package:skoolinq_project/Services/loading.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController search = TextEditingController();
  DBService dbService = DBService();
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    double screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder(
      stream: dbService.checkDocument(user!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        DocumentSnapshot documentSnapshots = snapshot.data!;
        Map<String, dynamic> data = documentSnapshots.data() as Map<String, dynamic>;

        return Scaffold(
          backgroundColor: Colors.blue[50],
          appBar: AppBar(
            title: Text('Search Mentors & Students', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.blue,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: search,
                    onChanged: (value) => setState(() => isSearching = value.isNotEmpty),
                    decoration: InputDecoration(
                      hintText: "Search mentors or students...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      prefixIcon: Icon(Icons.search, color: Colors.blue),
                      suffixIcon: search.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.red),
                        onPressed: () {
                          search.clear();
                          setState(() {});
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Mentor/Student List
                  search.text.isEmpty && !isSearching
                      ? _buildMentorList(context, dbService, data, user)
                      : _buildSearchResults(context, dbService, search.text, user),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMentorList(BuildContext context, DBService dbService, Map<String, dynamic> data, User? user) {
    return StreamBuilder(
      stream: dbService.Mentors(Class: int.parse(data["class"])),
      builder: (context, mentorSnapshot) {
        if (!mentorSnapshot.hasData) return Center(child: CircularProgressIndicator());

        QuerySnapshot mentorQuerySnapshot = mentorSnapshot.data!;
        List<DocumentSnapshot> mentorDocumentSnapshot = mentorQuerySnapshot.docs;

        if (mentorDocumentSnapshot.isEmpty) {
          return Center(child: Text("No mentors available.", style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: mentorDocumentSnapshot.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> mentors = mentorDocumentSnapshot[index].data() as Map<String, dynamic>;
            return data["accepted"].contains(mentors["uid"]) ? SizedBox() : _buildMentorCard(context, mentors, user);
          },
        );
      },
    );
  }

  Widget _buildSearchResults(BuildContext context, DBService dbService, String query, User? user) {
    return StreamBuilder(
      stream: dbService.search(query),
      builder: (context, searchSnapshot) {
        if (!searchSnapshot.hasData) return Center(child: CircularProgressIndicator());

        final searchDocumentSnapshot = searchSnapshot.data ?? [];

        if (searchDocumentSnapshot.isEmpty) {
          return Center(child: Text("No results found.", style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: searchDocumentSnapshot.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> searchData = searchDocumentSnapshot[index] as Map<String, dynamic>;
            return _buildMentorCard(context, searchData, user);
          },
        );
      },
    );
  }

  Widget _buildMentorCard(BuildContext context, Map<String, dynamic> mentorData, User? user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 5, spreadRadius: 2),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Text(mentorData["name"][0], style: TextStyle(color: Colors.white)),
          ),
          title: Text(mentorData['name'], style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(mentorData['profession'] ?? "No Profession"),
          trailing: ElevatedButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Request Mentor"),
                    content: Text("Send a request to ${mentorData['name']}?"),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(mentorData["uid"])
                              .update({
                            "requested": FieldValue.arrayUnion([user!.uid])
                          });
                          Navigator.pop(context);
                        },
                        child: Text("Request"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel"),
                      ),
                    ],
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text("Request"),
          ),
        ),
      ),
    );
  }
}
