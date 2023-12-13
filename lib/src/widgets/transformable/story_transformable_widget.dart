import 'package:flutter/material.dart';
import 'package:story_composer/src/_src.dart';

class StoryTransformableWidget extends StatefulWidget {
  const StoryTransformableWidget({
    required super.key,
    required this.child,
    this.initialTransform,
    this.transformationPointerCount = 2,
    this.isPersistent = false,
    this.trashAreaReactionBuilder = defaultStoryTrashAreaReactionBuilder,
  });

  final Matrix4? initialTransform;
  final int transformationPointerCount;
  final bool isPersistent;
  final StoryTrashAreaReactionBuilderFn trashAreaReactionBuilder;
  final PreferredSizeWidget child;

  @override
  State<StoryTransformableWidget> createState() =>
      _StoryTransformableWidgetState();
}

class _StoryTransformableWidgetState extends State<StoryTransformableWidget> {
  Size? _size;
  var _transform = Matrix4.identity();

  late final StoryComposerController _composerController;
  StoryTransformationController? _transformationController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _composerController = StoryComposerController.of(context);
  }

  void _onTransformStart(TransformStartDetails details) {
    _transformationController = _composerController.startTransformation(
      key: widget.key!,
      initialTransform: _transform,
      untransformedSize: _size!,
    );

    _transformationController!.onStart(details);
    setState(() {});
  }

  void _onTransformUpdate(TransformUpdateDetails details) {
    _transformationController!.onUpdate(details);
    setState(() {});
  }

  void _onTransformEnd(TransformEndDetails details) {
    _composerController.endTransformation();

    _transform = _transformationController!.transform;

    _transformationController!.onEnd(details);
    _transformationController!.dispose();
    _transformationController = null;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    child = widget.trashAreaReactionBuilder(
      context,
      _transformationController?.focalPointAlignment ?? Alignment.center,
      _transformationController?.isInTrashArea ?? false,
      child,
    );

    final transform = _transformationController?.transform ?? _transform;

    return Transform(
      transform: transform,
      origin: _composerController.center,
      child: Center(
        child: TransformGestureDetector(
          pointerCount: widget.transformationPointerCount,
          onTransformStart: _onTransformStart,
          onTransformUpdate: _onTransformUpdate,
          onTransformEnd: _onTransformEnd,
          child: LayoutTimeSizeNotifierWidget(
            onSizeChanged: (size) {
              if (_size == size) return;
              _size = size;
            },
            child: child,
          ),
        ),
      ),
    );
  }
}
