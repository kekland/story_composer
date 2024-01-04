import 'dart:io';

import 'package:camera/camera.dart';
import 'package:example/instagram/instagram_story_composer_page.dart';
import 'package:flutter/material.dart';

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
    print('ayo');
    print(_cameras);
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

  Future<void> _onCapture() async {
    final picture = await _controller?.takePicture();
    final provider = FileImage(File(picture!.path));

    if (!mounted) return;

    await precacheImage(provider, context);

    if (!mounted) return;

    Navigator.pop(context, provider);
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
                    child: _CaptureButton(
                      onCapture: _onCapture,
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
  const _CaptureButton({super.key, required this.onCapture});

  final Future<void> Function() onCapture;

  @override
  State<_CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<_CaptureButton> {
  bool _isCapturing = false;

  Future<void> _capture() async {
    setState(() {
      _isCapturing = true;
    });

    await widget.onCapture();

    if (!mounted) return;

    setState(() {
      _isCapturing = false;
    });
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
              onTap: _capture,
            ),
          ),
        ),
        Transform.scale(
          scale: 1.2,
          child: IgnorePointer(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isCapturing
                  ? const SizedBox.square(
                      dimension: 64.0,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                  : Container(
                      width: 64.0,
                      height: 64.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
