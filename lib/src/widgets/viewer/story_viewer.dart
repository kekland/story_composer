import 'package:flutter/widgets.dart';
import 'package:story_composer/src/model/story_data.dart';
import 'package:video_player/video_player.dart';

class StoryViewerWidget extends StatefulWidget {
  const StoryViewerWidget({
    super.key,
    required this.data,
    this.fit,
    this.thumbnailOnly = false,
  });

  const StoryViewerWidget.thumbnail({
    super.key,
    required this.data,
    this.fit,
  }) : thumbnailOnly = true;

  final StoryData data;
  final bool thumbnailOnly;
  final BoxFit? fit;

  @override
  State<StoryViewerWidget> createState() => _StoryViewerWidgetState();
}

class _StoryViewerWidgetState extends State<StoryViewerWidget> {
  @override
  void initState() {
    super.initState();

    if (widget.data is VideoStoryData) {
      _initVideoStory();
    }
  }

  Future<void> _initVideoStory() async {
    final data = widget.data as VideoStoryData;

    if (!data.controller.value.isInitialized) {
      await data.controller.initialize();
    }

    await data.controller.setLooping(true);

    await data.controller.seekTo(Duration.zero);
    await data.controller.play();

    setState(() {});
  }

  Future<void> _closeVideoStory() async {
    final data = widget.data as VideoStoryData;

    await data.controller.pause();
    await data.controller.seekTo(Duration.zero);
  }

  @override
  void dispose() {
    _closeVideoStory();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (widget.thumbnailOnly) {
      child = Image(
        image: widget.data.thumbnail,
        fit: widget.fit,
      );
    } else if (widget.data is ImageStoryData) {
      final data = widget.data as ImageStoryData;
      child = Image(
        image: data.imageProvider,
        fit: widget.fit,
      );
    } else if (widget.data is VideoStoryData) {
      final data = widget.data as VideoStoryData;
      child = FittedBox(
        fit: widget.fit ?? BoxFit.contain,
        child: VideoPlayer(
          data.controller,
        ),
      );
    } else {
      throw Exception('Unknown story data type');
    }

    return AspectRatio(
      aspectRatio: widget.data.size.aspectRatio,
      child: child,
    );
  }
}
