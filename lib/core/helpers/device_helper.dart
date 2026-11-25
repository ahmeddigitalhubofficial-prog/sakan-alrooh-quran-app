import 'package:material_ui/material_ui.dart';

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
