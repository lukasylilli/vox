// FILE: lib/features/wortschatz/controllers/wortschatz_filter_controller.dart
// PHASE: فاز F.2 / F.2c (Lukas, 2026-10-14)
// PURPOSE: Der gewählte Filter von «Alle Wörter» — geteilt zwischen Liste und
//          Filterseite und auf dem Gerät gemerkt (F.2c: beim nächsten Öffnen
//          sind die letzten Filter wieder da).
//          Schlüssel `vox_wortschatz_filter_v1` — bewusst mit «vox_», damit er
//          nie mit einem Root-in-Schlüssel kollidiert (beide Apps teilen sich
//          localStorage auf lukasylilli.github.io, siehe PLAN 2026-09-26).
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../vokabular/controllers/vokabular_controller.dart';
import '../data/wortschatz_filter.dart';
import 'word_controller.dart';

const wortschatzFilterSchluessel = 'vox_wortschatz_filter_v1';

class WortschatzFilterNotifier extends StateNotifier<WortschatzFilter> {
  WortschatzFilterNotifier() : super(WortschatzFilter.leer) {
    _laden();
  }

  /// Hat der Nutzer schon etwas geändert, bevor der gespeicherte Stand
  /// geladen war? Dann gewinnt seine Änderung.
  bool _geaendert = false;

  Future<void> _laden() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roh = prefs.getString(wortschatzFilterSchluessel);
      if (roh == null || _geaendert || !mounted) return;
      final json = jsonDecode(roh);
      if (json is Map<String, dynamic>) {
        state = WortschatzFilter.fromJson(json);
      }
    } catch (_) {
      // Kaputter Eintrag ⇒ einfach ohne Filter starten.
    }
  }

  Future<void> _setzen(WortschatzFilter neu) async {
    _geaendert = true;
    state = neu;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(wortschatzFilterSchluessel, jsonEncode(neu.toJson()));
  }

  Future<void> umschalten(FilterBereich b, String wert) =>
      _setzen(state.umschalten(b, wert));

  Future<void> entfernen(FilterBereich b, String wert) =>
      _setzen(state.mitBereich(b, {...state.werte(b)}..remove(wert)));

  Future<void> allesLoeschen() => _setzen(WortschatzFilter.leer);
}

final wortschatzFilterProvider =
    StateNotifierProvider<WortschatzFilterNotifier, WortschatzFilter>(
        (_) => WortschatzFilterNotifier());

/// [WortschatzBasis] für Liste und Filterseite aus den Providern — `null`,
/// solange die alten Wörter noch laden. Mit Suche kommen die Karten aus
/// [vokabSucheProvider] (inkl. gebeugter Formen); bis der geladen ist, die
/// einfachen Text-Treffer ([vokabKartePasst]).
WortschatzBasis? wortschatzBasisLesen(WidgetRef ref, String query) {
  final woerter = ref.watch(allWordsProvider).valueOrNull;
  if (woerter == null) return null;
  final karten = ref.watch(vokabIndexProvider).valueOrNull ??
      const <Map<String, dynamic>>[];
  final q = query.toLowerCase().trim();
  final kartenTreffer = q.isEmpty
      ? karten
      : (ref.watch(vokabSucheProvider(q)).valueOrNull ??
          [for (final k in karten) if (vokabKartePasst(k, q)) k]);
  return wortschatzBasis(
    alleWoerter: [for (final w in woerter) w.toModel()],
    kartenTreffer: kartenTreffer,
    query: q,
  );
}
