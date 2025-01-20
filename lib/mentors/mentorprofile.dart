import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Mentorprofile(),
    );
  }
}

class Mentorprofile extends StatefulWidget {
  const Mentorprofile({super.key});

  @override
  State<Mentorprofile> createState() => _MentorprofileState();
}

class _MentorprofileState extends State<Mentorprofile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String name = "John Doe"; // Initial name
  String bio = "Senior Software Engineer"; // Initial bio

  // Function to show the success dialog
  void _showUpdateDialog(String fieldName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("$fieldName Updated"),
          content: Text("Your $fieldName has been successfully updated!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Function to update name
  void _updateName() {
    setState(() {
      name = _nameController.text;
    });
    _showUpdateDialog('Name');
  }

  // Function to update bio
  void _updateBio() {
    setState(() {
      bio = _bioController.text;
    });
    _showUpdateDialog('Bio');
  }

  @override
  Widget build(BuildContext context) {
    final double divHeight = MediaQuery.of(context).size.height;
    final double divWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[900], // Background color for the whole page
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Section (No settings icon)
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Mentor Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: divHeight * 0.03,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: divHeight * 0.03),

              // Profile Picture Section
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.blue.withOpacity(0.3),
                      child: CircleAvatar(
                        radius: 65,
                        backgroundImage: NetworkImage(
                          'https://via.placeholder.com/150', // Replace with actual image URL
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () {
                          // Handle profile picture update
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: divHeight * 0.02),

              // Mentor Name
              Text(
                name,
                style: TextStyle(
                  fontSize: divHeight * 0.025,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: divHeight * 0.01),

              // Mentor Bio
              Text(
                bio,
                style: TextStyle(
                  fontSize: divHeight * 0.018,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[400],
                ),
              ),
              Divider(
                height: divHeight * 0.05,
                thickness: 2.0,
                color: Colors.grey[700],
              ),

              // Info Section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.grey[800],
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoRow(
                        icon: Icons.email_outlined,
                        label: "Email",
                        value: "johndoe@example.com",
                      ),
                      SizedBox(height: divHeight * 0.02),
                      InfoRow(
                        icon: Icons.phone_outlined,
                        label: "Phone",
                        value: "+1 234 567 890",
                      ),
                      SizedBox(height: divHeight * 0.02),
                      InfoRow(
                        icon: Icons.school_outlined,
                        label: "Experience",
                        value: "10+ Years in Software Development",
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: divHeight * 0.03),

              // Interactive Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ActionButton(
                    icon: Icons.message,
                    label: "Message",
                    color: Colors.blue,
                    onTap: () {
                      // Handle message action
                    },
                  ),
                  ActionButton(
                    icon: Icons.call,
                    label: "Call",
                    color: Colors.green,
                    onTap: () {
                      // Handle call action
                    },
                  ),
                  ActionButton(
                    icon: Icons.edit,
                    label: "Edit",
                    color: Colors.orange,
                    onTap: () {
                      _editProfile(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to show the Edit Profile dialog
  void _editProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit Name Field
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              SizedBox(height: 10),
              // Edit Bio Field
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: "Bio"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _updateName();
                _updateBio();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}

// Reusable InfoRow Widget
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 15),
        Text(
          "$label: ",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// Reusable ActionButton Widget
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
