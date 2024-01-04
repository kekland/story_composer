import 'package:flutter/material.dart';

class TextSizeSlider extends StatefulWidget {
  const TextSizeSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<TextSizeSlider> createState() => _TextSizeSliderState();
}

class _TextSizeSliderState extends State<TextSizeSlider> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 3,
      child: SizedBox(
        width: 240.0,
        height: 40.0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 125),
          curve: Curves.easeInOut,
          offset:
              _isDragging ? const Offset(0.0, 0.0) : const Offset(0.0, -0.5),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 125),
            curve: Curves.easeInOut,
            opacity: _isDragging ? 1.0 : 0.5,
            child: Slider(
              value: widget.value,
              min: 8.0,
              max: 40.0,
              thumbColor: Colors.white,
              activeColor: Colors.white,
              inactiveColor: Colors.white24,
              onChanged: widget.onChanged,
              onChangeStart: (value) {
                setState(() {
                  _isDragging = true;
                });
              },
              onChangeEnd: (value) {
                setState(() {
                  _isDragging = false;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
