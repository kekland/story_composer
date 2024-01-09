import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:story_composer/src/_src.dart';
import 'package:story_composer/src/model/story_data.dart';

import 'package:story_composer/src/utils/save_temp_image.dart';

class StoryComposerController extends ChangeNotifier {
  StoryComposerController({
    required this.primaryContent,
    required this.positionedGuides,
    required this.size,
    required this.getChildPaintIndex,
    required this.onWidgetRemoved,
    this.backgroundDecoration,
  });

  final StoryPrimaryContent primaryContent;
  final Size size;
  final List<PositionedSceneGuide> positionedGuides;
  final int Function(BuildContext) getChildPaintIndex;
  final void Function(Key)? onWidgetRemoved;
  final Decoration? backgroundDecoration;

  Offset get center => _viewportSize.center(Offset.zero);

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

  final _sizes = <Key, Size>{};
  final _transformations = <Key, Matrix4>{};

  StoryTransformationController? _activeTransformation;
  StoryTransformationController? get activeTransformation =>
      _activeTransformation;

  void setTransformation({
    required Key key,
    required Matrix4 transform,
    required Size size,
  }) {
    _transformations[key] = transform;
    _sizes[key] = size;
  }

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

    notifyListeners();

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

    notifyListeners();
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

  final _renderables = <Key, GlobalKey>{};

  void attachRenderable(Key key, GlobalKey repaintBoundaryKey) {
    _renderables[key] = repaintBoundaryKey;
  }

  void detachRenderable(Key key) {
    _renderables.remove(key);
  }

  Future<StoryData> render() async {
    // Sort renderables by their paint index.
    final renderableEntries = _renderables.entries.toList()
      ..sort((a, b) {
        final aIndex = getChildPaintIndex(a.value.currentContext!);
        final bIndex = getChildPaintIndex(b.value.currentContext!);

        return aIndex.compareTo(bIndex);
      });

    if (primaryContent is ImageStoryPrimaryContent) {
      final images = await renderRepaintBoundaries(
        renderableEntries
            .map((v) => v.value.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toList(),
        size: size,
      );

      final image = await composeLayeredImages(
        images,
        size: size,
        backgroundDecoration: backgroundDecoration,
      );

      final file = await saveTempImage(image);
      image.dispose();

      return ImageStoryData(
        file,
        size: size,
      );
    } else if (primaryContent is VideoStoryPrimaryContent) {
      final primaryContentKey = ValueKey(primaryContent);

      final images = await renderRepaintBoundaries(
        renderableEntries
            .where((v) => v.key != primaryContentKey)
            .map((v) => v.value.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toList(),
        size: size,
      );

      final overlayImage = await composeLayeredImages(
        images,
        size: size,
        backgroundDecoration: null,
      );

      final backgroundImage = await renderBackground(
        backgroundDecoration!,
        size,
      );

      final (file, thumbnailFile) = await renderVideo(
        canvasSize: size,
        viewportSize: _viewportSize,
        primaryContent: primaryContent as VideoStoryPrimaryContent,
        primaryContentSize: _sizes[primaryContentKey]!,
        primaryContentTransformation: _transformations[primaryContentKey]!,
        overlayImage: overlayImage,
        backgroundImage: backgroundImage,
      );

      backgroundImage.dispose();
      overlayImage.dispose();

      return VideoStoryData(
        file,
        thumbnailFile: thumbnailFile,
        size: size,
        duration: (primaryContent as VideoStoryPrimaryContent).duration,
      );
    }

    throw UnimplementedError();
  }

  late Size _viewportSize;

  late SceneGuides _sceneGuides;
  SceneGuides get sceneGuides => _sceneGuides;

  void setViewportSize(Size size) {
    _viewportSize = size;
    _computeSceneGuides();
  }

  void _computeSceneGuides() {
    _sceneGuides = SceneGuides(
      guides:
          positionedGuides.map((v) => v.toSceneGuide(_viewportSize)).toList(),
    );
  }
}
