import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

abstract class StoryPrimaryContent {
  const StoryPrimaryContent();

  Future<void> precache(BuildContext context);
  void dispose();
}

class ImageStoryPrimaryContent extends StoryPrimaryContent {
  const ImageStoryPrimaryContent(this.imageProvider);

  final ImageProvider imageProvider;

  @override
  Future<void> precache(BuildContext context) {
    return precacheImage(imageProvider, context);
  }

  @override
  void dispose() {
    imageProvider.evict();
  }
}

class VideoStoryPrimaryContent extends StoryPrimaryContent {
  VideoStoryPrimaryContent(this.videoFile);

  final File videoFile;

  VideoPlayerController? _controller;
  VideoPlayerController get controller => _controller!;

  @override
  Future<void> precache(BuildContext context) {
    _controller = VideoPlayerController.file(videoFile);
    return _controller!.initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
  }
}
