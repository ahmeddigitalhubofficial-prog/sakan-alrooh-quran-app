import 'package:material_ui/material_ui.dart';

class NavigationHelper {
  static Future push(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  static Future replace(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  static void pop(
    BuildContext context,
  ) {
    Navigator.pop(context);
  }
}
