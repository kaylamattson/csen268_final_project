import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/sensor_kind.dart';
import '../widgets/app_text.dart';
import 'sensor_painter.dart';

class SensorPanel extends StatelessWidget {
  final SensorKind kind;
  final bool practice;
  final double? headingDegrees;
  final double? tiltAngle;
  final int? lux;
  final String? errorText;

  const SensorPanel({
    super.key,
    required this.kind,
    this.practice = false,
    this.headingDegrees,
    this.tiltAngle,
    this.lux,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: switch (kind) {
            SensorKind.direction => C.purpleDark,
            SensorKind.tilt => C.rose,
            SensorKind.light => C.olive,
          },
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: CustomPaint(
            painter: SensorPainter(kind, heading: headingDegrees),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (kind != SensorKind.direction) ...[
                  headingText(),
                  labelText(
                    kind == SensorKind.tilt
                        ? 'Target: 45°'
                        : (practice ? 'Ambient\nLight Level' : 'Ambient light (lux)'),
                    size: 20,
                    color: Colors.white,
                    weight: FontWeight.w800,
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
                if (errorText != null)
                  labelText(errorText!, color: Colors.white, align: TextAlign.center),
              ],
            ),
          ),
        ),
      );

  Widget headingText() => heading(
        kind == SensorKind.tilt
            ? (tiltAngle == null ? '—°' : '${tiltAngle!.toStringAsFixed(1)}°')
            : (lux == null ? '— lx' : '$lux lx'),
        size: 29,
        color: Colors.white,
      );
}
