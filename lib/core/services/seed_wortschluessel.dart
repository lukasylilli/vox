// FILE: lib/core/services/seed_wortschluessel.dart
// DEPS: —  (bewusst ohne drift/Flutter, damit `dart run` es benutzen kann)
// EXPORTS: seedQuellen, seedWortschluessel, seedVerloreneSchluessel,
//          seedWortschluesselAusQuellen, mapWordClass
// PHASE: فاز LAUNCH, Schritt L.1e (2026-09-18)
//
// PURPOSE: Die geräteunabhängigen Schlüssel der ~830 mitgelieferten App-Wörter.
//
// WARUM ES DAS GIBT
//   Der Leitner-Stand eines Nutzers wird NICHT über die drift-Zeilennummer
//   gesichert (die ist auf jedem Gerät eine andere), sondern über einen
//   Textschlüssel — siehe `core/backup/nutzer_zustand.dart`:
//
//       eigen:<german>|<wordType>
//
//   Für die Archivkarten (`assets/vocab/`) wacht L.1a darüber, dass eine
//   veröffentlichte id nie verschwindet. Für die vier mitgelieferten
//   Datendateien gab es bis jetzt **keinen** solchen Wächter — obwohl ihr
//   Schlüssel aus genau zwei Feldern entsteht, die man leicht „nebenbei"
//   ändert: dem deutschen Text und der Wortart.
//
//   Ein korrigierter Tippfehler in `verb_infinitive`, ein zusätzliches
//   Leerzeichen in `phrase_de`, ein geändertes `word_class` — und der
//   Schlüssel ist ein anderer. Der Leitner-Eintrag des Nutzers zeigt dann ins
//   Leere: sein Fortschritt zu diesem Wort ist verwaist. Nach der
//   Veröffentlichung lässt sich das nicht mehr stillschweigend reparieren; es
//   bräuchte eine Umzugsregel alt→neu für jedes betroffene Gerät.
//
//   Darum: derselbe Wächter wie L.1a, nur für diese vier Dateien.
//
// ⚠️ EINZIGE QUELLE DER ABLEITUNG
//   Die Regeln hier müssen Zeichen für Zeichen dem entsprechen, was
//   `data_seed_service.dart` in `Words.german` und `Words.wordType` schreibt.
//   `data_seed_service.dart` benutzt dieses Modul, damit es nur EINE Fassung
//   gibt und die beiden nicht auseinanderlaufen können.
import 'dart:convert';

/// Die vier mitgelieferten Datendateien, aus denen `Words` gefüllt wird.
const List<String> seedQuellen = [
  'assets/data/dativ_akkusativ_data.json',
  'assets/data/konnektoren_data.json',
  'assets/data/nvv_data.json',
  'assets/data/praepositionen_data.json',
];

/// `word_class` der Präpositionen-Datei → `Words.wordType`.
/// Zeichengleich zu `DataSeedService._mapWordClass`.
String mapWordClass(String wc) => switch (wc.toLowerCase()) {
      'verb' => 'verb',
      'adjective' => 'adjektiv',
      'adjektiv' => 'adjektiv',
      'noun' => 'nomen',
      'nomen' => 'nomen',
      _ => 'sonstige',
    };

/// Der Schlüssel eines Worts — dieselbe Form wie
/// `LeitnerStand.wortSchluessel` in `core/backup/nutzer_zustand.dart`.
String _schluessel(String german, String wordType) => '$german|$wordType';

/// Schlüssel EINER Quelldatei, aus ihrem Inhalt.
///
/// [pfad] entscheidet über die Ableitung — deshalb genau die Werte aus
/// [seedQuellen] übergeben.
Set<String> seedWortschluesselAusQuelle(String pfad, String inhalt) {
  final liste = (jsonDecode(inhalt) as List).cast<Map<String, dynamic>>();
  final raus = <String>{};

  switch (pfad) {
    case 'assets/data/dativ_akkusativ_data.json':
      for (final j in liste) {
        raus.add(_schluessel(j['verb_infinitive'] as String, 'verb'));
      }
    case 'assets/data/konnektoren_data.json':
      for (final j in liste) {
        raus.add(_schluessel(j['connector'] as String, 'konnektor'));
      }
    case 'assets/data/nvv_data.json':
      for (final j in liste) {
        raus.add(_schluessel(j['phrase_de'] as String, 'sonstige'));
      }
    case 'assets/data/praepositionen_data.json':
      for (final cluster in liste) {
        final mitglieder =
            (cluster['members'] as List).cast<Map<String, dynamic>>();
        for (final m in mitglieder) {
          final lemma = m['lemma'] as String;
          final prep = m['preposition'] as String;
          final wt = mapWordClass(m['word_class'] as String? ?? '');
          // Zeichengleich zu data_seed_service.dart: '$lemma $prep'.
          raus.add(_schluessel('$lemma $prep', wt));
        }
      }
    default:
      throw ArgumentError('Unbekannte Seed-Quelle: $pfad');
  }
  return raus;
}

/// Alle Schlüssel aus allen vier Quellen.
///
/// [lesen] liefert den Inhalt einer Datei zu ihrem Pfad — so bleibt dieses
/// Modul frei von `dart:io` UND von `rootBundle`.
Set<String> seedWortschluessel(String Function(String pfad) lesen) {
  final raus = <String>{};
  for (final q in seedQuellen) {
    raus.addAll(seedWortschluesselAusQuelle(q, lesen(q)));
  }
  return raus;
}

/// Schlüssel, die es veröffentlicht gab und jetzt nicht mehr gibt —
/// geordnet, damit die Fehlermeldung stabil ist.
List<String> seedVerloreneSchluessel(
  Set<String> veroeffentlicht,
  Set<String> jetzt,
) =>
    veroeffentlicht.difference(jetzt).toList()..sort();
