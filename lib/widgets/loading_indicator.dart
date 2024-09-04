import 'dart:math';
import 'package:flutter/material.dart';

class CircularLoadingIndicator extends StatefulWidget {
  @override
  _CircularLoadingIndicatorState createState() =>
      _CircularLoadingIndicatorState();
}

class _CircularLoadingIndicatorState extends State<CircularLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CircularDotsPainter(progress: _controller),
      size: const Size(100, 100),
    );
  }
}

class CircularDotsPainter extends CustomPainter {
  final Animation<double> progress;
  final List<Color> colors = [
    Colors.purple.shade500,
    const Color.fromARGB(255, 193, 22, 199),
    Colors.purple.shade400,
    const Color.fromARGB(255, 126, 68, 173),
    const Color.fromARGB(255, 118, 21, 156),
    Colors.blue.shade300,
    Colors.blue.shade400,
    Colors.blue.shade500,
  ];

  final List<double> sizes = [
    22.0,
    20.0,
    18.0,
    16.0,
    14.0,
    12.0,
    10.0,
    8.0,
  ];

  CircularDotsPainter({required this.progress}) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final double angle = progress.value * 2 * pi;
    final double baseRadius = size.width / 2.5;

    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i % colors.length];
      double adjustedRadius =
          baseRadius + (sizes[i] - 8.0) / 2; // Adjust radius based on dot size

      final double x = (size.width / 2) +
          adjustedRadius * cos(angle + (i * 2 * pi / colors.length));
      final double y = (size.height / 2) +
          adjustedRadius * sin(angle + (i * 2 * pi / colors.length));

      canvas.drawCircle(
        Offset(x, y),
        sizes[i] / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
