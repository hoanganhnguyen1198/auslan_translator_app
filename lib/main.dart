import 'package:csit998_capstone_g16/screens/auth/PasswordRecoveryScreen.dart';
import 'package:csit998_capstone_g16/screens/auth/mainAuth.dart';
import 'package:csit998_capstone_g16/screens/auth/signupScreen.dart';
import 'package:csit998_capstone_g16/screens/auth/loginScreen.dart';
import 'package:csit998_capstone_g16/screens/libraryScreen/library.dart';
import 'package:csit998_capstone_g16/screens/userScreen/user.dart';
import 'package:csit998_capstone_g16/screens/userScreen/mylist.dart';

import 'package:csit998_capstone_g16/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            routes: {
              '/': (context) => const MainAuthScreen(),
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => SignUpScreen(),
              '/reset': (context) => PasswordRecoveryScreen(),
              '/library': (context) => AuslanLibraryScreen(),
              '/user': (context) => UserScreen(),
              '/vocabList': (context) => MyListScreen()
            },
            initialRoute: '/');
      },
    );
  }
}
