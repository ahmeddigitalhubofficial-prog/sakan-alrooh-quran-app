import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;

  final Widget? tablet;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final width = MediaQuery.of(
      context,
    ).size.width;

    if (width >= 600 && tablet != null) {
      return tablet!;
    }

    return mobile;
  }
}
