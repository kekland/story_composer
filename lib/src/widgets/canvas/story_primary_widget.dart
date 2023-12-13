import 'package:flutter/material.dart';
import 'package:story_composer/src/_src.dart';

class StoryPrimaryWidget extends StatelessWidget {
  const StoryPrimaryWidget({
    required Key key,
    required this.child,
    this.initialTransform,
  }) : super(key: key);

  final Matrix4? initialTransform;
  final PreferredSizeWidget child;

  @override
  Widget build(BuildContext context) {
    return StoryTransformableWidget(
      key: key!,
      initialTransform: initialTransform ?? Matrix4.identity(),
      transformationPointerCount: 2,
      isPersistent: false,
      child: child,
    );
  }
}
