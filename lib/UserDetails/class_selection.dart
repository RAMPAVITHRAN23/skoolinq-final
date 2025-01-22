import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skoolinq_project/mentors/mentorBottom.dart';
import 'class910.dart';
import 'class1112.dart';

class ClassSelectionPage extends StatefulWidget {
  @override
  _ClassSelectionPageState createState() => _ClassSelectionPageState();
}

class _ClassSelectionPageState extends State<ClassSelectionPage> {
  String? selectedClass; // Tracks the currently selected class

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final user=Provider.of<User?>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF202124), // Background color #202124
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05), // Dynamic horizontal padding
        child: Column(
          children: [
            SizedBox(
                height: screenHeight * 0.1), // Dynamic distance from the top
            Center(
              child: Text(
                'Choose your class',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenHeight * 0.03, // Dynamic font size for title
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
                height: screenHeight * 0.05), // Dynamic spacing below the title
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildClassButton(context, '9', Class910(), screenWidth,
                        screenHeight),
                    SizedBox(
                        width:
                        screenWidth * 0.05), // Dynamic horizontal spacing
                    _buildClassButton(context, '10', Class910(),
                        screenWidth, screenHeight),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03), // Dynamic spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildClassButton(context, '11', Class1112Page(),
                        screenWidth, screenHeight),
                    SizedBox(
                        width:
                        screenWidth * 0.05), // Dynamic horizontal spacing
                    _buildClassButton(context, '12', Class1112Page(),
                        screenWidth, screenHeight),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassButton(BuildContext context, String className, Widget page,
      double screenWidth, double screenHeight) {
    final user=Provider.of<User?>(context);
    return ElevatedButton(
      onPressed: () async{

        await  FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
          "class":className,
          "avatarChoosed":true,
        });
        Future.delayed(Duration(milliseconds: 200), () {
          // Slight delay for visual effect
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>page),
          );
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedClass == className
            ? const Color(0xFF176ADA) // Blue shade #176ADA
            : const Color(0xFFD9D9D9), // Grey shade #D9D9D9
        minimumSize:
        Size(screenWidth * 0.4, screenHeight * 0.12), // Dynamic button size
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        className,
        style: TextStyle(
          fontSize: screenHeight * 0.025, // Dynamic font size for class name
          color: selectedClass == className
              ? Colors.white // White text on blue
              : Colors.black, // Black text on grey
        ),
      ),
    );
  }
}