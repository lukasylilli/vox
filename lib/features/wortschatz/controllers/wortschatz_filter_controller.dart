// FILE: lib/features/wortschatz/controllers/wortschatz_filter_controller.dart
// PHASE: فاز F.2 / F.2c (Lukas, 2026-10-14)
// PURPOSE: Der gewählte Filter von «Alle Wörter» — geteilt zwischen Liste und
//          Filterseite und auf dem Gerät gemerkt (F.2c: beim nächsten Öffnen
//          sind die letzten Filter wieder da).
//          Schlüssel `vox_wortschatz_filter_v1` — bewusst mit «vox_», damit er
//          nie mit einem Root-in-Schlüssel kollidiert (beide Apps teilen sich
//          localStorage auf lukasylilli.github.io, siehe PLAN 2026-09-26).
import '../../../core/backup/nutzer_zustand.dart' show LeitnerStand;
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/app_database.dart';
import '../../categories/controllers/category_controller.dart';
import '../../vokabular/controllers/vokabular_controller.dart';
import '../data/vox_buecher.dart';
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

  /// Nur dieser eine Wert (Klick auf ein Etikett der Wort-Seite, F.6b):
  /// alle anderen Filter weg, damit genau «alle Pflege-Wörter» erscheinen.
  Future<void> nurDieser(FilterBereich b, String wert) =>
      _setzen(WortschatzFilter.leer.mitBereich(b, {wert}));
}

final wortschatzFilterProvider =
    StateNotifierProvider<WortschatzFilterNotifier, WortschatzFilter>(
        (_) => WortschatzFilterNotifier());

// ─── Bücher und eigene Kategorien (فاز F.4) ──────────────────────────────────

/// Die fertigen VOX-Bücher (assets/buecher/buecher.json).
final voxBuecherProvider = FutureProvider<List<VoxBuch>>((ref) async =>
    voxBuecherLesen(await rootBundle.loadString(voxBuecherAsset)));

/// Alle Zuordnungen alter Wörter zu Büchern (drift WordBooks).
final alleWortBuecherProvider = StreamProvider<List<WordBook>>(
    (ref) => ref.watch(wordDaoProvider).watchAllWordBooks());

/// Bücher + eigene Kategorien, wie sie gerade sind. Was noch lädt, fehlt
/// einfach (der Drawer füllt sich, sobald es da ist).
///   · Bücher: Reihenfolge wie in buecher.json; alte Wörter über den Namen
///     des Decks (`alt_buch`) in der Tabelle Books.
///   · Kategorien: die Notizbuch-Decks (X.2: eine Tabelle für alles),
///     alphabetisch. Ein Deck kann Karten UND alte Wörter enthalten. Die id
///     der Gruppe bleibt wie vor X.2 (`archiv:<id>` bzw. `eigen:…`) — sie
///     steht in gespeicherten Filtern.
WortschatzZugehoerigkeit wortschatzZugehoerigkeitLesen(WidgetRef ref) {
  final buecher = ref.watch(voxBuecherProvider).valueOrNull ?? const [];
  final altBuecher = ref.watch(allBooksProvider).valueOrNull ?? const [];
  final wortBuecher =
      ref.watch(alleWortBuecherProvider).valueOrNull ?? const [];
  final altBuchId = {for (final b in altBuecher) b.name: b.id};

  final decks = ref.watch(allCategoriesProvider).valueOrNull ?? const [];
  final zuordnung =
      ref.watch(deckZuordnungenProvider).valueOrNull ?? const [];
  // Alte Wörter stehen in den Decks mit ihrer Text-id; die Liste filtert sie
  // nach ihrer Nummer.
  final altNummer = {
    for (final w in ref.watch(allWordsProvider).valueOrNull ?? const <Word>[])
      LeitnerStand.eigenesWort(w.german, w.wordType): w.id,
  };

  final kategorien = <FilterGruppe>[
    for (final d in decks)
      FilterGruppe(
        id: d.id.startsWith('eigen:') ? d.id : 'archiv:${d.id}',
        name: d.name,
        karten: {
          for (final z in zuordnung)
            if (z.deckId == d.id && !z.wortId.startsWith('eigen:')) z.wortId,
        },
        altWoerter: {
          for (final z in zuordnung)
            if (z.deckId == d.id) ?altNummer[z.wortId],
        },
      ),
  ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  return WortschatzZugehoerigkeit(
    buecher: [
      for (final b in buecher)
        FilterGruppe(
          id: b.id,
          name: b.name,
          karten: b.karten.toSet(),
          altWoerter: {
            if (b.altBuch != null && altBuchId[b.altBuch] != null)
              for (final z in wortBuecher)
                if (z.bookId == altBuchId[b.altBuch]) z.wordId,
          },
        ),
    ],
    kategorien: kategorien,
  );
}

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
    zugehoerigkeit: wortschatzZugehoerigkeitLesen(ref),
  );
}
