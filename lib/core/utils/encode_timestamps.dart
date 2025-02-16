String encodeTimestamp(Duration? duration) {
  if (duration == null) {
    return '00:00';
  }
  String tempSeconds = (duration.inSeconds % 60).toString();
  String tempMinutes = (duration.inMinutes).toString();
  if (tempSeconds.length < 2) {
    tempSeconds = '0$tempSeconds';
  }
  if (tempMinutes.length < 2) {
    tempMinutes = '0$tempMinutes';
  }

  return "$tempMinutes:$tempSeconds";
}
