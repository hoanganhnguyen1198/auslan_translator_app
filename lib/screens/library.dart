import 'package:flutter/material.dart';
import 'library_list.dart';

class AuslanLibraryScreen extends StatelessWidget {
  final List<String> categories = [
    "Animals",
    "Arithmetic",
    "Arts",
    "Body Parts",
    "Cars",
    "Cities",
    "Clothing",
    "Colors",
    "Cooking",
    "Days",
    "Deaf Culture",
    "Drinks",
    "Education"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 154),
                Text(
                  "Auslan Library",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                for (String category in categories)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6f8c51).withOpacity(0.6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LibraryListScreen(category: category),
                          ),
                        );
                      },
                      child: Text(category),
                    ),
                  ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
