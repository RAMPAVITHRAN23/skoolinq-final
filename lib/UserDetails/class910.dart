import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'avatar.dart';

class Class910 extends StatefulWidget {
  const Class910({super.key});

  @override
  State<Class910> createState() => _Class910State();
}

class _Class910State extends State<Class910> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();
  DateTime? selectedDate;
  String? selectedBoard;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final user = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Title text color
          ),
        ),
        backgroundColor: Colors.blueAccent, // Main blue color
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // White color for icons (including back arrow)
      ),
      backgroundColor: Colors.blueGrey[50], // Light background color
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full Name
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Blue color for headings
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildTextField(
                controller: fullNameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name.';
                  }
                  return null;
                },
              ),

              SizedBox(height: screenHeight * 0.02),

              // Phone Number
              _buildTextField(
                controller: phoneNumberController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number.';
                  } else if (value.length != 10 ||
                      !RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'Enter a valid 10-digit phone number.';
                  }
                  return null;
                },
              ),

              SizedBox(height: screenHeight * 0.02),

              // School Name
              _buildTextField(
                controller: schoolNameController,
                label: 'School Name',
                icon: Icons.school,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your school name.';
                  }
                  return null;
                },
              ),

              SizedBox(height: screenHeight * 0.03),

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
                  padding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 1),
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Text(
                    selectedDate == null
                        ? 'Select your date of birth'
                        : '${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}',
                    style: TextStyle(
                      color:
                      selectedDate == null ? Colors.black54 : Colors.black,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Board of Education Dropdown
              const Text(
                'Board of Education',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.01),
              _buildDropdown(),

              SizedBox(height: screenHeight * 0.05),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select your date of birth.'),
                          ),
                        );
                        return;
                      }
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(user!.uid)
                          .update({
                        "name": fullNameController.text.trim(),
                        "dob":
                        '${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}',
                        "phone": phoneNumberController.text.trim(),
                        "schoolName": schoolNameController.text.trim(),
                        "board": selectedBoard,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Details updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                NextPage()), // Replace with actual page
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Blue color for button
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.25,
                      vertical: screenHeight * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
        Icon(icon, color: Colors.blueAccent), // Blue color for icons
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade50, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
          BorderSide(color: Colors.blueAccent), // Blue color for focus
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
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
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
          BorderSide(color: Colors.blueAccent), // Blue color for border
        ),
      ),
      validator: (value) {
        if (value == null) {
          return 'Please select your board of education.';
        }
        return null;
      },
    );
  }
}
