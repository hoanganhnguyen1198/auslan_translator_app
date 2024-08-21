import 'package:csit998_capstone_g16/screens/auth/login.dart';
import 'package:csit998_capstone_g16/screens/mainScreen/mainScreen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MainAuthScreen extends StatelessWidget {
  const MainAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Logo.png',
              scale: 4,
            ),
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                "Transforming Auslan to text and text to Auslan seamlessly.",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: 80.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(
                    height: 1.2,
                    fontFamily: 'Dubai',
                    fontSize: 13,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () {},
                child: const Text('Sign up with email'),
              ),
            ),
            GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => MainHomeScreen()));
                },
                child: Text("Already have an account? Log in"))
          ],
        ),
      ),
    );
  }
}
