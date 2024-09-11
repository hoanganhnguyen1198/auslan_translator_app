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
      appBar: AppBar(
        title: Text('My Vocabulary List'),
      ),
      body: ListView.builder(
        itemCount: words.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(words[index]),
            onTap: () => navigateToSearchResult(words[index]), // 添加点击事件
          );
        },
      ),
    );
  }
}
