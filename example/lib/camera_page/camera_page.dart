import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:story_composer/story_composer.dart';

enum _CaptureType {
  unknown,
  image,
  video,
  loading,
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  List<CameraDescription>? _cameras;
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _cameras = await availableCameras();
    await _setController(_cameras!.first);
  }

  Future<void> _setController(CameraDescription camera) async {
    await _controller?.dispose();

    _controller = CameraController(
      camera,
      ResolutionPreset.veryHigh,
    );

    await _controller?.initialize();
    setState(() {});
  }

  Future<void> _cycleCameras() async {
    final index = _cameras!.indexOf(_controller!.description);
    final nextIndex = (index + 1) % _cameras!.length;

    await _setController(_cameras![nextIndex]);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  static const _videoCaptureDelay = Duration(milliseconds: 350);
  static const _videoCaptureDuration = Duration(seconds: 15);

  _CaptureType? _captureType;

  Future<void> _onCaptureStart() async {
    _captureType = _CaptureType.unknown;
    setState(() {});

    Future.delayed(_videoCaptureDelay, () async {
      if (_captureType != _CaptureType.unknown) {
        return;
      }

      return _onVideoCaptureStart();
    });
  }

  Future<void> _onCaptureEnd() async {
    final StoryPrimaryContent primaryContent;

    if (_captureType == _CaptureType.video) {
      primaryContent = await _onVideoCaptureEnd();
    } else {
      primaryContent = await _onImageCaptureEnd();
    }

    if (!mounted) return;

    _captureType = null;
    setState(() {});

    await primaryContent.precache(context);

    if (!mounted) return;
    Navigator.pop(context, primaryContent);
  }

  Future<void> _onVideoCaptureStart() async {
    _captureType = _CaptureType.video;
    setState(() {});

    await _controller!.startVideoRecording();
  }

  Future<StoryPrimaryContent> _onVideoCaptureEnd() async {
    _captureType = _CaptureType.loading;

    setState(() {});

    final xFile = await _controller!.stopVideoRecording();
    final file = File(xFile.path);

    return VideoStoryPrimaryContent(file);
  }

  Future<StoryPrimaryContent> _onImageCaptureEnd() async {
    _captureType = _CaptureType.image;
    setState(() {});

    final file = await _controller?.takePicture();
    final provider = FileImage(File(file!.path));

    return ImageStoryPrimaryContent(provider);
  }

  Future<void> _onGalleryOpened() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.media,
    );

    if (result == null) return;

    final resultFile = result.files.single;
    final file = File(resultFile.path!);

    final primaryContent = acceptedVideoFormats.contains(resultFile.extension!)
        ? VideoStoryPrimaryContent(file)
        : ImageStoryPrimaryContent(FileImage(file));

    if (!mounted) return;
    await primaryContent.precache(context);

    if (!mounted) return;
    Navigator.pop(context, primaryContent);
  }

  @override
  Widget build(BuildContext context) {
    final child =
        _controller == null ? const SizedBox() : CameraPreview(_controller!);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Stack(
              children: [
                child,
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _TopButtonsRow(
                      onCameraSwitched: _cycleCameras,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _BottomButtonsRow(
                      onGalleryOpened: _onGalleryOpened,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _CaptureButton(
                      captureType: _captureType,
                      onCaptureStart: _onCaptureStart,
                      onCaptureEnd: _onCaptureEnd,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomButtonsRow extends StatelessWidget {
  const _BottomButtonsRow({
    super.key,
    required this.onGalleryOpened,
  });

  final VoidCallback onGalleryOpened;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = TextButton.styleFrom(
      backgroundColor: Colors.black38,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      padding: EdgeInsets.zero,
      elevation: 0.0,
    );

    return SizedBox(
      height: 64.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: 44.0,
            child: TextButton(
              onPressed: onGalleryOpened,
              style: buttonStyle,
              child: const Icon(Icons.photo_library_rounded),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _TopButtonsRow extends StatelessWidget {
  const _TopButtonsRow({
    super.key,
    required this.onCameraSwitched,
  });

  final VoidCallback onCameraSwitched;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = TextButton.styleFrom(
      backgroundColor: Colors.black38,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      padding: EdgeInsets.zero,
      elevation: 0.0,
    );

    return SizedBox(
      height: 44.0,
      child: Row(
        children: [
          SizedBox.square(
            dimension: 44.0,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: buttonStyle,
              child: const Icon(Icons.chevron_left_rounded),
            ),
          ),
          const Spacer(),
          SizedBox.square(
            dimension: 44.0,
            child: TextButton(
              onPressed: () async {},
              style: buttonStyle,
              child: const Icon(Icons.flash_off),
            ),
          ),
          const SizedBox(width: 8.0),
          SizedBox.square(
            dimension: 44.0,
            child: TextButton(
              onPressed: onCameraSwitched,
              style: buttonStyle,
              child: const Icon(Icons.cameraswitch_rounded),
            ),
          ),
          const SizedBox(width: 8.0),
          SizedBox.square(
            dimension: 44.0,
            child: TextButton(
              onPressed: () {},
              style: buttonStyle,
              child: const Icon(Icons.more_horiz_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureButton extends StatefulWidget {
  const _CaptureButton({
    super.key,
    required this.captureType,
    required this.onCaptureStart,
    required this.onCaptureEnd,
  });

  final _CaptureType? captureType;
  final VoidCallback onCaptureStart;
  final VoidCallback onCaptureEnd;

  @override
  State<_CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<_CaptureButton>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();

    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _CaptureButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.captureType != widget.captureType) {
      if (widget.captureType == _CaptureType.video) {
        _onVideoCaptureStart();
      } else {
        _onVideoCaptureEnd();
      }
    }
  }

  void _onVideoCaptureStart() {
    _ticker.start();
    _currentCaptureDuration = Duration.zero;

    setState(() {});
  }

  void _onVideoCaptureEnd() {
    _ticker.stop();
    _currentCaptureDuration = null;

    setState(() {});
  }

  Duration? _currentCaptureDuration;

  void _onTick(Duration duration) {
    _currentCaptureDuration = duration;
    setState(() {});
  }

  Widget _buildCaptureIndicator(BuildContext context) {
    if (widget.captureType == null ||
        widget.captureType == _CaptureType.unknown) {
      return Container(
        key: const ValueKey('idle'),
        width: 64.0,
        height: 64.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
        ),
      );
    }

    if (widget.captureType == _CaptureType.image ||
        widget.captureType == _CaptureType.loading) {
      return const SizedBox.square(
        dimension: 64.0,
        child: CircularProgressIndicator(
          key: ValueKey('image'),
          color: Colors.white,
          strokeWidth: 2.0,
        ),
      );
    }

    if (widget.captureType == _CaptureType.video) {
      return SizedBox.square(
        dimension: 64.0,
        child: CircularProgressIndicator(
          key: const ValueKey('video'),
          color: Colors.white,
          strokeWidth: 2.0,
          value: _currentCaptureDuration!.inMilliseconds /
              const Duration(seconds: 15).inMilliseconds,
        ),
      );
    }

    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 64.0,
          height: 64.0,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(32.0),
              onTapDown: (_) => widget.onCaptureStart(),
              onTapUp: (_) => widget.onCaptureEnd(),
            ),
          ),
        ),
        Transform.scale(
          scale: 1.2,
          child: IgnorePointer(
            child: SizedBox.square(
              dimension: 64.0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildCaptureIndicator(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
