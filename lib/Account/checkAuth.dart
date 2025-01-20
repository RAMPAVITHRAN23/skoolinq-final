import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skoolinq_project/Account/checkUserExist.dart';
import 'package:skoolinq_project/Account/intro.dart';
class CheckAuth extends StatefulWidget {
  const CheckAuth({super.key});

  @override
  State<CheckAuth> createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  @override
  Widget build(BuildContext context) {
    final user=Provider.of<User?>(context);
    if(user!=null){
      return CheckUserExist(uid: user!.uid,);
    }
    return IntroScreen();
  }
}
