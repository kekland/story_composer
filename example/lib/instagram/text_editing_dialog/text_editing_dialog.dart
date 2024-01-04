import 'dart:math';

import 'package:example/instagram/text_component/story_text_component.dart';
import 'package:example/instagram/text_component/story_text_component_data.dart';
import 'package:example/instagram/text_editing_dialog/text_align_picker.dart';
import 'package:example/instagram/text_editing_dialog/text_background_color_style_picker.dart';
import 'package:example/instagram/text_editing_dialog/text_font_picker.dart';
import 'package:example/instagram/text_editing_dialog/text_options_bar.dart';
import 'package:example/instagram/text_editing_dialog/text_size_slider.dart';
import 'package:example/instagram/widgets/after_hero_visibility_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class TextEditingDialog extends StatefulWidget {
  const TextEditingDialog({
    super.key,
    this.data,
  });

  final StoryTextComponentData? data;

  @override
  State<TextEditingDialog> createState() => _TextEditingDialogState();
}

class _TextEditingDialogState extends State<TextEditingDialog> {
  late final _controller = TextEditingController(
    text: widget.data?.text ?? '',
  );

  late final _focusNode = FocusNode();

  late final _id = widget.data?.id ?? Random().nextInt(1 << 32).toString();
  late var _font = widget.data?.textStyle ?? TextFont.defaultFont.textStyle;
  late var _fontSize = widget.data?.textStyle.fontSize ?? 20.0;
  late var _color = widget.data?.color ?? Colors.white;
  late var _textAlign = widget.data?.textAlign ?? TextAlign.center;
  late var _backgroundColorStyle =
      widget.data?.backgroundColorStyle ?? TextBackgroundColorStyle.none;

  StoryTextComponentData get data => StoryTextComponentData(
        id: _id,
        text: _controller.text,
        textStyle: _font.copyWith(fontSize: _fontSize),
        color: _color,
        backgroundColorStyle: _backgroundColorStyle,
        textAlign: _textAlign,
      );

  late var _textOptionsBarMode = TextOptionsBarMode.font;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        Navigator.pop(context, data);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topBar = Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 48.0,
                child: TextAlignPicker(
                  value: _textAlign,
                  onChanged: (value) {
                    setState(() {
                      _textAlign = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8.0),
              SizedBox.square(
                dimension: 48.0,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _textOptionsBarMode =
                          _textOptionsBarMode == TextOptionsBarMode.font
                              ? TextOptionsBarMode.color
                              : TextOptionsBarMode.font;
                    });
                  },
                  color: Colors.white,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 125),
                    child: _textOptionsBarMode == TextOptionsBarMode.font
                        ? const Icon(
                            key: Key('font-style-picker'),
                            Icons.text_fields_rounded,
                          )
                        : const Icon(
                            key: Key('font-color-picker'),
                            Icons.color_lens_rounded,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              SizedBox.square(
                dimension: 48.0,
                child: TextBackgroundColorStylePicker(
                  value: _backgroundColorStyle,
                  onChanged: (value) {
                    setState(() {
                      _backgroundColorStyle = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              _focusNode.unfocus();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: const Text('Done'),
          ),
        ),
      ],
    );

    final editor = Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          color: data.backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.symmetric(
          horizontal: 6.0,
          vertical: 6.0,
        ),
        child: IntrinsicWidth(
          child: EditableText(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            cursorColor: data.textColor,
            backgroundCursorColor: data.textColor,
            minLines: 1,
            maxLines: 8,
            textAlign: _textAlign,
            cursorWidth: 1.0,
            textWidthBasis: TextWidthBasis.longestLine,
            keyboardAppearance: Brightness.dark,
            style: _font.copyWith(
              color: data.textColor,
              fontSize: _fontSize,
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TextFieldTapRegion(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 16.0),
                  SizedBox(
                    height: 48.0,
                    child: topBar,
                  ),
                  const Spacer(),
                  editor,
                  const Spacer(),
                  SizedBox(
                    height: 48.0,
                    child: TextOptionsBar(
                      font: _font,
                      color: _color,
                      mode: _textOptionsBarMode,
                      onColorChanged: (color) {
                        setState(() {
                          _color = color;
                        });
                      },
                      onFontChanged: (font) {
                        setState(() {
                          _font = font;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
              Align(
                alignment: const Alignment(-1.0, -0.35),
                child: ExcludeFocus(
                  child: TextSizeSlider(
                    value: _fontSize,
                    onChanged: (value) {
                      setState(() {
                        _fontSize = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
