import 'dart:io';

import 'package:example/camera_page/camera_page.dart';
import 'package:example/instagram/instagram_story_composer_page.dart';
import 'package:example/main_page/story_circle.dart';
import 'package:example/main_page/story_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter_simulator/flutter_simulator.dart';
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
      scrollBehavior: const _CustomScrollBehavior(),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _stories = <StoryData>[];

  Future<void> _onCreate() async {
    final dynamic primaryContent;

    if (Platform.isAndroid || Platform.isIOS) {
      primaryContent = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CameraPage(),
        ),
      );
    } else {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.media,
      );

      if (result == null) return;

      final resultFile = result.files.single;
      final file = File(resultFile.path!);

      if (acceptedVideoFormats.contains(resultFile.extension!)) {
        primaryContent = VideoStoryPrimaryContent(file);
      } else {
        primaryContent = ImageStoryPrimaryContent(FileImage(file));
      }

      if (mounted && primaryContent is StoryPrimaryContent) {
        await primaryContent.precache(context);
      }
    }

    if (primaryContent is! StoryPrimaryContent) {
      return;
    }

    if (!mounted) return;

    final story = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InstagramStoryComposerPage(
          primaryContent: primaryContent,
        ),
      ),
    );

    if (!mounted) return;

    if (story is StoryData) {
      await story.precache(context);
      setState(() {
        _stories.add(story);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Composer Demo'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 96.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                StoryCircle(
                  hasBorder: false,
                  onTap: _onCreate,
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.black,
                  ),
                ),
                ..._stories.map(
                  (story) => StoryCircle(
                    hasBorder: true,
                    backgroundColor: Colors.transparent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => StoryPage(
                            story: story,
                            heroId: story.hashCode.toString(),
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: story.hashCode.toString(),
                      child: Image(
                        image: story.thumbnail,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ].intersperse(const SizedBox(width: 16.0)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomScrollBehavior extends ScrollBehavior {
  const _CustomScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.unknown,
        PointerDeviceKind.trackpad,
      };
}
