import 'package:flutter/material.dart';
import 'package:story_composer/src/_src.dart';

class StoryComposerCanvas extends StatefulWidget {
  const StoryComposerCanvas({
    super.key,
    required this.size,
    required this.children,
    this.onWidgetRemoved,
    this.backgroundColor = Colors.black,
    this.trashAreaWidget,
    this.trashAreaAlignment = Alignment.bottomCenter,
    this.guides,
  });

  final Size size;
  final List<Widget> children;
  final Color backgroundColor;
  final Widget? trashAreaWidget;
  final Alignment trashAreaAlignment;
  final void Function(Key)? onWidgetRemoved;
  final Guides? guides;

  @override
  State<StoryComposerCanvas> createState() => _StoryComposerCanvasState();
}

class _StoryComposerCanvasState extends State<StoryComposerCanvas> {
  final _canvasKey = GlobalKey();
  late final _controller = StoryComposerController(
    size: widget.size,
    onWidgetRemoved: widget.onWidgetRemoved,
    guides: widget.guides ??
        Guides.fromSizeAndPadding(
          size: widget.size,
          padding: const EdgeInsets.all(32.0),
        ),
  );

  @override
  Widget build(BuildContext context) {
    Widget child = AspectRatio(
      aspectRatio: widget.size.aspectRatio,
      child: Stack(
        children: [
          FittedBox(
            fit: BoxFit.contain,
            child: ClipRect(
              child: SizedBox.fromSize(
                key: _canvasKey,
                size: widget.size,
                child: ColoredBox(
                  color: widget.backgroundColor,
                  child: Stack(
                    children: [
                      ...widget.children,
                      IgnorePointer(
                        child: ValueListenableBuilder(
                          valueListenable: _controller.activeGuides,
                          builder: (context, activeGuides, _) => CustomPaint(
                            painter: DebugGuidesPainter(
                              guides: activeGuides,
                            ),
                            size: _controller.size,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (widget.trashAreaWidget != null)
            Align(
              alignment: widget.trashAreaAlignment,
              child: widget.trashAreaWidget!,
            ),
        ],
      ),
    );

    return InheritedStoryComposerController(
      controller: _controller,
      child: child,
    );
  }
}
