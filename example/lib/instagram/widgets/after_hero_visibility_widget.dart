import 'package:example/instagram/instagram_story_composer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AfterHeroVisibilityWidget extends StatefulWidget {
  const AfterHeroVisibilityWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AfterHeroVisibilityWidget> createState() =>
      _AfterHeroVisibilityWidgetState();
}

class _AfterHeroVisibilityWidgetState extends State<AfterHeroVisibilityWidget>
    with RouteAware {
  var _isVisible = false;
  var _didSchedule = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    storyComposerPageRouteObserver.subscribe(this, ModalRoute.of(context)!);

    if (!_didSchedule) {
      final route = ModalRoute.of(context);
      Future.delayed(
        route!.transitionDuration * timeDilation,
        () {
          if (route.isCurrent == true) {
            setState(() {
              _isVisible = true;
            });
          }
        },
      );

      _didSchedule = true;
    }
  }

  @override
  void dispose() {
    storyComposerPageRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPop() {
    setState(() {
      _isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility.maintain(
      visible: _isVisible,
      child: widget.child,
    );
  }
}
