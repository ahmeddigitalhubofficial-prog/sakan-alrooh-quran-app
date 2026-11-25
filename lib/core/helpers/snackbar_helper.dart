import 'package:material_ui/material_ui.dart';

class SnackbarHelper {
  static void show(
    BuildContext context,
    String text,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}
