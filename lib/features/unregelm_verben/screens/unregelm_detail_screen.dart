// FILE: lib/features/unregelm_verben/screens/unregelm_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/unregelm_controller.dart';
import '../models/unregelm_verb.dart';
import '../widgets/verb_class_badge.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/widgets/klick_wort_text.dart';
import '../../../core/widgets/deutsch_text.dart';

class UnregelmDetailScreen extends ConsumerWidget {
  const UnregelmDetailScreen({super.key, required this.verbId});
  final int verbId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(unregelVerbenProvider);
    return allAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (list) {
        final idx  = list.indexWhere((v) => v.id == verbId);
        if (idx == -1) {
          return Scaffold(
              body: Center(child: Text(AppL10n.t(context, 'not_found'))));
        }
        final verb = list[idx];
        return _DetailView(verb: verb, allVerbs: list, currentIdx: idx);
      },
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({
    required this.verb,
    required this.allVerbs,
    required this.currentIdx,
  });
  final UnregelmVerb       verb;
  final List<UnregelmVerb> allVerbs;
  final int                currentIdx;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: DeutschText(ganzeZeile: false, verb.verbInfinitive),
        actions: [
          if (currentIdx > 0)
            VoxIconButton(
              icon: Icons.arrow_back_ios_rounded,
              tooltip  : AppL10n.t(context, 'previous'),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => _DetailView(
                    verb      : allVerbs[currentIdx - 1],
                    allVerbs  : allVerbs,
                    currentIdx: currentIdx - 1,
                  ),
                ),
              ),
            ),
          if (currentIdx < allVerbs.length - 1)
            VoxIconButton(
              icon: Icons.arrow_forward_ios_rounded,
              tooltip  : AppL10n.t(context, 'next'),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => _DetailView(
                    verb      : allVerbs[currentIdx + 1],
                    allVerbs  : allVerbs,
                    currentIdx: currentIdx + 1,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // ── Badges row ─────────────────────────────────────────────
          Wrap(
            spacing: 8, runSpacing: 6,
            children: [
              VerbClassBadge(verb.verbClass),
              AuxiliaryBadge(verb.perfektAuxiliary),
              _InfoChip(verb.cefrLevel,
                  color: const Color(0xFF0277BD)),
              if (verb.praesensVowelChange != null)
                _InfoChip(verb.praesensVowelChange!,
                    color: const Color(0xFF00838F)),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // ── Principal parts ────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stammformen',
                    style: tt.labelLarge
                        ?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: AppSizes.sm),
                Directionality(
          // Deutsche Formen-Tabelle ⇒ fest LTR (2026-09-23)
          textDirection: TextDirection.ltr,
          child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: cs.outlineVariant, width: 0.5))),
                      children: [
                        _TH('Präsens (er/sie)'),
                        _TH('Präteritum'),
                        _TH('Partizip II'),
                      ],
                    ),
                    TableRow(children: [
                      _TD(verb.principalParts.praesens3sg,
                          bold: true),
                      _TD(verb.principalParts.praeteritum,
                          bold: true),
                      _TD(verb.principalParts.partizipIi,
                          bold: true),
                    ]),
                  ],
                )),
                const SizedBox(height: AppSizes.sm),
                Row(
                  // Beschriftung und Wert sind beide Deutsch ⇒ LTR.
                  textDirection: TextDirection.ltr,
                  children: [
                    DeutschText('Perfekt: ', ganzeZeile: false,
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    DeutschText(
                      '${verb.perfektAuxiliary.label} + ${verb.principalParts.partizipIi}',
                      style: tt.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.sm),

          // ── Verb info row ──────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DeutschText('Verb-Info', ganzeZeile: false,
                    style: tt.labelLarge
                        ?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: AppSizes.sm),
                _Row('Ablaut-Muster', verb.ablautPattern),
                _Row('Typ', '${verb.verbClass.labelDe} (${AppL10n.t(context, verb.verbClass.labelFa)})'),
                if (verb.prefix != null)
                  _Row('Präfix', '${verb.prefix} (${verb.prefixType ?? ''})'),
                _Row('Basisverb', verb.baseVerb),
                _Row('trennbar', verb.separable ? 'ja' : 'nein'),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.sm),

          // ── Meaning ────────────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppL10n.t(context, 'meaning'),
                    style: tt.labelLarge
                        ?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 6),
                Text(AppL10n.meaning(context,
                    fa: verb.meaningFa, en: verb.meaningEn),
                    style: tt.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          if (verb.exampleDe.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppL10n.t(context, 'example'),
                      style: tt.labelLarge
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  KlickWortText(verb.exampleDe,
                      style: tt.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w500)),
                  if (verb.exampleFa.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(AppL10n.meaning(context, fa: verb.exampleFa,
                        en: verb.exampleEn.isNotEmpty ? verb.exampleEn : verb.exampleFa),
                        style: tt.bodyMedium
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ],
              ),
            ),
          ],

          if (verb.note.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            _SectionCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: cs.primary),
                  const SizedBox(width: 8),
                  // aktive Sprache aus Settings (فاز L), EN-Fallback → FA
                  Expanded(
                    child: Text(
                        AppL10n.meaning(context,
                            fa: verb.note,
                            en: verb.noteEn.isNotEmpty
                                ? verb.noteEn
                                : verb.note),
                        style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant)),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── helpers ──────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child : Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: child,
        ),
      );
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        // Verb-Info: Beschriftung + Wert Deutsch ⇒ LTR (2026-09-23).
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: DeutschText(ganzeZeile: false, label,
                style:
                    tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ),
          Expanded(
            child: DeutschText(ganzeZeile: false, value,
                style: tt.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  const _TH(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: DeutschText(ganzeZeile: false, text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}

class _TD extends StatelessWidget {
  const _TD(this.text, {this.bold = false});
  final String text;
  final bool   bold;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: DeutschText(ganzeZeile: false, text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight:
                    bold ? FontWeight.w700 : FontWeight.normal)),
      );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.label, {required this.color});
  final String label;
  final Color  color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color       : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(5),
          border      : Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize  : 11,
                color     : color,
                fontWeight: FontWeight.w700)),
      );
}
