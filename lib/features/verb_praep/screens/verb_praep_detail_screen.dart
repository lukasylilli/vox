// FILE: lib/features/verb_praep/screens/verb_praep_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/vox_colors.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_badge.dart';
import '../controllers/verb_praep_controller.dart';
import '../models/verb_praep.dart';
import '../widgets/prep_case_badge.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/widgets/deutsch_text.dart';

class VerbPraepDetailScreen extends ConsumerStatefulWidget {
  const VerbPraepDetailScreen({super.key, required this.verbId});
  final int verbId;

  @override
  ConsumerState<VerbPraepDetailScreen> createState() =>
      _VerbPraepDetailScreenState();
}

class _VerbPraepDetailScreenState
    extends ConsumerState<VerbPraepDetailScreen> {

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(verbPraepProvider);

    return allAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error  : (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data   : (verbs) {
        final idx = verbs.indexWhere((v) => v.id == widget.verbId);
        if (idx == -1) {
          return Scaffold(
              body: Center(child: Text(AppL10n.t(context, 'not_found'))));
        }
        final verb = verbs[idx];

        return Scaffold(
          appBar: AppBar(
            title: Text(verb.displayVerb),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            children: [
              // ── header badges ──
              Wrap(
                spacing   : 8,
                runSpacing: 6,
                children  : [
                  PrepCaseBadge(verb.prepositionCase),
                  VoxBadge.level(verb.cefrLevel),
                  _Chip(verb.preposition, const Color(0xFF6A1B9A)),
                  if (verb.reflexive)
                    _Chip('reflexiv', const Color(0xFF00695C)),
                  _Chip(verb.register, _registerColor(verb.register)),
                ],
              ),
              const SizedBox(height: 16),

              // ── principal parts ──
              _PrincipalPartsCard(verb.principalParts),
              const SizedBox(height: 16),

              // ── preposition info ──
              _Section(
                title: 'Präposition',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DeutschRichText(
                      TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '${verb.verbInfinitive} + ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: verb.preposition,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color     : Color(0xFF6A1B9A),
                              fontSize  : 15,
                            ),
                          ),
                          TextSpan(
                            text: ' (${AppL10n.t(context, verb.prepositionCase.labelFa)})',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (verb.woCompound.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _QRow(AppL10n.t(context, 'question_about_thing'), verb.woCompound),
                    ],
                    if (verb.prepositionWithPerson.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _QRow(AppL10n.t(context, 'question_about_person'),
                          verb.prepositionWithPerson),
                    ],
                  ],
                ),
              ),
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
              const SizedBox(height: 16),

              // ── example ──
              _Section(
                title: 'Beispiel',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DeutschText(
                      verb.exampleDe,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppL10n.meaning(context, fa: verb.exampleFa, en: verb.exampleEn),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),

              // ── note — aktive Sprache aus Settings (فاز L), EN-Fallback → FA ──
              if (verb.note.isNotEmpty) ...[
                const SizedBox(height: 16),
                _Section(
                  title: 'Hinweis',
                  child: Text(AppL10n.meaning(context,
                      fa: verb.note,
                      en: verb.noteEn.isNotEmpty ? verb.noteEn : verb.note)),
                ),
              ],

              const SizedBox(height: 24),

              // ── navigation ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (idx > 0)
                    VoxButton.text(
                      label    : AppL10n.t(context, 'previous'),
                      icon     : Icons.arrow_back_rounded,
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => VerbPraepDetailScreen(
                              verbId: verbs[idx - 1].id),
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  if (idx < verbs.length - 1)
                    VoxButton.text(
                      label    : AppL10n.t(context, 'next'),
                      icon     : Icons.arrow_forward_rounded,
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => VerbPraepDetailScreen(
                              verbId: verbs[idx + 1].id),
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _registerColor(String r) => VoxColors.register(r);
}

// ─── Principal parts card ─────────────────────────────────────────────────────

class _PrincipalPartsCard extends StatelessWidget {
  const _PrincipalPartsCard(this.parts);
  final VerbPraepParts parts;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _header('Präsens (3.Sg)', cs),
                _header('Präteritum',     cs),
                _header('Partizip II',    cs),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _cell(parts.praesens3sg, tt),
                _cell(parts.praeteritum, tt),
                _cell(parts.partizipIi,  tt),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String t, ColorScheme cs) => Expanded(
        child: Text(t,
            style: TextStyle(
                fontSize    : 10,
                fontWeight  : FontWeight.w600,
                color       : cs.onSurfaceVariant,
                letterSpacing: 0.2)),
      );

  Widget _cell(String t, TextTheme tt) => Expanded(
        child: Text(t,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      );
}

// ─── Q-row (for wo-compound / preposition with person) ───────────────────────

class _QRow extends StatelessWidget {
  const _QRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text('$label: ',
            style: TextStyle(
                fontSize: 12, color: cs.onSurfaceVariant)),
        Text(value,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700,
                color   : Color(0xFF00695C))),
      ],
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

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
                fontSize    : 11,
                fontWeight  : FontWeight.w700,
                color       : cs.onSurfaceVariant,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.color);
  final String label;
  final Color  color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color       : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border      : Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w700)),
      );
}
