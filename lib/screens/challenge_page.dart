import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:light/light.dart';

import '../theme/app_colors.dart';
import '../models/sensor_kind.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text.dart';
import '../widgets/pill_button.dart';
import '../widgets/sensor_badge.dart';
import '../widgets/sensor_panel.dart';
import 'completion_page.dart';
import 'package:intl/intl.dart';

class ChallengePage extends StatefulWidget {
  final int initialTask;

  const ChallengePage({super.key, this.initialTask = 0});

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  late int current = widget.initialTask;

  // Direction Challenge
  static const double targetDirection = 120.0;

  double? currentHeading;
  double? startingHeading;
  double? lockedHeading;
  bool directionLocked = false;
  final Stopwatch _challengeStopwatch = Stopwatch();

  StreamSubscription<MagnetometerEvent>? magnetometerSubscription;

  // Tilt Challenge
  static const double targetTilt = 45.0;

  double? currentTilt;
  double? lockedTilt;
  bool tiltLocked = false;
  bool tiltReady = false;

  StreamSubscription<AccelerometerEvent>? accelerometerSubscription;

  // Light Challenge
  static const int targetLight = 500;

  int? currentLight;
  int? lockedLight;
  bool lightLocked = false;
  String? lightSensorError;

  StreamSubscription<int>? lightSubscription;

  String getCardinalDirection(double degrees) {
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

  @override
  void initState() {
    super.initState();
    _challengeStopwatch.start();

    if (current == 0) {
      startDirectionSensor();
    } else if (current == 1) {
      startTiltSensor();
    } else if (current == 2) {
      startLightSensor();
    }
  }

  void startDirectionSensor() {
    magnetometerSubscription = magnetometerEventStream().listen((event) {
      double heading = math.atan2(event.y, event.x) * (180 / math.pi);

      heading = (heading + 360) % 360;

      if (!mounted) return;

      setState(() {
        currentHeading = heading;
        startingHeading ??= heading;
      });
    });
  }

  void lockDirection() {
    if (currentHeading == null || directionLocked) return;

    setState(() {
      lockedHeading = currentHeading;
      directionLocked = true;
    });
  }

  double get directionError {
    if (lockedHeading == null) return 0;

    final difference = (lockedHeading! - targetDirection).abs();

    return math.min(difference, 360 - difference);
  }

Future<void> _saveResultsToFirestore() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  _challengeStopwatch.stop(); // Stop timing the session
  final int elapsedSeconds = _challengeStopwatch.elapsed.inSeconds;

  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('results')
        .add({
      'challengeDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'directionError': directionError,
      'tiltError': tiltError,
      'totalDurationSeconds': elapsedSeconds, // Now safe to include!
      'completedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('Challenge metrics successfully saved to Firestore!');
  } catch (e) {
    debugPrint('Error saving challenge results: $e');
  }
}

  void nextTask() async {
    // Require a locked answer before advancing.
    if (current == 0 && !directionLocked) return;
    if (current == 1 && !tiltLocked) return;
    if (current == 2 && !lightLocked) return;

    if (current < 2) {
      final previousTask = current;

      setState(() {
        current++;
      });

      // Direction -> Tilt
      if (previousTask == 0) {
        magnetometerSubscription?.cancel();
        magnetometerSubscription = null;

        startTiltSensor();
      }

      // Tilt -> Light
      if (previousTask == 1) {
        accelerometerSubscription?.cancel();
        accelerometerSubscription = null;

        startLightSensor();
      }
    } else {
      // Save results to Firestore right before finishing the final task
      await _saveResultsToFirestore();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CompletionPage(),
        ),
      );
    }
  }

  void startTiltSensor() {
    accelerometerSubscription = accelerometerEventStream().listen((event) {
      final tiltRadians = math.atan2(
        event.y,
        event.z,
      );

      final tiltDegrees = (tiltRadians * 180 / math.pi).abs();

      if (!mounted || tiltLocked) return;

      setState(() {
        currentTilt = tiltDegrees;
      });
    });
  }

  void lockTilt() {
    if (!tiltReady || currentTilt == null || tiltLocked) {
      return;
    }

    setState(() {
      lockedTilt = currentTilt;
      tiltLocked = true;
    });

    accelerometerSubscription?.cancel();
    accelerometerSubscription = null;
  }

  void confirmTiltReady() {
    if (currentTilt == null || currentTilt! > 5.0) {
      return;
    }

    setState(() {
      tiltReady = true;
    });
  }

  double get tiltError {
    if (lockedTilt == null) return 0;

    return (lockedTilt! - targetTilt).abs();
  }

  void startLightSensor() {
    lightSubscription?.cancel();

    lightSubscription = Light().lightSensorStream.listen(
      (lux) {
        if (!mounted || lightLocked) return;

        setState(() {
          currentLight = lux;
          lightSensorError = null;
        });
      },
      onError: (Object error) {
        if (!mounted) return;

        setState(() {
          lightSensorError = 'Light sensor unavailable: $error';
        });
      },
    );
  }

  void lockLight() {
    if (currentLight == null || lightLocked) return;

    setState(() {
      lockedLight = currentLight;
      lightLocked = true;
    });

    lightSubscription?.cancel();
    lightSubscription = null;
  }

  int get lightError {
    if (lockedLight == null) return 0;

    return (lockedLight! - targetLight).abs();
  }

  @override
  void dispose() {
    magnetometerSubscription?.cancel();
    accelerometerSubscription?.cancel();
    lightSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kind = SensorKind.values[current];

    return Base(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
        child: Column(
          children: [
            // Top navigation
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: C.ink,
                    size: 28,
                  ),
                ),

                Expanded(
                  child: Column(
                    children: [
                      labelText(
                        'Task ${current + 1} of 3',
                        color: Colors.black,
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (i) => Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  i == current ? Colors.black : Colors.black26,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Next appears only after locking Direction.
                if ((current == 0 && directionLocked) ||
                    (current == 1 && tiltLocked) ||
                    current == 2 && lightLocked)
                  Pill(
                    text: current == 2 ? 'Done' : 'Next',
                    width: 100,
                    color: C.pale,
                    onTap: nextTask,
                  )
                else
                  const SizedBox(width: 100),
              ],
            ),

            const SizedBox(height: 52),

            // Challenge instructions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SensorBadge(kind),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading(
                        switch (kind) {
                          SensorKind.direction =>
                            'Point ${targetDirection.toStringAsFixed(0)}° from North',
                          SensorKind.tilt => 'Tilt to 45°',
                          SensorKind.light => 'Match 50 Lux',
                        },
                        size: 20,
                      ),
                      const SizedBox(height: 5),
                      labelText(
                        switch (kind) {
                          SensorKind.direction =>
                            'Your target is ${getCardinalDirection(targetDirection)}. '
                                'Rotate your phone toward the target without seeing '
                                'your live heading.',
                          SensorKind.tilt =>
                            'Tilt your phone forward to exactly 45 degrees.',
                          SensorKind.light =>
                            'Cover or uncover the light sensor to match '
                            '50 lux without seeing your live reading.',
                        },
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 38),

            // Sensor display
            Expanded(
              child: current == 0
                  ? buildDirectionChallenge()
                  : current == 1
                      ? buildTiltChallenge()
                      : buildLightChallenge(),
            ),

            const SizedBox(height: 24),

            // Direction feedback
            if (current == 0) ...[
              if (!directionLocked) ...[
                labelText(
                  currentHeading == null
                      ? 'Waiting for compass sensor...'
                      : 'Find the target direction!\nYour current angle is hidden.',
                  weight: FontWeight.w800,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 18),
                if (currentHeading != null)
                  Pill(
                    text: 'Lock It In',
                    width: 200,
                    color: C.teal,
                    onTap: lockDirection,
                  ),
              ] else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: C.purplePale,
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: Column(
                    children: [
                      heading(
                        'Your Direction: ${lockedHeading!.toStringAsFixed(1)}°',
                        size: 20,
                      ),
                      const SizedBox(height: 8),
                      labelText(
                        '${directionError.toStringAsFixed(1)}° off target',
                        weight: FontWeight.w800,
                      ),
                    ],
                  ),
                ),
            ] else if (current == 1) ...[
              // TILT CHALLENGE

              if (!tiltReady) ...[
                labelText(
                  currentTilt == null
                      ? 'Waiting for tilt sensor...'
                      : currentTilt! <= 5
                          ? 'Your phone is flat. Press I\'m Ready!'
                          : 'Place your phone flat to begin.',
                  weight: FontWeight.w800,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 18),
                if (currentTilt != null && currentTilt! <= 5)
                  Pill(
                    text: "I'm Ready",
                    width: 200,
                    color: C.teal,
                    onTap: confirmTiltReady,
                  ),
              ] else if (!tiltLocked) ...[
                labelText(
                  'Tilt toward 45°!\nYour current angle is hidden.',
                  weight: FontWeight.w800,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Pill(
                  text: 'Lock It In',
                  width: 200,
                  color: C.teal,
                  onTap: lockTilt,
                ),
              ] else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: C.lightPink,
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: Column(
                    children: [
                      heading(
                        'Your Tilt: ${lockedTilt!.toStringAsFixed(1)}°',
                        size: 20,
                      ),
                      const SizedBox(height: 8),
                      labelText(
                        '${tiltError.toStringAsFixed(1)}° off target',
                        weight: FontWeight.w800,
                      ),
                    ],
                  ),
                ),
            ] else ...[
              // LIGHT CHALLENGE

              if (!lightLocked) ...[
                labelText(
                  lightSensorError != null
                      ? lightSensorError!
                      : currentLight == null
                          ? 'Waiting for light sensor...'
                          : 'Match 50 lux!\nYour current reading is hidden.',
                  weight: FontWeight.w800,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 18),
                if (currentLight != null)
                  Pill(
                    text: 'Lock It In',
                    width: 200,
                    color: C.teal,
                    onTap: lockLight,
                  ),
              ] else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: C.limePale,
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: Column(
                    children: [
                      heading(
                        'Your Light: $lockedLight lux',
                        size: 20,
                      ),
                      const SizedBox(height: 8),
                      labelText(
                        '$lightError lux off target',
                        weight: FontWeight.w800,
                      ),
                    ],
                  ),
                ),
            ],

            const Spacer(),

            // Challenge progress
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (current + 1) / 3,
                backgroundColor: const Color(0xFFE4E4E4),
                color: C.teal,
                minHeight: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Direction challenge panel
  Widget buildDirectionChallenge() {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: C.purpleDark,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.explore_outlined,
                color: Colors.white,
                size: 85,
              ),

              const SizedBox(height: 20),

              // Starting direction
              labelText(
                'YOUR STARTING DIRECTION',
                color: Colors.white70,
                weight: FontWeight.w800,
              ),

              const SizedBox(height: 8),

              heading(
                startingHeading == null
                    ? 'Reading sensor...'
                    : '${startingHeading!.toStringAsFixed(0)}° from North',
                size: 24,
                color: Colors.white,
              ),

              const SizedBox(height: 5),

              if (startingHeading != null)
                labelText(
                  'Facing ${getCardinalDirection(startingHeading!)}',
                  color: Colors.white,
                ),

              const SizedBox(height: 30),

              // Target direction
              labelText(
                'YOUR TARGET',
                color: Colors.white70,
                weight: FontWeight.w800,
              ),

              const SizedBox(height: 8),

              heading(
                '${targetDirection.toStringAsFixed(0)}° from North',
                size: 28,
                color: Colors.white,
              ),

              const SizedBox(height: 5),

              labelText(
                getCardinalDirection(targetDirection),
                color: Colors.white,
                weight: FontWeight.w800,
              ),

              // Only reveal after locking in
              if (directionLocked) ...[
                const SizedBox(height: 30),
                labelText(
                  'YOUR LOCKED DIRECTION',
                  color: Colors.white70,
                  weight: FontWeight.w800,
                ),
                const SizedBox(height: 8),
                heading(
                  '${lockedHeading!.toStringAsFixed(1)}°',
                  size: 30,
                  color: Colors.white,
                ),
                const SizedBox(height: 5),
                labelText(
                  'Facing ${getCardinalDirection(lockedHeading!)}',
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ));
  }

  // Tilt challenge panel
  Widget buildTiltChallenge() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: C.lightPink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 28,
          ),
          child: Column(
            children: [
              const Icon(
                Icons.screen_rotation_outlined,
                color: C.ink,
                size: 70,
              ),
              const SizedBox(height: 24),
              if (!tiltReady) ...[
                labelText(
                  'STEP 1: STARTING POSITION',
                  color: C.ink,
                  weight: FontWeight.w800,
                ),
                const SizedBox(height: 12),
                heading(
                  '0° — Flat',
                  size: 30,
                  color: C.ink,
                ),
                const SizedBox(height: 16),
                labelText(
                  'Place your phone flat on a surface, '
                  'screen facing upward.',
                  color: C.ink,
                  size: 14,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 16),
                labelText(
                  currentTilt == null
                      ? 'Waiting for sensor...'
                      : currentTilt! <= 5
                          ? 'Phone is flat! You are ready.'
                          : 'Adjust your phone until it is flat.',
                  color: C.ink,
                  weight: FontWeight.w800,
                  align: TextAlign.center,
                ),
              ] else ...[
                labelText(
                  'STEP 2: YOUR TARGET',
                  color: C.ink,
                  weight: FontWeight.w800,
                ),
                const SizedBox(height: 12),
                heading(
                  '${targetTilt.toStringAsFixed(0)}°',
                  size: 48,
                  color: C.ink,
                ),
                const SizedBox(height: 16),
                labelText(
                  'Lift the top edge of your phone '
                  'and estimate a 45° tilt.',
                  color: C.ink,
                  size: 14,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 12),
                labelText(
                  'Your live angle is hidden.',
                  color: C.ink,
                  weight: FontWeight.w800,
                ),
                if (tiltLocked) ...[
                  const SizedBox(height: 25),
                  heading(
                    'Locked In!',
                    size: 24,
                    color: C.ink,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLightChallenge() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: C.limePale,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 28,
          ),
          child: Column(
            children: [
              const Icon(
                Icons.light_mode_outlined,
                color: C.ink,
                size: 75,
              ),
              const SizedBox(height: 24),
              labelText(
                'YOUR TARGET',
                color: C.ink,
                weight: FontWeight.w800,
              ),
              const SizedBox(height: 12),
              heading(
                '$targetLight lux',
                size: 44,
                color: C.ink,
              ),
              const SizedBox(height: 24),
              labelText(
                'Cover or uncover your phone\'s '
                'light sensor to match the target.',
                color: C.ink,
                size: 14,
                align: TextAlign.center,
              ),
              const SizedBox(height: 20),
              labelText(
                'Your live light reading is hidden.',
                color: C.ink,
                weight: FontWeight.w800,
                align: TextAlign.center,
              ),
              if (lightLocked) ...[
                const SizedBox(height: 24),
                heading(
                  'Locked In!',
                  size: 24,
                  color: C.ink,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
