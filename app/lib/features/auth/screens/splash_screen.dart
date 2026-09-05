import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Écran affiché brièvement pendant la résolution de l'état d'authentification
/// (Firebase + `GET /auth/me`), avant que le router ne redirige vers l'écran
/// approprié. Ne contient aucune logique métier : c'est un simple écran de
/// transition (route initiale `AppRoutes.splash`).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDarkGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 140),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}
