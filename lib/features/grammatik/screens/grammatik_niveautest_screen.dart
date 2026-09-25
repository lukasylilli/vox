// FILE: lib/features/grammatik/screens/grammatik_niveautest_screen.dart
// PHASE: فاز G → G7b (2026-09-16)
// DEPS: grammatik_niveautest.dart, uebungs_sitzung.dart
// PURPOSE: Kombinierter Niveau-Test — Route /grammatik/quiz-niveau/:level
//          (AppRoutes.grammatikNiveauTest). Erst eine Einführung (Anzahl,
//          Bestehensgrenze), dann die Fragen; „آزمون تازه" zieht neue Fragen.
//          Einstieg: Karte oben in der Niveau-Ansicht des Katalogs
//          (NiveauTestKarte).
// T.1 (2026-09-25): Am Ende wird das Ergebnis gespeichert
//          (`pruefungsErgebnisseProvider`, Art `grammatik_niveau`) — nur
//          Punkte, nie die Antworten.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/backup/pruefungs_ergebnis.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/vox_colors.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/widgets/vox_empty_state.dart';
import '../../pruefungen/controllers/pruefungs_ergebnisse_controller.dart';
import '../controllers/grammatik_lektion_controller.dart';
import '../models/grammatik_lektion.dart';
import '../models/grammatik_niveautest.dart';
import '../models/grammatik_uebung.dart';
import '../widgets/uebungs_sitzung.dart';

/// Alles, was der Test braucht — oder null, solange etwas lädt.
/// Liefert einen leeren Vorrat, wenn es für das Niveau keinen Test gibt.
typedef _TestDaten = ({
  GrammatikNiveauTest? test,
  List<GrammatikUebung> vorrat,
  Map<String, GrammatikLektion> lektionen,
  Map<String, List<GrammatikUebung>> uebungen,
});

_TestDaten? _testDaten(WidgetRef ref, String niveau) {
  final test = ref.watch(grammatikNiveauTestProvider);
  final lektionen = ref.watch(grammatikLektionenProvider);
  final uebungen = ref.watch(grammatikUebungenProvider);
  if (test.isLoading || lektionen.isLoading || uebungen.isLoading) return null;
  final t = test.valueOrNull;
  final l = lektionen.valueOrNull;
  final u = uebungen.valueOrNull;
  if (t == null || l == null || u == null) {
    return (
      test: t,
      vorrat: const <GrammatikUebung>[],
      lektionen: const <String, GrammatikLektion>{},
      uebungen: const <String, List<GrammatikUebung>>{},
    );
  }
  // Ohne Zufall: nur die festen Quell-Übungen — reicht für „gibt es einen
  // Test?" und die Anzeige der Fragenzahl.
  return (test: t, vorrat: t.vorrat(niveau, l, u), lektionen: l, uebungen: u);
}

class GrammatikNiveauTestScreen extends ConsumerStatefulWidget {
  const GrammatikNiveauTestScreen({super.key, required this.level, this.zufall});

  final String level;

  /// Nur für Tests: fester Zufall.
  final Random? zufall;

  @override
  ConsumerState<GrammatikNiveauTestScreen> createState() =>
      _GrammatikNiveauTestScreenState();
}

class _GrammatikNiveauTestScreenState
    extends ConsumerState<GrammatikNiveauTestScreen> {
  late final Random _zufall = widget.zufall ?? Random();
  List<GrammatikUebung>? _fragen;
  int _runde = 0;
  DateTime? _beginn;

  String get _niveau => widget.level.toUpperCase();

  void _starte(GrammatikNiveauTest test, _TestDaten daten) {
    // Mit Zufall: Quell-Übungen + frisch erzeugte aus den Beispielsätzen.
    final vorrat = test.vorrat(_niveau, daten.lektionen, daten.uebungen,
        zufall: _zufall);
    setState(() {
      _fragen = test.ziehe(vorrat, _zufall);
      _runde++;
      _beginn = DateTime.now();
    });
  }

  /// T.1: Ergebnis dauerhaft ablegen. Fassung 1 = 10 Fragen je Niveau aus
  /// den Grammatik-Übungen, Grenze aus `grammatik_niveautest.json`.
  void _gespeichert(GrammatikNiveauTest test, int richtig, int gesamt) {
    final jetzt = DateTime.now();
    final beginn = _beginn;
    ref.read(pruefungsErgebnisseProvider.notifier).merken(PruefungsErgebnis(
          id: neuePruefungsId(),
          art: pruefungsArtGrammatikNiveau,
          niveau: _niveau,
          fassung: 1,
          am: jetzt.toUtc(),
          dauerSekunden:
              beginn == null ? null : jetzt.difference(beginn).inSeconds,
          punkte: richtig,
          maxPunkte: gesamt,
          bestanden: richtig / gesamt >= test.bestehensQuote,
          teile: {
            teilGrammatik: PruefungsTeil(punkte: richtig, maxPunkte: gesamt),
          },
        ));
  }

  void _zurueck() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.grammatikKatalog('niveau', _niveau.toLowerCase()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final daten = _testDaten(ref, _niveau);
    final titel = AppL10n.tf(context, 'niveautest_title', {'x': _niveau});

    Widget body;
    if (daten == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (daten.test == null || daten.vorrat.isEmpty) {
      body = const VoxEmptyState.comingSoon();
    } else if (_fragen == null) {
      body = _Einfuehrung(
        niveau: _niveau,
        test: daten.test!,
        anzahl: min(daten.test!.fragenProNiveau, daten.vorrat.length),
        onStart: () => _starte(daten.test!, daten),
      );
    } else {
      body = UebungsSitzung(
        key: ValueKey('niveautest-$_runde'),
        uebungen: _fragen!,
        bestehensQuote: daten.test!.bestehensQuote,
        onNochmal: () => _starte(daten.test!, daten),
        onZurueck: _zurueck,
        onFertig: (r, n) => _gespeichert(daten.test!, r, n),
      );
    }

    return Scaffold(appBar: AppBar(title: Text(titel)), body: body);
  }
}

class _Einfuehrung extends StatelessWidget {
  const _Einfuehrung({
    required this.niveau,
    required this.test,
    required this.anzahl,
    required this.onStart,
  });

  final String niveau;
  final GrammatikNiveauTest test;
  final int anzahl;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final farbe = VoxColors.cefr(niveau);
    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        const SizedBox(height: AppSizes.xl),
        Icon(Icons.fact_check_rounded, size: 72, color: farbe),
        const SizedBox(height: AppSizes.md),
        Text(
          AppL10n.tf(context, 'niveautest_title', {'x': niveau}),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700, color: farbe),
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          AppL10n.tf(context, 'niveautest_sub', {
            'n': '$anzahl',
            'x': niveau,
            'p': '${test.quoteProzent}',
          }),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSizes.xl),
        VoxButton.primary(
          label: AppL10n.t(context, 'niveautest_start'),
          icon: Icons.play_arrow_rounded,
          expand: true,
          onPressed: onStart,
        ),
      ],
    );
  }
}

/// Einstieg in der Niveau-Ansicht des Katalogs — nur, wenn es für das
/// Niveau einen Test mit mindestens einer Frage gibt.
class NiveauTestKarte extends ConsumerWidget {
  const NiveauTestKarte({super.key, required this.level});

  final String level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final niveau = level.toUpperCase();
    final daten = _testDaten(ref, niveau);
    final test = daten?.test;
    if (daten == null || test == null || daten.vorrat.isEmpty) {
      return const SizedBox.shrink();
    }
    final farbe = VoxColors.cefr(niveau);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: farbe.withValues(alpha: 0.15),
          child: Icon(Icons.fact_check_rounded, color: farbe, size: 20),
        ),
        title: Text(
          AppL10n.tf(context, 'niveautest_title', {'x': niveau}),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(AppL10n.tf(context, 'niveautest_sub', {
          'n': '${min(test.fragenProNiveau, daten.vorrat.length)}',
          'x': niveau,
          'p': '${test.quoteProzent}',
        })),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.push(AppRoutes.grammatikNiveauTest(niveau)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
