import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum SensorKind { direction, tilt, light }

Color sensorColor(SensorKind kind) => switch (kind) {
      SensorKind.direction => C.purple,
      SensorKind.tilt => C.pink,
      SensorKind.light => C.lime
    };
IconData sensorIcon(SensorKind kind) => switch (kind) {
      SensorKind.direction => Icons.navigation_outlined,
      SensorKind.tilt => Icons.screen_rotation_outlined,
      SensorKind.light => Icons.wb_sunny_outlined
    };
String sensorName(SensorKind kind) => switch (kind) {
      SensorKind.direction => 'Direction Task',
      SensorKind.tilt => 'Tilt Task',
      SensorKind.light => 'Light Task'
    };
