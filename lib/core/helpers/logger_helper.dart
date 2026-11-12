import 'dart:developer';

class LoggerHelper {
  static void logInfo(
    String message,
  ) {
    log(
      message,
      name: 'INFO',
    );
  }

  static void logError(
    String message,
  ) {
    log(
      message,
      name: 'ERROR',
    );
  }
}
