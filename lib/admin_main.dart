import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'adminPage/config/admin_theme.dart';
import 'adminPage/screens/admin_login_screen.dart';

/// Entry point for Admin Panel (run with: flutter run -t lib/admin_main.dart)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fuot Shop Admin',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.darkTheme,
      home: const AdminLoginScreen(),
    );
  }
}
