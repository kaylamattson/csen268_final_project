import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/sensor_kind.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_text.dart';
import '../widgets/pill_button.dart';
import '../widgets/sensor_badge.dart';
import '../widgets/metric_card.dart';
import 'share_dialog.dart';
import 'tabs_page.dart';

class CompletionPage extends StatelessWidget {
  const CompletionPage({super.key});
  @override
  Widget build(BuildContext context) => Base(
      child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 35, 25, 24),
              child: Column(children: [
                const Icon(Icons.emoji_events_outlined,
                    size: 95, color: Color(0xFF222227)),
                const SizedBox(height: 15),
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: C.ink,
                    child: Column(children: [
                      heading('You Did It!', size: 35, color: Colors.white),
                      const SizedBox(height: 8),
                      labelText("Completed today’s challenge in",
                          color: Colors.white),
                      heading('00:00', size: 25, color: Colors.white)
                    ])),
                const SizedBox(height: 15),
                const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                          width: 125,
                          child: MetricCard(value: 'X', title: 'Day Streak')),
                      SizedBox(
                          width: 125,
                          child: MetricCard(value: 'XX%', title: 'Accuracy'))
                    ]),
                const SizedBox(height: 15),
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: C.teal, borderRadius: BorderRadius.circular(30)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          heading("Today’s Results",
                              color: Colors.white, size: 19),
                          const SizedBox(height: 28),
                          const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SensorBadge(SensorKind.direction, size: 74),
                                SensorBadge(SensorKind.tilt, size: 74),
                                SensorBadge(SensorKind.light, size: 74)
                              ]),
                          const SizedBox(height: 12),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                for (final s in [
                                  'X°\noff target',
                                  'X°\noff target',
                                  'X%\nlight level'
                                ])
                                  labelText(s,
                                      size: 12,
                                      color: Colors.black,
                                      align: TextAlign.center)
                              ]),
                        ])),
                const SizedBox(height: 20),
                Pill(
                    text: 'Share Results',
                    color: C.pale,
                    onTap: () => showDialog(
                        context: context, builder: (_) => const ShareDialog())),
                const SizedBox(height: 12),
                Pill(
                    text: 'Back to Home',
                    onTap: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const TabsPage()),
                        (_) => false)),
              ]))));
}
