import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoggingOut = false;

  Future<void> logOut() async {
    if (isLoggingOut) return;

    setState(() {
      isLoggingOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not log out: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF7),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const SizedBox(height: 45),
            const CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFFE5D7F0),
              child: Icon(
                Icons.person_outline,
                size: 55,
                color: Color(0xFF765A91),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'My Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 27,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              user?.email ?? 'No email available',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF68767A),
              ),
            ),
            const SizedBox(height: 45),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: isLoggingOut ? null : logOut,
                icon: const Icon(Icons.logout),
                label: Text(
                  isLoggingOut ? 'Logging Out...' : 'Log Out',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7DFE5),
                  foregroundColor: const Color(0xFF753C53),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
