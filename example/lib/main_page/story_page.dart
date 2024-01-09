import 'package:flutter/material.dart';
import 'package:story_composer/story_composer.dart';

class StoryPage extends StatelessWidget {
  const StoryPage({
    super.key,
    required this.story,
    required this.heroId,
  });

  final StoryData story;
  final String heroId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Hero(
          tag: heroId,
          flightShuttleBuilder: (
            flightContext,
            animation,
            flightDirection,
            fromHeroContext,
            toHeroContext,
          ) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final borderRadiusCollapsed = BorderRadius.circular(32.0);
                final borderRadiusExpanded = BorderRadius.circular(0.0);

                final borderRadius = BorderRadiusTween(
                  begin: borderRadiusCollapsed,
                  end: borderRadiusExpanded,
                ).evaluate(animation)!;

                return ClipRRect(
                  borderRadius: borderRadius,
                  child: child,
                );
              },
              child: StoryViewer.thumbnail(data: story),
            );
          },
          child: StoryViewer(data: story),
        ),
      ),
    );
  }
}
