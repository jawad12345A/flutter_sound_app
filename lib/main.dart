import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:audioplayers/audio_cache.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'package:threading/threading.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MP3SCREEN(),
    );
  }
}

class MP3SCREEN extends StatefulWidget {
  @override
  _MP3SCREENState createState() => _MP3SCREENState();
}

class _MP3SCREENState extends State<MP3SCREEN> {
  AudioPlayer audioPlayer_song;
  double value_percent = 1.0;
  double value = 0;
  double song_duration ;
  @override
  Widget build(BuildContext context) {
    song_duration = 19;
    return Scaffold(
      appBar: AppBar(
        title: Text("Mp3 app"),
      ),
      body: new Container(
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: Text(
                  "Chicken.mp3",
                  style: TextStyle(fontSize: 20),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(icon: Image.asset("play.png",color: Colors.black,), onPressed: play),
                IconButton(icon: Image.asset("pause.png",color: Colors.black,), onPressed: pause),
                IconButton(icon: Image.asset("stop.png",color: Colors.black,), onPressed: stop)
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(
                    value: value_percent,
                    backgroundColor: Colors.grey,
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 10, right: 10,top: 2),
                      child: Text(value.ceil().toString())),
                  Text("/"),
                  Padding(
                      padding: EdgeInsets.only(left: 10,top: 2),
                      child: Text(song_duration.ceil().toString()))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }


  var thread;
  play() async {
    print("play");
    AudioCache audioPlayer = new AudioCache();

    if (audioPlayer_song != null &&
        audioPlayer_song.state == AudioPlayerState.PAUSED) {
      audioPlayer_song.resume();
      print("resumed");
    } else if(audioPlayer_song.state != AudioPlayerState.PLAYING){
      audioPlayer_song = await audioPlayer.play("chicken.mp3");
      audioPlayer_song.durationHandler =
          (p) => song_duration = p.inSeconds.roundToDouble();
      thread = new Thread(starttimer);
      thread.start();
    }

    //soundManager.playLocal("chicken.mp3").then((onValue) {

    //});
  }

  pause() {
    print("pause");
    audioPlayer_song.pause();
    //soundManager.pause();
  }

  stop() {
    print("stop");
    //soundManager.stop();
    audioPlayer_song.stop();
    value = 0;
    value_percent = 1.0;
    setState(() {});

  }

  Future starttimer() async {
    print(audioPlayer_song.state.toString());
    while (true) {
      if (audioPlayer_song.state == AudioPlayerState.COMPLETED ||
          audioPlayer_song.state == AudioPlayerState.STOPPED) {
        value_percent = 1;
        break;
      } else if (audioPlayer_song.state == AudioPlayerState.PLAYING ||
          audioPlayer_song.state == AudioPlayerState.PAUSED) {
        audioPlayer_song.positionHandler =
            (p) => value = p.inSeconds.roundToDouble();
        setState(() {
          print(value);
          value_percent = value / song_duration;
        });
        await Thread.sleep(500);
      }
    }
  }
}
