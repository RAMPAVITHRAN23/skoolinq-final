import 'package:flutter/material.dart';
import 'package:skoolinq_project/student/chat.dart';
import 'package:skoolinq_project/student/home.dart';
import 'package:skoolinq_project/student/createpost.dart';
import 'package:skoolinq_project/student/search.dart';
import 'package:skoolinq_project/student/student_profile.dart';
class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  List pages=[Search(),HomePage(), CreatePost(),ChatPage(), Student_Profile()];
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
          BottomNavigationBarItem(icon: Icon(Icons.search),label: "Home",),
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
