import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/sensor_kind.dart';

class SensorPainter extends CustomPainter {
  final SensorKind kind;
  SensorPainter(this.kind);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .43);
    final radius = math.min(size.width * .42, size.height * .34);
    if (kind == SensorKind.direction) {
      final p = Paint()
        ..color = C.pale
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5;
      canvas.drawCircle(center, radius, p);
      for (final (s, pos) in [
        ('N', Offset(0, -.79)),
        ('S', Offset(0, .79)),
        ('W', Offset(-.8, 0)),
        ('E', Offset(.8, 0))
      ]) {
        drawText(canvas, s, center + Offset(pos.dx * radius, pos.dy * radius),
            23, Colors.white);
      }
      final nav = Path()
        ..moveTo(center.dx - 9, center.dy + 4)
        ..lineTo(center.dx - 3, center.dy - 45)
        ..lineTo(center.dx + 22, center.dy - 10)
        ..lineTo(center.dx + 3, center.dy - 15)
        ..close();
      canvas.drawPath(
          nav,
          Paint()
            ..color = C.pale
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5);
      drawText(canvas, '15°', center + const Offset(0, 40), 28, Colors.white);
      drawText(canvas, 'from target', center + const Offset(0, 70), 14,
          Colors.white);
    } else if (kind == SensorKind.tilt) {
      final p = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      final origin = Offset(size.width * .23, size.height * .55);
      drawDashed(canvas, origin, Offset(size.width * .79, origin.dy), p);
      drawDashed(
          canvas, origin, Offset(size.width * .65, size.height * .17), p);
    } else {
      final p = Paint()
        ..color = C.darkTeal
        ..strokeWidth = 18
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius * .7), -.2,
          math.pi * 1.65, false, p);
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * .7),
          -math.pi / 2,
          .75,
          false,
          Paint()
            ..color = C.teal
            ..strokeWidth = 18
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round);
      final sun = Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, 13, sun);
      for (var i = 0; i < 8; i++) {
        final a = i * math.pi / 4;
        canvas.drawLine(center + Offset(math.cos(a) * 23, math.sin(a) * 23),
            center + Offset(math.cos(a) * 31, math.sin(a) * 31), sun);
      }
    }
  }

  void drawText(
      Canvas canvas, String text, Offset center, double size, Color color) {
    final painter = TextPainter(
        text: TextSpan(
            text: text,
            style: TextStyle(
                color: color, fontSize: size, fontWeight: FontWeight.w700)),
        textDirection: TextDirection.ltr)
      ..layout();
    painter.paint(
        canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  void drawDashed(Canvas c, Offset a, Offset b, Paint p) {
    final delta = b - a;
    final length = delta.distance;
    final unit = delta / length;
    for (double x = 0; x < length; x += 18) {
      c.drawLine(a + unit * x, a + unit * math.min(x + 9, length), p);
    }
  }

  @override
  bool shouldRepaint(covariant SensorPainter old) => old.kind != kind;
}
