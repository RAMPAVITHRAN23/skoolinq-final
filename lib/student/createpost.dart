import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  TextEditingController captionController = TextEditingController();
  File? selectedImage;

  // Function to pick an image from the gallery
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to upload the post to Firestore
  Future<void> uploadPost() async {
    if (selectedImage == null || captionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add an image and a caption!')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    // Upload post to Firestore
    await FirebaseFirestore.instance.collection('posts').add({
      'imagePath': selectedImage!.path,
      'caption': captionController.text,
      'user': user?.displayName ?? 'Anonymous',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Pop the screen after post is uploaded
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
        backgroundColor: Colors.blueAccent, // Blue background for app bar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Back arrow icon
          onPressed: () {
            Navigator.pop(context); // Go back when the back arrow is pressed
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage, // Allow user to pick an image from the gallery
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[50], // Light blue background for image picker area
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  border: Border.all(color: Colors.blueAccent, width: 2), // Blue border around the image picker
                ),
                child: selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(selectedImage!, fit: BoxFit.cover),
                )
                    : Icon(Icons.add_a_photo, color: Colors.blueAccent, size: 50),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: captionController,
              decoration: InputDecoration(
                labelText: 'Caption',
                labelStyle: TextStyle(color: Colors.blueAccent), // Blue label text
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent), // Blue border for the text field
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2), // Blue border when focused
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadPost, // Upload the post to Firestore
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Blue button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners for the button
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Text(
                'Post',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text for contrast
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
