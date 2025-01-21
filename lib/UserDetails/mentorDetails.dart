import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'class.dart'; // Import the Avatar page (NextPage)

class MentorDetails extends StatefulWidget {
  const MentorDetails({super.key});

  @override
  State<MentorDetails> createState() => _MentorDetailsState();
}

class _MentorDetailsState extends State<MentorDetails> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();
  DateTime? birthDate;
  String? selectedBoard;
  String? selectedMentorType;
  bool isLoading = false;

  final List<String> boardList = ['CBSE', 'ICSE', 'State Board'];
  final List<String> mentorTypeList = [
    'Alumini',
    'Tutors',
    'Professional Members',
    'Entrance Exam Trainee'
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final user = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mentor Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF202124),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: screenHeight * 0.3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF176ADA), Color(0xFF202124)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.15),

                  // Full Name
                  _buildTextField(
                    controller: fullNameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    hint: 'Enter your full name',
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Profession
                  _buildTextField(
                    controller: phoneNumberController,
                    label: 'Profession',
                    icon: Icons.work,
                    hint: 'Enter your profession',
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // School Name (Optional)
                  _buildTextField(
                    controller: schoolNameController,
                    label: 'School Name',
                    icon: Icons.school,
                    hint: 'Enter your school name (optional)',
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Date of Birth (Optional)
                  GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: TextEditingController(
                          text: birthDate != null
                              ? '${birthDate!.day}-${birthDate!.month}-${birthDate!.year}'
                              : '',
                        ),
                        label: 'Date of Birth',
                        icon: Icons.calendar_today,
                        hint: 'Select your birthdate',
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Board Selection
                  _buildDropdownField(
                    value: selectedBoard,
                    items: boardList,
                    label: 'Board of Education',
                    icon: Icons.school,
                    onChanged: (value) => setState(() {
                      selectedBoard = value;
                    }),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Mentor Type Selection
                  _buildDropdownField(
                    value: selectedMentorType,
                    items: mentorTypeList,
                    label: 'Mentor Type',
                    icon: Icons.person_search,
                    onChanged: (value) => setState(() {
                      selectedMentorType = value;
                    }),
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  // Continue Button
                  Center(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.3,
                        ),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Continue',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _selectDate() async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ) ??
        DateTime.now();

    setState(() {
      birthDate = picked;
    });
  }

  bool _formValidation() {
    if (fullNameController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        selectedBoard == null ||
        selectedMentorType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return false;
    }
    return true;
  }

  Future<void> _submitForm() async {
    if (_formValidation()) {
      setState(() {
        isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .update({
            "name": fullNameController.text.trim(),
            "profession": phoneNumberController.text.trim(),
            "schoolName": schoolNameController.text.trim(),
            "birthDate": birthDate?.toIso8601String(),
            "board": selectedBoard,
            "mentorType": selectedMentorType,
          });
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ClassSelectorPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.white),
        fillColor: Colors.grey[800],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
      style: const TextStyle(color: Colors.white),
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
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        fillColor: Colors.grey[800],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
      dropdownColor: Colors.grey[800], // Dropdown background color
    );
  }
}
