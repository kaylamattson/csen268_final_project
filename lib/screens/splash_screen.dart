import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/sensor_kind.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text.dart';
import '../widgets/pill_button.dart';
import '../widgets/sensor_badge.dart';
import 'tabs_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => Base(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(children: [
            const Spacer(flex: 2),
            const Icon(Icons.light_mode_outlined,
                size: 80, color: Color(0xFF242428)),
            const SizedBox(height: 20),
            Text('Sensle',
                style: TextStyle(
                    fontSize: 76,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    shadows: [
                      Shadow(color: C.teal, offset: const Offset(3, 4))
                    ])),
            const SizedBox(height: 8),
            labelText('Quick... Move. Measure. Master!',
                size: 16, color: Colors.black, weight: FontWeight.w800),
            const SizedBox(height: 58),
            const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SensorBadge(SensorKind.direction, size: 76),
                  SensorBadge(SensorKind.tilt, size: 76),
                  SensorBadge(SensorKind.light, size: 76)
                ]),
            const SizedBox(height: 62),
            Pill(
                text: 'Let’s Go!',
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const TabsPage())),
                width: 197),
            const Spacer(flex: 3),
          ])));
}
