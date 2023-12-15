import 'package:flutter/material.dart';
import 'package:story_composer/src/_src.dart';

Widget defaultGuidesBuilder(
  BuildContext context,
  List<SceneGuide> activeGuides,
  List<SceneGuide> guides,
) {
  return StoryGuidesWidget(
    activeGuides: activeGuides,
    guides: guides,
  );
}

typedef GuidesBuilder = Widget Function(
  BuildContext context,
  List<SceneGuide> activeGuides,
  List<SceneGuide> guides,
);

class StoryGuidesWidget extends StatelessWidget {
  const StoryGuidesWidget({
    super.key,
    required this.activeGuides,
    required this.guides,
    this.guideColor = Colors.white,
    this.guideThickness = 1.0,
  });

  final List<SceneGuide> activeGuides;
  final List<SceneGuide> guides;
  final Color guideColor;
  final double guideThickness;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...guides.map(
          (v) => _StoryGuideWidget(
            key: ValueKey(v),
            guide: v,
            isActive: activeGuides.contains(v),
            color: guideColor,
            thickness: guideThickness,
          ),
        ),
      ],
    );
  }
}

class _StoryGuideWidget extends StatefulWidget {
  const _StoryGuideWidget({
    super.key,
    required this.guide,
    required this.isActive,
    required this.color,
    required this.thickness,
  });

  final SceneGuide guide;
  final bool isActive;
  final Color color;
  final double thickness;

  @override
  State<_StoryGuideWidget> createState() => _StoryGuideWidgetState();
}

class _StoryGuideWidgetState extends State<_StoryGuideWidget>
    with SingleTickerProviderStateMixin {
  late final _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  late final _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOut,
  );

  @override
  void didUpdateWidget(_StoryGuideWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _GuidePainter(
            guide: widget.guide,
            color: widget.color.withOpacity(_animation.value),
            thickness: widget.thickness,
          ),
        );
      },
    );
  }
}

class _GuidePainter extends CustomPainter {
  const _GuidePainter({
    required this.guide,
    required this.color,
    required this.thickness,
  });

  final SceneGuide guide;
  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    if (guide is HorizontalSceneGuide) {
      final _guide = guide as HorizontalSceneGuide;

      canvas.drawLine(
        Offset(0, _guide.dy),
        Offset(size.width, _guide.dy),
        paint,
      );
    } else if (guide is VerticalSceneGuide) {
      final _guide = guide as VerticalSceneGuide;

      canvas.drawLine(
        Offset(_guide.dx, 0),
        Offset(_guide.dx, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GuidePainter oldDelegate) {
    return guide != oldDelegate.guide ||
        color != oldDelegate.color ||
        thickness != oldDelegate.thickness;
  }
}

class DebugGuidesPainter extends CustomPainter {
  DebugGuidesPainter({required this.guides});

  final List<SceneGuide> guides;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final guide in guides) {
      if (guide is HorizontalSceneGuide) {
        canvas.drawLine(
          Offset(0, guide.dy),
          Offset(size.width, guide.dy),
          paint,
        );
      } else if (guide is VerticalSceneGuide) {
        canvas.drawLine(
          Offset(guide.dx, 0),
          Offset(guide.dx, size.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DebugGuidesPainter oldDelegate) {
    return guides != oldDelegate.guides;
  }
}
