import 'package:flutter/material.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;

  const AnimatedCard({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _pressed = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(
          milliseconds: 120,
        ),
        child: widget.child,
      ),
    );
  }
}
