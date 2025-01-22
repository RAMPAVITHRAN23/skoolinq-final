import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/dbservice.dart';

class View_profile extends StatefulWidget {
  final String uid;
  const View_profile({required this.uid,super.key});

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
      stream: dbService.checkDocument(widget.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        DocumentSnapshot document = snapshot.data!;
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.lightBlue[50],
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                children: [
                  // Header Section
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.blueGrey),
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

                  // Profile Picture
                  Center(
                    child: CircleAvatar(
                      radius: screenHeight * 0.1,
                      backgroundColor: Colors.blue.withOpacity(0.3),
                      child: CircleAvatar(
                        radius: screenHeight * 0.09,
                        backgroundImage: NetworkImage(data["profilePic"] ?? ""),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Name Section
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blueGrey),
                      SizedBox(width: screenWidth * 0.03),
                      Text(
                        data["name"] ?? "Name not set",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenHeight * 0.025,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Bio Section
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blueGrey),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: Text(
                          data["role"],
                          style: TextStyle(
                            fontSize: screenHeight * 0.02,
                            color: Colors.blueGrey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Info Section
                  Container(
                    padding: EdgeInsets.all(screenHeight * 0.02),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        InfoRow(
                          icon: Icons.people_alt_outlined,
                          label: "Followers",
                          value: (data["requested"].length + data["accepted"].length).toString(),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        InfoRow(
                          icon: Icons.location_on_outlined,
                          label: "Location",
                          value: data["location"] ?? "Not set",
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        InfoRow(
                          icon: Icons.post_add_outlined,
                          label: "Posts",
                          value: data["postsCount"]?.toString() ?? "0",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey),
        SizedBox(width: screenWidth * 0.03),
        Text(
          "$label: ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
            fontSize: screenHeight * 0.02,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.blueGrey[600],
              fontSize: screenHeight * 0.02,
            ),
          ),
        ),
      ],
    );
  }
}
