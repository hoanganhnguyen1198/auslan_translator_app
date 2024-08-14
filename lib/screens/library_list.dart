import 'package:flutter/material.dart';

class LibraryListScreen extends StatelessWidget {
  final String category;

  LibraryListScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 62),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    'assets/images/arrow.png',
                    width: 24,
                    height: 24,
                  ),
                ),
                SizedBox(height: 72),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                for (int i = 0; i < 10; i++)
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
                        // 按钮点击事件
                      },
                      child: Text('Item ${i + 1}'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
