import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../data/data_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchResultPage extends StatefulWidget {
  final String word;
  final List<dynamic> videoLinks;
  final List<dynamic> definitions;

  SearchResultPage({
    required this.word,
    required this.videoLinks,
    required this.definitions,
  });

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  late VideoPlayerController _controller;

  Future<void> addWordToVocabList(String word) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // request user ID
      String userId = currentUser.uid;

      DocumentReference vocabListRef = FirebaseFirestore.instance.collection('vocabLists').doc(userId);

    // create or update vocablist
     await vocabListRef.set({
        'words': FieldValue.arrayUnion([word]),  // add new word
        'lastUpdated': FieldValue.serverTimestamp()  // update the timestamp
      }, SetOptions(merge: true)).catchError((error) {
        print("Error adding word to vocab list: $error");
      });
    } else {
      print("User not logged in");
    }
  }
  
  @override
  void initState() {
    super.initState();
    if (widget.videoLinks.isNotEmpty) {
      _controller = VideoPlayerController.network(widget.videoLinks[0])
        ..initialize().then((_) {
          setState(() {}); // update UI
        }).catchError((error) {
          print("Error initializing video player: $error");
        });
      _controller.setLooping(true);
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCDB798),
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
                    SizedBox(width: 10),
                    Text(
                      widget.word,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, 
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (_controller.value.isInitialized)
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                else
                  Container(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    widget.definitions.isNotEmpty
                        ? widget.definitions.join(', ')
                        : 'No description available',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await addWordToVocabList(widget.word);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${widget.word} added to your vocabulary list'))
                    );
                  },
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
