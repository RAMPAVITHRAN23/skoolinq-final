import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
class EditProfileStudent extends StatefulWidget {
  final String uid;
  const EditProfileStudent({required this.uid,super.key});

  @override
  State<EditProfileStudent> createState() => _EditProfileStudentState();
}

class _EditProfileStudentState extends State<EditProfileStudent> {
  late TextEditingController name;
  late TextEditingController bio;
  String? selectedClass; // Stores selected class
  List<String> classList = ["9", "10", "11", "12"];

  @override
  void initState() {
    super.initState();
    name = TextEditingController();
    bio = TextEditingController();
   // stclass = TextEditingController();
    getDetails();
  }

  Future<void> getDetails() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uid)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
        documentSnapshot.data() as Map<String, dynamic>;

        setState(() {
          name.text = data["name"] ?? "";
          bio.text = data["bio"] ?? "";
          selectedClass = data["class"] ?? "";
        });
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }
   saveProfileToFirebase( ) async{
     try {
       await FirebaseFirestore.instance.collection("users").doc(widget.uid).update({
         "name": name.text,
         "bio": bio.text,
         "class": selectedClass,
       });

       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Profile updated successfully!")),
       );
       Navigator.pop(context);
     } catch (e) {
       print("Error updating profile: $e");
     }
  }
  @override
  void initstate()async{
   await getDetails();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [

            SizedBox(height: 20),
            TextFormField(
              controller: name,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: bio,
              decoration: InputDecoration(labelText: 'Bio'),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedClass,
              decoration: InputDecoration(labelText: "Class"),
              items: classList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedClass = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: ()async{
               await saveProfileToFirebase();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
