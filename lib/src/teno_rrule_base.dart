class ParseException implements Exception {
  final String input;
  final String message;
  const ParseException(this.message, this.input);
}
