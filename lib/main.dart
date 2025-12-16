import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
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
