// import 'package:btc_crm/utilities/sizeconfig.dart';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../utilities/sizeconfig.dart';

class AudioWavePlayer extends StatefulWidget {
  final String audioUrl;
  final bool isSender;
  final DateTime? timestamp;

  const AudioWavePlayer({
    Key? key,
    required this.audioUrl,
    this.isSender = true,
    this.timestamp,
  }) : super(key: key);

  @override
  State<AudioWavePlayer> createState() => _AudioWavePlayerState();
}

class _AudioWavePlayerState extends State<AudioWavePlayer>
    with WidgetsBindingObserver {
  late PlayerController playerController;
  bool isPlaying = false;
  bool isLoading = true;
  String? errorMessage;
  String? localFilePath;
  double playbackSpeed = 1.0;
  bool isDisposed = false;
  bool isCompleted = false;

  final List<double> speedOptions = [1.0, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
    _initializePlayer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseAudio();
    }
  }

  Future<void> _downloadFile() async {
    try {
      var fileext = widget.audioUrl.split('.').last;
      var filename = widget.audioUrl.split('/').last;
      final dir = await getApplicationDocumentsDirectory();
      print('filename: $filename');
      var isExist = await File('${dir.path}/$filename').exists();
      print('isExist: $isExist');
      if (isExist) {
        localFilePath = '${dir.path}/$filename';
        print('file.path: $localFilePath');
        // return;
      } else {
        final response = await http.get(Uri.parse(widget.audioUrl));
        // final filename = '${DateTime.now().millisecondsSinceEpoch}.${fileext}';
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(response.bodyBytes);
        print('file.path: ${file.path}');
        localFilePath = file.path;
      }
    } catch (e) {
      if (!isDisposed) {
        setState(() {
          errorMessage = 'Error downloading audio: $e';
        });
      }
    }
  }

  Future<void> _initializePlayer() async {
    try {
      await _downloadFile();

      if (localFilePath == null) {
        throw Exception('Failed to download audio file');
      }

      playerController = PlayerController();

      // Add listener for player completion
      playerController.onPlayerStateChanged.listen((state) {
        if (!isDisposed) {
          if (state == PlayerState.stopped || state == PlayerState.paused) {
            setState(() {
              isPlaying = false;
              isCompleted = true;
            });
          }
        }
      });

      // Add listener for duration updates
      playerController.onCurrentDurationChanged.listen((duration) {
        if (!isDisposed) {
          // Check if we've reached the end of the audio
          playerController.getDuration().then((totalDuration) {
            if (duration >= totalDuration) {
              setState(() {
                isPlaying = false;
                isCompleted = true;
              });
            }
          });
        }
      });

      await playerController.preparePlayer(
        path: localFilePath!,
        noOfSamples: 100,
        volume: 1.0,
      );

      if (!isDisposed) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (!isDisposed) {
        setState(() {
          errorMessage = 'Error initializing player: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPlayer() async {
    try {
      await playerController.seekTo(0);
      // await playerController.stopPlayer();

      // if (!isDisposed) {
      setState(() {
        isCompleted = false;
        // isDisposed = false;
        // isPlaying = false;
      });
      // }
    } catch (e) {
      print('Error resetting player: $e');
    }
  }

  Future<void> _pauseAudio() async {
    if (isPlaying) {
      await playerController.pausePlayer();
      if (!isDisposed) {
        setState(() {
          isPlaying = false;
        });
      }
    }
  }

  Future<void> _playPause() async {
    // print('isCompleted: $isCompleted');
    // print('isPlaying: $isPlaying');
    // print('isDisposed: $isDisposed');
    try {
      if (isCompleted) {
        // Reset player if audio was completed
        await _resetPlayer();
      }

      if (isPlaying) {
        await playerController.pausePlayer();
      } else {
        await playerController.startPlayer();
      }

      if (!isDisposed) {
        setState(() {
          isPlaying = !isPlaying;
        });
      }
    } catch (e) {
      // print('Error playing/pausing: $e');
    }
  }

  void _changePlaybackSpeed() {
    final currentIndex = speedOptions.indexOf(playbackSpeed);
    final nextIndex = (currentIndex + 1) % speedOptions.length;
    if (!isDisposed) {
      setState(() {
        playbackSpeed = speedOptions[nextIndex];
      });
    }
    playerController.setRate(playbackSpeed);
  }

  String _formatDuration(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
    // WidgetsBinding.instance.removeObserver(this);
    _pauseAudio();
    if (playerController.playerState.isInitialised) {
      playerController.dispose();
    }
    // if (localFilePath != null) {
    //   File(localFilePath!)
    //       .delete()
    //       .catchError((e) => print('Error deleting file: $e'));
    // }
  }

  Widget _buildPlayButton() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      child: IconButton(
        icon: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 24,
        ),
        onPressed: _playPause,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildWaveform() {
    // final hour = int.parse(widget.timestamp!.hour.toString().padLeft(2, '0'));
    // final minute =
    //     int.parse(widget.timestamp!.minute.toString().padLeft(2, '0'));
    // var du = hour + minute;
    return Expanded(
      child: AudioFileWaveforms(
        size: Size(MediaQuery.of(context).size.width * 0.5, 50),
        playerController: playerController,
        enableSeekGesture: true,
        animationDuration: Duration(milliseconds: 2000),
        waveformType: WaveformType.fitWidth,
        playerWaveStyle: PlayerWaveStyle(
          fixedWaveColor: const Color.fromARGB(255, 183, 188, 192),
          liveWaveColor: Colors.blue,
          spacing: 4,
          waveThickness: 3,
          waveCap: StrokeCap.round,
          showBottom: true,
          scaleFactor: 200,
        ),
      ),
    );
  }

  Widget _buildDuration() {
    return StreamBuilder<int>(
      stream: playerController.onCurrentDurationChanged,
      builder: (context, snapshot) {
        return Text(
          _formatDuration(snapshot.data ?? 0),
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue.shade900,
          ),
        );
      },
    );
  }

  Widget _buildTimestamp() {
    if (widget.timestamp == null) return const SizedBox.shrink();

    return Text(
      _formatTime(widget.timestamp!),
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey[600],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildContainer(
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return _buildContainer(
        child: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return _buildContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildPlayButton(),
              const SizedBox(width: 8),
              _buildWaveform(),
              const SizedBox(width: 8),
              _buildDuration(),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: _buildTimestamp(),
          ),
        ],
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      width: SizeConfig.blockSizeHorizontal! * 50,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: EdgeInsets.only(
        left: 8,
        right: 8,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(169, 241, 246, 252),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
