Duration durationFromSeconds(double seconds) {
  return Duration(
    microseconds: (seconds * Duration.microsecondsPerSecond).toInt(),
  );
}

String durationToTimestamp(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final milliseconds = duration.inMilliseconds.remainder(1000).toString();

  return '$hours:$minutes:$seconds.$milliseconds';
}
