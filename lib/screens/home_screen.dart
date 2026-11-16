import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../theme/app_colors.dart';
import '../models/sensor_kind.dart';
import '../widgets/app_text.dart';
import '../widgets/pill_button.dart';
import '../widgets/task_card.dart';
import 'challenge_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1. Request notification permissions for iOS / Android 13+
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // 2. Get the unique FCM token for testing or backend targeting
    String? token = await messaging.getToken();
    debugPrint("FCM Device Token: $token");

    // 3. Listen for incoming messages while the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground message: ${message.notification?.title}');

      if (message.notification != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${message.notification?.title}: ${message.notification?.body}'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 24, 30, 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sensle',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.account_circle_outlined,
                size: 38,
                color: Colors.black,
              ),
              tooltip: 'Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),

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
              const SizedBox(height: 20),
              labelText('3 tasks.\nHow fast can you complete them all?',
                  color: Colors.white, align: TextAlign.center, size: 18),
              const SizedBox(height: 8)
            ])),
        const SizedBox(height: 24),

        // Task cards are now fully non-interactive
        for (final s in SensorKind.values) ...[
          taskCard(s),
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
      ]),
    );
  }
}
