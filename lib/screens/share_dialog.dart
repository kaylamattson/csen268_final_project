import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart'; 
import '../theme/app_colors.dart';
import '../widgets/app_text.dart';
import '../widgets/pill_button.dart';
import '../widgets/sensor_badge.dart';
import '../models/sensor_kind.dart';
import 'tabs_page.dart';

class ShareDialog extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ShareDialog({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    final timestamp = resultData['completedAt'] as Timestamp?;
    final dateStr = timestamp != null
        ? DateFormat('MMMM d, yyyy').format(timestamp.toDate())
        : (resultData['challengeDate'] ?? 'Today');

    final dirErr = (resultData['directionError'] ?? 0).toDouble();
    final tiltErr = (resultData['tiltError'] ?? 0).toDouble();
    final lightErr = (resultData['lightError'] ?? 0);

    final totalSeconds = resultData['totalDurationSeconds'] ?? 0;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final timeFormatted = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                heading('Sensle', size: 30),
                labelText(dateStr, size: 15, color: Colors.black54),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SensorBadge(SensorKind.direction, size: 76),
                SensorBadge(SensorKind.tilt, size: 76),
                SensorBadge(SensorKind.light, size: 76),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(width: 80, child: Center(child: labelText('${dirErr.toStringAsFixed(1)}°', color: Colors.black, weight: FontWeight.w800))),
                SizedBox(width: 80, child: Center(child: labelText('${tiltErr.toStringAsFixed(1)}°', color: Colors.black, weight: FontWeight.w800))),
                SizedBox(width: 80, child: Center(child: labelText('$lightErr lx', color: Colors.black, weight: FontWeight.w800))),
              ],
            ),
            const SizedBox(height: 22),
            heading(timeFormatted, color: Colors.black, size: 39),
            const SizedBox(height: 10),
            labelText('Challenge Completed!', color: Colors.black54, size: 18),
            const SizedBox(height: 12),
            labelText('Move. Measure. Master!', weight: FontWeight.w800),
            const SizedBox(height: 18),
            
            // 2. Trigger native share sheet when tapped
            Pill(
              text: 'Send to Friend',
              color: C.pale,
              onTap: () {
                final message = '🎮 Sensle Challenge Results ($dateStr)\n'
                    '⏱️ Time: $timeFormatted\n'
                    '🧭 Compass Error: ±${dirErr.toStringAsFixed(1)}°\n'
                    '📐 Tilt Error: ±${tiltErr.toStringAsFixed(1)}°\n'
                    '☀️ Light Error: ±$lightErr lx\n\n'
                    'Can you beat my score? 🚀';
                
                Share.share(message);
              },
            ),
            const SizedBox(height: 10),
            Pill(
              text: 'Back to Home',
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const TabsPage()),
                (_) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}