import 'package:flutter/material.dart';

enum TextBackgroundColorStyle {
  none,
  textPrimary,
  backgroundPrimary,
}

class TextBackgroundColorStylePicker extends StatelessWidget {
  const TextBackgroundColorStylePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TextBackgroundColorStyle value;
  final ValueChanged<TextBackgroundColorStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        final index = TextBackgroundColorStyle.values.indexOf(value);
        final nextIndex = (index + 1) % TextBackgroundColorStyle.values.length;

        onChanged(TextBackgroundColorStyle.values[nextIndex]);
      },
      color: Colors.white,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 125),
        child: switch (value) {
          TextBackgroundColorStyle.none => const Icon(
              key: Key('none'),
              Icons.check_box_outline_blank_rounded,
            ),
          _ => const Icon(
              key: Key('any-primary'),
              Icons.gradient_rounded,
            ),
        },
      ),
    );
  }
}
