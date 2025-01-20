import 'package:flutter/material.dart';
class Posting extends StatefulWidget {
  const Posting({super.key});

  @override
  State<Posting> createState() => _PostingState();
}

class _PostingState extends State<Posting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Center(
        child: Text("Posting",style: TextStyle(
          color: Colors.white
        ),),
      ),
    );
  }
}
