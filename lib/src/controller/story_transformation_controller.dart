import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:story_composer/src/_src.dart';

const _kGuideSnapPixelsPerSecondSquared = 3000.0;
const _kGuideSnapDistanceSquared = 100.0;
const _kGuideSnapBreakDistanceSquared = 400.0;

class StoryTransformationController extends ChangeNotifier {
  StoryTransformationController({
    required this.key,
    required this.parent,
    required this.untransformedSize,
    required Matrix4 initialTransform,
    this.isPersistent = false,
  }) : _initialTransform = initialTransform;

  final Key key;
  final Size untransformedSize;
  final StoryComposerController parent;

  final bool isPersistent;

  final Matrix4 _initialTransform;
  var _currentTransform = Matrix4.identity();
  var _snapTransform = Matrix4.identity();

  var _focalPoint = Offset.zero;
  var _focalPointAlignment = Alignment.center;
  var _isInTrashArea = false;

  Matrix4 get transform =>
      _snapTransform * _initialTransform * _currentTransform;

  Offset get focalPoint => _focalPoint;
  Alignment get focalPointAlignment => _focalPointAlignment;
  bool get isInTrashArea => _isInTrashArea;

  HorizontalGuide? _snapHorizontalGuide;
  VerticalGuide? _snapVerticalGuide;

  HorizontalGuide? get snapHorizontalGuide => _snapHorizontalGuide;
  VerticalGuide? get snapVerticalGuide => _snapVerticalGuide;
  List<Guide> get snapActiveGuides => [
        if (_snapHorizontalGuide != null) _snapHorizontalGuide!,
        if (_snapVerticalGuide != null) _snapVerticalGuide!,
      ];

  void onStart(TransformStartDetails details) {
    if (!isPersistent &&
        details.pointerCount == 1 &&
        parent.trashAreaState != null) {
      parent.trashAreaState!.showTrashArea();
    }
  }

  void onUpdate(TransformUpdateDetails details) {
    _focalPoint = details.localFocalPoint;

    _focalPointAlignment = Alignment(
      2.0 * _focalPoint.dx / details.size.width - 1.0,
      2.0 * _focalPoint.dy / details.size.height - 1.0,
    );

    _currentTransform = details.transform;

    _updateTrashArea(details);
    _updateSnap(details);
    _computeSnapTransform();

    notifyListeners();
  }

  void _computeSnapTransform() {
    final _aabb = MatrixUtils.transformRect(
      _initialTransform * _currentTransform,
      Offset(-untransformedSize.width / 2, -untransformedSize.height / 2) &
          untransformedSize,
    );

    final snappedRect = Guides.getSnappedRect(
      rect: _aabb,
      horizontalGuide: _snapHorizontalGuide,
      verticalGuide: _snapVerticalGuide,
    );

    print('horiz: $_snapHorizontalGuide');
    print('vert: $_snapVerticalGuide');

    print('snapped: $snappedRect');

    final t = (_initialTransform * _currentTransform).getTranslation();
    _snapTransform.setTranslationRaw(
      -t.x + snappedRect.center.dx,
      -t.y + snappedRect.center.dy,
      0.0,
    );
  }

  void _updateTrashArea(TransformUpdateDetails details) {
    if (!isPersistent &&
        details.hasSinglePointer &&
        parent.trashAreaState != null) {
      parent.trashAreaState!.showTrashArea();

      _isInTrashArea =
          parent.trashAreaState!.onPointerUpdated(details.pointers.first);
    } else {
      parent.trashAreaState?.hideTrashArea();
      _isInTrashArea = false;
    }
  }

  void _updateSnap(TransformUpdateDetails details) {
    if (!details.hasSinglePointer) {
      _snapHorizontalGuide = null;
      _snapVerticalGuide = null;
      return;
    }

    final _aabb = MatrixUtils.transformRect(
      _initialTransform * _currentTransform,
      Offset(-untransformedSize.width / 2, -untransformedSize.height / 2) &
          untransformedSize,
    );

    print(_aabb);

    final velocity =
        details.pointerVelocities.first.pixelsPerSecond.distanceSquared;
    final isMovingSlowly = velocity < _kGuideSnapPixelsPerSecondSquared;

    if (details.hasSinglePointer && isMovingSlowly) {
      final guides = parent.guides.getSortedByDistanceSquaredToRect(_aabb);

      final closestHorizontalGuide = guides.firstWhereOrNull(
        (v) =>
            v.guide is HorizontalGuide &&
            v.distanceSquared < _kGuideSnapDistanceSquared,
      );

      final closestVerticalGuide = guides.firstWhereOrNull(
        (v) =>
            v.guide is VerticalGuide &&
            v.distanceSquared < _kGuideSnapDistanceSquared,
      );

      _snapHorizontalGuide = closestHorizontalGuide?.guide as HorizontalGuide?;
      _snapVerticalGuide = closestVerticalGuide?.guide as VerticalGuide?;
    }

    if (_snapHorizontalGuide != null) {
      if (_snapHorizontalGuide!.distanceSquaredToRect(_aabb) >
          _kGuideSnapBreakDistanceSquared) {
        _snapHorizontalGuide = null;
      }
    }

    if (_snapVerticalGuide != null) {
      if (_snapVerticalGuide!.distanceSquaredToRect(_aabb) >
          _kGuideSnapBreakDistanceSquared) {
        _snapVerticalGuide = null;
      }
    }
  }

  void onEnd(TransformEndDetails details) {}
}
