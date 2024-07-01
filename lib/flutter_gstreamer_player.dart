// ignore_for_file: unnecessary_null_comparison, must_be_immutable, avoid_print

import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class GstPlayerTextureController {
  static const MethodChannel _channel =
      MethodChannel('flutter_gstreamer_player');

  var currentPlatform = Platform.operatingSystem;
  int textureId = 0;
  static int _id = 0;

  Future<int> initialize(String pipeline) async {
    // No idea why, but you have to increase `_id` first before pass it to method channel,
    // if not, receiver of method channel always received 0
    // if (currentPlatform == "ios") {
    GstPlayerTextureController._id = GstPlayerTextureController._id + 1;
    print("GstPlayerTextureController.id = $_id");
    // }
    textureId = await _channel.invokeMethod('PlayerRegisterTexture', {
      'pipeline': pipeline,
      'playerId': GstPlayerTextureController._id,
    });
    print("initialize textureId: $textureId");
    return textureId;
  }

  Future<void> dispose() {
    return _channel.invokeMethod('dispose', {'textureId': textureId});
  }

  bool get isInitialized => textureId != null;
}

class GstPlayer extends StatefulWidget {
  String pipeline;

  GstPlayer({Key? key, required this.pipeline}) : super(key: key);

  @override
  State<GstPlayer> createState() => _GstPlayerState();
}

class _GstPlayerState extends State<GstPlayer> {
  final _controller = GstPlayerTextureController();
  // GlobalKey key = GlobalKey();
  @override
  void initState() {
    initializeController();
    print("FIRST initializeController");
    super.initState();
  }

  @override
  void didUpdateWidget(GstPlayer oldWidget) {
    print("didUpdateWidget");
    if (widget.pipeline != oldWidget.pipeline) {
      print("widget.pipeline != oldwidget.pipeline");
      initializeController();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> initializeController() async {
    print("initializeController");
    await _controller.initialize(widget.pipeline);
    print("pipeline: ${widget.pipeline}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var currentPlatform = Platform.operatingSystem;
    switch (currentPlatform) {
      case 'linux':
      case 'android':
        print("gstreamer ANDROID textureId: ${_controller.textureId}");
        return Container(
          child: _controller.isInitialized
              ? Texture(textureId: _controller.textureId)
              : null,
        );

      case 'ios':
        String viewType = _controller.textureId.toString();
        final Map<String, dynamic> creationParams = <String, dynamic>{};
        print("on build textureId: $viewType ");
        return UiKitView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        );

      default:
        throw UnsupportedError('Unsupported platform view');
    }
  }
}
