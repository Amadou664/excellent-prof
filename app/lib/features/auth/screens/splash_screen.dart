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
            const Icon(Icons.school, color: AppColors.gold, size: 72),
            const SizedBox(height: 16),
            const Text(
              "L'Excellent Prof",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}
