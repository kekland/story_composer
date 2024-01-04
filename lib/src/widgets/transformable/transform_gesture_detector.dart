import 'package:flutter/widgets.dart';
import 'package:story_composer/src/_src.dart';

class TransformGestureDetector extends StatelessWidget {
  const TransformGestureDetector({
    super.key,
    required this.pointerCount,
    required this.child,
    required this.onTransformStart,
    required this.onTransformUpdate,
    required this.onTransformEnd,
  });

  final int pointerCount;
  final Widget child;
  final GestureTransformStartCallback onTransformStart;
  final GestureTransformUpdateCallback onTransformUpdate;
  final GestureTransformEndCallback onTransformEnd;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        TransformGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TransformGestureRecognizer>(
          () => TransformGestureRecognizer(
            context: context,
            requiredPointerCount: pointerCount,
          ),
          (recognizer) => recognizer
            ..requiredPointerCount = pointerCount
            ..onStart = onTransformStart
            ..onUpdate = onTransformUpdate
            ..onEnd = onTransformEnd,
        ),
      },
      child: child,
    );
  }
}
