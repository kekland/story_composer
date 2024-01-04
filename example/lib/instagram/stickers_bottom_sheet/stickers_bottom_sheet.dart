import 'package:flutter/material.dart';

class StickersBottomSheet extends StatelessWidget {
  const StickersBottomSheet({super.key});

  static Future<Widget?> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => const StickersBottomSheet(),
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
    );
  }

  static List<Widget> get stickers => const [
        EmojiSticker(emoji: '😀'),
        EmojiSticker(emoji: '😃'),
        EmojiSticker(emoji: '😄'),
        EmojiSticker(emoji: '😁'),
        EmojiSticker(emoji: '😆'),
        EmojiSticker(emoji: '😅'),
        EmojiSticker(emoji: '😂'),
        EmojiSticker(emoji: '🤣'),
        EmojiSticker(emoji: '😊'),
        EmojiSticker(emoji: '😇'),
        EmojiSticker(emoji: '🙂'),
        EmojiSticker(emoji: '🙃'),
      ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.75,
      expand: false,
      builder: (context, controller) => GridView.builder(
        controller: controller,
        itemCount: stickers.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemBuilder: (context, i) {
          return InkWell(
            onTap: () {
              Navigator.of(context).pop(stickers[i]);
            },
            child: Center(
              child: stickers[i],
            ),
          );
        },
      ),
    );
  }
}

class EmojiSticker extends StatelessWidget {
  const EmojiSticker({
    super.key,
    required this.emoji,
  });

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96.0,
      height: 96.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white12,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(8.0),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(
              fontSize: 64.0,
            ),
          ),
        ),
      ),
    );
  }
}
