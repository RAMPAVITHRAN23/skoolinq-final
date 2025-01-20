import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';

class WelcomeScreen extends StatefulWidget {
  final List<String> selectedClasses;

  const WelcomeScreen({required this.selectedClasses, Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  File? _profileImage;
  double profileCompletion = 0.75; // Profile completion percentage (0 to 1)

  Future<void> _pickImage() async {
    // Implement image picker logic here (optional)
  }

  void _updateProfileCompletion() {
    setState(() {
      // Update profile completion dynamically for testing
      profileCompletion = (profileCompletion + 0.1).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isSmallScreen = screenWidth < 600;

    // Dynamically set the color based on profile completion
    Color completionColor = profileCompletion == 1
        ? Colors.green
        : profileCompletion >= 0.75
        ? Colors.yellowAccent
        : Colors.orange;

    return Scaffold(
      backgroundColor: const Color(0xFF202124),
      body: Stack(
        children: [
          // Animated Gradient Background
          AnimatedContainer(
            duration: const Duration(seconds: 6),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2027), Color(0xFF176ADA)],
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade300, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade800.withOpacity(0.7),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              width: isSmallScreen ? screenWidth * 0.85 : 400,
              height: isSmallScreen ? screenHeight * 0.65 : 480,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [Color(0xFF42A5F5), Color(0xFF0D47A1)],
                        ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      // Profile Avatar with dynamic completion status
                      CircleAvatar(
                        radius: isSmallScreen ? 55 : 65,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                        child: _profileImage == null
                            ? const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 60,
                        )
                            : null,
                      ),
                      // Profile completion circle
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: completionColor,
                          child: Text(
                            '${(profileCompletion * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue, // Apply 60% opacity
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    "Selected Classes:\n${widget.selectedClasses.join(', ')}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 40 : 70,
                        vertical: 15,
                      ),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      shadowColor: Colors.blueAccent.withOpacity(0.5),
                      elevation: 8,
                    ),
                    onPressed: _updateProfileCompletion, // Trigger profile completion update
                    child: const Text(
                      "Update Completion",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
