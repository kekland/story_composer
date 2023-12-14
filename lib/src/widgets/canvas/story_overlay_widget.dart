import 'package:flutter/material.dart';
import 'package:story_composer/src/_src.dart';

class StoryOverlayWidget extends StatelessWidget {
  const StoryOverlayWidget({
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
        initialTransform: initialTransform,
        isPersistent: true,
        transformationPointerCount: 1,
        child: child,
      ),
    );
  }
}
