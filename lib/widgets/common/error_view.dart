import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String text;

  const ErrorView({
    super.key,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.red,
        ),
      ),
    );
  }
}
