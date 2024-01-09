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
    final buttonStyle = TextButton.styleFrom(
      backgroundColor: Colors.black38,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      padding: EdgeInsets.zero,
      elevation: 0.0,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
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
                      final borderRadiusExpanded = BorderRadius.circular(16.0);

                      final borderRadius = BorderRadiusTween(
                        begin: borderRadiusCollapsed,
                        end: borderRadiusExpanded,
                      ).evaluate(animation)!;

                      return ClipRRect(
                        borderRadius: borderRadius,
                        child: child,
                      );
                    },
                    child: StoryViewerWidget.thumbnail(
                      data: story,
                      fit: BoxFit.cover,
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: StoryViewerWidget(
                    data: story,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox.square(
                  dimension: 44.0,
                  child: TextButton(
                    style: buttonStyle,
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
