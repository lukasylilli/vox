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
  'zugewinnen', // zurückgestellt (Regel 14/16): selten (meist hinzugewinnen/dazugewinnen) 2026-10-13
  'zuhaben', // zurückgestellt (Regel 14/16): umgangssprachlich (wie aushaben, umhaben) 2026-10-13
  'zuhauen', // zurückgestellt (Regel 14/16): haute/hieb (wie aufhauen) 2026-10-13
  'zukneifen', // zurückgestellt (Regel 14/16): selten (wie auskneifen, einkneifen) 2026-10-13
  'zukriechen', // zurückgestellt (Regel 14/16): selten (wie ankriechen) 2026-10-13
  'zuladen', // zurückgestellt (Regel 14/16): selten/fachsprachlich (wie beiladen) 2026-10-13
  'zurechtbiegen', // zurückgestellt (Regel 14/16): selten (wie beibiegen, herumbiegen) 2026-10-13
  'zurechtbringen', // zurückgestellt (Regel 14/16): selten/veraltet 2026-10-13
  'zurückbegeben', // zurückgestellt (Regel 14/16): gehoben/selten (wie hinbegeben) 2026-10-13
  'zurückdürfen', // zurückgestellt (Regel 14/16): Modalverb-Verbindung 2026-10-13
  'zurückgießen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'zurückgleiten', // zurückgestellt (Regel 14/16): selten (wie hingleiten) 2026-10-13
  'zurückhaben', // zurückgestellt (Regel 14/16): umgangssprachlich (wie wiederhaben) 2026-10-13
  'zurückhauen', // zurückgestellt (Regel 14/16): haute/hieb (wie aufhauen) 2026-10-13
  'zurückkönnen', // zurückgestellt (Regel 14/16): Modalverb-Verbindung 2026-10-13
  'zurückmüssen', // zurückgestellt (Regel 14/16): Modalverb-Verbindung 2026-10-13
  'zusammenbiegen', // zurückgestellt (Regel 14/16): selten (wie herumbiegen) 2026-10-13
  'zusammenflechten', // zurückgestellt (Regel 14/16): selten (wie durchflechten, umflechten) 2026-10-13
  'zusammengeben', // zurückgestellt (Regel 14/16): selten/regional 2026-10-13
  'zusammengießen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'zusammenhaben', // zurückgestellt (Regel 14/16): umgangssprachlich (wie beisammenhaben) 2026-10-13
  'zusammenhängen', // zurückgestellt (Regel 14/16): hängen-Verbindung: hing (intransitiv) / hängte (transitiv) — wie die übrigen hängen-Verbindungen; häufig ⇒ Entscheidung Lukas 2026-10-13
  'zusammenhauen', // zurückgestellt (Regel 14/16): haute/hieb (wie aufhauen) 2026-10-13
  'zusammenklingen', // zurückgestellt (Regel 14/16): selten (wie mitklingen) 2026-10-13
  'zusammenkneifen', // zurückgestellt (Regel 14/16): selten (wie einkneifen) 2026-10-13
  'zusammenlassen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'zusammenlesen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'zusammenliegen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'zusammenlügen', // zurückgestellt (Regel 14/16): umgangssprachlich, selten 2026-10-13
  'zurückbiegen', // zurückgestellt (Regel 14/16): selten (wie herumbiegen) 2026-10-13
  'aasen', // zurückgestellt (Regel 14/16): landschaftlich/umgangssprachlich («mit etwas aasen») 2026-10-13
  'abhausen', // zurückgestellt (Regel 14/16): landschaftlich, selten 2026-10-13
  'abwägen', // zurückgestellt (Regel 14/16): wog/wägte ab (wie wägen); steht in der Liste der regelmäßigen Verben 2026-10-13
  'addizieren', // zurückgestellt (Regel 14/16): selten/fachsprachlich 2026-10-13
  'affirmieren', // zurückgestellt (Regel 14/16): gehoben/selten 2026-10-13
  'affizieren', // zurückgestellt (Regel 14/16): selten/fachsprachlich 2026-10-13
  'algorithmisieren', // zurückgestellt (Regel 14/16): fachsprachlich, selten 2026-10-13
  'alimentieren', // zurückgestellt (Regel 14/16): gehoben/selten 2026-10-13
  'allozieren', // zurückgestellt (Regel 14/16): fachsprachlich, selten 2026-10-13
  'älteln', // zurückgestellt (Regel 14/16): selten (älter wirken) 2026-10-13
  'alterieren', // zurückgestellt (Regel 14/16): veraltet («sich alterieren» = sich aufregen) 2026-10-13
  'altertümeln', // zurückgestellt (Regel 14/16): selten/gehoben 2026-10-13
  'altmachen', // zurückgestellt (Regel 14/16): Schreibung (alt machen) 2026-10-13
  'amalgamieren', // zurückgestellt (Regel 14/16): fachsprachlich, selten 2026-10-13
  'antichambrieren', // zurückgestellt (Regel 14/16): veraltet/gehoben 2026-10-13
  'apanagieren', // zurückgestellt (Regel 14/16): veraltet 2026-10-13
  'apern', // zurückgestellt (Regel 14/16): regional (schneefrei werden) 2026-10-13
  'äpfeln', // zurückgestellt (Regel 14/16): selten (vom Pferd: Kot absetzen) 2026-10-13
  'apostrophieren', // zurückgestellt (Regel 14/16): gehoben/selten 2026-10-13
  'approximieren', // zurückgestellt (Regel 14/16): fachsprachlich 2026-10-13
  'aptieren', // zurückgestellt (Regel 14/16): veraltet 2026-10-13
  'aquarellieren', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'äquilibrieren', // zurückgestellt (Regel 14/16): fachsprachlich/selten 2026-10-13
  'arabisieren', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'arbitrieren', // zurückgestellt (Regel 14/16): fachsprachlich 2026-10-13
  'archaisieren', // zurückgestellt (Regel 14/16): gehoben/selten 2026-10-13
  'arisieren', // zurückgestellt (Regel 14/16): historischer NS-Fachbegriff — Entscheidung Lukas 2026-10-13
  'arkadieren', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'armieren', // zurückgestellt (Regel 14/16): fachsprachlich (Bautechnik) 2026-10-13
  'armmachen', // zurückgestellt (Regel 14/16): Schreibung (arm machen) 2026-10-13
  'arretieren', // zurückgestellt (Regel 14/16): fachsprachlich/veraltet 2026-10-13
  'arrivieren', // zurückgestellt (Regel 14/16): gehoben/selten 2026-10-13
  'arrodieren', // zurückgestellt (Regel 14/16): fachsprachlich 2026-10-13
  'arrondieren', // zurückgestellt (Regel 14/16): fachsprachlich 2026-10-13
  'arsenieren', // zurückgestellt (Regel 14/16): fachsprachlich 2026-10-13
  'arten', // zurückgestellt (Regel 14/16): selten, Hilfsverb schwankt (ist geartet) 2026-10-13
  'äsen', // zurückgestellt (Regel 14/16): Jägersprache 2026-10-13
  'aspirieren', // zurückgestellt (Regel 14/16): fachsprachlich 2026-10-13
  'assekurieren', // zurückgestellt (Regel 14/16): veraltet 2026-10-13
  'assemblieren', // zurückgestellt (Regel 14/16): fachsprachlich 2026-10-13
  'asservieren', // zurückgestellt (Regel 14/16): fachsprachlich (Recht) 2026-10-13
  'asten', // zurückgestellt (Regel 14/16): regional/umgangssprachlich 2026-10-13
  'ästen', // zurückgestellt (Regel 14/16): fachsprachlich/selten 2026-10-13
  'ästhetisieren', // zurückgestellt (Regel 14/16): gehoben/selten 2026-10-13
  'äthern', // zurückgestellt (Regel 14/16): fachsprachlich/veraltet 2026-10-13
  'atomisieren', // zurückgestellt (Regel 14/16): fachsprachlich/gehoben 2026-10-13
  'atrophieren', // zurückgestellt (Regel 14/16): medizinischer Fachbegriff, selten als Verb 2026-10-13
  'attachieren', // zurückgestellt (Regel 14/16): veraltet 2026-10-13
  'attraktivieren', // zurückgestellt (Regel 14/16): selten/Modewort 2026-10-13
  'attribuieren', // zurückgestellt (Regel 14/16): fachsprachlich 2026-10-13
  'atzen', // zurückgestellt (Regel 14/16): Jägersprache/veraltet 2026-10-13
  'aufächzen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'appretieren', // zurückgestellt (Regel 14/16): fachsprachlich (Textil) 2026-10-13
  'äugeln', // zurückgestellt (Regel 14/16): veraltet 2026-10-13
  'äugen', // zurückgestellt (Regel 14/16): Jägersprache/gehoben 2026-10-13
  'ausixen', // zurückgestellt (Regel 14/16): umgangssprachlich, Schreibung schwankt 2026-10-13
  'ausmergeln', // zurückgestellt (Regel 14/16): fast nur im Partizip («ausgemergelt») 2026-10-13
  'auszementieren', // zurückgestellt (Regel 14/16): fachsprachlich 2026-10-13
  'auszieren', // zurückgestellt (Regel 14/16): veraltet 2026-10-13
  'auszirkeln', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'authentisieren', // zurückgestellt (Regel 14/16): fachsprachlich (meist authentifizieren) 2026-10-13
  'autographieren', // zurückgestellt (Regel 14/16): veraltet 2026-10-13
  'autoklavieren', // zurückgestellt (Regel 14/16): fachsprachlich 2026-10-13
  'autonomisieren', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'auxiliieren', // zurückgestellt (Regel 14/16): veraltet 2026-10-13
  'aversionieren', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'avertieren', // zurückgestellt (Regel 14/16): veraltet 2026-10-13
  'avisieren', // zurückgestellt (Regel 14/16): fachsprachlich/österreichisch, selten 2026-10-13
  'avivieren', // zurückgestellt (Regel 14/16): fachsprachlich 2026-10-13
  'avouieren', // zurückgestellt (Regel 14/16): veraltet 2026-10-13
  'axiomatisieren', // zurückgestellt (Regel 14/16): fachsprachlich 2026-10-13
  'azotieren', // zurückgestellt (Regel 14/16): fachsprachlich 2026-10-13
  'balbieren', // zurückgestellt (Regel 14/16): veraltet 2026-10-13
  'baldowern', // zurückgestellt (Regel 14/16): umgangssprachlich/selten (meist ausbaldowern) 2026-10-13
  'balsamieren', // zurückgestellt (Regel 14/16): fast nur «einbalsamieren» 2026-10-13
  'bändern', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'barbieren', // zurückgestellt (Regel 14/16): veraltet 2026-10-13
  'bäumen', // zurückgestellt (Regel 14/16): selten (meist sich aufbäumen) 2026-10-13
  'bauschen', // zurückgestellt (Regel 14/16): selten 2026-10-13
  'bechern', // zurückgestellt (Regel 14/16): umgangssprachlich (viel trinken) 2026-10-13
  'beckmessern', // zurückgestellt (Regel 14/16): gehoben/selten 2026-10-13
  'beeiden', // zurückgestellt (Regel 14/16): fachsprachlich (Recht) 2026-10-13
  'beeidigen', // zurückgestellt (Regel 14/16): fachsprachlich (Recht) 2026-10-13
  'befleißigen', // zurückgestellt (Regel 14/16): gehoben/veraltet 2026-10-13
  'befrachten', // zurückgestellt (Regel 14/16): fachsprachlich/selten 2026-10-13
  'befummeln', // zurückgestellt (Regel 14/16): umgangssprachlich, oft sexuell konnotiert — Entscheidung Lukas 2026-10-13
  'beglotzen', // zurückgestellt (Regel 14/16): umgangssprachlich/derb 2026-10-13
  'begnaden', // zurückgestellt (Regel 14/16): gehoben/veraltet (meist begnadet) 2026-10-13
  'bekiffen', // zurückgestellt (Regel 14/16): umgangssprachlich (Drogen), selten 2026-10-13
  'belämmern', // zurückgestellt (Regel 14/16): umgangssprachlich, selten; Bedeutung (belästigen/betrügen) nicht sicher 2026-10-14
  'benedeien', // zurückgestellt (Regel 14/16): veraltet/kirchlich; Partizip II schwankt (benedeit/gebenedeit) 2026-10-14
  'beschälen', // zurückgestellt (Regel 14/16): fachsprachlich (Pferdezucht), selten 2026-10-14
  'beschranken', // zurückgestellt (Regel 14/16): selten, meist nur Partizip (beschrankter Bahnübergang) 2026-10-14
  'bessemern', // zurückgestellt (Regel 14/16): fachsprachlich (Hüttenwesen, Bessemer-Verfahren) 2026-10-14
  'bestallen', // zurückgestellt (Regel 14/16): Amtssprache, veraltend, selten 2026-10-14
  'bestuhlen', // zurückgestellt (Regel 14/16): selten (fachsprachlich: Veranstaltungsraum mit Stühlen ausstatten) 2026-10-14
  'betatschen', // zurückgestellt (Regel 14/16): umgangssprachlich, oft sexuell konnotiert (wie befummeln) — Entscheidung Lukas 2026-10-14
  'betonnen', // zurückgestellt (Regel 14/16): fachsprachlich (Seefahrt: mit Tonnen markieren) 2026-10-14
  'beulen', // zurückgestellt (Regel 14/16): selten (sich beulen) 2026-10-14
  'beuteln', // zurückgestellt (Regel 14/16): umgangssprachlich/landschaftlich; Bedeutung nicht sicher 2026-10-14
  'bewandern', // zurückgestellt (Regel 14/16): als Verb kaum gebräuchlich (meist Adjektiv bewandert) 2026-10-14
  'bewegen', // zurückgestellt (Regel 14/16): zwei Konjugationen je nach Bedeutung (bewegte «in Bewegung setzen» ↔ bewog «veranlassen»), wie wenden — Entscheidung Lukas 2026-10-14
  'bimsen', // zurückgestellt (Regel 14/16): zwei Bedeutungen (mit Bimsstein glätten ↔ umgangssprachlich pauken); Bedeutung/Gebrauch nicht sicher 2026-10-15
  'bläuen', // zurückgestellt (Regel 14/16): selten; Verwechslung mit «bleuen» (schlagen) 2026-10-15
  'blessieren', // zurückgestellt (Regel 14/16): veraltet, sehr selten (verwunden) 2026-10-15
  'blinkern', // zurückgestellt (Regel 14/16): landschaftlich/selten 2026-10-15
  'bollern', // zurückgestellt (Regel 14/16): landschaftlich (poltern, dröhnen); Gebrauch nicht sicher 2026-10-15
  'bosseln', // zurückgestellt (Regel 14/16): umgangssprachlich/landschaftlich (basteln) und Spiel «Bosseln»; Bedeutung nicht eindeutig 2026-10-15
  'bummern', // zurückgestellt (Regel 14/16): landschaftlich (laut klopfen); selten 2026-10-15
  'bumsen', // zurückgestellt (Regel 14/16): umgangssprachlich/vulgär, sexuelle Bedeutung (wie befummeln) — Entscheidung Lukas 2026-10-15
  'chargieren', // zurückgestellt (Regel 14/16): mehrere fachsprachliche Bedeutungen (Theater: übertreiben; Militär; Hüttenwesen); Gebrauch nicht sicher 2026-10-15
  'deputieren', // zurückgestellt (Regel 14/16): selten (abordnen); Stilmarkierung (veraltet?) nicht sicher 2026-10-15
  'distinguieren', // zurückgestellt (Regel 14/16): heute fast nur Partizip «distinguiert» (eigene Adjektivkarte); Verb veraltet, Gebrauch nicht sicher 2026-10-15
  'doktern', // zurückgestellt (Regel 14/16): umgangssprachlich, meist «herumdoktern»; Bedeutung/Gebrauch nicht sicher 2026-10-15
  'downloaden', // zurückgestellt (Regel 3/16): Partizip II schwankt (downgeloadet/gedownloadet), trennbar nicht sicher ⇒ lieber kein Symbol als ein falsches 2026-10-15
  'dräuen', // zurückgestellt (Regel 14/16): dichterisch/veraltet (drohen); Gebrauch nicht sicher 2026-10-15
  'dröseln', // zurückgestellt (Regel 14/16): landschaftlich, meist «aufdröseln»; Bedeutung nicht sicher 2026-10-15
  'eifern', // zurückgestellt (Regel 14/16): gehoben, heute meist «nacheifern»/«ereifern»; Gebrauch/Stilmarkierung nicht sicher 2026-10-15
  'einverleiben', // zurückgestellt (Regel 3/16): Präteritum/Partizip schwanken (verleibte ein / einverleibte; einverleibt) ⇒ trennbar nicht sicher, lieber kein Symbol als ein falsches 2026-10-15
  'ejakulieren', // zurückgestellt: sexueller Bezug (wie masturbatorisch, promisk) — Entscheidung Lukas 2026-10-15
  'entblöden', // zurückgestellt (Regel 14/16): nur in der festen Wendung «sich nicht entblöden, … zu …» (gehoben/veraltend); Gebrauch nicht sicher 2026-10-15
  'entleiben', // zurückgestellt: «sich entleiben» = Selbsttötung (gehoben/veraltet), sensibles Thema — Entscheidung Lukas 2026-10-15
  'entpersönlichen', // zurückgestellt: selten, Gebrauch nicht sicher (Regel 14) 2026-10-15
  'entrinden', // zurückgestellt: Fachwort Forst, selten (Regel 14) 2026-10-15
  'entwanzen', // zurückgestellt: zwei seltene Bedeutungen (Ungeziefer / Abhörgeräte), Gebrauch nicht sicher (Regel 14) 2026-10-15
  'erbittern', // zurückgestellt: selten, heute meist Partizip «erbittert» bzw. «verbittern»; Gebrauch nicht sicher (Regel 14) 2026-10-15
  'erfrechen', // zurückgestellt: «sich erfrechen» veraltend/selten; Stilmarkierung nicht sicher (Regel 14/17) 2026-10-15
  'erigieren', // zurückgestellt: sexueller Bezug (wie ejakulieren) — Entscheidung Lukas 2026-10-15
  'erkühnen', // zurückgestellt: «sich erkühnen» gehoben/selten; Stilmarkierung nicht sicher (Regel 14/17) 2026-10-15
  'erotisieren', // zurückgestellt: sexueller Bezug — Entscheidung Lukas 2026-10-15
  'ertauben', // zurückgestellt: selten/fachsprachlich (taub werden); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'ertüchtigen', // zurückgestellt: selten/gehoben; Gebrauch nicht sicher (Regel 14) 2026-10-15
  'eskamotieren', // zurückgestellt: sehr selten (wegzaubern); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'evangelisieren', // zurückgestellt: selten (missionieren); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'exmittieren', // zurückgestellt: Amtssprache, selten (Zwangsräumung); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'extemporieren', // zurückgestellt: sehr selten (improvisieren); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'fächern', // zurückgestellt: selten (meist «auffächern»); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'fälteln', // zurückgestellt: Fachwort Schneiderei, selten (Regel 14) 2026-10-15
  'falzen', // zurückgestellt: Fachwort (Buchbinderei/Blech) mit mehreren Bedeutungen; nicht sicher (Regel 14) 2026-10-15
  'ferkeln', // zurückgestellt: selten, zwei verschiedene Bedeutungen (Ferkel werfen / sich unanständig benehmen); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'feudeln', // zurückgestellt: regional (norddeutsch: feucht wischen), selten (Regel 14) 2026-10-15
  'fiedern', // zurückgestellt: selten (mit Federn versehen; Botanik: gefiedert); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'fingern', // zurückgestellt: umgangssprachlich mit mehreren Bedeutungen (herumfingern / etwas geschickt erledigen); nicht sicher (Regel 14) 2026-10-15
  'fixen', // zurückgestellt: Jargon (Drogen spritzen / Börse); Gebrauch und Register nicht sicher (Regel 14/17) 2026-10-15
  'flammen', // zurückgestellt: gehoben/selten (meist aufflammen, entflammen); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'fläzen', // zurückgestellt: umgangssprachlich, abwertend («sich fläzen»); Stilmarkierung nicht sicher (Regel 14/17) 2026-10-15
  'fleddern', // zurückgestellt: selten (Leichen ausplündern); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'flennen', // zurückgestellt: umgangssprachlich abwertend (weinen); anstoessig-Stufe nicht sicher (Regel 17) 2026-10-15
  'flirren', // zurückgestellt: gehoben/selten (flimmern, schwirren); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'fraktionieren', // zurückgestellt: Fachwort (Chemie: destillieren; Medizin: Bestrahlung aufteilen), mehrere Bedeutungen; nicht sicher (Regel 14) 2026-10-15
  'freveln', // zurückgestellt: gehoben/veraltend (Unrecht tun); Stilmarkierung nicht sicher (Regel 14/17) 2026-10-15
  'frikassieren', // zurückgestellt: selten, zwei Bedeutungen (Frikassee machen / umgangssprachlich verprügeln); nicht sicher (Regel 14) 2026-10-15
  'frömmeln', // zurückgestellt: abwertend, selten (übertriebene Frömmigkeit zeigen); Stilmarkierung nicht sicher (Regel 14/17) 2026-10-15
  'frommen', // zurückgestellt: veraltet (nützen); zeitlich/ersatz nicht sicher (Regel 17) 2026-10-15
  'fummeln', // zurückgestellt: umgangssprachlich; eine Bedeutung mit sexuellem Bezug (wie befummeln) — Entscheidung Lukas 2026-10-15
  'furzen', // zurückgestellt: derb/vulgär — Entscheidung Lukas (Regel 17) 2026-10-15
  'füßeln', // zurückgestellt: umgangssprachlich (unter dem Tisch mit den Füßen berühren, oft flirtend); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'gasen', // zurückgestellt: mehrere Bedeutungen (Gas geben, Gas ausströmen; Nähe zu «vergasen»); nicht sicher (Regel 14) 2026-10-15
  'gaukeln', // zurückgestellt: gehoben/selten (flatternd schweben; vorgaukeln); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'gebaren', // zurückgestellt: veraltend/selten («sich gebaren»); Stilmarkierung nicht sicher (Regel 17) 2026-10-15
  'gedeihen', // zurückgestellt: in der regelmäßigen Liste, aber unregelmäßig (gedieh, gediehen); keine Grundkarte für die Formen — nicht sicher (Regel 14) 2026-10-15
  'geifern', // zurückgestellt: gehoben/abwertend (geifern gegen); Stilmarkierung nicht sicher (Regel 17) 2026-10-15
  'gelüsten', // zurückgestellt: gehoben, unpersönlich («es gelüstet mich nach»); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'gerieren', // zurückgestellt: bildungssprachlich, selten («sich gerieren als»); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'gieren', // zurückgestellt: gehoben/abwertend («nach etwas gieren»); Stilmarkierung nicht sicher (Regel 17) 2026-10-15
  'girren', // zurückgestellt: selten/gehoben (Tauben: gurren); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'gleißen', // zurückgestellt: gehoben/selten (grell glänzen; Präteritum gleißte/gliss schwankend); nicht sicher (Regel 14) 2026-10-15
  'grabbeln', // zurückgestellt: regional (norddeutsch: herumtasten), selten (Regel 14) 2026-10-15
  'grämen', // zurückgestellt: gehoben («sich grämen»); Stilmarkierung nicht sicher (Regel 17) 2026-10-15
  'granteln', // zurückgestellt: regional (bairisch/österreichisch umgangssprachlich: schlecht gelaunt sein); nicht sicher (Regel 14) 2026-10-15
  'grapschen', // zurückgestellt: umgangssprachlich; eine Bedeutung mit sexuellem Bezug (begrapschen) — Entscheidung Lukas 2026-10-15
  'grausen', // zurückgestellt: unpersönlich/reflexiv («es graust mir», «sich grausen»), Kasus schwankend; nicht sicher (Regel 14) 2026-10-15
  'greinen', // zurückgestellt: umgangssprachlich abwertend (weinerlich klagen); Stilmarkierung nicht sicher (Regel 17) 2026-10-15
  'grienen', // zurückgestellt: regional (norddeutsch: grinsen), selten (Regel 14) 2026-10-15
  'grummeln', // zurückgestellt: umgangssprachlich mit mehreren Bedeutungen (murren, Magen, Donner); nicht sicher (Regel 14) 2026-10-15
  'gründeln', // zurückgestellt: Fachwort Zoologie (Enten, Fische: am Grund nach Nahrung suchen), selten (Regel 14) 2026-10-15
  'guillotinieren', // zurückgestellt: historisch/selten (mit der Guillotine hinrichten); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'gustieren', // zurückgestellt: regional (österreichisch: kosten, probieren); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'hakeln', // zurückgestellt: regional (bairisch/österreichisch: Fingerhakeln; Sport: Gegner mit dem Fuß zu Fall bringen), mehrere Bedeutungen; nicht sicher (Regel 14) 2026-10-15
  'hampeln', // zurückgestellt: umgangssprachlich (zappeln; meist «herumhampeln»); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'hängen', // zurückgestellt: zwei Konjugationen je nach Bedeutung (hing/gehangen ↔ hängte/gehängt) — wie die anderen hängen-Verben zurückgestellt; Entscheidung Lukas 2026-10-15
  'härmen', // zurückgestellt: gehoben/veraltend («sich härmen»); Stilmarkierung nicht sicher (Regel 17) 2026-10-15
  'harren', // zurückgestellt: gehoben/veraltend (warten, «einer Sache harren»); Stilmarkierung nicht sicher (Regel 17) 2026-10-15
  'haschen', // zurückgestellt: mehrere Bedeutungen (nach etwas greifen / umgangssprachlich Haschisch rauchen); nicht sicher (Regel 14) 2026-10-15
  'haspeln', // zurückgestellt: mehrere Bedeutungen (Garn aufwickeln / hastig sprechen), selten (Regel 14) 2026-10-15
  'häufeln', // zurückgestellt: Fachwort Gartenbau (Erde anhäufeln), selten (Regel 14) 2026-10-15
  'hehlen', // zurückgestellt: veraltend/selten (Diebesgut verbergen; heute «Hehlerei»); Gebrauch nicht sicher (Regel 14/17) 2026-10-15
  'heuen', // zurückgestellt: regional (süddeutsch/österreichisch: Heu machen), selten (Regel 14) 2026-10-15
  'heuern', // zurückgestellt: Seemannssprache, selten (meist «anheuern»); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'historisieren', // zurückgestellt: bildungssprachlich, selten; Bedeutung nicht sicher (Regel 14) 2026-10-15
  'höhnen', // zurückgestellt: gehoben, selten (verhöhnen); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'hökern', // zurückgestellt: veraltend/regional (Kleinhandel treiben), selten (Regel 14/17) 2026-10-15
  'huren', // zurückgestellt: vulgär/veraltet (Prostitution, Geschlechtsverkehr) — Entscheidung Lukas (Regel 17) 2026-10-15
  'hutzeln', // zurückgestellt: regional/selten (Obst dörren, schrumpfen); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'hygienisieren', // zurückgestellt: sehr selten, Fachjargon; Gebrauch nicht sicher (Regel 14) 2026-10-15
  'indignieren', // zurückgestellt: bildungssprachlich, selten (meist Partizip «indigniert»); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'indossieren', // zurückgestellt: Fachwort Bankwesen (Wechsel übertragen), selten (Regel 14) 2026-10-15
  'inkommodieren', // zurückgestellt: veraltet/bildungssprachlich (belästigen); zeitlich/ersatz nicht sicher (Regel 17) 2026-10-15
  'innovieren', // zurückgestellt: sehr selten, Fachjargon; Gebrauch nicht sicher (Regel 14) 2026-10-15
  'insultieren', // zurückgestellt: bildungssprachlich/veraltet, österreichisch auch «beleidigen»; Stilmarkierung nicht sicher (Regel 17) 2026-10-15
  'judizieren', // zurückgestellt: veraltet (urteilen, richten); zeitlich/ersatz nicht sicher (Regel 17) 2026-10-15
  'kacken', // zurückgestellt: derb/vulgär (Kot ausscheiden) — Entscheidung Lukas (Regel 17) 2026-10-15
  'kannelieren', // zurückgestellt: Fachwort Architektur (Säulen mit Rillen versehen), sehr selten (Regel 14) 2026-10-15
  'karessieren', // zurückgestellt: veraltet (liebkosen, schmeicheln); zeitlich/ersatz nicht sicher (Regel 17) 2026-10-15
  'ketzern', // zurückgestellt: selten/veraltet, Gebrauch und Bedeutung nicht sicher (Regel 14) 2026-10-15
  'klamüsern', // zurückgestellt: regional/umgangssprachlich (meist «auseinanderklamüsern»); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'klimmen', // zurückgestellt: Doppelformen (klomm/geklommen und klimmte/geklimmt) — regelmäßig/unregelmäßig nicht eindeutig (Regel 16) 2026-10-15
  'klittern', // zurückgestellt: selten, meist «zusammenklittern»; Gebrauch nicht sicher (Regel 14) 2026-10-15
  'knäueln', // zurückgestellt: sehr selten (meist «sich knäueln»/«zusammenknäueln»); Gebrauch nicht sicher (Regel 14) 2026-10-15
  'kohlen', // zurückgestellt: zwei Bedeutungen (verkohlen/schwelen; ugs. flunkern) — Hauptbedeutung nicht sicher (Regel 14) 2026-10-15
  'koksen', // zurückgestellt: mehrere Bedeutungen (Koks herstellen; ugs. Kokain nehmen; ugs. schlafen) — nicht sicher (Regel 14) 2026-10-15
  'kollern', // zurückgestellt: zwei Bedeutungen/Hilfsverben (kullern = sein; Truthahn-Laut = haben) — nicht sicher (Regel 14) 2026-10-15
  'kontakten', // zurückgestellt: Fachjargon Werbung/Vertrieb, selten; Gebrauch nicht sicher (Regel 14) 2026-10-15
  'kontrahieren', // zurückgestellt: mehrere Fachbedeutungen (Medizin: sich zusammenziehen; Recht: Vertrag schließen; Fechten) — nicht sicher (Regel 14) 2026-10-15
  'kopulieren', // zurückgestellt: sexueller Bezug (Biologie: sich paaren) — sensibel, Entscheidung Lukas (wie ejakulieren) 2026-10-16
  'kosen', // zurückgestellt: gehoben/veraltend (liebkosen); zeitlich/ersatz nicht sicher (Regel 17) 2026-10-16
  'kotzen', // zurückgestellt: derb/vulgär (sich übergeben) — Entscheidung Lukas (wie kacken), Regel 17 2026-10-16
  'krampfen', // zurückgestellt: selten (meist «sich verkrampfen»/«sich krampfen um»); Gebrauch nicht sicher (Regel 14) 2026-10-16
  'kränzen', // zurückgestellt: veraltet/gehoben (bekränzen); zeitlich/ersatz nicht sicher (Regel 17) 2026-10-16
  'kreditieren', // zurückgestellt: Fachwort Buchhaltung (gutschreiben), selten; Gebrauch nicht sicher (Regel 14) 2026-10-16
  'kreißen', // zurückgestellt: veraltet (in den Wehen liegen); zeitlich/ersatz nicht sicher (Regel 17) 2026-10-16
  'krepieren', // zurückgestellt: salopp/derb (sterben; Granate explodieren) — Einordnung anstoessig nicht sicher, Entscheidung Lukas 2026-10-16
  'krickeln', // zurückgestellt: regional/umgangssprachlich, selten; Gebrauch nicht sicher (Regel 14) 2026-10-16
  'kujonieren', // zurückgestellt: veraltend (schikanieren); zeitlich/ersatz nicht sicher (Regel 17) 2026-10-16
  'kümmeln', // zurückgestellt: umgangssprachlich (Alkohol trinken) und Küche (mit Kümmel würzen) — Bedeutung nicht sicher (Regel 14) 2026-10-16
  'kupieren', // zurückgestellt: mehrere Fachbedeutungen (Schwanz/Ohren kürzen; Medizin: Anfall unterdrücken; Karten abheben) — nicht sicher (Regel 14) 2026-10-16
  'laugen', // zurückgestellt: Fachwort (mit Lauge behandeln), selten; Gebrauch nicht sicher (Regel 14) 2026-10-16
  'lecken', // zurückgestellt: Homograph (lecken = mit der Zunge; lecken = undicht sein) mit gleicher id — wie der See/die See, Entscheidung Lukas 2026-10-16
  'lithographieren', // zurückgestellt: ältere Schreibung (heute lithografieren), Fachwort Druck — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'löcken', // zurückgestellt: nur in der Wendung «wider den Stachel löcken», veraltet — zeitlich/ersatz nicht sicher (Regel 17) 2026-10-16
  'luchsen', // zurückgestellt: umgangssprachlich/regional, selten (meist «abluchsen») — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'lullen', // zurückgestellt: selten, meist «einlullen» — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'mäandern', // zurückgestellt: Hilfsverb schwankt (hat/ist gemäandert) — nicht eindeutig (Regel 16) 2026-10-16
  'mahlen', // zurückgestellt: gemischt: mahlte, aber Partizip II gemahlen — wie ausmahlen/vermahlen (Regel 16) 2026-10-16
  'majorisieren', // zurückgestellt: Fachwort, selten — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'malmen', // zurückgestellt: veraltet/gehoben (meist «zermalmen») — zeitlich nicht sicher (Regel 17) 2026-10-16
  'marodieren', // zurückgestellt: selten, meist als Partizip «marodierend» — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'masturbieren', // zurückgestellt: sexuelle Bedeutung — Entscheidung Lukas (wie ejakulieren, erigieren) 2026-10-16
  'maunzen', // zurückgestellt: regional/umgangssprachlich (Katze), selten — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'mauscheln', // zurückgestellt: umgangssprachlich abwertend, Herkunft antisemitisch («Mauschel») — anstoessig-Stufe nicht sicher, Entscheidung Lukas 2026-10-16
  'mausen', // zurückgestellt: umgangssprachlich/veraltend (stehlen; Mäuse fangen) — zeitlich nicht sicher (Regel 17) 2026-10-16
  'melieren', // zurückgestellt: selten, meist Adjektiv «meliert» — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'mendeln', // zurückgestellt: Fachwort Biologie, selten — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'mengen', // zurückgestellt: veraltend/landschaftlich (mischen) — zeitlich nicht sicher (Regel 17) 2026-10-16
  'menscheln', // zurückgestellt: umgangssprachlich, meist unpersönlich («es menschelt») — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'metzeln', // zurückgestellt: veraltet/regional (meist «niedermetzeln») — zeitlich nicht sicher (Regel 17) 2026-10-16
  'miefen', // zurückgestellt: umgangssprachlich, selten — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'möchten', // zurückgestellt: kein eigener Infinitiv (Konjunktiv-II-Form von mögen; Karte mögen vorhanden) — Listenfehler, Entscheidung Lukas 2026-10-16
  'modeln', // zurückgestellt: selten, zwei Bedeutungen (formen; als Model arbeiten) — nicht sicher (Regel 14) 2026-10-16
  'modern', // zurückgestellt: Hilfsverb schwankt (hat/ist gemodert) und Homograph mit Adjektiv modern — nicht eindeutig (Regel 16) 2026-10-16
  'moppen', // zurückgestellt: umgangssprachlich, selten (mit dem Mopp wischen) — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'mopsen', // zurückgestellt: umgangssprachlich (stehlen; sich langweilen) — Bedeutung/zeitlich nicht sicher (Regel 14/17) 2026-10-16
  'mucksen', // zurückgestellt: meist reflexiv und verneint («sich nicht mucksen»), umgangssprachlich — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'muffeln', // zurückgestellt: zwei Bedeutungen (muffig riechen; mürrisch sein), regional — nicht sicher (Regel 14) 2026-10-16
  'müffeln', // zurückgestellt: regional/umgangssprachlich (muffig riechen) — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'mummeln', // zurückgestellt: regional, mehrere Bedeutungen (murmeln; einhüllen) — nicht sicher (Regel 14) 2026-10-16
  'mümmeln', // zurückgestellt: umgangssprachlich (wie ein Hase kauen), selten — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'münden', // zurückgestellt: Hilfsverb schwankt (hat/ist gemündet) — nicht eindeutig (Regel 16) 2026-10-16
  'münzen', // zurückgestellt: meist nur «auf jemanden gemünzt sein»; Grundbedeutung (Münzen prägen) selten — nicht sicher (Regel 14) 2026-10-16
  'nachdunkeln', // zurückgestellt: trennbar, Hilfsverb schwankt (ist/hat nachgedunkelt) — nicht eindeutig (Regel 16) 2026-10-16
  'narren', // zurückgestellt: veraltend (zum Narren halten) — zeitlich/ersatz nicht sicher (Regel 17) 2026-10-16
  'nesteln', // zurückgestellt: selten (an etwas herumfingern) — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'neuern', // zurückgestellt: selten/veraltet (erneuern) — zeitlich nicht sicher (Regel 17) 2026-10-16
  'nölen', // zurückgestellt: norddeutsch umgangssprachlich (nörgeln, trödeln) — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'obstruieren', // zurückgestellt: Fachwort (Medizin/Politik), selten — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'onanieren', // zurückgestellt: sexuelle Bedeutung — Entscheidung Lukas (wie masturbieren) 2026-10-16
  'ontologisieren', // zurückgestellt: Fachwort Philosophie, sehr selten — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'optieren', // zurückgestellt: Fachwort (Staatsangehörigkeit/Recht wählen), selten — nicht sicher (Regel 14) 2026-10-16
  'orakeln', // zurückgestellt: umgangssprachlich, selten (dunkle Andeutungen machen) — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'ordinieren', // zurückgestellt: zwei Fachbedeutungen (Kirche: weihen; österr. Arzt: Sprechstunde halten) — nicht sicher (Regel 14) 2026-10-16
  'orgeln', // zurückgestellt: umgangssprachlich/selten (Orgel spielen; röhren) — nicht sicher (Regel 14) 2026-10-16
  'oxidieren', // zurückgestellt: Hilfsverb schwankt (hat/ist oxidiert) — nicht eindeutig (Regel 16) 2026-10-16
  'oxydieren', // zurückgestellt: ältere Schreibung von oxidieren, Hilfsverb schwankt — nicht eindeutig (Regel 16) 2026-10-16
  'paffen', // zurückgestellt: umgangssprachlich (rauchen ohne zu inhalieren) — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'paneelieren', // zurückgestellt: Fachwort, sehr selten — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'päppeln', // zurückgestellt: meist «aufpäppeln», regional — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'paradieren', // zurückgestellt: gehoben/selten (in einer Parade vorbeiziehen; prunken) — nicht sicher (Regel 14) 2026-10-16
  'paraphieren', // zurückgestellt: Fachwort Diplomatie (Vertrag vorläufig zeichnen) — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'parkettieren', // zurückgestellt: Fachwort Handwerk, selten — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'parkieren', // zurückgestellt: schweizerisch für parken — regionale Markierung nicht sicher (Regel 14) 2026-10-16
  'parlieren', // zurückgestellt: gehoben/veraltend (leicht plaudern, v. a. in Fremdsprache) — zeitlich nicht sicher (Regel 17) 2026-10-16
  'passivieren', // zurückgestellt: Fachwort (Buchhaltung, Grammatik), selten — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'patrouillieren', // zurückgestellt: Hilfsverb schwankt (hat/ist patrouilliert) — nicht eindeutig (Regel 16) 2026-10-16
  'patschen', // zurückgestellt: umgangssprachlich, Hilfsverb schwankt (hat/ist gepatscht) — nicht eindeutig (Regel 16) 2026-10-16
  'penetrieren', // zurückgestellt: Fachwort mit auch sexueller Bedeutung — Entscheidung Lukas 2026-10-16
  'perlen', // zurückgestellt: Hilfsverb schwankt (hat/ist geperlt) — nicht eindeutig (Regel 16) 2026-10-16
  'permutieren', // zurückgestellt: Fachwort Mathematik, selten — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'pervertieren', // zurückgestellt: Hilfsverb schwankt (transitiv hat / intransitiv ist pervertiert) — nicht eindeutig (Regel 16) 2026-10-16
  'pferchen', // zurückgestellt: selten, meist «zusammenpferchen» — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'pfriemeln', // zurückgestellt: regional/umgangssprachlich, selten — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'photographieren', // zurückgestellt: ältere Schreibung (heute fotografieren) — wie lithographieren (Regel 14) 2026-10-16
  'phrasieren', // zurückgestellt: Fachwort Musik, selten — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'picheln', // zurückgestellt: umgangssprachlich/regional (trinken), selten — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'pikieren', // zurückgestellt: Fachwort Gärtnerei; sonst nur Partizip «pikiert» — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'pilotieren', // zurückgestellt: Fachwort (steuern; Pilotprojekt), selten — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'pimpern', // zurückgestellt: vulgär, sexuelle Bedeutung — Entscheidung Lukas (wie die übrigen vulgären Wörter) 2026-10-16
  'pirschen', // zurückgestellt: Hilfsverb schwankt (hat/ist gepirscht), Jägersprache — nicht eindeutig (Regel 16) 2026-10-16
  'pissen', // zurückgestellt: vulgär — Entscheidung Lukas (wie die übrigen vulgären Wörter) 2026-10-16
  'placken', // zurückgestellt: nur reflexiv «sich placken», umgangssprachlich — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'pladdern', // zurückgestellt: norddeutsch umgangssprachlich (Regen) — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'plänkeln', // zurückgestellt: selten (veraltet: Gefecht; heute «Geplänkel») — zeitlich nicht sicher (Regel 17) 2026-10-16
  'platschen', // zurückgestellt: umgangssprachlich, Hilfsverb schwankt — nicht eindeutig (Regel 16) 2026-10-16
  'plätschern', // zurückgestellt: Hilfsverb schwankt (hat/ist geplätschert) — nicht eindeutig (Regel 16) 2026-10-16
  'plattieren', // zurückgestellt: Fachwort Technik, selten — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'plumpsen', // zurückgestellt: umgangssprachlich, Hilfsverb schwankt — nicht eindeutig (Regel 16) 2026-10-16
  'pointieren', // zurückgestellt: selten, meist Partizip «pointiert» — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'poltern', // zurückgestellt: Hilfsverb schwankt (hat/ist gepoltert) — nicht eindeutig (Regel 16) 2026-10-16
  'polymerisieren', // zurückgestellt: Fachwort Chemie, Hilfsverb schwankt — nicht sicher (Regel 14/16) 2026-10-16
  'pomadisieren', // zurückgestellt: veraltet/selten — zeitlich nicht sicher (Regel 17) 2026-10-16
  'poussieren', // zurückgestellt: veraltet (flirten; schmeicheln) — zeitlich/ersatz nicht sicher (Regel 17) 2026-10-16
  'prangen', // zurückgestellt: gehoben/selten (prächtig zu sehen sein) — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'prasseln', // zurückgestellt: Hilfsverb schwankt (hat/ist geprasselt) — nicht eindeutig (Regel 16) 2026-10-16
  'pressieren', // zurückgestellt: süddeutsch/österreichisch/schweizerisch (eilig sein) — regionale Markierung nicht sicher (Regel 14) 2026-10-16
  'profanieren', // zurückgestellt: Fachwort (Kirche entweihen), selten — Gebrauch nicht sicher (Regel 14) 2026-10-16
  'promenieren', // zurückgestellt: veraltend/gehoben (spazieren), Hilfsverb schwankt — nicht sicher (Regel 16/17) 2026-10-16
  'prostituieren', // zurückgestellt: sexuelle Bedeutung — Entscheidung Lukas 2026-10-16
  'pulsen', // zurückgestellt: Bedeutung unsicher (pulsieren / Puls messen?) — nicht sicher (Regel 14) 2026-10-18
  'pulvern', // zurückgestellt: umgangssprachlich, mehrere unsichere Bedeutungen (schießen / Geld hineinstecken?) — nicht sicher (Regel 14) 2026-10-18
  'pupen', // zurückgestellt: derb/Kindersprache (Darmwind) — Entscheidung Lukas (wie furzen) 2026-10-18
  'pupsen', // zurückgestellt: derb/Kindersprache (Darmwind) — Entscheidung Lukas (wie furzen) 2026-10-18
  'quartieren', // zurückgestellt: meist nur «einquartieren»; einfaches Verb kaum gebräuchlich — nicht sicher 2026-10-18
  'querulieren', // zurückgestellt: selten, Gebrauch unsicher — nicht sicher 2026-10-18
  'quotieren', // zurückgestellt: Fachsprache (Börse/Quote), Bedeutung uneinheitlich — nicht sicher 2026-10-18
  'rabattieren', // zurückgestellt: selten (Kaufmannssprache), Gebrauch unsicher — nicht sicher 2026-10-18
  'rädern', // zurückgestellt: historische Hinrichtungsart; heute v. a. «gerädert sein» — nicht sicher, wie die Karte aussehen soll 2026-10-18
  'rammeln', // zurückgestellt: derb/sexuelle Bedeutung — Entscheidung Lukas 2026-10-18
  'rappeln', // zurückgestellt: umgangssprachlich/landschaftlich, mehrere unsichere Bedeutungen — nicht sicher 2026-10-18
  'räsonieren', // zurückgestellt: veraltend/gehoben, Bedeutung schwankt (vernünfteln / nörgeln) — nicht sicher (Regel 17) 2026-10-18
  'rastern', // zurückgestellt: Fachsprache (Druck/Bildverarbeitung) — nicht sicher 2026-10-18
  'referenzieren', // zurückgestellt: Fachsprache (IT/Wissenschaft), Gebrauch unsicher — nicht sicher 2026-10-18
  'reffen', // zurückgestellt: Seemannssprache (Segel verkleinern) — nicht sicher 2026-10-18
  'reihern', // zurückgestellt: salopp/derb (sich übergeben) — Entscheidung Lukas 2026-10-18
  'rekognoszieren', // zurückgestellt: veraltet/Militär- und Amtssprache, Bedeutung schwankt — nicht sicher (Regel 17) 2026-10-18
  'rekonvaleszieren', // zurückgestellt: selten (Medizin), Gebrauch unsicher — nicht sicher 2026-10-18
  'relationieren', // zurückgestellt: Fachsprache, Bedeutung unsicher — nicht sicher 2026-10-18
  'relokalisieren', // zurückgestellt: selten/Fachsprache — nicht sicher (Regel 14) 2026-10-18
  'renegieren', // zurückgestellt: selten, Bedeutung unsicher — nicht sicher (Regel 14) 2026-10-18
  'renitieren', // zurückgestellt: veraltet, Bedeutung unsicher — nicht sicher (Regel 14) 2026-10-18
  'renommieren', // zurückgestellt: veraltend (prahlen); heute fast nur «renommiert» — nicht sicher (Regel 14) 2026-10-18
  'renoncieren', // zurückgestellt: veraltet/Kartenspiel — nicht sicher (Regel 14) 2026-10-18
  'replizieren', // zurückgestellt: Fachsprache (Wissenschaft/Recht/IT) — nicht sicher (Regel 14) 2026-10-18
  'requirieren', // zurückgestellt: Militär-/Amtssprache — nicht sicher (Regel 14) 2026-10-18
  'restituieren', // zurückgestellt: Rechtssprache, selten — nicht sicher (Regel 14) 2026-10-18
  'retardieren', // zurückgestellt: Fachsprache (Medizin/Literatur) — nicht sicher (Regel 14) 2026-10-18
  'retirieren', // zurückgestellt: veraltet — nicht sicher (Regel 14) 2026-10-18
  'reüssieren', // zurückgestellt: gehoben/selten — nicht sicher (Regel 14) 2026-10-18
  'reversieren', // zurückgestellt: österr. Fachsprache (Verkehr), Bedeutung uneinheitlich — nicht sicher (Regel 14) 2026-10-18
  'revieren', // zurückgestellt: Jägersprache — nicht sicher (Regel 14) 2026-10-18
  'rezipieren', // zurückgestellt: Fachsprache — nicht sicher (Regel 14) 2026-10-18
  'riegeln', // zurückgestellt: selten, meist «abriegeln/verriegeln» — nicht sicher (Regel 14) 2026-10-18
  'rieseln', // zurückgestellt: Hilfsverb schwankt (haben/sein) — nicht sicher (Regel 16), wie prasseln 2026-10-18
  'ritualisieren', // zurückgestellt: Fachsprache — nicht sicher (Regel 14) 2026-10-18
  'rochieren', // zurückgestellt: Schachsprache — nicht sicher (Regel 14) 2026-10-18
  'rotten', // zurückgestellt: meist nur «sich zusammenrotten» — nicht sicher (Regel 14) 2026-10-18
  'rotzen', // zurückgestellt: derb — Entscheidung Lukas 2026-10-18
  'rubrizieren', // zurückgestellt: Fachsprache, selten — nicht sicher (Regel 14) 2026-10-18
  'rucken', // zurückgestellt: selten, Bedeutung unsicher — nicht sicher (Regel 14) 2026-10-18
  'rückkoppeln', // zurückgestellt: Fachsprache (Technik) — nicht sicher (Regel 14) 2026-10-18
  'rumpeln', // zurückgestellt: Hilfsverb schwankt (haben/sein) — nicht sicher (Regel 16) 2026-10-18
  'rußen', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-18
  'sabbeln', // zurückgestellt: norddeutsch umgangssprachlich — nicht sicher (Regel 14) 2026-10-18
  'sächseln', // zurückgestellt: regional/umgangssprachlich — nicht sicher (Regel 14) 2026-10-18
  'sacken', // zurückgestellt: Hilfsverb/Bedeutung schwanken — nicht sicher (Regel 14) 2026-10-18
  'säkularisieren', // zurückgestellt: Fachsprache — nicht sicher (Regel 14) 2026-10-18
  'salben', // zurückgestellt: gehoben/religiös, selten — nicht sicher (Regel 14) 2026-10-18
  'salzen', // zurückgestellt: gemischte Formen (gesalzen/gesalzt) — nicht sicher, ob regelmäßig (Regel 17) 2026-10-18
  'saturieren', // zurückgestellt: gehoben/Fachsprache — nicht sicher (Regel 14) 2026-10-18
  'säuern', // zurückgestellt: Fachsprache (Küche/Chemie) — nicht sicher (Regel 14) 2026-10-18
  'säumen', // zurückgestellt: gehoben, mehrere Bedeutungen — nicht sicher (Regel 14) 2026-10-18
  'säuseln', // zurückgestellt: gehoben, selten — nicht sicher (Regel 14) 2026-10-18
  'schachern', // zurückgestellt: abwertend/umgangssprachlich — nicht sicher (Regel 14) 2026-10-18
  'schäkern', // zurückgestellt: veraltend — nicht sicher (Regel 14) 2026-10-18
  'scharen', // zurückgestellt: meist nur «sich scharen um» — nicht sicher (Regel 14) 2026-10-18
  'scharwenzeln', // zurückgestellt: umgangssprachlich, selten — nicht sicher (Regel 14) 2026-10-18
  'schattieren', // zurückgestellt: Fachsprache (Kunst) — nicht sicher (Regel 14) 2026-10-18
  'schaudern', // zurückgestellt: meist unpersönlich, Gebrauch schwankt — nicht sicher (Regel 14) 2026-10-18
  'schauern', // zurückgestellt: mehrere Bedeutungen (Regen/Schauder) — nicht sicher (Regel 14) 2026-10-18
  'schellen', // zurückgestellt: regional (läuten) — nicht sicher (Regel 14) 2026-10-18
  'schematisieren', // zurückgestellt: Fachsprache — nicht sicher (Regel 14) 2026-10-18
  'schillern', // zurückgestellt: gehoben, selten — nicht sicher (Regel 14) 2026-10-18
  'schippern', // zurückgestellt: umgangssprachlich, Hilfsverb schwankt — nicht sicher (Regel 14) 2026-10-18
  'schirmen', // zurückgestellt: gehoben, meist «abschirmen» — nicht sicher (Regel 14) 2026-10-18
  'schlabbern', // zurückgestellt: umgangssprachlich, mehrere Bedeutungen — nicht sicher (Regel 14) 2026-10-18
  'schlauchen', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-18
  'schleckern', // zurückgestellt: landschaftlich — nicht sicher (Regel 14) 2026-10-18
  'schlingern', // zurückgestellt: Hilfsverb schwankt (haben/sein) — nicht sicher (Regel 16) 2026-10-18
  'schlitzen', // zurückgestellt: selten, meist «aufschlitzen» — nicht sicher (Regel 14) 2026-10-18
  'schludern', // zurückgestellt: umgangssprachlich, abwertend — nicht sicher (Regel 14) 2026-10-18
  'schmarotzen', // zurückgestellt: abwertend, Partizip ohne ge- (schmarotzt) — nicht sicher (Regel 14/17) 2026-10-18
  'schmauchen', // zurückgestellt: veraltend — nicht sicher (Regel 14/17) 2026-10-18
  'schmausen', // zurückgestellt: veraltend/scherzhaft — nicht sicher (Regel 14/17) 2026-10-18
  'schmutzen', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-18
  'schnäbeln', // zurückgestellt: selten, scherzhaft — nicht sicher (Regel 14) 2026-10-18
  'schnabulieren', // zurückgestellt: scherzhaft, selten — nicht sicher (Regel 14) 2026-10-18
  'schnackeln', // zurückgestellt: bayerisch/österr. mundartlich — nicht sicher (Regel 14) 2026-10-18
  'schnalzen', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-18
  'schnarren', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-18
  'schnauzen', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-18
  'schnellen', // zurückgestellt: gehoben, Hilfsverb schwankt — nicht sicher (Regel 14/16) 2026-10-18
  'schniegeln', // zurückgestellt: veraltend, meist «geschniegelt» — nicht sicher (Regel 14) 2026-10-18
  'schnipseln', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-18
  'schnitzeln', // zurückgestellt: selten, landschaftlich — nicht sicher (Regel 14) 2026-10-18
  'schnörkeln', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-18
  'schönen', // zurückgestellt: Fachsprache/selten (Zahlen schönen) — nicht sicher (Regel 14) 2026-10-18
  'schrämen', // zurückgestellt: Bergbau-Fachsprache — nicht sicher (Regel 14) 2026-10-18
  'schrammen', // zurückgestellt: selten, meist «schrammen an» / Schramme — nicht sicher (Regel 14) 2026-10-18
  'schreinern', // zurückgestellt: landschaftlich (süddt.) — nicht sicher (Regel 14) 2026-10-18
  'schriftstellern', // zurückgestellt: scherzhaft, selten — nicht sicher (Regel 14) 2026-10-18
  'schröpfen', // zurückgestellt: veraltet (Medizin) / übertragen — nicht sicher (Regel 14/17) 2026-10-18
  'schrumpeln', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-18
  'schurigeln', // zurückgestellt: umgangssprachlich, veraltend — nicht sicher (Regel 14/17) 2026-10-18
  'schürzen', // zurückgestellt: gehoben, selten — nicht sicher (Regel 14) 2026-10-18
  'schustern', // zurückgestellt: umgangssprachlich, veraltend — nicht sicher (Regel 14/17) 2026-10-18
  'schwabbeln', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-18
  'schwäbeln', // zurückgestellt: regional — nicht sicher (Regel 14) 2026-10-18
  'schwadronieren', // zurückgestellt: abwertend, selten — nicht sicher (Regel 14/17) 2026-10-18
  'schwängern', // zurückgestellt: sexueller Bezug — Entscheidung Lukas 2026-10-18
  'schwänzeln', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-18
  'schwappen', // zurückgestellt: Hilfsverb schwankt (haben/sein) — nicht sicher (Regel 16) 2026-10-18
  'schwatzen', // zurückgestellt: landschaftlich (neben «schwätzen») — nicht sicher (Regel 14) 2026-10-18
  'schweinigeln', // zurückgestellt: umgangssprachlich, derb — Entscheidung Lukas 2026-10-18
  'schwelen', // zurückgestellt: gehoben, selten — nicht sicher (Regel 14) 2026-10-18
  'schwirren', // zurückgestellt: Hilfsverb schwankt (haben/sein) — nicht sicher (Regel 16) 2026-10-18
  'sedimentieren', // zurückgestellt: Fachsprache — nicht sicher (Regel 14) 2026-10-18
  'seihen', // zurückgestellt: selten (Küche) — nicht sicher (Regel 14) 2026-10-18
  'sekkieren', // zurückgestellt: österr. umgangssprachlich — nicht sicher (Regel 14) 2026-10-18
  'sekundieren', // zurückgestellt: gehoben/Fachsprache — nicht sicher (Regel 14) 2026-10-18
  'sengen', // zurückgestellt: gehoben, selten — nicht sicher (Regel 14) 2026-10-18
  'sexualisieren', // zurückgestellt: sexueller Bezug — Entscheidung Lukas 2026-10-18
  'siechen', // zurückgestellt: veraltet — nicht sicher (Regel 14/17) 2026-10-18
  'siegeln', // zurückgestellt: selten, meist «versiegeln» — nicht sicher (Regel 14) 2026-10-18
  'sirren', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-18
  'sistieren', // zurückgestellt: Rechts-/Amtssprache — nicht sicher (Regel 14) 2026-10-18
  'skalpieren', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-18
  'skaten', // zurückgestellt: Hilfsverb schwankt (haben/sein), Anglizismus — nicht sicher (Regel 16) 2026-10-18
  'soufflieren', // zurückgestellt: Theatersprache — nicht sicher (Regel 14) 2026-10-18
  'soupieren', // zurückgestellt: veraltet — nicht sicher (Regel 14/17) 2026-10-18
  'sowjetisieren', // zurückgestellt: historisch, selten — nicht sicher (Regel 14) 2026-10-18
  'spaßen', // zurückgestellt: veraltend — nicht sicher (Regel 14/17) 2026-10-18
  'speicheln', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-18
  'spintisieren', // zurückgestellt: umgangssprachlich, selten — nicht sicher (Regel 14) 2026-10-18
  'splittern', // zurückgestellt: Hilfsverb schwankt (haben/sein) — nicht sicher (Regel 16) 2026-10-18
  'spornen', // zurückgestellt: selten, meist «anspornen» — nicht sicher (Regel 14) 2026-10-18
  'spötteln', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-18
  'sprayen', // zurückgestellt: Anglizismus, Schreibung/Formen schwanken — nicht sicher (Regel 14) 2026-10-18
  'sprenkeln', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-18
  'spulen', // zurückgestellt: Fachsprache/selten — nicht sicher (Regel 14) 2026-10-18
  'spuren', // zurückgestellt: umgangssprachlich/Fachsprache (Skisport) — nicht sicher (Regel 14) 2026-10-18
  'spurten', // zurückgestellt: Hilfsverb schwankt (haben/sein) — nicht sicher (Regel 16) 2026-10-18
  'sputen', // zurückgestellt: veraltend, nur reflexiv — nicht sicher (Regel 14/17) 2026-10-18
  'stählen', // zurückgestellt: gehoben — nicht sicher (Regel 14) 2026-10-18
  'staksen', // zurückgestellt: umgangssprachlich, Hilfsverb sein — nicht sicher (Regel 14) 2026-10-18
  'statuieren', // zurückgestellt: fast nur in «ein Exempel statuieren» — nicht sicher (Regel 14) 2026-10-18
  'stäuben', // zurückgestellt: selten, veraltend — nicht sicher (Regel 14) 2026-10-18
  'stauchen', // zurückgestellt: mehrere Bedeutungen (Technik / umgangssprachlich «zurechtweisen»), selten — nicht sicher (Regel 14) 2026-10-18
  'stäupen', // zurückgestellt: veraltet (Strafe) — nicht sicher (Regel 14) 2026-10-18
  'stenographieren', // zurückgestellt: ältere Schreibung von «stenografieren» (wie photographieren) — nicht sicher (Regel 14) 2026-10-18
  'steppen', // zurückgestellt: Homograph: «Stoff steppen» (nähen) / «Stepp tanzen» — wie lecken (Regel 14) 2026-10-18
  'stieren', // zurückgestellt: selten, umgangssprachlich — nicht sicher (Regel 14) 2026-10-18
  'stoppeln', // zurückgestellt: selten (Stoppeln, zusammenstoppeln) — nicht sicher (Regel 14) 2026-10-18
  'stöpseln', // zurückgestellt: umgangssprachlich, selten — nicht sicher (Regel 14) 2026-10-18
  'strudeln', // zurückgestellt: selten, Hilfsverb schwankt — nicht sicher (Regel 14/16) 2026-10-18
  'stückeln', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-18
  'stümpern', // zurückgestellt: abwertend, selten — nicht sicher (Regel 14) 2026-10-18
  'stutzen', // zurückgestellt: zwei Verben (kürzen / innehalten) — wie lecken (Regel 14) 2026-10-18
  'sudeln', // zurückgestellt: umgangssprachlich, abwertend — nicht sicher (Regel 14) 2026-10-18
  'sülzen', // zurückgestellt: umgangssprachlich, mehrere Bedeutungen — nicht sicher (Regel 14) 2026-10-18
  'surren', // zurückgestellt: selten, Hilfsverb schwankt — nicht sicher (Regel 14/16) 2026-10-18
  'synthetisieren', // zurückgestellt: Fachsprache (Chemie), selten — nicht sicher (Regel 14) 2026-10-18
  'tabellarisieren', // zurückgestellt: selten, Fachsprache — nicht sicher (Regel 14) 2026-10-18
  'tabellieren', // zurückgestellt: selten, Fachsprache — nicht sicher (Regel 14) 2026-10-18
  'tafeln', // zurückgestellt: gehoben, veraltend — nicht sicher (Regel 14) 2026-10-18
  'täfeln', // zurückgestellt: Fachsprache (Handwerk), selten — nicht sicher (Regel 14) 2026-10-18
  'taillieren', // zurückgestellt: Fachsprache (Schneiderei), selten — nicht sicher (Regel 14) 2026-10-18
  'takeln', // zurückgestellt: Seemannssprache, selten — nicht sicher (Regel 14) 2026-10-18
  'tändeln', // zurückgestellt: veraltend — nicht sicher (Regel 14) 2026-10-18
  'tänzeln', // zurückgestellt: Hilfsverb schwankt (haben/sein), selten — nicht sicher (Regel 14/16) 2026-10-18
  'tapern', // zurückgestellt: landschaftlich, umgangssprachlich — nicht sicher (Regel 14) 2026-10-18
  'tappen', // zurückgestellt: Hilfsverb schwankt (haben/sein) — nicht sicher (Regel 16) 2026-10-18
  'tapsen', // zurückgestellt: umgangssprachlich, Hilfsverb schwankt — nicht sicher (Regel 14/16) 2026-10-18
  'tarieren', // zurückgestellt: Fachsprache (Waage), selten — nicht sicher (Regel 14) 2026-10-18
  'tattern', // zurückgestellt: umgangssprachlich, selten — nicht sicher (Regel 14) 2026-10-18
  'telegrafieren', // zurückgestellt: veraltend — nicht sicher (Regel 14) 2026-10-18
  'telegraphieren', // zurückgestellt: veraltete Schreibung von telegrafieren, veraltend — nicht sicher (Regel 14) 2026-10-18
  'tigern', // zurückgestellt: umgangssprachlich, Hilfsverb sein — nicht sicher (Regel 14) 2026-10-18
  'tingeln', // zurückgestellt: umgangssprachlich, Hilfsverb schwankt — nicht sicher (Regel 14/16) 2026-10-18
  'tippeln', // zurückgestellt: umgangssprachlich, Hilfsverb sein — nicht sicher (Regel 14) 2026-10-18
  'tirilieren', // zurückgestellt: dichterisch, selten — nicht sicher (Regel 14) 2026-10-18
  'tischlern', // zurückgestellt: umgangssprachlich, selten (wie schreinern) — nicht sicher (Regel 14) 2026-10-18
  'trassieren', // zurückgestellt: Fachsprache (Vermessung/Bank), selten — nicht sicher (Regel 14) 2026-10-18
  'travestieren', // zurückgestellt: Fachsprache Literatur, selten — nicht sicher (Regel 14) 2026-10-18
  'tremolieren', // zurückgestellt: Fachsprache Musik, selten — nicht sicher (Regel 14) 2026-10-18
  'triezen', // zurückgestellt: umgangssprachlich, landschaftlich — nicht sicher (Regel 14) 2026-10-18
  'trotteln', // zurückgestellt: umgangssprachlich, selten, Hilfsverb sein — nicht sicher (Regel 14) 2026-10-18
  'trutzen', // zurückgestellt: veraltet — nicht sicher (Regel 14) 2026-10-18
  'tüpfeln', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-18
  'türmen', // zurückgestellt: zwei Bedeutungen mit verschiedenem Hilfsverb (stapeln: haben / fliehen: sein) — nicht sicher (Regel 16) 2026-10-18
  'übersetzen', // zurückgestellt: trennbar UND untrennbar (setzte über ↔ übersetzte) — «🔀» (Regel 16) 2026-10-18
  'umfloren', // zurückgestellt: gehoben, selten — nicht sicher (Regel 14) 2026-10-18
  'umschiffen', // zurückgestellt: trennbar UND untrennbar (schiffte um ↔ umschiffte) — «🔀» (Regel 16) 2026-10-18
  'umwölken', // zurückgestellt: gehoben, selten — nicht sicher (Regel 14) 2026-10-18
  'unifizieren', // zurückgestellt: Fachsprache, selten — nicht sicher (Regel 14) 2026-10-18
  'verargen', // zurückgestellt: veraltend, gehoben — nicht sicher (Regel 14) 2026-10-19
  'verarschen', // zurückgestellt: derb/vulgär — Entscheidung Lukas (Regel 17) 2026-10-19
  'verbiestern', // zurückgestellt: umgangssprachlich, landschaftlich — nicht sicher (Regel 14) 2026-10-19
  'verblöden', // zurückgestellt: umgangssprachlich, Hilfsverb schwankt (haben/sein) — nicht sicher (Regel 14/16) 2026-10-19
  'verbrämen', // zurückgestellt: gehoben, selten — nicht sicher (Regel 14) 2026-10-19
  'verdrecken', // zurückgestellt: umgangssprachlich, Hilfsverb schwankt (haben/sein) — nicht sicher (Regel 14/16) 2026-10-19
  'verdummen', // zurückgestellt: Hilfsverb schwankt (haben/sein) — nicht sicher (Regel 16) 2026-10-19
  'verdünnisieren', // zurückgestellt: umgangssprachlich, scherzhaft — nicht sicher (Regel 14) 2026-10-19
  'verdutzen', // zurückgestellt: selten (meist nur «verdutzt») — nicht sicher (Regel 14) 2026-10-19
  'verehelichen', // zurückgestellt: veraltet/Amtssprache — nicht sicher (Regel 14) 2026-10-19
  'vereinzeln', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-19
  'verfemen', // zurückgestellt: gehoben, selten — nicht sicher (Regel 14) 2026-10-19
  'verfilzen', // zurückgestellt: Hilfsverb schwankt (haben/sein) — nicht sicher (Regel 16) 2026-10-19
  'verfrühen', // zurückgestellt: selten (meist nur «verfrüht») — nicht sicher (Regel 14) 2026-10-19
  'vergackeiern', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'vergattern', // zurückgestellt: umgangssprachlich/Militär — nicht sicher (Regel 14) 2026-10-19
  'vergeistigen', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-19
  'vergipsen', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-19
  'vergletschern', // zurückgestellt: Fachsprache, selten — nicht sicher (Regel 14) 2026-10-19
  'vergrätzen', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'vergraulen', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'vergröbern', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-19
  'verhohnepiepeln', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'verhohnepipeln', // zurückgestellt: umgangssprachlich, Nebenform — nicht sicher (Regel 14) 2026-10-19
  'verklickern', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'verknöchern', // zurückgestellt: selten, Hilfsverb sein — nicht sicher (Regel 14) 2026-10-19
  'verkorksen', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'verkupfern', // zurückgestellt: Fachsprache, selten — nicht sicher (Regel 14) 2026-10-19
  'verlottern', // zurückgestellt: umgangssprachlich, Hilfsverb sein — nicht sicher (Regel 14) 2026-10-19
  'verludern', // zurückgestellt: umgangssprachlich, selten — nicht sicher (Regel 14) 2026-10-19
  'verlustieren', // zurückgestellt: scherzhaft, selten — nicht sicher (Regel 14) 2026-10-19
  'vermöbeln', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'vermurksen', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'vernickeln', // zurückgestellt: Fachsprache, selten — nicht sicher (Regel 14) 2026-10-19
  'vernünfteln', // zurückgestellt: veraltend, selten — nicht sicher (Regel 14) 2026-10-19
  'veröden', // zurückgestellt: zwei Bedeutungen mit verschiedenem Hilfsverb (Medizin: haben / verlassen werden: sein) — nicht sicher (Regel 16) 2026-10-19
  'verplempern', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'verpönen', // zurückgestellt: nur als Partizip «verpönt» gebräuchlich — nicht sicher (Regel 14) 2026-10-19
  'verramschen', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'verrecken', // zurückgestellt: derb/vulgär — Entscheidung Lukas (Regel 17) 2026-10-19
  'versauen', // zurückgestellt: derb/umgangssprachlich — Entscheidung Lukas (Regel 17) 2026-10-19
  'verscheißern', // zurückgestellt: derb/vulgär — Entscheidung Lukas (Regel 17) 2026-10-19
  'verscherbeln', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'verschlammen', // zurückgestellt: selten, Hilfsverb sein — nicht sicher (Regel 14) 2026-10-19
  'verspießern', // zurückgestellt: umgangssprachlich, selten — nicht sicher (Regel 14) 2026-10-19
  'versumpfen', // zurückgestellt: umgangssprachlich (Bedeutung «verwahrlosen»), Hilfsverb sein — nicht sicher (Regel 14) 2026-10-19
  'vertäuen', // zurückgestellt: Seemannssprache, selten — nicht sicher (Regel 14) 2026-10-19
  'verulken', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'verweltlichen', // zurückgestellt: selten, Fachsprache — nicht sicher (Regel 14) 2026-10-19
  'verzärteln', // zurückgestellt: veraltend — nicht sicher (Regel 14) 2026-10-19
  'vespern', // zurückgestellt: landschaftlich (süddeutsch) — nicht sicher (Regel 14) 2026-10-19
  'visieren', // zurückgestellt: veraltet/Fachsprache — nicht sicher (Regel 14) 2026-10-19
  'visitieren', // zurückgestellt: veraltend — nicht sicher (Regel 14) 2026-10-19
  'vitaminisieren', // zurückgestellt: Fachsprache, selten — nicht sicher (Regel 14) 2026-10-19
  'vögeln', // zurückgestellt: derb/vulgär — Entscheidung Lukas (Regel 17) 2026-10-19
  'voltigieren', // zurückgestellt: Fachsprache (Reiten/Fechten), selten — nicht sicher (Regel 14) 2026-10-19
  'walken', // zurückgestellt: zwei Bedeutungen (Leder/Filz walken ↔ Nordic Walking), Hilfsverb schwankt — nicht sicher (Regel 14/16) 2026-10-19
  'wallen', // zurückgestellt: Hilfsverb schwankt (haben/sein), gehoben — nicht sicher (Regel 16) 2026-10-19
  'wegarbeiten', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'wegschnippen', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-19
  'werkeln', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'wichsen', // zurückgestellt: derb/vulgär (Nebenbedeutung) — Entscheidung Lukas (Regel 17) 2026-10-19
  'wiegeln', // zurückgestellt: selten, nur in aufwiegeln gebräuchlich — nicht sicher (Regel 14) 2026-10-19
  'wienern', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'winkeln', // zurückgestellt: selten (meist «abwinkeln», «angewinkelt») — nicht sicher (Regel 14) 2026-10-19
  'wummern', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'wursteln', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'wuscheln', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'wuseln', // zurückgestellt: umgangssprachlich, landschaftlich, Hilfsverb schwankt — nicht sicher (Regel 14/16) 2026-10-19
  'xerographieren', // zurückgestellt: veraltete Schreibung/Fachsprache — nicht sicher (Regel 14) 2026-10-19
  'zagen', // zurückgestellt: veraltend, gehoben — nicht sicher (Regel 14) 2026-10-19
  'zäumen', // zurückgestellt: Fachsprache (Pferd), selten — nicht sicher (Regel 14) 2026-10-19
  'zausen', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-19
  'zechen', // zurückgestellt: veraltend, scherzhaft — nicht sicher (Regel 14) 2026-10-19
  'zerdeppern', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'zerfurchen', // zurückgestellt: selten (meist «zerfurcht») — nicht sicher (Regel 14) 2026-10-19
  'zerknautschen', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'ziegeln', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-19
  'ziemen', // zurückgestellt: veraltend, gehoben — nicht sicher (Regel 14) 2026-10-19
  'zirkeln', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-19
  'zischeln', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-19
  'ziselieren', // zurückgestellt: Fachsprache (Goldschmied), selten — nicht sicher (Regel 14) 2026-10-19
  'zotteln', // zurückgestellt: umgangssprachlich, Hilfsverb sein — nicht sicher (Regel 14) 2026-10-19
  'zublinzeln', // zurückgestellt: selten — nicht sicher (Regel 14) 2026-10-19
  'züchtigen', // zurückgestellt: veraltend — nicht sicher (Regel 14) 2026-10-19
  'zuckeln', // zurückgestellt: umgangssprachlich, Hilfsverb sein — nicht sicher (Regel 14) 2026-10-19
  'zürnen', // zurückgestellt: veraltend, gehoben — nicht sicher (Regel 14) 2026-10-19
  'zuwenden', // zurückgestellt: gemischtes Verb mit zwei Präteritumformen (wandte/wendete zu) wie «wenden» — nicht sicher (Regel 16) 2026-10-19
  'zwiebeln', // zurückgestellt: umgangssprachlich — nicht sicher (Regel 14) 2026-10-19
  'Ablauf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ablauf eines Prozesses / Ablauf einer Frist / Abfluss) — nach den Nomen 2026-10-19
  'Ableger', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pflanzenableger / Zweigfirma) — nach den Nomen 2026-10-19
  'Ableitung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sprache/Mathematik / Wasserableitung) — nach den Nomen 2026-10-19
  'Abnahme', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rückgang / Abnahme eines Baus / Kauf) — nach den Nomen 2026-10-19
  'Abordnung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abordnen (Versetzung) / Delegation) — nach den Nomen 2026-10-19
  'Abrechnung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abrechnung (Rechnung) / Vergeltung («Abrechnung mit jdm.»)) — nach den Nomen 2026-10-19
  'Abruf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abrufen von Daten / Anforderung von Waren / «auf Abruf» (Bereitschaft)) — nach den Nomen 2026-10-19
  'Absatz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Textabschnitt / Schuhabsatz / Verkauf / Treppenabsatz) — nach den Nomen 2026-10-19
  'Abschlag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Preisnachlass / Abschlagszahlung / Torwart-Abstoß / Golf) — nach den Nomen 2026-10-19
  'Abschluss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ende / Schul-/Studienabschluss / Geschäftsabschluss) — nach den Nomen 2026-10-19
  'Abschnitt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Textteil / Zeitabschnitt / abtrennbarer Teil eines Formulars) — nach den Nomen 2026-10-19
  'Abschuss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abschießen eines Flugzeugs / Start einer Rakete / Jagd) — nach den Nomen 2026-10-19
  'Abschwung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: wirtschaftlicher Abschwung / Abgang beim Turnen) — nach den Nomen 2026-10-19
  'Abseits', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abseits (Fußballregel) / «im Abseits stehen» (ausgeschlossen sein)) — nach den Nomen 2026-10-19
  'Absetzung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Amtsenthebung / steuerliche Absetzung / Absetzung einer Sendung) — nach den Nomen 2026-10-19
  'Absprung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Absprung beim Springen / Ausstieg («den Absprung schaffen»)) — nach den Nomen 2026-10-19
  'Abstand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Entfernung / «Abstand nehmen» (verzichten) / Ablösesumme) — nach den Nomen 2026-10-19
  'Abstellgleis', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gleis / übertragen «aufs Abstellgleis» (kaltgestellt)) — nach den Nomen 2026-10-19
  'Abstieg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Weg nach unten / Abstieg in eine tiefere Liga / sozialer Niedergang) — nach den Nomen 2026-10-19
  'Abstimmung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wahl/Votum / Koordination («Abstimmung mit Kollegen»)) — nach den Nomen 2026-10-19
  'Abstract', // zurückgestellt: Genus unsicher (der oder das Abstract) — nicht sicher (Regel 14) 2026-10-19
  'Abstrich', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: medizinischer Abstrich / Kürzung («Abstriche machen») / Schreibstrich) — nach den Nomen 2026-10-19
  'Abstufung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gradation (Farbabstufung) / Herabstufung) — nach den Nomen 2026-10-19
  'Abteilung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 3 (Homograph, gleicher Artikel): Abteilung «Abtrennen» / Abteilung «Teil einer Firma» — nach den Nomen 2026-10-19
  'Abwehr', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verteidigung (Sport/Militär/Immunsystem) / Geheimdienst) — nach den Nomen 2026-10-19
  'Abwehrchef', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Chef der Verteidigung (Sport) / Chef des Geheimdienstes «Abwehr») — nach den Nomen 2026-10-19
  'Abwertung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Währungsabwertung / Herabsetzung einer Person) — nach den Nomen 2026-10-19
  'Abwicklung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Durchführung (Auftrag) / Liquidation einer Firma) — nach den Nomen 2026-10-19
  'Abwurf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abwerfen (Bomben, Hilfsgüter) / Abwurf des Torwarts) — nach den Nomen 2026-10-19
  'Abzug', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lohnabzug / Truppenabzug / Abzug der Waffe / Fotoabzug / Dunstabzug) — nach den Nomen 2026-10-19
  'Achse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Radachse / Achse (Geometrie) / politisches Bündnis) — nach den Nomen 2026-10-19
  'Achsel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schulter («mit den Achseln zucken») / Achselhöhle) — nach den Nomen 2026-10-19
  'Achter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ziffer/Form 8 / Ruderboot / verbogenes Rad) — nach den Nomen 2026-10-19
  'Achtung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Respekt / Warnruf «Achtung!») — nach den Nomen 2026-10-19
  'Ackermann', // zurückgestellt: Eigenname (Familienname) bzw. veraltet für «Bauer» — nicht sicher (Regel 14/18) 2026-10-19
  'Adaptierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anpassung / (österr.) Umbau einer Wohnung) — nach den Nomen 2026-10-19
  'Adaption', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bearbeitung (Film/Buch) / biologische Anpassung) — nach den Nomen 2026-10-19
  'Ade', // zurückgestellt: eher Interjektion, als Nomen («das Ade») selten — nicht sicher (Regel 14) 2026-10-19
  'Ader', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Blutgefäß / Leitungsdraht / Begabung («eine Ader für»)) — nach den Nomen 2026-10-19
  'Aderlass', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: medizinischer Aderlass / Verlust (übertragen)) — nach den Nomen 2026-10-19
  'Adieu', // zurückgestellt: eher Interjektion, als Nomen («das Adieu») selten — nicht sicher (Regel 14) 2026-10-19
  'Admiral', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Marineoffizier / Schmetterling) — nach den Nomen 2026-10-19
  'Advokat', // zurückgestellt: veraltet/regional (schweiz.) — Markierung nicht sicher (Regel 14/17) 2026-10-19
  'Aerobic', // zurückgestellt: Genus unsicher (das oder die Aerobic) — nicht sicher (Regel 14) 2026-10-19
  'Afghane', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einwohner Afghanistans / Hunderasse (Afghanischer Windhund)) — nach den Nomen 2026-10-19
  'Agent', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geheimagent / Vermittler (Künstler-, Handelsagent)) — nach den Nomen 2026-10-19
  'Agentin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen wie «Agent»: Geheimagentin / Vermittlerin) — nach den Nomen 2026-10-19
  'Aggregat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Maschinensatz / Aggregatzustand, Anhäufung (Chemie, Mathematik)) — nach den Nomen 2026-10-19
  'Ahn', // zurückgestellt: gehoben; Deklination schwankt (des Ahns/des Ahnen) — nicht sicher (Regel 14) 2026-10-19
  'Ahnung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorgefühl / Vorstellung, Wissen («keine Ahnung»)) — nach den Nomen 2026-10-19
  'Airbus', // zurückgestellt: Firmen-/Markenname, kein geografischer Name — nicht bauen (Regel 18) 2026-10-19
  'Aki', // zurückgestellt: Bedeutung unklar (Abkürzung/Eigenname?) — nicht sicher (Regel 14) 2026-10-19
  'Akkord', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musik (Dreiklang) / Akkordarbeit (Stücklohn)) — nach den Nomen 2026-10-19
  'Akquisition', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erwerb (Firmenkauf) / Kundenwerbung) — nach den Nomen 2026-10-19
  'Aktion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Handlung, Kampagne / Sonderangebot («in Aktion», österr.)) — nach den Nomen 2026-10-19
  'Aktionswoche', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Woche einer Kampagne / Woche mit Sonderangeboten) — nach den Nomen 2026-10-19
  'Aktiva', // zurückgestellt: nur Plural (Pluraletantum), Genus in der Liste «das» — nicht sicher (Regel 14) 2026-10-19
  'Aktuar', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Versicherungsmathematiker / (veraltet) Gerichtsschreiber) — nach den Nomen 2026-10-19
  'Akustik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lehre vom Schall / Klangwirkung eines Raumes) — nach den Nomen 2026-10-19
  'Akzent', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aussprache-Färbung / Betonungszeichen / Schwerpunkt («Akzente setzen»)) — nach den Nomen 2026-10-19
  'Album', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fotoalbum, Sammelbuch / Musikalbum (Tonträger)) — nach den Nomen 2026-10-19
  'Alfa', // zurückgestellt: Markenname bzw. Schreibvariante unklar — nicht sicher (Regel 14/18) 2026-10-19
  'Alibi', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nachweis der Abwesenheit / Ausrede, Vorwand) — nach den Nomen 2026-10-19
  'Alien', // zurückgestellt: Genus unsicher (das oder der Alien) — nicht sicher (Regel 14) 2026-10-19
  'Alitalia', // zurückgestellt: Firmen-/Markenname (Fluggesellschaft) — nicht bauen (Regel 18) 2026-10-19
  'Allah', // zurückgestellt: Eigenname (Religion), kein geografischer Name — nicht bauen (Regel 18) 2026-10-19
  'Allgemeinheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Öffentlichkeit, alle / Allgemeingültigkeit (Unbestimmtheit)) — nach den Nomen 2026-10-19
  'Alpe', // zurückgestellt: regional (österr./schweiz.) Nebenform von «Alm» — Gebrauch nicht sicher (Regel 14) 2026-10-19
  'Alster', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2 (Homograph, anderer Artikel): die Alster (Fluss in Hamburg) / das Alster (Bier-Mischgetränk) — nach den Nomen 2026-10-19
  'Alte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Alte, das Alte) + mehrere Bedeutungen — nach den Nomen 2026-10-19
  'Altertum', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Epoche der Antike / Plural «Altertümer»: alte Kunstgegenstände) — nach den Nomen 2026-10-19
  'Altlast', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: verseuchtes Gelände / übertragen: übernommenes altes Problem) — nach den Nomen 2026-10-19
  'Altmeister', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorsteher einer Zunft / anerkannter Meister eines Fachs / früherer Champion) — nach den Nomen 2026-10-19
  'Amazone', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kriegerin der Sage / Reiterin / Papagei) — nach den Nomen 2026-10-19
  'Ambulanz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Klinik-Abteilung für ambulante Behandlung / Krankenwagen) — nach den Nomen 2026-10-19
  'Amerika', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Doppelkontinent / umgangssprachlich die USA) — nach den Nomen 2026-10-19
  'Amerikaner', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einwohner der USA bzw. Amerikas / Gebäck mit Zuckerguss) — nach den Nomen 2026-10-19
  'Ampel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verkehrsampel / Hängelampe, Blumenampel / Ampelkoalition) — nach den Nomen 2026-10-19
  'Amt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Posten, Funktion / Behörde / Aufgabe; «Amt» der Telefonvermittlung) — nach den Nomen 2026-10-19
  'Amtssprache', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: offizielle Landessprache / bürokratischer Stil) — nach den Nomen 2026-10-19
  'Amen', // zurückgestellt: eher Interjektion/Gebetsformel, als Nomen («das Amen», «sein Amen geben») selten — nicht sicher (Regel 14) 2026-10-19
  'Ammann', // zurückgestellt: regional (schweiz.) Amtstitel — Gebrauch nicht sicher (Regel 14/17) 2026-10-19
  'Anachronismus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: falsche zeitliche Einordnung / überholte Einrichtung) — nach den Nomen 2026-10-19
  'Analphabet', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: wer nicht lesen und schreiben kann / abwertend: Unwissender) — nach den Nomen 2026-10-19
  'Analytiker', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: analytisch denkender Mensch / Psychoanalytiker) — nach den Nomen 2026-10-19
  'Anarchie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gesetzlosigkeit, Chaos / herrschaftsfreie Gesellschaftsordnung) — nach den Nomen 2026-10-19
  'Anatomie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wissenschaft vom Körperbau / Körperbau / anatomisches Institut) — nach den Nomen 2026-10-19
  'Anbau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anbau von Pflanzen / angebauter Gebäudeteil) — nach den Nomen 2026-10-19
  'Andacht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: innere Sammlung / kurzer Gottesdienst) — nach den Nomen 2026-10-19
  'Andenken', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erinnerung («im Andenken an») / Souvenir) — nach den Nomen 2026-10-19
  'Andeutung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anspielung, Hinweis / schwaches Anzeichen) — nach den Nomen 2026-10-19
  'Aneignung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erwerb von Wissen / widerrechtliche Inbesitznahme) — nach den Nomen 2026-10-19
  'Anerkennung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lob, Würdigung / offizielle Bestätigung, z. B. eines Abschlusses) — nach den Nomen 2026-10-19
  'Anfahrt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fahrt zum Ziel / Zufahrtsweg) — nach den Nomen 2026-10-19
  'Anfall', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Krankheitsanfall / Anwandlung (Wutanfall) / Anfallen von Kosten, Müll) — nach den Nomen 2026-10-19
  'Anfangszeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: erste Zeit, Anfangsperiode / Uhrzeit des Beginns) — nach den Nomen 2026-10-19
  'Anfechtung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: rechtliches Anfechten / gehoben: Versuchung) — nach den Nomen 2026-10-19
  'Anflug', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Landeanflug / Hauch, Spur («ein Anflug von Ironie»)) — nach den Nomen 2026-10-19
  'Anforderung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anspruch, Voraussetzung / Bestellung, Anfordern) — nach den Nomen 2026-10-19
  'Angabe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Auskunft, Information / umgangssprachlich: Prahlerei / Tennis: Aufschlag (österr.)) — nach den Nomen 2026-10-19
  'Angeklagte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Angeklagte) — nach den Nomen 2026-10-19
  'Angel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Angelrute / Türangel) — nach den Nomen 2026-10-19
  'Angestellte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Angestellte) — nach den Nomen 2026-10-19
  'Angriff', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Attacke / Sport: Sturm, Offensive) — nach den Nomen 2026-10-19
  'Anhang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anhang eines Textes, E-Mail-Anhang / Familie, Anhängerschaft) — nach den Nomen 2026-10-19
  'Animation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Trickfilm, Computeranimation / Freizeitprogramm im Hotel) — nach den Nomen 2026-10-19
  'Anklage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beschuldigung vor Gericht / Anklagevertretung) — nach den Nomen 2026-10-19
  'Anklang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zustimmung («Anklang finden») / Ähnlichkeit («Anklang an»)) — nach den Nomen 2026-10-19
  'Anlage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Grünanlage / technische Anlage / Geldanlage / Beilage zum Brief / Veranlagung) — nach den Nomen 2026-10-19
  'Anlass', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Grund, Ursache / Gelegenheit, Ereignis) — nach den Nomen 2026-10-19
  'Anlauf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anlauf beim Sprung / Versuch / Anlaufen einer Maschine) — nach den Nomen 2026-10-19
  'Anleger', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Investor / Bootsanlegestelle) — nach den Nomen 2026-10-19
  'Anleihe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wertpapier (Schuldverschreibung) / Entlehnung, Übernahme von Ideen) — nach den Nomen 2026-10-19
  'Anmeldung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Registrierung / Empfang, Rezeption («zur Anmeldung gehen»)) — nach den Nomen 2026-10-19
  'Annahme', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Akzeptieren / Vermutung / Annahmestelle) — nach den Nomen 2026-10-19
  'Anordnung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anordnung, Reihenfolge / Befehl, Weisung) — nach den Nomen 2026-10-19
  'Anpfiff', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spielbeginn durch Pfiff / umgangssprachlich: Rüge) — nach den Nomen 2026-10-19
  'Ana', // zurückgestellt: Bedeutung unklar (Abkürzung/Eigenname?) — nicht sicher (Regel 14) 2026-10-19
  'Anger', // zurückgestellt: regional/veraltend (Dorfwiese) — Gebrauch und Markierung nicht sicher (Regel 14/17) 2026-10-19
  'Anleihen', // zurückgestellt: Pluralform von «Anleihe», kein eigenes Nomen (Listenfehler, Genus «das») — nicht bauen (Regel 14) 2026-10-19
  'Anregung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorschlag, Idee / Stimulierung (Kreislauf, Appetit)) — nach den Nomen 2026-10-19
  'Anrufung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anrufung Gottes / Anrufung eines Gerichts) — nach den Nomen 2026-10-19
  'Ansage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Durchsage / Kartenspiel: Ansage / Diktat) — nach den Nomen 2026-10-19
  'Ansammlung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anhäufung von Dingen / Menschenmenge) — nach den Nomen 2026-10-19
  'Ansatz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Herangehensweise / Anfang, erstes Anzeichen / Haaransatz / Rechenansatz) — nach den Nomen 2026-10-19
  'Anschauung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Meinung, Auffassung / Wahrnehmung, Anschauungsmaterial) — nach den Nomen 2026-10-19
  'Anschlag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Attentat / Aushang / Tastenanschlag / Anschlag einer Tür) — nach den Nomen 2026-10-19
  'Anschluss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zuganschluss / Strom-, Telefonanschluss / Kontakt / historisch: «Anschluss» Österreichs) — nach den Nomen 2026-10-19
  'Ansehen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ruf, Prestige / das Ansehen (Betrachten)) — nach den Nomen 2026-10-19
  'Ansicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Meinung / Abbildung, Blick auf etwas / «zur Ansicht») — nach den Nomen 2026-10-19
  'Ansiedlung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Ansiedeln (Firmen, Menschen) / Siedlung) — nach den Nomen 2026-10-19
  'Anspannung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stress, Belastung / Anspannen von Muskeln oder Zugtieren) — nach den Nomen 2026-10-19
  'Ansprache', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kurze Rede / Kontakt, Gesprächspartner (österr.)) — nach den Nomen 2026-10-19
  'Anspruch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Recht, Forderung / Erwartung, Niveau («hohe Ansprüche»)) — nach den Nomen 2026-10-19
  'Anstalt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einrichtung, Institut / «Anstalten machen» (Vorbereitungen)) — nach den Nomen 2026-10-19
  'Anstand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: gutes Benehmen / Jagd: Ansitz) — nach den Nomen 2026-10-19
  'Anstieg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zunahme / ansteigender Weg) — nach den Nomen 2026-10-19
  'Anstrich', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Farbschicht / Anschein («einen seriösen Anstrich»)) — nach den Nomen 2026-10-19
  'Ansturm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Angriff / Andrang) — nach den Nomen 2026-10-19
  'Anteil', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Teil, Quote / «Anteil nehmen» (Mitgefühl, Interesse)) — nach den Nomen 2026-10-19
  'Anteilnahme', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mitgefühl, Beileid / Beteiligung, Interesse) — nach den Nomen 2026-10-19
  'Antenne', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Empfangsgerät / Fühler bei Insekten / umgangssprachlich: Gespür) — nach den Nomen 2026-10-19
  'Antrag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: schriftlicher Antrag / Heiratsantrag / Antrag im Parlament) — nach den Nomen 2026-10-19
  'Antrieb', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: technischer Antrieb / Motivation, Lust) — nach den Nomen 2026-10-19
  'Antritt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beginn (Reise, Amt) / Sport: Antritt, Sprint) — nach den Nomen 2026-10-19
  'Anwalt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rechtsanwalt / Fürsprecher («Anwalt der Schwachen»)) — nach den Nomen 2026-10-19
  'Anweisung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Befehl, Instruktion / Geldanweisung) — nach den Nomen 2026-10-19
  'Anwendung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gebrauch / Software, App / Behandlung (Kur)) — nach den Nomen 2026-10-19
  'Anwurf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beschuldigung (gehoben) / Handball: Anwurf) — nach den Nomen 2026-10-19
  'Anzeige', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Inserat / Strafanzeige / Display) — nach den Nomen 2026-10-19
  'Anzeiger', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Messgerät, Zeiger / Zeitungsname («Stadt-Anzeiger»)) — nach den Nomen 2026-10-19
  'Anziehungskraft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schwerkraft / Reiz, Attraktivität) — nach den Nomen 2026-10-19
  'Anzug', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kleidung / «im Anzug sein» (sich nähern)) — nach den Nomen 2026-10-19
  'Apokalypse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Offenbarung des Johannes / Weltuntergang, Katastrophe) — nach den Nomen 2026-10-19
  'Apostel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Jünger Jesu / Verfechter einer Idee (oft ironisch)) — nach den Nomen 2026-10-19
  'Antifa', // zurückgestellt: Kurzwort, politisch umstritten — Markierung (umgangssprachlich/abwertend?) nicht sicher (Regel 14/17) 2026-10-19
  'Anwachs', // zurückgestellt: sehr selten, Bedeutung nicht gesichert — nicht sicher (Regel 14) 2026-10-19
  'Apparat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gerät / Telefon («am Apparat») / Verwaltungsapparat) — nach den Nomen 2026-10-19
  'Appartement', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kleinwohnung / Zimmerflucht im Hotel, Suite) — nach den Nomen 2026-10-19
  'Appell', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufruf / militärischer Anwesenheitsappell) — nach den Nomen 2026-10-19
  'Appenzell', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schweizer Kanton(e) / Ort Appenzell) — nach den Nomen 2026-10-19
  'Applikation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Software, App / Verabreichung von Medikamenten / Stoffaufnäher) — nach den Nomen 2026-10-19
  'Araber', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mensch arabischer Herkunft / Pferderasse) — nach den Nomen 2026-10-19
  'Arabisch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (Sprachname: das Arabisch / das Arabische, adjektivisch gebeugt) — nach den Nomen 2026-10-19
  'Arbeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tätigkeit / Arbeitsplatz, Job / Klassenarbeit / Werk, Ergebnis) — nach den Nomen 2026-10-19
  'Arbeiterin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: weibliche Arbeiterin / Arbeitsbiene, -ameise) — nach den Nomen 2026-10-19
  'Arbeitsbereich', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufgabengebiet / räumlicher Arbeitsplatz) — nach den Nomen 2026-10-19
  'Arbeitskraft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fähigkeit zu arbeiten / arbeitende Person) — nach den Nomen 2026-10-19
  'Arbeitslose', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Arbeitslose) — nach den Nomen 2026-10-19
  'Arbeitsplatz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Platz zum Arbeiten / Stelle, Job) — nach den Nomen 2026-10-19
  'Arbeitsprozess', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Arbeitsablauf / Berufsleben («in den Arbeitsprozess eingliedern»)) — nach den Nomen 2026-10-19
  'Arbeitssuchende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv/Partizip: der/die Arbeitssuchende) — nach den Nomen 2026-10-19
  'Arbeitsstelle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stelle, Job / Arbeitsort) — nach den Nomen 2026-10-19
  'Arbeitszeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: tägliche/wöchentliche Arbeitszeit / für eine Arbeit benötigte Zeit) — nach den Nomen 2026-10-19
  'Architektur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Baukunst / Bauweise eines Gebäudes / Aufbau eines Systems (IT)) — nach den Nomen 2026-10-19
  'Arbeiterwohlfahrt', // zurückgestellt: Name einer Organisation (AWO), kein geografischer Name — nicht bauen (Regel 18) 2026-10-19
  'Arbeitslosenhilfe', // zurückgestellt: in Deutschland 2005 abgeschafft; heutiger Gebrauch/Markierung nicht sicher (Regel 14/17) 2026-10-19
  'Arbeitsmarktservice', // zurückgestellt: österr. Behördenname (AMS); Genus schwankt (das/der) — nicht sicher (Regel 14/18) 2026-10-19
  'Arena', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stadion, Kampfplatz / Zirkusmanege / Schauplatz (übertragen)) — nach den Nomen 2026-10-19
  'Argument', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Begründung / Mathematik: Argument einer Funktion) — nach den Nomen 2026-10-19
  'Arkade', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bogen auf Säulen / Bogengang (Plural)) — nach den Nomen 2026-10-19
  'Arm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Körperteil / Flussarm, Arm eines Leuchters o. Ä.) — nach den Nomen 2026-10-19
  'Armada', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kriegsflotte (span. Armada) / große Menge) — nach den Nomen 2026-10-19
  'Armatur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wasserhahn, Sanitärarmatur / Mess- und Bedienteile (Fahrzeug)) — nach den Nomen 2026-10-19
  'Armenhaus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: historisches Heim für Arme / ärmste Region (übertragen)) — nach den Nomen 2026-10-19
  'Aroma', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Duft, Geschmack / Aromastoff) — nach den Nomen 2026-10-19
  'Arrangement', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musikbearbeitung / Vereinbarung / Anordnung (Blumen)) — nach den Nomen 2026-10-19
  'Arsch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gesäß / Schimpfwort) — vulgär, Entscheidung Lukas — nach den Nomen 2026-10-19
  'Arsenal', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Waffenlager / große Sammlung (übertragen)) — nach den Nomen 2026-10-19
  'Art', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Weise / Sorte / biologische Art / Benehmen) — nach den Nomen 2026-10-19
  'Artikel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Grammatik / Zeitungsartikel / Ware / Gesetzesartikel) — nach den Nomen 2026-10-19
  'Artikulation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aussprache / Ausdruck von Gedanken) — nach den Nomen 2026-10-19
  'As', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spielkarte / Spitzenkönner / Tennis: Ass) — heute Schreibung «Ass» — nach den Nomen 2026-10-19
  'Aspekt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gesichtspunkt / Grammatik: Verbaspekt) — nach den Nomen 2026-10-19
  'Assoziation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gedankenverbindung / Vereinigung, Zusammenschluss) — nach den Nomen 2026-10-19
  'Asyl', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: politisches Asyl / Unterkunft (Obdachlosenasyl)) — nach den Nomen 2026-10-19
  'Asylsuchende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Partizip: der/die Asylsuchende) — nach den Nomen 2026-10-19
  'Are', // zurückgestellt: schweiz. Form von «das Ar» (Flächenmaß) — regional, nicht sicher (Regel 14/17) 2026-10-19
  'Arg', // zurückgestellt: gehoben/selten («ohne Arg») — Gebrauch als Nomen nicht sicher (Regel 14) 2026-10-19
  'Ari', // zurückgestellt: umgangssprachlich (Soldatensprache) für Artillerie — Markierung nicht sicher (Regel 14/17) 2026-10-19
  'Arschloch', // zurückgestellt: vulgäres Schimpfwort — Entscheidung Lukas (wie andere vulgäre Wörter) 2026-10-19
  'Aschenputtel', // zurückgestellt: Märchenfigur (Eigenname), kein geografischer Name — nicht bauen (Regel 18) 2026-10-19
  'Assekuranz', // zurückgestellt: veraltet/fachsprachlich für Versicherung — Markierung nicht sicher (Regel 14/17) 2026-10-19
  'Atlantis', // zurückgestellt: sagenhafter Ort, kein realer geografischer Name — nicht sicher (Regel 18) 2026-10-19
  'Atrium', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Innenhof / Herzvorhof (Anatomie)) — nach den Nomen 2026-10-19
  'Attribut', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Merkmal / Grammatik: Attribut / IT: Attribut) — nach den Nomen 2026-10-19
  'Auditorium', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hörsaal / Zuhörerschaft) — nach den Nomen 2026-10-19
  'Aufarbeitung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bewältigung der Vergangenheit / Erledigung liegen gebliebener Arbeit / Aufarbeiten von Möbeln) — nach den Nomen 2026-10-19
  'Aufbau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Errichtung / Struktur / Aufbau auf einem Fahrzeug) — nach den Nomen 2026-10-19
  'Aufbewahrung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Aufbewahren / Gepäckaufbewahrung (Ort)) — nach den Nomen 2026-10-19
  'Aufbruch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abreise, Losgehen / Neubeginn, Umbruch) — nach den Nomen 2026-10-19
  'Aufenthalt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verweilen, Aufenthalt in einer Stadt / Halt eines Zuges / Aufenthaltsort) — nach den Nomen 2026-10-19
  'Auffahrt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Autobahnauffahrt / Zufahrt zu einem Haus / schweiz.: Christi Himmelfahrt) — nach den Nomen 2026-10-19
  'Auffassung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Meinung / Auffassungsgabe) — nach den Nomen 2026-10-19
  'Aufgabe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pflicht, Auftrag / Übungsaufgabe / Aufgeben (eines Plans, eines Pakets)) — nach den Nomen 2026-10-19
  'Aufgebot', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: aufgebotene Menge (Polizei) / Eheaufgebot / Mannschaftskader) — nach den Nomen 2026-10-19
  'Aufkommen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Entstehen / Menge (Verkehrsaufkommen) / Steueraufkommen) — nach den Nomen 2026-10-19
  'Auflage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Buchauflage / Bedingung, Vorschrift / Unterlage, Polster) — nach den Nomen 2026-10-19
  'Aufmerksamkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Konzentration / kleines Geschenk, Gefälligkeit) — nach den Nomen 2026-10-19
  'Aufnahme', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Foto, Tonaufnahme / Aufnahme in eine Gruppe, ins Krankenhaus / Beginn / Empfang (Rezeption)) — nach den Nomen 2026-10-19
  'Aufruf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: öffentlicher Appell / Namensaufruf / IT: Funktionsaufruf) — nach den Nomen 2026-10-19
  'Aufruhr', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufstand / innere Erregung) — nach den Nomen 2026-10-19
  'Aufsatz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schulaufsatz, Fachartikel / aufgesetzter Teil (Möbel)) — nach den Nomen 2026-10-19
  'Aufschlag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Preisaufschlag / Tennis: Aufschlag / Aufprall / Ärmel- oder Hosenaufschlag) — nach den Nomen 2026-10-19
  'Aufschluss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufklärung, Information / Geologie: Aufschluss) — nach den Nomen 2026-10-19
  'Aufschwung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: wirtschaftlicher Aufschwung / Turnen: Aufschwung) — nach den Nomen 2026-10-19
  'Aufsicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beaufsichtigung / aufsichtführende Person) — nach den Nomen 2026-10-19
  'Aufsichtsrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gremium / Mitglied des Gremiums) — nach den Nomen 2026-10-19
  'Aufsichtsratsvorsitzende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Aufsichtsratsvorsitzende) — nach den Nomen 2026-10-19
  'Aufsichtsratsvorsitzender', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (starke Form von «Aufsichtsratsvorsitzende»; mit der Grundform zusammen behandeln) — nach den Nomen 2026-10-19
  'Aufsteiger', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: sozialer Aufsteiger / Sport: aufgestiegene Mannschaft) — nach den Nomen 2026-10-19
  'Aufstellung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Liste / Mannschaftsaufstellung / Errichtung, Aufstellen) — nach den Nomen 2026-10-19
  'Aufstieg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bergaufstieg / beruflicher oder sportlicher Aufstieg) — nach den Nomen 2026-10-19
  'Auftakt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beginn / Musik: Auftakt) — nach den Nomen 2026-10-19
  'Audit', // zurückgestellt: Genus schwankt (das/der Audit) — nicht sicher (Regel 14) 2026-10-19
  'Aufheben', // zurückgestellt: nur in Wendungen («viel Aufheben(s) machen») — als eigenes Nomen nicht sicher (Regel 14) 2026-10-19
  'Auftrag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bestellung / Aufgabe, Mission / Auftragen von Farbe) — nach den Nomen 2026-10-19
  'Auftreten', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Benehmen, Erscheinung / Vorkommen (Symptome)) — nach den Nomen 2026-10-19
  'Auftrieb', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: physikalischer Auftrieb / Schwung, Impuls / Almauftrieb) — nach den Nomen 2026-10-19
  'Auftritt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bühnenauftritt / Erscheinen, Benehmen / Internetauftritt) — nach den Nomen 2026-10-19
  'Aufweichung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Weichwerden / Lockerung von Regeln) — nach den Nomen 2026-10-19
  'Aufwertung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wertsteigerung, Aufwertung eines Viertels / Währungsaufwertung) — nach den Nomen 2026-10-19
  'Aufwind', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: aufsteigende Luft / positiver Trend (übertragen)) — nach den Nomen 2026-10-19
  'Aufzeichnung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ton-/Videoaufzeichnung / Notizen (Plural)) — nach den Nomen 2026-10-19
  'Aufzug', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lift / Akt im Theater / Aufmachung (abwertend) / Umzug) — nach den Nomen 2026-10-19
  'Auge', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sehorgan / Punkt auf dem Würfel / Knospe) — nach den Nomen 2026-10-19
  'Augenschein', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anschein («dem Augenschein nach») / Besichtigung («in Augenschein nehmen»)) — nach den Nomen 2026-10-19
  'Aura', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausstrahlung / Medizin: Aura vor einem Anfall) — nach den Nomen 2026-10-19
  'Aus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: Aus (Spielfeld) / Ende («das Aus für ...»)) — nach den Nomen 2026-10-19
  'Ausarbeitung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Ausarbeiten / schriftliche Arbeit) — nach den Nomen 2026-10-19
  'Ausbau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erweiterung / Herausnehmen eines Teils) — nach den Nomen 2026-10-19
  'Ausbeutung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausnutzung von Menschen / Abbau von Bodenschätzen) — nach den Nomen 2026-10-19
  'Ausblick', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aussicht (Landschaft) / Prognose, Zukunftsaussicht) — nach den Nomen 2026-10-19
  'Ausbruch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Krankheits-/Kriegsausbruch / Vulkanausbruch / Flucht aus dem Gefängnis / Gefühlsausbruch) — nach den Nomen 2026-10-19
  'Ausdehnung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erweiterung / Größe, Umfang) — nach den Nomen 2026-10-19
  'Auseinandersetzung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Streit / gründliche Beschäftigung mit einem Thema) — nach den Nomen 2026-10-19
  'Ausfahrt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Autobahnausfahrt / Hofausfahrt / Spazierfahrt) — nach den Nomen 2026-10-19
  'Ausfall', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausfallen (Strom, Unterricht) / Verlust / Fechten: Ausfall) — nach den Nomen 2026-10-19
  'Ausgabe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geldausgabe / Buch-, Zeitungsausgabe / Ausgabestelle / Datenausgabe) — nach den Nomen 2026-10-19
  'Ausgang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tür zum Hinausgehen / Ergebnis, Ende / Freizeit (Ausgang haben)) — nach den Nomen 2026-10-19
  'Ausgleich', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausgleich, Balance / Entschädigung / Sport: Ausgleichstor) — nach den Nomen 2026-10-19
  'Aushilfe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: vorübergehende Hilfe / Aushilfskraft (Person)) — nach den Nomen 2026-10-19
  'Auskommen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ausreichender Lebensunterhalt / «mit jemandem ist kein Auskommen») — nach den Nomen 2026-10-19
  'Auskunft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Information / Auskunftsschalter, Telefonauskunft) — nach den Nomen 2026-10-19
  'Auslage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schaufensterauslage / Kosten, Spesen (Plural)) — nach den Nomen 2026-10-19
  'Auslauf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bewegungsfreiheit (Tiere) / Abfluss, Mündung / Sport: Auslaufzone) — nach den Nomen 2026-10-19
  'Auslegung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Interpretation / technische Dimensionierung) — nach den Nomen 2026-10-19
  'Ausleihe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Ausleihen / Ausleihschalter in der Bibliothek) — nach den Nomen 2026-10-19
  'Aufwartung', // zurückgestellt: gehoben/veraltend, nur in «seine Aufwartung machen» — nicht sicher (Regel 14/17) 2026-10-19
  'Auslese', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Auswahl der Besten / Prädikatswein «Auslese») — nach den Nomen 2026-10-20
  'Auslieferung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lieferung von Waren / Übergabe eines Verdächtigen an einen anderen Staat) — nach den Nomen 2026-10-20
  'Ausnahmezustand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Notstand (Politik) / außergewöhnliche Lage (übertragen)) — nach den Nomen 2026-10-20
  'Ausnutzung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nutzung, Ausschöpfung / Ausnutzen einer Person) — nach den Nomen 2026-10-20
  'Ausrichtung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Orientierung, Ausrichten / Veranstaltung eines Festes / politische Richtung) — nach den Nomen 2026-10-20
  'Ausruf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kurzer Ruf, Äußerung / öffentliche Bekanntmachung) — nach den Nomen 2026-10-20
  'Ausrutscher', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausrutschen / Fehltritt, peinlicher Fehler / unerwartete Niederlage (Sport)) — nach den Nomen 2026-10-20
  'Aussage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mitteilung / Zeugenaussage vor Gericht / Gehalt eines Kunstwerks) — nach den Nomen 2026-10-20
  'Ausscheidung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausscheiden von Stoffen (Körper) / Sport: Ausscheidungsrunde) — nach den Nomen 2026-10-20
  'Ausschlag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hautausschlag / Ausschlag eines Zeigers; «den Ausschlag geben») — nach den Nomen 2026-10-20
  'Ausschnitt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Teil, Auszug / Zeitungsausschnitt / Halsausschnitt) — nach den Nomen 2026-10-20
  'Ausschuss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kommission, Gremium / fehlerhafte Ware) — nach den Nomen 2026-10-20
  'Ausschussvorsitzende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Ausschussvorsitzende) — nach den Nomen 2026-10-20
  'Aussendung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aussenden von Personen / Ausstrahlung einer Sendung / österr.: Presseaussendung) — nach den Nomen 2026-10-20
  'Aussetzung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Unterbrechung, Aufschub (Strafe zur Bewährung) / Aussetzen eines Kindes oder Tieres) — nach den Nomen 2026-10-20
  'Aussicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Blick, Ausblick / Chance, Zukunftsperspektive) — nach den Nomen 2026-10-20
  'Aussprache', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lautung / klärendes Gespräch) — nach den Nomen 2026-10-20
  'Ausstand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Streik / Abschiedsfeier beim Verlassen einer Stelle) — nach den Nomen 2026-10-20
  'Aussteller', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Firma auf einer Messe / ausstellende Stelle eines Dokuments) — nach den Nomen 2026-10-20
  'Ausstellung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kunst-/Messeausstellung / Ausstellen eines Dokuments) — nach den Nomen 2026-10-20
  'Ausstieg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tür zum Aussteigen / Aufgabe einer Tätigkeit, Atomausstieg) — nach den Nomen 2026-10-20
  'Ausstrahlung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sendung im Fernsehen/Radio / Charisma / Ausstrahlen von Schmerz) — nach den Nomen 2026-10-20
  'Austausch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gedanken-/Schüleraustausch / Ersetzen von Teilen) — nach den Nomen 2026-10-20
  'Austragung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Veranstaltung eines Wettkampfs / Austragen eines Streits / Austragen einer Schwangerschaft) — nach den Nomen 2026-10-20
  'Austritt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verlassen einer Organisation / Austreten von Gas oder Flüssigkeit) — nach den Nomen 2026-10-20
  'Ausverkauf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Räumungsverkauf / Preisgabe von Werten (übertragen)) — nach den Nomen 2026-10-20
  'Auswahl', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wahl, Selektion / Angebot an Waren / Auswahlmannschaft) — nach den Nomen 2026-10-20
  'Ausweisung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abschiebung aus dem Land / Ausweisen eines Gebiets (z. B. Naturschutzgebiet)) — nach den Nomen 2026-10-20
  'Auswuchs', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wucherung / Übertreibung, Missstand (übertragen)) — nach den Nomen 2026-10-20
  'Auszeichnung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Preis, Ehrung / Preisauszeichnung von Waren) — nach den Nomen 2026-10-20
  'Auszeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: Time-out / Pause vom Alltag (übertragen)) — nach den Nomen 2026-10-20
  'Auszubildende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Auszubildende) — nach den Nomen 2026-10-20
  'Auszug', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Umzug aus einer Wohnung / Textauszug / Kontoauszug) — nach den Nomen 2026-10-20
  'Ausschau', // zurückgestellt: nur in der Wendung «Ausschau halten» — als eigenes Nomen nicht sicher (Regel 14) 2026-10-20
  'Austria', // zurückgestellt: lateinischer Name / Vereins- und Firmenname, kein gebräuchlicher deutscher geografischer Name — nicht sicher (Regel 18) 2026-10-20
  'Ausweiche', // zurückgestellt: selten, regional (Ausweichstelle) — Bedeutung/Gebrauch nicht sicher (Regel 14) 2026-10-20
  'Automat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verkaufs-/Spielautomat / selbsttätige Maschine allgemein) — nach den Nomen 2026-10-20
  'Automatik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Automatikgetriebe / automatische Steuerung, Selbstlauf) — nach den Nomen 2026-10-20
  'Automatismus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: selbsttätiger Mechanismus / unbewusste, automatische Handlung (Psychologie/Medizin)) — nach den Nomen 2026-10-20
  'Autonomie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: politische Selbstverwaltung / persönliche Unabhängigkeit / technisch: Reichweite (Akku)) — nach den Nomen 2026-10-20
  'Bachelor', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Studienabschluss / Person mit diesem Abschluss) — nach den Nomen 2026-10-20
  'Backen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2 (Homograph: das Backen «Zubereitung im Ofen» ↔ der Backen «Wange», regional) — nach den Nomen 2026-10-20
  'Bad', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Badezimmer / Baden, Wannenbad / Schwimmbad / Kurort) — nach den Nomen 2026-10-20
  'Baden', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2/3 (Homograph: das Baden «Schwimmen» ↔ Baden «Region, Städte Baden bei Wien / Baden (AG)») — nach den Nomen 2026-10-20
  'Bahn', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Eisenbahn, Zug / Fahrbahn, Spur / Umlaufbahn / Stoffbahn) — nach den Nomen 2026-10-20
  'Balanceakt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Akrobatik auf dem Seil / schwieriger Ausgleich (übertragen)) — nach den Nomen 2026-10-20
  'Balken', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Holz-/Stahlträger / Strich, Balken im Diagramm) — nach den Nomen 2026-10-20
  'Ballast', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gewicht zum Ausbalancieren (Schiff, Ballon) / unnötige Last (übertragen)) — nach den Nomen 2026-10-20
  'Ballon', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Luftballon / Heißluftballon / bauchige Glasflasche) — nach den Nomen 2026-10-20
  'Balsam', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Heilsalbe, Pflegemittel / Trost, Wohltat (übertragen)) — nach den Nomen 2026-10-20
  'Bandbreite', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Technik: Datenrate, Frequenzbereich / Spannweite, Vielfalt) — nach den Nomen 2026-10-20
  'Ave', // zurückgestellt: nur als «Ave Maria» (Gebet) gebräuchlich — als eigenes Nomen nicht sicher (Regel 14) 2026-10-20
  'Azur', // zurückgestellt: dichterisch/gehoben für «Himmelsblau» — Markierung nicht sicher (Regel 14/17) 2026-10-20
  'Bader', // zurückgestellt: veraltet (Barbier, Wundarzt) — Ersatzwort nicht eindeutig (Regel 14/17) 2026-10-20
  'Ballhaus', // zurückgestellt: historisch: Ballspielhaus / Tanzlokal — Bedeutung nicht eindeutig (Regel 14) 2026-10-20
  'Bange', // zurückgestellt: nur in «keine Bange» (umgangssprachlich) — als eigenes Nomen nicht sicher (Regel 14) 2026-10-20
  'Bankangestellte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Bankangestellte) — nach den Nomen 2026-10-20
  'Bankrott', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zahlungsunfähigkeit / völliges Scheitern (übertragen, «moralischer Bankrott»)) — nach den Nomen 2026-10-20
  'Bann', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausschluss, Verbannung / Faszination, Zauber («im Bann von»)) — nach den Nomen 2026-10-20
  'Banner', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fahne, Spruchband / Werbebanner im Internet) — nach den Nomen 2026-10-20
  'Barbar', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fremder in der Antike / roher, grausamer Mensch (abwertend)) — nach den Nomen 2026-10-20
  'Barbarei', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Grausamkeit / Kulturlosigkeit) — nach den Nomen 2026-10-20
  'Bariton', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stimmlage / Sänger mit dieser Stimme) — nach den Nomen 2026-10-20
  'Bart', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Haare im Gesicht / Teil des Schlüssels) — nach den Nomen 2026-10-20
  'Basar', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: orientalischer Markt / Wohltätigkeitsbasar) — nach den Nomen 2026-10-20
  'Basis', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Grundlage / Militärstützpunkt / Parteibasis / Mathematik: Grundzahl) — nach den Nomen 2026-10-20
  'Basketball', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sportart / der Ball selbst) — nach den Nomen 2026-10-20
  'Bass', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: tiefe Stimme, Sänger / Bassgitarre, Kontrabass / tiefe Töne) — nach den Nomen 2026-10-20
  'Bassist', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sänger mit Bassstimme / Bassgitarrist) — nach den Nomen 2026-10-20
  'Bastard', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mischling (Biologie) / Schimpfwort; auch anstößig) — nach den Nomen 2026-10-20
  'Bastion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Festungsbau / Bollwerk, Hochburg (übertragen)) — nach den Nomen 2026-10-20
  'Batterie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stromspeicher / Militär: Geschützbatterie / Reihe gleicher Dinge) — nach den Nomen 2026-10-20
  'Batzen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Klumpen / große Menge Geld (umgangssprachlich)) — nach den Nomen 2026-10-20
  'Bau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Bauen / Gebäude / Tierbau / umgangssprachlich: Gefängnis) — nach den Nomen 2026-10-20
  'Banja', // zurückgestellt: russisches Dampfbad, Fremdwort — Gebrauch im Deutschen nicht sicher (Regel 14) 2026-10-20
  'Barbier', // zurückgestellt: Markierung unsicher (veraltet, heute als «Barber» wieder Mode) — nicht sicher (Regel 14/17) 2026-10-20
  'Barock', // zurückgestellt: Genus schwankt (der/das Barock) — nicht sicher (Regel 14) 2026-10-20
  'Barometer', // zurückgestellt: Genus schwankt (das/der Barometer) und übertragene Bedeutung — nicht sicher (Regel 14) 2026-10-20
  'Basso', // zurückgestellt: nur in Fachausdrücken (Basso continuo) — als eigenes Nomen nicht sicher (Regel 14) 2026-10-20
  'Bastille', // zurückgestellt: historisches Bauwerk (Eigenname), kein geografischer Name — nicht bauen (Regel 18) 2026-10-20
  'Bauhaus', // zurückgestellt: Eigenname (Kunstschule/Stil) bzw. Marke — nicht sicher (Regel 18) 2026-10-20
  'Baumeister', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Architekt/Bauunternehmer / Schöpfer (übertragen)) — nach den Nomen 2026-10-20
  'Bauplan', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Plan für ein Gebäude / Biologie: Grundbauplan eines Organismus) — nach den Nomen 2026-10-20
  'Baurecht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rechtsgebiet / Recht, ein Grundstück zu bebauen) — nach den Nomen 2026-10-20
  'Baustein', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stein zum Bauen / Spielzeugbaustein / Bestandteil (übertragen)) — nach den Nomen 2026-10-20
  'Beamter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der Beamte / ein Beamter) — nach den Nomen 2026-10-20
  'Bearbeitung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erledigung (Antrag) / Bearbeitung eines Werkes (Musik, Literatur) / Formgebung (Material)) — nach den Nomen 2026-10-20
  'Beauftragte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Beauftragte) — nach den Nomen 2026-10-20
  'Beauftragter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: stark gebeugte Form von «der Beauftragte») — nach den Nomen 2026-10-20
  'Becken', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Waschbecken/Schwimmbecken / Körperteil (Pelvis) / Musikinstrument) — nach den Nomen 2026-10-20
  'Bedenken', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Überlegung / meist Plural: Zweifel, Einwände) — nach den Nomen 2026-10-20
  'Bedeutung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sinn eines Wortes / Wichtigkeit) — nach den Nomen 2026-10-20
  'Bedienung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Bedienen (Service) / Kellner(in) / Handhabung einer Maschine) — nach den Nomen 2026-10-20
  'Befangenheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schüchternheit / Recht: Parteilichkeit) — nach den Nomen 2026-10-20
  'Befestigung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Festmachen / Festungsanlage) — nach den Nomen 2026-10-20
  'Befinden', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gesundheitszustand / gehoben: Meinung, Urteil) — nach den Nomen 2026-10-20
  'Befragte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Befragte) — nach den Nomen 2026-10-20
  'Befreiung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Freilassung, Erlösung / Freistellung (z. B. von Gebühren)) — nach den Nomen 2026-10-20
  'Befreiungsschlag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: Klärungsschlag / übertragen: Ausweg aus schwieriger Lage) — nach den Nomen 2026-10-20
  'Befriedigung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erfüllen (von Bedürfnissen, Forderungen) / Genugtuung, Zufriedenheit) — nach den Nomen 2026-10-20
  'Begegnung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Treffen / Sport: Spiel, Partie) — nach den Nomen 2026-10-20
  'Begehren', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verlangen, Wunsch / gehoben: Forderung, Ersuchen) — nach den Nomen 2026-10-20
  'Baumgarten', // zurückgestellt: landschaftlich (Obstgarten) und häufiger Familienname — nicht sicher (Regel 14) 2026-10-20
  'Bausch', // zurückgestellt: Plural schwankt (Bausche/Bäusche), meist nur in «in Bausch und Bogen» — nicht sicher (Regel 14) 2026-10-20
  'Bavaria', // zurückgestellt: Eigenname (Personifikation/Statue), kein geografischer Name — nicht bauen (Regel 18) 2026-10-20
  'Beach', // zurückgestellt: englisches Wort, als eigenes deutsches Nomen nicht sicher (Regel 14) 2026-10-20
  'Beamtenbund', // zurückgestellt: Eigenname einer Organisation (dbb) — nicht bauen (Regel 18) 2026-10-20
  'Beatle', // zurückgestellt: Personen-/Bandname — nicht bauen (Regel 18) 2026-10-20
  'Beauty', // zurückgestellt: englisches Wort, Gebrauch/Genus im Deutschen nicht sicher (Regel 14) 2026-10-20
  'Begehung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Besichtigung zu Fuß, Inspektion / das Begehen einer Tat oder eines Festes) — nach den Nomen 2026-10-20
  'Beginnen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Anfangen / gehoben: Vorhaben, Unterfangen) — nach den Nomen 2026-10-20
  'Begleiter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Person, die jemanden begleitet / Musik: Begleitmusiker) — nach den Nomen 2026-10-20
  'Begleiterin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Person, die jemanden begleitet / Musik: Begleitmusikerin) — nach den Nomen 2026-10-20
  'Begleitung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Begleiten / begleitende Person(en) / Musik: Begleitstimme) — nach den Nomen 2026-10-20
  'Behandlung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: medizinische Behandlung / Umgang mit jemandem / Bearbeitung eines Themas) — nach den Nomen 2026-10-20
  'Beherrschung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Herrschaft über etwas / Selbstbeherrschung / Können (einer Sprache)) — nach den Nomen 2026-10-20
  'Behinderte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Behinderte) — nach den Nomen 2026-10-20
  'Behinderung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beeinträchtigung (Körper, Geist) / Hindernis, z. B. im Verkehr) — nach den Nomen 2026-10-20
  'Beifall', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Applaus / Zustimmung) — nach den Nomen 2026-10-20
  'Beigeordnete', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Beigeordnete) — nach den Nomen 2026-10-20
  'Beigeschmack', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschmack (wörtlich) / übertragen: negativer Eindruck) — nach den Nomen 2026-10-20
  'Beihilfe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: finanzielle Unterstützung / Recht: Mithilfe an einer Straftat) — nach den Nomen 2026-10-20
  'Beilage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Speise neben dem Hauptgericht / Zeitungsbeilage) — nach den Nomen 2026-10-20
  'Beirat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: beratendes Gremium / Mitglied, Berater) — nach den Nomen 2026-10-20
  'Beistand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hilfe, Unterstützung / Person (Rechtsbeistand)) — nach den Nomen 2026-10-20
  'Beitrag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anteil, Mitwirkung / Mitgliedsbeitrag / Artikel, Sendung) — nach den Nomen 2026-10-20
  'Bekanntschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Bekanntsein / bekannte Person(en)) — nach den Nomen 2026-10-20
  'Bekenntnis', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geständnis, Eintreten für etwas / Konfession) — nach den Nomen 2026-10-20
  'Belag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schicht, Überzug / Brotbelag / Bremsbelag) — nach den Nomen 2026-10-20
  'Belang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wichtigkeit («von Belang») / Plural: Interessen («die Belange»)) — nach den Nomen 2026-10-20
  'Belastung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Last, Gewicht (Technik) / seelische Belastung / Kontobelastung) — nach den Nomen 2026-10-20
  'Belegung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Auslastung (Betten, Zimmer) / Kursbelegung) — nach den Nomen 2026-10-20
  'Bel', // zurückgestellt: Maßeinheit (Bel/Dezibel) — als eigenes Lernwort nicht sicher (Regel 14) 2026-10-20
  'Belvedere', // zurückgestellt: Aussichtspunkt bzw. Eigenname (Schloss in Wien), kein geografischer Name — nicht sicher (Regel 14/18) 2026-10-20
  'Benefiz', // zurückgestellt: fast nur in Zusammensetzungen (Benefizkonzert …); veraltete Bedeutung — allein nicht sicher (Regel 14) 2026-10-20
  'Bequemlichkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Komfort / Trägheit, Faulheit) — nach den Nomen 2026-10-20
  'Beratung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rat, Beratungsgespräch / Besprechung, Beratschlagung (z. B. im Parlament)) — nach den Nomen 2026-10-20
  'Berber', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Angehöriger eines Volkes in Nordafrika / Berberteppich / umgangssprachlich: Obdachloser) — nach den Nomen 2026-10-20
  'Berechnung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Ausrechnen / eigennütziges Kalkül («aus Berechnung»)) — nach den Nomen 2026-10-20
  'Berechtigung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Befugnis, Recht / Rechtmäßigkeit, Begründetheit) — nach den Nomen 2026-10-20
  'Bereicherung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gewinn, Gewinn an Erfahrung («eine Bereicherung für das Team») / unrechtmäßiges Sich-Bereichern) — nach den Nomen 2026-10-20
  'Bereitschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Willigkeit / Bereitschaftsdienst / Polizeieinheit) — nach den Nomen 2026-10-20
  'Berichterstatter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Reporter, Korrespondent / Referent eines Ausschusses) — nach den Nomen 2026-10-20
  'Berufung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Recht: Rechtsmittel / innerer Ruf (Lebensaufgabe) / Ernennung in ein Amt) — nach den Nomen 2026-10-20
  'Besatzung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mannschaft (Schiff, Flugzeug) / militärische Besetzung eines Landes) — nach den Nomen 2026-10-20
  'Bescherung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Weihnachtsgeschenke-Verteilung / ironisch: unangenehme Überraschung) — nach den Nomen 2026-10-20
  'Beschlag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Metallbeschlag / Feuchtigkeitsfilm auf Glas / Hufbeschlag; «in Beschlag nehmen») — nach den Nomen 2026-10-20
  'Beschneidung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zirkumzision / Kürzung, Einschränkung (von Rechten, Ästen)) — nach den Nomen 2026-10-20
  'Beschwerde', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Klage, Reklamation / Plural: körperliche Beschwerden) — nach den Nomen 2026-10-20
  'Besessenheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wahn, Obsession / religiös: Besessensein (von einem Dämon)) — nach den Nomen 2026-10-20
  'Besetzung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Besetzen (Haus, Land) / Rollenbesetzung (Theater, Film) / Mannschaftsaufstellung, Stellenbesetzung) — nach den Nomen 2026-10-20
  'Besinnung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bewusstsein («die Besinnung verlieren») / Nachdenken, innere Einkehr) — nach den Nomen 2026-10-20
  'Besprechung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sitzung, Meeting / Rezension (Buchbesprechung)) — nach den Nomen 2026-10-20
  'Bestand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fortbestehen, Dauer / Vorrat, Lagerbestand) — nach den Nomen 2026-10-20
  'Bestehen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Existenz («seit Bestehen») / das Bestehen einer Prüfung) — nach den Nomen 2026-10-20
  'Bestellung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Auftrag, Order / Ernennung (eines Vormunds) / Bestellen des Feldes) — nach den Nomen 2026-10-20
  'Bestimmung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorschrift, Regelung / Festlegung, Ermittlung / Schicksal, Zweck) — nach den Nomen 2026-10-20
  'Besuch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Besuchen / Gast, Gäste («wir haben Besuch»)) — nach den Nomen 2026-10-20
  'Beta', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: griechischer Buchstabe / Testversion (Software)) — nach den Nomen 2026-10-20
  'Beteiligte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Beteiligte) — nach den Nomen 2026-10-20
  'Beteiligung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Teilnahme / Kapitalanteil an einer Firma) — nach den Nomen 2026-10-20
  'Betrachtung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anschauen / Überlegung, Erörterung) — nach den Nomen 2026-10-20
  'Betreuer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Person, die betreut (Kinder, Kranke) / Recht: gerichtlich bestellter Betreuer (Erwachsenenvertreter)) — nach den Nomen 2026-10-20
  'Betreuerin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Person, die betreut / Recht: gerichtlich bestellte Betreuerin) — nach den Nomen 2026-10-20
  'Betrieb', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Firma, Unternehmen / Betriebszustand («in Betrieb») / Treiben, Andrang) — nach den Nomen 2026-10-20
  'Betriebsrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gremium der Arbeitnehmervertretung / einzelnes Mitglied dieses Gremiums) — nach den Nomen 2026-10-20
  'Betriebsratsvorsitzende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Betriebsratsvorsitzende) — nach den Nomen 2026-10-20
  'Betriebsratsvorsitzender', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: stark gebeugte Form von «der Betriebsratsvorsitzende») — nach den Nomen 2026-10-20
  'Betroffene', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Betroffene) — nach den Nomen 2026-10-20
  'Betroffener', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: stark gebeugte Form von «der Betroffene») — nach den Nomen 2026-10-20
  'Best', // zurückgestellt: als eigenes Nomen nicht sicher (nur «das Beste», «sein Bestes») (Regel 14) 2026-10-20
  'Bete', // zurückgestellt: fast nur in «Rote Bete» — als eigenes Nomen nicht sicher (Regel 14) 2026-10-20
  'Bettag', // zurückgestellt: fast nur in «Buß- und Bettag» / «Eidgenössischer Bettag» (Feiertagsname) — nicht sicher (Regel 14) 2026-10-20
  'Bettel', // zurückgestellt: umgangssprachlich/veraltend (Kram; «den Bettel hinwerfen») — nicht sicher (Regel 14) 2026-10-20
  'Bewegung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: körperliche Bewegung / politische oder soziale Bewegung / innere Bewegung, Rührung) — nach den Nomen 2026-10-20
  'Bewusstsein', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zustand des Wachseins («das Bewusstsein verlieren») / Wissen, Bewusstheit («Umweltbewusstsein»)) — nach den Nomen 2026-10-20
  'Beziehung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Liebesbeziehung, Partnerschaft / Verbindung, Zusammenhang / Plural: Kontakte («Beziehungen haben»)) — nach den Nomen 2026-10-20
  'Bezirksrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gremium eines Bezirks / einzelnes Mitglied dieses Gremiums) — nach den Nomen 2026-10-20
  'Bezirksverordnete', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Bezirksverordnete) — nach den Nomen 2026-10-20
  'Bezirksvorsitzende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Bezirksvorsitzende) — nach den Nomen 2026-10-20
  'Bezug', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Überzug (Kissenbezug) / Bezugnahme («in Bezug auf») / Erwerb, Erhalt; Plural: Gehalt («Bezüge»)) — nach den Nomen 2026-10-20
  'Biedermann', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: veraltet: rechtschaffener Mann / abwertend: Spießer) — nach den Nomen 2026-10-20
  'Bilanz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wirtschaft: Gegenüberstellung von Vermögen und Kapital / Ergebnis, Fazit («Bilanz ziehen»)) — nach den Nomen 2026-10-20
  'Bildung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erziehung, Wissen / Entstehung, Formung (Wortbildung, Bildung einer Regierung)) — nach den Nomen 2026-10-20
  'Bezirksbeirat', // zurückgestellt: regionales Gremium einzelner deutscher Städte — als allgemeines Lernwort nicht sicher (Regel 14) 2026-10-20
  'Bezirksklasse', // zurückgestellt: regionale Sportliga in Deutschland — als Lernwort nicht sicher (Regel 14) 2026-10-20
  'Bibi', // zurückgestellt: umgangssprachlich (Kopfbedeckung bzw. Kosename) — Bedeutung nicht sicher (Regel 14) 2026-10-20
  'Binde', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verband, Armbinde / Damenbinde / Augenbinde) — nach den Nomen 2026-10-20
  'Binder', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: österr.: Krawatte / Bauwesen: Träger / Bindemittel; Buchbinder) — nach den Nomen 2026-10-20
  'Bindung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: emotionale Bindung / Skibindung / chemische Bindung; Verpflichtung) — nach den Nomen 2026-10-20
  'Bitterkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: bitterer Geschmack / Verbitterung, seelischer Schmerz) — nach den Nomen 2026-10-20
  'Blackout', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stromausfall / Gedächtnisaussetzer, Filmriss) — nach den Nomen 2026-10-20
  'Blase', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Luftblase / Harnblase / Hautblase) — nach den Nomen 2026-10-20
  'Blatt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pflanzenblatt / Blatt Papier / Zeitung («das Blatt»); Spielkarten) — nach den Nomen 2026-10-20
  'Blech', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Metallblech / Backblech / umgangssprachlich: Unsinn («Red kein Blech»)) — nach den Nomen 2026-10-20
  'Blitz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wetterblitz / Kamerablitz / Radarfalle («geblitzt werden»)) — nach den Nomen 2026-10-20
  'Block', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Klotz / Notizblock / Häuserblock / politischer Block) — nach den Nomen 2026-10-20
  'Boden', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fußboden / Erdboden, Erde / Dachboden / Grund eines Gefäßes) — nach den Nomen 2026-10-20
  'Bodenhaftung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Haftung von Reifen auf der Straße / übertragen: Realitätssinn) — nach den Nomen 2026-10-20
  'Binge', // zurückgestellt: fachsprachlich/Bergbau bzw. Anglizismus — Bedeutung als Lernwort nicht sicher (Regel 14) 2026-10-20
  'Bleiche', // zurückgestellt: veraltet (Rasenbleiche) bzw. selten — als Lernwort nicht sicher (Regel 14) 2026-10-20
  'Blocher', // zurückgestellt: schweizerisch: Bohnermaschine bzw. Familienname — nicht sicher (Regel 14) 2026-10-20
  'Bobby', // zurückgestellt: englisch: britischer Polizist — im Deutschen selten, nicht sicher (Regel 14) 2026-10-20
  'Bobo', // zurückgestellt: Szenewort (Bourgeois-Bohème, v. a. Wien) — Gebrauch nicht sicher (Regel 14) 2026-10-20
  'Body', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bodysuit (Kleidungsstück) / umgangssprachlich: Körper) — nach den Nomen 2026-10-20
  'Bogen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Krümmung, Kurve / Waffe (Pfeil und Bogen) / Blatt Papier; Geigenbogen; Architektur: Torbogen) — nach den Nomen 2026-10-20
  'Bolid', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rennwagen / Astronomie: Feuerkugel, Meteor) — nach den Nomen 2026-10-20
  'Bomber', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bombenflugzeug / Person, die Bomben legt; Sport: Torjäger) — nach den Nomen 2026-10-20
  'Botschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nachricht, Mitteilung / diplomatische Vertretung (Gebäude, Behörde)) — nach den Nomen 2026-10-20
  'Boulevard', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: breite Prachtstraße / Boulevardpresse) — nach den Nomen 2026-10-20
  'Box', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kiste, Behälter / Lautsprecher / Boxengasse (Motorsport); Pferdebox) — nach den Nomen 2026-10-20
  'Boxer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sportler (Faustkampf) / Hunderasse / Unterhose (Boxershorts)) — nach den Nomen 2026-10-20
  'Brauner', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: stark gebeugte Form von «der Braune» (österr.: Kaffee mit Milch; braunes Pferd)) — nach den Nomen 2026-10-20
  'Brause', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Brausepulver, Limonade / Duschkopf, Brausekopf) — nach den Nomen 2026-10-20
  'Breite', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausdehnung in die Breite / geografische Breite) — nach den Nomen 2026-10-20
  'Born', // zurückgestellt: dichterisch: Quelle, Brunnen — als Lernwort nicht sicher (Regel 14) 2026-10-20
  'Borussia', // zurückgestellt: lateinischer Name für Preußen bzw. Vereinsname — kein allgemeines Lernwort (Regel 14/18) 2026-10-20
  'Boy', // zurückgestellt: Anglizismus (Hotelboy, umgangssprachlich: Junge) — Gebrauch nicht sicher (Regel 14) 2026-10-20
  'Breche', // zurückgestellt: landwirtschaftliches Gerät (Flachsbreche) — selten, nicht sicher (Regel 14) 2026-10-20
  'Bremser', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bremser bei der Bahn / übertragen: jemand, der Fortschritt bremst; Bobsport: Bremser) — nach den Nomen 2026-10-20
  'Bruder', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschwister / Ordensbruder, Mönch) — nach den Nomen 2026-10-20
  'Brut', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nachwuchs (Vögel, Fische) / abwertend: Gesindel) — nach den Nomen 2026-10-20
  'Bube', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spielkarte / veraltet: Junge / Schurke («Spitzbube»)) — nach den Nomen 2026-10-20
  'Buchenwald', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wald aus Buchen / ehemaliges Konzentrationslager (Eigenname)) — nach den Nomen 2026-10-20
  'Buckel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: umgangssprachlich: Rücken / Höcker, Buckel (Krankheit) / kleine Anhöhe) — nach den Nomen 2026-10-20
  'Bude', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verkaufsstand, Kiosk / umgangssprachlich: Zimmer, Wohnung) — nach den Nomen 2026-10-20
  'Breton', // zurückgestellt: Hutform bzw. Personenname (André Breton) — als Lernwort nicht sicher (Regel 14) 2026-10-20
  'Brill', // zurückgestellt: Fischart (Glattbutt) — sehr selten, nicht sicher (Regel 14) 2026-10-20
  'Brink', // zurückgestellt: norddeutsch/regional: Anhöhe, Grasrain — nicht sicher (Regel 14) 2026-10-20
  'Brunn', // zurückgestellt: veraltet/dichterisch für Brunnen bzw. Ortsnamenteil — nicht sicher (Regel 14) 2026-10-20
  'Bubi', // zurückgestellt: umgangssprachlich/abwertend: Junge, Milchbubi — Gebrauch nicht sicher (Regel 14) 2026-10-20
  'Buchs', // zurückgestellt: Buchsbaum (meist «Buchsbaum») bzw. Ortsname in der Schweiz — nicht sicher (Regel 14/18) 2026-10-20
  'Bundesrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Länderkammer (D, Ö) bzw. Regierung (CH) / Mitglied dieses Organs (CH, Ö: «ein Bundesrat»)) — nach den Nomen 2026-10-21
  'Bundesstaat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Staat aus mehreren Ländern (Föderation) / Gliedstaat eines Bundesstaates (z. B. US-Bundesstaat)) — nach den Nomen 2026-10-21
  'Bundestagsabgeordnete', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Bundestagsabgeordnete) — nach den Nomen 2026-10-21
  'Bundestagsabgeordneter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: stark gebeugte Form von «der Bundestagsabgeordnete») — nach den Nomen 2026-10-21
  'Bundesvorsitzende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Bundesvorsitzende) — nach den Nomen 2026-10-21
  'Bundesvorsitzender', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: stark gebeugte Form von «der Bundesvorsitzende») — nach den Nomen 2026-10-21
  'Bunker', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schutzraum / Behälter für Kohle, Getreide / Golf: Sandhindernis) — nach den Nomen 2026-10-21
  'Burg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Festung, Schloss / Strandburg (Sandwall) / Jägersprache: Biberbau) — nach den Nomen 2026-10-21
  'Bursch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen wie «Bursche»: junger Mann / Laufbursche, Gehilfe / Mitglied einer Burschenschaft; v. a. österr./südd. Form) — nach den Nomen 2026-10-21
  'Bursche', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: junger Mann / Laufbursche, Gehilfe / Mitglied einer Burschenschaft / ugs.: großes Exemplar) — nach den Nomen 2026-10-21
  'Bungee', // zurückgestellt: als selbständiges Nomen nicht gesichert (gebräuchlich: «Bungeejumping», «Bungeespringen») — nicht sicher (Regel 14) 2026-10-21
  'Bureau', // zurückgestellt: veraltete bzw. schweizerische Schreibung von «Büro» — Gebrauch/Einordnung nicht sicher (Regel 14) 2026-10-21
  'Bus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 3 (Homograph, gleicher Artikel: der Bus «Omnibus» / der Bus «EDV: Datenleitung») — nach den Nomen 2026-10-21
  'Busen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: weibliche Brust / gehoben: Inneres, Herz; Meeresbucht («Meerbusen»)) — nach den Nomen 2026-10-21
  'Butterfly', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schmetterlingsschwimmen / Sprung beim Eiskunstlauf) — nach den Nomen 2026-10-21
  'Button', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anstecker, Abzeichen / Schaltfläche (EDV)) — nach den Nomen 2026-10-21
  'Bypass', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Medizin: Umgehungsgefäß, Bypassoperation / Technik: Umgehungsleitung) — nach den Nomen 2026-10-21
  'Camper', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: jemand, der campt / ugs.: Wohnmobil) — nach den Nomen 2026-10-21
  'Caravan', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wohnwagen / Kombiwagen) — nach den Nomen 2026-10-21
  'Caritas', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nächstenliebe / Hilfsorganisation (Eigenname)) — nach den Nomen 2026-10-21
  'Carrier', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Flugzeugträger / Fluggesellschaft, Transportunternehmen / Telefonanbieter) — nach den Nomen 2026-10-21
  'Casino', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spielbank / Speiseraum, Kantine (z. B. Offizierskasino)) — nach den Nomen 2026-10-21
  'Chaot', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: unordentlicher Mensch / abwertend: politischer Randalierer) — nach den Nomen 2026-10-21
  'Charakter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wesen, Eigenart / Person, Figur / Schriftzeichen) — nach den Nomen 2026-10-21
  'Charge', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Dienstgrad, Rang / Produktionsserie (Pharma) / Nebenrolle (Theater)) — nach den Nomen 2026-10-21
  'Chart', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schaubild, Grafik / die Charts: Hitliste) — nach den Nomen 2026-10-21
  'Charter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Chartervertrag, Miete eines Fahrzeugs / Urkunde, Freibrief) — nach den Nomen 2026-10-21
  'Bye', // zurückgestellt: als deutsches Nomen nicht gesichert (Sport: Freilos?) — nicht sicher (Regel 14) 2026-10-21
  'Cafe', // zurückgestellt: Schreibung «Cafe» statt «Café» — Lemma/id nicht sicher (Regel 14) 2026-10-21
  'Carol', // zurückgestellt: als deutsches Nomen nicht gesichert (engl. «Christmas carol»?) — nicht sicher (Regel 14) 2026-10-21
  'Castle', // zurückgestellt: englisches Wort, kein gesichertes deutsches Nomen — nicht sicher (Regel 14) 2026-10-21
  'Celsius', // zurückgestellt: Einheit/Personenname («Grad Celsius»), Genus/Gebrauch als Nomen nicht sicher (Regel 14/18) 2026-10-21
  'Chase', // zurückgestellt: als deutsches Nomen nicht gesichert — nicht sicher (Regel 14) 2026-10-21
  'Chief', // zurückgestellt: als deutsches Nomen nicht gesichert (engl. «Chef») — nicht sicher (Regel 14) 2026-10-21
  'Chiffre', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geheimzeichen, Code / Kennziffer einer Zeitungsanzeige) — nach den Nomen 2026-10-21
  'Chili', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schote, Gewürz / Gericht «Chili con Carne») — nach den Nomen 2026-10-21
  'Chinese', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einwohner Chinas / ugs.: chinesisches Restaurant («zum Chinesen gehen»)) — nach den Nomen 2026-10-21
  'Chip', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mikrochip / Kartoffelchip / Spielmarke) — nach den Nomen 2026-10-21
  'Choral', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: gregorianischer Gesang / Kirchenlied) — nach den Nomen 2026-10-21
  'Christkind', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Jesuskind / Gabenbringer zu Weihnachten (bes. Österreich, Süddeutschland)) — nach den Nomen 2026-10-21
  'Claim', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Werbeslogan / Anspruch, Rechtsanspruch (z. B. Goldgräber)) — nach den Nomen 2026-10-21
  'Clinch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Boxen: Umklammerung / Streit («im Clinch liegen»)) — nach den Nomen 2026-10-21
  'Coca', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kokastrauch / ugs.: Coca-Cola) — nach den Nomen 2026-10-21
  'Code', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geheimschlüssel, Zugangscode / Zeichensystem; Programmcode / Verhaltenskodex) — nach den Nomen 2026-10-21
  'Controller', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fachmann für Controlling (Beruf) / Steuergerät, Spielkonsolen-Controller) — nach den Nomen 2026-10-21
  'Corner', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: österr./schweiz. Sport: Eckball / Boxen: Ringecke / Börse: Aufkauf) — nach den Nomen 2026-10-21
  'Couleur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Art, Richtung («jeder Couleur») / Farben einer Studentenverbindung) — nach den Nomen 2026-10-21
  'Cover', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Titelbild, Plattenhülle / Coverversion) — nach den Nomen 2026-10-21
  'Crash', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Unfall, Zusammenstoß / Börsenkrach / Computerabsturz) — nach den Nomen 2026-10-21
  'Credo', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Glaubensbekenntnis (Religion) / Grundsatz, Überzeugung) — nach den Nomen 2026-10-21
  'Colonia', // zurückgestellt: lateinischer Name (Köln u. a.), kein gesichertes deutsches Nomen (Regel 14/18) 2026-10-21
  'Colorado', // zurückgestellt: Fluss (der Colorado) oder US-Bundesstaat — Genus/Artikel nicht eindeutig (Regel 14/18) 2026-10-21
  'Columbia', // zurückgestellt: Name (Universität, Fluss, Bezirk …) — kein gesichertes Lernwort (Regel 14/18) 2026-10-21
  'Committee', // zurückgestellt: englisches Wort, kein gesichertes deutsches Nomen (Regel 14) 2026-10-21
  'Compagnie', // zurückgestellt: veraltete Schreibung von «Kompanie»/«Kompagnie» — nicht sicher (Regel 14) 2026-10-21
  'Corpus', // zurückgestellt: Schreibung/Bedeutung unsicher (Korpus: Textsammlung, Möbelkörper, Corpus Christi …) (Regel 14) 2026-10-21
  'County', // zurückgestellt: englisches Verwaltungswort (Grafschaft in GB/USA) — als deutsches Nomen nicht gesichert (Regel 14) 2026-10-21
  'Court', // zurückgestellt: Tennisplatz (Fachsprache) — Gebrauch/Genus nicht sicher (Regel 14) 2026-10-21
  'Couture', // zurückgestellt: meist nur in «Haute Couture» — als selbständiges Nomen nicht sicher (Regel 14) 2026-10-21
  'Cox', // zurückgestellt: Apfelsorte (Cox Orange) bzw. Personenname — nicht sicher (Regel 14) 2026-10-21
  'Creek', // zurückgestellt: englisches Wort (Bach), kein gesichertes deutsches Nomen (Regel 14) 2026-10-21
  'Cuba', // zurückgestellt: englische/spanische Schreibung von «Kuba» — Lemma nicht sicher (Regel 14/18) 2026-10-21
  'Cup', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pokal, Pokalwettbewerb / Körbchen des Büstenhalters) — nach den Nomen 2026-10-21
  'Curry', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gewürzmischung / Gericht mit Currysoße) — nach den Nomen 2026-10-21
  'Cut', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Filmschnitt / Schnittwunde (Boxen) / Herrenrock «Cutaway») — nach den Nomen 2026-10-21
  'Damm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Staudamm, Erdwall / Bahn-, Straßendamm / Anatomie: Bereich zwischen After und Genitalien) — nach den Nomen 2026-10-21
  'Darm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verdauungsorgan / Wursthaut (Natur- bzw. Kunstdarm)) — nach den Nomen 2026-10-21
  'Darstellung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abbildung, Grafik / Schilderung, Beschreibung / Verkörperung einer Rolle) — nach den Nomen 2026-10-21
  'Datenschutzbeauftragter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Partizip: der/die Datenschutzbeauftragte) — nach den Nomen 2026-10-21
  'Dauerbrenner', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ofen, der lange brennt / ugs.: lange erfolgreiche Sache, Dauerthema) — nach den Nomen 2026-10-21
  'Dealer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Drogenhändler / Kartengeber im Casino; Händler) — nach den Nomen 2026-10-21
  'Decke', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bett-, Tischdecke / Zimmerdecke) — nach den Nomen 2026-10-21
  'Deckung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schutz (in Deckung gehen) / finanzielle Absicherung / Sport: Abwehr) — nach den Nomen 2026-10-21
  'Defizit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fehlbetrag (Haushalt) / Mangel (z. B. Vitamindefizit)) — nach den Nomen 2026-10-21
  'Dekan', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Leiter einer Fakultät / kirchliches Amt (Dechant)) — nach den Nomen 2026-10-21
  'Deklaration', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erklärung (z. B. der Menschenrechte) / Zoll-, Inhaltsangabe) — nach den Nomen 2026-10-21
  'Delphin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Meeressäugetier / Schwimmstil «Delphinschwimmen») — nach den Nomen 2026-10-21
  'Dada', // zurückgestellt: Kunstrichtung, meist «Dadaismus» — als selbständiges Lernwort nicht sicher (Regel 14) 2026-10-21
  'Dagestan', // zurückgestellt: Name einer russischen Teilrepublik — Genus/Artikel nicht sicher (Regel 14/18) 2026-10-21
  'Damian', // zurückgestellt: Vorname — kein Lernwort (Regel 14/18) 2026-10-21
  'Dan', // zurückgestellt: Rang im Budo (Judo, Karate) — Plural/Gebrauch nicht sicher (Regel 14) 2026-10-21
  'Dancing', // zurückgestellt: veraltend/schweizerisch für Tanzlokal — Gebrauch nicht sicher (Regel 14) 2026-10-21
  'Demonstration', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kundgebung, Protestmarsch / Vorführung, Beweis (z. B. «Demonstration der Stärke»)) — nach den Nomen 2026-10-21
  'Demontage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abbau einer Anlage / übertragen: schrittweise Zerstörung, z. B. eines Politikers) — nach den Nomen 2026-10-21
  'Departement', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ministerium in der Schweiz / Verwaltungsbezirk in Frankreich) — nach den Nomen 2026-10-21
  'Depot', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lager, Aufbewahrungsort / Wertpapierdepot / Betriebshof für Busse, Straßenbahnen) — nach den Nomen 2026-10-21
  'Depression', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: psychische Krankheit / wirtschaftlicher Abschwung / Meteorologie: Tief) — nach den Nomen 2026-10-21
  'Derivat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Chemie: abgeleitete Verbindung / Finanzen: Finanzinstrument / Sprache: abgeleitetes Wort) — nach den Nomen 2026-10-21
  'Desktop', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bildschirmoberfläche / Desktop-Computer) — nach den Nomen 2026-10-21
  'Deutscher', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: stark gebeugte Form von «der Deutsche») — nach den Nomen 2026-10-21
  'Devise', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wahlspruch, Motto / Plural «Devisen»: ausländische Zahlungsmittel) — nach den Nomen 2026-10-21
  'Diakonie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kirchlicher Sozialdienst / Name der evangelischen Hilfsorganisation) — nach den Nomen 2026-10-21
  'Diener', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bediensteter / ugs.: Verbeugung («einen Diener machen»)) — nach den Nomen 2026-10-21
  'Dienst', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Arbeit, Schicht («Dienst haben») / Hilfe, Gefallen / Behörde, Einrichtung (z. B. Geheimdienst)) — nach den Nomen 2026-10-21
  'Demos', // zurückgestellt: griechisch «Volk», Fachwort — Abgrenzung zu «die Demo» (Plural Demos) nicht sicher (Regel 14) 2026-10-21
  'Deutschlandfunk', // zurückgestellt: Name eines Radiosenders — kein Lernwort (Regel 14/18) 2026-10-21
  'Dienstzeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Arbeitszeit, Dienststunden / Dauer der Beschäftigung, Dienstjahre) — nach den Nomen 2026-10-21
  'Diesel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kraftstoff / Dieselmotor / Auto mit Dieselmotor) — nach den Nomen 2026-10-21
  'Differenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Unterschied, Rechenergebnis / Plural: Meinungsverschiedenheiten) — nach den Nomen 2026-10-21
  'Diktat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schreibübung in der Schule / Text zum Mitschreiben / aufgezwungene Bedingung («Diktat der Sieger»)) — nach den Nomen 2026-10-21
  'Dimension', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausdehnung (Länge, Breite, Höhe) / Ausmaß, Größenordnung) — nach den Nomen 2026-10-21
  'Ding', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sache, Gegenstand / ugs.: junges Mädchen («ein junges Ding»)) — nach den Nomen 2026-10-21
  'Dino', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. Dinosaurier / übertragen: etwas Veraltetes) — nach den Nomen 2026-10-21
  'Dinosaurier', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ausgestorbenes Reptil / übertragen: etwas Veraltetes, Rückständiges) — nach den Nomen 2026-10-21
  'Diplomatie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Außenpolitik, diplomatischer Dienst / Geschick im Umgang («mit Diplomatie»)) — nach den Nomen 2026-10-21
  'Discount', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verkauf mit Preisnachlass / Discountgeschäft) — nach den Nomen 2026-10-21
  'Diskothek', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tanzlokal / Sammlung von Schallplatten) — nach den Nomen 2026-10-21
  'Disposition', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verfügung, Planung («zur Disposition stehen») / Medizin: Veranlagung) — nach den Nomen 2026-10-21
  'Dissonanz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musik: Missklang / übertragen: Unstimmigkeit) — nach den Nomen 2026-10-21
  'Distribution', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wirtschaft: Vertrieb, Verteilung / EDV: Software-Distribution) — nach den Nomen 2026-10-21
  'Disziplin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ordnung, Selbstbeherrschung / Sportart / wissenschaftliches Fach) — nach den Nomen 2026-10-21
  'Diva', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: gefeierte Sängerin, Schauspielerin / abwertend: launische Person) — nach den Nomen 2026-10-21
  'Division', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mathematik: Teilen / Militär: Truppenverband / Sport: Liga) — nach den Nomen 2026-10-21
  'Doktor', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: akademischer Titel / ugs.: Arzt) — nach den Nomen 2026-10-21
  'Dokumentation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Dokumentarfilm / das Dokumentieren, Pflegedokumentation / Sammlung von Unterlagen) — nach den Nomen 2026-10-21
  'Doppeldecker', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Flugzeug mit zwei Tragflächen / Bus mit zwei Etagen) — nach den Nomen 2026-10-22
  'Doppelpack', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: zwei Tore eines Spielers / zwei zusammen verpackte Stücke) — nach den Nomen 2026-10-22
  'Doppelpass', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fußball-Doppelpass / doppelte Staatsbürgerschaft (ugs.)) — nach den Nomen 2026-10-22
  'Doppelschlag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: zwei Treffer in kurzer Folge / Verzierung in der Musik / zwei Schläge) — nach den Nomen 2026-10-22
  'Dorado', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Paradies für jemanden / Sternbild) — nach den Nomen 2026-10-22
  'Dings', // zurückgestellt: ugs. Platzhalterwort (der/die/das Dings) — Genus nicht eindeutig (Regel 14) 2026-10-21
  'Direkteinspritzer', // zurückgestellt: Fachjargon (Motor mit Direkteinspritzung) — als Lernwort nicht sicher (Regel 14) 2026-10-21
  'Disc', // zurückgestellt: englische Schreibung (CD, Bandscheibe …) — Lemma/Bedeutung nicht sicher (Regel 14) 2026-10-21
  'Donna', // zurückgestellt: italienische Anrede/Vorname — Bedeutung und Gebrauch im Deutschen nicht sicher (Regel 14) 2026-10-22
};

/// Listeneinträge, die nur eine FORM einer anderen Karte sind (Lukas
/// 2026-10-19, Prompt-Regel 21: EINE Karte für «der/die Abgeordnete»; die
/// Liste führt zusätzlich die stark gebeugte Form «Abgeordneter»). Die Karte
/// heißt nach dem Ziel; die Suche findet die Form über vokab_formen.dart.
/// Mit Datum in PLAN.md.
const listenVerweis = <String, String>{
  'Abgeordneter': 'Abgeordnete', // Regel 21 (2026-10-19)
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
      final ziel = listenVerweis[w] ?? w;
      if (File('assets/vocab/$art/${vokabId(art, ziel)}.json').existsSync()) {
        zeilen[i] = '✓ $eintrag';
        neu++;
      }
    }
    if (neu > 0) datei.writeAsStringSync(zeilen.join('\n'));
    stdout.writeln('$liste: $neu neu abgehakt');
  }
}

/// Lemma eines Listeneintrags: alles vor dem ersten Komma bzw. vor der ersten
/// Klammer. Einträge der Verbliste tragen Zusätze («anbacken, kleben» =
/// Bedeutung, «sein, war, gewesen» = Stammformen, 2026-10-11; «miauen
/// (Partizip II: miaut)» = Hinweis, 2026-10-16) — die Karte heißt nach dem Lemma.
String listenLemma(String eintrag) =>
    eintrag.split(',').first.split('(').first.trim();

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
      final ziel = listenVerweis[w] ?? w;
      if (File('assets/vocab/$art/${vokabId(art, ziel)}.json').existsSync()) {
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
