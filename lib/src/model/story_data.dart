import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

abstract class StoryData {
  const StoryData(
    this.contentFile, {
    required this.size,
  });

  final File contentFile;
  final Size size;

  ImageProvider get thumbnail;

  Future<void> precache(BuildContext context);

  void dispose();
}

class ImageStoryData extends StoryData {
  ImageStoryData(
    super.contentFile, {
    required super.size,
  });

  ImageProvider get imageProvider => FileImage(contentFile);

  @override
  ImageProvider get thumbnail => imageProvider;

  @override
  Future<void> precache(BuildContext context) async {
    await precacheImage(imageProvider, context);
  }

  @override
  void dispose() {
    imageProvider.evict();
  }
}

class VideoStoryData extends StoryData {
  VideoStoryData(
    super.contentFile, {
    required this.thumbnailFile,
    required super.size,
    required this.duration,
  });

  final File thumbnailFile;
  ImageProvider get thumbnailImageProvider => FileImage(thumbnailFile);

  final Duration duration;

  VideoPlayerController? _controller;
  VideoPlayerController get controller => _controller!;

  @override
  ImageProvider get thumbnail => FileImage(thumbnailFile);

  @override
  Future<void> precache(BuildContext context) async {
    _controller = VideoPlayerController.file(contentFile);

    await Future.wait([
      precacheImage(thumbnailImageProvider, context),
      _controller!.initialize(),
    ]);
  }

  @override
  void dispose() {
    thumbnailImageProvider.evict();
    _controller!.dispose();
  }
}
