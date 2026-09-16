// FILE: lib/features/grammatik/screens/grammatik_uebung_screen.dart
// PHASE: فاز G → G7a (2026-09-16) · G7c (2026-09-16)
// DEPS: grammatik_lektion_controller.dart, beispiel_uebungen.dart,
//       uebungs_sitzung.dart
// PURPOSE: Übungen einer Grammatik-Lektion — Route
//          /grammatik/lektion/:slug/uebung (AppRoutes.grammatikLektionUebung).
//
// Ein Durchgang = die Quell-Übungen der Lektion + je Beispielsatz eine
// zufällig erzeugte Übung (G7c), alles gemischt. „دوباره از اول" erzeugt und
// mischt neu (Lukas: vielfältig und zufällig).
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_empty_state.dart';
import '../controllers/grammatik_lektion_controller.dart';
import '../models/beispiel_uebungen.dart';
import '../models/grammatik_lektion.dart';
import '../models/grammatik_uebung.dart';
import '../widgets/uebungs_sitzung.dart';

/// Anzahl der Übungen eines Durchgangs (für den Knopf in der Lektion).
int uebungenProDurchgang(GrammatikLektion lek, int quellUebungen) =>
    quellUebungen + BeispielUebungen.anzahl(lek);

/// Übungen eines Durchgangs, gemischt.
List<GrammatikUebung> stelleDurchgangZusammen(
  GrammatikLektion lek,
  List<GrammatikUebung> quelle,
  Random zufall,
) =>
    [...quelle, ...BeispielUebungen.erzeuge(lek, zufall)]..shuffle(zufall);

class GrammatikUebungScreen extends ConsumerStatefulWidget {
  const GrammatikUebungScreen({super.key, required this.slug, this.zufall});

  final String slug;

  /// Nur für Tests: fester Zufall.
  final Random? zufall;

  @override
  ConsumerState<GrammatikUebungScreen> createState() =>
      _GrammatikUebungScreenState();
}

class _GrammatikUebungScreenState extends ConsumerState<GrammatikUebungScreen> {
  late final Random _zufall = widget.zufall ?? Random();
  List<GrammatikUebung>? _durchgang;
  int _runde = 0;

  void _neu(GrammatikLektion lek, List<GrammatikUebung> quelle) {
    _durchgang = stelleDurchgangZusammen(lek, quelle, _zufall);
    _runde++;
  }

  void _zurueck() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.grammatikLektion(widget.slug));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lekAsync = ref.watch(grammatikLektionProvider(widget.slug));
    final quelleAsync =
        ref.watch(grammatikLektionUebungenProvider(widget.slug));
    final lek = lekAsync.valueOrNull;
    final titel = lek?.titleDe ?? '';

    Widget body;
    if (lekAsync.isLoading || quelleAsync.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (quelleAsync.hasError) {
      body = Center(
          child: Text('${AppL10n.t(context, 'error')}: ${quelleAsync.error}'));
    } else {
      final quelle = quelleAsync.valueOrNull ?? const <GrammatikUebung>[];
      if (lek == null) {
        body = quelle.isEmpty
            ? const VoxEmptyState.comingSoon()
            : _sitzung(quelle, null);
      } else {
        if (_durchgang == null) _neu(lek, quelle);
        body = _durchgang!.isEmpty
            ? const VoxEmptyState.comingSoon()
            : _sitzung(_durchgang!, () => setState(() => _neu(lek, quelle)));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titel.isEmpty
              ? AppL10n.t(context, 'practice')
              : AppL10n.tf(context, 'practice_dash', {'x': titel}),
        ),
      ),
      body: body,
    );
  }

  Widget _sitzung(List<GrammatikUebung> liste, VoidCallback? nochmal) =>
      UebungsSitzung(
        key: ValueKey('lektion-uebung-$_runde'),
        uebungen: liste,
        onNochmal: nochmal,
        onZurueck: _zurueck,
      );
}
