import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:rxdart/rxdart.dart';


class DBService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Method to check if a document exists
  Future<bool> checkDocumentExists(String uid) async {
    try {
      var docSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return docSnapshot.exists;
    } catch (e) {
      print("Error checking document existence: $e");
      return false;
    }
  }

  // Method to get a stream of user document
  Stream checkDocument(String uid) {
    return firestore.collection("users").doc(uid).snapshots();
  }

  // Method to upload the profile picture to Firebase Storage
  Future<String> uploadProfilePicture(String uid, String filePath) async {
    try {
      File file = File(filePath);

      // Create a reference to the location where the file will be stored
      Reference ref = storage.ref().child("profile_pictures/$uid");

      // Upload the file
      await ref.putFile(file);

      // Get the URL of the uploaded file
      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print("Error uploading profile picture: $e");
      throw e;
    }
  }

  // Method to update user data (e.g., bio)
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await firestore.collection("users").doc(uid).update(data);
    } catch (e) {
      print("Error updating user data: $e");
      throw e;
    }
  }

  // Additional Firestore stream methods
  Stream posts() {
    return firestore.collection("posts").orderBy("timestamp", descending: true).snapshots();
  }

  Stream chatUsers(String chat) {
    return firestore.collection(chat).orderBy("timeStamp", descending: false).snapshots();
  }

  Stream users() {
    return firestore.collection("users").snapshots();
  }

  Stream Mentors({required int Class}) {
    return firestore.collection("users").where("role", isEqualTo: "mentor").where("classes", arrayContains: Class).snapshots();
  }

  Stream<List<Map<String, dynamic>>> search(String word) {
    final roleStream = FirebaseFirestore.instance
        .collection("users")
        .where("role", isGreaterThanOrEqualTo: word)
        .where("role", isLessThanOrEqualTo: word + '\uf8ff')
        .snapshots();

    final professionStream = FirebaseFirestore.instance
        .collection("users")
        .where("profession", isGreaterThanOrEqualTo: word)
        .where("profession", isLessThanOrEqualTo: word + '\uf8ff')
        .snapshots();

    final nameStream = FirebaseFirestore.instance
        .collection("users")
        .where("name", isGreaterThanOrEqualTo: word)
        .where("name", isLessThanOrEqualTo: word + '\uf8ff')
        .snapshots();

    final schoolNameStream = FirebaseFirestore.instance
        .collection("users")
        .where("schoolName", isGreaterThanOrEqualTo: word)
        .where("schoolName", isLessThanOrEqualTo: word + '\uf8ff')
        .snapshots();

    return CombineLatestStream.list([roleStream, professionStream, nameStream, schoolNameStream]).map((snapshots) {
      final List<Map<String, dynamic>> results = [];
      for (QuerySnapshot snapshot in snapshots) {
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          results.add(doc.data() as Map<String, dynamic>);
        }
      }
      final uniqueResults = results.toSet().toList();
      return uniqueResults;
    });
  }
}
