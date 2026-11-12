import 'package:flutter/foundation.dart';

class PerformanceHelper {
  static bool get isRelease => kReleaseMode;

  static bool get isDebug => kDebugMode;
}
