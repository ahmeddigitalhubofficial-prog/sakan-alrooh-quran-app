import 'dart:ui';

import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;

  final EdgeInsetsGeometry? padding;

  final double borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        borderRadius,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Container(
          padding: padding ??
              const EdgeInsets.all(
                18,
              ),
          decoration: BoxDecoration(
            color: Colors.white.withValue(
              0.05,
            ),
            borderRadius: BorderRadius.circular(
              borderRadius,
            ),
            border: Border.all(
              color: Colors.white.withValue(
                0.08,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

extension on Color {
  Color withValue(double value) {
    return withAlpha((255 * value).toInt());
  }
}
