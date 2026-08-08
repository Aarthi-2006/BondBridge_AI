import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const BondBridgeAI());
}

class BondBridgeAI extends StatelessWidget {
  const BondBridgeAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BondBridge AI',

      // Global Theme
      theme: AppTheme.lightTheme,

      home: const SplashScreen(),
    );
  }
}