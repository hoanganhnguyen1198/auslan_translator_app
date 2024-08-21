import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.videoLinks.isNotEmpty) {
      _controller = VideoPlayerController.network(widget.videoLinks[0])
        ..initialize().then((_) {
          setState(() {}); // 更新UI
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
                        color: Colors.black, // 文字颜色
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
