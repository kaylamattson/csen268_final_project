import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/sensor_kind.dart';
import '../widgets/app_text.dart';
import '../widgets/pill_button.dart';
import '../widgets/task_card.dart';
import 'challenge_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
              Text(
                DateFormat('MMM d, yyyy').format(DateTime.now()),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 24),
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

// Temporary Firestore test button
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            try {
              final user = FirebaseAuth.instance.currentUser;

              if (user == null) {
                debugPrint('No user signed in');
                return;
              }

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('results')
                  .add({
                'directionError': 15,
                'tiltAngle': 42,
                'completedAt': FieldValue.serverTimestamp(),
              });

              debugPrint('Firestore test successful!');

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Result saved to Firestore!'),
                  ),
                );
              }
            } catch (e) {
              debugPrint('Firestore error: $e');

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Firestore error: $e')),
                );
              }
            }
          },
          child: const Text('Test Firestore'),
        ),
      ]));
}
