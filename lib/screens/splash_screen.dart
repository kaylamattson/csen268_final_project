import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../models/sensor_kind.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text.dart';
import '../widgets/pill_button.dart';
import '../widgets/sensor_badge.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _motionController;

  @override
  void initState() {
    super.initState();

    // 1. Entrance choreography controller (1.8 seconds)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    // 2. Motion controller (2.8 seconds for smooth, relaxed pacing)
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // Trigger the badge motions shortly after the screen appears
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _motionController.forward();
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _motionController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Base(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Top Sun Icon with scale entrance and RGB color fade
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _entranceController,
                curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
              ),
              child: AnimatedBuilder(
                animation: _motionController,
                builder: (context, child) {
                  final t = _motionController.value;
                  final hueShift = (t < 1.0) ? (t * 360 * 2) % 360 : 0.0;
                  final blendFactor = (t < 1.0) ? (1.0 - t) : 0.0;

                  final shiftingColor = HSVColor.fromAHSV(
                    1.0,
                    hueShift,
                    0.8,
                    0.9,
                  ).toColor();

                  return ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      shiftingColor.withOpacity(blendFactor * 0.8),
                      BlendMode.srcATop,
                    ),
                    child: child,
                  );
                },
                child: const Icon(
                  Icons.light_mode_outlined,
                  size: 80,
                  color: Color(0xFF242428),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Sensle Title with slide & fade
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _entranceController,
                curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _entranceController,
                  curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
                )),
                child: Text(
                  'Sensle',
                  style: TextStyle(
                    fontSize: 76,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    shadows: [
                      Shadow(color: C.teal, offset: const Offset(3, 4)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Tagline
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _entranceController,
                curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
              ),
              child: labelText(
                'Quick... Move. Measure. Master!',
                size: 16,
                color: Colors.black,
                weight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 58),

            // Three Sensor Badges with Slower, Relaxed Thematic Motions
            AnimatedBuilder(
              animation: _motionController,
              builder: (context, child) {
                final t = _motionController.value;

                // 1. Direction: Slower 360-degree horizontal spin
                final spinProgress = Curves.easeOutCubic.transform(t);
                final directionAngle = spinProgress * 2 * math.pi;

                // 2. Tilt: Slower 360-degree vertical flip
                final tiltProgress = Curves.easeOutCubic.transform(t);
                final tiltAngle = tiltProgress * 2 * math.pi;

                // 3. Light: Brighter and dimmer flash effect
                final brightnessOffset = (t < 1.0)
                    ? math.sin(t * 3 * math.pi) * 0.3 * (1.0 - t)
                    : 0.0;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Direction Badge (Spin)
                    Transform.rotate(
                      angle: directionAngle,
                      alignment: Alignment.center,
                      child: const SensorBadge(SensorKind.direction, size: 76),
                    ),

                    // Tilt Badge (Vertical Flip)
                    Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.003)
                        ..rotateX(tiltAngle),
                      alignment: Alignment.center,
                      child: const SensorBadge(SensorKind.tilt, size: 76),
                    ),

                    // Light Badge (Brighten and Dim Flash)
                    ColorFiltered(
                      colorFilter: ColorFilter.matrix(<double>[
                        1, 0, 0, 0, brightnessOffset * 255,
                        0, 1, 0, 0, brightnessOffset * 255,
                        0, 0, 1, 0, brightnessOffset * 255,
                        0, 0, 0, 1, 0,
                      ]),
                      child: const SensorBadge(SensorKind.light, size: 76),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 62),

            // Let's Go Button with slide-up entrance
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _entranceController,
                curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
              )),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _entranceController,
                  curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                ),
                child: Pill(
                  text: 'Let’s Go!',
                  onTap: _navigateToLogin,
                  width: 197,
                ),
              ),
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}