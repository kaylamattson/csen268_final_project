import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:light/light.dart';

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

  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<int>? _lightSubscription;

  double? _heading;
  double? _tiltAngle;
  int? _lux;
  String? _sensorError;

  @override
  void initState() {
    super.initState();
    _startCurrentSensor();
  }

  void _stopSensors() {
    _magnetometerSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _lightSubscription?.cancel();
    _magnetometerSubscription = null;
    _accelerometerSubscription = null;
    _lightSubscription = null;
  }

  void _startCurrentSensor() {
    _stopSensors();
    _heading = null;
    _tiltAngle = null;
    _lux = null;
    _sensorError = null;

    switch (SensorKind.values[current]) {
      case SensorKind.direction:
        _magnetometerSubscription = magnetometerEventStream().listen(
          (event) {
            // Matches the existing Practice screen: raw magnetometer
            // angle, not yet a calibrated, tilt-compensated compass heading.
            final rawAngle = math.atan2(event.y, event.x) * 180 / math.pi;
            final heading = (rawAngle + 360) % 360;
            if (mounted) setState(() => _heading = heading);
          },
          onError: (Object error) {
            if (mounted) setState(() => _sensorError = 'Direction sensor unavailable');
          },
          cancelOnError: true,
        );
        break;
      case SensorKind.tilt:
        _accelerometerSubscription = accelerometerEventStream().listen(
          (event) {
            // An approximate pitch-like tilt magnitude relative to the
            // device's Y axis. Calibrate against your emulator's Device Pose.
            final tilt = math.atan2(
              event.y.abs(),
              math.sqrt(event.x * event.x + event.z * event.z),
            ) * 180 / math.pi;
            if (mounted) setState(() => _tiltAngle = tilt);
          },
          onError: (Object error) {
            if (mounted) setState(() => _sensorError = 'Tilt sensor unavailable');
          },
          cancelOnError: true,
        );
        break;
      case SensorKind.light:
        try {
          _lightSubscription = Light().lightSensorStream.listen(
            (lux) {
              if (mounted) setState(() => _lux = lux);
            },
            onError: (Object error) {
              if (mounted) setState(() => _sensorError = 'Light sensor unavailable');
            },
            cancelOnError: true,
          );
        } catch (_) {
          _sensorError = 'Light sensor unavailable';
        }
        break;
    }
  }

  @override
  void dispose() {
    _stopSensors();
    super.dispose();
  }

  void _nextTask() {
    if (current < SensorKind.values.length - 1) {
      setState(() {
        current++;
        _startCurrentSensor();
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CompletionPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final kind = SensorKind.values[current];
    return Base(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, color: C.ink, size: 28),
                ),
                Expanded(
                  child: Column(
                    children: [
                      labelText('Task ${current + 1} of 3', color: Colors.black, size: 24),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == current ? Colors.black : Colors.black26,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Pill(
                  text: current == 2 ? 'Done' : 'Next',
                  width: 100,
                  color: C.pale,
                  onTap: _nextTask,
                ),
              ],
            ),
            const SizedBox(height: 52),
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
                          SensorKind.direction => 'Point Due North',
                          SensorKind.tilt => 'Tilt to 45°',
                          SensorKind.light => 'Block the Light Sensor',
                        },
                        size: 20,
                      ),
                      const SizedBox(height: 5),
                      labelText(
                        switch (kind) {
                          SensorKind.direction => 'Rotate your phone until it points exactly north.',
                          SensorKind.tilt => 'Tilt your phone forward to exactly 45 degrees.',
                          SensorKind.light => 'Cover the top of your phone to block the light sensor.',
                        },
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 38),
            Expanded(
              child: SensorPanel(
                kind: kind,
                practice: false,
                headingDegrees: _heading,
                tiltAngle: _tiltAngle,
                lux: _lux,
                errorText: _sensorError,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: kind == SensorKind.direction ? 76 : 55,
              width: double.infinity,
              decoration: BoxDecoration(
                color: switch (kind) {
                  SensorKind.direction => C.purplePale,
                  SensorKind.tilt => C.lightPink,
                  SensorKind.light => C.limePale,
                },
                borderRadius: BorderRadius.circular(21),
                boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 3), blurRadius: 3)],
              ),
              child: Center(
                child: labelText(
                  _sensorError ?? switch (kind) {
                    SensorKind.direction => 'Keep rotating...\nGet as close as possible!',
                    SensorKind.tilt => 'Tilt a bit more forward!',
                    SensorKind.light => 'Keep blocking the light!',
                  },
                  weight: FontWeight.w800,
                  align: TextAlign.center,
                ),
              ),
            ),
            const Spacer(),
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
}
