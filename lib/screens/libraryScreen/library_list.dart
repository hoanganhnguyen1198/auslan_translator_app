import 'package:flutter/material.dart';
import 'search_result.dart';
import 'package:video_player/video_player.dart';
import '../../data/data_repository.dart';

class LibraryListScreen extends StatelessWidget {
  final String category;
  final List<dynamic> words; 

  LibraryListScreen({required this.category, required this.words});

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
                SizedBox(height: 64), 
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                ...words.map((word) => Padding(
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
                          _navigateToSearchResult(context, word);
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
    );
  }

  void _navigateToSearchResult(BuildContext context, String word) async {
    final libraryData = await LibraryData.loadLibraryData();
    final wordData = libraryData.data.firstWhere(
      (entry) => entry['entry_in_english'] == word,
      orElse: () => null,
    );

    if (wordData != null) {
      final firstSubEntry = wordData['sub_entries'][0];
      final videoLink = firstSubEntry['video_links'][0];  
      final definition = firstSubEntry['definitions'].values.first[0];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultPage(
            word: word,
            videoLinks: [videoLink], 
            definitions: [definition], 
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No data found for $word')),
      );
    }
  }
}

