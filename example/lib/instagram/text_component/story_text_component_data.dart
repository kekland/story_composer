import 'package:example/instagram/color_utils.dart';
import 'package:example/instagram/text_editing_dialog/text_background_color_style_picker.dart';
import 'package:flutter/material.dart';

class StoryTextComponentData {
  const StoryTextComponentData({
    required this.id,
    required this.text,
    required this.textStyle,
    required this.color,
    required this.textAlign,
    required this.backgroundColorStyle,
  });

  final String id;
  final String text;
  final TextStyle textStyle;
  final Color color;
  final TextAlign textAlign;
  final TextBackgroundColorStyle backgroundColorStyle;

  Color get primaryColor => color;
  Color get secondaryColor {
    if (color == Colors.white) {
      return Colors.black;
    } else if (color == Colors.black) {
      return Colors.white;
    }

    if (color is MaterialColor) {
      return (color as MaterialColor).shade100;
    }

    return lighten(color, 0.5);
  }

  Color get textColor {
    switch (backgroundColorStyle) {
      case TextBackgroundColorStyle.none:
        return primaryColor;
      case TextBackgroundColorStyle.textPrimary:
        return primaryColor;
      case TextBackgroundColorStyle.backgroundPrimary:
        return secondaryColor;
    }
  }

  Color get backgroundColor {
    switch (backgroundColorStyle) {
      case TextBackgroundColorStyle.none:
        return Colors.transparent;
      case TextBackgroundColorStyle.textPrimary:
        return secondaryColor;
      case TextBackgroundColorStyle.backgroundPrimary:
        return primaryColor;
    }
  }
}
