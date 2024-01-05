import 'package:example/instagram/stickers_bottom_sheet/stickers_bottom_sheet.dart';
import 'package:example/instagram/text_component/story_text_component.dart';
import 'package:example/instagram/text_component/story_text_component_data.dart';
import 'package:example/instagram/text_editing_dialog/dialog_route_with_hero.dart';
import 'package:example/instagram/text_editing_dialog/text_editing_dialog.dart';
import 'package:example/instagram/widgets/icons.dart';
import 'package:flutter/material.dart';
import 'package:story_composer/story_composer.dart';

final storyComposerPageRouteObserver = RouteObserver<ModalRoute<void>>();

class InstagramStoryComposerPage extends StatefulWidget {
  const InstagramStoryComposerPage({
    super.key,
    required this.primaryContent,
  });

  final StoryPrimaryContent primaryContent;

  @override
  State<InstagramStoryComposerPage> createState() =>
      _InstagramStoryComposerPageState();
}

class _InstagramStoryComposerPageState
    extends State<InstagramStoryComposerPage> {
  late final _heroController = HeroController();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      observers: [
        storyComposerPageRouteObserver,
        _heroController,
      ],
      onPopPage: (route, result) {
        if (route.isFirst) {
          Navigator.pop(context, result);
        }

        return route.didPop(result);
      },
      pages: [
        MaterialPage(
          child: _StoryComposerMainPage(
            primaryContent: widget.primaryContent,
          ),
        ),
      ],
    );
  }
}

class _StoryComposerMainPage extends StatefulWidget {
  const _StoryComposerMainPage({super.key, required this.primaryContent});

  final StoryPrimaryContent primaryContent;

  @override
  State<_StoryComposerMainPage> createState() => _StoryComposerMainPageState();
}

class _StoryComposerMainPageState extends State<_StoryComposerMainPage>
    with RouteAware {
  final _composerKey = GlobalKey<StoryComposerCanvasState>();
  bool _isTopmostRoute = true;
  final _children = <Widget>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    storyComposerPageRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    storyComposerPageRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    _isTopmostRoute = false;
    setState(() {});
  }

  @override
  void didPopNext() {
    _isTopmostRoute = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: StoryComposerCanvas(
          key: _composerKey,
          primaryContent: widget.primaryContent,
          size: const Size(1080, 1920),
          backgroundColor: Colors.black,
          trashAreaWidget: const Padding(
            padding: EdgeInsets.all(16.0),
            child: StoryTrashAreaWidget(size: 64.0),
          ),
          trashAreaAlignment: Alignment.bottomCenter,
          onWidgetRemoved: (key) {
            _children.removeWhere((child) => child.key == key);
            setState(() {});
          },
          guides: SceneGuides.fromPadding(
            const EdgeInsets.only(
              top: 64.0,
              bottom: 80.0,
              left: 16.0,
              right: 16.0,
            ),
          ),
          children: [
            ..._children,
          ],
        ),
      ),
      Positioned.fill(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              opacity: _isTopmostRoute ? 1.0 : 0.0,
              child: _TopButtonsRow(
                onTextAdded: (data) {
                  setState(() {
                    _children.add(
                      StoryOverlayWidget(
                        key: UniqueKey(),
                        child: StoryTextComponent(
                          data: data,
                        ),
                      ),
                    );
                  });
                },
                onStickerAdded: (sticker) {
                  setState(() {
                    _children.add(
                      StoryOverlayWidget(
                        key: UniqueKey(),
                        child: sticker,
                      ),
                    );
                  });
                },
              ),
            ),
          ),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Flexible(
                child: Stack(
                  children: [
                    ...children,
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  opacity: _isTopmostRoute ? 1.0 : 0.0,
                  child: _BottomButtonsRow(
                    onSubmit: () async {
                      final image =
                          await _composerKey.currentState!.controller.render();

                      if (mounted) {
                        Navigator.pop(context, image);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopButtonsRow extends StatelessWidget {
  const _TopButtonsRow({
    super.key,
    required this.onTextAdded,
    required this.onStickerAdded,
  });

  final ValueChanged<StoryTextComponentData> onTextAdded;
  final ValueChanged<Widget> onStickerAdded;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = TextButton.styleFrom(
      backgroundColor: Colors.black38,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      padding: EdgeInsets.zero,
      elevation: 0.0,
    );

    return SizedBox(
      height: 44.0,
      child: Row(
        children: [
          SizedBox.square(
            dimension: 44.0,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: buttonStyle,
              child: const Icon(Icons.chevron_left_rounded),
            ),
          ),
          const Spacer(),
          SizedBox.square(
            dimension: 44.0,
            child: TextButton(
              onPressed: () async {
                final data = await Navigator.of(context).push(
                  DialogRouteWithHero(
                    builder: (_) => const TextEditingDialog(),
                  ),
                );

                if (data is StoryTextComponentData) {
                  onTextAdded(data);
                }
              },
              style: buttonStyle,
              child: const Icon(Icons.text_fields_rounded),
            ),
          ),
          const SizedBox(width: 8.0),
          SizedBox.square(
            dimension: 44.0,
            child: TextButton(
              onPressed: () async {
                final sticker = await StickersBottomSheet.show(context);

                if (sticker != null) {
                  onStickerAdded(sticker);
                }
              },
              style: buttonStyle,
              child: const Icon(Icons.add_reaction_rounded),
            ),
          ),
          const SizedBox(width: 8.0),
          SizedBox.square(
            dimension: 44.0,
            child: TextButton(
              onPressed: () {},
              style: buttonStyle,
              child: const Icon(Icons.more_horiz_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomButtonsRow extends StatelessWidget {
  const _BottomButtonsRow({
    super.key,
    required this.onSubmit,
  });

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = TextButton.styleFrom(
      backgroundColor: Colors.white12,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      padding: EdgeInsets.zero,
      elevation: 0.0,
    );

    final submitButtonStyle = TextButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      padding: EdgeInsets.zero,
      elevation: 0.0,
    );

    return SizedBox(
      height: 44.0,
      child: Row(
        children: [
          Expanded(
            child: SizedBox.square(
              dimension: 44.0,
              child: TextButton.icon(
                onPressed: onSubmit,
                style: buttonStyle,
                icon: const UserAvatarIcon(),
                label: const Text('Your story'),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: SizedBox.square(
              dimension: 44.0,
              child: TextButton.icon(
                onPressed: onSubmit,
                style: buttonStyle,
                icon: const CloseFriendsIcon(),
                label: const Text('Close friends'),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          SizedBox.square(
            dimension: 44.0,
            child: TextButton(
              onPressed: onSubmit,
              style: submitButtonStyle,
              child: const Icon(Icons.chevron_right_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
