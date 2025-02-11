import 'package:flutter/material.dart';
import 'package:skoolinq_project/mentors/chatpersons.dart';
import 'package:skoolinq_project/mentors/mentorHomePage.dart';
import 'package:skoolinq_project/mentors/viewprofile.dart';
import 'package:skoolinq_project/mentors/profile.dart';


import 'package:skoolinq_project/student/createpost.dart';

class MentorBottom extends StatefulWidget {
  const MentorBottom({super.key});

  @override
  State<MentorBottom> createState() => _MentorBottomState();
}

class _MentorBottomState extends State<MentorBottom> {
  int current = 0; // Current selected tab index
  final PageController _pageController = PageController(); // PageController for navigation

  // Function to switch tabs
  void _switchToProfile() {
    print("jjjjjjjjjjjjjj");
    setState(() {
      current = 3; // Set index to Profile
    });
    _pageController.jumpToPage(3); // Move to Profile Page
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(), // Disable swipe
        children: [
          MentorHomePage(onProfileNavigate: _switchToProfile),CreatePost(),Chat(),Profile()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF176ADA),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Create Post",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        currentIndex: current,
        onTap: (index) {
          setState(() {
            current = index;
          });
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}
