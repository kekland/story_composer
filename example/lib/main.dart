import 'package:flutter/material.dart';
import 'package:story_composer/story_composer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story Composer',
      showPerformanceOverlay: false,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const StoryComposerPage(),
    );
  }
}

class StoryComposerPage extends StatefulWidget {
  const StoryComposerPage({super.key});

  @override
  State<StoryComposerPage> createState() => _StoryComposerPageState();
}

class _StoryComposerPageState extends State<StoryComposerPage> {
  late final List<Widget> _children;

  @override
  void initState() {
    super.initState();

    _children = [
      StoryPrimaryWidget(
        key: const Key('primary'),
        child: SizedBox(
          width: 1080.0,
          height: 1920.0,
          child: Image.network(
            'https://test-photos-qklwjen.s3.eu-west-3.amazonaws.com/image11.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
      StoryOverlayWidget(
        key: const Key('red'),
        child: Container(
          width: 250.0,
          height: 250.0,
          color: Colors.red,
        ),
      ),
      // StoryOverlayWidget(
      //   key: const Key('text'),
      //   child: PreferredSize(
      //     preferredSize: Size.zero,
      //     child: Container(
      //       padding: const EdgeInsets.symmetric(
      //         horizontal: 16.0,
      //         vertical: 8.0,
      //       ),
      //       decoration: BoxDecoration(
      //         color: Colors.white,
      //         borderRadius: BorderRadius.circular(8.0),
      //       ),
      //       child: const Text(
      //         'Hello, world!',
      //         style: TextStyle(
      //           fontSize: 80.0,
      //           color: Colors.black,
      //           fontWeight: FontWeight.w600,
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Composer'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.save,
            ),
          ),
        ],
      ),
      body: StoryComposerCanvas(
        size: const Size(1080, 1920),
        trashAreaWidget: const StoryTrashAreaWidget(),
        onWidgetRemoved: (key) {
          _children.removeWhere((element) => element.key == key);
          setState(() {});
        },
        children: _children,
      ),
    );
  }
}
