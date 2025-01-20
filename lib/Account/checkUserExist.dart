import 'package:flutter/material.dart';
import 'package:skoolinq_project/Account/checkDocument.dart';
import 'package:skoolinq_project/Services/dbservice.dart';

import 'package:skoolinq_project/UserDetails/studentOrMentor.dart';

class CheckUserExist extends StatefulWidget {
  final String uid;
  const CheckUserExist({required this.uid, super.key});

  @override
  State<CheckUserExist> createState() => _CheckUserExistState();
}

class _CheckUserExistState extends State<CheckUserExist> {
  DBService dbservice = DBService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: dbservice.checkDocumentExists(widget.uid), // Ensure this returns a Future<bool>
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.hasData) {
          bool documentExists = snapshot.data ?? false;
          if (documentExists) {

            return Checkdocument();
          } else {
            return SelectionScreen();
          }
        }

        return Scaffold(
          body: Center(
            child: Text('No data found'),
          ),
        );
      },
    );
  }
}
