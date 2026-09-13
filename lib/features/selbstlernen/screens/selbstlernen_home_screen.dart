// FILE: lib/features/selbstlernen/screens/selbstlernen_home_screen.dart
// DEPS: app_routes.dart
// PURPOSE: خانه Selbstlernen — ۴ بخش: Routine، Pomodoro، Lernpfad، Vorlagen
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_links.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/utils/external_link_opener.dart';

class SelbstlernenHomeScreen extends StatelessWidget {
  const SelbstlernenHomeScreen({super.key});

  static const _sections = [
    (
      title   : 'Routine',
      titleFa : 'routine',
      icon    : Icons.local_fire_department_rounded,
      color   : Color(0xFFE65100),
      desc    : 'routine_sub',
      // Externer Link zu Root-in (separates Projekt/Repo) statt interner Route —
      // leeres route = Signal für _SectionCard, extern zu öffnen (kein Code-Merge).
      route   : '',
    ),
    (
      title   : 'Pomodoro',
      titleFa : 'focus_timer',
      icon    : Icons.timer_rounded,
      color   : Color(0xFF6750A4),
      desc    : 'focus_timer_sub',
      route   : AppRoutes.pomodoro,
    ),
    (
      title   : 'Lernpfad',
      titleFa : 'learning_path',
      icon    : Icons.terrain_rounded,
      color   : Color(0xFF2E7D32),
      desc    : 'learning_path_sub',
      route   : AppRoutes.leitfaden,
    ),
    (
      title   : 'Vorlagen',
      titleFa : 'practice_templates',
      icon    : Icons.description_rounded,
      color   : Color(0xFF1565C0),
      desc    : 'practice_templates_sub',
      route   : AppRoutes.vorlagen,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selbstlernen')),
      body: ListView.separated(
        padding        : const EdgeInsets.all(AppSizes.md),
        itemCount      : _sections.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSizes.md),
        itemBuilder    : (_, i) {
          final s = _sections[i];
          return _SectionCard(
            title  : s.title,
            titleFa: AppL10n.t(context, s.titleFa),
            icon   : s.icon,
            color  : s.color,
            desc   : AppL10n.t(context, s.desc),
            onTap  : () => s.route.isEmpty
              ? openExternalLink(AppLinks.rootInUrl)
              : context.push(s.route),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.titleFa,
    required this.icon,
    required this.color,
    required this.desc,
    required this.onTap,
  });

  final String     title;
  final String     titleFa;
  final IconData   icon;
  final Color      color;
  final String     desc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin : Alignment.topLeft,
              end   : Alignment.bottomRight,
              colors: [
                color.withValues(alpha: isDark ? 0.4 : 0.85),
                color.withValues(alpha: isDark ? 0.2 : 0.6),
              ],
            ),
          ),
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Row(
            children: [
              Container(
                padding   : const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color       : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          color     : Colors.white,
                          fontSize  : 18,
                          fontWeight: FontWeight.w800,
                        )),
                    Text(titleFa,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(desc,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
