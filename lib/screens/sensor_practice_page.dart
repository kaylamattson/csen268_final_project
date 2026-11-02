import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/sensor_kind.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text.dart';
import '../widgets/sensor_badge.dart';
import '../widgets/sensor_panel.dart';

class PracticePage extends StatelessWidget {
  final SensorKind kind;
  const PracticePage({super.key, required this.kind});
  @override
  Widget build(BuildContext context) => Base(
      child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 23, 26, 24),
          child: Column(children: [
            Row(children: [
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon:
                      const Icon(Icons.arrow_back_ios, color: C.ink, size: 28)),
              const SizedBox(width: 18),
              SensorBadge(kind),
              const SizedBox(width: 18),
              Expanded(
                  child: heading(
                      switch (kind) {
                        SensorKind.direction => 'Navigation Practice',
                        SensorKind.tilt => 'Tilt Practice',
                        SensorKind.light => 'Light Practice'
                      },
                      size: 20))
            ]),
            const SizedBox(height: 42),
            SizedBox(
                height: MediaQuery.sizeOf(context).height * .43,
                child: SensorPanel(kind: kind, practice: true)),
            if (kind != SensorKind.light) ...[
              const SizedBox(height: 50),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                practiceMetric(
                    kind == SensorKind.direction ? 'Heading' : 'Pitch', 'X°'),
                practiceMetric(
                    kind == SensorKind.direction ? 'Accuracy' : 'Roll', '±X°')
              ])
            ],
            const Spacer(),
          ])));
  Widget practiceMetric(String title, String value) => Container(
      width: 122,
      height: 92,
      decoration: BoxDecoration(
          color: sensorColor(kind), borderRadius: BorderRadius.circular(30)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        labelText(title, color: Colors.black),
        heading(value, color: Colors.black, size: 26)
      ]));
}
