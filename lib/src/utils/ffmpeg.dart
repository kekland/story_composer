import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/media_information.dart';
import 'package:flutter/widgets.dart';
import 'package:story_composer/src/utils/duration.dart';
import 'package:story_composer/src/utils/save_temp_image.dart';

class FfUtils {
  static bool get isFfmpegKitSupported => Platform.isAndroid || Platform.isIOS;

  /// Replaces all:
  /// - `\` with `\\`
  /// - `'` with `\'`
  static String formatPath(String path) {
    return path.replaceAll('\\', '\\\\').replaceAll('\'', '\\\'');
  }

  static Future<void> ffmpegExecute(List<String> command) async {
    final exitCodeCompleter = Completer<int>();

    if (isFfmpegKitSupported) {
      await FFmpegKit.executeAsync(
        command.join(' '),
        (s) async {
          exitCodeCompleter.complete((await s.getReturnCode())!.getValue());
        },
      );
    } else {
      print('ffmpeg ${command.join(' ')}');
      final process = await Process.start(
        'ffmpeg',
        command,
      );

      stdout.addStream(process.stdout);
      stderr.addStream(process.stderr);

      exitCodeCompleter.complete(process.exitCode);
    }

    final exitCode = await exitCodeCompleter.future;

    if (exitCode != 0) {
      throw Exception('ffmpeg exited with code $exitCode');
    }
  }

  static Future<File> getSnapshotFileAtTimestamp(
    File file,
    Duration duration,
  ) async {
    final outputPath = await createTempFilePath('jpg');
    final timestamp = durationToTimestamp(duration);

    final command = [
      '-noaccurate_seek',
      '-ss',
      timestamp,
      '-i',
      formatPath(file.path),
      '-frames:v',
      '1',
      formatPath(outputPath),
    ];

    await ffmpegExecute(command);

    return File(outputPath);
  }

  static Future<ui.Image> getSnapshotAtTimestamp(
    File file,
    Duration duration,
  ) async {
    final outputFile = await getSnapshotFileAtTimestamp(file, duration);
    final bytes = await outputFile.readAsBytes();
    final image = await decodeImageFromList(bytes);

    outputFile.delete();
    return image;
  }

  static Future<MediaInformation> getMediaInformation(
    File file,
  ) async {
    if (isFfmpegKitSupported) {
      final session = await FFprobeKit.getMediaInformation(file.path);
      return session.getMediaInformation()!;
    } else {
      final result = await Process.run(
        'ffprobe',
        [
          '-v',
          'error',
          '-hide_banner',
          '-print_format',
          'json',
          '-show_format',
          '-show_streams',
          '-show_chapters',
          '-i',
          formatPath(file.path),
        ],
      );

      final json = jsonDecode(result.stdout);
      return MediaInformation(json);
    }
  }

  static Future<(Size, Duration)> getVideoData(File file) async {
    final information = await getMediaInformation(file);
    final streams = information.getStreams();

    final videoStream = streams.firstWhere((v) => v.getWidth() != null);

    final width = videoStream.getWidth()!;
    final height = videoStream.getHeight()!;

    final sideDataList = videoStream.getProperty('side_data_list') as List?;
    final displayMatrix =
        sideDataList?.where((v) => v['displaymatrix'] != null).firstOrNull;

    var rotation = displayMatrix?['rotation'];

    if (rotation != null) {
      print(rotation);
    }

    final duration = durationFromSeconds(
      double.parse(information.getDuration()!),
    );

    var size = Size(width.toDouble(), height.toDouble());

    if (rotation != null) {
      if (rotation < 0) {
        rotation = 360 + rotation;
      }

      if (rotation == 0 || rotation == 180) {
        size = Size(width.toDouble(), height.toDouble());
      }

      if (rotation == 90 || rotation == 270) {
        size = Size(height.toDouble(), width.toDouble());
      }
    }

    return (size, duration);
  }
}
