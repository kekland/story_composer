import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;

import 'package:story_composer/src/model/story_primary_content.dart';
import 'package:story_composer/src/utils/ffmpeg.dart';
import 'package:story_composer/src/utils/quaternion.dart';
import 'package:story_composer/src/utils/save_temp_image.dart';
import 'package:vector_math/vector_math_64.dart';

Future<ui.Image> renderBackground(Decoration decoration, Size size) async {
  final width = size.width.toInt();
  final height = size.height.toInt();

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final painter = decoration.createBoxPainter();

  painter.paint(
    canvas,
    Offset.zero,
    ImageConfiguration(size: size),
  );

  painter.dispose();

  final picture = recorder.endRecording();
  final image = picture.toImage(width, height);

  return image;
}

Future<(File, File)> renderVideo({
  required Size canvasSize,
  required Size viewportSize,
  required Size primaryContentSize,
  required VideoStoryPrimaryContent primaryContent,
  required Matrix4 primaryContentTransformation,
  required ui.Image backgroundImage,
  required ui.Image overlayImage,
}) async {
  final primaryContentRect = Rect.fromLTRB(
    0.0,
    0.0,
    primaryContentSize.width,
    primaryContentSize.height,
  );

  final transformedPrimaryContentRect = MatrixUtils.transformRect(
    primaryContentTransformation,
    primaryContentRect,
  );

  final rotation =
      Quaternion.fromRotation(primaryContentTransformation.getRotation())
          .eulerAngles
          .yaw;

  final scale = canvasSize.width / viewportSize.width;

  final aabbWidth = transformedPrimaryContentRect.width;
  final aabbHeight = transformedPrimaryContentRect.height;

  final outputAabbWidth = aabbWidth * scale;
  final outputAabbHeight = aabbHeight * scale;

  final outputRectSize = _getInnerRectangleSizeFromAabb(
    transformedPrimaryContentRect.size,
    rotation,
  );

  final outputRectWidth = outputRectSize.width * scale;
  final outputRectHeight = outputRectSize.height * scale;

  final backgroundFile = await saveTempImage(backgroundImage);
  final overlayFile = await saveTempImage(overlayImage);

  final outputFilePath = await createTempFilePath('mp4');

  final canvasWidth = canvasSize.width.toInt();
  final canvasHeight = canvasSize.height.toInt();

  final primaryVideoWidth = outputRectWidth.toInt();
  final primaryVideoHeight = outputRectHeight.toInt();

  final primaryVideoAabbWidth = outputAabbWidth.toInt();
  final primaryVideoAabbHeight = outputAabbHeight.toInt();

  final primaryVideoAabbLeft =
      (transformedPrimaryContentRect.left * scale).toInt();
  final primaryVideoAabbTop =
      (transformedPrimaryContentRect.top * scale).toInt();

  final inputs = [
    '-i',
    FfUtils.formatPath(backgroundFile.path),
    '-i',
    FfUtils.formatPath(primaryContent.videoFile.path),
    '-i',
    FfUtils.formatPath(overlayFile.path),
  ];

  final filterGraph = [
    '[0:v]scale=$canvasWidth:$canvasHeight[output_a]',
    '[1:v]scale=$primaryVideoWidth:$primaryVideoHeight[primary_a]',
    '[primary_a]rotate=$rotation:ow=$primaryVideoAabbWidth:oh=$primaryVideoAabbHeight:fillcolor=none[primary_b]',
    '[output_a][primary_b]overlay=$primaryVideoAabbLeft:$primaryVideoAabbTop[output_b]',
    '[output_b][2:v]overlay=0:0',
  ];

  final output = [
    FfUtils.formatPath(outputFilePath),
  ];

  await FfUtils.ffmpegExecute(
    [
      ...inputs,
      '-filter_complex',
      filterGraph.join(';'),
      ...output,
    ],
  );

  final outputFile = File(outputFilePath);
  final thumbnailFile = await FfUtils.getSnapshotFileAtTimestamp(
    outputFile,
    Duration.zero,
  );

  return (outputFile, thumbnailFile);
}

Size _getInnerRectangleSizeFromAabb(Size aabb, double rotation) {
  final c = cos(rotation).abs();
  final s = sin(rotation).abs();

  final a = aabb.width;
  final b = aabb.height;

  final den = (c - (s * s) / c);

  final _b = (b - (s / c) * a) / den;
  final _a = (a - (s / c) * b) / den;

  return Size(_a, _b);
}
