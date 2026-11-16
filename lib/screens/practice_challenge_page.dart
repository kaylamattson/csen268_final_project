import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:light/light.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/sensor_kind.dart';

class PracticeChallengePage extends StatefulWidget {
  final SensorKind kind;

  const PracticeChallengePage({
    super.key,
    required this.kind,
  });

  @override
  State<PracticeChallengePage> createState() => _PracticeChallengePageState();
}

class _PracticeChallengePageState extends State<PracticeChallengePage> {
  final math.Random random = math.Random();

  StreamSubscription<MagnetometerEvent>? compassSubscription;
  StreamSubscription<AccelerometerEvent>? tiltSubscription;
  StreamSubscription<int>? lightSubscription;

  double? currentReading;
  double? startingHeading;
  double? lockedReading;
  String? sensorError;

  late double target;

  bool tiltReady = false;
  bool isLocked = false;

  bool get isDirection => widget.kind == SensorKind.direction;

  bool get isTilt => widget.kind == SensorKind.tilt;

  bool get isLight => widget.kind == SensorKind.light;

  @override
  void initState() {
    super.initState();
    target = generateTarget();
    startSensor();
  }

  double generateTarget() {
    switch (widget.kind) {
      case SensorKind.direction:
        return random.nextInt(360).toDouble();

      case SensorKind.tilt:
        return (15 + random.nextInt(61)).toDouble();

      case SensorKind.light:
        return random.nextInt(40001).toDouble();
    }
  }

  String cardinalDirection(double degrees) {
    const directions = [
      'North',
      'Northeast',
      'East',
      'Southeast',
      'South',
      'Southwest',
      'West',
      'Northwest',
    ];

    final index = ((degrees + 22.5) ~/ 45) % 8;
    return directions[index];
  }

  void updateReading(double value) {
    if (!mounted || isLocked) return;

    setState(() {
      currentReading = value;

      if (isDirection) {
        startingHeading ??= value;
      }
    });
  }

  void startSensor() {
    if (isDirection) {
      compassSubscription = magnetometerEventStream().listen(
        (event) {
          final heading =
              (math.atan2(event.y, event.x) * 180 / math.pi + 360) % 360;

          updateReading(heading);
        },
        onError: handleSensorError,
      );
    } else if (isTilt) {
      tiltSubscription = accelerometerEventStream().listen(
        (event) {
          final angle = math.atan2(event.y, event.z) * 180 / math.pi;

          updateReading(angle.abs());
        },
        onError: handleSensorError,
      );
    } else {
      lightSubscription = Light().lightSensorStream.listen(
        (lux) {
          updateReading(lux.toDouble());
        },
        onError: handleSensorError,
      );
    }
  }

  void handleSensorError(Object error) {
    if (!mounted) return;

    setState(() {
      sensorError = error.toString();
    });
  }

  void confirmTiltReady() {
    if (!isTilt || currentReading == null || currentReading! > 5 || isLocked) {
      return;
    }

    setState(() {
      tiltReady = true;
    });
  }

  void lockItIn() {
    if (currentReading == null || isLocked) return;

    if (isTilt && !tiltReady) return;

    setState(() {
      lockedReading = currentReading;
      isLocked = true;
    });
  }

  double get error {
    if (lockedReading == null) return 0;

    final difference = (lockedReading! - target).abs();

    if (isDirection) {
      return math.min(difference, 360 - difference);
    }

    return difference;
  }

  void tryAgain() {
    final oldTarget = target;
    double newTarget = generateTarget();

    // Avoid generating the same target twice in a row.
    while (newTarget == oldTarget) {
      newTarget = generateTarget();
    }

    setState(() {
      target = newTarget;
      lockedReading = null;
      isLocked = false;
      tiltReady = false;

      // The next attempt starts at the current heading.
      startingHeading = isDirection ? currentReading : null;
    });
  }

  String get taskTitle {
    if (isDirection) return 'Direction Practice';
    if (isTilt) return 'Tilt Practice';
    return 'Light Practice';
  }

  String get unit => isLight ? 'lux' : '°';

  String formatValue(double value) {
    if (isLight) {
      return '${value.toStringAsFixed(0)} lux';
    }

    return '${value.toStringAsFixed(1)}°';
  }

  @override
  void dispose() {
    compassSubscription?.cancel();
    tiltSubscription?.cancel();
    lightSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool needsFlatStart = isTilt && !tiltReady;

    final bool canLock =
        currentReading != null && !isLocked && (!isTilt || tiltReady);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        title: Text(taskTitle),
        backgroundColor: const Color(0xFFFFFBF7),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'PRACTICE MODE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                needsFlatStart
                    ? 'Set Your Starting Position'
                    : 'Match the Target!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                needsFlatStart
                    ? 'Place your phone flat, screen facing up.'
                    : 'Make your best guess without seeing '
                        'your live sensor reading.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: isDirection
                      ? const Color(0xFF8B70A3)
                      : isTilt
                          ? const Color(0xFFFFD6DF)
                          : const Color(0xFFE5F2BB),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Icon(
                      isDirection
                          ? Icons.explore_outlined
                          : isTilt
                              ? Icons.screen_rotation_outlined
                              : Icons.light_mode_outlined,
                      size: 65,
                      color: isDirection ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(height: 24),
                    if (isDirection && startingHeading != null) ...[
                      Text(
                        'STARTING DIRECTION',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDirection ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatValue(startingHeading!),
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        cardinalDirection(startingHeading!),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                    if (needsFlatStart) ...[
                      const Text(
                        'START AT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '0° — Flat',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        currentReading != null && currentReading! <= 5
                            ? 'Phone is flat! You are ready.'
                            : 'Adjust your phone until it is flat.',
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      Text(
                        'YOUR TARGET',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDirection ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${target.toStringAsFixed(0)}$unit',
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: isDirection ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (isDirection)
                        Text(
                          cardinalDirection(target),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      if (isTilt)
                        const Text(
                          'Lift the top edge of your phone.',
                          textAlign: TextAlign.center,
                        ),
                      if (isLight)
                        const Text(
                          'Adjust the light reaching the sensor.',
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 25),
              if (sensorError != null)
                Text(
                  'Sensor error: $sensorError',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              if (currentReading == null && sensorError == null)
                const Text(
                  'Waiting for sensor...',
                  textAlign: TextAlign.center,
                ),
              if (!isLocked && needsFlatStart) ...[
                ElevatedButton(
                  onPressed: currentReading != null && currentReading! <= 5
                      ? confirmTiltReady
                      : null,
                  child: const Text("I'm Ready"),
                ),
              ] else if (!isLocked) ...[
                const Text(
                  'Your live measurement is hidden.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: canLock ? lockItIn : null,
                  child: const Text('Lock It In'),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'YOUR RESULT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        formatValue(lockedReading!),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${formatValue(error)} off target',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: tryAgain,
                  child: const Text(
                    'Try Again — New Target',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
