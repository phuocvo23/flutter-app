import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/app_theme.dart';
import 'screens/splash_screen.dart';
// import 'services/seeding_service.dart';
import 'models/cart_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load cart from local storage
  await CartState.loadFromStorage();

  // [DISABLED] Seed products - bỏ comment để chạy lại seeding
  // await SeedingService().seedProducts();

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
