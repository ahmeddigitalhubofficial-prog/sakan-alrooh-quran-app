import 'dart:developer';

class ErrorHandler {
  static void handle(
    dynamic error,
  ) {
    log(
      error.toString(),
      name: 'APP_ERROR',
    );
  }
}
