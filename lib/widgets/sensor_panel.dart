import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/sensor_kind.dart';
import '../widgets/app_text.dart';
import 'sensor_painter.dart';

class SensorPanel extends StatelessWidget {
  final SensorKind kind;
  final bool practice;
  const SensorPanel({super.key, required this.kind, this.practice = false});
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: switch (kind) {
            SensorKind.direction => C.purpleDark,
            SensorKind.tilt => C.rose,
            SensorKind.light => C.olive
          },
          borderRadius: BorderRadius.circular(24)),
      child: Padding(
          padding: const EdgeInsets.all(14),
          child: CustomPaint(
              painter: SensorPainter(kind),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                if (kind != SensorKind.direction) ...[
                  heading(kind == SensorKind.tilt ? '42°' : '12%',
                      size: 29, color: Colors.white),
                  labelText(
                      kind == SensorKind.tilt
                          ? 'Target: 45°'
                          : (practice
                              ? 'Ambient\nLight Level'
                              : 'Target: < 5%'),
                      size: 20,
                      color: Colors.white,
                      weight: FontWeight.w800,
                      align: TextAlign.center),
                  const SizedBox(height: 20),
                ]
              ]))));
}
