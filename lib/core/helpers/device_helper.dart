import 'package:flutter/material.dart';

class DeviceHelper {
  static bool isTablet(
    BuildContext context,
  ) {
    return MediaQuery.of(
          context,
        ).size.width >
        600;
  }

  static bool isMobile(
    BuildContext context,
  ) {
    return MediaQuery.of(
          context,
        ).size.width <=
        600;
  }
}
