import 'package:flutter/widgets.dart';
import 'package:story_composer/src/_src.dart';

class InheritedStoryComposerController extends InheritedWidget {
  const InheritedStoryComposerController({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  final StoryComposerController controller;

  @override
  bool updateShouldNotify(InheritedStoryComposerController oldWidget) {
    return controller != oldWidget.controller;
  }
}
