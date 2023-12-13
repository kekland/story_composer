import 'package:flutter/widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _key,
      child: widget.child,
    );
  }
}
