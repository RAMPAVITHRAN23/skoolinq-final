import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../Account/checkAuth.dart';
import '../services/dbservice.dart';
import '../services/authservice.dart';
import '../services/loading.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late double divHeight, divWidth;
  DBService dbService = DBService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  String? newProfilePic;
  bool isEditingName = false;
  bool isEditingBio = false;

  @override
  Widget build(BuildContext context) {
    divHeight = MediaQuery.of(context).size.height;
    divWidth = MediaQuery.of(context).size.width;
    final user = Provider.of<User?>(context);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "User not logged in",
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }

    return StreamBuilder(
      stream: dbService.checkDocument(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Loading();
        DocumentSnapshot document = snapshot.data!;
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        nameController.text = data["name"] ?? "";
        bioController.text = data["bio"] ?? "";

        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.lightBlue[50], // Full background color
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                          color: Colors.blueGrey[800],
                          fontSize: divHeight * 0.035,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Navigate to settings
                        },
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: divHeight * 0.03),

                  // Profile Picture with Update Option
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.blue.withOpacity(0.3),
                          child: CircleAvatar(
                            radius: 65,
                            backgroundImage: newProfilePic != null
                                ? NetworkImage(newProfilePic!)
                                : NetworkImage(data["profilePic"] ?? ""),
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () async {
                              final pickedImage = await _imagePicker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (pickedImage != null) {
                                EasyLoading.show(status: "Uploading...");
                                String imageUrl =
                                await dbService.uploadProfilePicture(
                                  user.uid,
                                  pickedImage.path,
                                );
                                setState(() {
                                  newProfilePic = imageUrl;
                                });

                                // Save the new profile picture URL in Firebase
                                dbService.updateUserData(
                                  user.uid,
                                  {"profilePic": imageUrl},
                                );

                                EasyLoading.dismiss();
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
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

                  // Editable User Name Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          style: TextStyle(
                            fontSize: divHeight * 0.03,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                          decoration: InputDecoration(
                            labelText: "Name",
                            labelStyle: TextStyle(
                              color: Colors.blueGrey[600],
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueGrey[600]!),
                            ),
                          ),
                          enabled: isEditingName,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isEditingName ? Icons.check : Icons.edit,
                          color: Colors.blueGrey,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isEditingName) {
                              EasyLoading.show(status: "Saving Name...");
                              dbService.updateUserData(
                                user.uid,
                                {"name": nameController.text.trim()},
                              ).then((_) {
                                EasyLoading.dismiss();
                                setState(() {
                                  isEditingName = false;
                                });
                              });
                            } else {
                              isEditingName = true;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: divHeight * 0.02),

                  // Bio Section with Edit Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Bio",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isEditingBio ? Icons.check : Icons.edit,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isEditingBio) {
                              EasyLoading.show(status: "Saving Bio...");
                              dbService.updateUserData(
                                user.uid,
                                {"bio": bioController.text.trim()},
                              ).then((_) {
                                EasyLoading.dismiss();
                                setState(() {
                                  isEditingBio = false;
                                });
                              });
                            } else {
                              isEditingBio = true;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[100], // Using a light blue background for bio
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: bioController,
                      enabled: isEditingBio,
                      maxLength: 150,
                      decoration: const InputDecoration(
                        hintText: "Enter your bio",
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.blueGrey),
                    ),
                  ),
                  SizedBox(height: divHeight * 0.03),

                  // Info Section (Followers, Email, Location, Posts)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[200], // Light blue container for info section
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoRow(
                          icon: Icons.people_alt_outlined,
                          label: "Followers",
                          value: (data["requested"].length+data["accepted"].length).toString(),
                        ),
                        SizedBox(height: divHeight * 0.02),
                        InfoRow(
                          icon: Icons.email_outlined,
                          label: "Email",
                          value: user.email ?? "Not available",
                        ),
                        SizedBox(height: divHeight * 0.02),
                        InfoRow(
                          icon: Icons.location_on_outlined,
                          label: "Location",
                          value: data["location"] ?? "Not set",
                        ),
                        SizedBox(height: divHeight * 0.02),
                        InfoRow(
                          icon: Icons.post_add_outlined,
                          label: "Posts",
                          value: data["postsCount"]?.toString() ?? "0",
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: divHeight * 0.03),

                  // Log Out Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 25),
                      backgroundColor: Colors.red[600], // Red button for log out
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CheckAuth()));
                      await AuthService().SignOut();
                    },
                    icon: const Icon(Icons.exit_to_app, color: Colors.white),
                    label: const Text(

                      "Log Out",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.blueGrey,
          size: 24,
        ),
        SizedBox(width: 10),
        Text(
          "$label: ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.blueGrey[600],
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
