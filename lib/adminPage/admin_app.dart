import 'package:flutter/material.dart';
import 'config/admin_theme.dart';
import 'screens/admin_login_screen.dart';

/// Admin App - Entry point for admin panel
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
