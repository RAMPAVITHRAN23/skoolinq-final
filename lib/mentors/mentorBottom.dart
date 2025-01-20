import 'package:flutter/material.dart';
import 'package:skoolinq_project/mentors/chatpersons.dart';
import 'package:skoolinq_project/mentors/mentorHomePage.dart';
import 'package:skoolinq_project/mentors/profile.dart';


import 'package:skoolinq_project/student/createpost.dart';

class MentorBottom extends StatefulWidget {
  const MentorBottom({super.key});

  @override
  State<MentorBottom> createState() => _MentorBottomState();
}

class _MentorBottomState extends State<MentorBottom> {
  List pages=[MentorHomePage(),CreatePost(),Chat(),Profile()];
  int current=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:pages[current],
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
        },
      ),
    );
  }
}
