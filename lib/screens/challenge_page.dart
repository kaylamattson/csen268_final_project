
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../theme/app_colors.dart';
import '../models/sensor_kind.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text.dart';
import '../widgets/pill_button.dart';
import '../widgets/sensor_badge.dart';
import '../widgets/sensor_panel.dart';
import 'completion_page.dart';

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

  StreamSubscription<MagnetometerEvent>? magnetometerSubscription;

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

    if (current == 0) {
      startDirectionSensor();
    }
  }
  

  void startDirectionSensor() {
    magnetometerSubscription =
        magnetometerEventStream().listen((event) {
      double heading =
          math.atan2(event.y, event.x) * (180 / math.pi);

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

    final difference =
        (lockedHeading! - targetDirection).abs();

    return math.min(difference, 360 - difference);
  }

  void nextTask() {
    if (current == 0 && !directionLocked) return;

    if (current < 2) {
      setState(() {
        current++;
      });

      if (current == 1) {
        magnetometerSubscription?.cancel();
        magnetometerSubscription = null;
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CompletionPage(),
        ),
      );
    }
  }

  @override
  void dispose() {
    magnetometerSubscription?.cancel();
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
                              color: i == current
                                  ? Colors.black
                                  : Colors.black26,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Next appears only after locking Direction.
                if (current != 0 || directionLocked)
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
                          SensorKind.direction => 'Point ${targetDirection.toStringAsFixed(0)}° from North',
                          SensorKind.tilt => 'Tilt to 45°',
                          SensorKind.light => 'Block the Light Sensor',
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
                            'Cover the top of your phone to block the light sensor.',
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
                  : SensorPanel(
                      kind: kind,
                      practice: false,
                    ),
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
            ] else
              // Existing Tilt and Light feedback
              Container(
                height: 76,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: current == 1
                      ? C.lightPink
                      : C.limePale,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Center(
                  child: labelText(
                    current == 1
                        ? 'Tilt a bit more forward!'
                        : 'Keep blocking the light!',
                    weight: FontWeight.w800,
                    align: TextAlign.center,
                  ),
                ),
              ),

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
    )
  );
}

}
