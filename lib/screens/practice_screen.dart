import 'package:flutter/material.dart';
import '../models/sensor_kind.dart';
import '../widgets/app_text.dart';
import '../widgets/task_card.dart';
import 'sensor_practice_page.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 25, 30, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Practice',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          labelText(
            'Test and calibrate each\nsensor whenever you want!',
            color: const Color(0xFF68767A),
            size: 18,
          ),
          const SizedBox(height: 38),
          Expanded(
            child: ListView(
              children: [
                for (final kind in SensorKind.values) ...[
                  taskCard(
                    kind,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SensorPracticePage(
                          // Pass the specific task name dynamically based on the loop item
                          taskName: kind.name, 
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}