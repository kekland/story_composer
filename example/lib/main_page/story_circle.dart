import 'package:flutter/material.dart';

class StoryCircle extends StatelessWidget {
  const StoryCircle({
    super.key,
    required this.child,
    required this.hasBorder,
    this.onTap,
  });

  final Widget child;
  final bool hasBorder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 64.0,
          height: 64.0,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              IgnorePointer(child: child),
              Material(
                type: MaterialType.transparency,
                borderRadius: BorderRadius.circular(32.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(32.0),
                  onTap: onTap,
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
        if (hasBorder)
          IgnorePointer(
            child: Transform.scale(
              scale: 1.2,
              child: Container(
                width: 64.0,
                height: 64.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.indigo,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
