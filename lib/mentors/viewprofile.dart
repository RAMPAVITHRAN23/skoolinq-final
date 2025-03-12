import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skoolinq_project/Services/loading.dart';
import '../services/dbservice.dart';

class View_profile extends StatefulWidget {
  final String uid;
  const View_profile({required this.uid, super.key});

  @override
  State<View_profile> createState() => _View_profileState();
}

class _View_profileState extends State<View_profile> {
  DBService dbService = DBService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder(
      stream: dbService.checkDocument(user!.uid),
      builder: (context, snapshots) {
        if (!snapshots.hasData) return const Loading();
        DocumentSnapshot documents = snapshots.data!;
        Map<String, dynamic> mydata = documents.data() as Map<String, dynamic>;

        return StreamBuilder(
          stream: dbService.checkDocument(widget.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            DocumentSnapshot document = snapshot.data!;
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            return SafeArea(
              child: Scaffold(
                body: Container(
                  height: screenHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade100, Colors.blue.shade300],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.blueGrey),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Text(
                              'Profile',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.4,
                                color: Colors.blueGrey[800],
                                fontSize: screenHeight * 0.035,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        // Profile Picture with Glow Effect
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: screenHeight * 0.1,
                              backgroundColor: Colors.blue.withOpacity(0.3),
                              child: CircleAvatar(
                                radius: screenHeight * 0.09,
                                backgroundImage:
                                NetworkImage(data["profilePic"] ?? ""),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Profile Information
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(screenHeight * 0.02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ProfileInfoRow(
                                  icon: Icons.person,
                                  label: "Name",
                                  value: data["name"] ?? "Name not set",
                                ),
                                Divider(),
                                ProfileInfoRow(
                                  icon: Icons.info_outline,
                                  label: "Role",
                                  value: data["role"],
                                ),
                                Divider(),
                                ProfileInfoRow(
                                  icon: Icons.people_alt_outlined,
                                  label: data["class"] != null ? "Class" : "Profession",
                                  value: (data["profession"] ?? data['class']).toString(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Followers & Posts Information
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(screenHeight * 0.02),
                            child: Column(
                              children: [
                                ProfileInfoRow(
                                  icon: Icons.people_alt_outlined,
                                  label: "Followers",
                                  value: (data["requested"].length +
                                      data["accepted"].length)
                                      .toString(),
                                ),
                                Divider(),
                                ProfileInfoRow(
                                  icon: Icons.post_add_outlined,
                                  label: "Posts",
                                  value: data["posts"]?.toString() ?? "0",
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Mentor Request Button
                        if (mydata["role"] == "student" && data["role"] == "mentor")
                          Center(
                            child: data["accepted"].contains(mydata["uid"])
                                ? RequestButton(text: "Connected", color: Colors.green)
                                : data["requested"].contains(mydata["uid"])
                                ? RequestButton(text: "Requested", color: Colors.grey)
                                : RequestButton(
                              text: "Request Mentor",
                              color: Colors.blue,
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Request Mentor"),
                                      content: Text(
                                          "Send a request to ${data['name']}?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            await FirebaseFirestore
                                                .instance
                                                .collection("users")
                                                .doc(data["uid"])
                                                .update({
                                              "requested":
                                              FieldValue.arrayUnion(
                                                  [user.uid])
                                            });
                                            await FirebaseFirestore
                                                .instance
                                                .collection("users")
                                                .doc(mydata["uid"])
                                                .update({
                                              "requested":
                                              FieldValue.arrayUnion(
                                                  [user.uid])
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
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey),
        SizedBox(width: 10),
        Text(
          "$label: ",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.blueGrey[600]),
          ),
        ),
      ],
    );
  }
}

class RequestButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback? onPressed;

  const RequestButton({
    Key? key,
    required this.text,
    required this.color,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }
}
