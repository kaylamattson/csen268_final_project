import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SensleApp());
}

class SensleApp extends StatelessWidget {
  const SensleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Sensle',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: C.teal),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: C.ink, fontSize: 16),
          ),
        ),
        home: const SplashScreen(),
      );
}
