import 'package:example/instagram/text_editing_dialog/text_color_picker.dart';
import 'package:example/instagram/text_editing_dialog/text_font_picker.dart';
import 'package:flutter/widgets.dart';

enum TextOptionsBarMode {
  font,
  color,
}

class TextOptionsBar extends StatelessWidget {
  const TextOptionsBar({
    super.key,
    required this.mode,
    required this.font,
    required this.color,
    required this.onFontChanged,
    required this.onColorChanged,
  });

  final TextStyle font;
  final Color color;
  final ValueChanged<TextStyle> onFontChanged;
  final ValueChanged<Color> onColorChanged;
  final TextOptionsBarMode mode;

  Widget _buildVisibiltyAnimation(
    BuildContext context, {
    required bool isVisible,
    required Widget child,
  }) {
    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 125),
        curve: Curves.easeInOut,
        offset: isVisible ? const Offset(0.0, 0.0) : const Offset(0.0, 0.25),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 125),
          curve: Curves.easeInOut,
          opacity: isVisible ? 1.0 : 0.0,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Stack(
          children: [
            _buildVisibiltyAnimation(
              context,
              isVisible: mode == TextOptionsBarMode.font,
              child: TextColorPicker(
                value: color,
                onChanged: onColorChanged,
              ),
            ),
            _buildVisibiltyAnimation(
              context,
              isVisible: mode == TextOptionsBarMode.color,
              child: TextFontPicker(
                value: font,
                onChanged: onFontChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
