import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:story_composer/src/_src.dart';
import 'dart:ui' as ui;

class StoryComposerController extends ChangeNotifier {
  StoryComposerController({
    required this.viewportGuides,
    required this.size,
    required this.getChildPaintIndex,
    required this.onWidgetRemoved,
    this.backgroundColor,
  });

  final Size size;
  final List<ViewportGuide> viewportGuides;
  final int Function(BuildContext) getChildPaintIndex;
  final void Function(Key)? onWidgetRemoved;
  final Color? backgroundColor;

  Offset get center => size.center(Offset.zero);

  static StoryComposerController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedStoryComposerController>()!
        .controller;
  }

  StoryTrashAreaStateMixin? _trashAreaState;
  StoryTrashAreaStateMixin? get trashAreaState => _trashAreaState;

  void attachTrashAreaState(StoryTrashAreaStateMixin state) {
    _trashAreaState = state;
  }

  void detachTrashAreaState(StoryTrashAreaStateMixin state) {
    if (_trashAreaState == state) {
      _trashAreaState = null;
    }
  }

  StoryTransformationController? _activeTransformation;

  StoryTransformationController startTransformation({
    required Key key,
    required Matrix4 initialTransform,
    required Size untransformedSize,
    bool isPersistent = false,
  }) {
    if (_activeTransformation != null) {
      throw StateError(
        'Cannot start a new transformation while another one is active.',
      );
    }

    final result = StoryTransformationController(
      key: key,
      parent: this,
      untransformedSize: untransformedSize,
      initialTransform: initialTransform,
      isPersistent: isPersistent,
    );

    result.addListener(_onActiveTransformationChanged);
    _activeTransformation = result;

    return result;
  }

  void endTransformation() {
    if (_activeTransformation == null) {
      throw StateError(
        'Cannot end a transformation while none is active.',
      );
    }

    if (_activeTransformation!.isInTrashArea) {
      assert(onWidgetRemoved != null);
      onWidgetRemoved!(_activeTransformation!.key);
    }

    _activeTransformation!.removeListener(_onActiveTransformationChanged);
    _activeTransformation = null;

    trashAreaState?.hideTrashArea();
    _activeGuidesNotifier.value = [];
  }

  final _activeGuidesNotifier = ValueNotifier<List<SceneGuide>>([]);
  ValueListenable<List<SceneGuide>> get activeGuides => _activeGuidesNotifier;

  void _onActiveTransformationChanged() {
    if (!listEquals(
        _activeGuidesNotifier.value, _activeTransformation!.snapActiveGuides)) {
      _activeGuidesNotifier.value = _activeTransformation!.snapActiveGuides;
    }
  }

  @override
  void dispose() {
    _activeTransformation?.dispose();
    super.dispose();
  }

  final _renderables = <GlobalKey>[];

  void attachRenderable(GlobalKey key) {
    _renderables.add(key);
  }

  void detachRenderable(GlobalKey key) {
    _renderables.remove(key);
  }

  Future<ui.Image> render() async {
    // Sort renderables by their paint index.
    _renderables.sort((a, b) {
      final aIndex = getChildPaintIndex(a.currentContext!);
      final bIndex = getChildPaintIndex(b.currentContext!);

      return aIndex.compareTo(bIndex);
    });

    final images = await renderRepaintBoundaries(
      _renderables
          .map((v) =>
              v.currentContext!.findRenderObject() as RenderRepaintBoundary)
          .toList(),
    );

    return composeLayeredImages(
      images,
      backgroundColor: backgroundColor,
    );
  }

  SceneGuides? _sceneGuides;
  SceneGuides? get guides => _sceneGuides;

  late Size _viewportSize;
  double _scale = 1.0;

  void setViewportSize(Size size) {
    _viewportSize = size;

    final scaleX = this.size.width / _viewportSize.width;
    final scaleY = this.size.height / _viewportSize.height;

    final scale = min(scaleX, scaleY);

    if (_scale != scale) {
      _scale = scale;
      _computeCanvasSpaceGuides();
    }
  }

  void _computeCanvasSpaceGuides() {
    _sceneGuides = SceneGuides(
      guides: viewportGuides
          .map((g) => g.toSceneGuide(size, _viewportSize, _scale))
          .toList(),
    );
  }

  Offset toScene(Offset offset) {
    return offset * _scale;
  }
}
