import 'package:flutter/material.dart';
import 'dart:math';

class CircularDashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  CircularDashedBorderPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashWidth = 5.0,
    this.dashSpace = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double radius = size.width / 2;
    double circumference = 2 * pi * radius;

    double dashCount =
        (circumference / (dashWidth + dashSpace)).floor().toDouble();
    double adjustedDashWidth = circumference / dashCount - dashSpace;

    double startAngle = 0.0;

    for (int i = 0; i < dashCount; ++i) {
      final double endAngle = startAngle + (adjustedDashWidth / radius);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
      startAngle = endAngle + (dashSpace / radius);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
