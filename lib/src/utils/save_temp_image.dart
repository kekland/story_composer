import 'dart:io';
import 'dart:ui' as ui;

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

Future<String> createTempFilePath(String extension) async {
  final tempDirectory = await getTemporaryDirectory();

  final outputFilename = 'story-composer-${_uuid.v4()}.$extension';
  final outputPath = '${tempDirectory.path}/$outputFilename';

  return outputPath;
}

Future<File> saveTempImage(ui.Image image) async {
  final pngByteData = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );

  final filePath = await createTempFilePath('png');
  final file = File(filePath);

  await file.writeAsBytes(pngByteData!.buffer.asUint8List());
  return file;
}
