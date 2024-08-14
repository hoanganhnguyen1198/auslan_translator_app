import 'package:flutter/material.dart';
import 'screens/library.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auslan Library',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFCDB798),
      ),
      home: AuslanLibraryScreen(),
    );
  }
}
