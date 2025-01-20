import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skoolinq_project/Account/checkAuth.dart';
import '../UserDetails/studentOrMentor.dart'; // Import the SelectionScreen file
class OptScreen extends StatefulWidget {
  final dynamic verifyId;
  const OptScreen({required this.verifyId,super.key});

  @override
  State<OptScreen> createState() => _OptScreenState();
}

class _OptScreenState extends State<OptScreen> {
TextEditingController _otpController=TextEditingController();
final _auth=FirebaseAuth.instance;
  Future<void> verifyOtp() async {

    if (widget.verifyId != null) {
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verifyId!,
          smsCode: _otpController.text.trim(),
        );

        await _auth.signInWithCredential(credential);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CheckAuth()),
        );
        print("User signed in successfully.");
      } catch (e) {
        print("Failed to verify OTP: $e");
      }
    }
  }

  @override

  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            Text(
              "Enter OTP",
              style: TextStyle(
                color: Colors.white,
                fontSize: screenHeight * 0.03,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              "Please enter the OTP",
              style: TextStyle(
                color: Colors.grey,
                fontSize: screenHeight * 0.02,
              ),
            ),
            SizedBox(height: screenHeight * 0.05),

            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                2,
                (index) => Container(
                  width: screenWidth * 0.15,
                  height: screenHeight * 0.08,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 195, 194, 194),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenHeight * 0.03,
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      counterText: "",
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.06),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: "Enter OTP",
              ),
              keyboardType: TextInputType.number,
            ),
            // Verify Button
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.07,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to SelectionScreen
                  verifyOtp();

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Colors.white, width: 2),
                ),
                child: Text(
                  "Verify",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenHeight * 0.02,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Resend OTP
            GestureDetector(
              onTap: () {
                _showOtpResentDialog(context);
              },
              child: Text(
                "Resend OTP",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: screenHeight * 0.018,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show the OTP resent dialog
  void _showOtpResentDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User cannot dismiss by tapping outside
      builder: (context) {
        return AlertDialog(
          title: Text(
            "OTP Resent",
            style:
                TextStyle(fontSize: MediaQuery.of(context).size.height * 0.025),
          ),
          content: Text(
            "Your OTP has been resent.",
            style:
                TextStyle(fontSize: MediaQuery.of(context).size.height * 0.02),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                "OK",
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.02),
              ),
            ),
          ],
        );
      },
    );
  }
}
