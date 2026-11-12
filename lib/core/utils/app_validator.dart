class AppValidator {
  static bool isEmpty(
    String? text,
  ) {
    return text == null || text.trim().isEmpty;
  }
}
