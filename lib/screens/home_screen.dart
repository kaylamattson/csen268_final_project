import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/sensor_kind.dart';
import '../widgets/app_text.dart';
import '../widgets/pill_button.dart';
import '../widgets/task_card.dart';
import 'challenge_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
Widget build(BuildContext context) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 24, 30, 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Sensle',
            style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                color: Colors.black)),
        const SizedBox(height: 10),
        Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                color: C.teal, borderRadius: BorderRadius.circular(24)),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.calendar_month_outlined,
                    color: C.ink, size: 32),
                const SizedBox(width: 14),
                Expanded(child: heading("Today's Challenge", size: 25))
              ]),
              labelText('Oct 14, 2026', color: Colors.white70),
              const SizedBox(height: 32),
              labelText('3 tasks, 1 minute.\nCan you complete them all?',
                  color: Colors.white, align: TextAlign.center),
              const SizedBox(height: 8)
            ])),
        const SizedBox(height: 24),
        for (final s in SensorKind.values) ...[
          taskCard(
              s,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChallengePage(
                          initialTask: SensorKind.values.indexOf(s))))),
          const SizedBox(height: 18)
        ],
        const SizedBox(height: 16),
        Pill(
            text: 'Start Challenge',
            color: C.darkTeal,
            textColor: Colors.white,
            width: double.infinity,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ChallengePage()))),
      ]));
}
