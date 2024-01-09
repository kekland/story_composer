import 'package:flutter/widgets.dart';
import 'package:story_composer/src/model/story_data.dart';
import 'package:video_player/video_player.dart';

class StoryViewer extends StatefulWidget {
  const StoryViewer({
    super.key,
    required this.data,
    this.thumbnailOnly = false,
  });

  const StoryViewer.thumbnail({
    super.key,
    required this.data,
  }) : thumbnailOnly = true;

  final StoryData data;
  final bool thumbnailOnly;

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
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

  Future<void> _disposeVideoStory() async {
    final data = widget.data as VideoStoryData;

    await data.controller.pause();
    await data.controller.seekTo(Duration.zero);
  }

  @override
  void dispose() {
    _disposeVideoStory();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (widget.thumbnailOnly) {
      child = Image(image: widget.data.thumbnail);
    } else if (widget.data is ImageStoryData) {
      final data = widget.data as ImageStoryData;
      child = Image(image: data.imageProvider);
    } else if (widget.data is VideoStoryData) {
      final data = widget.data as VideoStoryData;
      child = VideoPlayer(data.controller);
    } else {
      throw Exception('Unknown story data type');
    }

    return AspectRatio(
      aspectRatio: widget.data.size.aspectRatio,
      child: child,
    );
  }
}
