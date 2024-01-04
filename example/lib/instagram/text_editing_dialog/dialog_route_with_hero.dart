import 'package:flutter/material.dart';

/// A dialog route with Material entrance and exit animations,
/// modal barrier color, and modal barrier behavior (dialog is dismissible
/// with a tap on the barrier).
///
/// It is used internally by [showDialog] or can be directly pushed
/// onto the [Navigator] stack to enable state restoration. See
/// [showDialog] for a state restoration app example.
///
/// This function takes a `builder` which typically builds a [Dialog] widget.
/// Content below the dialog is dimmed with a [ModalBarrier]. The widget
/// returned by the `builder` does not share a context with the location that
/// `showDialog` is originally called from. Use a [StatefulBuilder] or a
/// custom [StatefulWidget] if the dialog needs to update dynamically.
///
/// The `context` argument is used to look up
/// [MaterialLocalizations.modalBarrierDismissLabel], which provides the
/// modal with a localized accessibility label that will be used for the
/// modal's barrier. However, a custom `barrierLabel` can be passed in as well.
///
/// The `barrierDismissible` argument is used to indicate whether tapping on the
/// barrier will dismiss the dialog. It is `true` by default and cannot be `null`.
///
/// The `barrierColor` argument is used to specify the color of the modal
/// barrier that darkens everything below the dialog. If `null`, the default
/// color `Colors.black54` is used.
///
/// The `useSafeArea` argument is used to indicate if the dialog should only
/// display in 'safe' areas of the screen not used by the operating system
/// (see [SafeArea] for more details). It is `true` by default, which means
/// the dialog will not overlap operating system areas. If it is set to `false`
/// the dialog will only be constrained by the screen size. It can not be `null`.
///
/// The `settings` argument define the settings for this route. See
/// [RouteSettings] for details.
///
/// {@macro flutter.widgets.RawDialogRoute}
///
/// See also:
///
///  * [showDialog], which is a way to display a DialogRoute.
///  * [showGeneralDialog], which allows for customization of the dialog popup.
///  * [showCupertinoDialog], which displays an iOS-style dialog.
///  * [DisplayFeatureSubScreen], which documents the specifics of how
///    [DisplayFeature]s can split the screen into sub-screens.
class DialogRouteWithHero<T> extends PageRoute<T> {
  DialogRouteWithHero({
    required this.builder,
    this.barrierColor = Colors.black54,
    this.barrierLabel,
    this.themes,
    this.useSafeArea = true,
  });

  @override
  final Color barrierColor;

  @override
  final String? barrierLabel;

  final WidgetBuilder builder;
  final CapturedThemes? themes;
  final bool useSafeArea;

  @override
  bool get maintainState => false;

  @override
  bool get fullscreenDialog => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget pageChild = Builder(builder: builder);
    Widget dialog = themes?.wrap(pageChild) ?? pageChild;

    if (useSafeArea) {
      dialog = SafeArea(child: dialog);
    }

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: dialog,
    );
  }
}
