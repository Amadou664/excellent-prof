import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Bandeau d'erreur inline réutilisé dans les formulaires (au-dessus des
/// champs), pour signaler une erreur API/Firebase sans bloquer l'écran.
class InlineErrorBanner extends StatelessWidget {
  const InlineErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
