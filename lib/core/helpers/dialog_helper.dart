import 'package:material_ui/material_ui.dart';

class DialogHelper {
  static Future show(
    BuildContext context,
    Widget child,
  ) {
    return showDialog(
      context: context,
      builder: (_) => child,
    );
  }
}
