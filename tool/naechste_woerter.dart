// FILE: tool/naechste_woerter.dart
// PURPOSE: Routine «ده کلمه جدید» (Lukas, 2026-09-23) — nennt die nächsten N
//          Wörter der Wortliste, für die es noch KEINE Karte gibt.
//
//   dart run tool/naechste_woerter.dart            # 10 aus der aktuellen Liste
//   dart run tool/naechste_woerter.dart 5          # 5
//   dart run tool/naechste_woerter.dart --abhaken  # ✓ vor jedes Wort mit Karte
//
// Regeln (siehe PLAN.md → «📚 روال ده کلمه جدید»):
//   · Reihenfolge = Reihenfolge der Datei (alphabetisch) — NIE umsortieren.
//   · Übersprungen wird ein Wort nur, wenn
//       (a) seine Karte schon existiert (assets/vocab/<wortart>/<id>.json —
//           das ist die Wahrheit, nicht das ✓ in der Liste), oder
//       (b) es in [zurueckgestellt] steht (Claude war unsicher ⇒ Lukas fragt).
//   · Listen-Reihenfolge: [listen] (Entscheidung Lukas 2026-09-23). Ist eine
//     Liste durch, geht es automatisch mit der nächsten weiter.
//   · Unsichere Wörter: nicht bauen, in [zurueckgestellt] eintragen, Lukas
//     melden (Lukas 2026-09-23: «genau so weitermachen»).
//   · Feste Regel (Lukas 2026-09-24): Jedes nicht gebaute Wort steht AUCH in
//     PLAN.md → «🏁 مرحله‌ی آخر» (ganz unten, mit Datum/Liste/Grund). Geprüft
//     und gebaut werden sie erst ganz am Ende, wenn alle vier Listen durch
//     sind — nach Lukas' Entscheidung. [zurueckgestellt] und diese Tabelle
//     sind immer identisch.
import 'dart:io';

import 'package:vox/features/vokabular/data/vokab_schema.dart';

/// Wortlisten in der Reihenfolge der Abarbeitung — Entscheidung Lukas
/// (2026-09-23): erst Adjektive, dann unregelmäßige Verben, dann regelmäßige
/// Verben, dann Nomen. Innerhalb jeder Liste: Reihenfolge der Datei.
const listen = <(String, String)>[
  ('old files Lukasalmani/Wörter/Adjektive.txt', 'adjektiv'),
  ('old files Lukasalmani/Wörter/Verben_unregelmaeßig_Infinitiv.txt', 'verb'),
  ('old files Lukasalmani/Wörter/Verben_regelmaesig.txt', 'verb'),
  ('old files Lukasalmani/Wörter/substantiv_singular_alle.txt', 'nomen'),
  // ⛔ Vor dem ersten Nomen Lukas fragen: Nomen ohne Artikel (Städte …);
  //    Städtenamen = nur IPA + Bedeutung + Artikel (PLAN.md, 2026-09-24).
];

/// ⛔ Sperre vor den Verben — Entscheidung Lukas (2026-09-30): Bevor die
/// erste Verbkarte aus den Wortlisten gebaut wird, muss Claude Lukas fragen,
/// wie die Formensuche für Verben aussehen soll. Pflicht (schon entschieden):
/// JEDE Form eines Verbs muss in der Suche die Karte finden — gehe, ging,
/// gegangen, ausgehen, mitgegangen, … («gehen» im Archiv, «ging» gesucht ⇒
/// nie null Treffer). Offen (entscheidet Lukas): eigene Wortseite je Form
/// oder alle Formen auf der Seite des Infinitivs. Erst wenn Lukas
/// entschieden hat, wird dies auf `true` gesetzt (PLAN.md → «📚 روال …»).
const verbenFreigegeben = false;

/// Wörter, die Claude nicht sicher beschreiben konnte (Regel 14 des
/// Wort-Prompts: nie raten) — warten auf Lukas. Mit Datum/Grund in PLAN.md.
const zurueckgestellt = <String>{
  'abatisch',
  'abdikativ',
  'afrikaans',
  'aldente', // Schreibung zweifelhaft (Duden: «al dente») 2026-09-24
  'aleppinisch', // Gebrauch als Adjektiv unsicher 2026-09-24
  'allenfallsig', // keine gesicherte Form (nur Adverb «allenfalls») 2026-09-24
  'altaltbacken', // Schreibung zweifelhaft (wohl «altbacken») 2026-09-24
  'Altdorfer', // Eigenname/Herkunftsbezeichnung, kein gewöhnliches Adjektiv 2026-09-24
  'altkrank', // Bedeutung/Gebrauch unsicher 2026-09-24
  'amaranten', // Bedeutung/Gebrauch unsicher (veraltet?) 2026-09-25
  'ambient', // als deutsches Adjektiv nicht gesichert (v. a. Nomen «Ambient») 2026-09-25
  'amethysten', // Bedeutung unsicher («aus Amethyst» oder «amethystfarben»?) 2026-09-25
  'amphibolisch', // Bedeutung unsicher (Logik «mehrdeutig» oder Mineral «Amphibol»?) 2026-09-25
  'anamorph', // Bedeutung fachabhängig unsicher (Optik/Biologie/Mykologie) 2026-09-25
  'anelliert', // keine gesicherte Bedeutung/Form gefunden 2026-09-25
  'anotherm', // Bedeutung/Fachgebiet unsicher 2026-09-25
  'antichretisch', // Fachwort (Antichrese?), Bedeutung unsicher 2026-09-25
  'appendikuliert', // Bedeutung/Fachgebiet unsicher (Biologie?) 2026-09-25
  'aretologisch', // Bedeutung unsicher (Tugendlehre oder Wundererzählung?) 2026-09-25
  'arschig', // derb; Bedeutung/Gebrauch als Adjektiv nicht gesichert 2026-09-25
  'arschlos', // keine gesicherte Bedeutung/Form bekannt 2026-09-25
  'assi', // umgangssprachliche Kurzform; als Adjektiv nicht gesichert (Duden: «assig», «der Assi») 2026-09-25
  'athermisch', // Bedeutung/Fachgebiet unsicher 2026-09-25
  'ausheimisch', // Bedeutung/Gebrauch unsicher (landschaftlich/veraltet?) 2026-09-25
  'austral', // Bedeutung/Gebrauch unsicher (Fachwort «südlich»?) 2026-09-25
  'averbal', // Bedeutung/Gebrauch unsicher (Fachwort?) 2026-09-25
  'azentrisch', // Bedeutung/Fachgebiet unsicher 2026-09-25
  'azephal', // Bedeutung fachabhängig unsicher (Medizin «ohne Kopf» / Verslehre «ohne Auftakt»?) 2026-09-25
  'bananig', // Bedeutung/Gebrauch unsicher (umgangssprachlich?) 2026-09-25
  'bannig', // regional (norddeutsch «sehr»), eher Adverb — unsicher 2026-09-25
  'basalten', // Bedeutung unsicher («aus Basalt»?), nicht gesichert 2026-09-25
  'basiklin', // Fachwort (Botanik?), Bedeutung unsicher 2026-09-25
  'basten', // Bedeutung/Gebrauch unsicher («aus Bast»?) 2026-09-25
  'batisten', // Bedeutung/Gebrauch unsicher («aus Batist»?) 2026-09-25
  'bebuscht', // Bedeutung/Gebrauch unsicher 2026-09-25
  'bebust', // Bedeutung/Gebrauch unsicher (umgangssprachlich/derb?) 2026-09-25
  'bedonnert', // Bedeutung/Gebrauch unsicher (umgangssprachlich?) 2026-09-25
  'befotzt', // keine gesicherte Form/Bedeutung (derb, wohl Fehler) 2026-09-25
  'begeißelt', // Bedeutung/Fachgebiet unsicher (Biologie «mit Geißeln»?) 2026-09-25
  'begrannt', // Fachwort (Botanik «mit Grannen»?), unsicher 2026-09-25
  'behemdet', // Bedeutung/Gebrauch unsicher («mit Hemd»?) 2026-09-25
  'behost', // Bedeutung/Gebrauch unsicher («mit Hose»?) 2026-09-25
  'behuft', // Bedeutung/Gebrauch unsicher («mit Hufen»?) 2026-09-25
  'beinfarben', // Bedeutung unsicher («knochenfarben»?) 2026-09-25
  'bekrallt', // Bedeutung/Gebrauch unsicher («mit Krallen»?) 2026-09-25
  'bemähnt', // Bedeutung/Gebrauch unsicher («mit Mähne»?) 2026-09-25
  'bemützt', // Bedeutung/Gebrauch unsicher («mit Mütze»?) 2026-09-25
  'bepelzt', // Bedeutung/Gebrauch unsicher («mit Pelz»?) 2026-09-25
  'beredet', // Bedeutung/Form unsicher (wohl Nebenform/Verwechslung mit «beredt») 2026-09-25
  'berindet', // Bedeutung/Gebrauch unsicher («mit Rinde»?) 2026-09-25
  'bernsteinen', // Bedeutung unsicher («aus Bernstein»?) 2026-09-25
  'berstig', // keine gesicherte Form/Bedeutung 2026-09-25
  'berüscht', // Bedeutung/Gebrauch unsicher («mit Rüschen»?) 2026-09-25
  'beschilft', // Bedeutung/Gebrauch unsicher («mit Schilf»?) 2026-09-25
  'beschürzt', // Bedeutung/Gebrauch unsicher («mit Schürze»?) 2026-09-25
  'besoffenbesondere', // Listenfehler (zwei Wörter zusammengeschrieben) 2026-09-25
  'besonderes', // flektierte Form, keine Grundform (Lemma: «besonderer/besondere») 2026-09-25
  'besonderer', // flektierte Form, keine Grundform 2026-09-25
  'bestiefelt', // Bedeutung/Gebrauch unsicher («mit Stiefeln»?) 2026-09-25
  'bestrumpft', // Bedeutung/Gebrauch unsicher («mit Strümpfen»?) 2026-09-25
  'bestusst', // umgangssprachlich; Bedeutung/Gebrauch unsicher 2026-09-25
  'betresst', // Bedeutung/Gebrauch unsicher («mit Tressen»?) 2026-09-25
  'betrieben', // nur Partizip; als eigenständiges Adjektiv nicht gesichert (v. a. in Komposita wie «batteriebetrieben») 2026-09-25
  'bezastert', // keine gesicherte Form/Bedeutung 2026-09-25
  'bezopft', // Bedeutung/Gebrauch unsicher («mit Zopf»?) 2026-09-25
  'bibliophob', // Bedeutung/Gebrauch nicht gesichert 2026-09-25
  'biereifrig', // Bedeutung/Gebrauch unsicher (scherzhaft?) 2026-09-25
  'bimaxillär', // Fachwort (Medizin/Zahnmedizin), Bedeutung unsicher 2026-09-25
  'birken', // Bedeutung/Gebrauch unsicher («aus Birkenholz»?) 2026-09-25
  'bitchig', // umgangssprachlicher Anglizismus, Gebrauch nicht gesichert 2026-09-25
  'blakig', // Bedeutung/Gebrauch unsicher (rußend?) 2026-09-25
  'bland', // Fachwort (Medizin «mild, reizlos»?), unsicher 2026-09-25
  'blaustrümpfig', // Bedeutung/Gebrauch unsicher (abwertend für gebildete Frauen?) 2026-09-25
  'bonfortionös', // Schreibweise unsicher (Duden: «bomforzionös»?) 2026-09-26
  'botrytisiert', // Fachwort (Weinbau), Duden-Eintrag unsicher 2026-09-26
  'boustrophedon', // eher Adverb/Nomen (Bustrophedon), Wortart unsicher 2026-09-26
  'brennheiß', // Duden-Eintrag unsicher (eher «brennend heiß») 2026-09-26
  'brillanten', // Bedeutung/Gebrauch unsicher (aus Brillanten?) 2026-09-26
  'brokaten', // Bedeutung/Gebrauch unsicher (aus Brokat?) 2026-09-26
  'buchen', // Bedeutung/Gebrauch unsicher («aus Buchenholz»?) — wie birken 2026-09-26
  'bundrein', // Fachwort (Gitarrenbau?), Bedeutung/Duden-Eintrag unsicher 2026-09-26
  'buntfarben', // Duden-Eintrag unsicher (gesichert: buntfarbig) 2026-09-26
  'busig', // Bedeutung/Gebrauch unsicher (umgangssprachlich «vollbusig»?) — wie bebust 2026-09-26
  'bustrophedon', // eher Nomen/Adverb (das Bustrophedon), Wortart unsicher — wie boustrophedon 2026-09-26
  'chemometrisch', // Fachwort (Chemometrie), Duden-Eintrag unsicher 2026-09-26
  'chilotisch', // Bedeutung unsicher (Chiloé? Chilote?) 2026-09-26
  'chionophil', // Fachwort (Biologie «schneeliebend»?), unsicher 2026-09-26
  'chochem', // im Duden nur als Nomen «der Chochem»; Adjektivgebrauch unsicher 2026-09-26
  'chondritisch', // zwei mögliche Bedeutungen (Chondrit-Meteorit / Chondritis), unsicher 2026-09-26
  'claviform', // Fachwort (Botanik «keulenförmig»?), Duden-Eintrag unsicher 2026-09-26
  'damasten', // Bedeutung/Gebrauch unsicher («aus Damast»?) — wie batisten 2026-09-26
  'dasig', // landschaftlich; Bedeutung unsicher («verwirrt»? «hiesig»?) 2026-09-26
  'debitorisch', // Fachwort (Buchhaltung «die Debitoren betreffend»?), Duden-Eintrag unsicher 2026-09-26
  'dekremental', // Fachwort, Bedeutung/Duden-Eintrag unsicher («abnehmend»?) 2026-09-26
  'delatorisch', // Bedeutung/Duden-Eintrag unsicher («denunzierend»? veraltet) 2026-09-26
  'demanten', // Bedeutung/Gebrauch unsicher (dichterisch «diamanten»?) — wie brillanten 2026-09-26
  'deprekativ', // Fachwort (Sprachwissenschaft/Religion «bittend»?), Duden-Eintrag unsicher 2026-09-26
  'depretiativ', // Bedeutung/Schreibweise unsicher (vielleicht «depreziativ» = abwertend?) 2026-09-26
  'desiderat', // im Duden als Nomen «das Desiderat»; Adjektivgebrauch unsicher 2026-09-26
  'designatus', // lateinisch, nur nachgestellt (Rektor designatus); kein gewöhnliches Adjektiv 2026-09-26
  'desmal', // keine gesicherte Form/Bedeutung (Druckfehler für «dezimal»? «diesmal»?) 2026-09-26
  'dextral', // Fachwort (Biologie/Medizin «rechtsseitig/rechtsgewunden»?), Duden-Eintrag unsicher 2026-09-26
  'dezisionistisch', // Fachwort (Philosophie/Staatsrecht), Duden-Eintrag und genaue Bedeutung unsicher 2026-09-26
  'diamanten', // Bedeutung/Gebrauch unsicher («aus Diamant»? gehoben) — wie brillanten 2026-09-26
  'diffusibel', // Fachwort (Physik/Chemie «diffusionsfähig»?), Duden-Eintrag unsicher 2026-09-26
  'dikasterial', // Fachwort (Kirchenrecht/Verwaltung, von «Dikasterium»?), Bedeutung unsicher 2026-09-26
  'dilemmatisch', // Duden-Eintrag und Gebrauch unsicher 2026-09-26
  'diptotisch', // Fachwort (Grammatik: «mit nur zwei Kasusformen»?), Duden-Eintrag unsicher 2026-09-26
  'dissidentisch', // Duden-Eintrag unsicher (gesichert: «dissident») 2026-09-26
  'dissipativ', // Fachwort (Physik: «Energie zerstreuend»), Duden-Eintrag unsicher 2026-09-26
  'distich', // Fachwort (Botanik «zweizeilig»?) oder Verwechslung mit «Distichon»; unsicher 2026-09-26
  'dolent', // Fachwort (Medizin «schmerzhaft»?), Duden-Eintrag unsicher 2026-09-26
  'doloros', // Schreibvariante unsicher (gesichert: «dolorös») 2026-09-26
  'dominicanisch', // Schreibweise unsicher (gesichert: «dominikanisch») 2026-09-26
  'doppelherzig', // veraltet, Duden-Eintrag und Bedeutung unsicher («heuchlerisch»?) 2026-09-26
  'drahten', // Bedeutung/Gebrauch unsicher («aus Draht»?) — wie birken 2026-09-26
  'drittelzahlig', // Bedeutung/Duden-Eintrag unsicher 2026-09-26
  'dutzend', // Wortart unsicher (meist Nomen «das Dutzend»; klein nur in «dutzende») 2026-09-26
  'dyadisch', // mehrere Fachbedeutungen (Mathematik «dual» / Soziologie «Zweierbeziehung»), unsicher 2026-09-26
  'ebengleich', // Bedeutung/Duden-Eintrag unsicher 2026-09-26
  'egressiv', // mehrere Fachbedeutungen (Phonetik/Aktionsart), unsicher 2026-09-26
  'ehrenkäsig', // Bedeutung/Duden-Eintrag unsicher (umgangssprachlich?) 2026-09-26
  'eiben', // Stoffadjektiv («aus Eibenholz»?), Gebrauch unsicher — wie birken 2026-09-26
  'eichen', // Stoffadjektiv («aus Eichenholz»), leicht mit dem Verb «eichen» verwechselbar — wie birken 2026-09-26
  'einschaltbereit', // Bedeutung/Duden-Eintrag unsicher 2026-09-26
  'elektrogen', // Fachwort, Bedeutung/Duden-Eintrag unsicher 2026-09-26
  'elenktisch', // Fachwort (Philosophie «widerlegend»?), Duden-Eintrag unsicher 2026-09-26
  'emeritus', // lateinisch, nur nachgestellt (Professor emeritus); kein gewöhnliches Adjektiv — wie designatus 2026-09-26
  'emisch', // Fachwort (Ethnologie/Linguistik «emisch»), Duden-Eintrag unsicher 2026-09-26
  'empathogen', // Fachwort der Pharmakologie, Duden-Eintrag unsicher 2026-09-26
  'enaktiv', // Fachwort (Kognitionswissenschaft/Didaktik), Duden-Eintrag unsicher 2026-09-26
  'endogenetisch', // Fachwort, Abgrenzung zu «endogen» unsicher 2026-09-26
  'endothym', // Fachwort (Psychologie), Bedeutung/Duden-Eintrag unsicher 2026-09-26
  'endozentrisch', // Fachwort der Linguistik, Duden-Eintrag unsicher 2026-09-26
  'enkaptisch', // Bedeutung/Duden-Eintrag unsicher 2026-09-26
  'enneaeterisch', // sehr seltenes Fachwort («neunjährig»?), unsicher 2026-09-26
  'enostal', // Bedeutung/Duden-Eintrag unsicher (Verwechslung mit «enossal»?) 2026-09-26
  'entaktogen', // Fachwort der Pharmakologie, Duden-Eintrag unsicher 2026-09-26
  'ephebisch', // Bedeutung/Duden-Eintrag unsicher («jünglingshaft»?) 2026-09-26
  'epifaszial', // Fachwort der Medizin («oberhalb der Faszie»?), Duden-Eintrag unsicher 2026-09-26
  'epithetisch', // Fachwort (Rhetorik), Duden-Eintrag unsicher 2026-09-26
  'eponymisch', // Duden-Eintrag unsicher (gesichert eher: «eponym») 2026-09-26
  'erdhaltig', // Bedeutung/Duden-Eintrag unsicher 2026-09-26
  'erethisch', // Fachwort der Medizin (Erethismus), Duden-Eintrag unsicher 2026-09-26
  'erfolgswirksam', // Fachwort der Buchhaltung, genaue Bedeutung unsicher 2026-09-26
  'erlen', // Stoffadjektiv («aus Erlenholz»?) — wie birken 2026-09-26
  'erotomanisch', // Fachwort der Psychiatrie, Duden-Eintrag unsicher 2026-09-26
  'erzen', // Stoffadjektiv («aus Erz»?, veraltet) — wie birken 2026-09-26
  'eschen', // Stoffadjektiv («aus Eschenholz»?) — wie birken 2026-09-26
  'espen', // Stoffadjektiv («aus Espenholz»?) — wie birken 2026-09-26
  'etisch', // Fachwort (Ethnologie/Linguistik «etisch») — wie emisch 2026-09-26
  'euploid', // Fachwort der Genetik, Duden-Eintrag unsicher 2026-09-26
  'europazentriert', // Duden-Eintrag unsicher (üblich: «eurozentrisch») 2026-09-26
  'euryhalin', // Fachwort der Ökologie, Duden-Eintrag unsicher 2026-09-26
  'euryhygr', // Fachwort der Ökologie, Duden-Eintrag unsicher 2026-09-26
  'euryök', // Fachwort der Ökologie, Duden-Eintrag unsicher 2026-09-26
  'eurytherm', // Fachwort der Ökologie, Duden-Eintrag unsicher 2026-09-26
  'exergon', // Fachwort (Biochemie; üblich «exergonisch»), Form unsicher 2026-09-26
  'exogenetisch', // Fachwort, Abgrenzung zu «exogen» unsicher — wie endogenetisch 2026-09-26
  'exozentrischg', // Tippfehler in der Liste (wohl «exozentrisch»); Fachwort, unsicher 2026-09-26
  'expert', // kein gesichertes deutsches Adjektiv (engl. «expert») 2026-09-26
  'extinkt', // Bedeutung/Duden-Eintrag unsicher («ausgestorben»?) 2026-09-26
  'extradiegetisch', // Fachwort der Erzähltheorie, Duden-Eintrag unsicher 2026-09-26
  'extramundan', // Fachwort (Philosophie «außerweltlich»?), Duden-Eintrag unsicher 2026-09-26
  'extra-temporal', // Schreibweise/Bedeutung unsicher 2026-09-26
  'extratemporal', // Bedeutung/Duden-Eintrag unsicher (Medizin «außerhalb der Schläfe»?) 2026-09-26
  'fabisch', // Bedeutung/Duden-Eintrag unsicher 2026-09-26
  'fadenbreit', // eher Nomen («um keinen Fadenbreit»), Adjektivgebrauch unsicher 2026-09-26
  'fadenlos', // Bedeutung/Duden-Eintrag unsicher 2026-09-26
  'faselnackend', // landschaftlich, Bedeutung/Schreibweise unsicher («splitternackt»?) 2026-09-26
  'fasennackend', // landschaftlich, Bedeutung/Schreibweise unsicher — wie faselnackend 2026-09-26
  'fassettenartig', // Schreibvariante unsicher (gesichert: «facettenartig») 2026-09-26
  'fassettenreich', // Schreibvariante unsicher (gesichert: «facettenreich») 2026-09-26
  'fastidiös', // veraltet, Bedeutung unsicher («widerwärtig»? «wählerisch»?) 2026-09-26
  'fekund', // selten, Duden-Eintrag unsicher («fruchtbar»?) 2026-09-26
  'fennoskandisch', // Fachwort (Geologie/Geografie), Duden-Eintrag unsicher 2026-09-26
  'fichten', // Stoffadjektiv («aus Fichtenholz»?) — wie birken 2026-09-26
  'fickerig', // landschaftlich, Bedeutung unsicher («nervös»?) und leicht missverständlich 2026-09-26
  'filamentartig', // Duden-Eintrag unsicher 2026-09-26
  'fipsig', // landschaftlich/umgangssprachlich, Bedeutung unsicher 2026-09-26
  'firn', // veraltet (Wein «firn» = alt, gereift?), Bedeutung unsicher 2026-09-26
  'flächengroß', // Duden-Eintrag unsicher 2026-09-26
  'flächsen', // Stoffadjektiv («aus Flachs»?) — wie birken 2026-09-26
  'flächsern', // Stoffadjektiv («aus Flachs»?) — wie birken 2026-09-26
  'flanellen', // Stoffadjektiv («aus Flanell»?) — wie batisten 2026-09-26
  'fluvioglazial', // Fachwort der Geologie, Duden-Eintrag unsicher 2026-09-26
  'gasig', // Bedeutung/Gebrauch unsicher 2026-09-26
  'gebalkt', // Bedeutung/Gebrauch unsicher (Balken? Jagd?) 2026-09-26
  'gebuckelt', // Bedeutung unsicher (bucklig? mit Buckeln?) 2026-09-26
  'gefizt', // keine gesicherte Bedeutung/Form 2026-09-26
  'gegengleich', // Bedeutung/Fachgebiet unsicher (Technik? österr.?) 2026-09-26
  'gegiebelt', // Bedeutung/Gebrauch unsicher (mit Giebel?) 2026-09-26
  'gehäusetragend', // Fachwort, Gebrauch unsicher (Schnecken?) 2026-09-26
  'geheist', // keine gesicherte Bedeutung/Form 2026-09-26
  'gehenkelt', // Bedeutung/Gebrauch unsicher (mit Henkel?) 2026-09-26
  'gehl', // mundartlich/veraltet, Bedeutung unsicher 2026-09-26
  'geköpert', // Textil-Fachwort (Köperbindung?), unsicher 2026-09-26
  'gekröpft', // Fachwort (Technik/Jagd), Bedeutung unsicher 2026-09-26
  'geperlt', // Bedeutung/Gebrauch unsicher 2026-09-26
  'gewalmt', // Architektur-Fachwort (Walmdach?), unsicher 2026-09-26
  'glanzhell', // keine gesicherte lexikalische Form 2026-09-26
  'griveliert', // Form/Bedeutung unsicher (grivelliert?) 2026-09-26
  'hären', // Stoffadjektiv (aus Haar), gehoben/veraltet — wie birken/flächsen zurückgestellt 2026-09-27
  'halbverklungen', // freie Bildung, keine gesicherte lexikalische Form 2026-09-27
  'halbwollen', // Stoffadjektiv (Halbwolle) — wie flanellen/flächsen zurückgestellt 2026-09-27
  'hallisch', // Adjektiv zu Halle (Saale)? Form (hallesch/hallisch) unsicher 2026-09-27
  'haloniert', // seltenes Fachwort (Augenringe?), Bedeutung unsicher 2026-09-27
  'haltig', // als freies Wort unsicher (sonst nur Suffix -haltig) 2026-09-27
  'handsam', // landschaftlich, Bedeutung (handlich/umgänglich?) unsicher 2026-09-27
  'hanfen', // Stoffadjektiv (aus Hanf) — wie flächsen zurückgestellt 2026-09-27
  'hapaxanth', // botanisches Fachwort (einmal blühend?), Form/Bedeutung unsicher 2026-09-27
  'hieb-undstichfest', // Listenfehler: richtig «hieb- und stichfest» (mehrteilig) — Lukas entscheidet 2026-09-27
  'hinterer', // Listenfehler: flektierte Form, Grundform «hintere» (wie besonderer) 2026-09-27
  'hirschledern', // Stoffadjektiv (aus Hirschleder) — wie flächsern zurückgestellt 2026-09-27
  'hitlerisch', // Form/Gebrauch als Adjektiv unsicher (üblich: «hitlersch»/Umschreibung) 2026-09-27
  'hühnermüde', // umgangssprachlich/regional, Form und Bedeutung unsicher 2026-09-27
  'humil', // veraltet/selten (demütig?), Bedeutung und Gebrauch unsicher 2026-09-27
  'hydrogen', // als Adjektiv unsicher (wasserstoffhaltig?), sonst nur Präfix/Nomen 2026-09-27
  'hygrisch', // seltenes Fachwort (Feuchtigkeit betreffend?), unsicher 2026-09-27
  'hypophrenisch', // Fachwort (unter dem Zwerchfell?), Bedeutung und Gebrauch unsicher 2026-09-27
  'immediat', // veraltet (unmittelbar dem Herrscher unterstellt?), Bedeutung/Gebrauch unsicher 2026-09-27
  'impardonnabel', // veraltet (unverzeihlich?), Gebrauch unsicher 2026-09-27
  'imperturbatisch', // Form zweifelhaft (üblich: «imperturbabel»?) 2026-09-27
  'importun', // veraltet (ungelegen?), Gebrauch unsicher 2026-09-27
  'inkommod', // veraltet (lästig, unbequem?), Gebrauch unsicher 2026-09-27
  'innerer', // Listenfehler: flektierte Form, Grundform «innere» (wie hinterer) 2026-09-27
  'insistent', // als Adjektiv im Deutschen unsicher (beharrlich?), Gebrauch unklar 2026-09-27
  'interdenominational', // im Deutschen unüblich (üblich: «interkonfessionell»), Anglizismus unsicher 2026-09-27
  'interkranial', // Form unsicher (üblich: «intrakraniell/intrakranial») 2026-09-27
  'interkrustal', // seltenes Fachwort (Geologie?), Bedeutung unsicher 2026-09-27
  'interkurrierend', // Form unsicher (üblich: «interkurrent») 2026-09-27
  'interorbital', // mehrdeutig (Anatomie: zwischen den Augenhöhlen / Raumfahrt?), Bedeutung unsicher 2026-09-27
  'interterritorial', // seltenes Fachwort, Gebrauch unsicher 2026-09-27
  'interurban', // veraltet (Fernverkehr/-gespräch?), Bedeutung unsicher 2026-09-27
  'intervallisch', // Bedeutung unsicher (in Intervallen? Musik?) 2026-09-27
  'interventiv', // seltenes Fachwort, Gebrauch unsicher 2026-09-27
  'inzident', // mehrdeutig (Mathematik: inzident; sonst «zufällig eintretend»?), Bedeutung unsicher 2026-09-27
  'irden', // Stoffadjektiv (aus gebranntem Ton) — wie birken/flächsen zurückgestellt 2026-09-27
  'irländisch', // selten neben «irisch», Gebrauch unsicher 2026-09-27
  'jaden', // Stoffadjektiv (aus Jade) — wie birken/flächsen zurückgestellt 2026-09-27
  'jährig', // als freies Wort veraltet/unsicher (sonst nur -jährig: zweijährig) 2026-09-27
  'jiddischistisch', // seltenes Fachwort (Jiddischismus?), Bedeutung unsicher 2026-09-27
  'judiziös', // veraltet/bildungssprachlich (scharfsinnig urteilend?), unsicher 2026-09-27
  'juwelen', // Stoffadjektiv (aus Juwelen?) — wie birken/flächsen zurückgestellt, Gebrauch unsicher 2026-09-27
  'juxtarenal', // seltenes medizinisches Fachwort (neben der Niere?), unsicher 2026-09-27
  'kaduk', // veraltet (hinfällig?), Gebrauch unsicher 2026-09-27
  'kärntisch', // Form zweifelhaft (üblich: «kärntnerisch», das gebaut wurde) 2026-09-27
  'kanevassen', // Stoffadjektiv (aus Kanevas-Stoff) — wie flanellen zurückgestellt 2026-09-27
  'kantoniert', // seltenes Fachwort (Architektur: kantonierter Pfeiler?), Bedeutung unsicher 2026-09-27
  'karolinisch', // mehrdeutig (Karolinen-Inseln? Karl V./Carolina?), Bedeutung unsicher 2026-09-27
  'katenativ', // seltenes Fachwort (Linguistik?), Bedeutung unsicher 2026-09-27
  'katotherm', // seltenes Fachwort, Bedeutung unsicher 2026-09-27
  'kattunen', // Stoffadjektiv (aus Kattun) — wie flanellen zurückgestellt 2026-09-27
  'kautelarjuristisch', // sehr seltenes juristisches Fachwort, Gebrauch unsicher 2026-09-27
  'kiefern', // Stoffadjektiv (aus Kiefernholz) — wie birken zurückgestellt 2026-09-27
  'knitz', // landschaftlich (südwestdeutsch: pfiffig?), Gebrauch unsicher 2026-09-27
  'knülle', // landschaftlich/umgangssprachlich (betrunken? erschöpft?), Bedeutung unsicher 2026-09-27
  'knüll', // Nebenform von «knülle», Bedeutung unsicher 2026-09-27
  'koblenzisch', // Form unsicher (üblich: «Koblenzer») 2026-09-27
  'komplektisch', // Wort unbekannt, Bedeutung unsicher 2026-09-27
  'komputativ', // seltenes Fachwort, Bedeutung unsicher 2026-09-27
  'konfliktär', // seltenes Fachwort (konfliktgeladen?), Gebrauch unsicher 2026-09-27
  'konjugal', // veraltet (ehelich?), Gebrauch unsicher 2026-09-27
  'konkomitant', // seltenes medizinisches Fachwort (begleitend?), unsicher 2026-09-27
  'konphas', // Wort unbekannt (Physik? gleichphasig?), Bedeutung unsicher 2026-09-27
  'konvenient', // veraltet (passend, schicklich?), Gebrauch unsicher 2026-09-27
  'konvers', // seltenes Fachwort (Logik: umgekehrt?), Gebrauch unsicher 2026-09-27
  'konvivial', // selten/bildungssprachlich (gesellig?), Gebrauch unsicher 2026-09-27
  'korallen', // Stoffadjektiv (aus Koralle) — wie birken zurückgestellt 2026-09-27
  'kredibel', // veraltet/bildungssprachlich (glaubwürdig?), Gebrauch unsicher 2026-09-27
  'kreiden', // Stoffadjektiv (aus Kreide) — wie birken zurückgestellt 2026-09-27
  'krisselig', // landschaftlich/umgangssprachlich (gekräuselt? körnig?), Bedeutung unsicher 2026-09-27
  'krisslig', // Nebenform von «krisselig», Bedeutung unsicher 2026-09-27
  'kristallen', // Stoffadjektiv (aus Kristall) — wie birken zurückgestellt 2026-09-27
  'krütsch', // landschaftlich (wählerisch?), Bedeutung unsicher 2026-09-27
  'kryptomer', // seltenes Fachwort (Mineralogie: kryptokristallin?), Bedeutung unsicher 2026-09-27
  'kunstseiden', // Stoffadjektiv (aus Kunstseide) — wie flanellen zurückgestellt 2026-09-27
  'kurrent', // mehrdeutig (Kurrentschrift? kaufmännisch laufend?), Bedeutung unsicher 2026-09-27
  'laff', // landschaftlich/umgangssprachlich (schlaff? fade?), Bedeutung unsicher 2026-09-27
  'laikal', // seltenes Fachwort (Laien betreffend?), Gebrauch unsicher 2026-09-27
  'larifari', // vor allem Nomen/Interjektion («Larifari»), adjektivischer Gebrauch unsicher 2026-09-27
  'latinisch', // selten/historisch (Latium betreffend?), Gebrauch unsicher 2026-09-27
  'latreutisch', // sehr seltenes theologisches Fachwort, Bedeutung unsicher 2026-09-27
  'leckerfritzig', // umgangssprachlich/regional, Bedeutung unsicher 2026-09-27
  'legasthen', // seltene Nebenform (üblich: «legasthenisch», das gebaut wurde), unsicher 2026-09-27
  'leidsam', // veraltet/selten, Bedeutung unsicher 2026-09-27
  'leinen', // Stoffadjektiv (aus Leinen) — wie flanellen zurückgestellt 2026-09-27
  'leinwand', // Schreibvariante zweifelhaft (üblich österr.: «leiwand», das gebaut wurde) 2026-09-27
  'letzter', // Listenfehler: flektierte Form, Grundform «letzte» (wie hinterer/innerer) 2026-09-27
  'levurozid', // sehr seltenes Fachwort (hefeabtötend?), unsicher 2026-09-27
  'lidschäftig', // Wort unbekannt, Bedeutung unsicher 2026-09-27
  'limnophil', // seltenes Fachwort (Süßwasser liebend?), unsicher 2026-09-27
  'linden', // Stoffadjektiv (aus Lindenholz) — wie birken zurückgestellt 2026-09-27
  'linker', // Listenfehler: flektierte Form, Grundform «linke» (wie hinterer/letzter) 2026-09-27
  'listrisch', // seltenes geologisches Fachwort (listrische Verwerfung?), unsicher 2026-09-27
  'lohfarben', // Farbe unsicher (lohbraun? rotbraun?), Gebrauch unsicher 2026-09-27
  'lucianisch', // Bedeutung unsicher (auf Lukian bezogen?), selten 2026-09-27
  'ludisch', // seltenes Fachwort (spielerisch?), Gebrauch unsicher 2026-09-27
  'lübsch', // veraltet/historisch (Lübeck betreffend?), Gebrauch unsicher 2026-09-27
  'lüdisch', // Wort unbekannt, Bedeutung unsicher 2026-09-27
  'lukulent', // Wort unbekannt (Nebenform von «lukullisch»?), unsicher 2026-09-27
  'luminös', // selten/bildungssprachlich (leuchtend?), Gebrauch unsicher 2026-09-27
  'lustgetrieben', // freie Bildung, keine gesicherte lexikalische Form 2026-09-27
  'mainzisch', // Form unsicher (üblich: «Mainzer») 2026-09-27
  'majorenn', // veraltet (volljährig?), Gebrauch unsicher 2026-09-27
  'mamertinisch', // seltenes historisches Wort (Mamertiner?), Bedeutung unsicher 2026-09-27
  'mancherlei', // Wortart unsicher (Duden: unbestimmtes Zahlwort/Pronomen, undeklinierbar) — Lukas entscheidet 2026-09-27
  'marastisch', // Form unsicher (medizinisch üblich: «marantisch»?) 2026-09-27
  'marktbar', // Wort unbekannt (marktfähig?), Bedeutung unsicher 2026-09-27
  'maschinenmäßig', // freie Bildung (wie eine Maschine?), keine gesicherte lexikalische Form 2026-09-27
  'masturbatorisch', // sexueller Fachbegriff — für eine Lern-App ohne Altersgrenze zurückgestellt, Lukas entscheidet 2026-09-27
  'mediat', // veraltet/historisch (mittelbar?), Gebrauch unsicher 2026-09-27
  'meißenisch', // Form unsicher (üblich: «Meißner») 2026-09-27
  'meißnisch', // Form unsicher (üblich: «Meißner») 2026-09-27
  'messingen', // Stoffadjektiv (aus Messing) — wie flanellen zurückgestellt 2026-09-27
  'metadiegetisch', // sehr seltenes Fachwort (Erzähltheorie), unsicher 2026-09-27
  'millenarisch', // seltenes Fachwort (chiliastisch?), Bedeutung unsicher 2026-09-27
  'minderer', // Listenfehler: flektierte Form, Grundform «mindere» (wie hinterer/letzter) 2026-09-27
  'ministrabel', // bildungssprachlich/selten (für ein Ministeramt geeignet?), Gebrauch unsicher 2026-09-27
  'mirakulös', // bildungssprachlich/selten (wundersam?), Gebrauch unsicher 2026-09-27
  'mittelalterig', // Form unsicher (mittleren Alters? Nebenform «mittelaltrig») 2026-09-27
  'mittelaltrig', // Form unsicher (Nebenform von «mittelalterig»?) 2026-09-27
  'mnestisch', // seltenes Fachwort (Gedächtnis betreffend?), unsicher 2026-09-27
  'moderativ', // Wort unbekannt (mäßigend?), Bedeutung unsicher 2026-09-27
  'monadisch', // seltenes Fachwort (Philosophie/Mathematik), Gebrauch unsicher 2026-09-27
  'monadologisch', // sehr seltenes philosophisches Fachwort (Leibniz), unsicher 2026-09-27
  'mongolid', // veralteter rassentheoretischer Begriff, heute als diskriminierend angesehen — Lukas entscheidet 2026-09-27
  'mongoloid', // veralteter rassentheoretischer/abwertender Begriff — Lukas entscheidet 2026-09-27
  'moros', // veraltet (mürrisch, verdrießlich?), Gebrauch unsicher 2026-09-27
  'moselromanisch', // seltenes Fachwort (Sprachgeschichte), Bedeutung unsicher 2026-09-27
  'nachmalig', // veraltet (später?), Gebrauch unsicher 2026-09-27
  'nachrichtlich', // Amtssprache (zur Kenntnisnahme?), Bedeutung unsicher 2026-09-27
  'nächst', // Superlativform von «nah» (keine eigene Grundform) — Lukas entscheidet 2026-09-27
  'nämlich', // Wortart unsicher (meist Adverb/Partikel; adjektivisch «der nämliche» veraltet) — Lukas entscheidet 2026-09-27
  'naschsüchtig', // selten (Nebenform von «naschhaft»?), Gebrauch unsicher 2026-09-27
  'neolamarckistisch', // sehr seltenes Fachwort (Biologiegeschichte), unsicher 2026-09-27
  'neovitalistisch', // sehr seltenes Fachwort (Philosophie/Biologie), unsicher 2026-09-27
  'neurasthenisch', // veralteter medizinischer Begriff, Gebrauch unsicher 2026-09-27
  'neusilbern', // Stoffadjektiv (aus Neusilber) — wie flanellen zurückgestellt 2026-09-27
  'neusumerisch', // sehr seltenes Fachwort (Altorientalistik), unsicher 2026-09-27
  'nichtperturbativ', // sehr seltenes Fachwort (Physik), unsicher 2026-09-27
  'nillenkrank', // Wort unbekannt (vermutlich vulgär/regional), Bedeutung unsicher 2026-09-27
  'nordelbisch', // selten/regional (nördlich der Elbe?), Gebrauch unsicher 2026-09-27
  'notgeil', // vulgärer sexueller Ausdruck — für eine Lern-App ohne Altersgrenze zurückgestellt, Lukas entscheidet 2026-09-27
  'oberer', // Listenfehler: flektierte Form, Grundform «obere» (wie hinterer/innerer) 2026-09-27
  'oberschlächtig', // Fachwort (Wassermühle: oberschlächtiges Rad), Gebrauch unsicher 2026-09-27
  'obliviös', // Wort unbekannt (vergesslich?), unsicher 2026-09-27
  'obstinat', // veraltet/bildungssprachlich (hartnäckig?), Gebrauch unsicher 2026-09-27
  'öffenbar', // Wort unbekannt/Form zweifelhaft (offenbar? öffnungsfähig?) 2026-09-27
  'ogygisch', // sehr selten/bildungssprachlich (uralt?), unsicher 2026-09-27
  'oknophil', // sehr seltenes psychoanalytisches Fachwort, unsicher 2026-09-27
  'opalen', // Stoffadjektiv (aus Opal) — wie flanellen zurückgestellt 2026-09-27
  'oreal', // Wort unbekannt (Geografie: Gebirgs-?), Bedeutung unsicher 2026-09-27
  'orthotrop', // seltenes Fachwort (Botanik/Technik), unsicher 2026-09-27
  'oskisch', // sehr seltenes Fachwort (altitalische Sprache), unsicher 2026-09-27
  'ostensibel', // veraltet/bildungssprachlich, Gebrauch unsicher 2026-09-27
  'ostfälisch', // seltenes Fachwort (Dialektologie: Ostfälisch), unsicher 2026-09-27
  'ostgrönländisch', // sehr selten, Gebrauch unsicher 2026-09-27
  'ouvert', // Fachwort (Kartenspiel/Französisch), Gebrauch unsicher 2026-09-27
  'ovovivipar', // sehr seltenes Fachwort (Biologie), unsicher 2026-09-27
  'pädophil', // sensibler medizinisch-juristischer Begriff — für eine Lern-App ohne Altersgrenze zurückgestellt, Lukas entscheidet 2026-09-27
  'pagatorisch', // seltenes Fachwort (Rechnungswesen), unsicher 2026-09-27
  'palato-alveolar', // seltenes phonetisches Fachwort (Bindestrichform), unsicher 2026-09-27
  'panchronisch', // seltenes sprachwissenschaftliches Fachwort, unsicher 2026-09-27
  'panhellenisch', // selten (alle Griechen betreffend?), Gebrauch unsicher 2026-09-27
  'papabile', // italienische Nebenform von «papabel» (das gebaut wurde), unsicher 2026-09-27
  'papieren', // Stoffadjektiv (aus Papier) — wie flanellen zurückgestellt 2026-09-27
  'papiern', // Nebenform von «papieren» (Stoffadjektiv), unsicher 2026-09-27
  'papstfähig', // freie Bildung (Nebenform von «papabel»?), unsicher 2026-09-27
  'paradoxal', // seltene Nebenform von «paradox» (das gebaut wurde), unsicher 2026-09-27
  'parasprachlich', // seltene Nebenform von «paralinguistisch» (das gebaut wurde), unsicher 2026-09-27
  'paraxial', // seltenes Fachwort (Optik), unsicher 2026-09-27
  'pariserisch', // Form unsicher (üblich: «Pariser») 2026-09-27
  'partial', // seltene Nebenform von «partiell» (das gebaut wurde), unsicher 2026-09-27
  'passiert', // Partizip von «passieren» (Küche: durch ein Sieb gestrichen?), als Adjektiv unsicher 2026-09-27
  'pastellen', // selten (in Pastellfarben?), Gebrauch unsicher 2026-09-27
  'patrologisch', // seltenes theologisches Fachwort (Kirchenväter), unsicher 2026-09-27
  'pekig', // Wort unbekannt (regional?), Bedeutung unsicher 2026-09-27
  'penil', // anatomisch-sexueller Fachbegriff — für eine Lern-App ohne Altersgrenze zurückgestellt, Lukas entscheidet 2026-09-27
  'pentelisch', // sehr seltenes Fachwort (pentelischer Marmor), unsicher 2026-09-27
  'perdu', // umgangssprachlich/veraltet (verloren?), Gebrauch unsicher 2026-09-27
  'pergamenisch', // seltenes Fachwort (Pergamon betreffend?), unsicher 2026-09-27
  'pergamenten', // Stoffadjektiv (aus Pergament) — wie flanellen zurückgestellt 2026-09-27
  'perimortal', // seltenes forensisches Fachwort, unsicher 2026-09-27
  'perkussiv', // seltenes Fachwort (Musik/Medizin), unsicher 2026-09-27
  'perlmuttern', // Stoffadjektiv (aus Perlmutt) — wie flanellen zurückgestellt 2026-09-27
  'permutabel', // seltenes Fachwort (Mathematik), unsicher 2026-09-27
  'perpendikular', // seltenes Fachwort (senkrecht?), unsicher 2026-09-27
  'perpetuell', // bildungssprachlich/selten (fortwährend?), Gebrauch unsicher 2026-09-27
  'pervasiv', // seltenes Fachwort (Informatik: allgegenwärtig?), unsicher 2026-09-27
  'pervers', // primär sexuelle Bedeutung — für eine Lern-App ohne Altersgrenze zurückgestellt, Lukas entscheidet 2026-09-27
  'pestilenzartig', // veraltet/selten (wie die Pest?), unsicher 2026-09-27
  'phallisch', // sexuell konnotierter Fachbegriff — für eine Lern-App ohne Altersgrenze zurückgestellt, Lukas entscheidet 2026-09-27
  'phaneromer', // sehr seltenes geologisches Fachwort, unsicher 2026-09-27
  'phyletisch', // seltenes Fachwort (Stammesgeschichte), unsicher 2026-09-27
  'pikarisch', // seltene Nebenform von «pikaresk» (das gebaut wurde), unsicher 2026-09-27
  'pithekoid', // sehr seltenes anthropologisches Fachwort, unsicher 2026-09-27
  'pitschepatschenass', // umgangssprachliche Nebenform (verstärktes «pitschnass»), unsicher 2026-09-27
  'platzmäßig', // selten (Sport: vom Platz her?), Gebrauch unsicher 2026-09-27
  'plerophor', // sehr seltenes Fachwort, Bedeutung unsicher 2026-09-27
  'plüschen', // Stoffadjektiv (aus Plüsch) — wie flanellen zurückgestellt 2026-09-27
  'pluralisch', // selten (Plural betreffend?), Gebrauch unsicher 2026-09-27
  'poemisch', // Wort unbekannt, Bedeutung unsicher 2026-09-27
  'polabisch', // sehr seltenes Fachwort (ausgestorbene Sprache), unsicher 2026-09-27
  'polemogen', // sehr seltenes Fachwort (Konflikte erzeugend?), unsicher 2026-09-27
  'polydispers', // seltenes Fachwort (Chemie), unsicher 2026-09-27
  'polytoxikoman', // medizinischer Fachbegriff (Mehrfachabhängigkeit) — sensibel, Lukas entscheidet 2026-09-27
  'polytrop', // seltenes Fachwort, unsicher 2026-09-27
  'polyzyklisch', // seltenes Fachwort (Chemie), unsicher 2026-09-27
  'pongid', // sehr seltenes zoologisches Fachwort, unsicher 2026-09-27
  'pornografisch', // sexueller Inhalt — für eine Lern-App ohne Altersgrenze zurückgestellt, Lukas entscheidet 2026-09-27
  'pornographisch', // sexueller Inhalt (Schreibvariante) — zurückgestellt, Lukas entscheidet 2026-09-27
  'porzellanen', // Stoffadjektiv (aus Porzellan) — wie flanellen zurückgestellt 2026-09-27
  'porzin', // Fachwort (vom Schwein, Medizin?), unsicher 2026-09-27
  'postalveolar', // seltenes phonetisches Fachwort, unsicher 2026-09-27
  'postfrisch', // Fachwort (Philatelie: ungebrauchte Briefmarke), Gebrauch unsicher 2026-09-27
  'postulationsfähig', // juristisches Fachwort, selten, unsicher 2026-09-27
  'potentiometrisch', // sehr seltenes Fachwort (Chemie/Messtechnik), unsicher 2026-09-27
  'potenzsteigernd', // sexuell konnotiert — für eine Lern-App ohne Altersgrenze zurückgestellt, Lukas entscheidet 2026-09-27
  'prädiktabel', // selten (vorhersagbar?), Gebrauch unsicher 2026-09-27
  'präjudiziell', // juristisches Fachwort, selten, unsicher 2026-09-27
  'präliminär', // bildungssprachlich/selten (vorläufig?), unsicher 2026-09-27
  'prämonetär', // sehr seltenes Fachwort, unsicher 2026-09-27
  'präplanetar', // sehr seltenes Fachwort (Astronomie), unsicher 2026-09-27
  'prärogativ', // selten (Vorrecht betreffend?), Gebrauch unsicher 2026-09-27
  'präsentisch', // seltenes grammatisches Fachwort, unsicher 2026-09-27
  'präsidiabel', // bildungssprachlich/selten, unsicher 2026-09-27
  'präsumtiv', // juristisches Fachwort, selten, unsicher 2026-09-27
  'präterital', // seltenes grammatisches Fachwort, unsicher 2026-09-27
  'primordial', // sehr seltenes Fachwort (ursprünglich?), unsicher 2026-09-27
  'promisk', // sexueller Begriff — für eine Lern-App ohne Altersgrenze zurückgestellt, Lukas entscheidet 2026-09-27
  'promiskuitiv', // sexueller Begriff (Nebenform) — zurückgestellt, Lukas entscheidet 2026-09-27
  'prosopografisch', // sehr seltenes geschichtswissenschaftliches Fachwort, unsicher 2026-09-27
  'proteisch', // bildungssprachlich/selten (wandelbar?), unsicher 2026-09-27
  'psychrophil', // biologisches Fachwort (kälteliebend), sehr selten, unsicher 2026-09-29
  'pueril', // bildungssprachlich/selten (kindlich?), unsicher 2026-09-29
  'punitiv', // bildungssprachlich/juristisch selten (strafend?), unsicher 2026-09-29
  'pythonesk', // sehr selten/umgangssprachlich (im Stil von Monty Python?), unsicher 2026-09-29
  'quinär', // Fachwort (auf der Zahl Fünf beruhend?), sehr selten, unsicher 2026-09-29
  'quittegelb', // Nebenform, Schreibung unsicher 2026-09-29
  'quotal', // Fachwort (anteilig?), sehr selten, unsicher 2026-09-29
  'räß', // regional (schweiz./südd.), Bedeutung unsicher 2026-09-29
  'räumdig', // Bedeutung/Schreibung unsicher 2026-09-29
  'rahn', // regional/veraltet (schlank?), Bedeutung unsicher 2026-09-29
  'rallig', // Jägersprache/umgangssprachlich, Bedeutung unsicher 2026-09-29
  'rangig', // meist nur als Zweitglied (-rangig), eigenständiger Gebrauch unsicher 2026-09-29
  'raß', // regional (Nebenform zu räß), Bedeutung unsicher 2026-09-29
  'ratierlich', // Rechtssprache, sehr selten, unsicher 2026-09-29
  'raubauzig', // regional/umgangssprachlich, Bedeutung unsicher 2026-09-29
  'rebenumsponnen', // dichterisch/sehr selten, unsicher 2026-09-29
  'renaissancistisch', // sehr selten, Bedeutung/Gebrauch unsicher 2026-09-29
  'reputabel', // bildungssprachlich/sehr selten, unsicher 2026-09-29
  'reputierlich', // veraltet/sehr selten, unsicher 2026-09-29
  'resonant', // im Deutschen selten, Gebrauch unsicher 2026-09-29
  'respektiv', // veraltet, unsicher 2026-09-29
  'restituiert', // Partizip/Fachwort, Gebrauch als Adjektiv unsicher 2026-09-29
  'restitutiv', // Fachwort, sehr selten, unsicher 2026-09-29
  'retikulär', // medizinisches Fachwort, sehr selten, unsicher 2026-09-29
  'retinotop', // neurowissenschaftliches Fachwort, unsicher 2026-09-29
  'retransloziert', // Fachwort, sehr selten, unsicher 2026-09-29
  'retroaktiv', // im Deutschen selten (rückwirkend?), unsicher 2026-09-29
  'retrobulbär', // medizinisches Fachwort, sehr selten, unsicher 2026-09-29
  'retrofuturistisch', // Stilbegriff, Registrierung unsicher 2026-09-29
  'rezent', // mehrdeutig (Biologie: gegenwärtig lebend / regional: säuerlich), unsicher 2026-09-29
  'rezeptorvermittelt', // Fachwort, sehr selten, unsicher 2026-09-29
  'rheophil', // biologisches Fachwort, sehr selten, unsicher 2026-09-29
  'rhodiniert', // Fachwort (Schmuck), sehr selten, unsicher 2026-09-29
  'rhomboedrisch', // Fachwort (Kristallografie), sehr selten, unsicher 2026-09-29
  'ridikül', // veraltet/bildungssprachlich, unsicher 2026-09-29
  'rodelfrei', // Wort nicht gesichert, unsicher 2026-10-08
  'röntgenabsorbierend', // Fachwort, sehr selten, unsicher 2026-10-08
  'rösch', // regional, unsicher, unsicher 2026-10-08
  'romfreundlich', // Zusammensetzung, nicht gesichert, unsicher 2026-10-08
  'rossig', // Fachwort, unsicher, unsicher 2026-10-08
  'rostral', // Fachwort Anatomie, sehr selten, unsicher 2026-10-08
  'rücklaufend', // Partizip, Eintrag unsicher, unsicher 2026-10-08
  'rückwärtsgekrümmt', // Zusammensetzung, sehr selten, unsicher 2026-10-08
  'rügensch', // Ortsadjektiv, unsicher, unsicher 2026-10-08
  'rüstern', // Materialadjektiv wie birken, unsicher 2026-10-08
  'runtergerockt', // umgangssprachlich, Eintrag unsicher, unsicher 2026-10-08
  'sackleinen', // Materialadjektiv wie birken, unsicher 2026-10-08
  'salpeterhaltig', // Fachkompositum, unsicher, unsicher 2026-10-08
  'salzburgerisch', // ungebräuchliche Nebenform, unsicher 2026-10-08
  'samten', // Materialadjektiv wie birken, unsicher 2026-10-08
  'saphiren', // Materialadjektiv wie birken, unsicher 2026-10-08
  'satzwertig', // Fachwort Linguistik, unsicher, unsicher 2026-10-08
  'saubillig', // umgangssprachlich, unsicher, unsicher 2026-10-08
  'scharlachen', // Materialadjektiv wie birken, unsicher 2026-10-08
  'schau', // regional, unsicher, unsicher 2026-10-08
  'scheiße', // vulgär, Entscheidung Lukas, unsicher 2026-10-08
  'scheißegal', // vulgär, Entscheidung Lukas, unsicher 2026-10-08
  'scheißfreundlich', // vulgär, Entscheidung Lukas, unsicher 2026-10-08
  'schicker', // Komparativform, Listenfehler, unsicher 2026-10-08
  'schiefern', // Materialadjektiv wie birken, unsicher 2026-10-08
  'schilfen', // Materialadjektiv wie birken, unsicher 2026-10-08
  'schilfleinen', // Materialadjektiv wie birken, unsicher 2026-10-08
  'schismogen', // Fachwort, sehr selten, unsicher 2026-10-08
  'schlagzeilenträchtig', // Zusammensetzung, unsicher, unsicher 2026-10-08
  'schleckig', // regional, unsicher, unsicher 2026-10-08
  'schmerzenvoll', // ungebräuchliche Form, unsicher 2026-10-08
  'schnäukig', // regional, unsicher, unsicher 2026-10-08
  'schoflig', // ungebräuchliche Nebenform, unsicher 2026-10-08
  'schokoladen', // Materialadjektiv wie birken, unsicher 2026-10-08
  'schulautonom', // Fachwort Bildung, unsicher, unsicher 2026-10-08
  'schurwollen', // Materialadjektiv wie birken, unsicher 2026-10-08
  'schwachsinnig', // abwertend/veraltet, Entscheidung Lukas, unsicher 2026-10-08
  'schwätzicht', // selten, unsicher, unsicher 2026-10-08
  'schwanzgesteuert', // vulgär, Entscheidung Lukas, unsicher 2026-10-08
  'schwarzfeldrig', // Fachwort, sehr selten, unsicher 2026-10-08
  'schweinern', // Materialadjektiv wie birken, unsicher 2026-10-08
  'schwerkriegsbeschädigt', // historischer Amtsbegriff, unsicher 2026-10-08
  'schwerlötig', // Fachwort, sehr selten, unsicher 2026-10-08
  'sechsarmig', // Zusammensetzung, sehr selten, unsicher 2026-10-08
  'seiden', // Materialadjektiv wie birken, unsicher 2026-10-08
  'seiger', // Bergbau-Fachwort, selten, unsicher 2026-10-08
  'seimig', // regional, unsicher, unsicher 2026-10-08
  'sekkant', // österr. umgangssprachlich, unsicher, unsicher 2026-10-08
  'selektionistisch', // Fachwort, sehr selten, unsicher 2026-10-08
  'semesterbegleitend', // Zusammensetzung, Eintrag unsicher, unsicher 2026-10-08
  'serbisch-montenegrinisch', // historisch/politisch, unsicher, unsicher 2026-10-08
  'sexbesessen', // vulgär, Entscheidung Lukas, unsicher 2026-10-08
  'sichergestellt', // Partizip, Eintrag unsicher, unsicher 2026-10-08
  'sichtlaut', // Fachwort, sehr selten, unsicher 2026-10-08
  'silbentragend', // Fachwort, selten, unsicher 2026-10-08
  'silbern', // Materialadjektiv wie birken, unsicher 2026-10-08
  'siliziumhaltig', // Fachkompositum, unsicher, unsicher 2026-10-08
  'sinnfrei', // umgangssprachlich/neu, unsicher, unsicher 2026-10-08
  'siriusfern', // Zusammensetzung, sehr selten, unsicher 2026-10-08
  'skatologisch', // Fachwort/vulgär, Entscheidung Lukas, unsicher 2026-10-08
  'skoptisch', // Fachwort, sehr selten, unsicher 2026-10-08
  'small', // Anglizismus, unsicher, unsicher 2026-10-08
  'smaragden', // Materialadjektiv wie birken, unsicher 2026-10-08
  'sodomitisch', // veraltet/heikel, Entscheidung Lukas, unsicher 2026-10-08
  'solarthermisch', // Fachkompositum, unsicher, unsicher 2026-10-08
  'solenn', // sehr selten, unsicher, unsicher 2026-10-08
  'sozioökologisch', // Fachkompositum, unsicher, unsicher 2026-10-08
  'spack', // regional, unsicher, unsicher 2026-10-08
  'spackig', // regional, unsicher, unsicher 2026-10-08
  'spätmittelhochdeutsch', // Fachwort, unsicher, unsicher 2026-10-08
  'SPD-geführt', // politische Gelegenheitsbildung, unsicher 2026-10-08
  'speditiv', // schweizerisch/amtlich, unsicher, unsicher 2026-10-08
  'speicherresident', // Informatik-Fachwort, sehr selten, unsicher 2026-10-08
  'spillerig', // regional, unsicher, unsicher 2026-10-08
  'spillrig', // regional, unsicher, unsicher 2026-10-08
  'splitterfasernackt', // umgangssprachliche Steigerung, unsicher, unsicher 2026-10-08
  'spottschlecht', // umgangssprachlich, unsicher, unsicher 2026-10-08
  'spottsüchtig', // selten, unsicher, unsicher 2026-10-08
  'spritig', // regional/selten, unsicher, unsicher 2026-10-08
  'stählern', // Materialadjektiv wie birken, unsicher 2026-10-08
  'stärkehaltig', // Fachkompositum, unsicher, unsicher 2026-10-08
  'statutarisch', // juristisches Fachwort, selten, unsicher 2026-10-08
  'steinern', // Materialadjektiv wie birken, unsicher 2026-10-08
  'stenök', // Ökologie-Fachwort, selten, unsicher 2026-10-08
  'stenohalin', // Biologie-Fachwort, selten, unsicher 2026-10-08
  'stichometrisch', // Fachwort, sehr selten, unsicher 2026-10-08
  'stichprobenhaft', // ungebräuchliche Nebenform, unsicher 2026-10-08
  'stickstoffhaltig', // Fachkompositum, unsicher, unsicher 2026-10-08
  'stier', // mehrdeutig/regional, unsicher, unsicher 2026-10-08
  'stilmäßig', // umgangssprachlich, unsicher, unsicher 2026-10-08
  'stomachal', // medizinisches Fachwort, sehr selten, unsicher 2026-10-08
  'stotterig', // umgangssprachlich, unsicher, unsicher 2026-10-08
  'stottrig', // umgangssprachlich, unsicher, unsicher 2026-10-08
  'strack', // regional/veraltet, unsicher, unsicher 2026-10-08
  'strafbewehrt', // juristisch, selten, unsicher 2026-10-08
  'strafmindernd', // ungebräuchliche Nebenform, unsicher 2026-10-08
  'strafverdächtig', // juristisch, unsicher, unsicher 2026-10-08
  'straßenköterblond', // umgangssprachlich/abwertend, Entscheidung Lukas, unsicher 2026-10-08
  'streitbefangen', // juristisch, selten, unsicher 2026-10-08
  'stressresistent', // Neubildung, unsicher, unsicher 2026-10-08
  'streufähig', // technisch, unsicher, unsicher 2026-10-08
  'strohen', // Materialadjektiv wie birken, unsicher 2026-10-08
  'strunzdumm', // umgangssprachlich/beleidigend, unsicher 2026-10-08
  'subaquatisch', // Fachwort, selten, unsicher 2026-10-09
  'subfossil', // Fachwort Geologie, selten, unsicher 2026-10-09
  'subgingival', // Fachwort Zahnmedizin, selten, unsicher 2026-10-09
  'subglazial', // Fachwort Glaziologie, selten, unsicher 2026-10-09
  'subkonszient', // veraltetes Fachwort, selten, unsicher 2026-10-09
  'subkrustal', // Fachwort Geologie, selten, unsicher 2026-10-09
  'sublunarisch', // veraltet, selten, unsicher 2026-10-09
  'submers', // Fachwort Biologie, selten, unsicher 2026-10-09
  'submikroskopisch', // Fachwort, selten, unsicher 2026-10-09
  'submukös', // medizinisches Fachwort, selten, unsicher 2026-10-09
  'subnival', // Fachwort, selten, unsicher 2026-10-09
  'suborbital', // Fachwort, selten, unsicher 2026-10-09
  'subperiostal', // medizinisches Fachwort, selten, unsicher 2026-10-09
  'subphrenisch', // medizinisches Fachwort, selten, unsicher 2026-10-09
  'subsumtiv', // Fachwort, selten, unsicher 2026-10-09
  'subterran', // bildungssprachlich, selten, unsicher 2026-10-09
  'subungual', // medizinisches Fachwort, selten, unsicher 2026-10-09
  'suburbikarisch', // kirchliches Fachwort, sehr selten, unsicher 2026-10-09
  'südostdeutsch', // selten, unsicher, unsicher 2026-10-09
  'sulzig', // regional, unsicher, unsicher 2026-10-09
  'summativ', // Fachwort Pädagogik, selten, unsicher 2026-10-09
  'supergen', // Fachwort, sehr selten, unsicher 2026-10-09
  'superlativ', // adjektivisch selten, unsicher, unsicher 2026-10-09
  'superprovisorisch', // schweizerisch juristisch, selten, unsicher 2026-10-09
  'suppressiv', // medizinisches Fachwort, selten, unsicher 2026-10-09
  'supragingival', // Fachwort Zahnmedizin, selten, unsicher 2026-10-09
  'suprapubisch', // medizinisches Fachwort, selten, unsicher 2026-10-09
  'surjektiv', // Fachwort Mathematik, selten, unsicher 2026-10-09
  'suszeptibel', // Fachwort, selten, unsicher 2026-10-09
  'swasiländisch', // veralteter Ländername, unsicher, unsicher 2026-10-09
  'sympathetisch', // Fachwort/veraltet, selten, unsicher 2026-10-09
  'syndetisch', // Fachwort Linguistik, selten, unsicher 2026-10-09
  'synekdochisch', // Fachwort Rhetorik, selten, unsicher 2026-10-09
  'synergistisch', // Fachwort, selten, unsicher 2026-10-09
  'synkretistisch', // Fachwort, selten, unsicher 2026-10-09
  'synsemantisch', // Fachwort Linguistik, selten, unsicher 2026-10-09
  'synsystematisch', // Fachwort, sehr selten, unsicher 2026-10-09
  'syntagmatisch', // Fachwort Linguistik, selten, unsicher 2026-10-09
  'syntaxonomisch', // Fachwort, sehr selten, unsicher 2026-10-09
  'syntonisch', // Fachwort Psychologie, selten, unsicher 2026-10-09
  'systemlos', // selten, unsicher, unsicher 2026-10-09
  'systemoid', // Fachwort, sehr selten, unsicher 2026-10-09
  'szientifisch', // veraltet, selten, unsicher 2026-10-09
  'tablettensüchtig', // heikel, unsicher, unsicher 2026-10-09
  'taften', // Materialadjektiv wie birken, unsicher 2026-10-09
  'talentfrei', // umgangssprachlich/ironisch, unsicher, unsicher 2026-10-09
  'talmudisch', // religiöses Fachwort, selten, unsicher 2026-10-09
  'tangibel', // Fachwort, selten, unsicher 2026-10-09
  'tannen', // Materialadjektiv wie birken, unsicher 2026-10-09
  'tarentinisch', // Ortsadjektiv, sehr selten, unsicher 2026-10-09
  'taubstumm', // veraltet/verletzend, Entscheidung Lukas, unsicher 2026-10-09
  'tausendstel', // Bruchzahl, unsicher, unsicher 2026-10-09
  'taxativ', // österr. juristisch, selten, unsicher 2026-10-09
  'teaken', // Materialadjektiv wie birken, unsicher 2026-10-09
  'teilerfremd', // Fachwort Mathematik, selten, unsicher 2026-10-09
  'teleoklin', // Fachwort, sehr selten, unsicher 2026-10-09
  'teleologisch', // Fachwort Philosophie, selten, unsicher 2026-10-09
  'tellurisch', // Fachwort, selten, unsicher 2026-10-09
  'tentativ', // bildungssprachlich, selten, unsicher 2026-10-09
  'teratogen', // medizinisches Fachwort, selten, unsicher 2026-10-09
  'ternär', // Fachwort, selten, unsicher 2026-10-09
  'terrisch', // sehr selten, unsicher, unsicher 2026-10-09
  'tetragonal', // Fachwort, selten, unsicher 2026-10-09
  'thalassogen', // Fachwort, sehr selten, unsicher 2026-10-09
  'theodosianisch', // historisch, sehr selten, unsicher 2026-10-09
  'thermophil', // Fachwort Biologie, selten, unsicher 2026-10-09
  'thetisch', // Fachwort Philosophie, selten, unsicher 2026-10-09
  'thorakal', // medizinisches Fachwort, selten, unsicher 2026-10-09
  'timokratisch', // selten, unsicher 2026-10-09
  'timoresisch', // Ortsadjektiv, unsicher, unsicher 2026-10-09
  'tobsüchtig', // veraltet medizinisch, unsicher 2026-10-09
  'todgeweiht', // literarisch/heikel, unsicher 2026-10-09
  'töfte', // berlinerisch, unsicher, unsicher 2026-10-09
  'tönern', // Materialadjektiv wie birken, unsicher 2026-10-09
  'togoisch', // ungebräuchliche Nebenform, unsicher 2026-10-09
  'tomatiert', // Küchenfachwort, unsicher, unsicher 2026-10-09
  'tongaisch', // Ortsadjektiv, unsicher, unsicher 2026-10-09
  'tonhaltig', // Fachkompositum, unsicher, unsicher 2026-10-09
  'tonisch', // Fachwort, selten, unsicher 2026-10-09
  'tonotop', // Fachwort, sehr selten, unsicher 2026-10-09
  'topasen', // Materialadjektiv wie birken, unsicher 2026-10-09
  'topisch', // medizinisches Fachwort, selten, unsicher 2026-10-09
  'toreutisch', // Fachwort Kunst, sehr selten, unsicher 2026-10-09
  'totipotent', // Fachwort Biologie, selten, unsicher 2026-10-09
  'träf', // schweizerisch, unsicher, unsicher 2026-10-09
  'transdisziplinär', // Fachwort, selten, unsicher 2026-10-09
  'transfinit', // Fachwort Mathematik, selten, unsicher 2026-10-09
  'transient', // Fachwort, selten, unsicher 2026-10-09
  'transitorisch', // bildungssprachlich, selten, unsicher 2026-10-09
  'transmembranös', // Fachwort Biologie, sehr selten, unsicher 2026-10-09
  'transregional', // Fachkompositum, unsicher, unsicher 2026-10-09
  'transspezifisch', // Fachwort, sehr selten, unsicher 2026-10-09
  'transzendental', // Fachwort Philosophie, selten, unsicher 2026-10-09
  'treife', // religiöses Fachwort, selten, unsicher 2026-10-09
  'tribal', // Anglizismus, unsicher, unsicher 2026-10-09
  'trichinenhaltig', // Fachwort, selten, unsicher 2026-10-09
  'trilliardste', // sehr seltene Ordinalzahl, unsicher 2026-10-09
  'trillionste', // sehr seltene Ordinalzahl, unsicher 2026-10-09
  'trinär', // Fachwort, selten, unsicher 2026-10-09
  'tropologisch', // Fachwort, selten, unsicher 2026-10-09
  'trunksüchtig', // veraltet/heikel, unsicher 2026-10-09
  'trutzig', // veraltet, unsicher, unsicher 2026-10-09
  'tuchen', // Materialadjektiv wie birken, unsicher 2026-10-09
  'tumb', // veraltet, unsicher, unsicher 2026-10-09
  'tumultuarisch', // selten, Nebenform, unsicher 2026-10-09
  'tuvaluisch', // Ortsadjektiv, sehr selten, unsicher 2026-10-09
  'tuwinisch', // Ortsadjektiv, sehr selten, unsicher 2026-10-09
  'tyrrhenisch', // geografisch, selten, unsicher 2026-10-09
};

/// Wörter, deren Wortart in der Liste nicht stimmt (Duden-Wortart gilt,
/// Regel 14 des Wort-Prompts). Die Karte liegt dann unter der richtigen
/// Wortart; so erkennt das Tool sie trotzdem als fertig. Mit Datum in PLAN.md.
const wortartKorrektur = <String, String>{
  'aberhundert': 'numerale', // unbestimmtes Zahlwort (2026-09-24)
  'abertausend': 'numerale', // unbestimmtes Zahlwort (2026-09-24)
  'achte': 'numerale', // Ordinalzahl (2026-09-24)
  'sechste': 'numerale', // Ordinalzahl (2026-10-08)
  'sechzehnte': 'numerale', // Ordinalzahl (2026-10-08)
  'sechzigste': 'numerale', // Ordinalzahl (2026-10-08)
  'siebente': 'numerale', // Ordinalzahl (2026-10-08)
  'siebte': 'numerale', // Ordinalzahl (2026-10-08)
  'siebzehnte': 'numerale', // Ordinalzahl (2026-10-08)
  'siebzigste': 'numerale', // Ordinalzahl (2026-10-08)
  'tausendste': 'numerale', // Ordinalzahl (2026-10-09)
  'achtzehnte': 'numerale', // Ordinalzahl (2026-09-24)
  'achtzigste': 'numerale', // Ordinalzahl (2026-09-24)
  'andante': 'adverb', // Tempobezeichnung, Duden: Adverb (2026-09-25)
  'anderweit':
      'adverb', // Duden: Adverb; Adjektiv ist «anderweitig» (2026-09-25)
  'baldmöglichst': 'adverb', // Duden: Adverb (Amtssprache) (2026-09-25)
  'billiardste': 'numerale', // Ordinalzahl (2026-09-26)
  'billionste': 'numerale', // Ordinalzahl (2026-09-26)
  'demgemäß': 'adverb', // Duden: Adverb (2026-09-26)
  'dreihundertste': 'numerale', // Ordinalzahl (2026-09-26)
  'dreißigste': 'numerale', // Ordinalzahl (2026-09-26)
  'dreiundzwanzigste': 'numerale', // Ordinalzahl (2026-09-26)
  'dreizehnte': 'numerale', // Ordinalzahl (2026-09-26)
  'dritte': 'numerale', // Ordinalzahl (2026-09-26)
  'einhunderterste': 'numerale', // Ordinalzahl (2026-09-26)
  'einhundertste': 'numerale', // Ordinalzahl (2026-09-26)
  'einunddreißigste': 'numerale', // Ordinalzahl (2026-09-26)
  'einundzwanzigste': 'numerale', // Ordinalzahl (2026-09-26)
  'elfte': 'numerale', // Ordinalzahl (2026-09-26)
  'erste': 'numerale', // Ordinalzahl (2026-09-26)
  'forte': 'adverb', // Duden: Adverb (Musik) (2026-09-26)
  'fünfhundertste': 'numerale', // Ordinalzahl (2026-09-26)
  'fünfte': 'numerale', // Ordinalzahl (2026-09-26)
  'fünftel': 'numerale', // Bruchzahl (2026-09-26)
  'fünfzehnte': 'numerale', // Ordinalzahl (2026-09-26)
  'fünfzigste': 'numerale', // Ordinalzahl (2026-09-26)
  'fürbass': 'adverb', // Duden: Adverb (veraltet) (2026-09-26)
  'gell': 'partikel', // Duden: Partikel (landsch.) (2026-09-26)
  'gratis': 'adverb', // Duden: Adverb (2026-09-26)
  'hunderterste': 'numerale', // Duden: Numerale (2026-09-27)
  'hundertste': 'numerale', // Duden: Numerale (2026-09-27)
  'hundertstel': 'numerale', // Duden: Numerale (2026-09-27)
  'hunderttausendste': 'numerale', // Duden: Numerale (2026-09-27)
  'hundertundzweite': 'numerale', // Duden: Numerale (2026-09-27)
  'hundertzweite': 'numerale', // Duden: Numerale (2026-09-27)
  'milliardste': 'numerale', // Duden: Numerale (2026-09-27)
  'milliardstel': 'numerale', // Duden: Numerale (2026-09-27)
  'millionste': 'numerale', // Duden: Numerale (2026-09-27)
  'millionstel': 'numerale', // Duden: Numerale (2026-09-27)
  'neunte': 'numerale', // Duden: Numerale (2026-09-27)
  'neunzehnte': 'numerale', // Duden: Numerale (2026-09-27)
  'neunzigste': 'numerale', // Duden: Numerale (2026-09-27)
  'nullte': 'numerale', // Duden: Numerale (2026-09-27)
  'quadrillionste': 'numerale', // Duden: Numerale (2026-09-29)
};

/// `--abhaken` (Schritt 6 der Routine): setzt in ALLEN Listen «✓ » vor jedes
/// Wort, das eine Karte hat (Referenz: assets/vocab/, wie oben). Vorhandene
/// Zeilen ohne Karte bleiben unverändert; eine Datei wird nur geschrieben,
/// wenn sich etwas ändert.
void abhaken() {
  for (final (liste, wortart) in listen) {
    final datei = File(liste);
    if (!datei.existsSync()) continue;
    final alt = datei.readAsStringSync();
    final zeilen = alt.split('\n');
    var neu = 0;
    for (var i = 0; i < zeilen.length; i++) {
      final roh = zeilen[i];
      if (roh.trimLeft().startsWith('✓')) continue;
      final w = roh.trim();
      if (w.isEmpty) continue;
      final art = wortartKorrektur[w] ?? wortart;
      if (File('assets/vocab/$art/${vokabId(art, w)}.json').existsSync()) {
        zeilen[i] = '✓ $w';
        neu++;
      }
    }
    if (neu > 0) datei.writeAsStringSync(zeilen.join('\n'));
    stdout.writeln('$liste: $neu neu abgehakt');
  }
}

void main(List<String> args) {
  if (args.contains('--abhaken')) {
    abhaken();
    return;
  }
  final anzahl = args.isNotEmpty ? int.parse(args.first) : 10;
  final treffer = <(String, String)>[]; // (Wort, Wortart)

  for (final (liste, wortart) in listen) {
    if (wortart == 'verb' && !verbenFreigegeben) {
      stdout.writeln(
        '⛔ Verben gesperrt: vor der ersten Verbkarte Lukas fragen '
        '(Formensuche gehe/ging/gegangen/ausgehen …, eine Seite oder je '
        'Form eine Seite) — danach `verbenFreigegeben = true`.',
      );
      break;
    }
    final datei = File(liste);
    if (!datei.existsSync()) {
      stderr.writeln('Liste fehlt: $liste — im Projektordner starten.');
      exit(1);
    }
    var fertig = 0;
    var offen = 0;
    for (final roh in datei.readAsLinesSync()) {
      final w = roh.replaceFirst(RegExp(r'^\s*✓\s*'), '').trim();
      if (w.isEmpty) continue;
      final art = wortartKorrektur[w] ?? wortart;
      if (File('assets/vocab/$art/${vokabId(art, w)}.json').existsSync()) {
        fertig++;
        continue;
      }
      if (zurueckgestellt.contains(w)) continue;
      offen++;
      if (treffer.length < anzahl) treffer.add((w, art));
    }
    stdout.writeln('$liste ($wortart): $fertig als Karte · $offen offen');
    if (treffer.length >= anzahl) break;
  }

  if (treffer.isEmpty) {
    stdout.writeln('Alle Listen sind durch.');
    return;
  }
  stdout.writeln(
    'Nächste ${treffer.length}: '
    '${treffer.map((t) => '${t.$1} (${t.$2})').join(' · ')}',
  );
}
