// ignore_for_file: must_be_immutable, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gstreamer_player/flutter_gstreamer_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _pipeline = "";
    switch (defaultTargetPlatform) {
      case (TargetPlatform.linux):
      case (TargetPlatform.android):
        _pipeline = '''udpsrc port=8269 !
     application/x-rtp, media=video, clock-rate=90000, encoding-name=H264 !
      rtph264depay !
      queue !
      h264parse !
      tee name=t t. !
      decodebin !
      queue !
      videoconvert !
      video/x-raw,format=RGBA !
      appsink name=sink sync=false''';
        break;
      case (TargetPlatform.iOS):
        _pipeline = '''udpsrc port=8269 !
      application/x-rtp, media=video, clock-rate=90000, encoding-name=H264 !
      rtph264depay !
      queue !
      h264parse !
      tee name=t t. !
      decodebin !
      queue !
      glimagesink''';
        break;
      default:
        break;
    }
    print(_pipeline);

    return MaterialApp(
      home: Scaffold(
        body: GstPlayer(pipeline: _pipeline),
      ),
    );
  }
}
