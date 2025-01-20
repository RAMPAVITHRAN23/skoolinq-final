import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:skoolinq_project/UserDetails/mentorDetails.dart';
import 'class_selection.dart';

class SelectionScreen extends StatefulWidget {
  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  String? selectedRole; // Variable to track the selected role

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final user=Provider.of<User?>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF202124),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add the logo image with dynamic height
            Image.asset(
              'assets/skoolinq logo2.png', // Path to the logo
              height: screenHeight * 0.1, // Adjusted to screen size
            ),
            SizedBox(
                height:
                    screenHeight * 0.05), // Spacing between logo and buttons

            // Loop for Student and Mentor buttons
            for (String role in ['Student', 'Mentor'])
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03),
                child: GestureDetector(
                  onTap: () async{
                    setState(() {
                      selectedRole = role; // Update the selected role
                    });

                    // Navigate based on the selected role
                    if (role == 'Student') {
                      // Navigate to the student selection page
                     await  FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
                        "role":role.toLowerCase(),
                       "uid":user!.uid,
                       "avatarChoosed":false,
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ClassSelectionPage()),
                      );
                    } else if (role == 'Mentor') {
                      // Navigate to the mentor selection page
                      await  FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
                        "role":role.toLowerCase(),
                        "uid":user!.uid,
                        "avatarChoosed":false,
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MentorDetails()),
                      );
                    }
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.025),
                    decoration: BoxDecoration(
                      color: selectedRole == role
                          ? const Color(0xFF176ADA) // Blue color when selected
                          : const Color(
                              0xFFD9D9D9), // Gray color when not selected
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      role,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selectedRole == role
                            ? Colors.white // White text when selected
                            : Colors.black, // Black text when not selected
                        fontSize: screenHeight * 0.02, // Dynamic font size
                        fontWeight: FontWeight.w600, // Semi-bold
                        fontFamily: 'Inter', // Inter font family
                      ),
                    ),
                    width: screenWidth * 0.8, // Dynamic button width
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
