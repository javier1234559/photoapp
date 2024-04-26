class Format {
  static String formatSeconds(String seconds) {
    int secondsInt = int.parse(seconds);
    int minutes = secondsInt ~/ 60;
    int remainingSeconds = secondsInt % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }
}
