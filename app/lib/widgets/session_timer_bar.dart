import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';

/// Bandeau affiché sous la barre du haut de chaque dashboard : l'heure
/// actuelle et le temps passé sur l'application depuis son ouverture. Purement
/// informatif pour l'utilisateur (aucune donnée envoyée au serveur) ; à
/// placer dans `AppBar.bottom`.
class SessionTimerBar extends StatefulWidget implements PreferredSizeWidget {
  const SessionTimerBar({super.key});

  @override
  State<SessionTimerBar> createState() => _SessionTimerBarState();

  @override
  Size get preferredSize => const Size.fromHeight(28);
}

class _SessionTimerBarState extends State<SessionTimerBar> {
  final DateTime _debutSession = DateTime.now();
  late final Timer _timer;
  Duration _ecoule = Duration.zero;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _ecoule = DateTime.now().difference(_debutSession));
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _dureeFormatee {
    final heures = _ecoule.inHours;
    final minutes = _ecoule.inMinutes.remainder(60);
    final secondes = _ecoule.inSeconds.remainder(60);
    if (heures > 0) {
      return '${heures}h ${minutes.toString().padLeft(2, '0')}min';
    }
    if (minutes > 0) {
      return '$minutes min ${secondes.toString().padLeft(2, '0')}s';
    }
    return '$secondes s';
  }

  @override
  Widget build(BuildContext context) {
    final heureActuelle = DateFormat('HH:mm').format(DateTime.now());
    return Container(
      height: 28,
      color: AppColors.paleGold,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.access_time,
            size: 14,
            color: AppColors.primaryDarkGreen,
          ),
          const SizedBox(width: 6),
          Text(
            'Il est $heureActuelle — $_dureeFormatee sur l\'application',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDarkGreen,
            ),
          ),
        ],
      ),
    );
  }
}
