import 'package:flutter/material.dart';
import 'package:story_composer/src/_src.dart';
import 'package:video_player/video_player.dart';

class StoryPrimaryWidget extends StatelessWidget {
  const StoryPrimaryWidget({
    required Key key,
    required this.child,
    this.initialTransform,
  }) : super(key: key);

  final Matrix4? initialTransform;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StoryRenderableWidget(
      child: StoryTransformableWidget(
        key: key!,
        initialTransform: initialTransform ?? Matrix4.identity(),
        transformationPointerCount: 2,
        isPersistent: false,
        child: child,
      ),
    );
  }
}

Widget defaultPrimaryContentBuilder(
  BuildContext context,
  StoryPrimaryContent primaryContent,
) {
  return StoryDefaultPrimaryContentWidget(
    key: ValueKey(primaryContent),
    primaryContent: primaryContent,
  );
}

class StoryDefaultPrimaryContentWidget extends StatelessWidget {
  const StoryDefaultPrimaryContentWidget({
    required Key key,
    required this.primaryContent,
  }) : super(key: key);

  final StoryPrimaryContent primaryContent;

  @override
  Widget build(BuildContext context) {
    final _primaryContent = primaryContent;

    final Widget child;

    if (_primaryContent is ImageStoryPrimaryContent) {
      child = Image(
        image: _primaryContent.imageProvider,
        fit: BoxFit.cover,
      );
    } else if (_primaryContent is VideoStoryPrimaryContent) {
      child = _VideoStoryPrimaryContentWidget(
        controller: _primaryContent.controller,
      );
    } else {
      throw Exception('Unknown primary content type: $_primaryContent');
    }

    return StoryPrimaryWidget(
      key: key!,
      child: child,
    );
  }
}

class _VideoStoryPrimaryContentWidget extends StatefulWidget {
  const _VideoStoryPrimaryContentWidget({
    super.key,
    required this.controller,
  });

  final VideoPlayerController controller;

  @override
  State<_VideoStoryPrimaryContentWidget> createState() =>
      __VideoStoryPrimaryContentWidgetState();
}

class __VideoStoryPrimaryContentWidgetState
    extends State<_VideoStoryPrimaryContentWidget> {
  @override
  void initState() {
    super.initState();

    widget.controller.play();
    widget.controller.setLooping(true);
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.controller.value.isPlaying) {
          widget.controller.pause();
        } else {
          widget.controller.play();
        }
      },
      child: VideoPlayer(
        widget.controller,
      ),
    );
  }
}
