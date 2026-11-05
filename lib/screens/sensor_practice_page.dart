import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:light/light.dart';
import 'dart:async';
import 'dart:math' as math;

class SensorPracticePage extends StatefulWidget {
  final String taskName;

  const SensorPracticePage({super.key, required this.taskName});

  @override
  State<SensorPracticePage> createState() => _SensorPracticePageState();
}

class _SensorPracticePageState extends State<SensorPracticePage> {
  // Tilt variables
  double _xAxis = 0.0;
  double _yAxis = 0.0;
  double _zAxis = 0.0;

  // Direction variables
  double _heading = 0.0;

  // Light sensor variables
  int _luxValue = 0;
  bool _sensorAvailable = true;

  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  StreamSubscription<MagnetometerEvent>? _magSubscription;
  StreamSubscription<int>? _lightSubscription;
  Light? _light;

  @override
  void initState() {
    super.initState();
    final task = widget.taskName.toLowerCase();

    if (task.contains('tilt')) {
      _accelSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
        setState(() {
          _xAxis = event.x;
          _yAxis = event.y;
          _zAxis = event.z;
        });
      });
    } else if (task.contains('direction')) {
      _magSubscription = magnetometerEvents.listen((MagnetometerEvent event) {
        setState(() {
          double heading = math.atan2(event.y, event.x) * (180 / math.pi);
          if (heading < 0) {
            heading += 360;
          }
          _heading = heading;
        });
      });
    } else if (task.contains('light')) {
      _initLightSensor();
    }
  }

  Future<void> _initLightSensor() async {
    try {
      _light = Light();
      _lightSubscription = _light?.lightSensorStream.listen(
        (int lux) {
          setState(() {
            _luxValue = lux;
            _sensorAvailable = true;
          });
        },
        onError: (error) {
          setState(() {
            _sensorAvailable = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _sensorAvailable = false;
      });
    }
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    _magSubscription?.cancel();
    _lightSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.taskName.toLowerCase();
    bool isDirection = task.contains('direction');
    bool isLight = task.contains('light');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.taskName,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Calibration Mode',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isLight
                    ? 'Reading live hardware ambient light levels.'
                    : isDirection
                        ? 'Test live compass heading and orientation.'
                        : 'Test and monitor live sensor telemetry in real-time.',
                style: const TextStyle(
                  color: Color(0xFF68767A),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: isLight
                    ? _buildLightContent()
                    : isDirection
                        ? _buildDirectionContent()
                        : _buildTiltContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTiltContent() {
    return Column(
      children: [
        const Icon(Icons.screen_rotation, size: 48, color: Colors.teal),
        const SizedBox(height: 16),
        Text(
          widget.taskName.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 24),
        _buildMetricRow('X-Axis Tilt', _xAxis),
        const Divider(height: 24),
        _buildMetricRow('Y-Axis Tilt', _yAxis),
        const Divider(height: 24),
        _buildMetricRow('Z-Axis Gravity', _zAxis),
      ],
    );
  }

  Widget _buildDirectionContent() {
    return Column(
      children: [
        const Icon(Icons.explore, size: 48, color: Colors.teal),
        const SizedBox(height: 16),
        Text(
          widget.taskName.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '${_heading.toStringAsFixed(1)}°',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getCardinalDirection(_heading),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildLightContent() {
    return Column(
      children: [
        const Icon(Icons.wb_sunny, size: 48, color: Colors.amber),
        const SizedBox(height: 16),
        Text(
          widget.taskName.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.amber,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '$_luxValue lx',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getLightDescription(_luxValue),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.amber,
          ),
        ),
        if (!_sensorAvailable) ...[
          const SizedBox(height: 16),
          const Text(
            'Ambient light sensor not detected on this hardware emulator.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.redAccent),
          ),
        ],
      ],
    );
  }

  String _getLightDescription(int lux) {
    if (lux < 50) return 'Dim / Night';
    if (lux < 300) return 'Indoor Office Lighting';
    if (lux < 1000) return 'Bright Indoor / Overcast';
    return 'Direct Sunlight';
  }

  String _getCardinalDirection(double heading) {
    if (heading >= 337.5 || heading < 22.5) return 'North (N)';
    if (heading >= 22.5 && heading < 67.5) return 'North-East (NE)';
    if (heading >= 67.5 && heading < 112.5) return 'East (E)';
    if (heading >= 112.5 && heading < 157.5) return 'South-East (SE)';
    if (heading >= 157.5 && heading < 202.5) return 'South (S)';
    if (heading >= 202.5 && heading < 247.5) return 'South-West (SW)';
    if (heading >= 247.5 && heading < 292.5) return 'West (W)';
    return 'North-West (NW)';
  }

  Widget _buildMetricRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF68767A),
          ),
        ),
        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}