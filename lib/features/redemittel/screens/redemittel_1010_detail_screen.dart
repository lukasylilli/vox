// FILE: lib/features/redemittel/screens/redemittel_1010_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/vox_colors.dart';
import '../controllers/redemittel_controller.dart';
import '../models/redemittel_item.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/l10n/app_l10n.dart';

class Redemittel1010DetailScreen extends ConsumerWidget {
  const Redemittel1010DetailScreen({
    super.key,
    required this.phraseId,
    this.phrase,
  });

  final int             phraseId;
  final RedemittelItem? phrase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use passed phrase or look it up from provider
    final phraseAsync = phrase != null
        ? AsyncValue.data(phrase!)
        : ref.watch(redemittel1010Provider).whenData(
            (list) => list.firstWhere((p) => p.id == phraseId));

    return phraseAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error  : (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data   : (p) => _DetailView(phrase: p),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.phrase});
  final RedemittelItem phrase;

  static Color _registerColor(String r) => VoxColors.register(r);

  static String _registerLabel(String r) => switch (r) {
        'formal'     => 'Formell',
        'colloquial' => 'Umgangssprachlich',
        _            => 'Neutral',
      };

  static String _grammarLabel(String g) => switch (g) {
        'dass_satz'           => 'dass-Satz',
        'weil_satz'           => 'weil-Satz',
        'wenn_satz'           => 'wenn-Satz',
        'ob_satz'             => 'ob-Satz',
        'infinitiv_zu'        => 'Infinitiv mit zu',
        'hauptsatz_only'      => 'Hauptsatz',
        'w_frage_satz'        => 'W-Frage',
        'vollstaendiger_satz' => 'Vollständiger Satz',
        _                     => g,
      };

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final tt    = Theme.of(context).textTheme;
    final regCol= _registerColor(phrase.register);

    return Scaffold(
      appBar: AppBar(
        title: Text(phrase.sectionTitleDe,
            style: const TextStyle(fontSize: 15)),
        actions: [
          VoxIconButton(
            icon: Icons.quiz_rounded,
            tooltip  : AppL10n.t(context, 'quiz_of'),
            onPressed: () => context.push(
                AppRoutes.redemittel1010Quiz, extra: [phrase]),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // ── Badges row ─────────────────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _Badge(phrase.cefrLevel.toUpperCase(), cs.primaryContainer,
                  cs.onPrimaryContainer),
              _Badge(_registerLabel(phrase.register),
                  regCol.withValues(alpha: 0.15), regCol),
              if (phrase.grammarPattern.isNotEmpty)
                _Badge(_grammarLabel(phrase.grammarPattern),
                    cs.secondaryContainer, cs.onSecondaryContainer),
              if (phrase.topic.isNotEmpty)
                _Badge(phrase.topic, cs.tertiaryContainer,
                    cs.onTertiaryContainer),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // ── German phrase ───────────────────────────────────────────────────
          _Card(
            icon   : Icons.translate_rounded,
            color  : cs.primary,
            label  : 'Deutsch',
            content: phrase.phraseDe,
            style  : tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSizes.sm),

          // ── Übersetzung — nur aktive Zweitsprache (فاز L) ───────────────────
          _Card(
            icon   : Icons.language_rounded,
            color  : const Color(0xFF2E7D32),
            label  : AppL10n.isFa(context) ? 'فارسی' : 'English',
            content: AppL10n.meaning(context,
                fa: phrase.phraseFa,
                en: phrase.phraseEn.isNotEmpty
                    ? phrase.phraseEn
                    : phrase.phraseFa),
          ),
          const SizedBox(height: AppSizes.sm),

          // ── Grammar structure ────────────────────────────────────────────────
          if (phrase.structureAfter.isNotEmpty) ...[
            _Card(
              icon   : Icons.account_tree_rounded,
              color  : const Color(0xFF6A1B9A),
              label  : 'Struktur danach',
              content: phrase.structureAfter,
            ),
            const SizedBox(height: AppSizes.sm),
          ],

          // ── Example sentence ─────────────────────────────────────────────────
          if (phrase.exampleDe.isNotEmpty) ...[
            _ExampleCard(
              de: phrase.exampleDe,
              fa: phrase.exampleFa,
              en: phrase.exampleEn,
            ),
            const SizedBox(height: AppSizes.sm),
          ],

          // ── Note — aktive Sprache aus Settings (فاز L), EN-Fallback → FA ──
          if (phrase.note.isNotEmpty) ...[
            _Card(
              icon   : Icons.info_outline_rounded,
              color  : cs.secondary,
              label  : AppL10n.t(context, 'note_label'),
              content: AppL10n.meaning(context,
                  fa: phrase.note,
                  en: phrase.noteEn.isNotEmpty ? phrase.noteEn : phrase.note),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Badge ─────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.bg, this.fg);
  final String label;
  final Color  bg;
  final Color  fg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
      );
}

// ─── Content card ──────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({
    required this.icon,
    required this.color,
    required this.label,
    required this.content,
    this.style,
  });
  final IconData   icon;
  final Color      color;
  final String     label;
  final String     content;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 5),
                Text(label,
                    style: tt.labelSmall?.copyWith(
                        color: color, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            Text(content,
                style: style ??
                    tt.bodyMedium?.copyWith(
                        color: cs.onSurface, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

// ─── Example card ──────────────────────────────────────────────────────────────

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.de, required this.fa, required this.en});
  final String de;
  final String fa;
  final String en;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      color: cs.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.format_quote_rounded,
                    size: 14, color: cs.primary),
                const SizedBox(width: 5),
                Text(AppL10n.t(context, 'example'),
                    style: tt.labelSmall?.copyWith(
                        color: cs.primary, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            Text(de,
                style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600, height: 1.5)),
            const SizedBox(height: 4),
            // nur aktive Zweitsprache (فاز L)
            Text(
                AppL10n.meaning(context,
                    fa: fa, en: en.isNotEmpty ? en : fa),
                style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
