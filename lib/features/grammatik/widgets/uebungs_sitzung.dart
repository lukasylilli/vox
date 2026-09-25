// FILE: lib/features/grammatik/widgets/uebungs_sitzung.dart
// PHASE: فاز G → G7a (2026-09-16)
// DEPS: uebung_karte.dart
// PURPOSE: Eine Folge von Übungen nacheinander: Fortschritt oben, eine
//          Übung, „Weiter" nach dem Prüfen, am Ende das Ergebnis mit
//          „Nochmal" und „Zurück". Wiederverwendbar — G7b (Niveau-Test)
//          nutzt dieselbe Sitzung mit einer anderen Übungsliste.
//
// G7b (2026-09-16): optional Bestehensgrenze + „neuer Test" (onNochmal).
//
// Die Sitzung selbst speichert NICHTS: Übungen sind Training, kein
// Lernstand. T.1 (2026-09-25): Wer ein Ergebnis dauerhaft braucht (der
// Niveau-Test), bekommt es über [UebungsSitzung.onFertig] und speichert es
// selbst über die Nutzerdaten (Vertrag Fassung 5).
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/vox_colors.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_button.dart';
import '../models/grammatik_uebung.dart';
import 'uebung_karte.dart';

/// Schlüssel des „Weiter"-Knopfs (für Tests).
const uebungWeiterKey = ValueKey<String>('uebung-weiter');

class UebungsSitzung extends StatefulWidget {
  const UebungsSitzung({
    super.key,
    required this.uebungen,
    required this.onZurueck,
    this.bestehensQuote,
    this.onNochmal,
    this.onFertig,
  });

  final List<GrammatikUebung> uebungen;
  final VoidCallback onZurueck;

  /// Optional (G7b): Anteil richtiger Antworten zum Bestehen, z. B. 0.7.
  final double? bestehensQuote;

  /// Optional (G7b): statt dieselben Übungen zu wiederholen, zieht der
  /// Aufrufer neue (Niveau-Test). Er baut die Sitzung dann mit neuem Key auf.
  final VoidCallback? onNochmal;

  /// Optional (T.1): einmal je Durchgang, sobald das Ergebnis feststeht.
  final void Function(int richtig, int gesamt)? onFertig;

  @override
  State<UebungsSitzung> createState() => _UebungsSitzungState();
}

class _UebungsSitzungState extends State<UebungsSitzung> {
  int _index = 0;
  int _richtig = 0;
  bool _geprueft = false;
  bool _fertig = false;

  /// Zählt Durchgänge, damit „Nochmal" jede Karte frisch aufbaut.
  int _durchgang = 0;

  void _neuStart() => setState(() {
        _index = 0;
        _richtig = 0;
        _geprueft = false;
        _fertig = false;
        _durchgang++;
      });

  void _weiter() {
    final ende = _index + 1 >= widget.uebungen.length;
    setState(() {
      if (ende) {
        _fertig = true;
      } else {
        _index++;
        _geprueft = false;
      }
    });
    if (ende) widget.onFertig?.call(_richtig, widget.uebungen.length);
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.uebungen.length;
    if (n == 0) return const SizedBox.shrink();
    if (_fertig) return _ergebnis(context, n);

    final u = widget.uebungen[_index];
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        Text(
          AppL10n.tf(context, 'uebung_progress',
              {'i': '${_index + 1}', 'n': '$n'}),
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: AppSizes.xs),
        LinearProgressIndicator(
          value: (_index + (_geprueft ? 1 : 0)) / n,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        const SizedBox(height: AppSizes.lg),
        UebungKarte(
          key: ValueKey('${u.schluessel}#$_durchgang'),
          uebung: u,
          onGeprueft: (ok) => setState(() {
            _geprueft = true;
            if (ok) _richtig++;
          }),
        ),
        if (_geprueft) ...[
          const SizedBox(height: AppSizes.lg),
          VoxButton.primary(
            key: uebungWeiterKey,
            label: AppL10n.t(context,
                _index + 1 >= n ? 'result' : 'next'),
            expand: true,
            onPressed: _weiter,
          ),
        ],
      ],
    );
  }

  Widget _ergebnis(BuildContext context, int n) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final quote = widget.bestehensQuote;
    final bestanden = quote == null ? null : _richtig / n >= quote;
    final farbe = switch (bestanden) {
      true => VoxColors.success,
      false => cs.error,
      null => cs.primary,
    };
    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        const SizedBox(height: AppSizes.xl),
        Icon(
          bestanden == false
              ? Icons.replay_circle_filled_rounded
              : Icons.emoji_events_rounded,
          size: 72,
          color: farbe,
        ),
        const SizedBox(height: AppSizes.md),
        Text(
          AppL10n.tf(context, 'uebung_result', {'r': '$_richtig', 'n': '$n'}),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700, color: farbe),
        ),
        if (bestanden != null) ...[
          const SizedBox(height: AppSizes.sm),
          Text(
            AppL10n.t(context,
                bestanden ? 'niveautest_passed' : 'niveautest_failed'),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(color: farbe),
          ),
        ],
        const SizedBox(height: AppSizes.xl),
        VoxButton.primary(
          label: AppL10n.t(
              context,
              widget.onNochmal != null && widget.bestehensQuote != null
                  ? 'niveautest_new'
                  : 'uebung_repeat'),
          icon: Icons.refresh_rounded,
          expand: true,
          onPressed: widget.onNochmal ?? _neuStart,
        ),
        const SizedBox(height: AppSizes.sm),
        VoxButton.secondary(
          label: AppL10n.t(context, 'uebung_back'),
          expand: true,
          onPressed: widget.onZurueck,
        ),
      ],
    );
  }
}
