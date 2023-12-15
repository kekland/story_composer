import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:story_composer/src/_src.dart';

const _kGuideSnapPixelsPerSecondSquared = 2000.0;
const _kGuideSnapDistanceSquared = 60.0;
const _kGuideSnapBreakDistanceSquared = 200.0;

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
  final _translationSnapTransform = Matrix4.identity();
  // var _rotationSnapTransform = Matrix4.identity();

  var _focalPoint = Offset.zero;
  var _focalPointAlignment = Alignment.center;
  var _isInTrashArea = false;

  Matrix4 get transform =>
      _translationSnapTransform *
      // _rotationSnapTransform *
      _initialTransform *
      _currentTransform;

  Matrix4 get _transformWithoutSnap => _initialTransform * _currentTransform;

  Offset get focalPoint => _focalPoint;
  Alignment get focalPointAlignment => _focalPointAlignment;
  bool get isInTrashArea => _isInTrashArea;

  HorizontalSceneGuide? _snapHorizontalGuide;
  VerticalSceneGuide? _snapVerticalGuide;

  // double? _snapAngle;

  HorizontalSceneGuide? get snapHorizontalGuide => _snapHorizontalGuide;
  VerticalSceneGuide? get snapVerticalGuide => _snapVerticalGuide;
  List<SceneGuide> get snapActiveGuides => [
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
    _updateTranslationSnap(details);
    _computeTranslationSnapTransform();

    // TODO: Rework transformations.
    // _updateRotationSnap(details);
    // _computeRotationSnapTransform();

    notifyListeners();
  }

  void _computeTranslationSnapTransform() {
    final _aabb = MatrixUtils.transformRect(
      _transformWithoutSnap,
      Offset.zero & untransformedSize,
    );

    final snappedRect = SceneGuides.getSnappedRect(
      rect: _aabb,
      horizontalGuide: _snapHorizontalGuide,
      verticalGuide: _snapVerticalGuide,
    );

    _translationSnapTransform.setTranslationRaw(
      -_aabb.topLeft.dx + snappedRect.topLeft.dx,
      -_aabb.topLeft.dy + snappedRect.topLeft.dy,
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

  // void _updateRotationSnap(TransformUpdateDetails details) {
  //   if (details.hasSinglePointer || _isInTrashArea) {
  //     return;
  //   }

  //   final q = Quaternion.fromRotation(_transformWithoutSnap.getRotation());
  //   final angle = q.eulerAngles.yaw;

  //   // We should snap to angles that are close to [pi/2] * n, where n is an
  //   // integer.
  //   final snapAngle = (angle / (pi / 2)).round() * pi / 2;

  //   final angleDifference = (angle - snapAngle).abs();

  //   if (angleDifference < 0.3) {
  //     _snapAngle = snapAngle;
  //   } else {
  //     _snapAngle = null;
  //   }
  // }

  void _updateTranslationSnap(TransformUpdateDetails details) {
    if (_isInTrashArea) {
      _snapHorizontalGuide = null;
      _snapVerticalGuide = null;
      return;
    }

    final _aabb = MatrixUtils.transformRect(
      _transformWithoutSnap,
      Offset.zero & untransformedSize,
    );

    final velocity =
        details.pointerVelocities.first.pixelsPerSecond.distanceSquared;
    final isMovingSlowly = velocity < _kGuideSnapPixelsPerSecondSquared;

    if (isMovingSlowly) {
      final guides = parent.sceneGuides.getSortedByDistanceSquaredToRect(_aabb);

      final closestHorizontalGuide = guides.firstWhereOrNull(
        (v) =>
            v.guide is HorizontalSceneGuide &&
            v.distanceSquared < _kGuideSnapDistanceSquared,
      );

      final closestVerticalGuide = guides.firstWhereOrNull(
        (v) =>
            v.guide is VerticalSceneGuide &&
            v.distanceSquared < _kGuideSnapDistanceSquared,
      );

      var shouldVibrate = false;

      if (closestHorizontalGuide?.guide != _snapHorizontalGuide) {
        _snapHorizontalGuide =
            closestHorizontalGuide?.guide as HorizontalSceneGuide?;
        shouldVibrate = true;
      }

      if (closestVerticalGuide?.guide != _snapVerticalGuide) {
        _snapVerticalGuide = closestVerticalGuide?.guide as VerticalSceneGuide?;
        shouldVibrate = true;
      }

      if (shouldVibrate) {
        HapticFeedback.selectionClick();
      }
    }

    if (_snapHorizontalGuide != null) {
      if (_snapHorizontalGuide!.distanceSquaredToRect(_aabb) >
          _kGuideSnapBreakDistanceSquared) {
        _snapHorizontalGuide = null;
        HapticFeedback.selectionClick();
      }
    }

    if (_snapVerticalGuide != null) {
      if (_snapVerticalGuide!.distanceSquaredToRect(_aabb) >
          _kGuideSnapBreakDistanceSquared) {
        _snapVerticalGuide = null;
        HapticFeedback.selectionClick();
      }
    }
  }

  void onEnd(TransformEndDetails details) {}
}
