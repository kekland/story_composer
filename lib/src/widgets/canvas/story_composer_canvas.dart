import 'package:flutter/material.dart';
import 'package:story_composer/src/_src.dart';

class StoryComposerCanvas extends StatefulWidget {
  const StoryComposerCanvas({
    super.key,
    required this.primaryContent,
    required this.size,
    required this.children,
    this.onWidgetRemoved,
    this.backgroundColor = Colors.black,
    this.trashAreaWidget,
    this.trashAreaAlignment = Alignment.bottomCenter,
    this.guides,
    this.guidesBuilder = defaultGuidesBuilder,
    this.primaryContentBuilder = defaultPrimaryContentBuilder,
  });

  final StoryPrimaryContent primaryContent;
  final Widget Function(BuildContext, StoryPrimaryContent)
      primaryContentBuilder;

  final Size size;
  final List<Widget> children;
  final Color backgroundColor;
  final Widget? trashAreaWidget;
  final Alignment trashAreaAlignment;
  final void Function(Key)? onWidgetRemoved;
  final List<PositionedSceneGuide>? guides;
  final GuidesBuilder guidesBuilder;

  @override
  State<StoryComposerCanvas> createState() => StoryComposerCanvasState();
}

class StoryComposerCanvasState extends State<StoryComposerCanvas> {
  late final controller = StoryComposerController(
    size: widget.size,
    backgroundColor: widget.backgroundColor,
    getChildPaintIndex: getChildIndex,
    onWidgetRemoved: widget.onWidgetRemoved,
    positionedGuides:
        widget.guides ?? SceneGuides.fromPadding(const EdgeInsets.all(16.0)),
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
          ClipRect(
            child: SizedBox.expand(
              child: ColoredBox(
                color: widget.backgroundColor,
                child: Stack(
                  children: [
                    widget.primaryContentBuilder(
                      context,
                      widget.primaryContent,
                    ),
                    ...widget.children,
                  ],
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: ValueListenableBuilder(
              valueListenable: controller.activeGuides,
              builder: (context, activeGuides, _) {
                return widget.guidesBuilder(
                  context,
                  activeGuides,
                  controller.sceneGuides.guides,
                );
              },
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

    return LayoutBuilder(
      builder: (context, constraints) {
        controller.setViewportSize(
          constraints.constrainSizeAndAttemptToPreserveAspectRatio(widget.size),
        );

        return InheritedStoryComposerController(
          controller: controller,
          child: child,
        );
      },
    );
  }
}
