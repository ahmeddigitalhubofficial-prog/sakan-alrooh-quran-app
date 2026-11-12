import 'package:flutter/material.dart';

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
