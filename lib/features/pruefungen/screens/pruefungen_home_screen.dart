// FILE: lib/features/pruefungen/screens/pruefungen_home_screen.dart
// DEPS: pruefungen_controller.dart
// PURPOSE: خانه آزمون‌ها — ۳ سازمان (Goethe، telc، ÖSD) با card
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/pruefungen_controller.dart';

class PruefungenHomeScreen extends StatelessWidget {
  const PruefungenHomeScreen({super.key});

  static const _cards = [
    (org: ExamOrg.goethe, color: Color(0xFF1565C0),
     icon: Icons.school_rounded,
     desc: 'exam_goethe_sub'),
    (org: ExamOrg.telc, color: Color(0xFF2E7D32),
     icon: Icons.verified_rounded,
     desc: 'exam_telc_sub'),
    (org: ExamOrg.oesd, color: Color(0xFF6A1B9A),
     icon: Icons.flag_rounded,
     desc: 'exam_oesd_sub'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Prüfungen')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // Info banner
          Container(
            padding   : const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color       : theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: theme.colorScheme.onTertiaryContainer),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    AppL10n.t(context, 'pruefungen_tagline'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.lg),
          Text(AppL10n.t(context, 'select_exam_org'),
              style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),

          ..._cards.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.md),
                child  : _OrgCard(
                  org  : c.org,
                  color: c.color,
                  icon : c.icon,
                  desc : AppL10n.t(context, c.desc),
                  onTap: () => context.push('/pruefungen/${c.org.key}'),
                ),
              )),

          const SizedBox(height: AppSizes.sm),
          const Divider(),
          const SizedBox(height: AppSizes.sm),

          Text(AppL10n.t(context, 'topic_practice'), style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),

          ..._topicQuizzes.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child  : _TopicQuizTile(
                  icon   : t.icon,
                  color  : t.color,
                  titleDe: t.titleDe,
                  titleFa: AppL10n.t(context, t.titleFa),
                  onTap  : () => context.push(t.route),
                ),
              )),
        ],
      ),
    );
  }

  static const _topicQuizzes = [
    (
      icon   : Icons.link_rounded,
      color  : Color(0xFF0277BD),
      titleDe: 'Konnektoren',
      titleFa: 'topic_konnektoren_sub',
      route  : AppRoutes.konnektorenQuiz,
    ),
    (
      icon   : Icons.swap_horiz_rounded,
      color  : Color(0xFF2E7D32),
      titleDe: 'Dativ / Akkusativ Verben',
      titleFa: 'deck_dativ',
      route  : AppRoutes.dativVerbenQuiz,
    ),
    (
      icon   : Icons.grid_view_rounded,
      color  : Color(0xFF00838F),
      titleDe: 'Nomen-Verb-Verbindungen',
      titleFa: 'topic_nvv_sub',
      route  : AppRoutes.nvvQuiz,
    ),
    (
      icon   : Icons.account_tree_rounded,
      color  : Color(0xFF6A1B9A),
      titleDe: 'Präpositionen',
      titleFa: 'topic_praep_sub',
      route  : AppRoutes.praepositonenQuiz,
    ),
  ];
}

class _OrgCard extends StatelessWidget {
  const _OrgCard({
    required this.org,
    required this.color,
    required this.icon,
    required this.desc,
    required this.onTap,
  });

  final ExamOrg      org;
  final Color        color;
  final IconData     icon;
  final String       desc;
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
                color.withValues(alpha: isDark ? 0.5 : 0.85),
                color.withValues(alpha: isDark ? 0.3 : 0.6),
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
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(org.displayName,
                        style: const TextStyle(
                          color     : Colors.white,
                          fontSize  : 18,
                          fontWeight: FontWeight.w800,
                        )),
                    const SizedBox(height: 4),
                    Text(desc,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: org.levels
                          .map((l) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(l,
                                    style: const TextStyle(
                                      color    : Colors.white,
                                      fontSize : 11,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ))
                          .toList(),
                    ),
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

// ─── topic quiz tile ──────────────────────────────────────────────────────────

class _TopicQuizTile extends StatelessWidget {
  const _TopicQuizTile({
    required this.icon,
    required this.color,
    required this.titleDe,
    required this.titleFa,
    required this.onTap,
  });

  final IconData     icon;
  final Color        color;
  final String       titleDe;
  final String       titleFa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child : ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title   : Text(titleDe,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(titleFa),
        trailing: const Icon(Icons.play_arrow_rounded),
        onTap   : onTap,
        shape   : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
