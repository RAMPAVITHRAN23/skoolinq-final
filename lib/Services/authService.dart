import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skoolinq_project/Account/checkAuth.dart';

class AuthService{
  //final dbService=DBService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<User?> get UserStream
  {
    return _auth.authStateChanges();
  }
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    forceCodeForRefreshToken: true,
  );

  Future<String?> signInWithGoogle( {required BuildContext context,}) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }
      print(googleUser);
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CheckAuth()));
      //print(dbService.checkDocumentExists(user!.uid));
     /* if (await dbService.checkDocumentExists(user!.uid)) {

        // User is signed in
        await dbService.getuserDetails(user!.uid);
        Get.offAll(()=>BottomNavigation(initialPageIndex: 0,),transition: Transition.rightToLeftWithFade);
      }
      else{
        showSnackBar(context: context, text: "This account is not yet registered");
        await SignOut();
      }*/
    } catch (e) {
      print("Error during Google Sign-In: $e");
    }
  }

  SignOut() async{
    await _auth.signOut();
    await _googleSignIn.signOut();
    EasyLoading.dismiss();
  }
}