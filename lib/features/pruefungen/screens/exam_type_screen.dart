// FILE: lib/features/pruefungen/screens/exam_type_screen.dart
// DEPS: pruefungen_controller.dart
// PURPOSE: سطوح موجود برای یک سازمان + راهنمای آمادگی
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/pruefungen_controller.dart';
import '../../../core/widgets/vox_button.dart';

class ExamTypeScreen extends ConsumerWidget {
  const ExamTypeScreen({super.key, required this.orgKey});
  final String orgKey;

  ExamOrg get _org => ExamOrg.values.firstWhere(
        (e) => e.key == orgKey,
        orElse: () => ExamOrg.goethe,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final org         = _org;
    final countsAsync = ref.watch(examLevelCountsProvider(orgKey));
    final theme       = Theme.of(context);
    final scheme      = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(org.displayName)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // Prep guide
          _PrepGuide(org: org),
          const SizedBox(height: AppSizes.lg),

          Text(AppL10n.t(context, 'select_exam_level'),
              style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),

          countsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error  : (_, _) => const SizedBox.shrink(),
            data   : (counts) => Column(
              children: org.levels.map((level) {
                final count = counts[level] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        child: Text(level,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color     : scheme.onPrimaryContainer,
                              fontSize  : 13,
                            )),
                      ),
                      title: Text(
                        '${org.shortName} $level',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        count == 0
                            ? AppL10n.t(context, 'content_from_phase12')
                            : AppL10n.tf(context, 'n_questions_ready', {'n': '$count'}),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (count > 0) ...[
                            VoxIconButton(
                              icon: Icons.play_arrow_rounded,
                              tooltip: AppL10n.t(context, 'start_quiz'),
                              onPressed: () => context.push(
                                '/pruefungen/$orgKey/$level/simulation',
                              ),
                            ),
                          ],
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                      onTap: count > 0
                          ? () => context.push(
                                '/pruefungen/$orgKey/$level/simulation',
                              )
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrepGuide extends StatelessWidget {
  const _PrepGuide({required this.org});
  final ExamOrg org;

  @override
  Widget build(BuildContext context) {
    final tips = switch (org) {
      ExamOrg.goethe => [
          AppL10n.t(context, 'exam_goethe_i1'),
          AppL10n.t(context, 'exam_goethe_i2'),
          AppL10n.t(context, 'exam_goethe_i3'),
        ],
      ExamOrg.telc => [
          AppL10n.t(context, 'exam_telc_i1'),
          AppL10n.t(context, 'exam_telc_i2'),
          AppL10n.t(context, 'exam_telc_i3'),
        ],
      ExamOrg.oesd => [
          AppL10n.t(context, 'exam_oesd_i1'),
          AppL10n.t(context, 'exam_oesd_i2'),
          AppL10n.t(context, 'exam_oesd_i3'),
        ],
    };

    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding   : const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color       : scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  color: scheme.onSecondaryContainer, size: 18),
              const SizedBox(width: 6),
              Text(AppL10n.t(context, 'prep_guide'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color     : scheme.onSecondaryContainer,
                  )),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child  : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: TextStyle(color: scheme.onSecondaryContainer)),
                    Expanded(
                      child: Text(t,
                          style: TextStyle(
                            color  : scheme.onSecondaryContainer,
                            fontSize: 13,
                          )),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
