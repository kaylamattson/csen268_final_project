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
import '../models/challenge_result.dart';
import '../repositories/challenge_repository.dart';

class CompletionPage extends StatefulWidget {
  final String resultId;

  const CompletionPage({
    super.key,
    required this.resultId,
  });

  @override
  State<CompletionPage> createState() => _CompletionPageState();
}

class _CompletionPageState extends State<CompletionPage> {
  late final Future<ChallengeResult?> resultFuture;

  final ChallengeRepository _challengeRepository = ChallengeRepository();

  @override
  void initState() {
    super.initState();

    resultFuture = _challengeRepository.getResult(widget.resultId);
  }

  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String formatError(dynamic value, String unit) {
    if (value is! num) return '—';

    return '${value.toStringAsFixed(1)}$unit';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChallengeResult?>(
      future: resultFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Base(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Base(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load your results:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final result = snapshot.data;

        if (result == null) {
          return const Base(
            child: Center(
              child: Text('Challenge results not found.'),
            ),
          );
        }

        final duration = result.totalDurationSeconds;

        final directionError = result.directionError;
        final tiltError = result.tiltError;
        final lightError = result.lightError;

        final accuracy = result.accuracy;

        final challengeDate = result.challengeDate;

        return Base(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                25,
                35,
                25,
                24,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events_outlined,
                    size: 95,
                    color: Color(0xFF222227),
                  ),

                  const SizedBox(height: 15),

                  // Completion banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    color: C.ink,
                    child: Column(
                      children: [
                        heading(
                          'You Did It!',
                          size: 35,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        labelText(
                          'Completed today’s challenge in',
                          color: Colors.white,
                        ),
                        heading(
                          formatDuration(duration),
                          size: 25,
                          color: Colors.white,
                        ),
                        if (challengeDate.isNotEmpty)
                          labelText(
                            challengeDate,
                            color: Colors.white70,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(
                        width: 125,
                        child: MetricCard(
                          value: '—',
                          title: 'Day Streak',
                        ),
                      ),
                      SizedBox(
                        width: 125,
                        child: MetricCard(
                          value: accuracy == null
                              ? '—'
                              : '${accuracy.toStringAsFixed(1)}%',
                          title: 'Accuracy',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Today's Results
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: C.teal,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        heading(
                          'Today’s Results',
                          color: Colors.white,
                          size: 19,
                        ),
                        const SizedBox(height: 28),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SensorBadge(
                              SensorKind.direction,
                              size: 74,
                            ),
                            SensorBadge(
                              SensorKind.tilt,
                              size: 74,
                            ),
                            SensorBadge(
                              SensorKind.light,
                              size: 74,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: labelText(
                                '${formatError(directionError, '°')}\noff target',
                                size: 12,
                                color: Colors.black,
                                align: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: labelText(
                                '${formatError(tiltError, '°')}\noff target',
                                size: 12,
                                color: Colors.black,
                                align: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: labelText(
                                '${formatError(lightError, ' lux')}\noff target',
                                size: 12,
                                color: Colors.black,
                                align: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Existing Share Results dialog
                  Pill(
                    text: 'Share Results',
                    color: C.pale,
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => const ShareDialog(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Pill(
                    text: 'Back to Home',
                    onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TabsPage(),
                      ),
                      (_) => false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
