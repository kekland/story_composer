import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class LayoutTimeSizeNotifierWidget extends SingleChildRenderObjectWidget {
  const LayoutTimeSizeNotifierWidget({
    Key? key,
    required Widget child,
    required this.onSizeChanged,
  }) : super(key: key, child: child);

  final void Function(Size size) onSizeChanged;

  @override
  RenderLayoutTimeSizeNotifier createRenderObject(BuildContext context) {
    return RenderLayoutTimeSizeNotifier(onSizeChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLayoutTimeSizeNotifier renderObject,
  ) {
    renderObject.onLayoutTimeSize = onSizeChanged;
  }
}

class RenderLayoutTimeSizeNotifier extends RenderProxyBox {
  RenderLayoutTimeSizeNotifier(this.onLayoutTimeSize);

  void Function(Size size) onLayoutTimeSize;

  @override
  void performLayout() {
    super.performLayout();
    onLayoutTimeSize(size);
  }
}
