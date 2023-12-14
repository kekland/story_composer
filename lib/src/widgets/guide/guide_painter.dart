import 'package:flutter/material.dart';
import 'package:story_composer/src/_src.dart';

class DebugGuidesPainter extends CustomPainter {
  DebugGuidesPainter({required this.guides});

  final List<Guide> guides;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final guide in guides) {
      if (guide is HorizontalGuide) {
        canvas.drawLine(
          Offset(0, guide.dy),
          Offset(size.width, guide.dy),
          paint,
        );
      } else if (guide is VerticalGuide) {
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
