import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:skoolinq_project/Services/dbservice.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  late double divHeight, divWidth;
  TextEditingController post = TextEditingController();
  final formKey = GlobalKey<FormState>();
  File? pickedImage;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? selectedFile = await picker.pickImage(source: ImageSource.gallery);
    if (selectedFile != null) {
      setState(() {
        pickedImage = File(selectedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  Future<File> resizeImage(File imageFile) async {
    img.Image? image = img.decodeImage(await imageFile.readAsBytes());
    img.Image resizedImage =
    img.copyResize(image!, width: 600);
    return File(imageFile.path)
      ..writeAsBytesSync(img.encodeJpg(resizedImage));
  }

  Future<String> encodeImageToBase64(File imageFile) async {
    File resizedImage = await resizeImage(imageFile);
    final Uint8List imageBytes = await resizedImage.readAsBytes();
    return base64Encode(imageBytes);
  }

  DBService dbService = DBService();

  @override
  Widget build(BuildContext context) {
    divHeight = MediaQuery.of(context).size.height;
    divWidth = MediaQuery.of(context).size.width;
    final user = Provider.of<User?>(context);

    return StreamBuilder(
        stream: dbService.checkDocument(user!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator(color: Colors.blue)),
            );
          }

          DocumentSnapshot documentSnapshot = snapshot.data;
          Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

          return Scaffold(
            backgroundColor: const Color(0xFF0A2540),
            body: Form(
              key: formKey,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 2.0, color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue[100],
                        ),
                        height: divHeight * 0.4,
                        width: divWidth,
                        child: pickedImage != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(pickedImage!, fit: BoxFit.cover),
                        )
                            : Center(
                          child: Text(
                            "Tap here to pick an image from gallery",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: divHeight * 0.02),
                    TextFormField(
                      controller: post,
                      decoration: InputDecoration(
                        labelText: 'Post Content',
                        labelStyle: const TextStyle(color: Colors.blueAccent),
                        fillColor: Colors.blue[50],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Post Content cannot be empty';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: divHeight * 0.02),
                    ElevatedButton(
                      onPressed: () async {
                        EasyLoading.show(status: "Posting");
                        if (pickedImage != null &&
                            formKey.currentState!.validate()) {
                          EasyLoading.show(status: "Posting");
                          String base64Image =
                          await encodeImageToBase64(pickedImage!);

                          try {
                            await FirebaseFirestore.instance.collection("posts").add({
                              "post": post.text.toString(),
                              "uid": user!.uid,
                              "postedBy": data["name"],
                              "avatar": data["avatar"],
                              "postImg": base64Image,
                              "like": 0,
                              "timestamp": FieldValue.serverTimestamp(),
                            });
                            EasyLoading.dismiss();
                            post.clear();
                            setState(() {
                              pickedImage = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(seconds: 3),
                                backgroundColor: Colors.green,
                                content: Center(
                                  child: Text(
                                    "Post Added Successfully",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 17),
                                  ),
                                ),
                              ),
                            );
                          } catch (e) {
                            EasyLoading.showError("Compress the Image Please");
                          }
                        } else {
                          EasyLoading.showError("Please check the fields");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      ),
                      child: Text(
                        "Add Post",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
