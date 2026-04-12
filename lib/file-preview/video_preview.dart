import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  final String videoPath;
  VideoPreview({required this.videoPath});

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
          ..initialize().then((_) {
            setState(() {}); // Update the UI once the video is loaded
            // _videoController.play();
          });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
        decoration:
            BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
        child: Center(
          child: _videoController.value.isInitialized
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 200,
                      width: 200,
                      // aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                    IconButton(
                      icon: Icon(
                        _videoController?.value.isPlaying ?? false
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 50,
                        color: const Color.fromARGB(255, 247, 162, 106),
                      ),
                      onPressed: () {
                        setState(() {
                          if (_videoController!.value.isPlaying) {
                            _videoController!.pause();
                          } else {
                            _videoController!.play();
                          }
                        });
                      },
                    ),
                    // Video progress indicator
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: VideoProgressIndicator(
                        _videoController!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Colors.red,
                          bufferedColor: Colors.grey,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : CircularProgressIndicator(),
        ));
  }
}
