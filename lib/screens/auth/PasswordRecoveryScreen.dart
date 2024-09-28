import 'package:flutter/material.dart';
import 'package:csit998_capstone_g16/utils/colors.dart';  
import 'package:firebase_auth/firebase_auth.dart';

class PasswordRecoveryScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  Future<void> sendPasswordResetEmail(String email, BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password recovery email sent!'))
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send password recovery email: ${error.toString()}'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            'assets/images/arrow.png',  // Path to your image asset
            width: 24,                  // Set the desired width
            height: 24,                 // Set the desired height
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Password Recovery'),
        backgroundColor: bgColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Enter your email address to recover your password.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: tfColor,
                hintText: 'example@email.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => sendPasswordResetEmail(_emailController.text, context),
              child: Text('Send Recovery Email'),
            ),
          ],
        ),
      ),
    );
  }
}
