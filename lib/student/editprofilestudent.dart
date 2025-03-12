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
  late TextEditingController phone;
  String? selectedClass; // Stores selected class
  List<String> classList = ["9", "10", "11", "12"];
  String? selectedBoard;

  String? selectedExam;
  final List<String> exams = ['JEE', 'NEET', 'CUET'];
  late TextEditingController schoolName;

  @override
  void initState() {
    super.initState();
    name = TextEditingController();
    bio = TextEditingController();
    schoolName=TextEditingController();
    phone=TextEditingController();
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
          schoolName.text=data["schoolName"] ?? "";
          phone.text=data["phone"] ?? "";
          selectedBoard=data["board"] ?? "";
          selectedExam=data["selectedExam"] ?? null;

        });
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }
   saveProfileToFirebase( ) async{
     try {
       if(selectedExam!=null) {
         await FirebaseFirestore.instance.collection("users")
             .doc(widget.uid)
             .update({
           "name": name.text,
           "bio": bio.text,
           "class": selectedClass,
           "phone": phone.text,
           "schoolName": schoolName.text,
           "board": selectedBoard,
           "selectedExam":selectedExam!,
         });
       }
       else {
         await FirebaseFirestore.instance.collection("users")
             .doc(widget.uid)
             .update({
           "name": name.text,
           "bio": bio.text,
           "class": selectedClass,
           "phone": phone.text,
           "schoolName": schoolName.text,
           "board": selectedBoard,

         });
       }


       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Profile updated successfully!")),
       );
       Navigator.pop(context);
     } catch (e) {
       print("Error updating profile: $e");
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(e.toString())),
       );
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
            TextFormField(
              controller: phone,
              decoration: InputDecoration(labelText: 'Phone number'),
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

            _buildDropdown(),
            SizedBox(height: 20),
           selectedExam!=null ? _buildDropdownField(
              label: 'Select Exam',
              items: exams,
              value: selectedExam!,
              onChanged: (value) {
                setState(() {
                  selectedExam = value;
                });
              },
            ): SizedBox(),
            SizedBox(height: 20,),
            TextFormField(
              controller: schoolName,
              decoration: InputDecoration(labelText: 'School Name'),
            ),

            SizedBox(height: 40),
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
  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(

      value: selectedBoard,
      items: ['CBSE', 'ICSE', 'STATE BOARD']
          .map((board) => DropdownMenuItem(
        value: board,
        child: Text(board),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedBoard = value;
        });
      },
      decoration: InputDecoration(
        labelText: "Select Board",
      ),
      validator: (value) {
        if (value == null) {
          return 'Please select your board of education.';
        }
        return null;
      },
    );
  }
  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item, style: const TextStyle(color: Colors.black)),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),

        ),
        style: const TextStyle(color: Colors.black),
        validator: (value) {
          if (value == null) {
            return 'Please select an option';
          }
          return null;
        },
      ),
    );
  }
}
