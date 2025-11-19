class WordCountUtils {
  static int countWords(String text) {
    return text.replaceAll(RegExp(r'\W+'), ' ').trim().split(' ').length;
  }

  static Duration calculateReadingTime(String text) {
    const averageWordPerMinute = 275;
    final estimatedTimeInSeconds =
        (countWords(text) / averageWordPerMinute) * 60;
    return Duration(seconds: estimatedTimeInSeconds.ceil());
  }
}
