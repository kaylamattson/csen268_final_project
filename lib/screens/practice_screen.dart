import 'package:flutter/material.dart';
import '../models/sensor_kind.dart';
import '../widgets/app_text.dart';
import '../widgets/task_card.dart';
import 'sensor_practice_page.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});
  @override
Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(30, 25, 30, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Practice',
            style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w700,
                color: Colors.black)),
        const SizedBox(height: 10),
        labelText('Test and calibrate each\nsensor whenever you want!',
            color: const Color(0xFF68767A), size: 18),
        const SizedBox(height: 38),
        for (final kind in SensorKind.values) ...[
          taskCard(
              kind,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => PracticePage(kind: kind)))),
          const SizedBox(height: 28)
        ]
      ]));
}
