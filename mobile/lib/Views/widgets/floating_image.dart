import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingImage extends StatefulWidget {
  final String imagePath;
  final double width;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  const FloatingImage({
    Key? key,
    required this.imagePath,
    required this.width,
    this.top,
    this.left,
    this.right,
    this.bottom,
  }) : super(key: key);

  @override
  _FloatingImageState createState() => _FloatingImageState();
}

class _FloatingImageState extends State<FloatingImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: widget.left,
      right: widget.right,
      bottom: widget.bottom,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          double offset = math.sin(_controller.value * 2 * math.pi) * 6;
          return Transform.translate(
            offset: Offset(2, offset),
            child: Image.asset(widget.imagePath, width: widget.width),
          );
        },
      ),
    );
  }
}
