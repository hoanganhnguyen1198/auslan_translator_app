import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:csit998_capstone_g16/models/words.dart'; // Update with the correct path

class ResultPage extends StatelessWidget {
  final Map<String, List<Definition>> results;

  const ResultPage({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: results.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ...entry.value.map((definition) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (definition.videoLinks.isNotEmpty)
                        VideoPlayerWidget(videoUrl: definition.videoLinks[0]),
                      SizedBox(height: 10),
                      Text(
                        'Keywords: ${definition.keywords.join(', ')}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      ...definition.definitions.entries.map((defEntry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              defEntry.key,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              defEntry.value.join(', '),
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                          ],
                        );
                      }).toList(),
                      Text(
                        'Regions: ${definition.regions.join(', ')}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                }).toList(),
                SizedBox(height: 20),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..addListener(() {
        if (_controller.value.isInitialized && !_isVideoInitialized) {
          setState(() {
            _isVideoInitialized = true;
            _isPlaying = _controller.value.isPlaying;
          });
        }
        if (_controller.value.isPlaying) {
          if (!_showControls) {
            setState(() {
              _showControls = true;
            });
            Future.delayed(Duration(seconds: 3), () {
              if (_controller.value.isPlaying) {
                setState(() {
                  _showControls = false;
                });
              }
            });
          }
        }
      })
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
          _isPlaying = _controller.value.isPlaying;
        });
        _controller.play();
      }).catchError((error) {
        // Handle any errors related to video playback
        print("Error initializing video: $error");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isVideoInitialized
        ? Stack(
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              if (_showControls)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                        Expanded(
                          child: VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Fullscreen logic can be added here
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          )
        : Center(child: CircularProgressIndicator());
  }
}
