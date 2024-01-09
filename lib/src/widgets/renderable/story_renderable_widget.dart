import 'package:flutter/widgets.dart';
import 'package:story_composer/src/controller/story_composer_controller.dart';

class StoryRenderableWidget extends StatefulWidget {
  const StoryRenderableWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<StoryRenderableWidget> createState() => _StoryRenderableWidgetState();
}

class _StoryRenderableWidgetState extends State<StoryRenderableWidget> {
  final _key = GlobalKey();
  StoryComposerController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _controller = StoryComposerController.of(context);
    _controller!.attachRenderable(widget.key!, _key);
  }

  @override
  void dispose() {
    _controller!.detachRenderable(widget.key!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _key,
      child: widget.child,
    );
  }
}
