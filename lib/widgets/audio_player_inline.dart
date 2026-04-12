import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerInline extends StatefulWidget {
  final url;

  const AudioPlayerInline(this.url);

  @override
  State<AudioPlayerInline> createState() => _AudioPlayerInlineState();
}

class _AudioPlayerInlineState extends State<AudioPlayerInline> {
  var player;
  var duration;
  @override
  initState() {
    initPlayer();
  }

  initPlayer() async {
    player = AudioPlayer();
  }

  bool _isClicked = false;
  bool _isVClicked = false;
  int maxduration = 100;
  int currentpos = 0;
  String currentpostlabel = "00:00";
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        // color: Color.fromARGB(255, 78, 118, 236),
      ),
      // width: SizeConfig.blockSizeHorizontal! * 98,
      child: Row(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              // focusColor: Colors.transparent,
              // highlightColor: Colors.transparent,
              onPressed: () async {
                if (_isClicked) {
                  await player.stop();
                } else {
                  duration = await player.setUrl(widget.url);
                  // duration = await player.setUrl(_isClicked);
                  // player.play();
                  await player.play();
                }
                setState(() {
                  _isClicked = !_isClicked;
                });
              },
              icon: _isClicked
                  ? Icon(
                      Icons.stop,
                      size: 36,
                      color: Colors.blue,
                    )
                  : Icon(
                      Icons.play_arrow,
                      size: 36,
                      color: Colors.blue,
                    )),
        ),
        // Container(
        //     child: Slider(
        //   activeColor: Color.fromARGB(255, 222, 243, 239),
        //   thumbColor: Color.fromARGB(255, 90, 96, 222),
        //   inactiveColor: Colors.grey[100],
        //   value: double.parse(currentpos.toString()),
        //   min: 0,
        //   max: double.parse(maxduration.toString()),
        //   divisions: maxduration,
        //   label: currentpostlabel,
        //   onChanged: (double value) async {
        //     int seekval = value.round();
        //     int result = await player.seek(Duration(milliseconds: seekval));
        //     if (result == 1) {
        //       //seek successful
        //       currentpos = seekval;
        //     } else {
        //     // print("Seek unsuccessful.");
        //     }
        //   },
        // )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () async {
                if (_isVClicked) {
                  await player.setVolume(1.0);
                } else {
                  await player.setVolume(0.5);
                }
                setState(() {
                  _isVClicked = !_isVClicked;
                });
              },
              icon: _isVClicked
                  ? Icon(
                      Icons.volume_down,
                      size: 36,
                      color: Colors.blue,
                    )
                  : Icon(
                      Icons.volume_up,
                      size: 36,
                      color: Colors.blue,
                    )),
        ),
      ]),
    );
  }
}
