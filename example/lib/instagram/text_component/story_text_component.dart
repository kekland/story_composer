import 'package:example/instagram/text_component/story_text_component_data.dart';
import 'package:example/instagram/text_editing_dialog/dialog_route_with_hero.dart';
import 'package:example/instagram/text_editing_dialog/text_editing_dialog.dart';
import 'package:flutter/material.dart';

class StoryTextComponent extends StatefulWidget {
  const StoryTextComponent({
    super.key,
    required this.data,
    this.isInteractable = true,
  });

  final StoryTextComponentData data;
  final bool isInteractable;

  @override
  State<StoryTextComponent> createState() => _StoryTextComponentState();
}

class _StoryTextComponentState extends State<StoryTextComponent> {
  late var _data = widget.data;
  var _isVisible = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = _data.textStyle.copyWith(
      color: _data.textColor,
    );

    final child = Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          color: _data.backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 6.0,
          vertical: 6.0,
        ),
        child: Text(
          _data.text,
          strutStyle: StrutStyle.fromTextStyle(
            textStyle,
            forceStrutHeight: true,
          ),
          style: textStyle,
          textAlign: _data.textAlign,
        ),
      ),
    );

    if (widget.isInteractable) {
      return GestureDetector(
        onTap: () async {
          _isVisible = false;
          setState(() {});

          final newData = await Navigator.of(context).push(
            DialogRouteWithHero(
              builder: (_) => TextEditingDialog(data: _data),
            ),
          );

          if (newData is StoryTextComponentData) {
            _data = newData;
          }

          _isVisible = true;
          setState(() {});
        },
        child: Visibility.maintain(
          visible: _isVisible,
          child: child,
        ),
      );
    }

    return child;
  }
}
