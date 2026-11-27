import 'package:flutter/material.dart';

/// ويدجت ذكي للنصوص الطويلة يقوم بالتمرير التلقائي (Marquee / AutoScroll)
/// عند تجاوز طول النص المساحة المتاحة، مع تأثير التلاشي التدريجي للحواف (Edge Fading).
/// في حال كان النص مناسباً للمساحة، يعرضه كـ Text عادي بدون أي استهلاك للمعالج.
class AutoScrollText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Duration pauseDuration;
  final double velocity; // بيكسل في الثانية
  final double fadeWidth;
  final Curve curve;

  const AutoScrollText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.pauseDuration = const Duration(milliseconds: 1400),
    this.velocity = 32.0,
    this.fadeWidth = 16.0,
    this.curve = Curves.easeInOut,
  });

  @override
  State<AutoScrollText> createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  AnimationController? _animationController;
  Animation<double>? _animation;
  bool _isOverflowing = false;
  double _maxScrollExtent = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(covariant AutoScrollText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _stopAnimation();
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _checkOverflow() {
    if (!mounted || !_scrollController.hasClients) return;

    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent > 0) {
      if (!_isOverflowing || _maxScrollExtent != maxExtent) {
        setState(() {
          _isOverflowing = true;
          _maxScrollExtent = maxExtent;
        });
        _startAnimation();
      }
    } else {
      if (_isOverflowing) {
        _stopAnimation();
        setState(() {
          _isOverflowing = false;
          _maxScrollExtent = 0.0;
        });
      }
    }
  }

  void _stopAnimation() {
    _animationController?.stop();
    _animationController?.reset();
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
  }

  void _startAnimation() {
    if (!mounted || _maxScrollExtent <= 0) return;

    final scrollDurationMs = ((_maxScrollExtent / widget.velocity) * 1000).toInt();
    final totalDuration = Duration(milliseconds: scrollDurationMs) + widget.pauseDuration;

    _animationController?.duration = totalDuration;

    _animation = Tween<double>(begin: 0.0, end: _maxScrollExtent).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Interval(
          widget.pauseDuration.inMilliseconds / totalDuration.inMilliseconds,
          1.0,
          curve: widget.curve,
        ),
      ),
    )..addListener(() {
        if (_scrollController.hasClients && _isOverflowing) {
          _scrollController.jumpTo(_animation!.value);
        }
      });

    _animationController?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(widget.pauseDuration, () {
          if (mounted && _isOverflowing) {
            _animationController?.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed) {
        Future.delayed(widget.pauseDuration, () {
          if (mounted && _isOverflowing) {
            _animationController?.forward();
          }
        });
      }
    });

    _animationController?.forward();
  }

  @override
  Widget build(BuildContext context) {
    final directionality = widget.textDirection ?? Directionality.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());

        Widget content = SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Text(
            widget.text,
            style: widget.style,
            textAlign: widget.textAlign,
            textDirection: directionality,
            maxLines: 1,
            softWrap: false,
          ),
        );

        if (_isOverflowing && widget.fadeWidth > 0) {
          content = ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                  Colors.transparent,
                ],
                stops: [
                  0.0,
                  widget.fadeWidth / bounds.width,
                  1.0 - (widget.fadeWidth / bounds.width),
                  1.0,
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: content,
          );
        }

        return content;
      },
    );
  }
}
