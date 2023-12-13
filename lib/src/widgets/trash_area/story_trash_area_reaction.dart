import 'package:flutter/widgets.dart';

typedef StoryTrashAreaReactionBuilderFn = Widget Function(
  BuildContext context,
  Alignment pointerAlignment,
  bool isInTrashArea,
  Widget child,
);

Widget defaultStoryTrashAreaReactionBuilder(
  BuildContext context,
  Alignment pointerAlignment,
  bool isInTrashArea,
  Widget child,
) {
  return StoryTrashAreaReaction(
    alignment: pointerAlignment,
    isInTrashArea: isInTrashArea,
    child: child,
  );
}

class StoryTrashAreaReaction extends StatefulWidget {
  const StoryTrashAreaReaction({
    super.key,
    required this.alignment,
    required this.isInTrashArea,
    required this.child,
  });

  final Alignment alignment;
  final bool isInTrashArea;
  final Widget child;

  @override
  State<StoryTrashAreaReaction> createState() => _StoryTrashAreaReactionState();
}

class _StoryTrashAreaReactionState extends State<StoryTrashAreaReaction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 0.0,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StoryTrashAreaReaction oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isInTrashArea) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = 1.0 - _animation.value * 0.75;
    final opacity = 1.0 - _animation.value * 0.5;

    return Transform.scale(
      scale: scale,
      alignment: widget.alignment,
      child: Opacity(
        opacity: opacity,
        child: widget.child,
      ),
    );
  }
}
