import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SlidablePickerWidget<T> extends StatefulWidget {
  const SlidablePickerWidget({
    super.key,
    required this.values,
    required this.value,
    required this.onChanged,
    required this.itemBuilder,
  });

  final List<T> values;
  final T value;
  final ValueChanged<T> onChanged;
  final Widget Function(
    BuildContext context,
    T item,
    bool isSelected,
    VoidCallback onTap,
  ) itemBuilder;

  @override
  State<SlidablePickerWidget<T>> createState() =>
      _SlidablePickerWidgetState<T>();
}

class _SlidablePickerWidgetState<T> extends State<SlidablePickerWidget<T>> {
  late var _currentPage = _controller.initialPage;

  late final _controller = PageController(
    initialPage: widget.values.indexOf(widget.value),
    viewportFraction: 0.125,
  );

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      final page = _controller.page!.round();

      if (page != _currentPage) {
        HapticFeedback.selectionClick();

        setState(() {
          _currentPage = page;
          widget.onChanged(widget.values[_currentPage]);
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildItem(int index) {
    final item = widget.values[index];
    final isSelected = index == _currentPage;

    return Center(
      child: widget.itemBuilder(
        context,
        item,
        isSelected,
        () {
          _controller.animateToPage(
            index,
            duration: const Duration(milliseconds: 125),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children: [
        for (var i = 0; i < widget.values.length; i++) _buildItem(i),
      ],
    );
  }
}
