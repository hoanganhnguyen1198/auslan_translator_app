import 'package:csit998_capstone_g16/screens/auth/mainAuth.dart';
import 'package:csit998_capstone_g16/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'screens/mainScreen/mainScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            scaffoldBackgroundColor: bgColor,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MainAuthScreen(),
        );
      },
    );
  }
}
