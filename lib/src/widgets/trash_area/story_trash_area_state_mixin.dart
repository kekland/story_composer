import 'package:flutter/widgets.dart';
import 'package:story_composer/src/_src.dart';

mixin StoryTrashAreaStateMixin<T extends StatefulWidget> on State<T> {
  StoryComposerController? _controller;

  bool isVisible = false;
  bool isInside = false;

  void showTrashArea() {
    if (isVisible) return;

    setState(() {
      isVisible = true;
    });
  }

  void hideTrashArea() {
    if (!isVisible) return;

    setState(() {
      isVisible = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _controller = StoryComposerController.of(context);
    _controller?.attachTrashAreaState(this);
  }

  @override
  void dispose() {
    _controller?.detachTrashAreaState(this);
    super.dispose();
  }

  Rect? trashAreaRect;

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final renderBox = context.findRenderObject() as RenderBox;
      final rect = renderBox.localToGlobal(Offset.zero) & renderBox.size;

      trashAreaRect = rect;
    });

    return const _NullWidget();
  }

  bool onPointerUpdated(Offset pointer) {
    if (trashAreaRect == null) return false;

    final isInside = trashAreaRect!.contains(pointer);

    if (isInside != this.isInside) {
      if (isInside) {
        showTrashArea();
      } else {
        hideTrashArea();
      }
    }

    return isInside;
  }
}

class _NullWidget extends StatelessWidget {
  const _NullWidget();

  @override
  Widget build(BuildContext context) {
    throw FlutterError(
      'Widgets that mix StoryTrashAreaStateMixin into their State must '
      'call super.build() but must ignore the return value of the superclass.',
    );
  }
}
