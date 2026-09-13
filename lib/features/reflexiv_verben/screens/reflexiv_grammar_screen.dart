// FILE: lib/features/reflexiv_verben/screens/reflexiv_grammar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart' show AppL10n;
import '../controllers/reflexiv_controller.dart';

class ReflexivGrammarScreen extends ConsumerWidget {
  const ReflexivGrammarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grammarAsync = ref.watch(reflexivGrammarProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.t(context, 'view_grammar'))),
      body: grammarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (g) {
          final sections =
              (g['sections'] as List).cast<Map<String, dynamic>>();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              _GrammarCard(
                icon: Icons.menu_book_rounded,
                title: AppL10n.loc(context, g, 'title'),
                child: Text(
                  AppL10n.loc(context, g, 'summary'),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.8),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              ...sections.map((s) => _SectionWidget(s)),
            ],
          );
        },
      ),
    );
  }
}

// ─── Section dispatcher ───────────────────────────────────────────────────────

class _SectionWidget extends StatelessWidget {
  const _SectionWidget(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final id    = s['section_id'] as String? ?? '';
    final title = AppL10n.loc(context, s, 'title');
    final expl  = AppL10n.loc(context, s, 'explanation');

    final children = <Widget>[];

    if (expl.isNotEmpty) {
      children.add(Text(expl,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(height: 1.8)));
    }

    // ── Pronoun table ───────────────────────────────────────────────────────
    if (s.containsKey('table')) {
      final tbl     = s['table'] as Map<String, dynamic>;
      final headers = (tbl['headers'] as List).cast<String>();
      final rows    = (tbl['rows'] as List)
          .map((r) => (r as List).cast<String>())
          .toList();
      if (children.isNotEmpty) children.add(const SizedBox(height: 12));
      children.add(_ProTable(headers: headers, rows: rows));
    }

    // ── note_fa ─────────────────────────────────────────────────────────────
    if (s.containsKey('note_fa')) {
      children.add(const SizedBox(height: 8));
      children.add(_NoteBox(AppL10n.loc(context, s, 'note')));
    }

    // ── important_note_fa ────────────────────────────────────────────────────
    if (s.containsKey('important_note_fa')) {
      children.add(const SizedBox(height: 8));
      children.add(_NoteBox(AppL10n.loc(context, s, 'important_note')));
    }

    // ── types ────────────────────────────────────────────────────────────────
    if (s.containsKey('types')) {
      final types = (s['types'] as List).cast<Map<String, dynamic>>();
      for (final t in types) {
        children.add(const SizedBox(height: 10));
        children.add(_TypeBlock(t));
      }
    }

    // ── comparison_pairs ─────────────────────────────────────────────────────
    if (s.containsKey('comparison_pairs')) {
      final pairs =
          (s['comparison_pairs'] as List).cast<Map<String, dynamic>>();
      for (final p in pairs) {
        children.add(const SizedBox(height: 10));
        children.add(_ComparisonPair(p));
      }
    }

    // ── groups (prepositions) ─────────────────────────────────────────────
    if (s.containsKey('groups')) {
      final groups = (s['groups'] as List).cast<Map<String, dynamic>>();
      for (final g in groups) {
        children.add(const SizedBox(height: 8));
        children.add(_PrepGroup(g));
      }
    }

    // ── rules (word order) ────────────────────────────────────────────────
    if (s.containsKey('rules')) {
      final rules = (s['rules'] as List).cast<Map<String, dynamic>>();
      for (final r in rules) {
        children.add(const SizedBox(height: 10));
        children.add(_RuleBlock(r));
      }
    }

    // ── examples ─────────────────────────────────────────────────────────
    if (s.containsKey('examples')) {
      final examples =
          (s['examples'] as List).cast<Map<String, dynamic>>();
      if (examples.isNotEmpty) {
        children.add(const SizedBox(height: 10));
        for (final e in examples) {
          children.add(_ExRow(e));
        }
      }
    }

    // ── mistakes ─────────────────────────────────────────────────────────
    if (s.containsKey('mistakes')) {
      final mistakes =
          (s['mistakes'] as List).cast<Map<String, dynamic>>();
      for (final m in mistakes) {
        children.add(const SizedBox(height: 10));
        children.add(_MistakeBlock(m));
      }
    }

    // ── tips ─────────────────────────────────────────────────────────────
    if (s.containsKey('tips')) {
      final tips = (s['tips'] as List).cast<Map<String, dynamic>>();
      for (final t in tips) {
        children.add(const SizedBox(height: 6));
        children.add(_TipRow(t));
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: _GrammarCard(
        icon: _iconFor(id),
        title: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  IconData _iconFor(String id) => switch (id) {
        'reflexive_pronouns'          => Icons.grid_on_rounded,
        'three_types'                 => Icons.category_rounded,
        'akkusativ_vs_dativ_pronoun'  => Icons.compare_arrows_rounded,
        'prepositions_with_reflexive' => Icons.link_rounded,
        'word_order'                  => Icons.sort_rounded,
        'reciprocal'                  => Icons.sync_rounded,
        'partizip_perfekt'            => Icons.access_time_rounded,
        'common_mistakes'             => Icons.warning_amber_rounded,
        'tips'                        => Icons.lightbulb_outline_rounded,
        _                             => Icons.info_outline_rounded,
      };
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

// ─── Pronoun table ────────────────────────────────────────────────────────────

class _ProTable extends StatelessWidget {
  const _ProTable({required this.headers, required this.rows});
  final List<String>       headers;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Table(
      border: TableBorder.all(
          color: cs.outlineVariant,
          width: 0.8,
          borderRadius: BorderRadius.circular(6)),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.4)),
          children: headers
              .map((h) => Padding(
                    padding: const EdgeInsets.all(7),
                    child: Text(h,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700)),
                  ))
              .toList(),
        ),
        ...rows.map((r) => TableRow(
              children: r
                  .map((c) => Padding(
                        padding: const EdgeInsets.all(7),
                        child: Text(c, style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
            )),
      ],
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
          style:
              Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.6)),
    );
  }
}

// ─── Type block (echte / unechte / dativ) ────────────────────────────────────

class _TypeBlock extends StatelessWidget {
  const _TypeBlock(this.t);
  final Map<String, dynamic> t;

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final name = AppL10n.loc(context, t, 'name');
    final desc = AppL10n.loc(context, t, 'description');
    final examples = t.containsKey('examples')
        ? (t['examples'] as List).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                  fontSize: 13)),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(desc,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(height: 1.6)),
          ],
          ...examples.map((e) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: _ExRow(e),
              )),
        ],
      ),
    );
  }
}

// ─── Comparison pair (Akk vs Dat) ────────────────────────────────────────────

class _ComparisonPair extends StatelessWidget {
  const _ComparisonPair(this.p);
  final Map<String, dynamic> p;

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final akk  = p['akkusativ'] as Map<String, dynamic>;
    final dat  = p['dativ']     as Map<String, dynamic>;
    final expl = AppL10n.loc(context, p, 'explanation');

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ExRow(akk, label: 'Akk'),
          const SizedBox(height: 4),
          _ExRow(dat, label: 'Dat'),
          if (expl.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(expl,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant, height: 1.5)),
          ],
        ],
      ),
    );
  }
}

// ─── Preposition group ────────────────────────────────────────────────────────

class _PrepGroup extends StatelessWidget {
  const _PrepGroup(this.g);
  final Map<String, dynamic> g;

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final prep = g['preposition'] as String? ?? '';
    final examples = g.containsKey('examples')
        ? (g['examples'] as List).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(prep,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13)),
        ),
        ...examples.map((e) => Padding(
              padding: const EdgeInsets.only(top: 5, left: 8),
              child: _ExRow(e),
            )),
      ],
    );
  }
}

// ─── Word-order rule ──────────────────────────────────────────────────────────

class _RuleBlock extends StatelessWidget {
  const _RuleBlock(this.r);
  final Map<String, dynamic> r;

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final title = AppL10n.loc(context, r, 'title');
    final expl  = AppL10n.loc(context, r, 'explanation');
    final examples = r.containsKey('examples')
        ? (r['examples'] as List).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: cs.secondary,
                  fontSize: 13)),
          if (expl.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(expl,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(height: 1.6)),
          ],
          ...examples.map((e) => Padding(
                padding: const EdgeInsets.only(top: 5),
                child: _ExRow(e),
              )),
        ],
      ),
    );
  }
}

// ─── Mistake block ────────────────────────────────────────────────────────────

class _MistakeBlock extends StatelessWidget {
  const _MistakeBlock(this.m);
  final Map<String, dynamic> m;

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final title = AppL10n.loc(context, m, 'title');
    final expl  = AppL10n.loc(context, m, 'explanation');
    final examples = m.containsKey('examples')
        ? (m['examples'] as List).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.15),
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: cs.error,
                  fontSize: 13)),
          if (expl.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(expl,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(height: 1.6)),
          ],
          ...examples.map((e) => Padding(
                padding: const EdgeInsets.only(top: 5),
                child: _ExRow(e),
              )),
        ],
      ),
    );
  }
}

// ─── Tip row ──────────────────────────────────────────────────────────────────

class _TipRow extends StatelessWidget {
  const _TipRow(this.t);
  final Map<String, dynamic> t;

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final txt = t['fa'] as String? ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_rounded, size: 16, color: cs.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(txt,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(height: 1.6)),
        ),
      ],
    );
  }
}

// ─── Example row ──────────────────────────────────────────────────────────────

class _ExRow extends StatelessWidget {
  const _ExRow(this.e, {this.label});
  final Map<String, dynamic> e;
  final String?              label;

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final de     = e['de'] as String? ?? '';
    final transl = e['fa'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              margin: const EdgeInsets.only(top: 2, right: 6),
              decoration: BoxDecoration(
                color: cs.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(label!,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: cs.onSecondaryContainer)),
            ),
          ],
          Expanded(
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
          ),
        ],
      ),
    );
  }
}
