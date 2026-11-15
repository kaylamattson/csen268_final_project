import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../widgets/app_text.dart';
import '../widgets/metric_card.dart';
import 'share_dialog.dart';

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

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Metrics Cards with real count
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
                          value: totalChallenges > 0 ? 'Active' : '0%',
                          title: 'Status',
                        ),
                      ),
                    ]),
                    const SizedBox(height: 34),
                    heading('Recent Results', size: 27),
                    const SizedBox(height: 25),
                    
                    // Empty state vs Populated ListView
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
                              separatorBuilder: (_, __) => const SizedBox(height: 24),
                              itemBuilder: (context, i) {
                                final data = docs[i].data() as Map<String, dynamic>;
                                
                                // Format Firestore Timestamp safely
                                final timestamp = data['completedAt'] as Timestamp?;
                                final dateStr = timestamp != null
                                    ? DateFormat('MMM d, yyyy').format(timestamp.toDate())
                                    : 'Recent Attempt';

                                // Pull a specific metric nicely instead of raw map values
                                final completionTime = data['completion_time'];
                                final scoreDisplay = completionTime != null ? 'Time: $completionTime' : 'Completed';

                                return InkWell(
                                  onTap: () => showDialog(
                                    context: context,
                                    builder: (_) => const ShareDialog(),
                                  ),
                                  child: Container(
                                    height: 55,
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: C.lightPink,
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 3,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: labelText(dateStr, weight: FontWeight.w800),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: labelText(
                                              scoreDisplay, 
                                              weight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
}