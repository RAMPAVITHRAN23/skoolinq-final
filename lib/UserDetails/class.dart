import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skoolinq_project/Account/checkDocument.dart';
import 'package:skoolinq_project/mentors/mentorBottom.dart';
import '../mentors/welcome.dart'; // Import the WelcomeScreen

class ClassSelectorPage extends StatefulWidget {
  const ClassSelectorPage({Key? key}) : super(key: key);

  @override
  _ClassSelectorPageState createState() => _ClassSelectorPageState();
}

class _ClassSelectorPageState extends State<ClassSelectorPage> {
  final List<int> selectedClasses = []; // List of selected class numbers

  void toggleSelection(int classNumber) {
    setState(() {
      if (selectedClasses.contains(classNumber)) {
        selectedClasses.remove(classNumber);
      } else if (selectedClasses.length < 2) {
        selectedClasses.add(classNumber);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user=Provider.of<User?>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF202124),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'HELLO THERE!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Class you prefer handling',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildClassBox(9),
                    const SizedBox(width: 16),
                    _buildClassBox(10),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildClassBox(11),
                    const SizedBox(width: 16),
                    _buildClassBox(12),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: selectedClasses.isNotEmpty
                  ? () async{
                      // Convert selectedClasses (List<int>) to List<String>
                await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
                  "classes":selectedClasses.toString(),
                  "avatarChoosed":true,
                  "requested":[],
                  "accepted":[],
                });

                      final selectedClassesStrings = selectedClasses
                          .map((classNumber) => 'Class $classNumber')
                          .toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>Checkdocument(),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF176ADA),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassBox(int classNumber) {
    final isSelected = selectedClasses.contains(classNumber);
    return GestureDetector(
      onTap: () => toggleSelection(classNumber),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF176ADA) : Colors.grey,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: Center(
          child: Text(
            '$classNumber',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
