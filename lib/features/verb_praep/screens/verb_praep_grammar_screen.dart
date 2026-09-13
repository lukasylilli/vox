// FILE: lib/features/verb_praep/screens/verb_praep_grammar_screen.dart
// PURPOSE: Grammar screen for Verben mit Präpositionen — 9 section types
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../controllers/verb_praep_controller.dart';
import '../../../core/l10n/app_l10n.dart';

class VerbPraepGrammarScreen extends ConsumerWidget {
  const VerbPraepGrammarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grammarAsync = ref.watch(verbPraepGrammarProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Verben mit Präpositionen — Grammatik')),
      body  : grammarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, _) => Center(child: Text('$e')),
        data   : (data) {
          final sections = (data['sections'] as List).cast<Map<String, dynamic>>();
          return ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.xl),
            children: [
              _OverviewCard(data),
              const SizedBox(height: AppSizes.md),
              ...sections.map((s) => _sectionCard(context, s)),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionCard(BuildContext context, Map<String, dynamic> s) {
    final id = s['section_id'] as String;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(AppL10n.loc(context, s, 'title')),
              const SizedBox(height: AppSizes.sm),
              _buildSection(context, id, s),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String id, Map<String, dynamic> s) {
    switch (id) {
      case 'what_and_why':
        return _WhatAndWhy(s);
      case 'akkusativ_vs_dativ':
        return _AkkDat(s);
      case 'question_formation':
        return _QuestionFormation(s);
      case 'da_compounds':
        return _DaCompounds(s);
      case 'preposition_groups':
        return _PrepGroups(s);
      case 'reflexive_with_prep':
        return _ReflexiveWithPrep(s);
      case 'common_mistakes':
        return _CommonMistakes(s);
      case 'full_sentence_pattern':
        return _FullPattern(s);
      case 'tips':
        return _Tips(s);
      default:
        final expl = s['explanation_fa'] as String?;
        if (expl != null && expl.isNotEmpty) {
          return _ExplText(expl);
        }
        return const SizedBox.shrink();
    }
  }
}

// ─── Overview card ────────────────────────────────────────────────────────────

class _OverviewCard extends StatelessWidget {
  const _OverviewCard(this.data);
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final summary = AppL10n.loc(context, data, 'summary');
    return Card(
      color: const Color(0xFF6A1B9A).withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['title_fa'] as String? ?? AppL10n.t(context, 'verb_praep_title'),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (summary.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(summary,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.6)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── what_and_why ─────────────────────────────────────────────────────────────

class _WhatAndWhy extends StatelessWidget {
  const _WhatAndWhy(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final expl     = AppL10n.loc(context, s, 'explanation');
    final examples = (s['examples'] as List? ?? []).cast<Map<String, dynamic>>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (expl.isNotEmpty) _ExplText(expl),
        if (examples.isNotEmpty) ...[
          const SizedBox(height: AppSizes.sm),
          ...examples.map((e) => _ExampleRow(
                de  : e['de']    as String? ?? '',
                fa  : (AppL10n.isFa(context) ? e['fa'] : (e['en'] ?? e['fa'])) as String? ?? '',
                note: AppL10n.loc(context, e, 'note'),
              )),
        ],
      ],
    );
  }
}

// ─── akkusativ_vs_dativ ───────────────────────────────────────────────────────

class _AkkDat extends StatelessWidget {
  const _AkkDat(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final expl   = AppL10n.loc(context, s, 'explanation');
    final groups = (s['groups'] as List? ?? []).cast<Map<String, dynamic>>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (expl.isNotEmpty) ...[_ExplText(expl), const SizedBox(height: AppSizes.sm)],
        ...groups.map((g) => _AkkDatGroup(g)),
      ],
    );
  }
}

class _AkkDatGroup extends StatelessWidget {
  const _AkkDatGroup(this.g);
  final Map<String, dynamic> g;

  @override
  Widget build(BuildContext context) {
    final title = AppL10n.loc(context, g, 'title');
    final preps = (g['prepositions'] as List? ?? []).cast<String>();
    final note  = AppL10n.loc(context, g, 'note');
    final exs   = (g['examples']   as List? ?? []).cast<Map<String, dynamic>>();
    final id    = g['group_id']    as String? ?? '';
    final color = id == 'always_akkusativ'
        ? const Color(0xFF1565C0)
        : id == 'always_dativ'
            ? const Color(0xFF2E7D32)
            : const Color(0xFFE65100);

    return Container(
      margin : const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color       : color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border      : Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: color, fontSize: 13)),
          if (preps.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6, runSpacing: 4,
              children: preps.map((p) => _PrepChip(p, color)).toList(),
            ),
          ],
          if (note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(note,
                style: const TextStyle(
                    fontSize: 12, fontStyle: FontStyle.italic)),
          ],
          if (exs.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...exs.map((e) => _ExampleRow(
                  de  : e['de'] as String? ?? '',
                  fa  : (AppL10n.isFa(context) ? e['fa'] : (e['en'] ?? e['fa'])) as String? ?? '',
                  hint: e['verb'] as String?,
                )),
          ],
        ],
      ),
    );
  }
}

// ─── question_formation ───────────────────────────────────────────────────────

class _QuestionFormation extends StatelessWidget {
  const _QuestionFormation(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final expl      = AppL10n.loc(context, s, 'explanation');
    final subRules  = (s['sub_rules'] as List? ?? []).cast<Map<String, dynamic>>();
    final table     = s['summary_table'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (expl.isNotEmpty) ...[_ExplText(expl), const SizedBox(height: AppSizes.sm)],
        ...subRules.map((r) => _SubRule(r)),
        if (table != null) ...[
          const SizedBox(height: AppSizes.sm),
          _SummaryTable(table),
        ],
      ],
    );
  }
}

class _SubRule extends StatelessWidget {
  const _SubRule(this.r);
  final Map<String, dynamic> r;

  @override
  Widget build(BuildContext context) {
    final title      = AppL10n.loc(context, r, 'title');
    final formation  = AppL10n.loc(context, r, 'formation');
    final explanation = AppL10n.loc(context, r, 'explanation');
    final examples   = (r['examples'] as List? ?? []).cast<Map<String, dynamic>>();

    return Container(
      margin : const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color       : Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          if (formation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(formation,
                style: const TextStyle(
                    fontStyle: FontStyle.italic, fontSize: 13)),
          ],
          if (explanation.isNotEmpty) ...[
            const SizedBox(height: 4),
            _ExplText(explanation),
          ],
          if (examples.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...examples.map((e) {
              final stmt = e['statement']    as String? ?? '';
              final q    = e['question']     as String? ?? '';
              final ans  = e['answer']       as String? ?? '';
              final faQ  = e['fa_question']  as String? ?? '';
              return _QARow(stmt: stmt, question: q, answer: ans, fa: faQ);
            }),
          ],
        ],
      ),
    );
  }
}

class _QARow extends StatelessWidget {
  const _QARow({
    required this.stmt,
    required this.question,
    required this.answer,
    required this.fa,
  });
  final String stmt;
  final String question;
  final String answer;
  final String fa;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (stmt.isNotEmpty)
            Text('· $stmt',
                style: const TextStyle(fontStyle: FontStyle.italic)),
          if (question.isNotEmpty)
            Text('? $question',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary)),
          if (answer.isNotEmpty)
            Text('→ $answer', style: const TextStyle(fontSize: 12)),
          if (fa.isNotEmpty)
            Text(fa,
                style: TextStyle(
                    fontSize: 12, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _SummaryTable extends StatelessWidget {
  const _SummaryTable(this.table);
  final Map<String, dynamic> table;

  @override
  Widget build(BuildContext context) {
    final title = AppL10n.loc(context, table, 'title');
    final rows  = (table['rows'] as List? ?? []).cast<Map<String, dynamic>>();
    final cs    = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Table(
          border: TableBorder.all(
              color: cs.outlineVariant, borderRadius: BorderRadius.circular(4)),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(3),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest),
              children: [
                _TCell(AppL10n.t(context, 'status_label'), header: true),
                _TCell(AppL10n.t(context, 'form_label'), header: true),
                _TCell(AppL10n.t(context, 'example'), header: true),
              ],
            ),
            ...rows.map((r) => TableRow(
                  children: [
                    _TCell(AppL10n.loc(context, r, 'situation')),
                    _TCell(AppL10n.loc(context, r, 'form')),
                    _TCell(r['example']      as String? ?? ''),
                  ],
                )),
          ],
        ),
      ],
    );
  }
}

class _TCell extends StatelessWidget {
  const _TCell(this.text, {this.header = false});
  final String text;
  final bool   header;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: Text(text,
            style: TextStyle(
                fontSize  : 12,
                fontWeight: header ? FontWeight.w700 : FontWeight.normal)),
      );
}

// ─── da_compounds ─────────────────────────────────────────────────────────────

class _DaCompounds extends StatelessWidget {
  const _DaCompounds(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final expl     = AppL10n.loc(context, s, 'explanation');
    final examples = (s['examples'] as List? ?? []).cast<Map<String, dynamic>>();
    final note     = AppL10n.loc(context, s, 'important_note');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (expl.isNotEmpty) ...[_ExplText(expl), const SizedBox(height: AppSizes.sm)],
        ...examples.map((e) => _ExampleRow(
              de: e['de'] as String? ?? '',
              fa  : (AppL10n.isFa(context) ? e['fa'] : (e['en'] ?? e['fa'])) as String? ?? '',
            )),
        if (note.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color       : const Color(0xFFE65100).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border      : Border.all(
                  color: const Color(0xFFE65100).withValues(alpha: 0.3)),
            ),
            child: Text(note, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ],
    );
  }
}

// ─── preposition_groups ───────────────────────────────────────────────────────

class _PrepGroups extends StatelessWidget {
  const _PrepGroups(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final groups = (s['groups'] as List? ?? []).cast<Map<String, dynamic>>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.map((g) => _PrepGroupCard(g)).toList(),
    );
  }
}

class _PrepGroupCard extends StatelessWidget {
  const _PrepGroupCard(this.g);
  final Map<String, dynamic> g;

  @override
  Widget build(BuildContext context) {
    final prep      = g['prep']       as String? ?? '';
    final woComp    = g['wo_compound'] as String? ?? '';
    final verbsFa   = (g['verbs_fa']  as List? ?? []).cast<String>();

    return Container(
      margin : const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color       : const Color(0xFF6A1B9A).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border      : Border.all(
            color: const Color(0xFF6A1B9A).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PrepChip(prep, const Color(0xFF6A1B9A)),
              if (woComp.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text('→ $woComp?',
                    style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF00695C))),
              ],
            ],
          ),
          if (verbsFa.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...verbsFa.map((v) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text('• $v',
                      style: const TextStyle(fontSize: 12)),
                )),
          ],
        ],
      ),
    );
  }
}

// ─── reflexive_with_prep ──────────────────────────────────────────────────────

class _ReflexiveWithPrep extends StatelessWidget {
  const _ReflexiveWithPrep(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final expl     = AppL10n.loc(context, s, 'explanation');
    final examples = (s['examples'] as List? ?? []).cast<Map<String, dynamic>>();
    final cs       = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (expl.isNotEmpty) ...[_ExplText(expl), const SizedBox(height: AppSizes.sm)],
        ...examples.map((e) {
          final verb  = e['verb']         as String? ?? '';
          final stmt  = e['de_statement'] as String? ?? '';
          final q     = e['de_question']  as String? ?? '';
          final ans   = e['de_answer']    as String? ?? '';
          final da    = e['de_da']        as String? ?? '';
          final fa    = e['fa']           as String? ?? '';
          return Container(
            margin : const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color       : cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (verb.isNotEmpty)
                  Text(verb,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                if (stmt.isNotEmpty)
                  Text('· $stmt',
                      style: const TextStyle(fontStyle: FontStyle.italic)),
                if (q.isNotEmpty)
                  Text('? $q',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary)),
                if (ans.isNotEmpty)
                  Text('→ $ans', style: const TextStyle(fontSize: 12)),
                if (da.isNotEmpty)
                  Text('da-: $da',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF00695C))),
                if (fa.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(fa,
                      style: TextStyle(
                          fontSize: 12, color: cs.onSurfaceVariant)),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─── common_mistakes ──────────────────────────────────────────────────────────

class _CommonMistakes extends StatelessWidget {
  const _CommonMistakes(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final mistakes = (s['mistakes'] as List? ?? []).cast<Map<String, dynamic>>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: mistakes.map((m) => _MistakeBlock(m)).toList(),
    );
  }
}

class _MistakeBlock extends StatelessWidget {
  const _MistakeBlock(this.m);
  final Map<String, dynamic> m;

  @override
  Widget build(BuildContext context) {
    final title    = AppL10n.loc(context, m, 'title');
    final examples = (m['examples'] as List? ?? []).cast<Map<String, dynamic>>();

    return Container(
      margin : const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color       : const Color(0xFFB71C1C).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border      : Border.all(
            color: const Color(0xFFB71C1C).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          ...examples.map((e) {
            final wrong   = e['wrong']   as String? ?? '';
            final correct = e['correct'] as String? ?? '';
            final fa      = e['fa']      as String? ?? '';
            final note    = e['note']    as String? ?? '';
            final expl    = AppL10n.loc(context, e, 'explanation');
            // simple example with de/fa keys
            final de      = e['de'] as String? ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (wrong.isNotEmpty)
                    Text('✗ $wrong',
                        style: const TextStyle(
                            color: Color(0xFFB71C1C),
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12)),
                  if (correct.isNotEmpty)
                    Text('✓ $correct',
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  if (de.isNotEmpty)
                    Text('· $de',
                        style: const TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 12)),
                  if (fa.isNotEmpty)
                    Text(fa,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                  if (expl.isNotEmpty)
                    Text(expl,
                        style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic)),
                  if (note.isNotEmpty)
                    Text('💡 $note', style: const TextStyle(fontSize: 11)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── full_sentence_pattern ────────────────────────────────────────────────────

class _FullPattern extends StatelessWidget {
  const _FullPattern(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final expl     = AppL10n.loc(context, s, 'explanation');
    final steps    = (s['pattern_steps']  as List? ?? []).cast<Map<String, dynamic>>();
    final fullExs  = (s['full_examples']  as List? ?? []).cast<Map<String, dynamic>>();
    final cs       = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (expl.isNotEmpty) ...[_ExplText(expl), const SizedBox(height: AppSizes.sm)],
        if (steps.isNotEmpty) ...[
          Text(AppL10n.t(context, 'steps_label'),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          ...steps.map((st) {
            final step    = st['step']    as int? ?? 0;
            final nameFa  = AppL10n.loc(context, st, 'name');
            final example = st['example'] as String? ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width : 22, height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color       : const Color(0xFF6A1B9A),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text('$step',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nameFa,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                        if (example.isNotEmpty)
                          Text(example,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
        if (fullExs.isNotEmpty) ...[
          const SizedBox(height: AppSizes.sm),
          Text(AppL10n.t(context, 'full_example'),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          ...fullExs.map((fe) => _FullExCard(fe, cs)),
        ],
      ],
    );
  }
}

class _FullExCard extends StatelessWidget {
  const _FullExCard(this.fe, this.cs);
  final Map<String, dynamic> fe;
  final ColorScheme           cs;

  @override
  Widget build(BuildContext context) {
    final verb = fe['verb'] as String? ?? '';
    final fa   = fe['fa']   as String? ?? '';
    final steps = <String>[
      fe['step1'] as String? ?? '',
      fe['step2'] as String? ?? '',
      fe['step3'] as String? ?? '',
      fe['step4'] as String? ?? '',
    ].where((s) => s.isNotEmpty).toList();

    return Container(
      margin : const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color       : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (verb.isNotEmpty)
            Text(verb,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
          ...steps.asMap().entries.map((e) => Text(
                '${e.key + 1}. ${e.value}',
                style: const TextStyle(fontSize: 12),
              )),
          if (fa.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(fa,
                style: TextStyle(
                    fontSize: 12, color: cs.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}

// ─── tips ─────────────────────────────────────────────────────────────────────

class _Tips extends StatelessWidget {
  const _Tips(this.s);
  final Map<String, dynamic> s;

  @override
  Widget build(BuildContext context) {
    final tips = (s['tips'] as List? ?? []).cast<Map<String, dynamic>>();
    return Column(
      children: tips.map((t) {
        final fa = t['fa'] as String? ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡 ',
                  style: TextStyle(fontSize: 14)),
              Expanded(
                child: Text(fa,
                    style: const TextStyle(fontSize: 13, height: 1.5)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color     : const Color(0xFF6A1B9A),
            ),
      );
}

class _ExplText extends StatelessWidget {
  const _ExplText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(height: 1.6),
      );
}

class _ExampleRow extends StatelessWidget {
  const _ExampleRow({
    required this.de,
    required this.fa,
    this.hint,
    this.note = '',
  });
  final String  de;
  final String  fa;
  final String? hint;
  final String  note;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hint != null && hint!.isNotEmpty)
            Text(hint!,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color     : Color(0xFF6A1B9A))),
          Text('· $de',
              style: const TextStyle(fontStyle: FontStyle.italic)),
          Text(fa,
              style:
                  TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          if (note.isNotEmpty)
            Text(note,
                style: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color    : Color(0xFF00695C))),
        ],
      ),
    );
  }
}

class _PrepChip extends StatelessWidget {
  const _PrepChip(this.label, this.color);
  final String label;
  final Color  color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color       : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border      : Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize  : 11,
                fontWeight: FontWeight.w700,
                color     : color)),
      );
}
