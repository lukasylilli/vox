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
const verbenFreigegeben = true; // Lukas 2026-10-11: Variante (b) — PLAN «✅ افعال»

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
  'überwechtet', // Fachwort Schnee/Bergsport, selten, unsicher 2026-10-09
  'unangesehen', // veraltet, eher Präposition, unsicher 2026-10-09
  'unbedankt', // selten, veraltet, unsicher 2026-10-09
  'unbeugbar', // mehrdeutig, selten, unsicher 2026-10-09
  'unbewehrt', // selten, Fachwort, unsicher 2026-10-09
  'undulös', // Fachwort Mineralogie, unsicher 2026-10-09
  'ungerechnet', // Gebrauch als Adjektiv unsicher (eher präpositional) 2026-10-10
  'ungeständig', // seltenes Rechtswort, unsicher 2026-10-10
  'unikursal', // Fachwort Mathematik, unsicher 2026-10-10
  'unitaristisch', // Fachwort Theologie, unsicher 2026-10-10
  'unleidig', // landschaftlich/veraltet, unsicher 2026-10-10
  'unschierig', // Schreibung/Bedeutung unbekannt 2026-10-10
  'unsexy', // umgangssprachlich, sexueller Bezug - Entscheidung Lukas 2026-10-10
  'unterer', // flektierte Form wie oberer 2026-10-10
  'unzial', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'uptodate', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'uranhaltig', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'urcool', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'uroborisch', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'vagil', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'vaginal', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'valabel', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'vanille', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'vaskularisiert', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'veilchenfarben', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'venenös', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'venerisch', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'venetisch', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'vereinslos', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'verfristet', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'vergnügungssüchtig', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'verhaltensgestört', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'verhascht', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'veritabel', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'verkrebst', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'verlustbehaftet', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'vernakulär', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'veronesisch', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'verpflichtungslos', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'verrechenbar', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'verrunzelt', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'versaut', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'verschwendungssüchtig', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'vertiert', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'vertränt', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'verzopft', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'vestibulär', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'vestimentär', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'vielerlei', // zurückgestellt (Regel 14), Grund: PLAN «🏁 مرحله‌ی آخر» 2026-10-10
  'vigil', // zurückgestellt (Regel 14): Bedeutung/Gebrauch unsicher (Fachwort) 2026-10-10
  'vincentisch', // zurückgestellt (Regel 14): Herkunftsadjektiv unsicher 2026-10-10
  'vinophil', // zurückgestellt (Regel 14): selten, Beleg unsicher 2026-10-10
  'vogtländisch', // zurückgestellt (Regel 14): regionales Herkunftsadjektiv wie ostfälisch 2026-10-10
  'volitional', // zurückgestellt (Regel 14): Fachwort, selten; Beleg unsicher 2026-10-10
  'vorderer', // zurückgestellt (Regel 14): flektierte Form wie oberer 2026-10-10
  'vorgabenwirksam', // zurückgestellt (Regel 14): sehr seltener Verwaltungsbegriff 2026-10-10
  'vorletzte', // zurückgestellt (Regel 14): flektierte Form wie letzter 2026-10-10
  'vulkanistisch', // zurückgestellt (Regel 14): Fachwort, Bedeutung unsicher 2026-10-10
  'wegsam', // zurückgestellt (Regel 14): veraltet, selten 2026-10-10
  'wehrig', // zurückgestellt (Regel 14): Bedeutung unsicher 2026-10-10
  'weidlich', // zurückgestellt (Regel 14): Wortart unsicher (Adverb/Adjektiv) 2026-10-10
  'weinfarben', // zurückgestellt (Regel 14): wie beinfarben/lohfarben 2026-10-10
  'weinfröhlich', // zurückgestellt (Regel 14): sehr selten 2026-10-10
  'weinfroh', // zurückgestellt (Regel 14): sehr selten 2026-10-10
  'weingelb', // zurückgestellt (Regel 14): selten, Farbton unsicher 2026-10-10
  'weinhaltig', // zurückgestellt (Regel 14): wie uranhaltig 2026-10-10
  'weinig', // zurückgestellt (Regel 14): selten, Bedeutung unsicher 2026-10-10
  'weinsauer', // zurückgestellt (Regel 14): selten, Bedeutung unsicher 2026-10-10
  'weißfeldrig', // zurückgestellt (Regel 14): Bedeutung unsicher 2026-10-10
  'weißgolden', // zurückgestellt (Regel 14): selten, Bedeutung unsicher 2026-10-10
  'weitentlegen', // zurückgestellt (Regel 14): Schreibung zweifelhaft (weit entlegen) 2026-10-10
  'wergen', // zurückgestellt (Regel 14): Stoffadjektiv wie flächsen 2026-10-10
  'westmitteldeutsch', // zurückgestellt (Regel 14): Fachwort der Dialektologie 2026-10-10
  'westoberdeutsch', // zurückgestellt (Regel 14): Fachwort der Dialektologie 2026-10-10
  'wipfelschäftig', // zurückgestellt (Regel 14): Bedeutung unsicher 2026-10-10
  'wirsch', // zurückgestellt (Regel 14): landschaftlich, Bedeutung schwankend (ärgerlich/verwirrt) 2026-10-11
  'wollen', // zurückgestellt (Regel 14): Stoffadjektiv «aus Wolle», leicht mit Verb wollen verwechselbar 2026-10-11
  'wollüstig', // zurückgestellt (Regel 14): sexuelle Bedeutung — Entscheidung Lukas 2026-10-11
  'wurzelverwandt', // zurückgestellt (Regel 14): selten, Fachwort der Sprachwissenschaft 2026-10-11
  'wuschig', // zurückgestellt (Regel 14): umgangssprachlich, Bedeutung schwankend (nervös / sexuell erregt) 2026-10-11
  'xenophontisch', // zurückgestellt (Regel 14): Eigenname-Adjektiv (Xenophon) 2026-10-11
  'xerographisch', // zurückgestellt (Regel 14): Fachwort, selten 2026-10-11
  'xerophil', // zurückgestellt (Regel 14): Fachwort der Biologie 2026-10-11
  'yttriumhaltig', // zurückgestellt (Regel 14): Fachwort wie uranhaltig 2026-10-11
  'zahlungswirksam', // zurückgestellt (Regel 14): Fachwort der Buchhaltung, Duden-Eintrag unsicher 2026-10-11
  'zapfentragend', // zurückgestellt (Regel 14): Fachwort der Botanik wie gehäusetragend 2026-10-11
  'zedern', // zurückgestellt (Regel 14): Stoffadjektiv wie fichten 2026-10-11
  'zehntpflichtig', // zurückgestellt (Regel 14): historischer Fachbegriff 2026-10-11
  'zeitgeistlich', // zurückgestellt (Regel 14): Bedeutung unsicher 2026-10-11
  'zeitinvariant', // zurückgestellt (Regel 14): Fachwort der Systemtheorie 2026-10-11
  'zementen', // zurückgestellt (Regel 14): Stoffadjektiv, Gebrauch unsicher 2026-10-11
  'zertalt', // zurückgestellt (Regel 14): Fachwort der Geografie, selten 2026-10-11
  'zervikogen', // zurückgestellt (Regel 14): medizinisches Fachwort 2026-10-11
  'zinken', // zurückgestellt (Regel 14): Stoffadjektiv «aus Zink», Gebrauch unsicher 2026-10-11
  'zinnen', // zurückgestellt (Regel 14): Stoffadjektiv wie zinnern 2026-10-11
  'zinnern', // zurückgestellt (Regel 14): Stoffadjektiv wie messingen 2026-10-11
  'zirkumpolar', // zurückgestellt (Regel 14): Fachwort der Astronomie/Geografie 2026-10-11
  'zisalpin', // zurückgestellt (Regel 14): selten, Fachwort der Geschichte 2026-10-11
  'zombig', // zurückgestellt (Regel 14): Umgangssprache, Bedeutung unsicher 2026-10-11
  'zotig', // zurückgestellt (Regel 14): anstößig/sexuell — Entscheidung Lukas 2026-10-11
  'zusammengeritten', // zurückgestellt (Regel 14): Bedeutung unsicher 2026-10-11
  'zweibasig', // zurückgestellt (Regel 14): Fachwort der Chemie 2026-10-11
  'zweibasisch', // zurückgestellt (Regel 14): Fachwort der Chemie 2026-10-11
  'zweihebig', // zurückgestellt (Regel 14): Fachwort der Verslehre 2026-10-11
  'zweitmeist', // zurückgestellt (Regel 14): selten, Duden-Eintrag unsicher 2026-10-11
  'zwirnen', // zurückgestellt (Regel 14): Stoffadjektiv «aus Zwirn» 2026-10-11
  'zygomorph', // zurückgestellt (Regel 14): Fachwort der Botanik 2026-10-11
  'zypressen', // zurückgestellt (Regel 14): Stoffadjektiv wie zedern 2026-10-11
  'zytogen', // zurückgestellt (Regel 14): Fachwort, Bedeutung unsicher 2026-10-11
  'zytotrop', // zurückgestellt (Regel 14): Fachwort, selten 2026-10-11
  'abbedingen', // zurückgestellt (Regel 14): Rechtssprache, sehr selten 2026-10-11
  'abbehalten', // zurückgestellt (Regel 14): umgangssprachlich, selten 2026-10-11
  'abbleichen', // zurückgestellt (Regel 14): selten, Bedeutung schwankend 2026-10-11
  'abdingen', // zurückgestellt (Regel 14): veraltet 2026-10-11
  'abdreschen', // zurückgestellt (Regel 14): selten (fast nur «abgedroschen») 2026-10-11
  'abkneifen', // zurückgestellt (Regel 14): umgangssprachlich, selten («sich etwas abkneifen») 2026-10-11
  'abkönnen', // zurückgestellt (Regel 14): regional umgangssprachlich («nicht abkönnen» = nicht ertragen), Bedeutung schwankend 2026-10-11
  'abliegen', // zurückgestellt (Regel 14): selten («weit abliegen»), fast nur Partizip «abgelegen» 2026-10-11
  'abmelken', // zurückgestellt (Regel 14): Fachwort Landwirtschaft, selten 2026-10-11
  'achthaben', // zurückgestellt (Regel 14): veraltend (= achtgeben) 2026-10-11
  'andringen', // zurückgestellt (Regel 14): veraltet 2026-10-11
  'anessen', // zurückgestellt (Regel 14): umgangssprachlich selten («sich einen Bauch anessen») 2026-10-11
  'anfinden', // zurückgestellt (Regel 14): regional, selten («sich anfinden») 2026-10-11
  'angedeihen', // zurückgestellt (Regel 14): nur in «jemandem etwas angedeihen lassen» — keine eigenen Formen 2026-10-11
  'anheimgeben', // zurückgestellt (Regel 14): gehoben, sehr selten 2026-10-11
  'ankeifen', // zurückgestellt (Regel 14): selten, umgangssprachlich 2026-10-11
  'ankleiben', // zurückgestellt (Regel 14): kein Duden-Eintrag gefunden 2026-10-11
  'ankönnen', // zurückgestellt (Regel 14): umgangssprachlich («gegen jemanden nicht ankönnen»), Formen unsicher 2026-10-11
  'ankriechen', // zurückgestellt (Regel 14): selten (fast nur «angekrochen kommen») 2026-10-11
  'aufbersten', // zurückgestellt (Regel 14): selten, gehoben 2026-10-11
  'aufbrennen', // zurückgestellt (Regel 14): selten, Bedeutung schwankend 2026-10-11
  'aufdringen', // zurückgestellt (Regel 14): veraltet (heute nur «aufdrängen», «aufdringlich») 2026-10-11
  'aufgleiten', // zurückgestellt (Regel 14): selten, Bedeutung/Gebrauch nicht sicher belegt 2026-10-11
  'aufglimmen', // zurückgestellt (Regel 14/16): Stammformen schwanken (glomm/glimmte) ⇒ «regelmaessig» nicht sicher 2026-10-11
  'aufhauen', // zurückgestellt (Regel 14/16): umgangssprachlich; Präteritum (haute/hieb) und Hilfsverb (haben/sein) je nach Bedeutung schwankend 2026-10-11
  'aufkleiben', // zurückgestellt (Regel 14): veraltet/landschaftlich (heute «aufkleben»), Formen unsicher 2026-10-11
  'aufklieben', // zurückgestellt (Regel 14): landschaftlich, Bedeutung/Formen nicht sicher belegt 2026-10-11
  'aufklingen', // zurückgestellt (Regel 14): selten, gehoben 2026-10-11
  'aufliegen', // zurückgestellt (Regel 16): Hilfsverb schwankt (haben; südd./österr./schweiz. sein) — wie abliegen 2026-10-11
  'aufrechtbleiben', // zurückgestellt (Regel 14): Schreibung — nach heutiger Rechtschreibung meist getrennt «aufrecht bleiben» 2026-10-11
  'ausbedingen', // zurückgestellt (Regel 14/16): Präteritum schwankt (bedang/bedingte aus) 2026-10-11
  'ausbiegen', // zurückgestellt (Regel 14): Hauptbedeutung landschaftlich (ausweichen, sein) vs. geradebiegen (haben) — Gebrauch unsicher 2026-10-11
  'ausbieten', // zurückgestellt (Regel 14): selten (zum Verkauf anbieten) 2026-10-11
  'ausbinden', // zurückgestellt (Regel 14): selten/fachsprachlich, Bedeutung schwankend 2026-10-11
  'ausbleichen', // zurückgestellt (Regel 14/16): Formen schwanken (blich/bleichte; ausgeblichen/ausgebleicht), Hilfsverb je nach Bedeutung — wie abbleichen 2026-10-11
  'ausdreschen', // zurückgestellt (Regel 14): selten, fachsprachlich — wie abdreschen 2026-10-11
  'auseinanderbersten', // zurückgestellt (Regel 14): selten, gehoben 2026-10-11
  'auserkiesen', // zurückgestellt (Regel 14): veraltet/gehoben (erkor aus, auserkoren), heute fast nur Partizip «auserkoren» 2026-10-11
  'ausfinden', // zurückgestellt (Regel 14): selten/landschaftlich («sich ausfinden»), Gebrauch unsicher 2026-10-11
  'ausfrieren', // zurückgestellt (Regel 14/16): Bedeutung und Hilfsverb schwankend (durchfrieren ist / ausfrieren lassen hat) 2026-10-11
  'ausgären', // zurückgestellt (Regel 14/16): Formen schwanken (gor/gärte aus) 2026-10-11
  'ausgebären', // zurückgestellt (Regel 14): selten, gehoben 2026-10-11
  'ausgreifen', // zurückgestellt (Regel 14): selten, gehoben (meist nur Partizip «weit ausgreifend») 2026-10-11
  'aushaben', // zurückgestellt (Regel 14): umgangssprachlich, Bedeutungen schwankend 2026-10-11
  'aushängen', // zurückgestellt (Regel 16): transitiv regelmäßig (hängte aus), intransitiv unregelmäßig (hing aus) ⇒ «regelmaessig» nicht eindeutig 2026-10-11
  'aushauen', // zurückgestellt (Regel 14/16): Präteritum schwankt (haute/hieb aus), selten — wie aufhauen 2026-10-11
  'auskiesen', // zurückgestellt (Regel 14/16): veraltet (wie auserkiesen) 2026-10-12
  'auskneifen', // zurückgestellt (Regel 14/16): umgangssprachlich (ausreißen), Gebrauch unsicher 2026-10-12
  'ausliegen', // zurückgestellt (Regel 14/16): Hilfsverb schwankt (haben; südd./österr. sein) — wie aufliegen 2026-10-12
  'ausmahlen', // zurückgestellt (Regel 14/16): selten/fachsprachlich; Formen gemischt (mahlte, gemahlen) 2026-10-12
  'ausmelken', // zurückgestellt (Regel 14/16): selten — wie abmelken 2026-10-12
  'auswärtsgehen', // zurückgestellt (Regel 14/16): selten (mit nach außen gerichteten Füßen gehen) 2026-10-12
  'bedünken', // zurückgestellt (Regel 14/16): veraltet 2026-10-12
  'bedürfen', // zurückgestellt (Regel 14/16): kein gebräuchlicher Imperativ (Präterito-Präsens wie dürfen) — Pflichtfeld imperativ nicht sicher füllbar 2026-10-12
  'befleißen', // zurückgestellt (Regel 14/16): veraltet (heute «sich befleißigen») 2026-10-12
  'beibiegen', // zurückgestellt (Regel 14/16): umgangssprachlich, Gebrauch unsicher 2026-10-12
  'beibleiben', // zurückgestellt (Regel 14/16): selten 2026-10-12
  'beieinanderhaben', // zurückgestellt (Regel 14/16): umgangssprachlich, fast nur Redewendung 2026-10-12
  'beieinanderhalten', // zurückgestellt (Regel 14/16): selten 2026-10-12
  'beifallen', // zurückgestellt (Regel 14/16): veraltet 2026-10-12
  'beigehen', // zurückgestellt (Regel 14/16): veraltet/landschaftlich 2026-10-12
  'beihalten', // zurückgestellt (Regel 14/16): selten, Bedeutung unsicher 2026-10-12
  'beiladen', // zurückgestellt (Regel 14/16): fachsprachlich (Recht/Transport), selten 2026-10-12
  'beiliegen', // zurückgestellt (Regel 14/16): Hilfsverb schwankt (haben; südd./österr. sein) 2026-10-12
  'beisammenhaben', // zurückgestellt (Regel 14/16): umgangssprachlich, fast nur Redewendung 2026-10-12
  'beisammenhalten', // zurückgestellt (Regel 14/16): selten 2026-10-12
  'bekleiben', // zurückgestellt (Regel 14/16): veraltet 2026-10-12
  'belesen', // zurückgestellt (Regel 14/16): als Verb veraltet (heute nur Adjektiv «belesen») 2026-10-12
  'bereitliegen', // zurückgestellt (Regel 14/16): Hilfsverb schwankt (haben; südd./österr. sein) 2026-10-12
  'blickenlassen', // zurückgestellt (Regel 14/16): Schreibung: heute getrennt «sich blicken lassen» 2026-10-12
  'blindfliegen', // zurückgestellt (Regel 14/16): selten; Hilfsverb schwankt 2026-10-12
  'bloßliegen', // zurückgestellt (Regel 14/16): Hilfsverb schwankt (haben; südd./österr. sein) 2026-10-12
  'brachliegen', // zurückgestellt (Regel 14/16): Hilfsverb schwankt (haben; südd./österr. sein) 2026-10-12
  'dafürhalten', // zurückgestellt (Regel 14/16): gehoben, fast nur «nach meinem Dafürhalten» 2026-10-12
  'dafürkönnen', // zurückgestellt (Regel 14/16): umgangssprachlich; kein Imperativ, Konjugation wie Modalverb 2026-10-12
  'daherbringen', // zurückgestellt (Regel 14/16): landschaftlich, selten 2026-10-12
  'daherfliegen', // zurückgestellt (Regel 14/16): selten 2026-10-12
  'dahinfahren', // zurückgestellt (Regel 14/16): gehoben/veraltet (auch: sterben) 2026-10-12
  'dahinfallen', // zurückgestellt (Regel 14/16): schweizerisch/selten 2026-10-12
  'dahinfliegen', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-12
  'dahinfließen', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-12
  'dahingeben', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-12
  'dahingehen', // zurückgestellt (Regel 14/16): gehoben (auch: sterben), Bedeutungen schwankend 2026-10-12
  'dahingleiten', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-12
  'daliegen', // zurückgestellt (Regel 14/16): Hilfsverb schwankt (haben; südd./österr. sein) 2026-10-12
  'danebenfallen', // zurückgestellt (Regel 14/16): selten 2026-10-12
  'danebengelingen', // zurückgestellt (Regel 14/16): Bildung/Gebrauch nicht belegt 2026-10-12
  'danebenhalten', // zurückgestellt (Regel 14/16): selten 2026-10-12
  'danebenhauen', // zurückgestellt (Regel 14/16): umgangssprachlich; Präteritum schwankt (haute/hieb) 2026-10-12
  'danebenliegen', // zurückgestellt (Regel 14/16): umgangssprachlich; Hilfsverb schwankt 2026-10-12
  'daniederliegen', // zurückgestellt (Regel 14/16): gehoben; Hilfsverb schwankt 2026-10-12
  'darangeben', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-12
  'darangehen', // zurückgestellt (Regel 14/16): selten; meist «an etwas gehen» 2026-10-12
  'darbringen', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-12
  'dareinfinden', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-12
  'darleihen', // zurückgestellt (Regel 14/16): veraltet 2026-10-12
  'darniederliegen', // zurückgestellt (Regel 14/16): gehoben; Hilfsverb schwankt 2026-10-12
  'darüberfahren', // zurückgestellt (Regel 14/16): selten; meist getrennt geschrieben 2026-10-12
  'darüberliegen', // zurückgestellt (Regel 14/16): Schreibung/Hilfsverb schwankend 2026-10-12
  'darumbinden', // zurückgestellt (Regel 14/16): selten; meist getrennt geschrieben 2026-10-12
  'darumkommen', // zurückgestellt (Regel 14/16): selten; meist getrennt geschrieben («darum kommen») 2026-10-12
  'darunterbleiben', // zurückgestellt (Regel 14/16): selten; meist getrennt geschrieben 2026-10-12
  'darunterfallen', // zurückgestellt (Regel 14/16): selten; meist getrennt geschrieben 2026-10-12
  'daruntergehen', // zurückgestellt (Regel 14/16): selten 2026-10-12
  'darunterheben', // zurückgestellt (Regel 14/16): selten, Bedeutung unsicher 2026-10-12
  'darunterliegen', // zurückgestellt (Regel 14/16): Schreibung/Hilfsverb schwankend 2026-10-12
  'davonbleiben', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-12
  'davorhalten', // zurückgestellt (Regel 14/16): selten; meist getrennt geschrieben 2026-10-12
  'davorliegen', // zurückgestellt (Regel 14/16): Hilfsverb schwankt; selten 2026-10-12
  'dazuhalten', // zurückgestellt (Regel 14/16): landschaftlich (sich beeilen) 2026-10-12
  'dazukönnen', // zurückgestellt (Regel 14/16): umgangssprachlich; kein Imperativ 2026-10-12
  'dazwischenfragen', // zurückgestellt (Regel 14/16): selten 2026-10-12
  'dazwischenhauen', // zurückgestellt (Regel 14/16): umgangssprachlich; Präteritum schwankt 2026-10-12
  'dazwischenliegen', // zurückgestellt (Regel 14/16): Hilfsverb schwankt (haben; südd./österr. sein) 2026-10-12
  'dortbehalten', // zurückgestellt (Regel 14/16): selten 2026-10-12
  'drangeben', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-12
  'dranhalten', // zurückgestellt (Regel 14/16): umgangssprachlich (sich beeilen), Gebrauch schwankend 2026-10-12
  'dranhängen', // zurückgestellt (Regel 14/16): umgangssprachlich; transitiv regelmäßig/intransitiv unregelmäßig (hängte/hing) 2026-10-12
  'draufgeben', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-12
  'draufhalten', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-12
  'draufhauen', // zurückgestellt (Regel 14/16): umgangssprachlich; Präteritum schwankt (haute/hieb) 2026-10-12
  'drauflosfahren', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-12
  'drauflosgehen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-12
  'drausbringen', // zurückgestellt (Regel 14/16): landschaftlich (südd.) 2026-10-12
  'drauskommen', // zurückgestellt (Regel 14/16): landschaftlich (südd./schweiz.) 2026-10-12
  'dreinfahren', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-12
  'dreinfinden', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-12
  'dreingeben', // zurückgestellt (Regel 14/16): landschaftlich, selten 2026-10-12
  'durchblasen', // zurückgestellt (Regel 14/16): selten 2026-10-12
  'durchbrechen', // zurückgestellt (Regel 14/16): trennbar UND untrennbar mit verschiedener Bedeutung (brach durch / durchbrach) — Symbol nicht eindeutig 2026-10-12
  'durchdenken', // zurückgestellt (Regel 14/16): trennbar UND untrennbar (dachte durch / durchdachte) — Symbol nicht eindeutig 2026-10-12
  'durchdreschen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-12
  'durchdringen', // zurückgestellt (Regel 14/16): trennbar UND untrennbar mit verschiedener Bedeutung — Symbol nicht eindeutig 2026-10-12
  'durchdürfen', // zurückgestellt (Regel 14/16): umgangssprachlich; kein Imperativ (wie dürfen) 2026-10-12
  'durcheinanderessen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-12
  'durcheinanderlaufen', // zurückgestellt (Regel 14/16): selten 2026-10-12
  'durchessen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-12
  'durchfahren', // zurückgestellt (Regel 14/16): trennbar UND untrennbar mit verschiedener Bedeutung — Symbol nicht eindeutig 2026-10-12
  'durchflechten', // zurückgestellt (Regel 14/16): trennbar UND untrennbar mit verschiedener Bedeutung — Symbol nicht eindeutig 2026-10-11
  'durchfliegen', // zurückgestellt (Regel 14/16): trennbar UND untrennbar mit verschiedener Bedeutung — Symbol nicht eindeutig 2026-10-11
  'durchfließen', // zurückgestellt (Regel 14/16): trennbar UND untrennbar mit verschiedener Bedeutung — Symbol nicht eindeutig 2026-10-11
  'durchfressen', // zurückgestellt (Regel 14/16): trennbar UND untrennbar mit verschiedener Bedeutung — Symbol nicht eindeutig 2026-10-11
  'durchfrieren', // zurückgestellt (Regel 14/16): trennbar UND untrennbar mit verschiedener Bedeutung — Symbol nicht eindeutig 2026-10-11
  'durchgären', // zurückgestellt (Regel 14/16): selten (Fachsprache) 2026-10-11
  'durchgraben', // zurückgestellt (Regel 14/16): trennbar UND untrennbar mit verschiedener Bedeutung — Symbol nicht eindeutig 2026-10-11
  'durchhauen', // zurückgestellt (Regel 14/16): trennbar UND untrennbar; Präteritum schwankt (haute/hieb) 2026-10-11
  'durchklingen', // zurückgestellt (Regel 14/16): trennbar UND untrennbar mit verschiedener Bedeutung — Symbol nicht eindeutig 2026-10-11
  'durchkönnen', // zurückgestellt (Regel 14/16): umgangssprachlich; Modalverb-Kompositum, kein Imperativ 2026-10-11
  'durchkriechen', // zurückgestellt (Regel 14/16): trennbar UND untrennbar mit verschiedener Bedeutung — Symbol nicht eindeutig 2026-10-11
  'durchlaufen', // zurückgestellt (Regel 14/16): trennbar UND untrennbar mit verschiedener Bedeutung — Symbol nicht eindeutig 2026-10-11
  'durchmahlen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'durchmüssen', // zurückgestellt (Regel 14/16): umgangssprachlich; Modalverb-Kompositum, kein Imperativ 2026-10-11
  'ehebrechen', // zurückgestellt (Regel 14/16): fast nur im Infinitiv; Konjugation nicht fest 2026-10-11
  'einbacken', // zurückgestellt (Regel 14/16): selten; Präteritum schwankt (buk/backte) 2026-10-11
  'einbegreifen', // zurückgestellt (Regel 14/16): fast nur als Partizip «einbegriffen» 2026-10-11
  'einbeißen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'einblasen', // zurückgestellt (Regel 14/16): selten; umgangssprachliche Bedeutung unsicher 2026-10-11
  'eindreschen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-11
  'einfressen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'eingebären', // zurückgestellt (Regel 14/16): veraltet, selten 2026-10-11
  'einhängen', // zurückgestellt (Regel 14/16): transitiv schwach, intransitiv stark — Formen schwanken 2026-10-11
  'einhauen', // zurückgestellt (Regel 14/16): umgangssprachlich; Präteritum schwankt (haute/hieb) 2026-10-11
  'einhelfen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'einherfahren', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-11
  'einiggehen', // zurückgestellt (Regel 14/16): Schreibung unsicher (einig gehen) 2026-10-11
  'einkneifen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'einkommen', // zurückgestellt (Regel 14/16): amtssprachlich, selten 2026-10-11
  'einwärtsgehen', // zurückgestellt (Regel 14/16): selten, keine feste Form 2026-10-11
  'eislaufen', // zurückgestellt (Regel 14/16): Schreibung der getrennten Formen unsicher (läuft Eis) 2026-10-11
  'emporfahren', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-11
  'emporfliegen', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-11
  'emporheben', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-11
  'entbieten', // zurückgestellt (Regel 14/16): gehoben, veraltet 2026-10-11
  'entgegenfließen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'entzweibeißen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'entzweibrechen', // zurückgestellt (Regel 14/16): Hilfsverb schwankt (haben/sein) 2026-10-11
  'erbieten', // zurückgestellt (Regel 14/16): sich erbieten — gehoben, selten 2026-10-11
  'erbleichen', // zurückgestellt (Regel 14/16): Konjugation schwankt (erbleichte/erblich) 2026-10-11
  'erfechten', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-11
  'erheischen', // zurückgestellt (Regel 14/16): gehoben, veraltet 2026-10-11
  'erkiesen', // zurückgestellt (Regel 14/16): veraltet, selten 2026-10-11
  'erküren', // zurückgestellt (Regel 14/16): veraltet, selten 2026-10-11
  'erlaufen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'erlesen', // zurückgestellt (Regel 14/16): als Verb gehoben; meist Adjektiv «erlesen» 2026-10-11
  'erlügen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'erschrecken', // zurückgestellt (Regel 14/16): intransitiv stark (erschrak), transitiv schwach (erschreckte) — ein Symbol nicht eindeutig 2026-10-11
  'fahen', // zurückgestellt (Regel 14/16): veraltet, selten 2026-10-11
  'fahrenlassen', // zurückgestellt (Regel 14/16): amtliche Schreibung «fahren lassen» (getrennt) 2026-10-11
  'fallenlassen', // zurückgestellt (Regel 14/16): Schreibung schwankt (fallen lassen / fallenlassen) 2026-10-11
  'feilbieten', // zurückgestellt (Regel 14/16): veraltend, selten 2026-10-11
  'feilhalten', // zurückgestellt (Regel 14/16): veraltend, selten 2026-10-11
  'feinmahlen', // zurückgestellt (Regel 14/16): amtliche Schreibung «fein mahlen» (getrennt) 2026-10-11
  'fertiglesen', // zurückgestellt (Regel 14/16): amtliche Schreibung «fertig lesen» (getrennt) 2026-10-11
  'festbleiben', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'fortbegeben', // zurückgestellt (Regel 14/16): sich fortbegeben — gehoben, selten 2026-10-11
  'fortblasen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'fortdenken', // zurückgestellt (Regel 14/16): sich etwas fortdenken — selten (üblich: wegdenken) 2026-10-11
  'fortdürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'fortgießen', // zurückgestellt (Regel 14/16): selten (üblich: weggießen) 2026-10-11
  'forthaben', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-11
  'fortkönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'fortkriechen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'fortmüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'freibleiben', // zurückgestellt (Regel 14/16): im Grundsinn amtlich getrennt («frei bleiben») 2026-10-11
  'freilaufen', // zurückgestellt (Regel 14/16): sich freilaufen (Sport) — selten 2026-10-11
  'gegeneinanderhalten', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'gegenfragen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'geheißen', // zurückgestellt (Regel 14/16): kein Infinitiv, sondern Partizip II von heißen 2026-10-11
  'gutgehen', // zurückgestellt (Regel 14/16): Schreibung schwankt (gut gehen / gutgehen) 2026-10-11
  'heimbegeben', // zurückgestellt (Regel 14/16): sich heimbegeben — gehoben, selten 2026-10-11
  'heimdürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'heimfallen', // zurückgestellt (Regel 14/16): Rechtssprache, selten 2026-10-11
  'heimkönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'heimmüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'heischen', // zurückgestellt (Regel 14/16): gehoben, veraltet; Konjugation unsicher 2026-10-11
  'herabfahren', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-11
  'herabkommen', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-11
  'heranbinden', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'herandürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'herankönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'heranmüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'heraufdringen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'heraufdürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'heraufkönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'heraufmüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'herausbrechen', // zurückgestellt (Regel 14/16): transitiv mit haben, intransitiv mit sein — Hilfsverb nicht eindeutig 2026-10-11
  'herausdringen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'herausdürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'heraushängen', // zurückgestellt (Regel 14/16): transitiv schwach, intransitiv stark — Formen schwanken 2026-10-11
  'heraushauen', // zurückgestellt (Regel 14/16): umgangssprachlich; Präteritum schwankt (haute/hieb) 2026-10-11
  'herausklingen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'herauskönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'herausmüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'herbeifahren', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'herbeifliegen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'herbeilassen', // zurückgestellt (Regel 14/16): sich herbeilassen — gehoben, selten 2026-10-11
  'herdürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hereindringen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hereindürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hereingeben', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hereinkönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hereinkriechen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hereinmüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'herkönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hermüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'herniederfallen', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-11
  'herniedergehen', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-11
  'herüberdringen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'herüberdürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'herüberfliegen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'herüberhängen', // zurückgestellt (Regel 14/16): transitiv schwach, intransitiv stark — Formen schwanken 2026-10-11
  'herüberkönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'herübermüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'herumbiegen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'herumbinden', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'herumgreifen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'herumhaben', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-11
  'herumhängen', // zurückgestellt (Regel 14/16): transitiv schwach, intransitiv stark — Formen schwanken 2026-10-11
  'herumkriechen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'herunterbiegen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'herunterbrechen', // zurückgestellt (Regel 14/16): transitiv mit haben, intransitiv mit sein — Hilfsverb nicht eindeutig 2026-10-11
  'herunterbrennen', // zurückgestellt (Regel 14/16): transitiv mit haben, intransitiv mit sein — Hilfsverb nicht eindeutig 2026-10-11
  'herunterdürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'herunterfliegen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-11
  'heruntergießen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'heruntergleiten', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'herunterhängen', // zurückgestellt (Regel 14/16): transitiv schwach, intransitiv stark — Formen schwanken 2026-10-11
  'herunterhauen', // zurückgestellt (Regel 14/16): umgangssprachlich; Präteritum schwankt (haute/hieb) 2026-10-11
  'herunterkönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'herunterkriechen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'heruntermüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hervordringen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'herzukommen', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-11
  'hinabfahren', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-11
  'hinaufdürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hinauffallen', // zurückgestellt (Regel 14/16): fast nur in der Wendung «die Treppe hinauffallen» 2026-10-11
  'hinaufkönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hinaufkriechen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinauflassen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinaufmüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hinausbegeben', // zurückgestellt (Regel 14/16): sich hinausbegeben — gehoben, selten 2026-10-11
  'hinausblasen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinausdenken', // zurückgestellt (Regel 14/16): fast nur «über etwas hinausdenken»; selten 2026-10-11
  'hinausdringen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinausdürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hinausgreifen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinaushalten', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinaushängen', // zurückgestellt (Regel 14/16): transitiv schwach, intransitiv stark — Formen schwanken 2026-10-11
  'hinausheben', // zurückgestellt (Regel 14/16): fast nur «über etwas hinausheben»; selten 2026-10-11
  'hinauskönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hinausmüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hinbegeben', // zurückgestellt (Regel 14/16): sich hinbegeben — gehoben, selten 2026-10-11
  'hinbieten', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-11
  'hindurchdringen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hindurchdürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hindurchfließen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hindurchkönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hindurchkriechen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hindurchmüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hindürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hineinbegeben', // zurückgestellt (Regel 14/16): sich hineinbegeben — gehoben, selten 2026-10-11
  'hineinblasen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hineinbrennen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hineindringen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hineindürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hineinfliegen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hineinfressen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten (in sich hineinfressen) 2026-10-11
  'hineingleiten', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hineingreifen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hineinhalten', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hineinhängen', // zurückgestellt (Regel 14/16): transitiv schwach, intransitiv stark — Formen schwanken 2026-10-11
  'hineinkönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hineinkriechen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hineinmüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hinfließen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hingießen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hingleiten', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinhaben', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-11
  'hinhängen', // zurückgestellt (Regel 14/16): transitiv schwach, intransitiv stark — Formen schwanken 2026-10-11
  'hinhauen', // zurückgestellt (Regel 14/16): umgangssprachlich; Präteritum schwankt (haute/hieb) 2026-10-11
  'hinkönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hinmüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hintanbleiben', // zurückgestellt (Regel 14/16): veraltet, selten 2026-10-11
  'hintanhalten', // zurückgestellt (Regel 14/16): veraltet, selten 2026-10-11
  'hintenüberfallen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinterbringen', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-11
  'hintereinanderfahren', // zurückgestellt (Regel 14/16): amtliche Schreibung getrennt («hintereinander …») 2026-10-11
  'hintereinandergehen', // zurückgestellt (Regel 14/16): amtliche Schreibung getrennt («hintereinander …») 2026-10-11
  'hintereinanderlaufen', // zurückgestellt (Regel 14/16): amtliche Schreibung getrennt («hintereinander …») 2026-10-11
  'hinteressen', // zurückgestellt (Regel 14/16): kein bekanntes Wort (vermutlich Listenfehler) 2026-10-11
  'hintergießen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-11
  'hinterlaufen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinüberbegeben', // zurückgestellt (Regel 14/16): sich hinüberbegeben — gehoben, selten 2026-10-11
  'hinüberdürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hinüberfliegen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinübergleiten', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinübergreifen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinüberhängen', // zurückgestellt (Regel 14/16): transitiv schwach, intransitiv stark — Formen schwanken 2026-10-11
  'hinüberkönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hinüberlassen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinunterdürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hinunterfliegen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-11
  'hinuntergießen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinwegbegeben', // zurückgestellt (Regel 14/16): sich hinwegbegeben — gehoben, selten 2026-10-11
  'hinwegbringen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinweglesen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinzubekommen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinzudenken', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinzuerfinden', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hinzulaufen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hochbiegen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hochbinden', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hochfliegen', // zurückgestellt (Regel 14/16): umgangssprachlich; Bedeutung schwankt (auffliegen/explodieren) 2026-10-11
  'hochkönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hochkriechen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'hochmüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'hockenbleiben', // zurückgestellt (Regel 14/16): amtliche Schreibung getrennt («hocken bleiben») 2026-10-11
  'hofhalten', // zurückgestellt (Regel 14/16): gehoben/historisch; auch «Hof halten» geschrieben 2026-10-11
  'küren', // zurückgestellt (Regel 14/16): Präteritum schwankt (kor/kürte) 2026-10-11
  'langliegen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-11
  'laufenlassen', // zurückgestellt (Regel 14/16): Schreibung schwankt (laufen lassen / laufenlassen) 2026-10-11
  'leeressen', // zurückgestellt (Regel 14/16): amtliche Schreibung getrennt («leer essen») 2026-10-11
  'liebbehalten', // zurückgestellt (Regel 14/16): amtliche Schreibung getrennt («lieb behalten») 2026-10-11
  'liegenbleiben', // zurückgestellt (Regel 14/16): Schreibung schwankt (getrennt/zusammen) 2026-10-11
  'liegenlassen', // zurückgestellt (Regel 14/16): Schreibung schwankt (getrennt/zusammen) 2026-10-11
  'losbrechen', // zurückgestellt (Regel 14/16): transitiv mit haben, intransitiv mit sein — Hilfsverb nicht eindeutig 2026-10-11
  'losdreschen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-11
  'losdürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'loshaben', // zurückgestellt (Regel 14/16): umgangssprachlich; Bedeutung schwankt 2026-10-11
  'loshalten', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'loskönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'losmüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'mitbieten', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'mitdürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'mitempfinden', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-11
  'mitklingen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'mitkönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'mitlassen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'mitmüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'nachdürfen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'nachfallen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'nachgären', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'nachgreifen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'nachhalten', // zurückgestellt (Regel 14/16): als Verb selten (üblich: Adjektiv «nachhaltig») 2026-10-11
  'nachkönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'nachmüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'näherliegen', // zurückgestellt (Regel 14/16): amtliche Schreibung getrennt bzw. schwankend 2026-10-11
  'nebeneinanderhalten', // zurückgestellt (Regel 14/16): amtliche Schreibung getrennt bzw. schwankend 2026-10-11
  'nebeneinanderliegen', // zurückgestellt (Regel 14/16): amtliche Schreibung getrennt bzw. schwankend 2026-10-11
  'niederbrechen', // zurückgestellt (Regel 14/16): transitiv mit haben, intransitiv mit sein — Hilfsverb nicht eindeutig 2026-10-11
  'niederbrennen', // zurückgestellt (Regel 14/16): transitiv mit haben, intransitiv mit sein — Hilfsverb nicht eindeutig 2026-10-11
  'niederbringen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'niederdreschen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-11
  'niederfahren', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-11
  'niederhauen', // zurückgestellt (Regel 14/16): umgangssprachlich; Präteritum schwankt (haute/hieb) 2026-10-11
  'obliegen', // zurückgestellt (Regel 14/16): trennbar (liegt ob) und untrennbar (obliegt) — Symbol nicht eindeutig 2026-10-11
  'offenliegen', // zurückgestellt (Regel 14/16): selten 2026-10-11
  'paarlaufen', // zurückgestellt (Regel 14/16): seltener Sportbegriff; getrennte Formen unsicher 2026-10-11
  'platzenlassen', // zurückgestellt (Regel 14/16): Schreibung schwankt (platzen lassen / platzenlassen) 2026-10-11
  'quellen', // zurückgestellt (Regel 14/16): intransitiv stark (quoll), transitiv schwach (quellte) — Formen schwanken 2026-10-11
  'querkommen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-11
  'ranbinden', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-11
  'rankönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'ranmüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-11
  'reinfliegen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-13
  'reinhauen', // zurückgestellt (Regel 14/16): umgangssprachlich; Präteritum schwankt (haute/hieb) 2026-10-13
  'reinkönnen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-13
  'reinmüssen', // zurückgestellt (Regel 14/16): Modalverb-Kompositum (umgangssprachlich), kein Imperativ 2026-10-13
  'richtigliegen', // zurückgestellt (Regel 14/16): umgangssprachlich; Hilfsverb regional schwankend (haben/sein) 2026-10-13
  'rinnen', // zurückgestellt (Regel 14/16): gehoben/selten; Konjunktiv II schwankt (ränne/rönne) 2026-10-13
  'rückfragen', // zurückgestellt (Regel 14/16): nur im Infinitiv/Partizip II gebräuchlich (defektiv) 2026-10-13
  'rückwärtsfahren', // zurückgestellt (Regel 14/16): Schreibung schwankt (rückwärts fahren / rückwärtsfahren) 2026-10-13
  'rückwärtsgehen', // zurückgestellt (Regel 14/16): Schreibung/Bedeutung schwankt (rückwärts gehen / rückwärtsgehen = sich verschlechtern) 2026-10-13
  'ruhenlassen', // zurückgestellt (Regel 14/16): Schreibung schwankt (ruhen lassen / ruhenlassen) 2026-10-13
  'rumhaben', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-13
  'rumhängen', // zurückgestellt (Regel 14/16): hängen-Kompositum (wie herumhängen) 2026-10-13
  'rundfragen', // zurückgestellt (Regel 14/16): selten, kaum konjugiert gebräuchlich 2026-10-13
  'runterfliegen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-13
  'runterhauen', // zurückgestellt (Regel 14/16): umgangssprachlich; Präteritum schwankt (haute/hieb) 2026-10-13
  'sattbekommen', // zurückgestellt (Regel 14/16): Schreibung schwankt (satt bekommen / sattbekommen) 2026-10-13
  'satthaben', // zurückgestellt (Regel 14/16): Schreibung schwankt (satt haben / satthaben) 2026-10-13
  'saugen', // zurückgestellt (Regel 14/16): Präteritum schwankt (sog/saugte) 2026-10-13
  'sausenlasen', // zurückgestellt (Regel 14/16): Schreibfehler der Liste (sausenlassen); Schreibung schwankt 2026-10-13
  'schaffen', // zurückgestellt (Regel 14/16): zwei Konjugationen je Bedeutung (schuf/geschaffen ↔ schaffte/geschafft) 2026-10-13
  'schallen', // zurückgestellt (Regel 14/16): Präteritum schwankt (scholl/schallte) 2026-10-13
  'scheren', // zurückgestellt (Regel 14/16): zwei Konjugationen je Bedeutung (schor ↔ scherte) 2026-10-13
  'schiefliegen', // zurückgestellt (Regel 14/16): umgangssprachlich; Hilfsverb regional schwankend (haben/sein) 2026-10-13
  'schießenlassen', // zurückgestellt (Regel 14/16): Schreibung schwankt (schießen lassen / schießenlassen) 2026-10-13
  'schinden', // zurückgestellt (Regel 14/16): Präteritum schwankt (schindete/schund) 2026-10-13
  'schlechtgehen', // zurückgestellt (Regel 14/16): unpersönlich (wie gutgehen); Schreibung schwankt 2026-10-13
  'schleifen', // zurückgestellt (Regel 14/16): zwei Konjugationen je Bedeutung (schliff ↔ schleifte) 2026-10-13
  'schleifenlassen', // zurückgestellt (Regel 14/16): Schreibung schwankt (schleifen lassen / schleifenlassen) 2026-10-13
  'schleißen', // zurückgestellt (Regel 14/16): selten; Präteritum schwankt (schliss/schleißte) 2026-10-13
  'schliefen', // zurückgestellt (Regel 14/16): Listenfehler: Präteritum von «schlafen», kein Infinitiv 2026-10-13
  'schmalzen', // zurückgestellt (Regel 14/16): selten; Partizip schwankt (geschmalzt/geschmalzen) 2026-10-13
  'schmorenlassen', // zurückgestellt (Regel 14/16): Schreibung schwankt (schmoren lassen / schmorenlassen) 2026-10-13
  'schockgefrieren', // zurückgestellt (Regel 14/16): nur im Infinitiv/Partizip II gebräuchlich (defektiv) 2026-10-13
  'schrecken', // zurückgestellt (Regel 14/16): zwei Konjugationen je Bedeutung (schrak ↔ schreckte) 2026-10-13
  'schroten', // zurückgestellt (Regel 14/16): selten (Fachwort) 2026-10-13
  'schwären', // zurückgestellt (Regel 14/16): veraltet; Präteritum schwankt (schwor/schwärte) 2026-10-13
  'schwarzbrennen', // zurückgestellt (Regel 14/16): selten (Fachjargon) 2026-10-13
  'schweifen', // zurückgestellt (Regel 14/16): gehoben/selten 2026-10-13
  'schwellen', // zurückgestellt (Regel 14/16): zwei Konjugationen je Bedeutung (schwoll ↔ schwellte) 2026-10-13
  'schwerhalten', // zurückgestellt (Regel 14/16): selten; Bedeutung/Schreibung unsicher 2026-10-13
  'segelfliegen', // zurückgestellt (Regel 14/16): nur im Infinitiv gebräuchlich (defektiv) 2026-10-13
  'seinlassen', // zurückgestellt (Regel 14/16): Schreibung schwankt (sein lassen / seinlassen) 2026-10-13
  'setzenlassen', // zurückgestellt (Regel 14/16): Schreibung/Bedeutung unsicher (setzen lassen) 2026-10-13
  'sieden', // zurückgestellt (Regel 14/16): Präteritum schwankt (sott/siedete) 2026-10-13
  'sinnen', // zurückgestellt (Regel 14/16): gehoben/selten; Konjunktiv II schwankt (sänne/sönne) 2026-10-13
  'sitzenbleiben', // zurückgestellt (Regel 14/16): Schreibung schwankt (sitzen bleiben / sitzenbleiben) 2026-10-13
  'sitzenlassen', // zurückgestellt (Regel 14/16): Schreibung schwankt (sitzen lassen / sitzenlassen) 2026-10-13
  'spalten', // zurückgestellt (Regel 14/16): Partizip II schwankt (gespalten/gespaltet) 2026-10-13
  'spitzbekommen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-13
  'spitzhaben', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-13
  'spleißen', // zurückgestellt (Regel 14/16): Fachwort; Präteritum schwankt (spliss/spleißte) 2026-10-13
  'statthaben', // zurückgestellt (Regel 14/16): veraltet/selten 2026-10-13
  'steckenbleiben', // zurückgestellt (Regel 14/16): Schreibung schwankt (stecken bleiben / steckenbleiben) 2026-10-13
  'steckenlassen', // zurückgestellt (Regel 14/16): Schreibung schwankt (stecken lassen / steckenlassen) 2026-10-13
  'stehenbleiben', // zurückgestellt (Regel 14/16): Schreibung schwankt (stehen bleiben / stehenbleiben) 2026-10-13
  'stehenlassen', // zurückgestellt (Regel 14/16): Schreibung schwankt (stehen lassen / stehenlassen) 2026-10-13
  'steifhalten', // zurückgestellt (Regel 14/16): Schreibung schwankt (steif halten / steifhalten) 2026-10-13
  'stieben', // zurückgestellt (Regel 14/16): selten; Präteritum schwankt (stob/stiebte) 2026-10-13
  'stillbleiben', // zurückgestellt (Regel 14/16): Schreibung schwankt (still bleiben / stillbleiben) 2026-10-13
  'stillhalten', // zurückgestellt (Regel 14/16): Schreibung schwankt (still halten / stillhalten) 2026-10-13
  'stillliegen', // zurückgestellt (Regel 14/16): Schreibung schwankt; Hilfsverb regional schwankend 2026-10-13
  'tiefgefrieren', // zurückgestellt (Regel 14/16): nur im Infinitiv/Partizip II gebräuchlich (defektiv) 2026-10-13
  'totbeißen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'totlaufen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten (sich totlaufen) 2026-10-13
  'triefen', // zurückgestellt (Regel 14/16): Präteritum schwankt (troff/triefte) 2026-10-13
  'trockenfallen', // zurückgestellt (Regel 14/16): selten (Fachwort); Schreibung schwankt 2026-10-13
  'überbacken', // zurückgestellt (Regel 14/16): Präsens/Präteritum schwanken (überbäckt/überbackt, überbuk/überbackte) 2026-10-13
  'überbekommen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-13
  'überbinden', // zurückgestellt (Regel 14/16): regional (schweiz.), selten 2026-10-13
  'überblasen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'überbleiben', // zurückgestellt (Regel 14/16): umgangssprachlich (= übrig bleiben), selten 2026-10-13
  'überbraten', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-13
  'überbrennen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'übereinanderliegen', // zurückgestellt (Regel 14/16): Schreibung schwankt (übereinander liegen) 2026-10-13
  'überessen', // zurückgestellt (Regel 14/16): trennbar und untrennbar; Symbol nicht eindeutig 2026-10-13
  'überfahren', // zurückgestellt (Regel 14/16): trennbar und untrennbar mit verschiedener Bedeutung; Symbol nicht eindeutig 2026-10-13
  'überfallen', // zurückgestellt (Regel 14/16): trennbar/untrennbar nicht sicher geklärt; Symbol nicht eindeutig 2026-10-13
  'überfangen', // zurückgestellt (Regel 14/16): selten (Fachwort) 2026-10-13
  'überfliegen', // zurückgestellt (Regel 14/16): trennbar/untrennbar nicht sicher geklärt; Symbol nicht eindeutig 2026-10-13
  'überfließen', // zurückgestellt (Regel 14/16): trennbar/untrennbar nicht sicher geklärt; Symbol nicht eindeutig 2026-10-13
  'überfragen', // zurückgestellt (Regel 14/16): fast nur «überfragt sein» (defektiv) 2026-10-13
  'überfressen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-13
  'überfrieren', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'übergehen', // zurückgestellt (Regel 14/16): trennbar und untrennbar mit verschiedener Bedeutung; Symbol nicht eindeutig 2026-10-13
  'übergießen', // zurückgestellt (Regel 14/16): trennbar und untrennbar; Symbol nicht eindeutig 2026-10-13
  'überhaben', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-13
  'überhängen', // zurückgestellt (Regel 14/16): hängen-Kompositum; trennbar/untrennbar 2026-10-13
  'überheben', // zurückgestellt (Regel 14/16): trennbar und untrennbar; Symbol nicht eindeutig 2026-10-13
  'überkommen', // zurückgestellt (Regel 14/16): trennbar und untrennbar; Symbol nicht eindeutig 2026-10-13
  'überladen', // zurückgestellt (Regel 14/16): trennbar und untrennbar; Symbol nicht eindeutig 2026-10-13
  'überlaufen', // zurückgestellt (Regel 14/16): trennbar und untrennbar mit verschiedener Bedeutung; Symbol nicht eindeutig 2026-10-13
  'überlesen', // zurückgestellt (Regel 14/16): trennbar und untrennbar; Symbol nicht eindeutig 2026-10-13
  'übrigbleiben', // zurückgestellt (Regel 14/16): Schreibung schwankt (übrig bleiben / übrigbleiben) 2026-10-13
  'übrighaben', // zurückgestellt (Regel 14/16): Schreibung schwankt (übrig haben / übrighaben) 2026-10-13
  'übriglassen', // zurückgestellt (Regel 14/16): Schreibung schwankt (übrig lassen / übriglassen) 2026-10-13
  'umbehalten', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-13
  'umbinden', // zurückgestellt (Regel 14/16): trennbar/untrennbar nicht sicher geklärt; Symbol nicht eindeutig 2026-10-13
  'umbrechen', // zurückgestellt (Regel 14/16): trennbar und untrennbar mit verschiedener Bedeutung; Symbol nicht eindeutig 2026-10-13
  'umfahren', // zurückgestellt (Regel 14/16): trennbar und untrennbar mit verschiedener Bedeutung; Symbol nicht eindeutig 2026-10-13
  'umfangen', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-13
  'umflechten', // zurückgestellt (Regel 14/16): selten (Fachwort) 2026-10-13
  'umfliegen', // zurückgestellt (Regel 14/16): trennbar und untrennbar mit verschiedener Bedeutung; Symbol nicht eindeutig 2026-10-13
  'umfragen', // zurückgestellt (Regel 14/16): selten, kaum konjugiert gebräuchlich 2026-10-13
  'umgeben', // zurückgestellt (Regel 14/16): trennbar (ugs. umlegen) und untrennbar (umringen); Symbol nicht eindeutig 2026-10-13
  'umgehen', // zurückgestellt (Regel 14/16): trennbar und untrennbar mit verschiedener Bedeutung; Symbol nicht eindeutig 2026-10-13
  'umgreifen', // zurückgestellt (Regel 14/16): trennbar und untrennbar mit verschiedener Bedeutung; Symbol nicht eindeutig 2026-10-13
  'umhaben', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-13
  'umhängen', // zurückgestellt (Regel 14/16): hängen-Kompositum; transitiv schwach, intransitiv stark — Formen schwanken 2026-10-13
  'umhauen', // zurückgestellt (Regel 14/16): umgangssprachlich; Präteritum schwankt (haute/hieb) 2026-10-13
  'umherkriechen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'umhinkönnen', // zurückgestellt (Regel 14/16): Modalverb-Kombination (wie loskönnen); Lemma «umhinkommen» hat Karte 2026-10-13
  'umlassen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-13
  'umlaufen', // zurückgestellt (Regel 14/16): trennbar und untrennbar mit verschiedener Bedeutung; Symbol nicht eindeutig 2026-10-13
  'unterbinden', // zurückgestellt (Regel 14/16): trennbar und untrennbar mit verschiedener Bedeutung; Symbol nicht eindeutig 2026-10-13
  'untereinanderliegen', // zurückgestellt (Regel 14/16): Schreibung schwankt (untereinander liegen) 2026-10-13
  'unterfahren', // zurückgestellt (Regel 14/16): selten; trennbar/untrennbar nicht sicher geklärt 2026-10-13
  'unterfallen', // zurückgestellt (Regel 14/16): selten (Amtssprache) 2026-10-13
  'unterfliegen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'untergraben', // zurückgestellt (Regel 14/16): trennbar und untrennbar mit verschiedener Bedeutung; Symbol nicht eindeutig 2026-10-13
  'unterhalten', // zurückgestellt (Regel 14/16): trennbar und untrennbar mit verschiedener Bedeutung; Symbol nicht eindeutig 2026-10-13
  'unterkriechen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'unterlaufen', // zurückgestellt (Regel 14/16): trennbar/untrennbar nicht sicher geklärt; Hilfsverb je nach Bedeutung (sein/haben) 2026-10-13
  'unterliegen', // zurückgestellt (Regel 14/16): trennbar (landsch. darunterliegen) und untrennbar (besiegt werden); Symbol nicht eindeutig 2026-10-13
  'verbacken', // zurückgestellt (Regel 14/16): Formen schwanken (verbäckt/verbackt, verbackte/verbuk) 2026-10-13
  'verblasen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'verbleichen', // zurückgestellt (Regel 14/16): Präteritum schwankt (verblich/verbleichte) 2026-10-13
  'verdingen', // zurückgestellt (Regel 14/16): veraltet; Formen schwanken (verdingte/verdang, verdungen/verdingt) 2026-10-13
  'verdreschen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten (dreschen-Komposita) 2026-10-13
  'verdrießen', // zurückgestellt (Regel 14/16): gehoben, selten; fast nur unpersönlich 2026-10-13
  'vergären', // zurückgestellt (Regel 14/16): Formen schwanken (vergor/vergärte) 2026-10-13
  'verglimmen', // zurückgestellt (Regel 14/16): selten; Formen schwanken (verglomm/verglimmte) 2026-10-13
  'verhauen', // zurückgestellt (Regel 14/16): umgangssprachlich; Präteritum schwankt (verhaute/verhieb) 2026-10-13
  'verkiesen', // zurückgestellt (Regel 14/16): veraltet (wie erkiesen, auskiesen) 2026-10-13
  'verkleiben', // zurückgestellt (Regel 14/16): veraltet, selten (wie ankleiben) 2026-10-13
  'verleitgeben', // zurückgestellt (Regel 14/16): regional (bair./österr.), selten; Bedeutung unsicher 2026-10-13
  'verlorengeben', // zurückgestellt (Regel 14/16): Schreibung schwankt (verloren geben / verlorengeben) 2026-10-13
  'verlorengehen', // zurückgestellt (Regel 14/16): Schreibung schwankt (verloren gehen / verlorengehen) 2026-10-13
  'vermahlen', // zurückgestellt (Regel 14/16): fachsprachlich; gemischte Konjugation (wie ausmahlen) 2026-10-13
  'verquergehen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten; Schreibung unsicher 2026-10-13
  'verschüttgehen', // zurückgestellt (Regel 14/16): umgangssprachlich; Schreibung schwankt (verschütt gehen) 2026-10-13
  'vollessen', // zurückgestellt (Regel 14/16): Schreibung schwankt (sich voll essen / vollessen) 2026-10-13
  'vollfressen', // zurückgestellt (Regel 14/16): Schreibung schwankt (sich voll fressen / vollfressen) 2026-10-13
  'vollgießen', // zurückgestellt (Regel 14/16): Schreibung schwankt (voll gießen / vollgießen) 2026-10-13
  'vollladen', // zurückgestellt (Regel 14/16): Schreibung schwankt (voll laden / vollladen) 2026-10-13
  'volllaufen', // zurückgestellt (Regel 14/16): Schreibung schwankt (voll laufen / volllaufen) 2026-10-13
  'voraufgehen', // zurückgestellt (Regel 14/16): veraltet/gehoben (= vorangehen) 2026-10-13
  'vorausfliegen', // zurückgestellt (Regel 14/16): selten (wie herüberfliegen, hineinfliegen) 2026-10-13
  'vorbeidürfen', // zurückgestellt (Regel 14/16): Modalverb-Verbindung (wie hindurchdürfen) 2026-10-13
  'vorbeifließen', // zurückgestellt (Regel 14/16): selten (wie hinfließen, dahinfließen) 2026-10-13
  'vorbeigelingen', // zurückgestellt (Regel 14/16): kein gebräuchliches Wort (wie danebengelingen) 2026-10-13
  'vorbeigleiten', // zurückgestellt (Regel 14/16): selten (wie hingleiten) 2026-10-13
  'vorbeikönnen', // zurückgestellt (Regel 14/16): Modalverb-Verbindung 2026-10-13
  'vorbeimüssen', // zurückgestellt (Regel 14/16): Modalverb-Verbindung 2026-10-13
  'vorblasen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'voreinanderliegen', // zurückgestellt (Regel 14/16): Schreibung/Gebrauch unsicher (wie nebeneinanderliegen) 2026-10-13
  'vorenthalten', // zurückgestellt (Regel 14/16): trennbar/untrennbar schwankend (enthielt vor / vorenthielt) 2026-10-13
  'voressen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'vorfliegen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'vorgebären', // zurückgestellt (Regel 14/16): kein gebräuchliches Wort 2026-10-13
  'vorhängen', // zurückgestellt (Regel 14/16): hängen-Verbindung: transitiv/intransitiv schwankend (wie hinhängen) 2026-10-13
  'vorlaufen', // zurückgestellt (Regel 14/16): selten; meist vorauslaufen 2026-10-13
  'vornüberfallen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'vorüberfahren', // zurückgestellt (Regel 14/16): gehoben, selten (= vorbeifahren) 2026-10-13
  'vorüberfliegen', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-13
  'vorübergleiten', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-13
  'vorüberkommen', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-13
  'vorüberlassen', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-13
  'vorüberlaufen', // zurückgestellt (Regel 14/16): gehoben, selten 2026-10-13
  'vorwärtslaufen', // zurückgestellt (Regel 14/16): Schreibung je nach Bedeutung (vorwärts laufen) 2026-10-13
  'wachhalten', // zurückgestellt (Regel 14/16): Schreibung schwankt (wach halten / wachhalten) 2026-10-13
  'wägen', // zurückgestellt (Regel 14/16): Formen schwanken (wog/wägte); gehoben 2026-10-13
  'wahrhaben', // zurückgestellt (Regel 14/16): nur «nicht wahrhaben wollen» (defektiv) 2026-10-13
  'warmhalten', // zurückgestellt (Regel 14/16): Schreibung schwankt (warm halten / warmhalten) 2026-10-13
  'warmlaufen', // zurückgestellt (Regel 14/16): Schreibung schwankt (warm laufen / warmlaufen) 2026-10-13
  'wegbegeben', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'wegbeißen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'wegbinden', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'wegbrechen', // zurückgestellt (Regel 14/16): Hilfsverb nicht eindeutig (sein/haben, wie herausbrechen) 2026-10-13
  'wegbrennen', // zurückgestellt (Regel 14/16): selten; Hilfsverb schwankt 2026-10-13
  'wegdürfen', // zurückgestellt (Regel 14/16): Modalverb-Verbindung 2026-10-13
  'wegfangen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'wegfließen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'wegfressen', // zurückgestellt (Regel 14/16): umgangssprachlich/derb (wie wegessen) 2026-10-13
  'weghaben', // zurückgestellt (Regel 14/16): umgangssprachlich (wie herumhaben) 2026-10-13
  'weghalten', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'weghauen', // zurückgestellt (Regel 14/16): Präteritum schwankt (haute/hieb) 2026-10-13
  'weghelfen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'wegkönnen', // zurückgestellt (Regel 14/16): Modalverb-Verbindung 2026-10-13
  'wegkriechen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'wegmüssen', // zurückgestellt (Regel 14/16): Modalverb-Verbindung 2026-10-13
  'weiterdürfen', // zurückgestellt (Regel 14/16): Modalverb-Verbindung 2026-10-13
  'weiterfragen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'weiterfressen', // zurückgestellt (Regel 14/16): umgangssprachlich/derb 2026-10-13
  'weiterkönnen', // zurückgestellt (Regel 14/16): Modalverb-Verbindung 2026-10-13
  'weiterkriechen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'weitermüssen', // zurückgestellt (Regel 14/16): Modalverb-Verbindung 2026-10-13
  'wenden', // zurückgestellt (Regel 14/16): zwei Konjugationen je nach Bedeutung (wandte/wendete, wie schaffen) 2026-10-13
  'werthalten', // zurückgestellt (Regel 14/16): veraltet, selten 2026-10-13
  'wettlaufen', // zurückgestellt (Regel 14/16): fast nur im Infinitiv 2026-10-13
  'widerklingen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'wiedererhalten', // zurückgestellt (Regel 14/16): selten (meist zurückerhalten) 2026-10-13
  'wiederhaben', // zurückgestellt (Regel 14/16): umgangssprachlich 2026-10-13
  'wiederkennen', // zurückgestellt (Regel 14/16): selten/regional 2026-10-13
  'wiegen', // zurückgestellt (Regel 14/16): zwei Verben (wog = Gewicht / wiegte = schaukeln), wie schaffen 2026-10-13
  'wissenlassen', // zurückgestellt (Regel 14/16): Schreibung (wissen lassen) 2026-10-13
  'wundliegen', // zurückgestellt (Regel 14/16): Schreibung schwankt (wund liegen) 2026-10-13
  'zeihen', // zurückgestellt (Regel 14/16): veraltet 2026-10-13
  'zerbersten', // zurückgestellt (Regel 14/16): selten/gehoben (wie aufbersten, auseinanderbersten) 2026-10-13
  'zerfahren', // zurückgestellt (Regel 14/16): als Verb selten (meist Adjektiv «zerfahren») 2026-10-13
  'zerhauen', // zurückgestellt (Regel 14/16): haute/hieb (wie aufhauen) 2026-10-13
  'zerklieben', // zurückgestellt (Regel 14/16): veraltet 2026-10-13
  'zerlesen', // zurückgestellt (Regel 14/16): als Verb selten (meist Adjektiv «zerlesen») 2026-10-13
  'zermahlen', // zurückgestellt (Regel 14/16): mahlte/gemahlen (wie ausmahlen, vermahlen) 2026-10-13
  'zudenken', // zurückgestellt (Regel 14/16): fast nur im Partizip («zugedacht») 2026-10-13
  'zueinanderdürfen', // zurückgestellt (Regel 14/16): Modalverb-Verbindung 2026-10-13
  'zueinanderhalten', // zurückgestellt (Regel 14/16): Schreibung schwankt (zueinander halten) 2026-10-13
  'zueinanderkommen', // zurückgestellt (Regel 14/16): Schreibung schwankt (zueinander kommen) 2026-10-13
  'zueinanderkönnen', // zurückgestellt (Regel 14/16): Modalverb-Verbindung 2026-10-13
  'zueinanderlassen', // zurückgestellt (Regel 14/16): Schreibung schwankt, selten 2026-10-13
  'zuerkennen', // zurückgestellt (Regel 14/16): trennbar/untrennbar schwankt (erkannte zu / zuerkannte) 2026-10-13
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
  'viel': 'numerale', // Duden: unbestimmtes Zahlwort/Indefinitpronomen (2026-10-10)
  'vierte': 'numerale', // Duden: Ordinalzahl (2026-10-10)
  'viertel': 'numerale', // Duden: Bruchzahl (2026-10-10)
  'vierzehnte': 'numerale', // Duden: Ordinalzahl (2026-10-10)
  'vierzigste': 'numerale', // Duden: Ordinalzahl (2026-10-10)
  'vorbehältlich': 'praeposition', // Duden: Präposition mit Genitiv (österr./schweiz.) (2026-10-10)
  'vorbehaltlich': 'praeposition', // Duden: Präposition mit Genitiv (2026-10-10)
  'wahrlich': 'adverb', // Duden: Adverb (2026-10-10)
  'wenig': 'numerale', // Duden: unbestimmtes Zahlwort/Indefinitpronomen (2026-10-10)
  'zehntausendste': 'numerale', // Ordinalzahl (2026-10-11)
  'zehnte': 'numerale', // Ordinalzahl (2026-10-11)
  'zehntel': 'numerale', // Bruchzahl (2026-10-11)
  'zwanzigste': 'numerale', // Ordinalzahl (2026-10-11)
  'zweihundertste': 'numerale', // Ordinalzahl (2026-10-11)
  'zweite': 'numerale', // Ordinalzahl (2026-10-11)
  'zweiundzwanzigste': 'numerale', // Ordinalzahl (2026-10-11)
  'zwölfte': 'numerale', // Ordinalzahl (2026-10-11)
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
      final eintrag = roh.trim();
      if (eintrag.isEmpty) continue;
      final w = listenLemma(eintrag);
      final art = wortartKorrektur[w] ?? wortart;
      if (File('assets/vocab/$art/${vokabId(art, w)}.json').existsSync()) {
        zeilen[i] = '✓ $eintrag';
        neu++;
      }
    }
    if (neu > 0) datei.writeAsStringSync(zeilen.join('\n'));
    stdout.writeln('$liste: $neu neu abgehakt');
  }
}

/// Lemma eines Listeneintrags: alles vor dem ersten Komma. Zwei Einträge der
/// Verbliste tragen Zusätze («anbacken, kleben» = Bedeutung, «sein, war,
/// gewesen» = Stammformen) — die Karte heißt nach dem Lemma (2026-10-11).
String listenLemma(String eintrag) => eintrag.split(',').first.trim();

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
      final w = listenLemma(roh.replaceFirst(RegExp(r'^\s*✓\s*'), '').trim());
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
