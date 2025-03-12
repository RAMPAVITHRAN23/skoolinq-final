import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MentorProfileEdit extends StatefulWidget {
  final String uid;
  const MentorProfileEdit({required this.uid, super.key});

  @override
  State<MentorProfileEdit> createState() => _MentorProfileEditState();
}

class _MentorProfileEditState extends State<MentorProfileEdit> {
  late TextEditingController name;
  late TextEditingController bio;
  late TextEditingController schoolName;
  late TextEditingController profession;
  late TextEditingController phonenum;

  final List<String> boardList = ['CBSE', 'ICSE', 'State Board'];
  final List<String> mentorTypeList = [
    'Student Mentor',
    'Working Mentor (In a job/Professional)',
    'Tutor (Individual subject teachers / tuition)',
    'Coaches (Coaching institutes or individual coaches for entrance exams)',
    'Consultants (Professional career or educational consultants)'
  ];

  List<int> selectedClasses = [];
  String? selectedMentorType;
  String? selectedBoard;

  @override
  void initState() {
    super.initState();
    name = TextEditingController();
    bio = TextEditingController();
    schoolName = TextEditingController();
    profession = TextEditingController();
    phonenum = TextEditingController();
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
          schoolName.text = data["schoolName"] ?? "";
          profession.text = data["profession"] ?? "";
          phonenum.text = data["phoneNumber"] ?? "";
          selectedClasses = List<int>.from(data["classes"] ?? []);
          selectedBoard = data["board"]?.toString();
          selectedMentorType = data["mentorType"]?.toString();
        });
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  void toggleSelection(int classNumber) {
    setState(() {
      if (selectedClasses.contains(classNumber)) {
        selectedClasses.remove(classNumber);
      } else if (selectedClasses.length < 2) {
        selectedClasses.add(classNumber);
      }
    });
  }

  Future<void> saveProfileToFirebase() async {
    try {
      if (phonenum.text.length == 10) {
        await FirebaseFirestore.instance.collection("users").doc(widget.uid).update({
          "name": name.text,
          "bio": bio.text,
          "classes": selectedClasses,
          "board": selectedBoard,
          "mentorType": selectedMentorType,
          "schoolName": schoolName.text,
          "profession": profession.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please check the phone number")),
        );
      }
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(name, 'Name', Icons.person),
                _buildTextField(phonenum, 'Phone Number', Icons.phone, keyboardType: TextInputType.number),
                _buildTextField(bio, 'Enter your bio', Icons.info),
                const SizedBox(height: 10),

                // Class Selection Grid
                const Text("Select Classes: (Maximum 2)", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [9, 10, 11, 12].map((classNumber) => _buildClassBox(classNumber)).toList(),
                ),
                const SizedBox(height: 20),

                // Dropdowns
                _buildDropdownField(
                  value: selectedBoard,
                  items: boardList,
                  label: 'Board of Education',
                  icon: Icons.school,
                  onChanged: (value) => setState(() => selectedBoard = value),
                ),
                const SizedBox(height: 20),

                _buildDropdownField(
                  value: selectedMentorType,
                  items: mentorTypeList,
                  label: 'Mentor Type',
                  icon: Icons.person_search,
                  onChanged: (value) => setState(() => selectedMentorType = value),
                ),
                const SizedBox(height: 20),

                _buildTextField(profession, 'Profession', Icons.work),
                _buildTextField(schoolName, 'School Name', Icons.school),

                // Save Button
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: saveProfileToFirebase,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text("Save Profile", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildClassBox(int classNumber) {
    final isSelected = selectedClasses.contains(classNumber);
    return GestureDetector(
      onTap: () => toggleSelection(classNumber),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.grey[400],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.white : Colors.transparent),
        ),
        child: Center(
          child: Text(
            '$classNumber',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String label,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      isExpanded: true,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
