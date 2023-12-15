import 'package:flutter/widgets.dart';

enum GuideSnapEdge {
  start,
  center,
  end,
}

abstract class SceneGuide {
  const SceneGuide({
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

class HorizontalSceneGuide extends SceneGuide {
  const HorizontalSceneGuide({
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

class VerticalSceneGuide extends SceneGuide {
  const VerticalSceneGuide({
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

typedef SceneGuideResult = ({SceneGuide guide, double distanceSquared});

class SceneGuides {
  const SceneGuides({
    required this.guides,
  });

  const SceneGuides.empty() : guides = const [];

  final List<SceneGuide> guides;

  static List<PositionedSceneGuide> fromPadding(EdgeInsets padding) {
    return [
      const HorizontalPositionedSceneGuide(
        alignment: Alignment.center,
        snapEdge: GuideSnapEdge.center,
      ),
      const VerticalPositionedSceneGuide(
        alignment: Alignment.center,
        snapEdge: GuideSnapEdge.center,
      ),
      if (padding.top > 0.0)
        HorizontalPositionedSceneGuide(
          top: padding.top,
          snapEdge: GuideSnapEdge.start,
        ),
      if (padding.bottom > 0.0)
        HorizontalPositionedSceneGuide(
          bottom: padding.bottom,
          snapEdge: GuideSnapEdge.end,
        ),
      if (padding.left > 0.0)
        VerticalPositionedSceneGuide(
          left: padding.left,
          snapEdge: GuideSnapEdge.start,
        ),
      if (padding.right > 0.0)
        VerticalPositionedSceneGuide(
          right: padding.right,
          snapEdge: GuideSnapEdge.end,
        ),
    ];
  }

  List<SceneGuideResult> getSortedByDistanceSquaredTo(Offset offset) {
    final sorted = List<SceneGuide>.from(guides);

    sorted.sort((a, b) {
      return a.distanceSquaredTo(offset).compareTo(b.distanceSquaredTo(offset));
    });

    return sorted
        .map((v) => (guide: v, distanceSquared: v.distanceSquaredTo(offset)))
        .toList();
  }

  List<SceneGuideResult> getSortedByDistanceSquaredToRect(Rect rect) {
    final sorted = List<SceneGuide>.from(guides);

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
    HorizontalSceneGuide? horizontalGuide,
    VerticalSceneGuide? verticalGuide,
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

abstract class PositionedSceneGuide {
  const PositionedSceneGuide();

  SceneGuide toSceneGuide(Size sceneSize);
}

class HorizontalPositionedSceneGuide extends PositionedSceneGuide {
  const HorizontalPositionedSceneGuide({
    this.top,
    this.bottom,
    this.alignment,
    this.snapEdge = GuideSnapEdge.center,
  });

  final double? top;
  final double? bottom;
  final AlignmentGeometry? alignment;
  final GuideSnapEdge snapEdge;

  @override
  SceneGuide toSceneGuide(Size sceneSize) {
    if (alignment != null) {
      var y = alignment!.resolve(TextDirection.ltr).y; // From [-1; 1]
      y = (y + 1.0) / 2.0; // From [0; 1]

      return HorizontalSceneGuide(
        dy: sceneSize.height * y,
        snapEdge: snapEdge,
      );
    }

    if (top != null && bottom != null) {
      throw ArgumentError('Cannot specify both top and bottom');
    }

    if (top != null) {
      return HorizontalSceneGuide(
        dy: top!,
        snapEdge: snapEdge,
      );
    }

    if (bottom != null) {
      return HorizontalSceneGuide(
        dy: sceneSize.height - bottom!,
        snapEdge: snapEdge,
      );
    }

    throw ArgumentError('Must specify either top, bottom, or alignment');
  }
}

class VerticalPositionedSceneGuide extends PositionedSceneGuide {
  const VerticalPositionedSceneGuide({
    this.left,
    this.right,
    this.alignment,
    this.snapEdge = GuideSnapEdge.center,
  });

  final double? left;
  final double? right;
  final AlignmentGeometry? alignment;
  final GuideSnapEdge snapEdge;

  @override
  SceneGuide toSceneGuide(Size sceneSize) {
    if (alignment != null) {
      var x = alignment!.resolve(TextDirection.ltr).x; // From [-1; 1]
      x = (x + 1.0) / 2.0; // From [0; 1]

      return VerticalSceneGuide(
        dx: sceneSize.width * x,
        snapEdge: snapEdge,
      );
    }

    if (left != null && right != null) {
      throw ArgumentError('Cannot specify both left and right');
    }

    if (left != null) {
      return VerticalSceneGuide(
        dx: left!,
        snapEdge: snapEdge,
      );
    }

    if (right != null) {
      return VerticalSceneGuide(
        dx: sceneSize.width - right!,
        snapEdge: snapEdge,
      );
    }

    throw ArgumentError('Must specify either left, right, or alignment');
  }
}
