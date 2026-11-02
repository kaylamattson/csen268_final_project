import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/sensor_kind.dart';
import 'app_text.dart';
import 'sensor_badge.dart';

Widget taskCard(SensorKind kind, VoidCallback onTap) => Material(
      color: C.pale,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              child: Row(children: [
                SensorBadge(kind),
                const SizedBox(width: 20),
                Expanded(child: heading(sensorName(kind), size: 21))
              ]))));
