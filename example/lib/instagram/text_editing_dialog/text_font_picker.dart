import 'package:example/instagram/text_editing_dialog/slidable_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum TextFont {
  roboto,
  robotoBold,
  lobster,
  robotoSlab,
  robotoMono;

  static TextFont defaultFont = TextFont.roboto;

  static TextFont fromTextStyle(TextStyle style) {
    return _textStyleToTextFont(style);
  }

  TextStyle get textStyle {
    return _textFontToTextStyle(this);
  }
}

Map<TextFont, TextStyle> _textFontToTextStyleMap = {
  TextFont.roboto: GoogleFonts.roboto(),
  TextFont.robotoBold: GoogleFonts.roboto(fontWeight: FontWeight.bold),
  TextFont.lobster: GoogleFonts.lobster(),
  TextFont.robotoSlab: GoogleFonts.robotoSlab(),
  TextFont.robotoMono: GoogleFonts.robotoMono(),
};

TextStyle _textFontToTextStyle(TextFont font) {
  return _textFontToTextStyleMap[font]!;
}

TextFont _textStyleToTextFont(TextStyle style) {
  return _textFontToTextStyleMap.entries
      .firstWhere(
        (e) =>
            e.value.fontFamily == style.fontFamily &&
            e.value.fontWeight == style.fontWeight,
      )
      .key;
}

class TextFontPicker extends StatelessWidget {
  const TextFontPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TextStyle value;
  final ValueChanged<TextStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    return SlidablePickerWidget(
      values: TextFont.values,
      value: TextFont.fromTextStyle(value),
      onChanged: (v) {
        onChanged(v.textStyle);
      },
      itemBuilder: (context, font, isSelected, onTap) {
        return SizedBox.square(
          dimension: 32.0,
          child: TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              elevation: 0.0,
              backgroundColor: isSelected ? Colors.white : Colors.black38,
              surfaceTintColor: Colors.transparent,
            ),
            child: Text(
              'Aa',
              style: font.textStyle.copyWith(
                fontSize: 14.0,
                height: 1.0,
                color: isSelected ? Colors.black : Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
