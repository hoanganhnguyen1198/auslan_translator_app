import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'library_list.dart';
import '../data/data_repository.dart';

class AuslanLibraryScreen extends StatefulWidget {
  @override
  _AuslanLibraryScreenState createState() => _AuslanLibraryScreenState();
}

class _AuslanLibraryScreenState extends State<AuslanLibraryScreen> {
  Map<String, dynamic> categories = {};

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final String response =
        await rootBundle.loadString('assets/categories.json');
    final data = await json.decode(response);
    setState(() {
      categories = data;
    });
  }

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
                ...categories.keys.map((category) => Padding(
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
                              builder: (context) => LibraryListScreen(
                                category: category,
                                words: categories[category],
                              ),
                            ),
                          );
                        },
                        child: Text(category),
                      ),
                    )),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
