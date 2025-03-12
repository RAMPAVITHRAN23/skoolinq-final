import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skoolinq_project/Services/dbservice.dart';
import 'package:skoolinq_project/Services/loading.dart';
import 'package:skoolinq_project/mentors/viewprofile.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String MentorName = "";
  String SchoolName = "";
  final List<String> mentorTypeList = [
    'Student Mentor',
    'Working Mentor (In a job/Professional)',
    'Tutor (Individual subject teachers / tuition)',
    'Coaches (Coaching institutes or individual coaches for entrance exams)',
    'Consultants (Professional career or educational consultants)'
  ];
  String? selectedMentorType;
  DBService dbService = DBService();
  bool isSearching = false;
  String searchType = "mentorName";
  List searchedResult=[] ;

  Future searchResults() async {
    searchedResult=[];
    QuerySnapshot querySnapshot = await dbService.SearchMentors();
    for (var doc in querySnapshot.docs) {
      searchedResult.add(doc.data());
    }
    setState(() {
      isSearching=true;
    });
  }

  @override
  void initState() {
    super.initState();

    searchResults();
  }

  late double divHeight, divWidth;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    divWidth = MediaQuery.of(context).size.width;
    divHeight = MediaQuery.of(context).size.height;
    return StreamBuilder(
        stream: dbService.checkDocument(user!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Loading();
          DocumentSnapshot document = snapshot.data!;
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;

          return Scaffold(
            appBar: AppBar(
              title: Text('Search Mentors'),
              centerTitle: true,
            ),
            body: isSearching
                ? SingleChildScrollView(
                    child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Search Mentor By "),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        searchType = "mentorName";
                                      });
                                    },
                                    child: Chip(
                                        label: Text("Mentor name"),
                                        backgroundColor:
                                            searchType == "mentorName"
                                                ? Colors.yellow
                                                : Colors.white)),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      searchType = "schoolName";
                                    });
                                  },
                                  child: Chip(
                                      label: Text("School Name"),
                                      backgroundColor:
                                          searchType == "schoolName"
                                              ? Colors.yellow
                                              : Colors.white),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      searchType = "mentorType";
                                    });
                                  },
                                  child: Chip(
                                      label: Text("Mentor Type"),
                                      backgroundColor:
                                          searchType == "mentorType"
                                              ? Colors.yellow
                                              : Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            searchType == "mentorName"
                                ? Column(children: [
                                    TextField(
                                      onChanged: (e) {
                                        setState(() {
                                          MentorName = e.toString();
                                        });
                                      },
                                      decoration: InputDecoration(
                                          hintText: "Enter the Mentor Name",
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15))),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        Map mentorsData = searchedResult[index];
                                        bool mentN = mentorsData["name"]
                                            .toString()
                                            .toLowerCase()
                                            .contains(MentorName.toLowerCase());

                                        return mentN
                                            ? _buildMentorCard(
                                                searchedResult[index],
                                                user!.uid,data)
                                            : SizedBox();
                                      },
                                      itemCount: searchedResult.length,
                                    )
                                  ])
                                : searchType == "schoolName"
                                    ? Column(children: [
                                        TextField(
                                          onChanged: (e) {
                                            setState(() {
                                              SchoolName = e.toString();
                                            });
                                          },
                                          decoration: InputDecoration(
                                              hintText: "Enter the School Name",
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15))),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            Map mentorsData =
                                                searchedResult[index];
                                            bool mentN = mentorsData[
                                                    "schoolName"]
                                                .toString()
                                                .toLowerCase()
                                                .contains(
                                                    SchoolName.toLowerCase());
                                            bool acpRreq=data["requested"].contains(mentorsData["uid"]);
                                            return mentN
                                                ? _buildMentorCard(
                                                    searchedResult[index],
                                                    user!.uid,data)
                                                : SizedBox();
                                          },
                                          itemCount: searchedResult.length,
                                        )
                                      ])
                                    : Column(children: [
                                        _buildDropdownField(
                                          value: selectedMentorType,
                                          items: mentorTypeList,
                                          label: 'Mentor Type',
                                          icon: Icons.person_search,
                                          onChanged: (value) => setState(() {
                                            selectedMentorType = value;
                                          }),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            Map mentorsData =
                                                searchedResult[index];
                                            bool mentN =
                                                mentorsData["mentorType"] ==
                                                    (selectedMentorType);

                                            return mentN
                                                ? _buildMentorCard(
                                                    searchedResult[index],
                                                    user!.uid,data)
                                                : SizedBox();
                                          },
                                          itemCount: searchedResult.length,
                                        )
                                      ]),
                          ],
                        )))
                : Loading(),
          );
        });
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String label,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(color: Colors.black),
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      // Dropdown background color
    );
  }

  Widget _buildMentorCard(Map mentorData, uid,stdata) {
    // print(mentorData["name"]+mentorData["requested"].contains(uid).toString());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 2),
          ],
        ),
        child: ListTile(
            leading: InkWell(
                onTap:(){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> View_profile(uid: mentorData["uid"])));
                },
                child:CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(mentorData["name"][0],
                  style: TextStyle(color: Colors.white)),
            )),
            title: Text(mentorData['name'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(mentorData['profession'] ?? "Student"),
            trailing: stdata["accepted"].contains(mentorData["uid"]) ? Text("Already Accepted") :
            stdata["requested"].contains(mentorData["uid"]) ? Text("Requested") :

                 ElevatedButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Request Mentor"),
                            content: Text(
                                "Send a request to ${mentorData['name']}?"),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(mentorData["uid"])
                                      .update({
                                    "requested": FieldValue.arrayUnion([uid])
                                  });
                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(uid)
                                      .update({
                                    "requested": FieldValue.arrayUnion([mentorData["uid"]])
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
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text("Request"),
                  )),
      ),
    );
  }
}
/*StreamBuilder(
      stream: dbService.checkDocument(user!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        DocumentSnapshot documentSnapshots = snapshot.data!;
        Map<String, dynamic> data = documentSnapshots.data() as Map<String, dynamic>;

        return Scaffold(
          backgroundColor: Colors.blue[50],
          appBar: AppBar(
            title: Text('Search Mentors', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.blue,
            centerTitle: true,
            automaticallyImplyLeading: false,

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
                      hintText: "Search for mentors...",
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
            print(mentors["uid"]);
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
          subtitle: Text(mentorData['profession'] ?? "Student"),
          trailing:!mentorData["requested"].contains(user!.uid) ? ElevatedButton(
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
          ):Text("Requested")
        ),
      ),
    );
  }
}
*/
