import 'package:flutter/material.dart';
import 'package:csit998_capstone_g16/utils/colors.dart';  

class PasswordRecoveryScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recover Password'),
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
                hintText: 'example@email.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement sending recovery email logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password recovery email sent!')),
                );
              },
              child: Text('Send Recovery Email'),
            ),
          ],
        ),
      ),
    );
  }
}
