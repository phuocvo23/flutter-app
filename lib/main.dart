import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/firestore_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Seed data nếu chưa có
  final seeder = FirestoreSeeder();
  if (!await seeder.isSeeded()) {
    await seeder.seedAll();
  }

  runApp(const FuotShopApp());
}

class FuotShopApp extends StatelessWidget {
  const FuotShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fuot Shop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
