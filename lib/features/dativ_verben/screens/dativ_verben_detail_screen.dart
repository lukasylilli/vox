// FILE: lib/features/dativ_verben/screens/dativ_verben_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_l10n.dart';
import '../controllers/dativ_verben_controller.dart';
import '../models/dativ_verb.dart';
import '../widgets/case_highlight_text.dart';
import '../widgets/case_type_badge.dart';
import '../widgets/principal_parts_table.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/widgets/deutsch_text.dart';

class DativVerbenDetailScreen extends ConsumerStatefulWidget {
  const DativVerbenDetailScreen({super.key, required this.verbId});

  final int verbId;

  @override
  ConsumerState<DativVerbenDetailScreen> createState() =>
      _DativVerbenDetailScreenState();
}

class _DativVerbenDetailScreenState
    extends ConsumerState<DativVerbenDetailScreen> {

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(dativVerbenProvider);

    return allAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (verbs) {
        final idx  = verbs.indexWhere((v) => v.id == widget.verbId);
        if (idx == -1) return Scaffold(body: Center(child: Text(AppL10n.t(context, 'not_found'))));
        final verb = verbs[idx];

        return Scaffold(
          appBar: AppBar(
            title: DeutschText(ganzeZeile: false, verb.verbInfinitive),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            children: [
              // ── header badges ──
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  CaseTypeBadge(verb.caseType),
                  _LevelBadge(verb.cefrLevel),
                  _RegisterBadge(verb.register),
                  if (verb.separable) _Chip('trennbar', Colors.teal),
                  if (verb.reflexive) _Chip('reflexiv', Colors.deepPurple),
                ],
              ),
              const SizedBox(height: 16),

              // ── principal parts ──
              PrincipalPartsTable(verb.principalParts),
              const SizedBox(height: 16),

              // ── meaning ──
              _Section(
                title: AppL10n.t(context, 'meaning'),
                child: Text(
                  AppL10n.meaning(context, fa: verb.meaningFa, en: verb.meaningEn),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height    : 1.6,
                      ),
                ),
              ),
              const SizedBox(height: 12),

              // ── example with Dativ/Akkusativ highlight ──
              _Section(
                title: AppL10n.t(context, 'example'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CaseHighlightText(
                      sentence : verb.exampleDe,
                      caseType : verb.caseType,
                      caseRoles: verb.caseRoles,
                      style    : Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            height    : 1.6,
                          ),
                    ),
                    if (verb.caseType == CaseType.dativAkkusativ)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            _ColorDot(const Color(0xFF1565C0)),
                            const SizedBox(width: 4),
                            const Text('Dativ', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 12),
                            _ColorDot(const Color(0xFF6A1B9A)),
                            const SizedBox(width: 4),
                            const Text('Akkusativ', style: TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      AppL10n.meaning(context, fa: verb.exampleFa, en: verb.exampleEn),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color : Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                    ),
                  ],
                ),
              ),

              // ── note — aktive Sprache aus Settings (فاز L), EN-Fallback → FA ──
              if (verb.note.isNotEmpty) ...[
                const SizedBox(height: 12),
                _NoteCard(AppL10n.meaning(context,
                    fa: verb.note,
                    en: verb.noteEn.isNotEmpty ? verb.noteEn : verb.note)),
              ],

              // ── dativ rule info ──
              const SizedBox(height: 12),
              _CaseInfoCard(verb.caseType),

              // ── navigation ──
              const SizedBox(height: 20),
              _NavRow(verbs: verbs, currentIdx: idx),
            ],
          ),
        );
      },
    );
  }
}

// ─── small widgets ────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
              fontSize  : 11,
              fontWeight: FontWeight.w700,
              color     : cs.onSurfaceVariant,
              letterSpacing: 0.5,
            )),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge(this.level);

  final String level;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color       : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(level,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      );
}

class _RegisterBadge extends StatelessWidget {
  const _RegisterBadge(this.register);

  final String register;

  static const _label = {
    'neutral'   : 'register_neutral',
    'formal'    : 'register_formal',
    'colloquial': 'register_colloquial',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color       : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(AppL10n.t(context, _label[register] ?? register),
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.color);

  final String label;
  final Color  color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color       : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border      : Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      );
}

class _NoteCard extends StatelessWidget {
  const _NoteCard(this.note);

  final String note;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color       : cs.tertiaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border      : Border.all(color: cs.tertiary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, size: 16, color: cs.tertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(note,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.7,
                    )),
          ),
        ],
      ),
    );
  }
}

class _CaseInfoCard extends StatelessWidget {
  const _CaseInfoCard(this.caseType);

  final CaseType caseType;

  @override
  Widget build(BuildContext context) {
    final color = CaseTypeBadge.colorFor(caseType, context);
    final text  = switch (caseType) {
      CaseType.datumOnly =>
        AppL10n.t(context, 'case_hint_dativ'),
      CaseType.dativAkkusativ =>
        AppL10n.t(context, 'case_hint_both'),
      CaseType.akkusativOnlyConfusable =>
        AppL10n.t(context, 'case_hint_akk'),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color       : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border      : Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.7,
                      color : color.withValues(alpha: 0.85),
                    )),
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.verbs, required this.currentIdx});

  final List<DativVerb> verbs;
  final int             currentIdx;

  @override
  Widget build(BuildContext context) {
    final hasPrev = currentIdx > 0;
    final hasNext = currentIdx < verbs.length - 1;

    return Row(
      children: [
        Expanded(
          child: hasPrev
              ? VoxButton.secondary(
                  label    : verbs[currentIdx - 1].verbInfinitive,
                  icon     : Icons.arrow_back_rounded,
                  onPressed: () => _go(context, verbs[currentIdx - 1].id),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: hasNext
              ? VoxButton.primary(
                  label    : verbs[currentIdx + 1].verbInfinitive,
                  icon     : Icons.arrow_forward_rounded,
                  onPressed: () => _go(context, verbs[currentIdx + 1].id),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _go(BuildContext context, int id) {
    // Replace so back-stack doesn't pile up
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DativVerbenDetailScreen(verbId: id),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width : 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
