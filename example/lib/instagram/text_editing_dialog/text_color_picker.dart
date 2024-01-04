import 'package:example/instagram/text_editing_dialog/slidable_picker.dart';
import 'package:flutter/material.dart';

class TextColorPicker extends StatelessWidget {
  const TextColorPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Color value;
  final ValueChanged<Color> onChanged;

  static const colors = [
    Colors.white,
    Colors.black,
    ...Colors.primaries,
  ];

  @override
  Widget build(BuildContext context) {
    return SlidablePickerWidget(
      values: colors,
      value: value,
      onChanged: onChanged,
      itemBuilder: (context, color, isSelected, onTap) {
        return Container(
          width: 32.0,
          height: 32.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 2.0,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          padding: const EdgeInsets.all(2.0),
          child: TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              elevation: 0.0,
              backgroundColor: color,
              surfaceTintColor: Colors.transparent,
            ),
            child: const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
