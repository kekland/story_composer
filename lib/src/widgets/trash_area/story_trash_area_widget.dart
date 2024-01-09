import 'package:flutter/material.dart';
import 'package:story_composer/src/widgets/trash_area/story_trash_area_state_mixin.dart';

class StoryTrashAreaWidget extends StatefulWidget {
  const StoryTrashAreaWidget({super.key, this.size = 80.0});

  final double size;

  @override
  State<StoryTrashAreaWidget> createState() => StoryTrashAreaWidgetState();
}

class StoryTrashAreaWidgetState extends State<StoryTrashAreaWidget>
    with StoryTrashAreaStateMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 150),
        curve: decelerateEasing,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(48.0),
              color: Colors.black.withOpacity(0.25),
            ),
            child: Icon(
              Icons.delete,
              size: widget.size / 2.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
