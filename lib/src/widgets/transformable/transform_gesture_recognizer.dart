import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class LineSegment {
  LineSegment(this.start, this.end);

  final Offset start;
  final Offset end;

  bool get isPoint => start == end;

  double get length => (start - end).distance;

  LineSegment transform(Matrix4 transform) {
    final start = PointerEvent.transformPosition(transform, this.start);
    final end = PointerEvent.transformPosition(transform, this.end);

    return LineSegment(start, end);
  }

  @override
  String toString() =>
      'LineSegment(start: $start, end: $end, isPoint: $isPoint)';
}

class TransformGestureRecognizer extends OneSequenceGestureRecognizer {
  TransformGestureRecognizer({
    required this.context,
    required this.requiredPointerCount,
    super.debugOwner,
    super.supportedDevices,
    super.allowedButtonsFilter,
    this.dragStartBehavior = DragStartBehavior.down,
  });

  int requiredPointerCount;
  BuildContext context;
  DragStartBehavior dragStartBehavior;
  GestureTransformStartCallback? onStart;
  GestureTransformUpdateCallback? onUpdate;
  GestureTransformEndCallback? onEnd;

  final _velocityTrackers = <int, VelocityTracker>{};
  final _pointerLocations = <int, Offset>{};
  final _pointerQueue = <int>[];

  int get _pointerCount => _pointerQueue.length;

  LineSegment? _currentSegment;
  LineSegment? _initialSegment;

  Matrix4? _transform;

  Matrix4? _lastGlobalTransform;

  var _state = _TransformState.ready;

  RenderBox? _cachedRenderBox;
  RenderBox get _renderBox {
    return _cachedRenderBox ??= context.findRenderObject() as RenderBox;
  }

  void _updateLastGlobalTransform() {
    _setLastGlobalTransform(
      Matrix4.inverted(_renderBox.getTransformTo(null)),
    );
  }

  @override
  void handleEvent(PointerEvent event) {
    bool didChangeConfiguration = false;
    bool shouldStartIfAccepted = false;

    if (event is PointerDownEvent) {
      _pointerQueue.add(event.pointer);
      _pointerLocations[event.pointer] = event.position;
      shouldStartIfAccepted = _pointerCount >= requiredPointerCount;
      didChangeConfiguration = true;
    } else if (event is PointerMoveEvent) {
      final tracker = _velocityTrackers[event.pointer]!;
      if (!event.synthesized) {
        tracker.addPosition(event.timeStamp, event.position);
      }

      _pointerLocations[event.pointer] = event.position;
      shouldStartIfAccepted = _pointerCount >= requiredPointerCount;
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _pointerQueue.remove(event.pointer);
      _pointerLocations.remove(event.pointer);
      didChangeConfiguration = true;
    }

    _updateLineSegments();

    if (_lastGlobalTransform == null) {
      _updateLastGlobalTransform();
    }

    _update();

    if (!didChangeConfiguration || _reconfigure(event.pointer)) {
      _advanceStateMachine(shouldStartIfAccepted, event);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  bool isPointerPanZoomAllowed(PointerPanZoomStartEvent event) => false;

  void _setLastGlobalTransform(Matrix4? t) {
    if (_lastGlobalTransform != t) {
      _lastGlobalTransform = t;
    }
  }

  Offset _transformPosition(Offset position) {
    if (_lastGlobalTransform == null) {
      return position;
    }

    return PointerEvent.transformPosition(
      _lastGlobalTransform!,
      position,
    );
  }

  void _updateLineSegments() {
    _initialSegment ??= _createLineSegment();
    _currentSegment = _createLineSegment();
  }

  LineSegment? _createLineSegment() {
    if (_pointerCount == 1) {
      return LineSegment(
        _pointerLocations.values.first,
        _pointerLocations.values.first,
      );
    } else if (_pointerCount > 1) {
      final firstPointer = _pointerQueue.first;
      final lastPointer = _pointerQueue.last;

      final firstPosition = _pointerLocations[firstPointer]!;
      final lastPosition = _pointerLocations[lastPointer]!;

      return LineSegment(firstPosition, lastPosition);
    }

    return null;
  }

  void _update() {
    if (_initialSegment == null || _currentSegment == null) {
      return;
    }

    if (_initialSegment!.isPoint != _currentSegment!.isPoint) {
      return;
    }

    final a = _transformPosition(_initialSegment!.start);
    final b = _transformPosition(_initialSegment!.end);
    final c = _transformPosition(_currentSegment!.start);
    final d = _transformPosition(_currentSegment!.end);

    if (_initialSegment!.isPoint) {
      _transform = Matrix4.identity()
        ..translate(c.dx, c.dy)
        ..translate(-a.dx, -a.dy);

      return;
    }

    final scaleFactor = _currentSegment!.length / _initialSegment!.length;
    final rotationAngle = atan2(
      (d.dx - c.dx) * (b.dy - a.dy) - (d.dy - c.dy) * (b.dx - a.dx),
      (d.dx - c.dx) * (b.dx - a.dx) + (d.dy - c.dy) * (b.dy - a.dy),
    );

    _transform = Matrix4.identity()
      ..translate(c.dx, c.dy)
      ..scale(scaleFactor)
      ..rotateZ(-rotationAngle)
      ..translate(-a.dx, -a.dy);
  }

  bool _reconfigure(int pointer) {
    _initialSegment = _currentSegment;

    if (_state == _TransformState.started) {
      _state = _TransformState.accepted;

      if (onEnd != null) {
        invokeCallback<void>(
          'onEnd',
          () => onEnd!(TransformEndDetails(pointerCount: _pointerCount)),
        );
      }

      _lastGlobalTransform = null;
      return false;
    }

    return true;
  }

  void _advanceStateMachine(bool shouldStartIfAccepted, PointerEvent event) {
    if (_state == _TransformState.ready) {
      _state = _TransformState.possible;
    }

    if (_state == _TransformState.possible) {
      if (_pointerCount >= requiredPointerCount) {
        resolve(GestureDisposition.accepted);
      }
    } else if (_state.index >= _TransformState.accepted.index) {
      resolve(GestureDisposition.accepted);
    }

    if (_state == _TransformState.accepted && shouldStartIfAccepted) {
      _state = _TransformState.started;
      _dispatchOnStartCallbackIfNeeded();
    }

    if (_state == _TransformState.started) {
      if (onUpdate != null) {
        invokeCallback<void>('onUpdate', () {
          onUpdate!(
            TransformUpdateDetails(
              size: _renderBox.size,
              initialLineSegment: _initialSegment!,
              currentLineSegment: _currentSegment!,
              transform: _transform!,
              pointers: _pointerLocations.values.toList(),
              localPointers: _pointerLocations.values
                  .map((e) => _renderBox.globalToLocal(e))
                  .toList(),
              pointerVelocities: [
                for (final i in _pointerLocations.keys)
                  _velocityTrackers[i]!.getVelocity(),
              ],
            ),
          );
        });
      }
    }
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);

    _velocityTrackers[event.pointer] = VelocityTracker.withKind(event.kind);

    if (_state == _TransformState.ready) {
      _state = _TransformState.possible;
    }
  }

  @override
  void acceptGesture(int pointer) {
    if (_state == _TransformState.possible &&
        _pointerCount >= requiredPointerCount) {
      _state = _TransformState.started;
      _dispatchOnStartCallbackIfNeeded();
    }
  }

  @override
  void rejectGesture(int pointer) {
    _pointerLocations.remove(pointer);
    _pointerQueue.remove(pointer);
    stopTrackingPointer(pointer);
  }

  void _dispatchOnStartCallbackIfNeeded() {
    assert(_state == _TransformState.started);

    if (onStart != null) {
      invokeCallback<void>('onStart', () {
        onStart!(TransformStartDetails(
          pointerCount: _pointerCount,
        ));
      });
    }
  }

  @override
  void dispose() {
    _velocityTrackers.clear();
    _pointerLocations.clear();
    _pointerQueue.clear();
    _currentSegment = null;
    _initialSegment = null;
    _transform = null;
    _lastGlobalTransform = null;

    super.dispose();
  }

  @override
  String get debugDescription => 'transform';
}

/// The possible states of a [TransformGestureRecognizer].
enum _TransformState {
  /// The recognizer is ready to start recognizing a gesture.
  ready,

  /// The sequence of pointer events seen thus far is consistent with a scale
  /// gesture but the gesture has not been accepted definitively.
  possible,

  /// The sequence of pointer events seen thus far has been accepted
  /// definitively as a scale gesture.
  accepted,

  /// The sequence of pointer events seen thus far has been accepted
  /// definitively as a scale gesture and the pointers established a focal point
  /// and initial scale.
  started,
}

/// Signature for when the pointers in contact with the screen have established
/// a focal point.
typedef GestureTransformStartCallback = void Function(
  TransformStartDetails details,
);

/// Signature for when the pointers in contact with the screen have indicated a
/// new focal point and/or scale.
typedef GestureTransformUpdateCallback = void Function(
  TransformUpdateDetails details,
);

/// Signature for when the pointers are no longer in contact with the screen.
typedef GestureTransformEndCallback = void Function(
  TransformEndDetails details,
);

/// Details for [GestureTransformStartCallback].
class TransformStartDetails {
  /// Creates details for [GestureTransformStartCallback].
  TransformStartDetails({
    this.pointerCount = 0,
  });

  /// The number of pointers being tracked by the gesture recognizer.
  ///
  /// Typically this is the number of fingers being used to pan the widget using the gesture
  /// recognizer.
  final int pointerCount;

  @override
  String toString() => 'TransformStartDetails(pointerCount: $pointerCount)';
}

/// Details for [GestureTransformUpdateCallback].
class TransformUpdateDetails {
  /// Creates details for [GestureTransformUpdateCallback].
  TransformUpdateDetails({
    required this.pointers,
    required this.localPointers,
    required this.initialLineSegment,
    required this.currentLineSegment,
    required this.transform,
    required this.size,
    required this.pointerVelocities,
  });

  final LineSegment initialLineSegment;
  final LineSegment currentLineSegment;

  final List<Offset> pointers;
  final List<Offset> localPointers;

  final Matrix4 transform;
  final Size size;

  final List<Velocity> pointerVelocities;

  bool get hasSinglePointer => pointers.length == 1;

  Offset get focalPoint =>
      pointers.reduce((a, b) => a + b) * (1 / pointers.length);

  Offset get localFocalPoint =>
      localPointers.reduce((a, b) => a + b) * (1 / pointers.length);

  @override
  String toString() =>
      'TransformUpdateDetails(initialLineSegment: $initialLineSegment, currentLineSegment: $currentLineSegment, transform: $transform)';
}

/// Details for [GestureTransformEndCallback].
class TransformEndDetails {
  /// Creates details for [GestureTransformEndCallback].
  TransformEndDetails({
    this.pointerCount = 0,
  });

  /// The number of pointers being tracked by the gesture recognizer.
  ///
  /// Typically this is the number of fingers being used to pan the widget using the gesture
  /// recognizer.
  final int pointerCount;

  @override
  String toString() => 'ScaleEndDetails(pointerCount: $pointerCount)';
}
