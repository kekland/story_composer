import 'package:flutter/material.dart';

class TextAlignPicker extends StatelessWidget {
  const TextAlignPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TextAlign value;
  final ValueChanged<TextAlign> onChanged;

  static const _values = [
    TextAlign.left,
    TextAlign.center,
    TextAlign.right,
  ];

  @override
  Widget build(BuildContext context) {
    final icon = switch (value) {
      TextAlign.left => Icons.format_align_left_rounded,
      TextAlign.center => Icons.format_align_center_rounded,
      TextAlign.right => Icons.format_align_right_rounded,
      _ => throw UnimplementedError(),
    };

    return IconButton(
      onPressed: () {
        final index = _values.indexOf(value);
        final nextIndex = (index + 1) % _values.length;

        onChanged(_values[nextIndex]);
      },
      color: Colors.white,
      icon: Icon(icon),
    );
  }
}
