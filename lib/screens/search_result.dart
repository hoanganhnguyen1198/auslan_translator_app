import 'package:flutter/material.dart';

class SearchResultPage extends StatelessWidget {
  final String word;
  final List<dynamic> videoLinks;
  final List<dynamic> definitions;

  SearchResultPage({
    required this.word,
    required this.videoLinks,
    required this.definitions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCDB798), // 背景颜色
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 62), // 箭头距离顶部的高度
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        'assets/images/arrow.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      word,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (videoLinks.isNotEmpty)
                  Image.network(
                    videoLinks[0],
                    fit: BoxFit.cover,
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    'Video description or other content goes here',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('SAVE TO MY LIST'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6f8c51).withOpacity(0.6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    minimumSize: Size(double.infinity, 50),
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
