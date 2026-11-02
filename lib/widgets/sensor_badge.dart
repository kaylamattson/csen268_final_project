import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/sensor_kind.dart';

class SensorBadge extends StatelessWidget {
  final SensorKind kind;
  final double size;
  const SensorBadge(this.kind, {super.key, this.size = 44});
  @override
  Widget build(BuildContext context) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: sensorColor(kind),
          borderRadius: BorderRadius.circular(size * .21)),
      child: Icon(sensorIcon(kind), color: C.ink, size: size * .65));
}
