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
    final user = Provider.of<User?>(context);

    return Scaffold(
      backgroundColor: Color(0xFF1C1C1C), // Darker background color for better contrast
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Class Selection',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenHeight * 0.035, // Slightly larger title for emphasis
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centering the buttons vertically
            children: [
              SizedBox(height: screenHeight * 0.05),
              Text(
                'Choose Your Class',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenHeight * 0.035,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.05),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: screenWidth * 0.05,
                runSpacing: screenHeight * 0.03,
                children: [
                  _buildClassButton(context, '9', Class910(), screenWidth, screenHeight),
                  _buildClassButton(context, '10', Class910(), screenWidth, screenHeight),
                  _buildClassButton(context, '11', Class1112Page(), screenWidth, screenHeight),
                  _buildClassButton(context, '12', Class1112Page(), screenWidth, screenHeight),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              ElevatedButton(
                onPressed: selectedClass != null
                    ? () {
                  // Perform action on proceed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MentorBottom(), // Replace with the desired page
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // White background for the button
                  disabledBackgroundColor: Colors.grey, // Grey for disabled state
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.3,
                    vertical: screenHeight * 0.02,
                  ),
                ),
                child: Text(
                  'Proceed',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassButton(BuildContext context, String className, Widget page, double screenWidth, double screenHeight) {
    final user = Provider.of<User?>(context);

    return GestureDetector(
      onTap: () async {
        setState(() {
          selectedClass = className; // Set selected class
        });
        await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
          "class": className,
          "avatarChoosed": true,
        });
        Future.delayed(Duration(milliseconds: 200), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: screenWidth * 0.4,
        height: screenHeight * 0.12,
        decoration: BoxDecoration(
          color: selectedClass == className ? Color(0xFF176ADA) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selectedClass == className ? Colors.blue : Colors.grey,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: selectedClass == className
                  ? Color(0xFF0C3C7A) // Darker blue shadow when selected
                  : Color(0xFFBDBDBD), // Lighter shadow when not selected
              offset: Offset(0, 4),
              blurRadius: 8,
            )
          ],
        ),
        child: Center(
          child: Text(
            className,
            style: TextStyle(
              fontSize: screenHeight * 0.025,
              color: selectedClass == className ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
