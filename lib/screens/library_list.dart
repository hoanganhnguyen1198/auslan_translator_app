import 'package:flutter/material.dart';
import 'search_result.dart';
import 'package:video_player/video_player.dart';

class LibraryListScreen extends StatefulWidget {
  final String category;
  final List<dynamic> words;

  LibraryListScreen({required this.category, required this.words});

  @override
  _LibraryListScreenState createState() => _LibraryListScreenState();
}

class _LibraryListScreenState extends State<LibraryListScreen> {
  int _currentIndex = 2; // 将初始索引设置为2，即Library项

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
                SizedBox(height: 62),
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
                  ],
                ),
                SizedBox(height: 64), // 箭头和种类名称之间的距离
                Text(
                  widget.category,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                ...widget.words.map((word) => Padding(
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
                              builder: (context) => SearchResultPage(
                                word: word,
                                videoLinks: [
                                  'https://object-store.rc.nectar.org.au/v1/AUTH_92e2f9b70316412697cddc6f3ac0ee4e/staticauslanorgau/auslan/34/34820.mp4'
                                ],
                                definitions: [
                                  'The organ inside your body where food is digested; or the front part of your body below your waist. English = stomach, belly. Informal English = tummy. Medical or scientific English = abdomen.'
                                ],
                              ),
                            ),
                          );
                        },
                        child: Text(word),
                      ),
                    )),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 0) {
              Navigator.pushReplacementNamed(context, '/home');
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, '/search');
            } else if (index == 2) {
            } else if (index == 3) {
              Navigator.pushReplacementNamed(context, '/profile');
            }
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Auslan To Text',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
