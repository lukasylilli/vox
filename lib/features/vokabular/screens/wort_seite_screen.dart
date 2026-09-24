// FILE: lib/features/vokabular/screens/wort_seite_screen.dart
// PURPOSE: Wort-Seite — vollständige Ansicht einer Karte (Schema 3.0, فاز V Stufe ۴).
//          Kopf (Symbol + Wort + IPA + Niveau) → Übersetzung (aktive Sprache) →
//          Actions → Beispiele → Details je Wortart → Synonyme/Antonyme/Komposita →
//          Wortnetz (klickbar: vorhanden → push nächste Wort-Seite, Ketten-Navigation;
//          fehlt → Dialog mit Suche). IDs der Wortnetz-Einträge werden über vokabId()
//          abgeleitet — Schema 2.0 speichert kein id_ref (deterministisch, Regel 5).
//          Kopf und Abschnitte: widgets/wort_karte_inhalt.dart (EINE Quelle, auch
//          für die erweiterte alte Seite).
//
// L.4b (Lukas, 2026-09-24): Gehört die Karte zu einem Wort, das schon vorher in
//   der App war (altes App-Wort, drift), ist DESSEN Seite die einzige Seite des
//   Worts — sie wird um diese Karte erweitert (word_detail_screen.dart). Diese
//   Route zeigt dann die alte Seite; jeder Link (Wortnetz, Popup, Deck) landet
//   so auf derselben Seite. Paarung: features/wortschatz/data/altwort_karte.dart.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_l10n.dart';
import '../../wortschatz/controllers/altwort_karte_provider.dart';
import '../../wortschatz/screens/word_detail_screen.dart';
import '../controllers/vokabular_controller.dart';
import '../widgets/wort_actions.dart';
import '../widgets/wort_karte_inhalt.dart';

class WortSeiteScreen extends ConsumerWidget {
  final String wortId;
  const WortSeiteScreen({super.key, required this.wortId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // L.4b: altes App-Wort zu dieser Karte? ⇒ dessen (erweiterte) Seite.
    // Ist die Paarung nicht ladbar, bleibt es bei der Karten-Seite — die
    // Karte ist trotzdem vollständig sichtbar, nichts geht verloren.
    final zuordnung = ref.watch(altwortZuordnungProvider);
    if (zuordnung.isLoading && !zuordnung.hasValue) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final altesWort = zuordnung.valueOrNull?.karteZuWort[wortId];
    if (altesWort != null) return WordDetailScreen(wordId: altesWort);

    // V.2: die volle Karte wird erst hier geladen (eine Datei); für die
    // Wortnetz-Links genügt der Index (gibt es das Wort?).
    final karteAsync = ref.watch(vokabKarteProvider(wortId));
    final byId = ref.watch(vokabIndexByIdProvider).valueOrNull ??
        const <String, Map<String, dynamic>>{};

    return karteAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (card) {
        if (card == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
                child: Text(AppL10n.t(context, 'no_words_found'),
                    style: Theme.of(context).textTheme.bodyMedium)),
          );
        }
        return _WortSeiteBody(card: card, byId: byId);
      },
    );
  }
}

class _WortSeiteBody extends StatelessWidget {
  final Map<String, dynamic> card;

  /// id → Index-Eintrag (NICHT volle Karten) — nur für „gibt es das Wort?".
  final Map<String, Map<String, dynamic>> byId;
  const _WortSeiteBody({required this.card, required this.byId});

  @override
  Widget build(BuildContext context) {
    final wort = card['wort'] as String? ?? '';
    final teile = wort.split(' ');
    final lemma = card['wortart'] == 'nomen' && teile.length > 1
        ? teile.sublist(1).join(' ')
        : wort;

    return Scaffold(
      appBar: AppBar(title: Text(lemma)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Kopf ──
          WortKarteKopf(card: card),
          const SizedBox(height: 14),
          WortActions(card: card),

          // ── Beispiele … Wortnetz … Meine Notiz ──
          WortKarteAbschnitte(card: card, byId: byId),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
