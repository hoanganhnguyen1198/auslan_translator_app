import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../libraryScreen/search_result.dart';
import 'package:video_player/video_player.dart';
import '../../data/data_repository.dart';

class MyListScreen extends StatefulWidget {
  @override
  _MyListScreenState createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  List<String> words = [];

  @override
  void initState() {
    super.initState();
    fetchVocabList();
  }

  Future<void> fetchVocabList() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('vocabLists').doc(userId).get();
      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          words = List.from(data['words']);
        });
      }
    }
  }

  void navigateToSearchResult(String word) async {
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
            showSaveButton: false,  
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No data found for $word')),
      );
    }
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
                  'My Vocabulary List',
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
                    onPressed: () => navigateToSearchResult(word),
                    child: Text(word),
                  ),
                )).toList(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
