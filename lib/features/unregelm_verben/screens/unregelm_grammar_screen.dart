// FILE: lib/features/unregelm_verben/screens/unregelm_grammar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../controllers/unregelm_controller.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/deutsch_text.dart';

class UnregelmGrammarScreen extends ConsumerWidget {
  const UnregelmGrammarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grammarAsync = ref.watch(unregelVerbenGrammarProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Unregelmäßige Verben — Grammatik')),
      body: grammarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('$e')),
        data   : (grammar) {
          final sections =
              (grammar['sections'] as List<dynamic>).cast<Map<String, dynamic>>();
          return ListView.separated(
            padding         : const EdgeInsets.fromLTRB(16, 16, 16, 48),
            itemCount       : sections.length,
            separatorBuilder: (_, _) => const SizedBox(height: 20),
            itemBuilder     : (ctx, i) => _Section(section: sections[i]),
          );
        },
      ),
    );
  }
}

// ─── section dispatcher ───────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.section});
  final Map<String, dynamic> section;

  @override
  Widget build(BuildContext context) {
    final sid = section['section_id'] as String;
    return switch (sid) {
      'verb_types'           => _VerbTypes(section),
      'three_principal_parts'=> _PrincipalParts(section),
      'ablaut_patterns'      => _AblautPatterns(section),
      'partizip_ii_formation'=> _Partizip2Formation(section),
      'praesens_vowel_change'=> _PraesensVowel(section),
      'haben_vs_sein'        => _HabenSein(section),
      'modal_verbs'          => _ModalVerbs(section),
      'fully_irregular'      => _FullyIrregular(section),
      'compound_verbs'       => _CompoundVerbs(section),
      'common_mistakes'      => _CommonMistakes(section),
      'tips'                 => _Tips(section),
      _                      => const SizedBox.shrink(),
    };
  }
}

// ─── shared helpers ───────────────────────────────────────────────────────────

class _GrammarCard extends StatelessWidget {
  const _GrammarCard({required this.child, this.padding});
  final Widget  child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        color    : Theme.of(context).colorScheme.surfaceContainerLow,
        shape    : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSizes.md),
          child  : child,
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.titleFa);
  final String titleFa;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.sm),
        child  : Text(
          titleFa,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      );
}

class _ExplaFa extends StatelessWidget {
  const _ExplaFa(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
}

class _GreenChip extends StatelessWidget {
  const _GreenChip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color       : Colors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border      : Border.all(color: Colors.green.withValues(alpha: 0.4)),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize  : 12,
                color     : Colors.green,
                fontWeight: FontWeight.w700)),
      );
}

// ─── 1. verb_types ────────────────────────────────────────────────────────────

class _VerbTypes extends StatelessWidget {
  const _VerbTypes(this.s);
  final Map<String, dynamic> s;

  static const _colors = {
    'stark'    : Color(0xFF1565C0),
    'gemischt' : Color(0xFFE65100),
    'modal'    : Color(0xFF2E7D32),
    'irregular': Color(0xFF6A1B9A),
  };

  @override
  Widget build(BuildContext context) {
    final types = (s['types'] as List<dynamic>).cast<Map<String, dynamic>>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(AppL10n.loc(context, s, 'title')),
        ...types.map((t) {
          final tid   = t['type_id'] as String;
          final color = _colors[tid] ?? Colors.blueGrey;
          return _GrammarCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width : 4, height: 50,
                  decoration: BoxDecoration(
                    color       : color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color : color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(AppL10n.loc(context, t, 'title'),
                            style: TextStyle(
                                fontSize  : 12,
                                color     : color,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 6),
                      Text(AppL10n.loc(context, t, 'explanation'),
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─── 2. three_principal_parts ─────────────────────────────────────────────────

class _PrincipalParts extends StatelessWidget {
  const _PrincipalParts(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final examples =
        (s['examples'] as List<dynamic>).cast<Map<String, dynamic>>();
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(AppL10n.loc(context, s, 'title')),
        _GrammarCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((s['explanation_fa'] as String?)?.isNotEmpty == true)
                _ExplaFa(AppL10n.loc(context, s, 'explanation')),
              const SizedBox(height: AppSizes.sm),
              Table(
                border: TableBorder.all(
                    color: cs.outlineVariant, width: 0.5),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: cs.surfaceContainerHigh),
                    children: ['Infinitiv', 'Präteritum', 'Partizip II']
                        .map((h) => Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(h,
                                  style: const TextStyle(
                                      fontSize  : 11,
                                      fontWeight: FontWeight.w700)),
                            ))
                        .toList(),
                  ),
                  ...examples.map((e) => TableRow(children: [
                        _TC(e['infinitiv'] as String),
                        _TC(e['praeteritum'] as String),
                        _TC(e['partizip_ii'] as String),
                      ])),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TC extends StatelessWidget {
  const _TC(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(6),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500)),
      );
}

// ─── 3. ablaut_patterns ───────────────────────────────────────────────────────

class _AblautPatterns extends StatelessWidget {
  const _AblautPatterns(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final groups =
        (s['groups'] as List<dynamic>).cast<Map<String, dynamic>>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(AppL10n.loc(context, s, 'title')),
        if ((s['explanation_fa'] as String?)?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child  : _ExplaFa(AppL10n.loc(context, s, 'explanation')),
          ),
        ...groups.map((g) {
          final examples =
              (g['examples'] as List<dynamic>).cast<Map<String, dynamic>>();
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _GrammarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _GreenChip(g['pattern'] as String),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(AppL10n.loc(context, g, 'title'),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  if ((g['explanation_fa'] as String?)?.isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    _ExplaFa(AppL10n.loc(context, g, 'explanation')),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: examples
                        .map((e) => _VerbFormChip(
                              infinitiv  : e['infinitiv']   as String,
                              praeteritum: e['praeteritum'] as String,
                              partizipIi : e['partizip_ii'] as String,
                              meaningFa  : AppL10n.loc(context, e, 'meaning'),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _VerbFormChip extends StatelessWidget {
  const _VerbFormChip({
    required this.infinitiv,
    required this.praeteritum,
    required this.partizipIi,
    required this.meaningFa,
  });
  final String infinitiv;
  final String praeteritum;
  final String partizipIi;
  final String meaningFa;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color       : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$infinitiv · $praeteritum · $partizipIi',
              style: const TextStyle(
                  fontSize  : 11,
                  fontWeight: FontWeight.w600)),
          Text(meaningFa,
              style: TextStyle(
                  fontSize: 10, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ─── 4. partizip_ii_formation ─────────────────────────────────────────────────

class _Partizip2Formation extends StatelessWidget {
  const _Partizip2Formation(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final rules =
        (s['rules'] as List<dynamic>).cast<Map<String, dynamic>>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(AppL10n.loc(context, s, 'title')),
        ...rules.map((r) {
          final examples =
              (r['examples'] as List<dynamic>).cast<Map<String, dynamic>>();
          final noteFa = r['note_fa'] as String?;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _GrammarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppL10n.loc(context, r, 'title'),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color       : const Color(0xFF1565C0).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(r['formula'] as String,
                        style: const TextStyle(
                            fontSize  : 13,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                            color     : Color(0xFF1565C0))),
                  ),
                  if (noteFa != null && noteFa.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _ExplaFa(noteFa),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: examples
                        .map((e) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '${e["infinitiv"]} → ${e["partizip_ii"]}',
                                style: const TextStyle(
                                    fontSize  : 11,
                                    fontWeight: FontWeight.w500),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── 5. praesens_vowel_change ─────────────────────────────────────────────────

class _PraesensVowel extends StatelessWidget {
  const _PraesensVowel(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final groups = (s['change_groups'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(AppL10n.loc(context, s, 'title')),
        if ((s['explanation_fa'] as String?)?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child  : _ExplaFa(AppL10n.loc(context, s, 'explanation')),
          ),
        ...groups.map((g) {
          final examples =
              (g['examples'] as List<dynamic>).cast<Map<String, dynamic>>();
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _GrammarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color       : const Color(0xFF00838F)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                          border      : Border.all(
                              color: const Color(0xFF00838F)
                                  .withValues(alpha: 0.4)),
                        ),
                        child: Text(g['change'] as String,
                            style: const TextStyle(
                                fontSize  : 12,
                                color     : Color(0xFF00838F),
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(AppL10n.loc(context, g, 'title'),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight : 32,
                      dataRowMinHeight : 28,
                      dataRowMaxHeight : 32,
                      columnSpacing    : 20,
                      columns          : const [
                        DataColumn(label: Text('Infinitiv',
                            style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('ich',
                            style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('du',
                            style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('er/sie',
                            style: TextStyle(fontWeight: FontWeight.w700))),
                      ],
                      rows: examples
                          .map((e) => DataRow(cells: [
                                DataCell(Text(e['infinitiv'] as String,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600))),
                                DataCell(Text(e['ich'] as String)),
                                DataCell(Text(e['du']  as String)),
                                DataCell(Text(e['er']  as String,
                                    style: const TextStyle(
                                        color     : Color(0xFFE65100),
                                        fontWeight: FontWeight.w600))),
                              ]))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── 6. haben_vs_sein ────────────────────────────────────────────────────────

class _HabenSein extends StatelessWidget {
  const _HabenSein(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final rules =
        (s['rules'] as List<dynamic>).cast<Map<String, dynamic>>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(AppL10n.loc(context, s, 'title')),
        if ((s['explanation_fa'] as String?)?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child  : _ExplaFa(AppL10n.loc(context, s, 'explanation')),
          ),
        ...rules.map((r) {
          final aux      = r['auxiliary'] as String;
          final color    = aux == 'sein'
              ? const Color(0xFFC62828)
              : aux == 'haben'
                  ? const Color(0xFF00695C)
                  : const Color(0xFF6A1B9A);
          final examples =
              (r['examples'] as List<dynamic>).cast<Map<String, dynamic>>();

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _GrammarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color : color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: color.withValues(alpha: 0.4)),
                        ),
                        child: Text(aux,
                            style: TextStyle(
                                fontSize  : 12,
                                color     : color,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(AppL10n.loc(context, r, 'title'),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),

                  // rules_fa list
                  if (r['rules_fa'] != null) ...[
                    const SizedBox(height: 8),
                    ...(r['rules_fa'] as List<dynamic>).map((rule) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ',
                                  style: TextStyle(color: color)),
                              Expanded(child: Text(rule as String,
                                  style: Theme.of(context).textTheme.bodySmall)),
                            ],
                          ),
                        )),
                  ],

                  // explanation_fa for haben_oder_sein
                  if (r['explanation_fa'] != null &&
                      (AppL10n.loc(context, r, 'explanation')).isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _ExplaFa(AppL10n.loc(context, r, 'explanation')),
                  ],

                  // examples
                  if (examples.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...examples.map((e) {
                      // haben_oder_sein has de_sein / de_haben keys
                      if (e.containsKey('de_sein')) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('(sein)  ${e["de_sein"]}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic)),
                              Text('(haben) ${e["de_haben"]}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic)),
                              if ((e['fa'] as String?)?.isNotEmpty == true)
                                Text((AppL10n.isFa(context) ? e['fa'] : (e['en'] ?? e['fa'])) as String,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)),
                            ],
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((e['de'] as String?)?.isNotEmpty == true)
                              DeutschText(e['de'] as String,
                                  style: const TextStyle(
                                      fontSize  : 12,
                                      fontStyle : FontStyle.italic)),
                            if ((e['fa'] as String?)?.isNotEmpty == true)
                              Text((AppL10n.isFa(context) ? e['fa'] : (e['en'] ?? e['fa'])) as String,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── 7. modal_verbs ──────────────────────────────────────────────────────────

class _ModalVerbs extends StatelessWidget {
  const _ModalVerbs(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final ct = s['conjugation_table'] as Map<String, dynamic>;
    final pt = s['prateritum_table']  as Map<String, dynamic>;
    final cs = Theme.of(context).colorScheme;

    final ctHeaders = (ct['headers'] as List<dynamic>).cast<String>();
    final ctRows    = (ct['rows'] as List<dynamic>)
        .map((r) => (r as List<dynamic>).cast<String>())
        .toList();

    final ptHeaders = (pt['headers'] as List<dynamic>).cast<String>();
    final ptRows    = (pt['rows'] as List<dynamic>)
        .map((r) => (r as List<dynamic>).cast<String>())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(AppL10n.loc(context, s, 'title')),
        if ((s['explanation_fa'] as String?)?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child  : _ExplaFa(AppL10n.loc(context, s, 'explanation')),
          ),

        // Präsens conjugation
        _GrammarCard(
          padding: const EdgeInsets.all(8),
          child  : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 30,
              dataRowMaxHeight: 36,
              columnSpacing   : 16,
              decoration      : BoxDecoration(
                border: Border.all(color: cs.outlineVariant, width: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              columns: ctHeaders
                  .map((h) => DataColumn(
                        label: Text(h,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize  : 12)),
                      ))
                  .toList(),
              rows: ctRows
                  .map((row) => DataRow(
                        cells: [
                          DataCell(Text(row[0],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600))),
                          ...row.sublist(1).map((c) => DataCell(Text(c,
                              style: const TextStyle(
                                  fontSize  : 12,
                                  fontWeight: FontWeight.w500,
                                  color     : Color(0xFF1565C0))))),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Präteritum table
        _GrammarCard(
          padding: const EdgeInsets.all(8),
          child  : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pt['title_fa'] as String? ?? 'Präteritum',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 32,
                  dataRowMinHeight: 28,
                  dataRowMaxHeight: 32,
                  columnSpacing   : 20,
                  columns: ptHeaders
                      .map((h) => DataColumn(
                            label: Text(h,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize  : 11)),
                          ))
                      .toList(),
                  rows: ptRows
                      .map((row) => DataRow(
                            cells: row
                                .map((c) => DataCell(Text(c,
                                    style: const TextStyle(fontSize: 12))))
                                .toList(),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),

        if ((s['important_note_fa'] as String?)?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          _GrammarCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size : 16,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(AppL10n.loc(context, s, 'important_note'),
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─── 8. fully_irregular ──────────────────────────────────────────────────────

class _FullyIrregular extends StatelessWidget {
  const _FullyIrregular(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final verbs =
        (s['verbs'] as List<dynamic>).cast<Map<String, dynamic>>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(AppL10n.loc(context, s, 'title')),
        ...verbs.map((v) {
          final cs = Theme.of(context).colorScheme;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _GrammarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(v['infinitiv'] as String,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize  : 16)),
                      const SizedBox(width: 8),
                      Text(AppL10n.loc(context, v, 'meaning'),
                          style: TextStyle(
                              color   : cs.onSurfaceVariant,
                              fontSize: 13)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                            '+ ${v["perfekt_auxiliary"]}',
                            style: const TextStyle(
                                fontSize  : 10,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  if ((v['conjugation_note_fa'] as String?)?.isNotEmpty ==
                      true) ...[
                    const SizedBox(height: 4),
                    _ExplaFa(AppL10n.loc(context, v, 'conjugation_note')),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PraesRow('Präsens', v['praesens'] as String),
                        const SizedBox(height: 2),
                        _PraesRow('Präteritum', v['praeteritum'] as String),
                        const SizedBox(height: 2),
                        _PraesRow('Partizip II', v['partizip_ii'] as String),
                      ],
                    ),
                  ),
                  if ((v['example_de'] as String?)?.isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    DeutschText(v['example_de'] as String,
                        style: const TextStyle(
                            fontSize  : 12,
                            fontStyle : FontStyle.italic)),
                    if ((v['example_fa'] as String?)?.isNotEmpty == true)
                      Text(AppL10n.loc(context, v, 'example'),
                          style: TextStyle(
                              fontSize: 11, color: cs.onSurfaceVariant)),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _PraesRow extends StatelessWidget {
  const _PraesRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color   : Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize  : 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      );
}

// ─── 9. compound_verbs ────────────────────────────────────────────────────────

class _CompoundVerbs extends StatelessWidget {
  const _CompoundVerbs(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final families = (s['base_verb_families'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final noteFa = s['important_note_fa'] as String?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(AppL10n.loc(context, s, 'title')),
        if ((s['explanation_fa'] as String?)?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child  : _ExplaFa(AppL10n.loc(context, s, 'explanation')),
          ),
        ...families.map((f) {
          final compounds =
              (f['compounds'] as List<dynamic>).cast<String>();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _GrammarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f['base'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: compounds
                        .map((c) => Chip(
                              label  : Text(c,
                                  style: const TextStyle(fontSize: 11)),
                              padding: EdgeInsets.zero,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        }),
        if (noteFa != null && noteFa.isNotEmpty)
          _GrammarCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size : 16,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(noteFa,
                    style: Theme.of(context).textTheme.bodySmall)),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── 10. common_mistakes ─────────────────────────────────────────────────────

class _CommonMistakes extends StatelessWidget {
  const _CommonMistakes(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final mistakes =
        (s['mistakes'] as List<dynamic>).cast<Map<String, dynamic>>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(AppL10n.loc(context, s, 'title')),
        ...mistakes.map((m) {
          final examples =
              (m['examples'] as List<dynamic>).cast<Map<String, dynamic>>();
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _GrammarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppL10n.loc(context, m, 'title'),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...examples.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('✗ ',
                                    style: TextStyle(color: Colors.red)),
                                Expanded(
                                  child: Text(e['wrong'] as String,
                                      style: const TextStyle(
                                          color    : Colors.red,
                                          fontSize : 12,
                                          fontStyle: FontStyle.italic)),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('✓ ',
                                    style: TextStyle(color: Colors.green)),
                                Expanded(
                                  child: Text(e['correct'] as String,
                                      style: const TextStyle(
                                          color    : Colors.green,
                                          fontSize : 12,
                                          fontStyle: FontStyle.italic)),
                                ),
                              ],
                            ),
                            if ((e['note'] as String?)?.isNotEmpty == true)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(e['note'] as String,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color   : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)),
                              ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── 11. tips ────────────────────────────────────────────────────────────────

class _Tips extends StatelessWidget {
  const _Tips(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final tips =
        (s['tips'] as List<dynamic>).cast<Map<String, dynamic>>();
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(AppL10n.loc(context, s, 'title')),
        ...tips.asMap().entries.map((entry) {
          final i   = entry.key;
          final tip = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _GrammarCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius         : 12,
                    backgroundColor: cs.primaryContainer,
                    child          : Text('${i + 1}',
                        style: TextStyle(
                            fontSize : 10,
                            color    : cs.onPrimaryContainer,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text((AppL10n.isFa(context) ? tip['fa'] : (tip['en'] ?? tip['fa'])) as String,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
