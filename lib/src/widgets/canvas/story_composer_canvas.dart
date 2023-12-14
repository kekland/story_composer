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
  State<StoryComposerCanvas> createState() => StoryComposerCanvasState();
}

class StoryComposerCanvasState extends State<StoryComposerCanvas> {
  final _canvasKey = GlobalKey();
  late final controller = StoryComposerController(
    size: widget.size,
    backgroundColor: widget.backgroundColor,
    getChildPaintIndex: getChildIndex,
    onWidgetRemoved: widget.onWidgetRemoved,
    guides: widget.guides ??
        Guides.fromSizeAndPadding(
          size: widget.size,
          padding: const EdgeInsets.all(32.0),
        ),
  );

  int getChildIndex(BuildContext context) {
    Widget? ancestor;

    context.visitAncestorElements((e) {
      if (widget.children.contains(e.widget)) {
        ancestor = e.widget;
        return false;
      } else if (e.widget == widget) {
        return false;
      }

      return true;
    });

    return ancestor != null ? widget.children.indexOf(ancestor!) : -1;
  }

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
                          valueListenable: controller.activeGuides,
                          builder: (context, activeGuides, _) => CustomPaint(
                            painter: DebugGuidesPainter(
                              guides: activeGuides,
                            ),
                            size: controller.size,
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
      controller: controller,
      child: child,
    );
  }
}
