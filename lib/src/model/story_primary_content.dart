import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:palette_generator/palette_generator.dart';
import 'package:story_composer/src/utils/ffmpeg.dart';
import 'package:story_composer/src/utils/precache_image_with_size.dart';
import 'package:video_player/video_player.dart';

abstract class StoryPrimaryContent {
  const StoryPrimaryContent();

  Size get size;
  List<Color> get paletteColors;

  Future<void> precache(BuildContext context);
  void dispose();
}

class ImageStoryPrimaryContent extends StoryPrimaryContent {
  ImageStoryPrimaryContent(this.imageProvider);

  final ImageProvider imageProvider;

  late Size _size;

  @override
  Size get size => _size;

  late List<Color> _paletteColors;

  @override
  List<Color> get paletteColors => _paletteColors;

  @override
  Future<void> precache(BuildContext context) async {
    final size = await precacheImageWithSize(imageProvider, context);

    if (size == null) {
      throw Exception('Failed to precache image');
    } else {
      _size = size;
    }

    final palette = await PaletteGenerator.fromImageProvider(imageProvider);
    _paletteColors = palette.colors.take(2).toList();
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

  late Size _size;
  late Duration _duration;

  Duration get duration => _duration;

  @override
  Size get size => _size;

  late List<Color> _paletteColors;

  @override
  List<Color> get paletteColors => _paletteColors;

  @override
  Future<void> precache(BuildContext context) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      fvp.registerWith(options: {
        'platforms': ['windows', 'macos', 'linux']
      });
    }

    _controller = VideoPlayerController.file(videoFile);

    await Future.wait([
      _controller!.initialize(),
      FfUtils.getVideoData(videoFile).then((result) {
        _size = result.$1;
        _duration = result.$2;
      }),
    ]);

    final firstFrame =
        await FfUtils.getSnapshotAtTimestamp(videoFile, Duration.zero);

    final palette = await PaletteGenerator.fromImage(firstFrame);
    _paletteColors = palette.colors.take(2).toList();
  }

  @override
  void dispose() {
    _controller?.dispose();
  }
}
