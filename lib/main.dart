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
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF4E7227),
          selectedItemColor: Color(0xFFF2F2F2),
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: AuslanLibraryScreen(),
    );
  }
}
