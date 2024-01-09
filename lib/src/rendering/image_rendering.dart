import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

Future<ui.Image> renderRepaintBoundary(
  RenderRepaintBoundary renderObject, {
  Size? size,
}) {
  var pixelRatio = 1.0;

  if (size != null) {
    pixelRatio = size.width / renderObject.size.width;
  }

  final image = renderObject.toImage(pixelRatio: pixelRatio);
  return image;
}

Future<List<ui.Image>> renderRepaintBoundaries(
  List<RenderRepaintBoundary> renderObjects, {
  Size? size,
}) async {
  final futures = renderObjects.map(
    (v) => renderRepaintBoundary(v, size: size),
  );

  final images = await Future.wait(futures);

  return images;
}

Future<ui.Image> composeLayeredImages(
  List<ui.Image> images, {
  required Size size,
  Decoration? backgroundDecoration,
}) {
  final width = size.width.toInt();
  final height = size.height.toInt();

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  if (backgroundDecoration != null) {
    final painter = backgroundDecoration.createBoxPainter();

    painter.paint(
      canvas,
      Offset.zero,
      ImageConfiguration(size: size),
    );

    painter.dispose();
  }

  for (final image in images) {
    canvas.drawImage(image, Offset.zero, Paint());
  }

  final picture = recorder.endRecording();
  final image = picture.toImage(width, height);

  return image;
}
