import 'package:flutter/material.dart';
import '../widgets/app_text.dart';
import '../widgets/pill_button.dart';
import '../widgets/sensor_badge.dart';
import '../models/sensor_kind.dart';
import 'tabs_page.dart';

class ShareDialog extends StatelessWidget {
  const ShareDialog({super.key});
  @override
  Widget build(BuildContext context) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              heading('Sensle', size: 30),
              labelText('June 27, 2026', size: 17, color: Colors.black)
            ]),
            const SizedBox(height: 20),
            const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SensorBadge(SensorKind.direction, size: 76),
                  SensorBadge(SensorKind.tilt, size: 76),
                  SensorBadge(SensorKind.light, size: 76)
                ]),
            const SizedBox(height: 14),
            labelText('X°                 X°                 X%',
                color: Colors.black),
            const SizedBox(height: 22),
            heading('00:00', color: Colors.black, size: 39),
            const SizedBox(height: 10),
            labelText('X Day Streak!', color: Colors.black, size: 24),
            const SizedBox(height: 12),
            labelText('Move. Measure. Master!', weight: FontWeight.w800),
            const SizedBox(height: 18),
            Pill(
                text: 'Back to Home',
                onTap: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const TabsPage()),
                    (_) => false)),
          ])));
}
