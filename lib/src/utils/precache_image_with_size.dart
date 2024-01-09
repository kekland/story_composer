import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Prefetches an image into the image cache.
///
/// Returns a [Future] that will complete when the first image yielded by the
/// [ImageProvider] is available or failed to load.
///
/// If the image is later used by an [Image] or [BoxDecoration] or [FadeInImage],
/// it will probably be loaded faster. The consumer of the image does not need
/// to use the same [ImageProvider] instance. The [ImageCache] will find the image
/// as long as both images share the same key, and the image is held by the
/// cache.
///
/// The cache may refuse to hold the image if it is disabled, the image is too
/// large, or some other criteria implemented by a custom [ImageCache]
/// implementation.
///
/// The [ImageCache] holds a reference to all images passed to
/// [ImageCache.putIfAbsent] as long as their [ImageStreamCompleter] has at
/// least one listener. This method will wait until the end of the frame after
/// its future completes before releasing its own listener. This gives callers a
/// chance to listen to the stream if necessary. A caller can determine if the
/// image ended up in the cache by calling [ImageProvider.obtainCacheStatus]. If
/// it is only held as [ImageCacheStatus.live], and the caller wishes to keep
/// the resolved image in memory, the caller should immediately call
/// `provider.resolve` and add a listener to the returned [ImageStream]. The
/// image will remain pinned in memory at least until the caller removes its
/// listener from the stream, even if it would not otherwise fit into the cache.
///
/// Callers should be cautious about pinning large images or a large number of
/// images in memory, as this can result in running out of memory and being
/// killed by the operating system. The lower the available physical memory, the
/// more susceptible callers will be to running into OOM issues. These issues
/// manifest as immediate process death, sometimes with no other error messages.
///
/// The [BuildContext] and [Size] are used to select an image configuration
/// (see [createLocalImageConfiguration]).
///
/// The returned future will not complete with error, even if precaching
/// failed. The `onError` argument can be used to manually handle errors while
/// pre-caching.
///
/// See also:
///
///  * [ImageCache], which holds images that may be reused.
Future<Size?> precacheImageWithSize(
  ImageProvider provider,
  BuildContext context, {
  Size? size,
  ImageErrorListener? onError,
}) {
  final ImageConfiguration config =
      createLocalImageConfiguration(context, size: size);
  final Completer<Size?> completer = Completer<Size?>();
  final ImageStream stream = provider.resolve(config);
  ImageStreamListener? listener;
  listener = ImageStreamListener(
    (ImageInfo? image, bool sync) {
      if (!completer.isCompleted) {
        final uiImage = image?.image;

        completer.complete(
          uiImage != null
              ? Size(
                  uiImage.width.toDouble(),
                  uiImage.height.toDouble(),
                )
              : null,
        );
      }
      // Give callers until at least the end of the frame to subscribe to the
      // image stream.
      // See ImageCache._liveImages
      SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
        stream.removeListener(listener!);
      });
    },
    onError: (Object exception, StackTrace? stackTrace) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      stream.removeListener(listener!);
      if (onError != null) {
        onError(exception, stackTrace);
      } else {
        FlutterError.reportError(FlutterErrorDetails(
          context: ErrorDescription('image failed to precache'),
          library: 'image resource service',
          exception: exception,
          stack: stackTrace,
          silent: true,
        ));
      }
    },
  );
  stream.addListener(listener);
  return completer.future;
}
