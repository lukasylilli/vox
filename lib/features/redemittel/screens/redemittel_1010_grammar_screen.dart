// FILE: lib/features/redemittel/screens/redemittel_1010_grammar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../controllers/redemittel_controller.dart';
import '../models/redemittel_item.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/deutsch_text.dart';

class Redemittel1010GrammarScreen extends ConsumerWidget {
  const Redemittel1010GrammarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(redemittel1010Provider);
    return Scaffold(
      appBar: AppBar(title: const Text('Redemittel — Grammatikmuster')),
      body: allAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
        data   : (phrases) => _GrammarBody(phrases: phrases),
      ),
    );
  }
}

// ─── Main body ─────────────────────────────────────────────────────────────────

class _GrammarBody extends StatelessWidget {
  const _GrammarBody({required this.phrases});
  final List<RedemittelItem> phrases;

  static const _patternMeta = <String, (String, String, String, String, String, Color)>{
    'dass_satz': (
      'dass-Satz',
      'جمله با «dass»',
      'dass-clause',
      'فعل اصلی به انتهای جمله می‌رود:\n'
          'Ich bin der Meinung, DASS das Rauchen verboten sein SOLLTE.',
      'The main verb moves to the end of the clause:\n'
          'Ich bin der Meinung, DASS das Rauchen verboten sein SOLLTE.',
      Color(0xFF1565C0),
    ),
    'weil_satz': (
      'weil-Satz',
      'جمله با «weil»',
      'weil-clause',
      'دلیل می‌آورد، فعل اصلی به انتهای جمله:\n'
          'Ich stimme zu, WEIL die Lösung effektiv IST.',
      'Gives a reason, main verb at the end of the clause:\n'
          'Ich stimme zu, WEIL die Lösung effektiv IST.',
      Color(0xFF2E7D32),
    ),
    'wenn_satz': (
      'wenn-Satz',
      'جمله با «wenn»',
      'wenn-clause',
      'شرط را بیان می‌کند:\n'
          'WENN man bedenkt, dass … dann …',
      'Expresses a condition:\n'
          'WENN man bedenkt, dass … dann …',
      Color(0xFF00838F),
    ),
    'ob_satz': (
      'ob-Satz',
      'جمله با «ob»',
      'ob-clause',
      'سوال غیرمستقیم:\n'
          'Ich frage mich, OB diese Lösung sinnvoll IST.',
      'Indirect question:\n'
          'Ich frage mich, OB diese Lösung sinnvoll IST.',
      Color(0xFF6A1B9A),
    ),
    'infinitiv_zu': (
      'Infinitiv mit zu',
      'مصدر با «zu»',
      'Infinitive with zu',
      'فعل اصلی + zu + مصدر:\n'
          'Es ist wichtig, die Umwelt ZU SCHÜTZEN.',
      'Main verb + zu + infinitive:\n'
          'Es ist wichtig, die Umwelt ZU SCHÜTZEN.',
      Color(0xFFBF360C),
    ),
    'hauptsatz_only': (
      'Hauptsatz',
      'جمله اصلی',
      'Main clause',
      'ساختار ساده، فعل در مکان دوم:\n'
          'Das ist meiner Meinung nach richtig.',
      'Simple structure, verb in second position:\n'
          'Das ist meiner Meinung nach richtig.',
      Color(0xFF455A64),
    ),
    'w_frage_satz': (
      'W-Frage-Satz',
      'جمله پرسشی با W',
      'W-question clause',
      'سوال غیرمستقیم با Wie، Was، Warum …:\n'
          'Ich möchte wissen, WIE das Problem gelöst werden KANN.',
      'Indirect question with Wie, Was, Warum …:\n'
          'Ich möchte wissen, WIE das Problem gelöst werden KANN.',
      Color(0xFF880E4F),
    ),
    'vollstaendiger_satz': (
      'Vollständiger Satz',
      'جمله کامل',
      'Full sentence',
      'ساختار کامل جمله، مناسب نوشتار رسمی:\n'
          'In Anbetracht der Tatsache, dass … möchte ich festhalten, dass …',
      'A complete sentence structure, suited to formal writing:\n'
          'In Anbetracht der Tatsache, dass … möchte ich festhalten, dass …',
      Color(0xFF0277BD),
    ),
    'ob_satz_indirekt': (
      'ob-Satz (indirekt)',
      'سوال غیرمستقیم',
      'ob-clause (indirect)',
      'Ich bin nicht sicher, OB …',
      'Ich bin nicht sicher, OB …',
      Color(0xFF558B2F),
    ),
    'doppelpunkt_aufzaehlung': (
      'Doppelpunkt + Aufzählung',
      'دونقطه و فهرست',
      'Colon + list',
      'برای لیست کردن نکات:\n'
          'Es gibt mehrere Gründe: erstens …, zweitens …',
      'For listing points:\n'
          'Es gibt mehrere Gründe: erstens …, zweitens …',
      Color(0xFF37474F),
    ),
    'frage_direkt': (
      'Direkte Frage',
      'سوال مستقیم',
      'Direct question',
      'سوال مستقیم، فعل کمکی در ابتدا:\n'
          'Können Sie mir bitte helfen?',
      'A direct question, auxiliary verb first:\n'
          'Können Sie mir bitte helfen?',
      Color(0xFF00695C),
    ),
  };

  @override
  Widget build(BuildContext context) {
    // Group phrases by grammar pattern, count occurrences
    final counts = <String, int>{};
    final examples = <String, List<RedemittelItem>>{};
    for (final p in phrases) {
      final pat = p.grammarPattern;
      if (pat.isEmpty) { continue; }
      counts[pat] = (counts[pat] ?? 0) + 1;
      examples.putIfAbsent(pat, () => []).add(p);
    }

    // Sort by frequency descending
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.xl),
      children: [
        // ── Intro ────────────────────────────────────────────────────────────
        _IntroCard(),
        const SizedBox(height: AppSizes.md),

        // ── Pattern cards ─────────────────────────────────────────────────────
        ...sorted.map((entry) {
          final pat  = entry.key;
          final meta = _patternMeta[pat];
          final color = meta?.$6 ?? const Color(0xFF455A64);
          final labelDe = meta?.$1 ?? pat;
          final labelFa = AppL10n.meaning(context,
              fa: meta?.$2 ?? pat, en: meta?.$3 ?? pat);
          final explanation = AppL10n.meaning(context,
              fa: meta?.$4 ?? '', en: meta?.$5 ?? '');
          final exs  = examples[pat] ?? [];

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: _PatternCard(
              patternKey : pat,
              labelDe    : labelDe,
              labelFa    : labelFa,
              explanation: explanation,
              color      : color,
              count      : entry.value,
              examples   : exs.take(3).toList(),
            ),
          );
        }),

        const SizedBox(height: AppSizes.md),

        // ── Register overview ─────────────────────────────────────────────────
        _RegisterOverview(phrases: phrases),
      ],
    );
  }
}

// ─── Intro card ────────────────────────────────────────────────────────────────

class _IntroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: cs.onPrimaryContainer, size: 18),
                const SizedBox(width: 8),
                Text(
                  AppL10n.t(context, 'redemittel_patterns'),
                  style: tt.titleSmall?.copyWith(
                      color     : cs.onPrimaryContainer,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppL10n.t(context, 'redemittel_intro'),
              style: tt.bodySmall
                  ?.copyWith(color: cs.onPrimaryContainer, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pattern card ──────────────────────────────────────────────────────────────

class _PatternCard extends StatefulWidget {
  const _PatternCard({
    required this.patternKey,
    required this.labelDe,
    required this.labelFa,
    required this.explanation,
    required this.color,
    required this.count,
    required this.examples,
  });

  final String             patternKey;
  final String             labelDe;
  final String             labelFa;
  final String             explanation;
  final Color              color;
  final int                count;
  final List<RedemittelItem> examples;

  @override
  State<_PatternCard> createState() => _PatternCardState();
}

class _PatternCardState extends State<_PatternCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Column(
        children: [
          // ── header ─────────────────────────────────────────────────────────
          InkWell(
            onTap       : () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: Row(
                children: [
                  Container(
                    width : 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color       : widget.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        widget.labelDe.substring(0, 1),
                        style: TextStyle(
                          fontSize  : 20,
                          fontWeight: FontWeight.w900,
                          color     : widget.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DeutschText(widget.labelDe,
                            style: tt.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700)),
                        Text(widget.labelFa,
                            style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color       : widget.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.count}',
                      style: TextStyle(
                          fontSize  : 12,
                          fontWeight: FontWeight.w700,
                          color     : widget.color),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: cs.onSurfaceVariant,
                    size : 20,
                  ),
                ],
              ),
            ),
          ),

          // ── expanded content ────────────────────────────────────────────────
          if (_expanded) ...[
            Divider(height: 1, color: cs.outlineVariant),
            Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // explanation
                  if (widget.explanation.isNotEmpty) ...[
                    Container(
                      width     : double.infinity,
                      padding   : const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        color       : widget.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.explanation,
                        style: tt.bodySmall?.copyWith(
                            height: 1.6, fontFamily: 'monospace'),
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                  ],
                  // examples
                  if (widget.examples.isNotEmpty) ...[
                    Text(AppL10n.t(context, 'samples_label'),
                        style: tt.labelSmall?.copyWith(
                            color     : widget.color,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    ...widget.examples.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: _ExampleRow(phrase: p, color: widget.color),
                        )),
                    // link to filtered list
                    Align(
                      alignment: Alignment.centerRight,
                      child: VoxButton.text(
                        label    : AppL10n.tf(context, 'view_all_n_phrases', {'n': '${widget.count}'}),
                        icon     : Icons.arrow_forward_rounded,
                        size     : VoxButtonSize.small,
                        onPressed: () => context.push(
                          AppRoutes.redemittel1010,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Example row ───────────────────────────────────────────────────────────────

class _ExampleRow extends StatelessWidget {
  const _ExampleRow({required this.phrase, required this.color});
  final RedemittelItem phrase;
  final Color          color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color       : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeutschText(phrase.phraseDe,
              style: tt.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          // aktive Sprache aus Settings (فاز L), EN-Fallback → FA
          Text(
              AppL10n.meaning(context,
                  fa: phrase.phraseFa,
                  en: phrase.phraseEn.isNotEmpty
                      ? phrase.phraseEn
                      : phrase.phraseFa),
              style: tt.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ─── Register overview ─────────────────────────────────────────────────────────

class _RegisterOverview extends StatelessWidget {
  const _RegisterOverview({required this.phrases});
  final List<RedemittelItem> phrases;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final counts = <String, int>{};
    for (final p in phrases) {
      final r = p.register.isEmpty ? 'neutral' : p.register;
      counts[r] = (counts[r] ?? 0) + 1;
    }
    final total = phrases.length;

    final regs = [
      ('formal',     'Formell',           const Color(0xFF1565C0)),
      ('neutral',    'Neutral',           const Color(0xFF455A64)),
      ('colloquial', 'Umgangssprachlich', const Color(0xFF2E7D32)),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune_rounded, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Text(AppL10n.t(context, 'register_formality'),
                    style: tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            ...regs.map((r) {
              final (key, label, color) = r;
              final cnt = counts[key] ?? 0;
              final pct = total == 0 ? 0.0 : cnt / total;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width : 10, height: 10,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(label,
                            style: tt.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text('$cnt',
                            style: tt.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value          : pct,
                        minHeight      : 6,
                        backgroundColor: color.withValues(alpha: 0.1),
                        valueColor     : AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
