import 'package:flutter/material.dart';

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
