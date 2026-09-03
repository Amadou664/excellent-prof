import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Bouton principal réutilisé dans toute l'app, avec état de chargement
/// intégré (évite de dupliquer un `CircularProgressIndicator` partout).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final button = outlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: isLoading
                ? ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen.withValues(
                      alpha: 0.7,
                    ),
                  )
                : null,
            child: child,
          );

    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
