import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import '../../utilities/sizeconfig.dart';

class Player extends StatefulWidget {
  final videoLink;
  final page;
  const Player({this.videoLink, this.page = true});
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  ChewieController? _chewieController;
  VideoPlayerController? videoPlayerController;
  var videoLink;
  var errorMessage;
  bool isDisposed = false;
  void initPlayer() async {
    videoLink = widget.videoLink;
    // await _downloadFile();
    // printvideoLink);
    videoPlayerController = VideoPlayerController.networkUrl((Uri.parse(videoLink)));
    _chewieController = ChewieController(
      allowedScreenSleep: false,
      useRootNavigator: false,
      videoPlayerController: videoPlayerController!,
      aspectRatio: 1,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color.fromARGB(255, 243, 84, 72),
        handleColor: const Color.fromARGB(255, 255, 106, 96),
        backgroundColor: Colors.grey,
        bufferedColor: Colors.grey,
      ),
      allowPlaybackSpeedChanging: true,
      autoInitialize: true,
      showControls: true,
      autoPlay: false,
      looping: true,
    );
  }

  Future<void> _downloadFile() async {
    try {
      var fileext = widget.videoLink.split('.').last;
      var filename = widget.videoLink.split('/').last;
      final dir = await getApplicationDocumentsDirectory();
      print('filename: $filename');
      var isExist = await File('${dir.path}/$filename').exists();
      print('isExist: $isExist');
      if (isExist) {
        videoLink = '${dir.path}/$filename';
        print('file.path: $videoLink');
        // return;
      } else {
        final response = await http.get(Uri.parse(widget.videoLink));
        // final filename = '${DateTime.now().millisecondsSinceEpoch}.${fileext}';
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(response.bodyBytes);
        print('file.path: ${file.path}');
        videoLink = file.path;
      }
    } catch (e) {
      if (!isDisposed) {
        setState(() {
          errorMessage = 'Error downloading audio: $e';
        });
      }
    }
  }

  void disposePlayer() {
    videoPlayerController!.dispose();
    _chewieController!.dispose();
    setState(() {
      isDisposed = true;
    });
    // widget.secureVideo(widget.folder, 1);
  }

  void resetPlayer() {
    // disposePlayer();
    initPlayer();
  }

  @override
  void initState() {
    initPlayer();
    super.initState();
  }

  @override
  void didUpdateWidget(Player oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoLink != widget.videoLink) {
      resetPlayer();
    }
  }

  Future getPostiton() async {
    var position = await _chewieController!.videoPlayerController.position;
    return position;
  }

  Future setPostiton(position) async {
    await _chewieController!.seekTo(position);
  }

  @override
  void dispose() {
    super.dispose();
    disposePlayer();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.page == true) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            "Video",
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ),
        body: _chewieController != null
            ? Container(
                // padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 3),
                height: SizeConfig.blockSizeVertical! * 40,
                child: Chewie(controller: _chewieController!),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      );
    }
    return _chewieController != null
        ? Chewie(controller: _chewieController!)
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}
