import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'avatar.dart'; // Import NextPage

class Class1112Page extends StatefulWidget {
  const Class1112Page({Key? key}) : super(key: key);

  @override
  _Class1112PageState createState() => _Class1112PageState();
}

class _Class1112PageState extends State<Class1112Page> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();
  DateTime? selectedDate; // Declare the selectedDate variable
  String? selectedBoard;
  String? selectedExam;

  final List<String> boards = ['CBSE', 'ICSE', 'State Board'];
  final List<String> exams = ['JEE', 'NEET', 'CUET'];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 600;
    final user = Provider.of<User?>(context);

    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Light background color
      appBar: AppBar(
        title: const Text(
          'Class 11/12 Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Title text color
          ),
        ),
        backgroundColor: Colors.blueAccent, // Main blue color
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 10.0 : 20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Heading text color
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildTextField(
                  controller: fullNameController,
                  label: 'Full Name',
                  icon: Icons.person,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Full name cannot be empty';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: phoneNumberController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number cannot be empty';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: schoolNameController,
                  label: 'School Name',
                  icon: Icons.school,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'School name cannot be empty';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                // Date of Birth
                const Text(
                  'Date of Birth',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenHeight * 0.01),
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 2),
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Text(
                      selectedDate == null
                          ? 'Select your date of birth'
                          : '${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}',
                      style: TextStyle(
                        color: selectedDate == null ? Colors.black54 : Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildDropdownField(
                  label: 'Select Board',
                  items: boards,
                  value: selectedBoard,
                  onChanged: (value) {
                    setState(() {
                      selectedBoard = value;
                    });
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildDropdownField(
                  label: 'Select Exam',
                  items: exams,
                  value: selectedExam,
                  onChanged: (value) {
                    setState(() {
                      selectedExam = value;
                    });
                  },
                ),
                SizedBox(height: screenHeight * 0.05),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(user!.uid)
                            .update({
                          "name": fullNameController.text.toLowerCase(),
                          "dob": selectedDate != null
                              ? '${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}'
                              : 'Not provided', // Handle empty date case
                          "phone": phoneNumberController.text,
                          "schoolName": schoolNameController.text.toLowerCase(),
                          "board": selectedBoard!,
                          "selectedExam": selectedExam!,
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NextPage()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Blue color for button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(isSmallScreen ? 200 : 250, 50),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue.shade50, width: 2),
          ),
        ),
        style: const TextStyle(color: Colors.black),
      ),
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
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
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
