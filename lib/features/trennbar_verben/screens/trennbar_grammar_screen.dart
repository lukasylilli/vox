// FILE: lib/features/trennbar_verben/screens/trennbar_grammar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart' show AppL10n;
import '../controllers/trennbar_controller.dart';

/// فاز L3: liest `<base>_en` im EN-Modus, Fallback auf `<base>_fa`.
String _loc(BuildContext context, Map<String, dynamic> m, String base) =>
    AppL10n.isFa(context)
        ? (m['${base}_fa'] as String? ?? '')
        : (m['${base}_en'] as String? ?? m['${base}_fa'] as String? ?? '');


class TrennbarGrammarScreen extends ConsumerWidget {
  const TrennbarGrammarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grammarAsync = ref.watch(trennbarGrammarProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.t(context, 'view_grammar'))),
      body: grammarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('$e')),
        data   : (g) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            // ── Overview card ──────────────────────────────────────────────
            _GrammarCard(
              icon : Icons.call_split_rounded,
              title: _loc(context, g, 'title'),
              child: Text(
                _loc(context, g, 'overview'),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.8),
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            // ── Categories (trennbar / untrennbar / wechselpraefix) ────────
            _GrammarCard(
              icon : Icons.category_rounded,
              title: AppL10n.t(context, 'verb_categories'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final cat
                      in (g['categories'] as List).cast<Map<String, dynamic>>()) ...[
                    _CategoryBlock(cat),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            // ── Grammar rules ─────────────────────────────────────────────
            for (final rule
                in (g['grammar_rules'] as List)
                    .cast<Map<String, dynamic>>()) ...[
              _GrammarCard(
                icon : _iconForRule(rule['rule_id'] as String? ?? ''),
                title: _loc(context, rule, 'title'),
                child: _RuleContent(rule),
              ),
              const SizedBox(height: AppSizes.sm),
            ],

            // ── Prefix meaning table ──────────────────────────────────────
            _GrammarCard(
              icon : Icons.table_chart_rounded,
              title: AppL10n.t(context, 'prefix_table_title'),
              child: _PrefixTable(
                  (g['prefix_meaning_table'] as List)
                      .cast<Map<String, dynamic>>()),
            ),
            const SizedBox(height: AppSizes.sm),

            // ── Tips ──────────────────────────────────────────────────────
            _GrammarCard(
              icon : Icons.lightbulb_outline_rounded,
              title: AppL10n.t(context, 'key_tips'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final tip in ((AppL10n.isFa(context) ? g['tips_fa'] : (g['tips_en'] ?? g['tips_fa'])) as List).cast<String>())
                    _TipRow(tip),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForRule(String id) => switch (id) {
        'main_clause_word_order'      => Icons.sort_rounded,
        'subordinate_clause_position' => Icons.account_tree_rounded,
        'partizip_ii_formation'       => Icons.access_time_rounded,
        'infinitive_with_zu'          => Icons.link_rounded,
        _                             => Icons.info_outline_rounded,
      };
}

// ─── Category block ───────────────────────────────────────────────────────────

class _CategoryBlock extends StatelessWidget {
  const _CategoryBlock(this.cat);
  final Map<String, dynamic> cat;

  static Color _typeColor(String type) => switch (type) {
        'trennbar'       => const Color(0xFF0277BD),
        'untrennbar'     => const Color(0xFF2E7D32),
        'wechselpraefix' => const Color(0xFFBF360C),
        _                => const Color(0xFF455A64),
      };

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final type  = cat['type']           as String? ?? '';
    final title = _loc(context, cat, 'title');
    final expl  = _loc(context, cat, 'explanation');
    final color = _typeColor(type);

    final prefixes = cat.containsKey('common_prefixes')
        ? (cat['common_prefixes'] as List).cast<String>()
        : <String>[];
    final exNoteRaw = _loc(context, cat, 'exception_note');
    final exNote = exNoteRaw.isEmpty ? null : exNoteRaw;
    final pairs  = cat.containsKey('example_pairs')
        ? (cat['example_pairs'] as List).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color     : color,
                  fontSize  : 13)),
          if (expl.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(expl,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(height: 1.6)),
          ],
          if (prefixes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing  : 6,
              runSpacing: 4,
              children : prefixes
                  .map((p) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color       : color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(p,
                            style: TextStyle(
                                fontSize  : 11,
                                color     : color,
                                fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
            ),
          ],
          if (exNote != null && exNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            _NoteBox(exNote),
          ],
          ...pairs.map((p) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: _ExPair(p, cs),
              )),
        ],
      ),
    );
  }
}

class _ExPair extends StatelessWidget {
  const _ExPair(this.p, this.cs);
  final Map<String, dynamic> p;
  final ColorScheme           cs;

  @override
  Widget build(BuildContext context) {
    final verb  = (p['verb_separable'] as String? ?? '').split(' ').first;
    final trDe  = p['verb_separable']   as String? ?? '';
    final unDe  = p['verb_inseparable'] as String? ?? '';
    final trFa  = _loc(context, p, 'meaning_separable');
    final unFa  = _loc(context, p, 'meaning_inseparable');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(verb,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        if (trDe.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text('+ $trDe',
              style: TextStyle(
                  fontSize : 11,
                  fontStyle: FontStyle.italic,
                  color    : cs.primary)),
          if (trFa.isNotEmpty)
            Text(trFa,
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
        ],
        if (unDe.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text('- $unDe',
              style: TextStyle(
                  fontSize : 11,
                  fontStyle: FontStyle.italic,
                  color    : cs.secondary)),
          if (unFa.isNotEmpty)
            Text(unFa,
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
        ],
      ],
    );
  }
}

// ─── Rule content ─────────────────────────────────────────────────────────────

class _RuleContent extends StatelessWidget {
  const _RuleContent(this.rule);
  final Map<String, dynamic> rule;

  @override
  Widget build(BuildContext context) {
    final expl = _loc(context, rule, 'explanation');
    final examples = rule.containsKey('examples')
        ? (rule['examples'] as List).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (expl.isNotEmpty)
          Text(expl,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.8)),
        ...examples.map((e) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _ExRow(e),
            )),
      ],
    );
  }
}

// ─── Prefix table ──────────────────────────────────────────────────────────────

class _PrefixTable extends StatelessWidget {
  const _PrefixTable(this.entries);
  final List<Map<String, dynamic>> entries;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Table(
      border: TableBorder.all(
          color : cs.outlineVariant,
          width : 0.8,
          borderRadius: BorderRadius.circular(6)),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(1.4),
        1: FlexColumnWidth(2.5),
        2: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.4)),
          children: [
            _TCell(AppL10n.t(context, 'prefix_label'), header: true),
            _TCell(AppL10n.t(context, 'meaning'), header: true),
            _TCell(AppL10n.t(context, 'example'), header: true),
          ],
        ),
        for (final e in entries)
          TableRow(
            children: [
              _TypedPrefixCell(
                  e['prefix'] as String? ?? '',
                  e['type'] as String? ?? ''),
              _TCell(_loc(context, e, 'meaning')),
              _TCell(e['example_de'] as String? ?? '',
                  italic: true),
            ],
          ),
      ],
    );
  }
}

class _TCell extends StatelessWidget {
  const _TCell(this.text, {this.header = false, this.italic = false});
  final String text;
  final bool   header;
  final bool   italic;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(6),
        child: Text(
          text,
          style: TextStyle(
            fontSize  : header ? 11 : 11,
            fontWeight: header ? FontWeight.w700 : FontWeight.normal,
            fontStyle : italic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      );
}

class _TypedPrefixCell extends StatelessWidget {
  const _TypedPrefixCell(this.prefix, this.type);
  final String prefix;
  final String type;

  static Color _color(String t) => switch (t) {
        'trennbar'       => const Color(0xFF0277BD),
        'untrennbar'     => const Color(0xFF2E7D32),
        'wechselpraefix' => const Color(0xFFBF360C),
        _                => const Color(0xFF455A64),
      };

  @override
  Widget build(BuildContext context) {
    final color = _color(type);
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(
        prefix,
        style: TextStyle(
          fontSize  : 12,
          fontWeight: FontWeight.w700,
          color     : color,
        ),
      ),
    );
  }
}

// ─── Shared card ──────────────────────────────────────────────────────────────

class _GrammarCard extends StatelessWidget {
  const _GrammarCard(
      {required this.icon, required this.title, required this.child});
  final IconData icon;
  final String   title;
  final Widget   child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

// ─── Note box ─────────────────────────────────────────────────────────────────

class _NoteBox extends StatelessWidget {
  const _NoteBox(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.tertiary.withValues(alpha: 0.3)),
      ),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(height: 1.6)),
    );
  }
}

// ─── Tip row ──────────────────────────────────────────────────────────────────

class _TipRow extends StatelessWidget {
  const _TipRow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(height: 1.6)),
          ),
        ],
      ),
    );
  }
}

// ─── Example row ──────────────────────────────────────────────────────────────

class _ExRow extends StatelessWidget {
  const _ExRow(this.e);
  final Map<String, dynamic> e;

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final de     = e['de'] as String? ?? '';
    final transl = AppL10n.isFa(context)
        ? (e['fa'] as String? ?? '')
        : (e['en'] as String? ?? e['fa'] as String? ?? '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(de,
              style: const TextStyle(
                  fontStyle: FontStyle.italic, fontSize: 13)),
          if (transl.isNotEmpty)
            Text(transl,
                style: TextStyle(
                    fontSize: 12, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
