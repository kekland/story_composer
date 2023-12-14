import 'package:flutter/widgets.dart';

enum GuideSnapEdge {
  start,
  center,
  end,
}

abstract class Guide {
  const Guide({
    this.snapEdge = GuideSnapEdge.center,
    this.debugLabel,
  });

  final GuideSnapEdge snapEdge;
  final String? debugLabel;

  Offset snap(Offset offset);
  Rect snapRect(Rect rect) {
    final snapPoint = getRectSnapPoint(rect);
    final snappedPoint = snap(snapPoint);

    final translation = snapPoint - snappedPoint;
    return rect.translate(-translation.dx, -translation.dy);
  }

  double distanceSquaredTo(Offset offset) {
    return (offset - snap(offset)).distanceSquared;
  }

  Offset getRectSnapPoint(Rect rect) {
    switch (snapEdge) {
      case GuideSnapEdge.start:
        return rect.topLeft;
      case GuideSnapEdge.center:
        return rect.center;
      case GuideSnapEdge.end:
        return rect.bottomRight;
    }
  }

  double distanceSquaredToRect(Rect rect) {
    return distanceSquaredTo(getRectSnapPoint(rect));
  }

  @override
  String toString() {
    return 'Guide($debugLabel, snapEdge: $snapEdge)';
  }
}

class HorizontalGuide extends Guide {
  const HorizontalGuide({
    required this.dy,
    super.snapEdge,
    super.debugLabel,
  });

  final double dy;

  @override
  Offset snap(Offset offset) {
    return Offset(offset.dx, dy);
  }

  @override
  String toString() {
    return 'HorizontalGuide($debugLabel, dy: $dy, snapEdge: $snapEdge)';
  }
}

class VerticalGuide extends Guide {
  const VerticalGuide({
    required this.dx,
    super.snapEdge,
    super.debugLabel,
  });

  final double dx;

  @override
  Offset snap(Offset offset) {
    return Offset(dx, offset.dy);
  }

  @override
  String toString() {
    return 'VerticalGuide($debugLabel, dx: $dx, snapEdge: $snapEdge)';
  }
}

typedef GuideResult = ({Guide guide, double distanceSquared});

class Guides {
  const Guides({
    required this.guides,
  });

  const Guides.empty() : guides = const [];

  factory Guides.fromSizeAndPadding({
    required Size size,
    required EdgeInsets padding,
  }) {
    return Guides(
      guides: [
        // Left
        VerticalGuide(
          dx: padding.left,
          debugLabel: 'left',
          snapEdge: GuideSnapEdge.start,
        ),

        // Right
        VerticalGuide(
          dx: size.width - padding.right,
          debugLabel: 'right',
          snapEdge: GuideSnapEdge.end,
        ),

        // Top
        HorizontalGuide(
          dy: padding.top,
          debugLabel: 'top',
          snapEdge: GuideSnapEdge.start,
        ),

        // Bottom
        HorizontalGuide(
          dy: size.height - padding.bottom,
          debugLabel: 'bottom',
          snapEdge: GuideSnapEdge.end,
        ),

        // Center X
        VerticalGuide(
          dx: size.width / 2.0,
          debugLabel: 'center x',
          snapEdge: GuideSnapEdge.center,
        ),

        // Center Y
        HorizontalGuide(
          dy: size.height / 2.0,
          debugLabel: 'center y',
          snapEdge: GuideSnapEdge.center,
        ),
      ],
    );
  }

  final List<Guide> guides;

  List<GuideResult> getSortedByDistanceSquaredTo(Offset offset) {
    final sorted = List<Guide>.from(guides);

    sorted.sort((a, b) {
      return a.distanceSquaredTo(offset).compareTo(b.distanceSquaredTo(offset));
    });

    return sorted
        .map((v) => (guide: v, distanceSquared: v.distanceSquaredTo(offset)))
        .toList();
  }

  List<GuideResult> getSortedByDistanceSquaredToRect(Rect rect) {
    final sorted = List<Guide>.from(guides);

    sorted.sort((a, b) {
      return a
          .distanceSquaredToRect(rect)
          .compareTo(b.distanceSquaredToRect(rect));
    });

    return sorted
        .map((v) => (guide: v, distanceSquared: v.distanceSquaredToRect(rect)))
        .toList();
  }

  static Rect getSnappedRect({
    required Rect rect,
    HorizontalGuide? horizontalGuide,
    VerticalGuide? verticalGuide,
  }) {
    var resultRect = rect;

    if (horizontalGuide != null) {
      resultRect = horizontalGuide.snapRect(resultRect);
    }

    if (verticalGuide != null) {
      resultRect = verticalGuide.snapRect(resultRect);
    }

    return resultRect;
  }
}
