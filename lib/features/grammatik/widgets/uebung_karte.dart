// FILE: lib/features/grammatik/widgets/uebung_karte.dart
// PHASE: فاز G → G7a (2026-09-16)
// DEPS: grammatik_uebung.dart, vox_button.dart, app_l10n.dart
// PURPOSE: EINE Grammatik-Übung zeigen und prüfen — alle fünf Arten der
//          Quelle. Ob eine Antwort richtig ist, entscheidet nur das Modell
//          (GrammatikUebung.pruefe…); hier wird nur gezeigt.
//
// Deutscher Text steht immer links-nach-rechts (auch in der FA-Oberfläche) —
// sonst würden Kärtchen und Sätze rückwärts angeordnet.
// [onGeprueft] wird GENAU EINMAL aufgerufen, sobald die Übung bewertet ist.
// G7c (2026-09-16): auch die Arten aus Beispielsätzen (bedeutung · satzWahl ·
// richtigFalsch · Satzbau mit Vorgabe · Zuordnung Satz ↔ Bedeutung).
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/vox_colors.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_button.dart';
import '../models/beispiel_uebungen.dart';
import '../models/grammatik_uebung.dart';
import '../../../core/widgets/deutsch_text.dart';

/// Schlüssel des „Prüfen"-Knopfs (für Tests).
const uebungPruefenKey = ValueKey<String>('uebung-pruefen');

/// Schlüssel einer Wahlmöglichkeit (für Tests) — [wert] ist der Options-Wert.
ValueKey<String> uebungOptionKey(String wert) => ValueKey('option-$wert');

class UebungKarte extends StatefulWidget {
  const UebungKarte({
    super.key,
    required this.uebung,
    required this.onGeprueft,
  });

  final GrammatikUebung uebung;
  final ValueChanged<bool> onGeprueft;

  @override
  State<UebungKarte> createState() => _UebungKarteState();
}

class _UebungKarteState extends State<UebungKarte> {
  /// null = noch nicht bewertet.
  bool? _richtig;

  // Auswahl (multipleChoice / fillBlank)
  late final List<String> _optionen;
  String? _gewaehlt;

  // Reihenfolge (wordOrder): Indizes in uebung.woerter — Indizes statt
  // Wörter, weil ein Wort mehrfach vorkommen kann („er", „er").
  final List<int> _gelegt = [];

  // Umformung (transform)
  final TextEditingController _eingabe = TextEditingController();

  // Zuordnung (matching): linker Eintrag → gewählter rechter Wert
  final Map<String, String> _zuordnung = {};

  GrammatikUebung get _u => widget.uebung;

  @override
  void initState() {
    super.initState();
    final o = List<String>.of(_u.optionen);
    // fillBlank: Lösung steht im Modell vorn ⇒ mischen, aber für jede Übung
    // immer gleich (stabil über Neuaufbau und in Tests).
    // multipleChoice: Reihenfolge der Quelle (dort schon gemischt).
    if (_u.art == UebungsArt.fillBlank) {
      o.shuffle(Random(_u.id.hashCode));
    }
    _optionen = o;
    _eingabe.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _eingabe.dispose();
    super.dispose();
  }

  void _bewerte(bool richtig) {
    if (_richtig != null) return;
    setState(() => _richtig = richtig);
    widget.onGeprueft(richtig);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final u = _u;
    final istWahlFrage = u.art == UebungsArt.multipleChoice;
    final gross = theme.textTheme.titleMedium
        ?.copyWith(fontWeight: FontWeight.w700, height: 1.5);
    final auftrag = u.aufgabeKey != null
        ? AppL10n.t(context, u.aufgabeKey!)
        : AppL10n.meaning(context, fa: u.aufgabeFa, en: u.aufgabeEn);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Auftrag ────────────────────────────────────────────────────
        if (!istWahlFrage && u.aufgabeDe.isNotEmpty)
          _Deutsch(u.aufgabeDe,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        Text(
          auftrag,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: AppSizes.md),

        // ── Übung ──────────────────────────────────────────────────────
        switch (u.art) {
          UebungsArt.multipleChoice ||
          UebungsArt.fillBlank =>
            _auswahl(context,
                frage: _Deutsch(istWahlFrage ? u.aufgabeDe : u.satz,
                    style: gross)),
          UebungsArt.bedeutung =>
            _auswahl(context, frage: _Deutsch(u.satz, style: gross)),
          UebungsArt.satzWahl => _auswahl(context,
              frage: Text(
                  AppL10n.meaning(context,
                      fa: u.beispielFa, en: u.beispielEn),
                  style: gross)),
          UebungsArt.richtigFalsch => _auswahl(context,
              frage: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Deutsch(u.satz, style: gross),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    '« ${AppL10n.meaning(context, fa: u.bedeutungFa, en: u.bedeutungEn)} »',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: cs.primary),
                  ),
                ],
              )),
          UebungsArt.wordOrder => _reihenfolge(context),
          UebungsArt.transform => _umformung(context),
          UebungsArt.matching => _zuordnen(context),
        },

        // ── Rückmeldung ────────────────────────────────────────────────
        if (_richtig != null) ...[
          const SizedBox(height: AppSizes.md),
          _Rueckmeldung(uebung: u, richtig: _richtig!),
        ],
      ],
    );
  }

  // ── Auswahl: multipleChoice · fillBlank · bedeutung · satzWahl · r/f ────

  /// Anzeige einer Option: deutscher Wert, übersetzte Bedeutung oder
  /// richtig/falsch.
  (String, bool) _optionText(BuildContext context, String o) {
    final u = _u;
    if (u.art == UebungsArt.richtigFalsch) {
      return (
        AppL10n.t(context,
            o == BeispielUebungen.richtig ? 'bsp_true' : 'bsp_false'),
        false,
      );
    }
    final i = u.optionen.indexOf(o);
    if (u.optionenFa.isNotEmpty && i >= 0) {
      return (
        AppL10n.meaning(context, fa: u.optionenFa[i], en: u.optionenEn[i]),
        false,
      );
    }
    return (o, true);
  }

  Widget _auswahl(BuildContext context, {required Widget frage}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        frage,
        const SizedBox(height: AppSizes.md),
        for (final o in _optionen)
          KeyedSubtree(
            key: uebungOptionKey(o),
            child: Builder(builder: (context) {
              final (text, deutsch) = _optionText(context, o);
              final knopf = VoxOptionButton(
                label: text,
                state: _zustand(o),
                onPressed: _richtig != null
                    ? null
                    : () {
                        _gewaehlt = o;
                        _bewerte(_u.pruefeWahl(o));
                      },
              );
              return deutsch
                  ? Directionality(
                      textDirection: TextDirection.ltr, child: knopf)
                  : knopf;
            }),
          ),
      ],
    );
  }

  VoxOptionState _zustand(String o) {
    if (_richtig == null) return VoxOptionState.idle;
    if (o == _u.loesung) return VoxOptionState.correct;
    if (o == _gewaehlt) return VoxOptionState.wrong;
    return VoxOptionState.idle;
  }

  // ── wordOrder ───────────────────────────────────────────────────────────

  Widget _reihenfolge(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fertig = _richtig != null;
    final frei = [
      for (var i = 0; i < _u.woerter.length; i++)
        if (!_gelegt.contains(i)) i,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_u.ausBeispiel)
          Text(
            AppL10n.meaning(context, fa: _u.beispielFa, en: _u.beispielEn),
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700, height: 1.5),
          )
        else
          Text(AppL10n.t(context, 'uebung_order_hint'),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: AppSizes.sm),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // gelegter Satz
              Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
                ),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    // fester Satzanfang (G7c) — nicht verschiebbar
                    if (_u.vorgabe.isNotEmpty)
                      Chip(
                        label: DeutschText(ganzeZeile: false, _u.vorgabe,
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        backgroundColor: cs.secondaryContainer,
                      ),
                    for (final i in _gelegt)
                      ActionChip(
                        key: ValueKey('gelegt-$i'),
                        label: Text(_u.woerter[i]),
                        backgroundColor: cs.primaryContainer,
                        onPressed: fertig
                            ? null
                            : () => setState(() => _gelegt.remove(i)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.md),
              // freie Kärtchen
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final i in frei)
                    ActionChip(
                      key: ValueKey('frei-$i'),
                      label: Text(_u.woerter[i]),
                      onPressed: fertig
                          ? null
                          : () => setState(() => _gelegt.add(i)),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (!fertig) ...[
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: VoxButton.primary(
                  key: uebungPruefenKey,
                  label: AppL10n.t(context, 'check'),
                  onPressed: _gelegt.isEmpty
                      ? null
                      : () => _bewerte(_u.pruefeReihenfolge(
                          [for (final i in _gelegt) _u.woerter[i]])),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              VoxButton.text(
                label: AppL10n.t(context, 'uebung_reset'),
                onPressed: _gelegt.isEmpty
                    ? null
                    : () => setState(_gelegt.clear),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Anzeige eines rechten Werts (übersetzt, falls das Paar es vorsieht).
  String _rechtsText(BuildContext context, String wert) {
    for (final p in _u.paare) {
      if (p.rechts == wert && p.rechtsUebersetzt) {
        return AppL10n.meaning(context, fa: p.rechtsFa, en: p.rechtsEn);
      }
    }
    return wert;
  }

  // ── transform ───────────────────────────────────────────────────────────

  Widget _umformung(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final u = _u;
    final fertig = _richtig != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Deutsch(u.satz,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700, height: 1.5)),
        const SizedBox(height: AppSizes.xs),
        if (u.anweisungDe.isNotEmpty)
          _Deutsch('→ ${u.anweisungDe}',
              style: theme.textTheme.bodyMedium?.copyWith(color: cs.primary)),
        if (u.anweisungFa.isNotEmpty || u.anweisungEn.isNotEmpty)
          Text(
            AppL10n.meaning(context, fa: u.anweisungFa, en: u.anweisungEn),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
        const SizedBox(height: AppSizes.md),
        Directionality(
          textDirection: TextDirection.ltr,
          child: TextField(
            controller: _eingabe,
            enabled: !fertig,
            minLines: 1,
            maxLines: 3,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: AppL10n.t(context, 'uebung_type_hint'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
            onSubmitted: (t) {
              if (t.trim().isNotEmpty) _bewerte(u.pruefeUmformung(t));
            },
          ),
        ),
        if (!fertig) ...[
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: VoxButton.primary(
                  key: uebungPruefenKey,
                  label: AppL10n.t(context, 'check'),
                  onPressed: _eingabe.text.trim().isEmpty
                      ? null
                      : () => _bewerte(u.pruefeUmformung(_eingabe.text)),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              // Lösung ansehen zählt als nicht gelöst.
              VoxButton.text(
                label: AppL10n.t(context, 'show_answer'),
                onPressed: () => _bewerte(false),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ── matching ────────────────────────────────────────────────────────────

  Widget _zuordnen(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final u = _u;
    final werte = u.rechteWerte;
    final fertig = _richtig != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppL10n.t(context, 'uebung_match_hint'),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: AppSizes.sm),
        for (final (pi, p) in u.paare.indexed)
          Card(
            margin: const EdgeInsets.only(bottom: AppSizes.sm),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: Directionality(
                // Deutsche Werte links-nach-rechts; übersetzte Bedeutungen
                // in der Richtung der Oberfläche.
                textDirection: p.rechtsUebersetzt
                    ? Directionality.of(context)
                    : TextDirection.ltr,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _Deutsch(p.links,
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        if (fertig)
                          Icon(
                            _zuordnung[p.links] == p.rechts
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            size: 20,
                            color: _zuordnung[p.links] == p.rechts
                                ? VoxColors.success
                                : cs.error,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final w in werte)
                          ChoiceChip(
                            key: ValueKey('wahl-$pi-$w'),
                            label: Text(_rechtsText(context, w)),
                            selected: fertig
                                ? w == p.rechts
                                : _zuordnung[p.links] == w,
                            onSelected: fertig
                                ? null
                                : (_) =>
                                    setState(() => _zuordnung[p.links] = w),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (!fertig) ...[
          const SizedBox(height: AppSizes.sm),
          VoxButton.primary(
            key: uebungPruefenKey,
            label: AppL10n.t(context, 'check'),
            expand: true,
            onPressed: _zuordnung.length < u.paare.length
                ? null
                : () => _bewerte(u.pruefeZuordnung(_zuordnung)),
          ),
        ],
      ],
    );
  }
}

// ─── Rückmeldung nach dem Prüfen ─────────────────────────────────────────────

class _Rueckmeldung extends StatelessWidget {
  const _Rueckmeldung({required this.uebung, required this.richtig});
  final GrammatikUebung uebung;
  final bool richtig;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final farbe = richtig ? VoxColors.success : cs.error;
    // Bei Auswahl und Zuordnung ist die Lösung schon markiert; bei
    // Satzbau und Umformung wird sie hier ausgeschrieben.
    final zeigeLoesung = !richtig &&
        !uebung.ausBeispiel &&
        (uebung.art == UebungsArt.wordOrder ||
            uebung.art == UebungsArt.transform);

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: farbe.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: farbe.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(richtig ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: farbe, size: 20),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  AppL10n.t(
                      context, richtig ? 'correct_feedback' : 'uebung_wrong_answer'),
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: farbe, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (zeigeLoesung) ...[
            const SizedBox(height: AppSizes.sm),
            Text(AppL10n.t(context, 'answer_label'),
                style: theme.textTheme.labelMedium),
            _Deutsch(uebung.loesung,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ],
          if (uebung.ausBeispiel && uebung.beispielDe.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            Text(AppL10n.t(context, 'bsp_means'),
                style: theme.textTheme.labelMedium),
            _Deutsch(uebung.beispielDe,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            Text(
              AppL10n.meaning(context,
                  fa: uebung.beispielFa, en: uebung.beispielEn),
              style: theme.textTheme.bodyMedium,
            ),
          ],
          if (uebung.hatErklaerung) ...[
            const SizedBox(height: AppSizes.sm),
            _Deutsch(uebung.erklaerungDe, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSizes.xs),
            Text(
              AppL10n.meaning(context,
                  fa: uebung.erklaerungFa, en: uebung.erklaerungEn),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant, height: 1.6),
            ),
          ],
        ],
      ),
    );
  }
}

/// Deutscher Text — immer links-nach-rechts, auch in der FA-Oberfläche.
class _Deutsch extends StatelessWidget {
  const _Deutsch(this.text, {this.style});
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: style,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
      );
}
