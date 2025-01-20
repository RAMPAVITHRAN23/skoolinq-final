import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skoolinq_project/Services/dbservice.dart';

import 'package:skoolinq_project/UserDetails/studentOrMentor.dart';
import 'package:skoolinq_project/mentors/mentorBottom.dart';
import 'package:skoolinq_project/student/bottomBar.dart';
class Checkdocument extends StatefulWidget {
  const Checkdocument({super.key});

  @override
  State<Checkdocument> createState() => _CheckdocumentState();
}

class _CheckdocumentState extends State<Checkdocument> {
  DBService dbService=DBService();
  @override
  Widget build(BuildContext context) {
    final user=Provider.of<User?>(context);
    return StreamBuilder(stream: dbService.checkDocument(user!.uid), builder: (context,snapshot){
      if(!snapshot.hasData) return Scaffold(
        body: Center(
          child: Text("loading"),
        ),
      );
      DocumentSnapshot documentSnapshot=snapshot.data;
      Map<String,dynamic> data=documentSnapshot.data() as  Map<String,dynamic>;
      if(data["avatarChoosed"]){
        if(data["role"]=="student") {
          return BottomBar();
        }else{
          return MentorBottom();
        }
      }



      return SelectionScreen();
    });
  }
}
