import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  final Widget child;

  const CustomBottomSheet({
    super.key,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            24,
          ),
        ),
      ),
      child: child,
    );
  }
}
