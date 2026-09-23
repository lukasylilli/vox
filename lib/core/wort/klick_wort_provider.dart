// FILE: lib/core/wort/klick_wort_provider.dart
// DEPS: vokabular_controller.dart (Wortindex), word_controller.dart (alte
//       Wortdatenbank), wort_form.dart
// PURPOSE: «Welche Einträge gehören zu diesem angetippten Wort?» (L.5f)
//
// QUELLEN, in dieser Reihenfolge — nie beide zugleich:
//   1. Vokabular-Archiv (assets/vocab_index.json): hat das Wort einen oder
//      mehrere Treffer, sind DAS die Treffer. Ziel: Wort-Seite
//      (`/vokabular/wort/:id`, wort_seite_screen.dart).
//   2. Alte Wortdatenbank (drift, Tabelle Words) — nur wenn das Archiv nichts
//      hat. Ziel: deren Detailseite (`/wortschatz/word/:id`). Ein Wort, das in
//      beiden steht, erscheint so nicht doppelt.
//   2b. Gebeugte Form eines Archivworts (assets/vocab_formen/, 2026-09-23).
//   3. Nichts → leere Liste → «nicht im Wörterbuch».
//      Ausnahme: der Wortindex war nicht ladbar ⇒ Fehler statt leerer Liste,
//      damit der Popup «konnte nicht geladen werden» sagt, nicht «fehlt».
//
// Mehrere Treffer (Homographen: «See», «Band», «Reisen»/«reisen») werden ALLE
// gezeigt; gewählt wird nie geraten (Regel 3 des Projekts).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/vokabular/controllers/vokabular_controller.dart';
import '../../features/wortschatz/controllers/word_controller.dart';
import '../constants/app_routes.dart';
import '../models/word_model.dart';
import 'wort_form.dart';

/// Höchstens so viele Treffer je Wort im Popup (Schutz gegen sehr lange Listen).
const int klickWortMaxTreffer = 8;

enum KlickWortQuelle { archiv, datenbank }

/// Ein Eintrag hinter einem angetippten Wort.
class KlickWortTreffer {
  const KlickWortTreffer._(this.quelle, {this.karte, this.wort});

  /// Treffer im Vokabular-Archiv (Index-Eintrag, nicht die volle Karte).
  factory KlickWortTreffer.archiv(Map<String, dynamic> karte) =>
      KlickWortTreffer._(KlickWortQuelle.archiv, karte: karte);

  /// Treffer in der alten Wortdatenbank.
  factory KlickWortTreffer.datenbank(WordModel wort) =>
      KlickWortTreffer._(KlickWortQuelle.datenbank, wort: wort);

  final KlickWortQuelle quelle;
  final Map<String, dynamic>? karte;
  final WordModel? wort;

  /// Die volle Wort-Seite dieses Treffers (zweite Stufe des Klicks).
  String get pfad => quelle == KlickWortQuelle.archiv
      ? AppRoutes.vokabularWort(karte!['id'] as String? ?? '')
      : AppRoutes.wortschatzWordDetail.replaceFirst(':wordId', '${wort!.id}');
}

/// Wortindex nach Schlüssel (siehe wort_form.dart) — einmal gebaut, danach nur
/// noch Nachschlagen. Mehrere Einträge mit demselben Schlüssel sind erlaubt.
final vokabIndexNachSchluesselProvider =
    FutureProvider<Map<String, List<Map<String, dynamic>>>>((ref) async {
  final eintraege = await ref.watch(vokabIndexProvider.future);
  final nachSchluessel = <String, List<Map<String, dynamic>>>{};
  for (final e in eintraege) {
    final wort = e['wort'] as String? ?? '';
    final schluessel = wortSchluessel(wort);
    if (schluessel.isEmpty) continue;
    nachSchluessel.putIfAbsent(schluessel, () => []).add(e);
  }
  return nachSchluessel;
});

/// Treffer für einen fertigen Schlüssel (`wortSchluessel(angetipptesWort)`).
final klickWortTrefferProvider =
    FutureProvider.family<List<KlickWortTreffer>, String>(
        (ref, schluessel) async {
  // Archiv nicht ladbar ⇒ nicht sofort abbrechen: die alte Datenbank kann
  // trotzdem antworten. Findet sie auch nichts, wird der Ladefehler aber
  // WEITERGEGEBEN (L.5f-Nachtrag, 2026-09-23) — sonst hieße es fälschlich
  // «nicht im Wörterbuch», obwohl das Wörterbuch nur nicht geladen war.
  var nachSchluessel = const <String, List<Map<String, dynamic>>>{};
  Object? indexFehler;
  StackTrace? indexStack;
  try {
    nachSchluessel = await ref.watch(vokabIndexNachSchluesselProvider.future);
  } catch (e, st) {
    indexFehler = e;
    indexStack = st;
  }

  final imArchiv = nachSchluessel[schluessel] ?? const [];
  if (imArchiv.isNotEmpty) {
    return [
      for (final karte in imArchiv.take(klickWortMaxTreffer))
        KlickWortTreffer.archiv(karte),
    ];
  }

  // Gebeugte Form eines Archivworts («aalartige» ⇒ «aalartig»,
  // «bot» ⇒ «bieten»/«anbieten») — L.5f-Nachtrag 2026-09-23. Ladefehler der
  // Formen-Tabelle zählen wie Ladefehler des Index (siehe unten).
  try {
    final ueberForm = await ref.watch(vokabNachFormProvider(schluessel).future);
    if (ueberForm.isNotEmpty) {
      return [
        for (final karte in ueberForm.take(klickWortMaxTreffer))
          KlickWortTreffer.archiv(karte),
      ];
    }
  } catch (e, st) {
    indexFehler ??= e;
    indexStack ??= st;
  }

  // Die Suche der Datenbank ist eine Teilstring-Suche — nur Einträge mit
  // GLEICHEM Schlüssel zählen («Hausaufgabe» ist kein Treffer für «Haus»).
  final zeilen = await ref.watch(wordDaoProvider).search(schluessel);
  final ausDatenbank = [
    for (final z in zeilen)
      if (wortSchluessel(z.german) == schluessel)
        KlickWortTreffer.datenbank(z.toModel()),
  ].take(klickWortMaxTreffer).toList();
  if (ausDatenbank.isEmpty && indexFehler != null) {
    Error.throwWithStackTrace(indexFehler, indexStack!);
  }
  return ausDatenbank;
});
