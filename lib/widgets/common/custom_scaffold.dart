import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;

  final PreferredSizeWidget? appBar;

  final Widget? floatingActionButton;

  const CustomScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
