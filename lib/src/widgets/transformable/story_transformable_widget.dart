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
  final Widget child;

  @override
  State<StoryTransformableWidget> createState() =>
      _StoryTransformableWidgetState();
}

class _StoryTransformableWidgetState extends State<StoryTransformableWidget> {
  Size? _size;
  var _transform = Matrix4.identity();
  var _didSetTransform = false;

  StoryComposerController? _composerController;
  StoryTransformationController? _transformationController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_composerController == null) {
      _composerController = StoryComposerController.of(context);
      _composerController!.addListener(_onComposerControllerChanged);
    }

    if (widget.initialTransform != null) {
      _transform = widget.initialTransform!;
      _didSetTransform = true;
    }
  }

  void _onComposerControllerChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _composerController?.removeListener(_onComposerControllerChanged);
    super.dispose();
  }

  void _onTransformStart(TransformStartDetails details) {
    _transformationController = _composerController?.startTransformation(
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
    _composerController?.endTransformation();

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

    return IgnorePointer(
      ignoring: _transformationController !=
          _composerController?.activeTransformation,
      child: Align(
        alignment: Alignment.topLeft,
        child: Transform(
          transform: transform,
          child: TransformGestureDetector(
            pointerCount: widget.transformationPointerCount,
            onTransformStart: _onTransformStart,
            onTransformUpdate: _onTransformUpdate,
            onTransformEnd: _onTransformEnd,
            child: LayoutTimeSizeNotifierWidget(
              onSizeChanged: (size) {
                if (_size == size) return;
                _size = size;

                if (!_didSetTransform) {
                  _transform = Matrix4.translationValues(
                    _composerController!.center.dx - size.width / 2.0,
                    _composerController!.center.dy - size.height / 2.0,
                    0,
                  );

                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    setState(() {});
                  });

                  _didSetTransform = true;
                }
              },
              child: Visibility.maintain(
                visible: _didSetTransform || _size != null,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
