import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skoolinq_project/Account/checkDocument.dart';

class NextPage extends StatefulWidget {
  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  int? _selectedAvatarIndex; // Track the selected avatar index

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isSmallScreen = screenWidth < 600;
    final user = Provider.of<User?>(context);

    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent background for gradient
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 10.0 : 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
              crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
              children: [
                SizedBox(height: screenHeight * 0.1), // Add space at the top
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(seconds: 1), // Smooth animation for opacity
                  child: const LabelText(text: "Choose your Avatar to continue your journey"),
                ),
                SizedBox(height: screenHeight * 0.03), // Adjusted spacing
                AvatarGrid(
                  screenWidth: screenWidth,
                  selectedAvatarIndex: _selectedAvatarIndex,
                  onAvatarSelected: (index) {
                    setState(() {
                      _selectedAvatarIndex = index;
                    });
                  },
                ),
                SizedBox(height: screenHeight * 0.05), // Adjusted spacing
                ElevatedButton(
                  onPressed: () async {
                    if (_selectedAvatarIndex != null) {
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(user!.uid)
                          .update({
                        "avatarChoosed": true,
                        "accepted": [],
                        "requested": [],
                        "avatar": _selectedAvatarIndex! + 1
                      });
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Checkdocument()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select an avatar to continue')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15), // Consistent padding
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 12, // Floating button effect
                    // side: const BorderSide(color: , width: 2),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LabelText extends StatelessWidget {
  final String text;

  const LabelText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center, // Center the heading text
      style: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700, // Bold weight for emphasis
        fontSize: 22, // Larger font size
        color: Colors.white,
      ),
    );
  }
}

class AvatarGrid extends StatelessWidget {
  final double screenWidth;
  final int? selectedAvatarIndex;
  final Function(int) onAvatarSelected;

  const AvatarGrid({
    super.key,
    required this.screenWidth,
    required this.selectedAvatarIndex,
    required this.onAvatarSelected,
  });

  @override
  Widget build(BuildContext context) {
    double avatarSize = screenWidth < 600 ? 90.0 : 110.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20, // Increased spacing between rows
        crossAxisSpacing: 20, // Increased spacing between columns
        childAspectRatio: 1,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        bool isSelected = selectedAvatarIndex == index;

        return GestureDetector(
          onTap: () {
            onAvatarSelected(index);
          },
          child: ClipOval(
            child: Container(
              decoration: BoxDecoration(
                border: isSelected
                    ? Border.all(color: Colors.blueAccent, width: 3)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(
                'assets/avatar_${index + 1}.jpg',
                fit: BoxFit.cover,
                width: avatarSize,
                height: avatarSize,
              ),
            ),
          ),
        );
      },
    );
  }
}
