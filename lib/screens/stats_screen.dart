import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../widgets/app_text.dart';
import '../widgets/metric_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Please log in to view your statistics.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: heading('Statistics', size: 23)),
          const SizedBox(height: 30),
          
          // StreamBuilder listens to live Firestore updates
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('results')
                  .orderBy('completedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: C.teal),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading stats: ${snapshot.error}'),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                final totalChallenges = docs.length;

                // Calculate lifetime averages across all completed sessions
                double avgDuration = 0;
                double avgDirError = 0;
                double avgTiltError = 0;
                double avgLightError = 0;

                if (docs.isNotEmpty) {
                  int totalSeconds = 0;
                  double totalDir = 0;
                  double totalTilt = 0;
                  num totalLight = 0;

                  for (final doc in docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    totalSeconds += (data['totalDurationSeconds'] as int? ?? 0);
                    totalDir += (data['directionError'] ?? 0).toDouble();
                    totalTilt += (data['tiltError'] ?? 0).toDouble();
                    totalLight += (data['lightError'] ?? 0);
                  }

                  avgDuration = totalSeconds / docs.length;
                  avgDirError = totalDir / docs.length;
                  avgTiltError = totalTilt / docs.length;
                  avgLightError = totalLight / docs.length;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Metrics Cards: Total Done and Avg Time
                    Row(children: [
                      Expanded(
                        child: MetricCard(
                          value: totalChallenges.toString(),
                          title: 'Total Done',
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: MetricCard(
                          value: docs.isNotEmpty ? '${avgDuration.toStringAsFixed(1)}s' : '0.0s',
                          title: 'Avg Time',
                        ),
                      ),
                    ]),

                    // Lifetime Average Error Banner
                    if (docs.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: C.teal.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'LIFETIME AVG ERROR',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _metricColumn('Compass', '±${avgDirError.toStringAsFixed(1)}°'),
                                _metricColumn('Tilt', '±${avgTiltError.toStringAsFixed(1)}°'),
                                _metricColumn('Light', '±${avgLightError.toStringAsFixed(0)} lx'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),
                    heading('Recent Results', size: 27),
                    const SizedBox(height: 20),
                    
                    // Empty state vs Populated ListView with Flat Cards
                    docs.isEmpty
                        ? const Expanded(
                            child: Center(
                              child: Text(
                                'No challenge history yet. Complete one today!',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.separated(
                              itemCount: docs.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, i) {
                                final data = docs[i].data() as Map<String, dynamic>;
                                
                                // Format Firestore Timestamp safely
                                final timestamp = data['completedAt'] as Timestamp?;
                                final dateStr = timestamp != null
                                    ? DateFormat('MMM d, yyyy').format(timestamp.toDate())
                                    : (data['challengeDate'] ?? 'Recent Attempt');

                                final duration = data['totalDurationSeconds'] ?? 0;
                                final dirErr = (data['directionError'] ?? 0).toDouble();
                                final tiltErr = (data['tiltError'] ?? 0).toDouble();
                                final lightErr = data['lightError'] ?? 0;

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: C.lightPink,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      // Top row: Date on left, Duration on right
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            dateStr,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(Icons.timer_outlined, size: 16, color: Colors.black54),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${duration}s',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Bottom row: 3 crisp mini-chips for each sensor error
                                      Row(
                                        children: [
                                          _statChip(Icons.explore_outlined, '${dirErr.toStringAsFixed(1)}°'),
                                          const SizedBox(width: 8),
                                          _statChip(Icons.screen_rotation_outlined, '${tiltErr.toStringAsFixed(1)}°'),
                                          const SizedBox(width: 8),
                                          _statChip(Icons.wb_sunny_outlined, '$lightErr lx'),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for the 3 mini-chips inside each card
  Widget _statChip(IconData icon, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: Colors.black54),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for the lifetime banner columns
  Widget _metricColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label, 
          style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          value, 
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}