// FILE: tool/naechste_woerter.dart
// PURPOSE: Routine «ده کلمه جدید» (Lukas, 2026-09-23) — nennt die nächsten N
//          Wörter der Wortliste, für die es noch KEINE Karte gibt.
//
//   dart tool/naechste_woerter.dart                # 20 aus der aktuellen Liste
//   dart tool/naechste_woerter.dart 5              # 5
//   (Rundengröße 20 statt 10: Lukas 2026-10-31 — «Zeit verkürzen»)
//   dart tool/naechste_woerter.dart --abhaken      # ✓ vor jedes Wort mit Karte
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
//     docs/ZURUECKGESTELLT.md → Tabelle 1 (mit Datum/Liste/Grund; Regeln:
//     PLAN.md → «🏁 مرحله‌ی آخر»). Geprüft
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
  'Dorn', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pflanzendorn / Dorn der Schnalle / Werkzeug) — nach den Nomen 2026-10-22
  'Dose', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Konservendose / Behälter / Steckdose (ugs.)) — nach den Nomen 2026-10-22
  'Double', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Film-Double / Doppelgänger / Sport: Doppelsieg) — nach den Nomen 2026-10-22
  'Drachen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spielzeug-/Sportdrachen / Fabelwesen / zänkische Frau (ugs.)) — nach den Nomen 2026-10-22
  'Drama', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bühnenstück / dramatisches Geschehen) — nach den Nomen 2026-10-22
  'Dramatik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Dramenliteratur / dramatische Spannung) — nach den Nomen 2026-10-22
  'Dramaturgie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lehre vom Drama / Abteilung am Theater / Aufbau einer Handlung) — nach den Nomen 2026-10-22
  'Dreh', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kniff/Trick (ugs.) / Drehung / Filmaufnahme) — nach den Nomen 2026-10-22
  'Dreher', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beruf an der Drehbank / Volkstanz) — nach den Nomen 2026-10-22
  'Drehkreuz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sperre am Eingang / Verkehrsknotenpunkt (Luftverkehr)) — nach den Nomen 2026-10-22
  'Drehscheibe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Töpferscheibe / Gleisdrehscheibe / Knotenpunkt) — nach den Nomen 2026-10-22
  'Dressur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abrichten von Tieren / Dressurreiten als Disziplin) — nach den Nomen 2026-10-22
  'Droge', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rauschgift / Rohstoff für Arzneimittel / etwas, das süchtig macht) — nach den Nomen 2026-10-22
  'Drogentoter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Drogentote / ein Drogentoter) — nach den Nomen 2026-10-22
  'Drucker', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gerät zum Drucken / Facharbeiter in der Druckerei) — nach den Nomen 2026-10-22
  'Dschihad', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: «Heiliger Krieg» / religiöses Bemühen, innerer Kampf) — nach den Nomen 2026-10-22
  'Duktus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schriftzug, Linienführung / charakteristische Art des Ausdrucks) — nach den Nomen 2026-10-22
  'Duldung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Dulden, Hinnehmen / Recht: ausgesetzte Abschiebung, Aufenthaltsstatus) — nach den Nomen 2026-10-22
  'Durchblick', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Blick durch etwas, Ausblick / ugs.: Überblick, Verständnis) — nach den Nomen 2026-10-22
  'Durchgang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Weg, Passage / Runde, Wahlgang) — nach den Nomen 2026-10-22
  'Durchmarsch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Marsch durch ein Gebiet / Sport, Politik: Siegesserie / Kartenspiel) — nach den Nomen 2026-10-22
  'Durchschlagskraft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kraft eines Geschosses / Wirksamkeit, Überzeugungskraft) — nach den Nomen 2026-10-22
  'Durchsicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Prüfung, Durchsehen / Blick durch etwas) — nach den Nomen 2026-10-22
  'Dynamik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Physik: Lehre von Kräften / Schwung, Triebkraft / Musik: Lautstärkeverlauf) — nach den Nomen 2026-10-22
  'Ebene', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: flaches Land / Mathematik: Fläche / Stufe, Niveau) — nach den Nomen 2026-10-22
  'Eckpunkt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Punkt an einer Ecke, Endpunkt / wesentlicher Punkt («Eckpunkte eines Plans»)) — nach den Nomen 2026-10-22
  'Eckstein', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stein an einer Ecke, Grundstein / Spielkartenfarbe Karo) — nach den Nomen 2026-10-22
  'Ehrenrunde', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Runde nach einem Sieg / ugs.: Wiederholen einer Schulklasse) — nach den Nomen 2026-10-22
  'Ehrenvorsitzende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Ehrenvorsitzende) — nach den Nomen 2026-10-22
  'Ehrenvorsitzender', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Ehrenvorsitzende / ein Ehrenvorsitzender) — nach den Nomen 2026-10-22
  'Eichel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Frucht der Eiche / Anatomie: Spitze des Penis / Spielkartenfarbe) — nach den Nomen 2026-10-23
  'Eidgenosse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mitglied eines Eidbundes, historisch / Schweizer, Schweizerin) — nach den Nomen 2026-10-23
  'Eidgenossenschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bund, durch Eid geschlossen / die Schweiz («Schweizerische Eidgenossenschaft»)) — nach den Nomen 2026-10-23
  'Eigentor', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ballspiele: Tor ins eigene Netz / Handlung, die einem selbst schadet) — nach den Nomen 2026-10-23
  'Einberufung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einberufen einer Versammlung / Einberufung zum Wehrdienst) — nach den Nomen 2026-10-23
  'Einblick', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Blick in etwas hinein / Kenntnis, Einsicht («Einblick gewinnen»)) — nach den Nomen 2026-10-23
  'Einbringung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorlegen eines Gesetzentwurfs / Einbringen von Kapital, Ernte) — nach den Nomen 2026-10-23
  'Einbruch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Eindringen zum Stehlen / Beginn («bei Einbruch der Nacht») / Einsturz, starker Rückgang) — nach den Nomen 2026-10-23
  'Einer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mathematik: Einerstelle / Sport: Einerboot) — nach den Nomen 2026-10-23
  'Einfall', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Idee / Eindringen in ein Land / Einfallen von Licht) — nach den Nomen 2026-10-23
  'Eingabe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gesuch an eine Behörde / EDV: Eingeben von Daten) — nach den Nomen 2026-10-23
  'Eingang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tür, Zugang / Eintreffen von Post, Geld) — nach den Nomen 2026-10-23
  'Eingriff', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Medizin: Operation / Eingreifen in Rechte, Abläufe) — nach den Nomen 2026-10-23
  'Einheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einigkeit, Ganzes / Maßeinheit / militärische Gruppe / deutsche Einheit) — nach den Nomen 2026-10-23
  'Einigung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Übereinkunft / Vereinigung, z. B. deutsche Einigung) — nach den Nomen 2026-10-23
  'Einigungsprozess', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorgang einer Übereinkunft / Prozess der staatlichen Vereinigung) — nach den Nomen 2026-10-23
  'Einkauf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Einkaufen / gekaufte Ware / Einkaufsabteilung einer Firma) — nach den Nomen 2026-10-23
  'Einkehr', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einkehren in ein Gasthaus / Besinnung, innere Sammlung) — nach den Nomen 2026-10-23
  'Einklang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musik: Zusammenklingen / Übereinstimmung («im Einklang mit»)) — nach den Nomen 2026-10-23
  'Einlage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geldeinlage / Schuheinlage / Suppeneinlage / Programmeinlage) — nach den Nomen 2026-10-23
  'Einleitung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorwort, Anfang / Einleiten eines Verfahrens / Einleiten von Abwasser) — nach den Nomen 2026-10-23
  'Einnahme', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: eingenommenes Geld / Einnehmen von Medikamenten / Eroberung) — nach den Nomen 2026-10-23
  'Einordnung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einordnen, Klassifizierung / Verkehr: Einordnen in eine Spur) — nach den Nomen 2026-10-23
  'Einrichtung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Möbel / Institution / Einrichten, Installation) — nach den Nomen 2026-10-23
  'Eins', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ziffer 1 / Schulnote «sehr gut» / Linie 1) — nach den Nomen 2026-10-23
  'Einsatz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verwendung / Einsatz von Polizei, Feuerwehr / Engagement / Spieleinsatz / Musik: Einsetzen) — nach den Nomen 2026-10-23
  'Einsatzgebiet', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gebiet eines Polizei-/Militäreinsatzes / Anwendungsbereich eines Geräts) — nach den Nomen 2026-10-23
  'Einschaltung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einschalten eines Geräts / Hinzuziehen («Einschaltung eines Anwalts») / Einschub) — nach den Nomen 2026-10-23
  'Einschlag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufprall, Blitzeinschlag / Holzeinschlag / Anteil, Note («mit südländischem Einschlag»)) — nach den Nomen 2026-10-23
  'Einschluss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einbeziehung («mit Einschluss von») / Eingeschlossenes, z. B. im Gestein) — nach den Nomen 2026-10-23
  'Einschnitt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schnitt, Kerbe / Wendepunkt, Zäsur) — nach den Nomen 2026-10-23
  'Einsicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erkenntnis, Verständnis / Einblick in Akten / Vernunft) — nach den Nomen 2026-10-23
  'Einspielung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musikaufnahme / Einspielen von Geld, z. B. eines Films) — nach den Nomen 2026-10-23
  'Einstand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: erster Arbeitstag mit Ausgabe / Tennis: Gleichstand) — nach den Nomen 2026-10-23
  'Einstellung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Haltung / Anstellung / Einstellen eines Geräts / Beenden / Filmaufnahme) — nach den Nomen 2026-10-23
  'Einstieg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einsteigen, Tür eines Fahrzeugs / Beginn, Zugang zu einem Thema) — nach den Nomen 2026-10-23
  'Eintagsfliege', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Insekt / kurzlebige Erscheinung) — nach den Nomen 2026-10-23
  'Eintritt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hineingehen / Eintrittsgeld / Beitritt zu einer Organisation / Beginn («Eintritt der Dunkelheit»)) — nach den Nomen 2026-10-23
  'Einweihung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: feierliche Eröffnung / Einweihen in ein Geheimnis) — nach den Nomen 2026-10-23
  'Einweisung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einweisung ins Krankenhaus / Einführung, Anleitung) — nach den Nomen 2026-10-23
  'Einwurf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: Einwurf des Balls / Öffnung, Schlitz / Einwand) — nach den Nomen 2026-10-23
  'Einzug', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Umzug in eine Wohnung / feierliches Hineinziehen / Einziehen von Geld) — nach den Nomen 2026-10-23
  'Eiszeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: erdgeschichtliche Kaltzeit / übertragen: Abkühlung von Beziehungen) — nach den Nomen 2026-10-23
  'Elektronik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fachgebiet der Elektrotechnik / elektronische Bauteile eines Geräts) — nach den Nomen 2026-10-23
  'Element', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: chemisches Element / Bestandteil, Bauteil / Naturelement) — nach den Nomen 2026-10-23
  'Elfer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. Elfmeter / Zahl Elf, Mannschaft aus elf) — nach den Nomen 2026-10-23
  'Elle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Unterarmknochen / altes Längenmaß) — nach den Nomen 2026-10-23
  'Elternhaus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Familie, in der man aufwächst / Haus der Eltern) — nach den Nomen 2026-10-23
  'Email', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2 (das Email = Schmelzüberzug, Emaille / umgangssprachlich die Email = E-Mail) — nach den Nomen 2026-10-23
  'Emission', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausstoß von Schadstoffen / Ausgabe von Wertpapieren) — nach den Nomen 2026-10-23
  'Emittent', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Herausgeber von Wertpapieren / Verursacher von Emissionen) — nach den Nomen 2026-10-23
  'Empfang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erhalt / Rezeption im Hotel / feierliche Veranstaltung / Radio- und Handyempfang) — nach den Nomen 2026-10-23
  'Endkampf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: entscheidender Kampf im Krieg / Sport: Finale) — nach den Nomen 2026-10-23
  'Endspiel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: Finale / Schach: Endphase einer Partie) — nach den Nomen 2026-10-23
  'Engagement', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einsatz für eine Sache / Anstellung eines Künstlers / Börse: Verpflichtung) — nach den Nomen 2026-10-25
  'Enge', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mangel an Raum, Beengtheit / enge Stelle, Meerenge) — nach den Nomen 2026-10-25
  'Engpass', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: schmale Stelle eines Weges / Knappheit, Versorgungsengpass) — nach den Nomen 2026-10-25
  'Enquete', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: amtliche Untersuchung, Umfrage / österreichisch: Arbeitstagung) — nach den Nomen 2026-10-25
  'Ensemble', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Künstlergruppe / zusammengehörige Gruppe von Gebäuden / Kleidung: Kombination) — nach den Nomen 2026-10-25
  'Entbindung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geburt eines Kindes / Befreiung von einer Pflicht, z. B. Entbindung von der Schweigepflicht) — nach den Nomen 2026-10-25
  'Ente', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vogel / Zeitungsente, Falschmeldung / Urinflasche im Krankenhaus / ugs. Citroën 2CV) — nach den Nomen 2026-10-25
  'Entfaltung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Auseinanderfalten / Entwicklung, z. B. der Persönlichkeit / Darbietung, Zurschaustellung) — nach den Nomen 2026-10-25
  'Entfernung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abstand, Distanz / Beseitigen, Wegnehmen / unerlaubte Entfernung von der Truppe) — nach den Nomen 2026-10-25
  'Entflechtung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufteilung eines Konzerns / Trennung von Verkehrswegen) — nach den Nomen 2026-10-25
  'Entgleisung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Herausspringen eines Zuges aus den Schienen / taktlose Äußerung, Fehltritt) — nach den Nomen 2026-10-25
  'Enthaltung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stimmenthaltung bei einer Abstimmung / Verzicht, z. B. auf Alkohol) — nach den Nomen 2026-10-25
  'Entlassung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kündigung durch den Arbeitgeber / Entlassung aus Krankenhaus oder Gefängnis) — nach den Nomen 2026-10-25
  'Entlastung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erleichterung, Verringerung einer Belastung / Recht: Entlastung eines Angeklagten bzw. des Vorstands) — nach den Nomen 2026-10-25
  'Entschuldigung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bitte um Verzeihung / Rechtfertigung, Begründung / schriftliche Entschuldigung für Schule oder Arbeit) — nach den Nomen 2026-10-25
  'Entspannung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erholung, Lockerung / Politik: Entspannung zwischen Staaten) — nach den Nomen 2026-10-25
  'Entwickler', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Person, die etwas entwickelt, z. B. Software / Fotografie: Entwicklerflüssigkeit) — nach den Nomen 2026-10-25
  'Entwicklung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fortschritt, Wachstum / Entwickeln eines Produkts / Fotografie: Entwickeln eines Films) — nach den Nomen 2026-10-25
  'Entzug', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wegnahme, z. B. Führerscheinentzug / Drogen- bzw. Alkoholentzug) — nach den Nomen 2026-10-25
  'Episode', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Folge einer Serie / kurzer Abschnitt, Begebenheit im Leben) — nach den Nomen 2026-10-25
  'Equipe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport, bes. Reitsport: Mannschaft / schweizerisch: Arbeitsgruppe, Team) — nach den Nomen 2026-10-25
  'Erbgut', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Biologie: Gesamtheit der Erbanlagen / ererbter Besitz, z. B. Hof) — nach den Nomen 2026-10-25
  'Erde', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Planet / Boden, Erdreich / Elektrotechnik: Erdung) — nach den Nomen 2026-10-25
  'Erdrutsch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: abrutschende Erdmassen / übertragen: Erdrutschsieg bei einer Wahl) — nach den Nomen 2026-10-25
  'Erfahrung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erlebnis, aus dem man lernt / Kenntnisse, Berufserfahrung) — nach den Nomen 2026-10-25
  'Erfindung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: neu Erfundenes, Invention / Ausgedachtes, Lüge) — nach den Nomen 2026-10-25
  'Erfrischung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Erfrischen, Abkühlung / Getränk oder kleiner Imbiss) — nach den Nomen 2026-10-25
  'Ergreifung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Festnahme eines Täters / Ergreifen der Macht bzw. Initiative) — nach den Nomen 2026-10-25
  'Erhalt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Empfang, Erhalt eines Briefes / Bewahrung, Erhalt der Natur) — nach den Nomen 2026-10-25
  'Erhebung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Umfrage, statistische Erhebung / Aufstand / Anhöhe / Einziehen von Gebühren) — nach den Nomen 2026-10-25
  'Erinnerung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gedächtnis, Erinnertes / Mahnung, Erinnerungsschreiben / Andenken, Souvenir) — nach den Nomen 2026-10-25
  'Erlass', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verordnung einer Behörde / Befreiung von einer Pflicht, z. B. Steuererlass) — nach den Nomen 2026-10-25
  'Erledigung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abschluss einer Aufgabe / Besorgung, Einkauf («Erledigungen machen»)) — nach den Nomen 2026-10-25
  'Erleichterung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gefühl der Entlastung / Vereinfachung, Minderung, z. B. Steuererleichterung) — nach den Nomen 2026-10-25
  'Erleuchtung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: plötzliche Einsicht, Idee / religiöse Erleuchtung / Beleuchtung) — nach den Nomen 2026-10-25
  'Ermittlung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: polizeiliche Untersuchung / Feststellung, Berechnung eines Wertes) — nach den Nomen 2026-10-25
  'Erniedrigung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Demütigung / Musik: Senkung eines Tones um einen Halbton) — nach den Nomen 2026-10-25
  'Erosion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geologie: Abtragung des Bodens / übertragen: allmählicher Verfall / Medizin: Schleimhautdefekt) — nach den Nomen 2026-10-25
  'Erreger', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Krankheitserreger / Elektrotechnik: Erregermaschine) — nach den Nomen 2026-10-25
  'Erregung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufregung, Zorn / sexuelle Erregung / Physiologie: Reizung von Nerven) — nach den Nomen 2026-10-25
  'Errungenschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fortschritt, Leistung / ugs. scherzhaft: neue Anschaffung) — nach den Nomen 2026-10-25
  'Ersatz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Austausch, Ersatzstück / Entschädigung, Schadenersatz) — nach den Nomen 2026-10-25
  'Erscheinung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Phänomen / äußeres Bild einer Person / Geistererscheinung / Veröffentlichung) — nach den Nomen 2026-10-25
  'Ersparnis', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: erspartes Geld (meist Plural) / Einsparung, z. B. an Zeit) — nach den Nomen 2026-10-25
  'Erstarrung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Starrwerden, Gefrieren / übertragen: Stillstand, Unbeweglichkeit) — nach den Nomen 2026-10-25
  'Erstattung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rückzahlung von Kosten / Erstatten einer Anzeige oder eines Berichts) — nach den Nomen 2026-10-25
  'Erstling', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: erstes Kind, erstes Junges / erstes Werk eines Künstlers) — nach den Nomen 2026-10-25
  'Ertrag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ernte, Ausbeute in der Landwirtschaft / Gewinn, Erlös) — nach den Nomen 2026-10-25
  'Eruption', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: vulkanischer Ausbruch / Medizin: Hautausschlag / Astronomie: Gasausbruch der Sonne) — nach den Nomen 2026-10-25
  'Erwerb', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: berufliche Tätigkeit, Lebensunterhalt / das Erwerben, Kauf / Aneignung von Wissen) — nach den Nomen 2026-10-25
  'Erzeuger', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hersteller, Produzent (bes. Landwirtschaft) / ugs. scherzhaft-abwertend: leiblicher Vater) — nach den Nomen 2026-10-25
  'Esel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tier (Huftier) / ugs. Schimpfwort: Dummkopf) — nach den Nomen 2026-10-25
  'Eskapade', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Reitsport: falscher Sprung des Pferdes zur Seite / abenteuerlicher Streich, Seitensprung) — nach den Nomen 2026-10-25
  'Essenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wesen, Kern einer Sache / konzentrierter Auszug (Aroma, Duftstoff)) — nach den Nomen 2026-10-25
  'Etablissement', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Unternehmen, Geschäft / Lokal, Gaststätte / verhüllend: Bordell) — nach den Nomen 2026-10-25
  'Etappe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Teilstrecke einer Reise oder eines Rennens / Entwicklungsabschnitt / Militär (veraltet): rückwärtiges Gebiet hinter der Front) — nach den Nomen 2026-10-25
  'Euroland', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. Gesamtgebiet der Eurozone / einzelnes Land der Eurozone) — nach den Nomen 2026-10-25
  'Europaabgeordnete', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Europaabgeordnete) — nach den Nomen 2026-10-25
  'Euthanasie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sterbehilfe / nationalsozialistisch verhüllend: Ermordung kranker und behinderter Menschen) — nach den Nomen 2026-10-25
  'Evangelist', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verfasser eines der vier Evangelien / Prediger, Wanderprediger) — nach den Nomen 2026-10-25
  'Evangelium', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Heilsbotschaft Jesu / eines der vier Bücher des Neuen Testaments / übertragen: etwas, woran man fest glaubt) — nach den Nomen 2026-10-25
  'Evolution', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: allmähliche Entwicklung / Biologie: stammesgeschichtliche Entwicklung der Lebewesen) — nach den Nomen 2026-10-25
  'Ewigkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: unendliche Zeit / Religion: Jenseits / ugs.: sehr lange Zeit) — nach den Nomen 2026-10-25
  'Exekution', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hinrichtung / österr.: Zwangsvollstreckung, Pfändung) — nach den Nomen 2026-10-25
  'Exekutivbeamter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: stark gebeugte Form von «der Exekutivbeamte») — nach den Nomen 2026-10-25
  'Exekutive', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: vollziehende Gewalt im Staat / österr.: Polizei und Sicherheitsbehörden) — nach den Nomen 2026-10-25
  'Exempel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: (warnendes) Beispiel, «ein Exempel statuieren» / veraltend: Rechenaufgabe) — nach den Nomen 2026-10-25
  'Exhibitionist', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Person mit sexuellem Exhibitionismus / übertragen: jemand, der sich gern zur Schau stellt) — nach den Nomen 2026-10-25
  'Existenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Dasein, Vorhandensein / Lebensgrundlage, Auskommen / abwertend: Mensch, «eine verkrachte Existenz») — nach den Nomen 2026-10-25
  'Exodus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: 2. Buch Mose / Auszug, massenhafte Abwanderung) — nach den Nomen 2026-10-25
  'Exote', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mensch, Tier oder Pflanze aus fernen Ländern / Börse: ausländisches, wenig gehandeltes Wertpapier) — nach den Nomen 2026-10-25
  'Expansion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Physik: Ausdehnung / Ausweitung von Macht- oder Wirtschaftsbereich) — nach den Nomen 2026-10-25
  'Expedition', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Forschungsreise / Kaufmannssprache: Versandabteilung, Abfertigung) — nach den Nomen 2026-10-25
  'Expertise', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gutachten eines Sachverständigen / Fachwissen, Sachkenntnis) — nach den Nomen 2026-10-25
  'Exponent', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mathematik: Hochzahl / herausragender Vertreter einer Richtung) — nach den Nomen 2026-10-25
  'Exposition', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Literatur/Musik: einleitender Teil / Medizin/Fotografie: Ausgesetztsein, Belichtung / veraltet: Ausstellung) — nach den Nomen 2026-10-25
  'Express', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schnellzug / «per Express»: Eilzustellung) — nach den Nomen 2026-10-25
  'Extrakt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Auszug aus Pflanzen o. Ä. / Zusammenfassung eines Textes; Genus der, fachsprachlich auch das) — nach den Nomen 2026-10-25
  'Exzellenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Titel/Anrede «Eure Exzellenz» / bildungssprachlich: hervorragende Qualität) — nach den Nomen 2026-10-25
  'Fabel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: lehrhafte Tiergeschichte / Handlung einer Dichtung / erfundene Geschichte) — nach den Nomen 2026-10-25
  'Facette', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: geschliffene Fläche eines Edelsteins / Aspekt, Seite einer Sache) — nach den Nomen 2026-10-25
  'Fach', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abteil in Schrank, Tasche o. Ä. / Unterrichtsfach / Fachgebiet, Beruf) — nach den Nomen 2026-10-25
  'Fachbereich', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fachgebiet / Organisationseinheit einer Hochschule) — nach den Nomen 2026-10-25
  'Faden', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 3 (Homograph mit gleichem Artikel: der Faden «Garn» / der Faden «altes Längenmaß in der Seefahrt», Plural Faden) — nach den Nomen 2026-10-25
  'Fahne', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Flagge / ugs. Alkoholgeruch «eine Fahne haben» / Druckwesen: Korrekturabzug) — nach den Nomen 2026-10-25
  'Fahrdienst', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Dienst des Zugpersonals bei der Bahn / Beförderungsdienst, z. B. für Kranke oder Behinderte) — nach den Nomen 2026-10-25
  'Fahrleistung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Leistungsfähigkeit eines Fahrzeugs (Geschwindigkeit, Beschleunigung) / gefahrene Strecke, Kilometerleistung) — nach den Nomen 2026-10-25
  'Fahrstuhl', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufzug / veraltend: Rollstuhl) — nach den Nomen 2026-10-25
  'Fahrt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Fahren, Reise / Geschwindigkeit «Fahrt aufnehmen» / ugs. «in Fahrt sein» = in Schwung, wütend) — nach den Nomen 2026-10-25
  'Fahrverhalten', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verhalten des Fahrers im Verkehr / Verhalten eines Fahrzeugs beim Fahren) — nach den Nomen 2026-10-25
  'Fahrwasser', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: schiffbare Fahrrinne / übertragen: Einflussbereich «in jemandes Fahrwasser») — nach den Nomen 2026-10-25
  'Fahrwerk', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Flugzeug: Landeeinrichtung / Auto: Achsen, Federung, Räder) — nach den Nomen 2026-10-25
  'Faktor', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Umstand, Einflussgröße / Mathematik: Zahl, die multipliziert wird / veraltet: Leiter einer Druckerei) — nach den Nomen 2026-10-25
  'Falke', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Greifvogel / Politik: Vertreter einer harten Linie) — nach den Nomen 2026-10-25
  'Falle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fangvorrichtung für Tiere / Hinterhalt, List / ugs. Bett) — nach den Nomen 2026-10-25
  'Falte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: in Stoff oder Papier / in der Haut, Runzel / Geologie: Gesteinsfalte) — nach den Nomen 2026-10-25
  'Familiendrama', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Theaterstück/Film über eine Familie / tragisches Ereignis, Gewalttat in einer Familie) — nach den Nomen 2026-10-25
  'Familiengeschichte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschichte einer Familie über Generationen / Ereignis, Angelegenheit innerhalb einer Familie) — nach den Nomen 2026-10-25
  'Familientag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Treffen der ganzen Verwandtschaft / Aktionstag, Veranstaltung für Familien) — nach den Nomen 2026-10-25
  'Familienverband', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Organisation, Interessenverband für Familien / die Großfamilie, Verwandtschaft als Gemeinschaft) — nach den Nomen 2026-10-25
  'Fanfare', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: lange Trompete ohne Ventile / kurzes, festliches Signal-Musikstück) — nach den Nomen 2026-10-25
  'Fang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Fangen, die Beute / Jägersprache: Fangzahn, Kralle eines Raubtiers) — nach den Nomen 2026-10-25
  'Farbe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Farbeindruck, Farbton / Anstrichmittel / Kartenspiel: Farbe der Spielkarten) — nach den Nomen 2026-10-25
  'Farbtupfer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kleiner farbiger Fleck / übertragen: etwas Belebendes, Abwechslung) — nach den Nomen 2026-10-25
  'Farce', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Posse, lächerliches Theater / Kochkunst: Füllung aus fein gehacktem Fleisch o. Ä.) — nach den Nomen 2026-10-25
  'Fassade', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorderseite eines Gebäudes / übertragen: äußerer Schein) — nach den Nomen 2026-10-25
  'Fassung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Version eines Textes oder Films / Selbstbeherrschung «die Fassung verlieren» / Halterung, z. B. Lampenfassung, Brillenfassung) — nach den Nomen 2026-10-25
  'Fax', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Faxgerät / gefaxtes Schriftstück) — nach den Nomen 2026-10-25
  'Feder', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vogelfeder / Schreibfeder / Technik: Sprungfeder, Spiralfeder) — nach den Nomen 2026-10-25
  'Fehlanzeige', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Amtssprache: Meldung, dass nichts vorhanden ist / ugs. Ausruf «Fehlanzeige!» = Nein, nichts da) — nach den Nomen 2026-10-25
  'Fehlleistung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Psychologie: Versprecher, freudsche Fehlleistung / schlechte Leistung) — nach den Nomen 2026-10-25
  'Fehltritt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: falscher Schritt, Stolpern / übertragen: moralisches Vergehen) — nach den Nomen 2026-10-25
  'Feierlichkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: feierliche Stimmung, Würde / meist Plural: Feier, Festakt) — nach den Nomen 2026-10-25
  'Feige', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Frucht, Feigenbaum / ugs. landschaftlich: Ohrfeige) — nach den Nomen 2026-10-25
  'Feigenblatt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Blatt des Feigenbaums / übertragen: Tarnung, Vorwand) — nach den Nomen 2026-10-25
  'Feindseligkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: feindselige Haltung / Plural: Kampfhandlungen) — nach den Nomen 2026-10-25
  'Feine', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: das Feine) — nach den Nomen 2026-10-25
  'Feinheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: feine Beschaffenheit, Zartheit / meist Plural: Einzelheiten, Nuancen) — nach den Nomen 2026-10-25
  'Feld', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Acker / Spielfeld, Kästchen / Fachgebiet, Bereich) — nach den Nomen 2026-10-25
  'Ferkel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: junges Schwein / ugs. abwertend: schmutziger oder unanständiger Mensch) — nach den Nomen 2026-10-25
  'Fernsehprogramm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Programmablauf eines Senders / Fernsehkanal / Programmzeitschrift) — nach den Nomen 2026-10-25
  'Fernsehsender', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fernsehanstalt, Kanal / technische Sendeanlage) — nach den Nomen 2026-10-25
  'Feste', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (veraltet: die Feste = Festung; sonst Pluralform von «das Fest») — Lemma unklar — nach den Nomen 2026-10-25
  'Festigkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Technik: Widerstandsfähigkeit eines Materials / Standhaftigkeit, Entschlossenheit) — nach den Nomen 2026-10-25
  'Festlichkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: festliche Stimmung / meist Plural: Feier, Festveranstaltung) — nach den Nomen 2026-10-25
  'Festsetzung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bestimmung, das Festlegen (Preis, Strafe) / Inhaftierung, Festnahme) — nach den Nomen 2026-10-25
  'Festspiel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: festliches Bühnenstück / Plural «Festspiele» = Festival, z. B. Salzburger Festspiele) — nach den Nomen 2026-10-25
  'Feststellung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ermittlung, das Feststellen / Äußerung, Bemerkung) — nach den Nomen 2026-10-25
  'Fetisch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kultgegenstand mit magischer Kraft / Psychologie, Sexualität: Fetisch) — nach den Nomen 2026-10-25
  'Fette', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (unklares Lemma: Plural von «das Fett» bzw. substantiviertes Adjektiv «die Fette») — nach den Nomen 2026-10-25
  'Feuer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Flamme, Brand / Feuer für die Zigarette / Beschuss «das Feuer eröffnen» / Leidenschaft, Begeisterung) — nach den Nomen 2026-10-25
  'Feuerbrand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pflanzenkrankheit bei Obstbäumen / gehoben: brennendes Holzstück) — nach den Nomen 2026-10-25
  'Feuertaufe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Militär: erster Kampfeinsatz / übertragen: erste Bewährungsprobe) — nach den Nomen 2026-10-25
  'Figur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Körperform, Gestalt / Person in einem Werk / Spielfigur, Schachfigur / geometrische Figur) — nach den Nomen 2026-10-26
  'Film', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kino-/Fernsehfilm / dünne Schicht «ein Ölfilm» / Fotofilm, Filmrolle) — nach den Nomen 2026-10-26
  'Filmgeschichte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschichte des Films als Kunst / Handlung eines bestimmten Films) — nach den Nomen 2026-10-26
  'Filmrolle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rolle eines Schauspielers in einem Film / aufgerollter Fotofilm) — nach den Nomen 2026-10-26
  'Filz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stoff aus gepressten Fasern / ugs. abwertend: Vetternwirtschaft, Korruption) — nach den Nomen 2026-10-26
  'Finale', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: Endspiel / Musik: Schlusssatz / allgemein: Schluss, Höhepunkt) — nach den Nomen 2026-10-26
  'Finanzbeamter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der Finanzbeamte / ein Finanzbeamter) — nach den Nomen 2026-10-26
  'Finanzvorstand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: für Finanzen zuständiges Vorstandsmitglied (Person) / Gremium, Vorstand für Finanzen) — nach den Nomen 2026-10-26
  'Finesse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Feinheit, Raffinesse / meist Plural: Kniff, Trick) — nach den Nomen 2026-10-26
  'Finish', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: Endspurt / Technik: letzte Oberflächenbehandlung, Veredelung) — nach den Nomen 2026-10-26
  'Finsternis', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Dunkelheit / Astronomie: Sonnen- bzw. Mondfinsternis) — nach den Nomen 2026-10-26
  'Fixierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Befestigung, Festhalten (auch Medizin: Fixierung eines Patienten) / Psychologie: starke Bindung an etwas / schriftliches Festlegen) — nach den Nomen 2026-10-26
  'Flaggschiff', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schiff des Flottenkommandanten / übertragen: wichtigstes Produkt oder Aushängeschild) — nach den Nomen 2026-10-26
  'Flanke', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Seite des Körpers (Tier) / Fußball: Flanke (Pass) / Turnen: Sprung / Militär: Seite einer Truppe) — nach den Nomen 2026-10-26
  'Flasche', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gefäß / ugs. abwertend: Versager) — nach den Nomen 2026-10-26
  'Fleck', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schmutzfleck / Stelle, Ort «nicht vom Fleck kommen» / österr. Kuttelfleck) — nach den Nomen 2026-10-26
  'Fliege', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Insekt / Querbinder, Krawattenschleife) — nach den Nomen 2026-10-26
  'Flieger', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pilot / ugs. Flugzeug) — nach den Nomen 2026-10-26
  'Flitzer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. kleines schnelles Auto / nackter Läufer bei Veranstaltungen) — nach den Nomen 2026-10-26
  'Fluch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schimpfwort, Kraftausdruck / Verwünschung, böser Zauber) — nach den Nomen 2026-10-26
  'Fluglinie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fluggesellschaft / regelmäßige Flugverbindung, Strecke) — nach den Nomen 2026-10-26
  'Flugstunde', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stunde Flugzeit / Unterrichtsstunde beim Fliegenlernen) — nach den Nomen 2026-10-26
  'Flut', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gezeiten, Hochwasser / Überschwemmung / große Menge «eine Flut von Briefen») — nach den Nomen 2026-10-26
  'Fokus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Optik: Brennpunkt / Mittelpunkt des Interesses «im Fokus stehen» / Medizin: Krankheitsherd) — nach den Nomen 2026-10-26
  'Folge', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Konsequenz, Auswirkung / Teil einer Serie, Episode / Reihenfolge) — nach den Nomen 2026-10-26
  'Fond', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rücksitz im Auto / Hintergrund / Kochkunst: Bratensaft als Grundlage für Soßen) — nach den Nomen 2026-10-26
  'Forderung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verlangen, Anspruch / Wirtschaft: Geldforderung, offener Betrag) — nach den Nomen 2026-10-26
  'Form', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gestalt, Umriss / körperliche Verfassung «in Form sein» / Backform / Umgangsform) — nach den Nomen 2026-10-26
  'Format', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Größe, Maß (Papier, Datei) / Persönlichkeit von Rang «ein Mann von Format» / Sendeformat) — nach den Nomen 2026-10-26
  'Formation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gruppierung, Aufstellung / Geologie: Gesteinsformation / Militär: Verband) — nach den Nomen 2026-10-26
  'Formel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mathematik/Chemie: Formel / feste Redewendung / Motorsport: Formel 1) — nach den Nomen 2026-10-26
  'Forte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musik: laut / Stärke, besondere Fähigkeit) — nach den Nomen 2026-10-26
  'Fortgang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Weggang, Abreise / Fortschritt, Verlauf «der Fortgang der Arbeiten») — nach den Nomen 2026-10-26
  'Forum', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Marktplatz im alten Rom / Plattform für Diskussion / Internetforum) — nach den Nomen 2026-10-26
  'Fotografie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Technik und Kunst des Fotografierens / einzelnes Foto) — nach den Nomen 2026-10-26
  'Fraktion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abgeordnete einer Partei im Parlament / Gruppe innerhalb einer Organisation / Chemie: Bestandteil bei der Trennung) — nach den Nomen 2026-10-26
  'Fraktionsvorsitzende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv/Partizip: die/der Fraktionsvorsitzende) — nach den Nomen 2026-10-26
  'Fraktionsvorsitzender', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv/Partizip: ein Fraktionsvorsitzender) — nach den Nomen 2026-10-26
  'Franke', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Angehöriger des germanischen Volks der Franken / Einwohner Frankens) — nach den Nomen 2026-10-26
  'Frau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: weiblicher Mensch / Ehefrau / Anrede «Frau Müller») — nach den Nomen 2026-10-26
  'Frauchen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. Besitzerin eines Hundes / Verkleinerung von Frau) — nach den Nomen 2026-10-26
  'Frauenbeauftragte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv/Partizip: die Frauenbeauftragte) — nach den Nomen 2026-10-26
  'Frauenbeauftragter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv/Partizip: ein Frauenbeauftragter) — nach den Nomen 2026-10-26
  'Frauenhaus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zufluchtsstätte für misshandelte Frauen / früher Frauengemach bzw. Bordell) — nach den Nomen 2026-10-26
  'Frauenstimme', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stimme einer Frau beim Sprechen/Singen / Wählerstimme einer Frau) — nach den Nomen 2026-10-26
  'Frauentag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Internationaler Frauentag am 8. März / kath. Marienfest) — nach den Nomen 2026-10-26
  'Freak', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Außenseiter, der sich nicht anpasst / begeisterter Fan, z. B. Computerfreak) — nach den Nomen 2026-10-26
  'Freibrief', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: früher Urkunde mit Vorrecht / übertragen: Erlaubnis, Rechtfertigung «kein Freibrief für …») — nach den Nomen 2026-10-26
  'Freiburg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 3 (Homograph mit gleichem Genus: Freiburg im Breisgau / Freiburg im Üechtland (Fribourg), Schweiz) — nach den Nomen 2026-10-26
  'Freiheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zustand des Freiseins / Vorrecht «sich Freiheiten herausnehmen») — nach den Nomen 2026-10-26
  'Freiraum', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: unbebaute, offene Fläche / Spielraum zur persönlichen Entfaltung) — nach den Nomen 2026-10-26
  'Freisetzung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Freiwerden von Stoffen/Energie / Entlassung von Arbeitskräften) — nach den Nomen 2026-10-26
  'Freizeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: freie Zeit / mehrtägiges Gruppentreffen, z. B. Jugendfreizeit) — nach den Nomen 2026-10-26
  'Fremder', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Fremde, ein Fremder) — nach den Nomen 2026-10-26
  'Frequenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Häufigkeit, Besucherzahl / Physik: Schwingungszahl) — nach den Nomen 2026-10-26
  'Freund', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Freund allgemein / fester Partner «mein Freund») — nach den Nomen 2026-10-26
  'Freundin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Freundin allgemein / feste Partnerin «meine Freundin») — nach den Nomen 2026-10-26
  'Friese', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bewohner Frieslands / Friesenpferd) — nach den Nomen 2026-10-26
  'Fromme', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Fromme) — nach den Nomen 2026-10-26
  'Front', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorderseite eines Gebäudes / Kampflinie im Krieg / Wetterfront) — nach den Nomen 2026-10-26
  'Frontmann', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sänger einer Band / führende Person einer Gruppe) — nach den Nomen 2026-10-26
  'Frosch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tier / Knallkörper / Teil am Geigenbogen) — nach den Nomen 2026-10-26
  'Frost', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Temperatur unter null / Kältegefühl, Schüttelfrost) — nach den Nomen 2026-10-26
  'Frucht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pflanzenfrucht / Leibesfrucht / übertragen: Ergebnis «Früchte der Arbeit») — nach den Nomen 2026-10-26
  'Fuchs', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tier / schlauer Mensch / Pferd mit rotbraunem Fell) — nach den Nomen 2026-10-26
  'Fuhrmann', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kutscher, Fahrer eines Fuhrwerks / Sternbild) — nach den Nomen 2026-10-26
  'Fund', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Finden / gefundener Gegenstand) — nach den Nomen 2026-10-26
  'Fundament', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Unterbau eines Gebäudes / übertragen: Grundlage) — nach den Nomen 2026-10-26
  'Fundgrube', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ort mit vielen wertvollen Dingen / Bergbau: Grube) — nach den Nomen 2026-10-26
  'Fundstelle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ort eines Fundes / Stelle in einem Text, Beleg) — nach den Nomen 2026-10-26
  'Fundus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bestand an Kostümen/Requisiten im Theater / übertragen: Grundstock an Wissen) — nach den Nomen 2026-10-26
  'Funke', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: glühendes Teilchen / übertragen: ein kleines bisschen «ein Funke Hoffnung») — nach den Nomen 2026-10-26
  'Funkstille', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pause im Funkverkehr / ugs. kein Kontakt mehr) — nach den Nomen 2026-10-26
  'Funktion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufgabe, Zweck / Amt, Stellung / Mathematik: Funktion) — nach den Nomen 2026-10-26
  'Furche', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rille im Ackerboden / tiefe Falte in der Haut) — nach den Nomen 2026-10-26
  'Fusion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zusammenschluss von Firmen / Physik: Kernfusion / Musikstil) — nach den Nomen 2026-10-26
  'Gabe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschenk / Begabung, Talent / Medizin: Verabreichung, Dosis) — nach den Nomen 2026-10-26
  'Gabel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Essbesteck / Astgabel, Gabelung / Telefongabel) — nach den Nomen 2026-10-26
  'Gala', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: festliche Kleidung «in Gala» / festliche Veranstaltung) — nach den Nomen 2026-10-26
  'Galerie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kunstgalerie / oberster Rang im Theater / Laufgang an einem Gebäude) — nach den Nomen 2026-10-26
  'Galgen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gerüst zum Hinrichten / Technik: Ausleger, z. B. für ein Mikrofon) — nach den Nomen 2026-10-26
  'Galionsfigur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Figur am Bug eines Schiffes / übertragen: bekannte Leitfigur) — nach den Nomen 2026-10-26
  'Galopp', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gangart des Pferdes / schneller Rundtanz) — nach den Nomen 2026-10-26
  'Gangart', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Art des Gehens, Gangart eines Pferdes / übertragen: Vorgehensweise «eine härtere Gangart») — nach den Nomen 2026-10-26
  'Gans', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vogel / Schimpfwort «dumme Gans») — nach den Nomen 2026-10-26
  'Garage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abstellraum für Autos / österr./schweiz.: Autowerkstatt) — nach den Nomen 2026-10-26
  'Garde', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Leibwache, Elitetruppe / übertragen: Gruppe «die alte Garde») — nach den Nomen 2026-10-26
  'Garderobe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kleiderablage / Kleidung, die jemand besitzt / Ankleideraum im Theater) — nach den Nomen 2026-10-26
  'Garnitur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Satz zusammengehöriger Teile (Sitzgarnitur, Wäsche) / übertragen: «die erste Garnitur») — nach den Nomen 2026-10-26
  'Gartenhaus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kleines Haus im Garten / Hinterhaus eines Wohnblocks) — nach den Nomen 2026-10-26
  'Gartenzwerg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zwergfigur im Garten / abwertend: kleiner, unbedeutender Mensch) — nach den Nomen 2026-10-26
  'Gas', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: luftförmiger Stoff, Brennstoff / ugs. Gaspedal «Gas geben») — nach den Nomen 2026-10-26
  'Gasse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: schmale Straße / österr.: Straße allgemein / Durchgang in einer Menschenmenge) — nach den Nomen 2026-10-26
  'Gastgeber', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: jemand, der Gäste empfängt / Sport: Heimmannschaft) — nach den Nomen 2026-10-26
  'Gastgeberin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Frau, die Gäste empfängt / Sport: Heimmannschaft) — nach den Nomen 2026-10-26
  'Gastronomie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gaststättengewerbe / feine Kochkunst) — nach den Nomen 2026-10-26
  'Gastspiel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Auftritt von Künstlern an einem fremden Ort / Sport: Auswärtsspiel) — nach den Nomen 2026-10-26
  'Gattung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Biologie: Gruppe verwandter Arten / Art, Sorte, z. B. literarische Gattung) — nach den Nomen 2026-10-26
  'Gau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 3 (Homograph: der Gau «Landschaft, Bezirk» / der GAU «größter anzunehmender Unfall») — nach den Nomen 2026-10-26
  'Gaukler', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Jahrmarktskünstler / übertragen: Betrüger, Schwindler) — nach den Nomen 2026-10-26
  'Gaumen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: obere Wölbung der Mundhöhle / Geschmackssinn «ein feiner Gaumen») — nach den Nomen 2026-10-26
  'Gauner', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Betrüger / ugs. scherzhaft: schlauer, gerissener Mensch) — nach den Nomen 2026-10-26
  'Gebein', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: gehoben: Knochengerüst / Plural: sterbliche Überreste «die Gebeine») — nach den Nomen 2026-10-26
  'Geber', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: jemand, der etwas gibt / Kartenspiel: wer die Karten gibt / Technik: Messfühler) — nach den Nomen 2026-10-26
  'Gebiet', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fläche, Region / Fachbereich «auf diesem Gebiet») — nach den Nomen 2026-10-26
  'Gebiss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: alle Zähne / Zahnprothese / Mundstück am Pferdezaum) — nach den Nomen 2026-10-26
  'Gebot', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gebot, Vorschrift (die Zehn Gebote) / Angebot bei einer Versteigerung) — nach den Nomen 2026-10-26
  'Gebrauch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Benutzen / Plural Gebräuche: Sitten, Bräuche) — nach den Nomen 2026-10-26
  'Geburt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Gebären, Entbindung / Herkunft, Abstammung «von Geburt Österreicher») — nach den Nomen 2026-10-26
  'Geburtshaus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Haus, in dem jemand geboren wurde / Einrichtung für Geburten mit Hebammen) — nach den Nomen 2026-10-26
  'Geburtsstunde', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stunde der Geburt / übertragen: Entstehung «die Geburtsstunde des Internets») — nach den Nomen 2026-10-26
  'Gefangener', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv/Partizip: der/die Gefangene, ein Gefangener) — nach den Nomen 2026-10-26
  'Geflecht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Flechtwerk / übertragen: Netz von Beziehungen) — nach den Nomen 2026-10-26
  'Gefolge', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Begleitung einer wichtigen Person / übertragen «im Gefolge von» = als Folge) — nach den Nomen 2026-10-26
  'Gefolgschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anhänger, Gefolge / Treue, Gehorsam «Gefolgschaft leisten») — nach den Nomen 2026-10-26
  'Gegengewicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gewicht, das ein anderes ausgleicht / übertragen: Ausgleich «ein Gegengewicht bilden») — nach den Nomen 2026-10-26
  'Gegenliebe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: erwiderte Liebe / Zustimmung «auf wenig Gegenliebe stoßen») — nach den Nomen 2026-10-26
  'Gegenpol', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Physik: entgegengesetzter Pol / übertragen: Gegenstück, Gegensatz) — nach den Nomen 2026-10-26
  'Gegensatz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gegenteil «im Gegensatz zu» / Meinungsverschiedenheit, Konflikt) — nach den Nomen 2026-10-26
  'Gegenseite', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: gegenüberliegende Seite / gegnerische Partei, z. B. vor Gericht) — nach den Nomen 2026-10-26
  'Gegenstand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ding, Objekt / Thema «Gegenstand der Diskussion» / österr.: Schulfach) — nach den Nomen 2026-10-26
  'Gegenstimme', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stimme gegen einen Antrag / Musik: Gegenstimme / abweichende Meinung) — nach den Nomen 2026-10-26
  'Gegenwart', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: jetzige Zeit / Anwesenheit «in Gegenwart von» / Grammatik: Präsens) — nach den Nomen 2026-10-26
  'Gegenwind', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wind von vorn / übertragen: Widerstand, Kritik) — nach den Nomen 2026-10-26
  'Gegenzug', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gegenmaßnahme «im Gegenzug» / Zug aus der Gegenrichtung / Spielzug im Schach) — nach den Nomen 2026-10-26
  'Gehege', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: eingezäuntes Gelände für Tiere / Jägersprache: Revier; «jemandem ins Gehege kommen») — nach den Nomen 2026-10-26
  'Gehen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Gehen allgemein / Sport: Gehen als Disziplin der Leichtathletik) — nach den Nomen 2026-10-26
  'Gehilfe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Helfer, Assistent / Recht: Gehilfe bei einer Straftat) — nach den Nomen 2026-10-26
  'Geier', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Greifvogel / abwertend: habgieriger Mensch; ugs. «Hol’s der Geier!») — nach den Nomen 2026-10-26
  'Geldmenge', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: eine bestimmte Menge Geld / Volkswirtschaft: gesamtes umlaufendes Geld) — nach den Nomen 2026-10-26
  'Gelegenheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: günstiger Augenblick / Anlass / Kaufmannssprache: Gelegenheitskauf) — nach den Nomen 2026-10-27
  'Gelehrte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Gelehrte) — nach den Nomen 2026-10-27
  'Geleit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Begleitung, «freies Geleit» / Schutzbegleitung (Geleitzug) / Geleitwort) — nach den Nomen 2026-10-27
  'Gelenk', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anatomie: Knochenverbindung / Technik: bewegliche Verbindung von Teilen) — nach den Nomen 2026-10-27
  'Geliebte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Geliebte) — nach den Nomen 2026-10-27
  'Geltung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gültigkeit / Ansehen, Wert / Wirkung «zur Geltung kommen») — nach den Nomen 2026-10-27
  'Gemeinde', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: politische Gemeinde / Kirchengemeinde / Gemeinschaft von Anhängern, z. B. Fangemeinde) — nach den Nomen 2026-10-27
  'Gemeindeammann', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen, schweiz.: Gemeindepräsident / Vollstreckungsbeamter) — nach den Nomen 2026-10-27
  'Gemeinderat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gremium der Gemeindevertretung / einzelnes Mitglied dieses Gremiums) — nach den Nomen 2026-10-27
  'Gemeinheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Charakter: Bosheit / gemeine Handlung / ugs. Ärgernis «So eine Gemeinheit!») — nach den Nomen 2026-10-27
  'Gemeinsamkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: gemeinsames Merkmal / Zusammengehörigkeit, gemeinsames Handeln) — nach den Nomen 2026-10-27
  'Gemeinschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zusammensein / Gruppe von Menschen / Staatenbund, z. B. Europäische Gemeinschaft) — nach den Nomen 2026-10-27
  'Gendarmeriebeamter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der Gendarmeriebeamte / ein Gendarmeriebeamter) — nach den Nomen 2026-10-27
  'General', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Offizier im höchsten Rang / katholisch: Oberhaupt eines Ordens) — nach den Nomen 2026-10-27
  'Generation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Altersgruppe / Glied in der Geschlechterfolge / Technik: Entwicklungsstufe, z. B. Handys der neuesten Generation) — nach den Nomen 2026-10-27
  'Generationswechsel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wechsel zur jüngeren Generation, z. B. in Führung / Biologie: Wechsel von geschlechtlicher und ungeschlechtlicher Fortpflanzung) — nach den Nomen 2026-10-27
  'Genesis', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: gehoben: Entstehung / Bibel: erstes Buch Mose) — nach den Nomen 2026-10-27
  'Genius', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: genialer Mensch, Schöpferkraft / Mythologie: Schutzgeist) — nach den Nomen 2026-10-27
  'Genosse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Parteigenosse, Anrede in sozialistischen Parteien / Mitglied einer Genossenschaft / veraltet: Gefährte) — nach den Nomen 2026-10-27
  'Genossin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (wie Genosse: Parteigenossin / Mitglied einer Genossenschaft) — nach den Nomen 2026-10-27
  'Genugtuung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wiedergutmachung «Genugtuung verlangen» / innere Befriedigung «mit Genugtuung») — nach den Nomen 2026-10-27
  'Genuss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zu-sich-Nehmen «der Genuss von Alkohol» / Freude, Wohlbehagen «ein Genuss»; auch «in den Genuss von etwas kommen») — nach den Nomen 2026-10-27
  'Gerade', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 + Fall 1 (wie ein Adjektiv gebeugt: eine Gerade, zwei Geraden; Bedeutungen: Mathematik: gerade Linie / Sport: gerades Teilstück der Bahn, Zielgerade / Boxen: gerader Stoß) — nach den Nomen 2026-10-27
  'Gerangel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rangelei, Balgerei / übertragen, abwertend: zähes Ringen um etwas, z. B. Posten) — nach den Nomen 2026-10-27
  'Gerede', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: abwertend: dummes, überflüssiges Reden / Klatsch, Gerüchte «ins Gerede kommen») — nach den Nomen 2026-10-27
  'Geruch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausdünstung, Duft «ein angenehmer Geruch» / Geruchssinn / gehoben: Ruf «in den Geruch kommen») — nach den Nomen 2026-10-27
  'Gesang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Singen «Unterricht in Gesang» / Lied «geistliche Gesänge» / Teil eines Epos) — nach den Nomen 2026-10-27
  'Geschichte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Historie, Vergangenheit / Erzählung, Story / ugs. Angelegenheit «eine dumme Geschichte») — nach den Nomen 2026-10-27
  'Geschirr', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Teller, Tassen usw. / Riemenzeug für Zugtiere, Pferdegeschirr) — nach den Nomen 2026-10-27
  'Geschlecht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: biologisches Geschlecht / Gattung, Generation, Familie «ein altes Geschlecht» / Grammatik: Genus / Geschlechtsteil) — nach den Nomen 2026-10-27
  'Geschmack', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschmackssinn, Geschmack von Speisen / ästhetisches Urteil «guten Geschmack haben» / Vorliebe «auf den Geschmack kommen») — nach den Nomen 2026-10-27
  'Geschmacklosigkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ohne Pl.: Mangel an Geschmack, Taktlosigkeit / zählbar: geschmacklose Äußerung oder Handlung) — nach den Nomen 2026-10-27
  'Geschoss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Projektil, Kugel / Stockwerk, Etage; österr. auch «Geschoß») — nach den Nomen 2026-10-27
  'Geschrei', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: lautes Schreien / ugs. abwertend: übertriebenes Klagen, Aufhebens «viel Geschrei um nichts») — nach den Nomen 2026-10-27
  'Geselle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Handwerker nach der Gesellenprüfung / veraltend: Kerl, Bursche «ein lustiger Geselle») — nach den Nomen 2026-10-27
  'Geselligkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ohne Pl.: Freude am Zusammensein / geselliges Beisammensein, Treffen) — nach den Nomen 2026-10-27
  'Gesellschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gemeinschaft der Menschen / Firma, z. B. GmbH / Begleitung «jemandem Gesellschaft leisten» / Veranstaltung, Fest) — nach den Nomen 2026-10-27
  'Gesellschafter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Teilhaber einer Firma / jemand, der Gesellschaft leistet, Unterhalter «ein guter Gesellschafter») — nach den Nomen 2026-10-27
  'Gesetz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: staatliches Gesetz / Gesetzmäßigkeit in Natur und Wissenschaft «Naturgesetz» / feste Regel «ungeschriebenes Gesetz») — nach den Nomen 2026-10-27
  'Gespann', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zugtiere mit Wagen / ugs. zwei zusammengehörende Menschen «ein gutes Gespann») — nach den Nomen 2026-10-27
  'Gespenst', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geist, Spuk / drohende Gefahr «das Gespenst der Arbeitslosigkeit») — nach den Nomen 2026-10-27
  'Gestalt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Körperform, Figur / Person, oft unbekannt «eine dunkle Gestalt» / Figur in Literatur / Form «Gestalt annehmen») — nach den Nomen 2026-10-27
  'Geste', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Handbewegung / symbolische Handlung «eine Geste der Versöhnung») — nach den Nomen 2026-10-27
  'Gestell', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Regal, Rahmen, Ständer / ugs. sehr dünner Mensch, Beine / Brillengestell) — nach den Nomen 2026-10-27
  'Getriebe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Technik: Zahnradgetriebe, z. B. im Auto / gehoben: lebhaftes Treiben «das Getriebe der Großstadt») — nach den Nomen 2026-10-27
  'Getto', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: historisch: abgesondertes jüdisches Wohnviertel / abgesondertes Viertel einer benachteiligten Gruppe / übertragen: Abschottung; auch «Ghetto») — nach den Nomen 2026-10-27
  'Gewalt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gewalttätigkeit / Macht, Herrschaft «die Staatsgewalt», «in seiner Gewalt» / Naturkraft «die Gewalt des Sturms») — nach den Nomen 2026-10-27
  'Gewand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: gehoben: langes, festliches Kleidungsstück / österr., süddt. ugs.: Kleidung allgemein / übertragen: äußere Aufmachung «im neuen Gewand») — nach den Nomen 2026-10-27
  'Gewebe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stoff, gewebtes Material / Biologie: Zellgewebe / übertragen: Geflecht «ein Gewebe aus Lügen») — nach den Nomen 2026-10-27
  'Gewerbe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: selbstständige Erwerbstätigkeit «ein Gewerbe anmelden» / Gesamtheit der Betriebe, Wirtschaftszweig / schweiz.: Bauernhof) — nach den Nomen 2026-10-27
  'Gewinn', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wirtschaft: Profit / Preis, Treffer in Lotterie oder Spiel / Nutzen, Bereicherung «ein Gewinn für das Team») — nach den Nomen 2026-10-27
  'Gezerre', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: dauerndes Zerren, Ziehen / übertragen, abwertend: langes Streiten, Feilschen «das Gezerre um den Haushalt») — nach den Nomen 2026-10-27
  'Gigant', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mythologie: Riese / übertragen: Großunternehmen, Riese «ein Gigant der Branche», etwas sehr Großes) — nach den Nomen 2026-10-27
  'Gilde', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: historisch: Zunft, Genossenschaft von Kaufleuten oder Handwerkern / Gruppe Gleichgesinnter, oft scherzhaft «die Gilde der Kritiker») — nach den Nomen 2026-10-27
  'Gips', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mineral, Baustoff / Medizin: Gipsverband «den Arm in Gips haben») — nach den Nomen 2026-10-27
  'Girl', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs.: Mädchen, junge Frau / Revuetänzerin, Mitglied einer Tanzgruppe) — nach den Nomen 2026-10-27
  'Glanz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schimmer, Leuchten / Pracht, Herrlichkeit «der Glanz vergangener Zeiten») — nach den Nomen 2026-10-27
  'Glanzlicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Malerei, Fotografie: hellster Lichtreflex / übertragen: Höhepunkt «ein Glanzlicht des Festivals») — nach den Nomen 2026-10-27
  'Glaube', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vertrauen, Überzeugung «der Glaube an + Akk» / religiöse Überzeugung, Religion, Konfession) — nach den Nomen 2026-10-27
  'Glaubensbekenntnis', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Religion: formelhafte Zusammenfassung des Glaubens, Credo / übertragen: persönliche Überzeugung, Weltanschauung) — nach den Nomen 2026-10-27
  'Gleichgewicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Physik: Zustand ausgeglichener Kräfte / körperliches Gleichgewicht, Balance / seelisches Gleichgewicht, Ausgeglichenheit) — nach den Nomen 2026-10-27
  'Gleichklang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musik: Zusammenklang von Tönen / übertragen: Übereinstimmung, Harmonie) — nach den Nomen 2026-10-27
  'Glied', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Körperteil, Arm/Bein / Teil einer Kette, Glied einer Reihe / Mitglied, Generation «bis ins dritte Glied» / männliches Glied) — nach den Nomen 2026-10-27
  'Glocke', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kirchenglocke, Klingel / glockenförmiger Gegenstand, z. B. Käseglocke, Taucherglocke) — nach den Nomen 2026-10-27
  'Gloria', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2 (Homograph mit anderem Artikel: das Gloria «Lobgesang in der Messe» / die Gloria «Ruhm, Glanz», oft ironisch; Liste nennt der) — nach den Nomen 2026-10-27
  'Glosse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Journalismus: kurzer, spöttischer Kommentar / Sprachwissenschaft: Erklärung, Randbemerkung zu einem Wort) — nach den Nomen 2026-10-27
  'Glut', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: glühende Masse, Kohlenglut / große Hitze / Leidenschaft «die Glut der Liebe») — nach den Nomen 2026-10-27
  'Gnade', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gunst, Wohlwollen eines Höhergestellten / Milde, Verzeihung, Begnadigung / Religion: Gnade Gottes) — nach den Nomen 2026-10-27
  'Goal', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen, österr./schweiz.: Tor als Gehäuse / erzielter Treffer) — nach den Nomen 2026-10-27
  'Gondel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: venezianisches Boot / Kabine einer Seilbahn / Korb eines Ballons / Verkaufsregal im Supermarkt) — nach den Nomen 2026-10-27
  'Goodwill', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wohlwollen, guter Wille / Wirtschaft: Firmenwert, Ansehen eines Unternehmens) — nach den Nomen 2026-10-27
  'Gorilla', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Menschenaffe / ugs.: Leibwächter, Türsteher) — nach den Nomen 2026-10-27
  'Gott', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Christentum/Monotheismus: der eine Gott / übermenschliches Wesen, Gottheit «die griechischen Götter») — nach den Nomen 2026-10-27
  'Graben', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rinne im Boden, Straßengraben / Militär: Schützengraben / Geologie: Grabenbruch) — nach den Nomen 2026-10-27
  'Grabenkampf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Militär: Kampf aus Schützengräben / übertragen: zäher, verbissener Streit) — nach den Nomen 2026-10-27
  'Grad', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Temperatur- und Winkelgrad / akademischer oder militärischer Rang / Maß, Ausmaß «in hohem Grad») — nach den Nomen 2026-10-27
  'Grafik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kunst: Grafik als Kunstwerk, Druckgrafik / Diagramm, Schaubild / Computergrafik, grafische Gestaltung) — nach den Nomen 2026-10-27
  'Grammatik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Regelsystem einer Sprache / Buch, Lehrbuch der Grammatik «eine Grammatik kaufen») — nach den Nomen 2026-10-27
  'Grat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bergkamm, schmaler Gebirgsrücken / Technik: scharfer Rand an Werkstücken) — nach den Nomen 2026-10-27
  'Gratwanderung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wanderung auf einem Grat / übertragen: heikles Vorgehen zwischen zwei Gefahren) — nach den Nomen 2026-10-27
  'Greif', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fabeltier mit Adlerkopf und Löwenkörper / Greifvogel) — nach den Nomen 2026-10-27
  'Grenzbereich', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gebiet an einer Grenze / übertragen: Bereich an der Grenze des Möglichen, Grenzfall) — nach den Nomen 2026-10-27
  'Grenze', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Staatsgrenze, Landesgrenze / Trennlinie zwischen Gebieten / übertragen: Schranke, Limit «an seine Grenzen stoßen») — nach den Nomen 2026-10-27
  'Grenzer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen, ugs.: Grenzsoldat, Grenzbeamter / Grenzbewohner) — nach den Nomen 2026-10-27
  'Grenzgebiet', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gebiet an der Grenze eines Staates / übertragen: Übergangsgebiet zwischen Fachgebieten) — nach den Nomen 2026-10-27
  'Grenzwert', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: zulässiger Höchstwert «Grenzwerte für Feinstaub» / Mathematik: Limes einer Folge oder Funktion) — nach den Nomen 2026-10-27
  'Griff', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Greifen, Zugreifen «ein fester Griff» / Handgriff, Teil zum Anfassen (Tür, Koffer) / Musik, Sport: Griff, Technik) — nach den Nomen 2026-10-27
  'Grille', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Insekt, Heimchen / veraltend: Laune, wunderlicher Einfall) — nach den Nomen 2026-10-27
  'Groschen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: österreichische Münze bis 2001 (1/100 Schilling) / ugs. deutsches Zehnpfennigstück / übertragen: wenig Geld «keinen Groschen haben») — nach den Nomen 2026-10-27
  'Groteske', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kunst: Ornament mit Fabelwesen / Literatur: groteske Erzählung / absurd-komische Situation) — nach den Nomen 2026-10-27
  'Grube', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Loch, Vertiefung im Boden / Bergwerk, Zeche) — nach den Nomen 2026-10-27
  'Grund', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ursache, Anlass / Erdboden, Grundstück «Grund und Boden» / Boden eines Gewässers oder Gefäßes) — nach den Nomen 2026-10-27
  'Grundgesetz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verfassung der Bundesrepublik Deutschland / allgemein: grundlegendes Gesetz, Grundprinzip «ein Grundgesetz der Natur») — nach den Nomen 2026-10-27
  'Grundlinie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport (Tennis): Linie am Ende des Spielfelds / Grundzug, Leitlinie «die Grundlinien der Politik» / Mathematik: Grundseite) — nach den Nomen 2026-10-27
  'Grundpreis', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Basispreis ohne Zuschläge, Grundgebühr / Preis je Mengeneinheit «Grundpreis pro Kilogramm») — nach den Nomen 2026-10-27
  'Grundriss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zeichnung eines Gebäudes von oben, Wohnungsplan / kurzes Lehrbuch, Abriss «Grundriss der deutschen Grammatik») — nach den Nomen 2026-10-27
  'Grundstoff', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rohstoff, Ausgangsmaterial für die Industrie / Chemie: chemisches Element) — nach den Nomen 2026-10-27
  'Grundton', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musik: Grundton einer Tonart / vorherrschende Farbe / übertragen: Grundstimmung «der Grundton der Rede») — nach den Nomen 2026-10-27
  'Grundwert', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: grundlegender ethischer Wert «Grundwerte der Demokratie» / Mathematik: Grundwert der Prozentrechnung) — nach den Nomen 2026-10-27
  'Grunge', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musikstil der 1990er-Jahre / Modestil, absichtlich nachlässige Kleidung) — nach den Nomen 2026-10-27
  'Gruppierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anordnung, Einteilung in Gruppen / Gruppe, Fraktion innerhalb einer Organisation) — nach den Nomen 2026-10-27
  'Guide', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Reiseführer als Person / Reiseführer als Buch, Handbuch) — nach den Nomen 2026-10-27
  'Gurke', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gemüse, Gewürzgurke / ugs. scherzhaft: große Nase, altes Auto) — nach den Nomen 2026-10-27
  'Guru', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: religiöser Lehrer im Hinduismus / übertragen: Leitfigur, Experte «ein Guru der Modewelt») — nach den Nomen 2026-10-27
  'Guss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gießen von Metall, Gussstück / kurzer, heftiger Regen / Zuckerguss, Glasur) — nach den Nomen 2026-10-27
  'Gusto', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschmack, Neigung «nach meinem Gusto» / österr.: Appetit, Lust auf etwas) — nach den Nomen 2026-10-27
  'Gut', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Besitz, Habe «Hab und Gut» / Landgut, Gutshof / Ware, Wirtschaftsgut «Güter des täglichen Bedarfs» / ethischer Wert «das höchste Gut») — nach den Nomen 2026-10-27
  'Dings', // zurückgestellt: ugs. Platzhalterwort (der/die/das Dings) — Genus nicht eindeutig (Regel 14) 2026-10-21
  'Direkteinspritzer', // zurückgestellt: Fachjargon (Motor mit Direkteinspritzung) — als Lernwort nicht sicher (Regel 14) 2026-10-21
  'Disc', // zurückgestellt: englische Schreibung (CD, Bandscheibe …) — Lemma/Bedeutung nicht sicher (Regel 14) 2026-10-21
  'Donna', // zurückgestellt: italienische Anrede/Vorname — Bedeutung und Gebrauch im Deutschen nicht sicher (Regel 14) 2026-10-22
  'Drost', // zurückgestellt: regionaler/historischer Amtstitel (Landdrost) — Bedeutung und Gebrauch nicht sicher (Regel 14) 2026-10-22
  'Duke', // zurückgestellt: englischer Adelstitel — als deutsches Nomen nicht gesichert (Regel 14) 2026-10-22
  'Eagle', // zurückgestellt: Golfbegriff (englisch) — als deutsches Nomen nicht gesichert (Regel 14) 2026-10-22
  'Ecker', // zurückgestellt: Buchecker bzw. Spielkartenfarbe (landschaftlich) — Bedeutung und Gebrauch nicht sicher (Regel 14) 2026-10-22
  'Eden', // zurückgestellt: biblischer Name (Garten Eden) — kein geografischer Name, Gebrauch als Nomen nicht sicher (Regel 14/18) 2026-10-22
  'Egli', // zurückgestellt: schweizerisch für Flussbarsch, auch Familienname — nicht sicher (Regel 14) 2026-10-22
  'Eicher', // zurückgestellt: Eichmeister bzw. Familien-/Markenname — Bedeutung und Gebrauch nicht sicher (Regel 14) 2026-10-23
  'Eigen', // zurückgestellt: das Eigen (gehoben, fast nur «sein Eigen nennen», «zu eigen») — als eigenes Nomen nicht sicher (Regel 14) 2026-10-23
  'Einst', // zurückgestellt: das Einst (gehoben, «das Einst und Jetzt») — als eigenes Nomen nicht sicher (Regel 14) 2026-10-23
  'Emd', // zurückgestellt: das Emd (schweizerisch/landschaftlich für Grummet, zweiter Heuschnitt) — regional, Gebrauch und Plural nicht sicher (Regel 14) 2026-10-23
  'Erachten', // zurückgestellt: das Erachten (gehoben, fast nur «meines Erachtens», «nach meinem Erachten») — als eigenes Nomen nicht sicher (Regel 14) 2026-10-25
  'Ermangelung', // zurückgestellt: die Ermangelung (gehoben, fast nur «in Ermangelung + Gen») — als eigenes Nomen nicht sicher (Regel 14) 2026-10-25
  'Etter', // zurückgestellt: der Etter (südd./schweiz.: Gemarkung, bebautes Ortsgebiet; auch Zaun) — regional, Genus und Gebrauch nicht sicher (Regel 14) 2026-10-25
  'Etwas', // zurückgestellt: das Etwas (substantiviertes Pronomen, fast nur «das gewisse Etwas», «ein kleines Etwas») — als eigenes Nomen nicht sicher (Regel 14) 2026-10-25
  'Eurofighter', // zurückgestellt: Produkt-/Markenname (Kampfflugzeug), kein geografischer Name — nicht bauen (Regel 18) 2026-10-25
  'Europaliga', // zurückgestellt: deutsche Bezeichnung für die «Europa League» (Fußball) — als deutsches Nomen nicht gesichert (Regel 14) 2026-10-25
  'Eurotunnel', // zurückgestellt: Name eines Bauwerks bzw. der Betreibergesellschaft (Ärmelkanaltunnel), kein geografischer Name — nicht bauen (Regel 18) 2026-10-25
  'Eurovision', // zurückgestellt: Name einer Organisation bzw. eines Fernsehverbunds, kein geografischer Name — nicht bauen (Regel 18) 2026-10-25
  'Eva', // zurückgestellt: weiblicher Vorname (biblisch) — Personenname, nicht bauen (Regel 18) 2026-10-25
  'Event', // zurückgestellt: der oder das Event — Genus nicht eindeutig (Regel 14) 2026-10-25
  'Evergreen', // zurückgestellt: der oder das Evergreen — Genus nicht eindeutig (Regel 14) 2026-10-25
  'Exchange', // zurückgestellt: englisches Wort (Börse, Tausch) — als deutsches Nomen nicht gesichert (Regel 14) 2026-10-25
  'Faber', // zurückgestellt: Personen- bzw. Markenname (z. B. Faber-Castell), kein Gattungsnomen — nicht bauen (Regel 18) 2026-10-25
  'Face', // zurückgestellt: englisches Wort (ugs./Jugendsprache: Gesicht) — als deutsches Nomen nicht gesichert, Genus unklar (Regel 14) 2026-10-25
  'Fakt', // zurückgestellt: der oder das Fakt — Genus nicht eindeutig (Regel 14) 2026-10-25
  'Fashion', // zurückgestellt: englisches Wort (Mode) — als deutsches Nomen nicht gesichert (Regel 14) 2026-10-25
  'Faxe', // zurückgestellt: meist Plural «die Faxen» (Unsinn, Albernheiten); Singular «die Faxe» unüblich — Lemma nicht sicher (Regel 14) 2026-10-25
  'Feature', // zurückgestellt: das oder die Feature — Genus nicht eindeutig, mehrere Bedeutungen (Regel 14) 2026-10-25
  'Federspiel', // zurückgestellt: Fachwort der Falknerei bzw. Spiel — Bedeutung als Lernwort nicht sicher (Regel 14) 2026-10-25
  'Ferner', // zurückgestellt: kein klares Nomen: Komparativ/Adverb «ferner»; regional (Tirol) auch: der Ferner = Gletscher — Lemma nicht sicher (Regel 14) 2026-10-25
  'Fiction', // zurückgestellt: englisches Wort (Belletristik) — als deutsches Nomen nicht gesichert (Regel 14) 2026-10-26
  'Fidel', // zurückgestellt: mehrdeutig: Eigenname bzw. altes Streichinstrument «die Fidel» — Lemma nicht sicher (Regel 14) 2026-10-26
  'Figaro', // zurückgestellt: Name einer Bühnenfigur bzw. scherzhaft «Friseur» — Eigenname, nicht bauen (Regel 18) 2026-10-26
  'Fighter', // zurückgestellt: englisches Wort (Kämpfer) — als deutsches Nomen nicht gesichert (Regel 14) 2026-10-26
  'File', // zurückgestellt: englisches Wort (Datei) — als deutsches Nomen nicht gesichert, Genus unklar (Regel 14) 2026-10-26
  'Finanz', // zurückgestellt: Singular unüblich (meist Plural «die Finanzen»; österr. ugs. «die Finanz» = Finanzamt) — Lemma nicht sicher (Regel 14) 2026-10-26
  'Fine', // zurückgestellt: kein deutsches Nomen (ital. Musikbegriff «fine» = Ende) — Lemma nicht sicher (Regel 14) 2026-10-26
  'Finke', // zurückgestellt: Nebenform von «der Fink» bzw. Familienname — Lemma nicht sicher (Regel 14) 2026-10-26
  'Fis', // zurückgestellt: Musik: Tonbezeichnung (das Fis) — sehr fachlich, Schreibung/Genus als Lernwort unsicher (Regel 14) 2026-10-26
  'Fitz', // zurückgestellt: kein gesichertes Gattungsnomen (landschaftlich «Fitz» = Faden, Wirrwarr; sonst Familienname) (Regel 14) 2026-10-26
  'Fixing', // zurückgestellt: englischer Fachbegriff der Börse (Kursfeststellung) — als deutsches Nomen nicht gesichert (Regel 14) 2026-10-26
  'Flach', // zurückgestellt: kein Nomen (Adjektiv «flach»); Substantivierung unklar (Regel 14) 2026-10-26
  'Flair', // zurückgestellt: das Flair (seltener: der Flair) — Genus nicht eindeutig (Regel 14) 2026-10-26
  'Flash', // zurückgestellt: englisches Wort (Blitz, Rauschgift-Wirkung) — als deutsches Nomen nicht gesichert (Regel 14) 2026-10-26
  'Force', // zurückgestellt: kein deutsches Nomen (engl./frz. «force»; nur in «Task-Force», «Force majeure») (Regel 14) 2026-10-26
  'Fortune', // zurückgestellt: Schreibung schwankt (die Fortune / Fortüne), veraltend — Lemma nicht sicher (Regel 14) 2026-10-26
  'Fox', // zurückgestellt: kein gesichertes Nomen (Kurzform von Foxtrott bzw. Foxterrier; engl. «fox») (Regel 14) 2026-10-26
  'Freestyle', // zurückgestellt: englisches Wort (Sport, Musik) — Genus und Gebrauch als deutsches Nomen nicht gesichert (Regel 14) 2026-10-26
  'Friaul', // zurückgestellt: Region in Italien — Gebrauch mit/ohne Artikel schwankt («das Friaul» / «in Friaul»), Lemma nicht sicher (Regel 14/18) 2026-10-26
  'Funkbild', // zurückgestellt: veraltet (per Funk übertragenes Bild) — als Lernwort nicht gesichert (Regel 14) 2026-10-26
  'Furore', // zurückgestellt: Genus schwankt (die Furore / österr. das Furore), meist nur in «Furore machen» (Regel 14) 2026-10-26
  'Gabler', // zurückgestellt: Bedeutung unklar (Jägersprache: Rehbock mit Gabelgeweih bzw. Familienname) — nicht sicher (Regel 14) 2026-10-26
  'Gal', // zurückgestellt: Fachwort (physikalische Einheit der Beschleunigung) bzw. Abkürzung — als Lernwort nicht gesichert (Regel 14) 2026-10-26
  'Gams', // zurückgestellt: Genus schwankt (die Gams / Jägersprache der oder das Gams; standardsprachlich die Gämse) (Regel 14) 2026-10-26
  'Garaus', // zurückgestellt: nur in der festen Wendung «jemandem/etwas den Garaus machen» — als eigenes Nomen nicht sinnvoll (Regel 14) 2026-10-26
  'Gatt', // zurückgestellt: Seemannssprache (enge Durchfahrt, Loch im Schiff) — Genus/Plural und Gebrauch nicht sicher (Regel 14) 2026-10-26
  'Gault', // zurückgestellt: Bedeutung unklar (Fachbegriff der Geologie bzw. Eigenname) — nicht sicher (Regel 14) 2026-10-26
  'Gebauer', // zurückgestellt: veraltet/landschaftlich (Vogelkäfig) bzw. Familienname — nicht sicher (Regel 14) 2026-10-26
  'Geldhahn', // zurückgestellt: nur in der festen Wendung «jemandem den Geldhahn zudrehen» — als eigenes Nomen nicht sinnvoll (Regel 14) 2026-10-26
  'Gemeindevorstand', // zurückgestellt: Bedeutung je nach Land verschieden (Gremium der Gemeindeleitung / Gemeindevorsteher, Mitglied) — nicht sicher (Regel 14) 2026-10-27
  'Generale', // zurückgestellt: nur Pluralform von «General» (General steht in der Vier-Fälle-Liste) — kein eigenes Nomen 2026-10-27
  'Haben', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kaufmannssprache Habenseite «Soll und Haben» / substantivierter Infinitiv: das Besitzen) — nach den Nomen 2026-10-28
  'Haberer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen, österr. ugs.: Kumpel, Freund / Liebhaber, fester Freund) — nach den Nomen 2026-10-28
  'Habitus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erscheinungsbild, Auftreten, Haltung / Medizin: Körperbau, Konstitution) — nach den Nomen 2026-10-28
  'Hahn', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: männliches Huhn / Wasserhahn, Zapfhahn / Abzugshahn einer Waffe) — nach den Nomen 2026-10-28
  'Hahnenkamm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kamm des Hahns / Pflanze (Celosia) / Berg und Skirennen bei Kitzbühel) — nach den Nomen 2026-10-28
  'Haken', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Haken zum Aufhängen / ugs. Schwierigkeit «die Sache hat einen Haken» / Häkchen, Zeichen / Boxen: Haken) — nach den Nomen 2026-10-28
  'Halbe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: die Halbe / eine Halbe = halber Liter Bier, bayr./österr.) — nach den Nomen 2026-10-28
  'Halbzeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hälfte der Spielzeit «die zweite Halbzeit» / Pause zwischen den Hälften «zur Halbzeit») — nach den Nomen 2026-10-28
  'Halde', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufschüttung, Abraumhalde, Lager «auf Halde produzieren» / landschaftlich: Berghang) — nach den Nomen 2026-10-28
  'Halle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2 (Homograph: die Halle = großer Raum, Sporthalle / Halle (Saale) = Stadt, das) — nach den Nomen 2026-10-28
  'Halt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anhalten, Stopp «Halt machen» / Stütze, innere Stabilität «Halt geben, keinen Halt finden») — nach den Nomen 2026-10-28
  'Halter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorrichtung zum Halten «Handyhalter» / Besitzer, Fahrzeug- oder Tierhalter) — nach den Nomen 2026-10-28
  'Haltung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Körperhaltung / Einstellung, Meinung / Tierhaltung) — nach den Nomen 2026-10-28
  'Hammer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Werkzeug / Sport: Hammerwurf-Gerät / ugs. «Das ist der Hammer!» = unglaublich) — nach den Nomen 2026-10-28
  'Handarbeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Arbeit mit der Hand, handgefertigt / Nähen, Stricken, Sticken als Tätigkeit oder Gegenstand) — nach den Nomen 2026-10-28
  'Handball', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sportart / der Ball selbst) — wie Basketball — nach den Nomen 2026-10-28
  'Handeln', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: substantivierter Infinitiv: Tun, Vorgehen «schnelles Handeln» / Feilschen, Handeltreiben) — nach den Nomen 2026-10-28
  'Handelsbilanz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bilanz eines Kaufmanns, Jahresabschluss / Außenhandelsbilanz eines Landes, Export minus Import) — nach den Nomen 2026-10-28
  'Handgriff', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Griff zum Festhalten, Henkel / kurze Handbewegung, Tätigkeit «mit wenigen Handgriffen») — nach den Nomen 2026-10-28
  'Handicap', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Behinderung, Nachteil / Sport: Vorgabe, Golf-Handicap) — nach den Nomen 2026-10-28
  'Handlanger', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hilfsarbeiter am Bau / abwertend: Helfershelfer, Werkzeug anderer) — nach den Nomen 2026-10-28
  'Handlung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tat, Tun / Geschehen in Roman oder Film / Geschäft, Laden «Buchhandlung») — nach den Nomen 2026-10-28
  'Handschrift', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: persönliche Schrift / handgeschriebenes Buch, Manuskript / übertragen: persönlicher Stil «trägt seine Handschrift») — nach den Nomen 2026-10-28
  'Hang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abhang, Berghang / Neigung, Vorliebe «einen Hang zu etwas haben») — nach den Nomen 2026-10-28
  'Hanseat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: historisch: Mitglied der Hanse, Kaufmann / Bewohner einer Hansestadt, bes. Hamburg, Bremen) — nach den Nomen 2026-10-28
  'Hardcore', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musikrichtung (Punk) / pornografischer Film mit expliziten Szenen / ugs.: extrem, kompromisslos) — nach den Nomen 2026-10-28
  'Harmonie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musik: Zusammenklang / Einklang, Eintracht zwischen Menschen / Ebenmaß der Teile) — nach den Nomen 2026-10-28
  'Harmonika', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ziehharmonika, Akkordeon / Mundharmonika) — nach den Nomen 2026-10-28
  'Harnisch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ritterrüstung / Weberei: Teil des Webstuhls / Wendung «in Harnisch geraten» = wütend werden) — nach den Nomen 2026-10-28
  'Hatz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hetzjagd, Treibjagd auf Tiere / landschaftlich, ugs.: Hast, Eile, Stress) — nach den Nomen 2026-10-28
  'Haube', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kopfbedeckung, Mütze / Motorhaube / Auszeichnung in der Gastronomie (Gault-Millau) / «unter die Haube kommen» = heiraten) — nach den Nomen 2026-10-28
  'Hauch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Atem, Luftzug / Spur, ein wenig «ein Hauch von Parfüm») — nach den Nomen 2026-10-28
  'Hauer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Eckzahn des Keilers / Bergmann, der Gestein abbaut) — nach den Nomen 2026-10-28
  'Haufen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: aufgeschüttete Menge «ein Haufen Sand» / ugs. große Menge, viele «ein Haufen Arbeit») — nach den Nomen 2026-10-28
  'Haupt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: gehoben: Kopf / Oberhaupt, Anführer «das Haupt der Familie») — nach den Nomen 2026-10-28
  'Hauptangeklagte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Hauptangeklagte) — nach den Nomen 2026-10-28
  'Haus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gebäude / Haushalt, Familie, Dynastie «das Haus Habsburg» / Firma, Institution «im Haus» / Theater, Parlamentskammer) — nach den Nomen 2026-10-28
  'Hausarbeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Arbeit im Haushalt / schriftliche Arbeit für Schule oder Studium, Seminararbeit) — nach den Nomen 2026-10-28
  'Haushalt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wohnung und Hausarbeit, Familie «ein Haushalt mit drei Personen» / Staatshaushalt, Etat) — nach den Nomen 2026-10-28
  'Haushaltsberatung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beratung über den Staatshaushalt im Parlament / Beratung für private Haushalte, z. B. Schulden- oder Energieberatung) — nach den Nomen 2026-10-28
  'Hausherr', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gastgeber, Haushaltsvorstand / Hausbesitzer, Vermieter / Sport: Heimmannschaft «die Hausherren») — nach den Nomen 2026-10-28
  'Havarie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Unfall eines Schiffs oder Flugzeugs / Schaden an Schiff oder Ladung / österr.: Autounfall, Schaden an einem Gerät) — nach den Nomen 2026-10-28
  'Heber', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gerät zum Heben, Wagenheber / Saugheber, Pipette / Sportler: Gewichtheber) — nach den Nomen 2026-10-28
  'Hebung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Heben, Anheben / Verbesserung «Hebung des Lebensstandards» / Geologie: Erdhebung / Verslehre: betonte Silbe) — nach den Nomen 2026-10-28
  'Heil', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wohlergehen, Glück «sein Heil versuchen» / Religion: Erlösung / Grußformel, auch historisch belastet) — nach den Nomen 2026-10-28
  'Heilbad', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kurort mit Heilquelle / medizinisches Bad zur Behandlung) — nach den Nomen 2026-10-28
  'Heilige', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Heilige) — nach den Nomen 2026-10-28
  'Heiliger', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (stark gebeugte Form von «der/die Heilige», substantiviertes Adjektiv) — nach den Nomen 2026-10-28
  'Heim', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zuhause, Wohnung «ein gemütliches Heim» / Einrichtung: Alten-, Kinder-, Studentenheim) — nach den Nomen 2026-10-28
  'Helle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2/4 (die Helle «Helligkeit» ↔ das Helle «helles Bier», substantiviertes Adjektiv) — nach den Nomen 2026-10-28
  'Herabsetzung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Senkung, Verringerung «Herabsetzung der Preise» / Kränkung, Abwertung einer Person) — nach den Nomen 2026-10-28
  'Herausgabe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aushändigung, Rückgabe «Herausgabe der Dokumente» / Veröffentlichung eines Buches oder einer Zeitung) — nach den Nomen 2026-10-28
  'Herd', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Küchenherd zum Kochen / Ausgangspunkt «Krankheitsherd, Brandherd» / gehoben: Zuhause «der eigene Herd») — nach den Nomen 2026-10-28
  'Hering', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fisch / Zeltpflock, Zelthering) — nach den Nomen 2026-10-28
  'Herr', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anrede, Mann «Herr Müller» / Herrscher, Gebieter «Herr im Haus» / Religion: Gott «der Herr») — nach den Nomen 2026-10-28
  'Herrenhaus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gutshaus eines Adligen / historisch: Erste Kammer des Parlaments, z. B. österreichisches Herrenhaus) — nach den Nomen 2026-10-28
  'Herrschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Macht, Regierung «unter der Herrschaft des Königs» / Plural als Anrede «meine Herrschaften» / früher: Dienstherren eines Hauses) — nach den Nomen 2026-10-28
  'Herz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Organ / Gefühl, Gemüt «ein gutes Herz» / Mitte, Zentrum «im Herzen der Stadt» / Spielkartenfarbe) — nach den Nomen 2026-10-28
  'Herzblatt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kosewort für einen geliebten Menschen / Botanik: inneres, junges Blatt einer Pflanze) — nach den Nomen 2026-10-28
  'Herzschlag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: einzelner Schlag des Herzens, Puls / plötzlicher Herztod «an einem Herzschlag sterben») — nach den Nomen 2026-10-28
  'Hetze', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hast, Eile, Stress / hetzerische Stimmungsmache gegen Menschen «Hetze gegen Flüchtlinge») — nach den Nomen 2026-10-28
  'Hetzjagd', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Jagd mit Hunden auf Tiere / Verfolgung von Menschen, auch Medienkampagne / große Eile) — nach den Nomen 2026-10-28
  'Hilfestellung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport/Turnen: Sicherung beim Üben / allgemein: Unterstützung, Hilfe «Hilfestellung geben») — nach den Nomen 2026-10-28
  'Himmel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Luftraum über der Erde «blauer Himmel» / Religion: Aufenthalt Gottes, Paradies / Baldachin «Betthimmel») — nach den Nomen 2026-10-28
  'Himmelfahrt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Auffahrt in den Himmel (Religion) / Feiertag «Christi Himmelfahrt») — nach den Nomen 2026-10-28
  'Hinterbliebene', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Hinterbliebene, ein Hinterbliebener) — nach den Nomen 2026-10-28
  'Hintergrund', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: hinterer Teil eines Bildes/Raumes / unauffällige Stelle «im Hintergrund bleiben» / Umstände, Zusammenhänge «die Hintergründe einer Tat») — nach den Nomen 2026-10-28
  'Hinterhand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: hinterer Teil eines Pferdes / Kartenspiel: Spieler, der zuletzt ausspielt «etwas in der Hinterhand haben») — nach den Nomen 2026-10-28
  'Hintermann', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Person dahinter (Schlange, Verkehr) / Drahtzieher im Verborgenen «die Hintermänner eines Anschlags») — nach den Nomen 2026-10-28
  'Hinterteil', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gesäß (ugs.) / hinterer Teil einer Sache) — nach den Nomen 2026-10-28
  'Hirn', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gehirn / Hirn als Speise «Kalbshirn» / Verstand (ugs.) «sein Hirn anstrengen») — nach den Nomen 2026-10-28
  'Hirt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: jemand, der eine Herde hütet / Religion: Seelsorger «der gute Hirte»; Nebenform zu Hirte) — nach den Nomen 2026-10-28
  'Hirte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: jemand, der eine Herde hütet / Religion: Seelsorger «der gute Hirte») — nach den Nomen 2026-10-28
  'Historie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschichte, Geschichtswissenschaft (veraltend) / (veraltet) Bericht, Erzählung) — nach den Nomen 2026-10-28
  'Hit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: erfolgreiches Lied / etwas sehr Erfolgreiches, Verkaufsschlager / (Jargon) Portion Rauschgift) — nach den Nomen 2026-10-28
  'Hoch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hochdruckgebiet (Wetter) / Hochruf «ein Hoch auf das Brautpaar» / Höhepunkt «ein Hoch erleben») — nach den Nomen 2026-10-28
  'Hochkultur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: hoch entwickelte Kultur einer frühen Gesellschaft «die Hochkultur der Maya» / anspruchsvolle Kunst im Gegensatz zur Populärkultur) — nach den Nomen 2026-10-28
  'Hochspannung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: elektrische Hochspannung / große Spannung, Nervenkitzel «ein Krimi voller Hochspannung») — nach den Nomen 2026-10-28
  'Hochtour', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bergtour im Hochgebirge / nur Plural «auf Hochtouren laufen» = mit voller Kraft) — nach den Nomen 2026-10-28
  'Hochwasser', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: hoher Wasserstand, Überschwemmung eines Flusses / Flut am Meer / (ugs.) zu kurze Hose «Hochwasser haben») — nach den Nomen 2026-10-28
  'Hochzeitstag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tag der Hochzeit / jährlicher Jahrestag der Hochzeit) — nach den Nomen 2026-10-28
  'Hof', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Platz hinter/zwischen Gebäuden / Bauernhof / Fürstenhof «am Hof des Kaisers» / Lichtkranz um Sonne oder Mond) — nach den Nomen 2026-10-28
  'Hofmeister', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen (veraltet): Verwalter eines Gutshofs / Hauslehrer und Erzieher adliger Kinder) — nach den Nomen 2026-10-28
  'Hofrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: früher Beamter eines Fürstenhofs / (österr.) Ehrentitel für hohe Beamte «Herr Hofrat») — nach den Nomen 2026-10-28
  'Hoheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: staatliche Souveränität «die Hoheit über ein Gebiet» / Titel und Anrede fürstlicher Personen «Eure Hoheit» / Erhabenheit) — nach den Nomen 2026-10-28
  'Holzbau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bauweise mit Holz / Gebäude aus Holz) — nach den Nomen 2026-10-28
  'Holzschnitt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: grafische Technik / einzelnes so hergestelltes Bild) — nach den Nomen 2026-10-28
  'Holzweg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Waldweg zum Holztransport / übertragen «auf dem Holzweg sein» = sich irren) — nach den Nomen 2026-10-28
  'Homburg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 3 (Homograph: Homburg, Stadt / der Homburg, Herrenhut) — nach den Nomen 2026-10-28
  'Horizont', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Linie zwischen Himmel und Erde / geistiger Gesichtskreis «seinen Horizont erweitern») — nach den Nomen 2026-10-28
  'Horn', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Horn eines Tieres / Blechblasinstrument / Hornsubstanz als Material) — nach den Nomen 2026-10-28
  'Hort', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kinderhort, Nachmittagsbetreuung / (gehoben) Zuflucht, Stätte «ein Hort der Freiheit» / (dichterisch) Schatz) — nach den Nomen 2026-10-28
  'Hospital', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: (veraltend) Krankenhaus / (veraltet) Pflegeheim, Altenheim) — nach den Nomen 2026-10-28
  'Hospiz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einrichtung zur Begleitung Sterbender / Herberge im Gebirge / christlich geführtes Hotel) — nach den Nomen 2026-10-28
  'Huhn', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Haushuhn als Tier / Fleisch «Huhn mit Reis» / (ugs.) Person «ein dummes Huhn») — nach den Nomen 2026-10-28
  'Humanismus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: geistige Bewegung der Renaissance / Denken und Handeln im Sinne der Menschlichkeit) — nach den Nomen 2026-10-28
  'Humanist', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vertreter des Humanismus / Kenner der alten Sprachen) — nach den Nomen 2026-10-28
  'Hund', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Haustier / (ugs., Schimpfwort) Mensch «gemeiner Hund» / Bergbau: Förderwagen) — nach den Nomen 2026-10-28
  'Hunderter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hunderteuroschein / Zahl an der Hunderterstelle) — nach den Nomen 2026-10-28
  'Hymne', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: feierlicher Lobgesang, Gedicht / Nationalhymne) — nach den Nomen 2026-10-28
  'Hymnus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: (gehoben) Lobgesang, Hymne / Kirchenlied der Liturgie) — nach den Nomen 2026-10-28
  'Hypothek', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Grundpfandrecht, Immobilienkredit / übertragen: Belastung «eine schwere Hypothek für die Zukunft») — nach den Nomen 2026-10-28
  'Hysterie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Medizin (veraltet): psychische Störung / übertragen: übertriebene Aufregung «Massenhysterie») — nach den Nomen 2026-10-28
  'Ich', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das eigene Selbst «mein anderes Ich» / Psychoanalyse: Ich (neben Es und Über-Ich)) — nach den Nomen 2026-10-28
  'Ideal', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Inbegriff der Vollkommenheit, Vorbild / erstrebenswerter Wert «seine Ideale verraten») — nach den Nomen 2026-10-28
  'Idealismus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Philosophie (deutscher Idealismus) / selbstloses Streben nach Idealen) — nach den Nomen 2026-10-28
  'Idealist', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mensch, der nach Idealen strebt / Vertreter des philosophischen Idealismus) — nach den Nomen 2026-10-28
  'Idee', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einfall, Gedanke / Philosophie: Urbild / (ugs.) ein bisschen «eine Idee mehr Salz») — nach den Nomen 2026-10-28
  'Identifikation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Feststellung der Identität «Identifikation des Opfers» / psychisch: sich mit jemandem gleichsetzen) — nach den Nomen 2026-10-28
  'Identifizierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Feststellung der Identität «Identifizierung des Toten» / innere Gleichsetzung mit jemandem) — nach den Nomen 2026-10-28
  'Idiom', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spracheigentümlichkeit einer Gruppe, Mundart / feste Redewendung) — nach den Nomen 2026-10-28
  'Idiot', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: (ugs., Schimpfwort) Dummkopf / (veraltet, Medizin) geistig schwer behinderter Mensch) — nach den Nomen 2026-10-28
  'Idol', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: verehrtes Vorbild «Idol der Jugend» / Götzenbild) — nach den Nomen 2026-10-28
  'Idylle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Literatur: Hirtendichtung / = das Idyll, friedlicher Zustand) — nach den Nomen 2026-10-28
  'Ikone', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Heiligenbild der Ostkirche / Kultfigur, Symbol «eine Ikone der Mode» / Bildschirmsymbol) — nach den Nomen 2026-10-28
  'Illusion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: falsche Hoffnung «sich Illusionen machen» / Sinnestäuschung «optische Illusion» / Zauberkunst) — nach den Nomen 2026-10-28
  'Illustration', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bild in einem Buch / Veranschaulichung, Erläuterung) — nach den Nomen 2026-10-28
  'Imam', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorbeter in der Moschee / Ehrentitel, im schiitischen Islam: einer der zwölf Imame) — nach den Nomen 2026-10-28
  'Imbiss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kleine Mahlzeit / Imbissstube, Imbissstand) — nach den Nomen 2026-10-28
  'Imitation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nachahmung / minderwertige Nachbildung «Imitation aus Plastik» / Musik: Wiederholung eines Themas in einer anderen Stimme) — nach den Nomen 2026-10-29
  'Imperativ', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Grammatik: Befehlsform / Philosophie: Pflichtgebot «kategorischer Imperativ») — nach den Nomen 2026-10-29
  'Imperium', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kaiserreich, Weltreich «das Römische Imperium» / übertragen: großer Machtbereich «Wirtschaftsimperium») — nach den Nomen 2026-10-29
  'Import', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einfuhr von Waren / eingeführte Ware (meist Pl. «Importe») / EDV: Übernahme von Daten) — nach den Nomen 2026-10-29
  'Impression', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Eindruck, Sinneswahrnehmung / Medizin: Eindellung eines Organs) — nach den Nomen 2026-10-29
  'Impuls', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anstoß, Anregung / innere Regung, Antrieb / Physik: Bewegungsgröße / Elektrotechnik: Stromstoß) — nach den Nomen 2026-10-29
  'Inanspruchnahme', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nutzung «Inanspruchnahme einer Leistung» / Belastung, Beanspruchung «starke berufliche Inanspruchnahme») — nach den Nomen 2026-10-29
  'Index', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verzeichnis, Register / Kennzahl «Preisindex» / kirchliches Verbotsverzeichnis «auf dem Index» / Mathematik: Kennziffer) — nach den Nomen 2026-10-29
  'Indikation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Medizin: Grund für eine Behandlung / Recht: Grund für einen erlaubten Schwangerschaftsabbruch) — nach den Nomen 2026-10-29
  'Indikator', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anzeichen, Merkmal / Chemie: Stoff, der durch Farbe etwas anzeigt / Technik: Messgerät) — nach den Nomen 2026-10-29
  'Individualismus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Philosophie: Lehre vom Vorrang des Einzelnen / Haltung, die das Eigene betont) — nach den Nomen 2026-10-29
  'Individualist', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mensch mit ausgeprägter Eigenart / Vertreter des philosophischen Individualismus) — nach den Nomen 2026-10-29
  'Individuum', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einzelwesen, Mensch / abwertend: zweifelhafte Person «ein verdächtiges Individuum» / Biologie: Einzelorganismus) — nach den Nomen 2026-10-29
  'Industrieller', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der Industrielle / ein Industrieller) — nach den Nomen 2026-10-29
  'Inferno', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hölle «Dantes Inferno» / übertragen: schreckliches Geschehen «Flammeninferno») — nach den Nomen 2026-10-29
  'Inflation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geldentwertung / übertragen: übermäßige Ausweitung «eine Inflation von Preisen, Titeln») — nach den Nomen 2026-10-29
  'Information', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Auskunft, Nachricht / Auskunftsschalter «an der Information fragen» / Informatik: Information als Datenmenge) — nach den Nomen 2026-10-29
  'Informationsstand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stand mit Informationen, Infostand / Grad der Informiertheit «nach dem jetzigen Informationsstand») — nach den Nomen 2026-10-29
  'Inhalt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Enthaltene «Inhalt der Flasche» / Gedankengehalt «Inhalt eines Buches» / Mathematik: Flächen- oder Rauminhalt) — nach den Nomen 2026-10-29
  'Initiative', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anstoß, Entschlusskraft «die Initiative ergreifen» / Gruppe mit gemeinsamem Ziel «Bürgerinitiative» / schweiz.: Volksbegehren) — nach den Nomen 2026-10-29
  'Injektion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Medizin: Einspritzung, Spritze / Bautechnik, Geologie: Einpressen von Material) — nach den Nomen 2026-10-29
  'Inka', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Herrscher des Inkareichs / Angehöriger des Volkes der Inka) — nach den Nomen 2026-10-29
  'Inkarnation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Religion: Fleischwerdung, Menschwerdung / Verkörperung «die Inkarnation des Bösen») — nach den Nomen 2026-10-29
  'Inland', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: eigenes Staatsgebiet, Gegensatz zu Ausland / Binnenland, von der Küste entfernt) — nach den Nomen 2026-10-29
  'Innenleben', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Seelenleben, innere Gefühle / ugs.: innerer Aufbau eines Geräts «das Innenleben des Computers») — nach den Nomen 2026-10-29
  'Inquisition', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschichte: kirchliches Gericht gegen Ketzer / strenges, peinliches Verhör) — nach den Nomen 2026-10-29
  'Insasse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fahrgast eines Fahrzeugs / Bewohner eines Heims, Gefangener einer Anstalt) — nach den Nomen 2026-10-29
  'Inspekteur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Leiter einer Inspektion, Prüfer / Bundeswehr: höchster Offizier einer Teilstreitkraft) — nach den Nomen 2026-10-29
  'Inspektion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Prüfung, Kontrolle / Wartung eines Fahrzeugs / Behörde, Dienststelle) — nach den Nomen 2026-10-29
  'Inspektor', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beamter im gehobenen Dienst / Kontrolleur, Prüfer; österr.: Polizeiinspektor) — nach den Nomen 2026-10-29
  'Installation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einbau von Leitungen, Anlagen / EDV: Installieren von Software / Kunst: Rauminstallation) — nach den Nomen 2026-10-29
  'Installierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen wie «Installation»: Einbau von Leitungen, Anlagen / EDV: Installieren von Software) — nach den Nomen 2026-10-29
  'Instanz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: zuständige Stelle, Behörde / Recht: Stufe eines Gerichtsverfahrens «in zweiter Instanz») — nach den Nomen 2026-10-29
  'Instinkt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: angeborener Trieb bei Tieren / sicheres Gefühl, Gespür «ein guter Instinkt») — nach den Nomen 2026-10-29
  'Institution', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: öffentliche Einrichtung, Behörde / gesellschaftliche Einrichtung wie Ehe, Familie / ugs.: feste Größe «Er ist eine Institution») — nach den Nomen 2026-10-29
  'Instrument', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gerät, Werkzeug / Musikinstrument / Mittel zum Zweck «ein politisches Instrument») — nach den Nomen 2026-10-29
  'Instrumentarium', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gesamtheit der Instrumente, Geräte / übertragen: Gesamtheit der Mittel «das politische Instrumentarium») — nach den Nomen 2026-10-29
  'Inszenierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Theater: Einstudierung, Aufführung / übertragen: geschickt organisierte Show «eine perfekte Inszenierung») — nach den Nomen 2026-10-29
  'Integration', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Eingliederung in die Gesellschaft / Zusammenschluss «europäische Integration» / Mathematik: Berechnung eines Integrals) — nach den Nomen 2026-10-29
  'Intelligenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Klugheit, Denkvermögen / Schicht der Intellektuellen / intelligentes Wesen, künstliche Intelligenz) — nach den Nomen 2026-10-29
  'Intendanz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Amt, Leitung eines Intendanten / Büro, Verwaltung eines Theaters oder Senders) — nach den Nomen 2026-10-29
  'Interesse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anteilnahme, Aufmerksamkeit «Interesse an + Dat» / Neigung, Hobby «meine Interessen» / Belang, Vorteil «im Interesse der Kunden») — nach den Nomen 2026-10-29
  'Interieur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Innere, die Ausstattung eines Raumes / Kunst: Bild eines Innenraums) — nach den Nomen 2026-10-29
  'Interim', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zwischenzeit / vorläufige Regelung, Übergangslösung) — nach den Nomen 2026-10-29
  'Intermezzo', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musik, Theater: Zwischenspiel / kleiner, kurzer Zwischenfall) — nach den Nomen 2026-10-29
  'Generalleutnant', // zurückgestellt: Plural nicht sicher (Generalleutnante / Generalleutnants) — Regel 14 2026-10-27
  'Genozid', // zurückgestellt: Genus schwankt (der oder das Genozid) — Regel 14 2026-10-27
  'Gens', // zurückgestellt: Fachwort der Geschichte (altrömische Sippe, Pl. Gentes) — als Lernwort nicht sicher (Regel 14) 2026-10-27
  'Ger', // zurückgestellt: historisch: Wurfspeer der Germanen (Pl. Gere) — als Lernwort nicht sicher (Regel 14) 2026-10-27
  'Germania', // zurückgestellt: lateinischer Name / Personifikation Deutschlands (Allegorie) bzw. Eigenname — kein geografischer Name im heutigen Gebrauch, nicht sicher (Regel 14/18) 2026-10-27
  'Gest', // zurückgestellt: landschaftlich/veraltet (Hefe bzw. Gischt), Genus und Gebrauch nicht sicher (Regel 14) 2026-10-27
  'Gestapo', // zurückgestellt: Name einer Organisation (Geheime Staatspolizei, NS-Zeit) — keine Eigennamen-Karte nach Regel 18, nicht bauen 2026-10-27
  'Gestus', // zurückgestellt: bildungssprachlich/Theater (Ausdruck, Gebärde); Plural nicht sicher (Regel 14) 2026-10-27
  'Glamour', // zurückgestellt: Genus schwankt (der oder das Glamour) — Regel 14 2026-10-27
  'Google', // zurückgestellt: Name einer Firma/Marke — keine Eigennamen-Karte nach Regel 18, nicht bauen 2026-10-27
  'Graffito', // zurückgestellt: Genus schwankt (der oder das Graffito), meist nur Plural Graffiti — Regel 14 2026-10-27
  'Guardian', // zurückgestellt: Bedeutung unsicher (Franziskaner-Oberer / englischer Name, Zeitung) — Regel 14 2026-10-27
  'Gulasch', // zurückgestellt: Genus schwankt (das oder der Gulasch, österr. das) — Regel 14 2026-10-27
  'Gun', // zurückgestellt: Bedeutung unsicher (Jargon, englisch; z. B. Drogenszene: Spritze) — kein gesichertes deutsches Lernwort, Regel 14 2026-10-27
  'Haag', // zurückgestellt: Lemma unsicher: die Stadt heißt «Den Haag» (mit Artikel, niederländisch); Listeneintrag «Haag» mit der — Regel 14 2026-10-27
  'Haber', // zurückgestellt: landschaftlich (österr./schweiz.) für Hafer, auch Familienname — nicht sicher (Regel 14) 2026-10-28
  'Hack', // zurückgestellt: Genus und Bedeutung unsicher (ugs. Hackfleisch: das/der Hack; Computer: Hack) — Regel 14 2026-10-28
  'Hag', // zurückgestellt: veraltet/dichterisch (Hecke, umfriedeter Wald, Hain) — als Lernwort nicht sicher (Regel 14) 2026-10-28
  'Haller', // zurückgestellt: Familienname bzw. Bewohner von Hall/Halle — kein Lernwort (Regel 14/18) 2026-10-28
  'Han', // zurückgestellt: Bedeutung unsicher (chinesische Dynastie / Volksgruppe der Han / Name) — Regel 14 2026-10-28
  'Handelssystem', // zurückgestellt: Bedeutung unscharf (Handelsordnung eines Staates / Börsen-Handelsplattform / Anlagestrategie) — Regel 14 2026-10-28
  'Handumdrehen', // zurückgestellt: nur in der festen Wendung «im Handumdrehen» (= sehr schnell) — als eigenes Nomen nicht sinnvoll (Regel 14) 2026-10-28
  'Hanke', // zurückgestellt: Fachwort (Hüfte, Hinterteil des Pferdes) bzw. Familienname — als Lernwort nicht sicher (Regel 14) 2026-10-28
  'Hartmann', // zurückgestellt: Familienname (Personenname) — keine Eigennamen-Karte nach Regel 18 2026-10-28
  'Hartung', // zurückgestellt: veraltet für Januar, auch Familienname — als Lernwort nicht sicher (Regel 14) 2026-10-28
  'Haschisch', // zurückgestellt: Genus schwankt (das oder der Haschisch) — Regel 14 2026-10-28
  'Haslinger', // zurückgestellt: Familienname (Personenname) — keine Eigennamen-Karte nach Regel 18 2026-10-28
  'Hau', // zurückgestellt: Bedeutung und Gebrauch unsicher (ugs. Hieb, «einen Hau haben» = verrückt sein) — Regel 14 2026-10-28
  'Hauptwache', // zurückgestellt: meist Name bestimmter Gebäude/Plätze (z. B. Frankfurter Hauptwache), sonst veraltet für Hauptpolizeiwache — Regel 14 2026-10-28
  'Hauser', // zurückgestellt: Familienname (Personenname) — keine Eigennamen-Karte nach Regel 18 2026-10-28
  'Heilsarmee', // zurückgestellt: Name einer Organisation (christliche Hilfsorganisation) — keine Eigennamen-Karte nach Regel 18, nicht bauen 2026-10-28
  'Heimen', // zurückgestellt: als Nomen nicht belegt (vermutlich Pluralform von «das Heim» oder Familienname) — Regel 14 2026-10-28
  'Hektar', // zurückgestellt: Genus schwankt (das oder der Hektar) — Regel 14 2026-10-28
  'Hektare', // zurückgestellt: schweizerische Nebenform von «Hektar» (die Hektare); Genus/Lemma von Hektar selbst unsicher — Regel 14 2026-10-28
  'Hektoliter', // zurückgestellt: Genus schwankt (der oder das Hektoliter) — Regel 14 2026-10-28
  'Helfe', // zurückgestellt: als Nomen nicht belegt (Verbform von «helfen» oder Nebenform von «Hilfe») — Regel 14 2026-10-28
  'Herzenslust', // zurückgestellt: nur in der festen Wendung «nach Herzenslust» (= so viel man will) — als eigenes Nomen nicht sinnvoll (Regel 14) 2026-10-28
  'Hickhack', // zurückgestellt: Genus schwankt (das oder der Hickhack) — Regel 14 2026-10-28
  'Hinkunft', // zurückgestellt: nur in der Wendung «in Hinkunft» (österr. = künftig) — als eigenes Nomen nicht sinnvoll (Regel 14) 2026-10-28
  'Hintertreffen', // zurückgestellt: nur in der Wendung «ins Hintertreffen geraten/kommen» (= in Nachteil geraten) — als eigenes Nomen nicht sinnvoll (Regel 14) 2026-10-28
  'Hofgarten', // zurückgestellt: meist Name bestimmter Parkanlagen (Hofgarten Innsbruck, München) — als allgemeines Lernwort nicht sicher (Regel 14) 2026-10-28
  'Hofmann', // zurückgestellt: Familienname (historisch auch: Hofbeamter) — keine Eigennamen-Karte nach Regel 18, nicht bauen 2026-10-28
  'Hot', // zurückgestellt: als Nomen nicht belegt (englisches Adjektiv; nur in Fügungen wie Hot Jazz, Hotdog) — Regel 14 2026-10-28
  'Hube', // zurückgestellt: landschaftlich/veraltet (= Hufe, bäuerliches Landmaß) — als Lernwort nicht sicher (Regel 14) 2026-10-28
  'Huber', // zurückgestellt: Familienname — keine Eigennamen-Karte nach Regel 18, nicht bauen 2026-10-28
  'Hunderttausend', // zurückgestellt: Wortart/Genus unsicher (Zahlwort «hunderttausend» oder Nomen «das Hunderttausend», meist Plural «Hunderttausende») — Regel 14 2026-10-28
  'Hunt', // zurückgestellt: Bergbau-Fachwort (Förderwagen, auch «Hund» geschrieben) — als Lernwort nicht sicher (Regel 14) 2026-10-28
  'Hunter', // zurückgestellt: Fachwort (englisch: Jagdpferd) — als Lernwort nicht sicher (Regel 14) 2026-10-28
  'Importe', // zurückgestellt: Pluralform von «der Import» (kein eigenes Lemma); «Import» selbst steht in der Vier-Fälle-Liste — Regel 14 2026-10-29
  'Interpellation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: parlamentarische Anfrage an die Regierung / veraltet: Einspruch, Unterbrechung) — nach den Nomen 2026-10-29
  'Interpret', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: jemand, der etwas deutet, auslegt / Künstler, der ein Musikstück wiedergibt, Sänger) — nach den Nomen 2026-10-29
  'Interpretation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Deutung, Auslegung eines Textes / künstlerische Wiedergabe eines Musikstücks) — nach den Nomen 2026-10-29
  'Intervall', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zeitabstand, Zwischenraum / Musik: Abstand zweier Töne / Mathematik: Bereich zwischen zwei Zahlen) — nach den Nomen 2026-10-29
  'Intervention', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Eingreifen eines Staates in fremde Angelegenheiten / Vermittlung, Einschreiten / Medizin, Psychologie: gezielte Maßnahme) — nach den Nomen 2026-10-29
  'Intoleranz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Unduldsamkeit gegenüber anderen Meinungen / Medizin: Unverträglichkeit «Laktoseintoleranz») — nach den Nomen 2026-10-29
  'Intonation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sprache: Satzmelodie / Musik: Tongebung, saubere Tonhöhe beim Singen und Spielen) — nach den Nomen 2026-10-29
  'Invasion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: militärischer Einfall in ein Land / übertragen: massenhaftes Eindringen «eine Invasion von Touristen» / Medizin: Eindringen von Erregern) — nach den Nomen 2026-10-29
  'Inventar', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gesamtheit der Einrichtungsgegenstände eines Betriebs / Bestandsverzeichnis, Liste / ugs.: «zum Inventar gehören» von Personen) — nach den Nomen 2026-10-29
  'Inzest', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschlechtsverkehr zwischen engen Blutsverwandten / Biologie: Inzucht bei Tieren und Pflanzen) — nach den Nomen 2026-10-29
  'Ironie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: feiner, versteckter Spott / Widersinn, paradoxer Zufall «die Ironie des Schicksals») — nach den Nomen 2026-10-29
  'Irritation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Medizin: Reizung «Hautirritation» / Verunsicherung, Verärgerung) — nach den Nomen 2026-10-29
  'Irrsinn', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: veraltend: schwere geistige Störung / ugs.: großer Unsinn, Unvernunft «Das ist doch Irrsinn!») — nach den Nomen 2026-10-29
  'Irrweg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: falscher Weg beim Gehen oder Fahren / übertragen: falsches Vorgehen «auf dem Irrweg sein») — nach den Nomen 2026-10-29
  'Isolation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Absonderung, z. B. von Kranken / Vereinsamung, Abgeschiedenheit / Technik: Dämmung gegen Strom, Wärme, Schall) — nach den Nomen 2026-10-29
  'Isolierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Absonderung, Abtrennung von anderen / Technik: Dämmung, Isoliermaterial gegen Strom, Kälte, Schall) — nach den Nomen 2026-10-29
  'Jagd', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Jagen von Wild / Jagdrevier, Jagdgesellschaft / übertragen: Verfolgung, eifrige Suche «die Jagd nach dem Glück») — nach den Nomen 2026-10-29
  'Jahresabschluss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ende des Jahres «zum Jahresabschluss» / Wirtschaft: Bilanz und Abrechnung eines Geschäftsjahres) — nach den Nomen 2026-10-29
  'Jahrgang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: alle im selben Jahr Geborenen «Jahrgang 1990» / alle Hefte einer Zeitschrift aus einem Jahr / Wein aus einem bestimmten Erntejahr) — nach den Nomen 2026-10-29
  'Jammer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: lautes Klagen, Wehklagen / Elend, Kummer / ugs.: «Es ist ein Jammer» = schade) — nach den Nomen 2026-10-29
  'Jargon', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fachsprache, Sondersprache einer Gruppe «Juristenjargon» / abwertend: saloppe, ungepflegte Ausdrucksweise) — nach den Nomen 2026-10-29
  'Jerez', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2 (Homograph mit anderem Genus: Jerez de la Frontera, Stadt in Spanien / der Jerez = Sherry, Wein aus dieser Gegend) — nach den Nomen 2026-10-29
  'Jesuit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mitglied des Jesuitenordens / abwertend: spitzfindig, listig argumentierender Mensch) — nach den Nomen 2026-10-29
  'Joch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zuggeschirr für Rinder / übertragen: drückende Last, Unterdrückung «das Joch abschütteln» / Bergsattel, Pass / Bauwesen: Brückenjoch, Gewölbejoch) — nach den Nomen 2026-10-29
  'Jodler', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: einzelner Jodelruf, Jodellied / Person, die jodelt) — nach den Nomen 2026-10-29
  'Joker', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spielkarte mit beliebigem Wert / übertragen: Trumpf, Hilfe im Quiz «den Joker ziehen») — nach den Nomen 2026-10-29
  'Jugend', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zeit des Jungseins «in meiner Jugend» / die jungen Menschen als Gruppe «die Jugend von heute») — nach den Nomen 2026-10-29
  'Jugendarbeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sozialarbeit, Freizeitangebote für Jugendliche / Erwerbsarbeit von Jugendlichen «Jugendarbeitsschutz») — nach den Nomen 2026-10-29
  'Jugendheim', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Treffpunkt, Freizeitheim für Jugendliche / Heim, in dem Jugendliche untergebracht und betreut werden) — nach den Nomen 2026-10-29
  'Jugendmusik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musik, die Jugendliche hören / schweiz., österr.: Blasmusikkapelle von Jugendlichen) — nach den Nomen 2026-10-29
  'Junge', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2/4 (der Junge = Knabe ↔ das Junge = Jungtier, adjektivisch gebeugt «ein Junges») — nach den Nomen 2026-10-29
  'Jungfrau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Frau ohne Geschlechtsverkehr / Sternzeichen / Berg in den Berner Alpen) — nach den Nomen 2026-10-29
  'Junior', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sohn im Vergleich zum Vater, «der Junior» im Familienbetrieb / Sport: Nachwuchsspieler / Wirtschaft: jüngerer Teilhaber) — nach den Nomen 2026-10-29
  'Juniorin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tochter im Familienbetrieb / Sport: Nachwuchssportlerin) — nach den Nomen 2026-10-29
  'Juniorpartner', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: jüngerer Teilhaber einer Firma / Politik: kleinerer Partner einer Koalition) — nach den Nomen 2026-10-29
  'Junker', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: historisch: junger Adliger / adliger Gutsbesitzer in Ostelbien, Preußen) — nach den Nomen 2026-10-29
  'Jury', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Preisrichter-Gremium bei Wettbewerben / Geschworene vor Gericht, bes. in den USA) — nach den Nomen 2026-10-29
  'Kabarett', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kleinkunstbühne, satirische Darbietung / drehbare, unterteilte Servierplatte) — nach den Nomen 2026-10-29
  'Kabine', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schiffskabine / Umkleidekabine, Telefonkabine / Kabine einer Seilbahn, eines Flugzeugs) — nach den Nomen 2026-10-29
  'Kabinett', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gesamtheit der Minister einer Regierung / kleiner Nebenraum, Ausstellungsraum / Qualitätsstufe beim Wein) — nach den Nomen 2026-10-29
  'Kader', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stammmannschaft, Kerntruppe (Sport, Militär) / Führungskraft, Gruppe von Führungskräften (DDR, schweiz.)) — nach den Nomen 2026-10-29
  'Kadi', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Richter in islamischen Ländern / ugs. scherzhaft für Gericht «vor den Kadi bringen») — nach den Nomen 2026-10-29
  'Kaffee', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kaffeebohnen, Pulver / Getränk / Nachmittagsmahlzeit «zum Kaffee einladen») — nach den Nomen 2026-10-29
  'Kahlschlag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abholzen eines ganzen Waldstücks / übertragen: radikaler Abbau, z. B. von Stellen) — nach den Nomen 2026-10-29
  'Kahn', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kleines Ruderboot / Lastschiff ohne Motor / ugs. Gefängnis, Bett) — nach den Nomen 2026-10-29
  'Kakao', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kakaobaum, Kakaobohnen, Pulver / Getränk «eine Tasse Kakao») — nach den Nomen 2026-10-29
  'Kalb', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: junges Rind / Junges anderer großer Säugetiere (Hirsch, Elefant, Wal) / Kalbfleisch) — nach den Nomen 2026-10-29
  'Kaleidoskop', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spielzeug-Fernrohr mit bunten Mustern / übertragen: bunte, wechselnde Folge «ein Kaleidoskop von Eindrücken») — nach den Nomen 2026-10-29
  'Kalender', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wand-/Taschenkalender, Terminkalender / Zeitrechnung «der gregorianische Kalender») — nach den Nomen 2026-10-29
  'Kaliber', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Durchmesser eines Laufs, Geschosses / ugs. Art, Format «ein Mann seines Kalibers») — nach den Nomen 2026-10-29
  'Kalkulation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kostenberechnung (Wirtschaft) / allgemein: Berechnung, Überlegung «nach meiner Kalkulation») — nach den Nomen 2026-10-29
  'Kamel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tier / salopp abwertend: Dummkopf) — nach den Nomen 2026-10-29
  'Kameradschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verbundenheit unter Kameraden / Gruppe, Vereinigung von Kameraden) — nach den Nomen 2026-10-29
  'Kamin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: offene Feuerstelle im Zimmer / südd., österr.: Schornstein / Bergsteigen: Felsspalt) — nach den Nomen 2026-10-29
  'Kamm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Haarkamm / Hahnenkamm / Gebirgskamm / Nackenstück (Fleisch)) — nach den Nomen 2026-10-29
  'Kammer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kleiner Raum / Berufsvertretung (Ärztekammer) / Parlamentskammer / Herzkammer) — nach den Nomen 2026-10-29
  'Kammeroper', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Oper für kleine Besetzung / kleines Opernhaus, Bühne dafür) — nach den Nomen 2026-10-29
  'Kammerspiel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Theaterstück mit wenigen Personen / Pl. «Kammerspiele»: kleines Theater) — nach den Nomen 2026-10-29
  'Kampagne', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aktion, Werbe-/Wahlkampagne / veraltet: Feldzug / Betriebszeit in Saisonbetrieben) — nach den Nomen 2026-10-29
  'Kampf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: körperliche Auseinandersetzung, Gefecht / Wettkampf / Anstrengung für ein Ziel «Kampf gegen Armut») — nach den Nomen 2026-10-29
  'Kanadier', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einwohner Kanadas / offenes Sportboot, Kanu mit Stechpaddel) — nach den Nomen 2026-10-29
  'Kanal', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: künstlicher Wasserweg / Abwasserkanal / Fernseh-, Kommunikationskanal / der Ärmelkanal) — nach den Nomen 2026-10-29
  'Kanone', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschütz / ugs. Könner, Ass «Sportkanone» / salopp: Pistole) — nach den Nomen 2026-10-29
  'Kante', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rand, Grenzlinie einer Fläche / Webkante, Saum; Wendung «auf die hohe Kante legen») — nach den Nomen 2026-10-29
  'Kantonsrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Parlament eines Kantons / Mitglied dieses Parlaments) — nach den Nomen 2026-10-29
  'Kantor', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kirchenmusiker, Leiter des Kirchenchors / Vorsänger in der Synagoge) — nach den Nomen 2026-10-29
  'Kanzel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: erhöhter Predigtplatz in der Kirche / Cockpit eines Flugzeugs / Hochsitz) — nach den Nomen 2026-10-29
  'Kanzlei', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Büro eines Anwalts oder Notars / Behörde, Amt (Staatskanzlei)) — nach den Nomen 2026-10-29
  'Kanzler', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Regierungschef (Bundeskanzler) / Verwaltungsleiter einer Universität) — nach den Nomen 2026-10-29
  'Kanzlerin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Regierungschefin (Bundeskanzlerin) / Verwaltungsleiterin einer Universität) — nach den Nomen 2026-10-29
  'Kapital', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geldvermögen, Betriebskapital / übertragen: Wert, Vorteil «Kapital schlagen aus» / die Kapitalbesitzer als Klasse) — nach den Nomen 2026-10-29
  'Kapitel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abschnitt eines Buches / übertragen: Zeitabschnitt, Angelegenheit «ein dunkles Kapitel» / Domkapitel, Ordenskapitel) — nach den Nomen 2026-10-29
  'Kappe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mütze ohne Krempe / Verschlusskappe, Schuhkappe) — nach den Nomen 2026-10-29
  'Kapriole', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Luftsprung, übermütiger Streich «Kapriolen des Wetters» / Sprung in der Hohen Schule (Reitkunst)) — nach den Nomen 2026-10-29
  'Kapsel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Arzneikapsel / Raumkapsel / kleiner Behälter, Kaffeekapsel / Kapsel um ein Gelenk (Anatomie)) — nach den Nomen 2026-10-29
  'Karambolage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zusammenstoß (Massenkarambolage) / Billard: Treffen zweier Bälle) — nach den Nomen 2026-10-29
  'Karawane', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Reisegruppe mit Kamelen in der Wüste / übertragen: lange Reihe, Kolonne «Autokarawane») — nach den Nomen 2026-10-29
  'Kardinal', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: katholischer Würdenträger / Singvogel / Getränk (Bowle)) — nach den Nomen 2026-10-29
  'Karenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: österr. Elternkarenz, unbezahlter Urlaub / Wartezeit, Sperrfrist (Versicherung, Arbeitsrecht)) — nach den Nomen 2026-10-29
  'Karikatur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: satirische Zeichnung / übertragen: Zerrbild «eine Karikatur der Demokratie») — nach den Nomen 2026-10-29
  'Karosse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Prunkkutsche / ugs. großes, prächtiges Auto / Karosserie) — nach den Nomen 2026-10-29
  'Karren', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kleiner Wagen zum Schieben oder Ziehen / ugs. abwertend: altes Auto) — nach den Nomen 2026-10-29
  'Karriere', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: berufliche Laufbahn, Aufstieg / Reitsport: schnellster Galopp) — nach den Nomen 2026-10-29
  'Karte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Postkarte / Eintrittskarte, Fahrkarte / Landkarte / Spielkarte / Speisekarte) — nach den Nomen 2026-10-29
  'Kartell', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Absprache, Zusammenschluss von Unternehmen / kriminelle Organisation (Drogenkartell) / politisches Bündnis) — nach den Nomen 2026-10-29
  'Kartenspiel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spiel mit Karten / Satz Spielkarten) — nach den Nomen 2026-10-29
  'Karton', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: dünne Pappe / Schachtel aus Pappe) — nach den Nomen 2026-10-29
  'Kasper', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: lustige Figur im Puppenspiel / ugs. alberner Mensch) — nach den Nomen 2026-10-29
  'Kassa', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (österr. für Kasse; mehrere Bedeutungen: Geldkassette, Ladenkasse / Zahlstelle, Schalter / Krankenkasse) — nach den Nomen 2026-10-29
  'Kasse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ladenkasse, Zahlstelle / Geldkassette, Barbestand / Krankenkasse «auf Kasse») — nach den Nomen 2026-10-29
  'Kassette', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tonband-/Videokassette / Kästchen für Schmuck, Geld / Schuber für Bücher) — nach den Nomen 2026-10-29
  'Kassier', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (österr./schweiz.; mehrere Bedeutungen: Kassierer im Geschäft, in der Bank / Kassenwart eines Vereins) — nach den Nomen 2026-10-29
  'Kassierin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (österr./schweiz.; mehrere Bedeutungen: Kassiererin / Kassenwartin eines Vereins) — nach den Nomen 2026-10-29
  'Kastanie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rosskastanie (Baum, Frucht) / Edelkastanie, Maroni (essbar)) — nach den Nomen 2026-10-29
  'Kasten', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kiste, Getränkekasten / südd., österr., schweiz.: Schrank / Turngerät / ugs. großes Gebäude, Fahrzeug) — nach den Nomen 2026-10-29
  'Katalysator', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Chemie: Stoff, der eine Reaktion beschleunigt / Abgaskatalysator im Auto / übertragen: Auslöser, Beschleuniger) — nach den Nomen 2026-10-30
  'Katzenjammer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kater nach Alkohol / gedrückte Stimmung, Reue) — nach den Nomen 2026-10-30
  'Kauf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Kaufen / das Gekaufte «ein guter Kauf» / Wendung «in Kauf nehmen») — nach den Nomen 2026-10-30
  'Kegel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: geometrischer Körper / Spielfigur beim Kegeln / Lichtkegel) — nach den Nomen 2026-10-30
  'Kehle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gurgel, Rachen / vordere Halsseite / Hohlkehle (Bauwesen)) — nach den Nomen 2026-10-30
  'Kehre', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Haarnadelkurve / Turnübung (Schwung über das Gerät)) — nach den Nomen 2026-10-30
  'Kehrseite', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rückseite / übertragen: Nachteil «die Kehrseite der Medaille» / scherzh. Hintern) — nach den Nomen 2026-10-30
  'Keim', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Krankheitserreger / Pflanzenkeim, Sprössling / übertragen: Ursprung «im Keim ersticken») — nach den Nomen 2026-10-30
  'Keimzelle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Biologie: Geschlechtszelle / übertragen: Ausgangspunkt, Kern) — nach den Nomen 2026-10-30
  'Kelch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Trinkgefäß, Abendmahlskelch / Blütenkelch (Botanik) / übertragen: Leid «der Kelch ist an mir vorübergegangen») — nach den Nomen 2026-10-30
  'Kelle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schöpfkelle / Maurerkelle / Signalkelle (Polizei, Bahn)) — nach den Nomen 2026-10-30
  'Kenntnis', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wissen von einer Sache «zur Kenntnis nehmen» / Plural: Fachwissen, Fähigkeiten «Sprachkenntnisse») — nach den Nomen 2026-10-30
  'Kennzahl', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kennziffer, Vorwahl / betriebswirtschaftliche Kenngröße) — nach den Nomen 2026-10-30
  'Kennzeichen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Merkmal / Autokennzeichen, Nummernschild) — nach den Nomen 2026-10-30
  'Keramik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Werkstoff, gebrannter Ton / Töpferkunst / einzelner Gegenstand aus Keramik) — nach den Nomen 2026-10-30
  'Kern', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Obstkern, Samen / Atomkern / übertragen: das Wesentliche «der Kern der Sache») — nach den Nomen 2026-10-30
  'Kerze', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wachskerze / Turnübung (Schulterstand) / Zündkerze) — nach den Nomen 2026-10-30
  'Kessel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kochkessel, Heizkessel / Talkessel / Einkesselung (Militär, Polizei)) — nach den Nomen 2026-10-30
  'Kette', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Metallkette / Halskette, Schmuck / Ladenkette, Hotelkette / Reihe «eine Kette von Ereignissen») — nach den Nomen 2026-10-30
  'Keule', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schlagwaffe / Fleisch: Hinterbein (Hähnchenkeule) / Turngerät) — nach den Nomen 2026-10-30
  'Keyboard', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: elektronisches Tasteninstrument / Computertastatur) — nach den Nomen 2026-10-30
  'Kicker', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fußballspieler (ugs.) / Tischfußball / Name einer Sportzeitschrift) — nach den Nomen 2026-10-30
  'Kies', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kleine Steine, Schotter / ugs. Geld) — nach den Nomen 2026-10-30
  'Kinderfreund', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mensch, der Kinder mag / österr. Name einer Organisation «die Kinderfreunde») — nach den Nomen 2026-10-30
  'Kinderkrankheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: typische Krankheit im Kindesalter / übertragen: Anfangsfehler eines neuen Produkts) — nach den Nomen 2026-10-30
  'Kinderschuh', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schuh für Kinder / Redewendung «noch in den Kinderschuhen stecken» = am Anfang stehen) — nach den Nomen 2026-10-30
  'Kinderspiel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spiel für Kinder / übertragen: sehr leichte Sache «das ist ein Kinderspiel») — nach den Nomen 2026-10-30
  'Kino', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Filmtheater (Gebäude) / Filmvorstellung «nach dem Kino» / Film als Kunst «das europäische Kino») — nach den Nomen 2026-10-30
  'Kippe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. Zigarettenstummel, Zigarette / Mülldeponie, Halde / Wendung «auf der Kippe stehen») — nach den Nomen 2026-10-30
  'Kirchdorf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Dorf mit Pfarrkirche / häufiger Ortsname (Kirchdorf an der Krems u. a.)) — nach den Nomen 2026-10-30
  'Kirche', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gebäude / Institution, Glaubensgemeinschaft / Gottesdienst «nach der Kirche») — nach den Nomen 2026-10-30
  'Kirchenrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Leitungsgremium einer Kirche / Mitglied dieses Gremiums, Amtstitel) — nach den Nomen 2026-10-30
  'Kirsche', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Frucht / Kirschbaum / Kirschholz) — nach den Nomen 2026-10-30
  'Kiste', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Holzkasten, Kasten / ugs. altes Auto, Flugzeug / ugs. Angelegenheit «eine schwierige Kiste») — nach den Nomen 2026-10-30
  'Klage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Recht: Klage vor Gericht / Beschwerde / Wehklage, Trauer) — nach den Nomen 2026-10-30
  'Klammer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wäscheklammer, Büroklammer / Satzzeichen (runde, eckige Klammer) / Wundklammer, Zahnklammer) — nach den Nomen 2026-10-30
  'Klamotte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. Plural: Kleidung «die Klamotten» / anspruchsloses, derbes Theaterstück oder Film) — nach den Nomen 2026-10-30
  'Klappe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Deckel, Lasche / Herzklappe, Ventil / derb: Mund «halt die Klappe» / Filmklappe) — nach den Nomen 2026-10-30
  'Klarheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Durchsichtigkeit, Reinheit (Wasser, Luft) / Deutlichkeit, Verständlichkeit «Klarheit schaffen») — nach den Nomen 2026-10-30
  'Klartext', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: entschlüsselter Text (Technik) / übertragen: offene Worte «Klartext reden») — nach den Nomen 2026-10-30
  'Klasse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schulklasse, Jahrgang / Klassenzimmer / Gesellschaftsklasse / Kategorie, Güteklasse / ugs. «Klasse!» = toll) — nach den Nomen 2026-10-30
  'Klassik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Epoche (Weimarer Klassik, Wiener Klassik) / klassische Musik allgemein / Antike) — nach den Nomen 2026-10-30
  'Klassiker', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Dichter/Komponist der Klassik / bewährtes, bekanntes Werk oder Produkt «ein Klassiker») — nach den Nomen 2026-10-30
  'Klatsch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. Gerede, Tratsch / klatschendes Geräusch) — nach den Nomen 2026-10-30
  'Klatsche', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fliegenklatsche / ugs. hohe Niederlage / ugs. Spickzettel) — nach den Nomen 2026-10-30
  'Klausur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Prüfungsarbeit (Schule, Uni) / Abgeschiedenheit, Klausurtagung «in Klausur gehen» / Klosterbereich) — nach den Nomen 2026-10-30
  'Klavierkonzert', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musikstück für Klavier und Orchester / Konzertveranstaltung eines Pianisten) — nach den Nomen 2026-10-30
  'Kleber', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. Klebstoff / Eiweiß im Getreide (Gluten) / ugs. Aufkleber) — nach den Nomen 2026-10-30
  'Kleine', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die/das Kleine, ein Kleiner) + Fall 1 (kleines Kind / Freundin, Kosewort) — nach den Nomen 2026-10-30
  'Kleinkrieg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Guerillakrieg / dauernde kleine Streitereien) — nach den Nomen 2026-10-30
  'Kleinkunst', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kabarett, Varieté, Kleinkunstbühne / kunsthandwerkliche Kleinarbeiten) — nach den Nomen 2026-10-30
  'Kleinod', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schmuckstück, Pl. Kleinodien / übertragen: etwas Kostbares, Pl. Kleinode) — nach den Nomen 2026-10-30
  'Klemme', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Klammer, Haarklemme, Kabelklemme (Technik) / ugs. Notlage «in der Klemme sitzen») — nach den Nomen 2026-10-30
  'Klima', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wetterverhältnisse eines Gebiets / Atmosphäre, Stimmung «Betriebsklima») — nach den Nomen 2026-10-30
  'Klippe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Felsen im Meer / übertragen Hindernis, Schwierigkeit «eine Klippe umschiffen») — nach den Nomen 2026-10-31
  'Klischee', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Druckstock (Druckwesen) / abgegriffene Vorstellung, Stereotyp) — nach den Nomen 2026-10-31
  'Klotz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Holzklotz, Block / ugs. abwertend plumper Mensch / «Klotz am Bein») — nach den Nomen 2026-10-31
  'Klub', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verein / Nachtklub, Räume / österr. Parlamentsfraktion) — nach den Nomen 2026-10-31
  'Klubchef', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorsitzender eines Vereins / österr. Fraktionschef im Parlament) — nach den Nomen 2026-10-31
  'Knaller', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. Knallkörper / ugs. Sensation, Hit) — nach den Nomen 2026-10-31
  'Knappe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bergmann / historisch Edelknabe, Schildträger) — nach den Nomen 2026-10-31
  'Knappheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mangel «Knappheit an Wasser» / Kürze des Ausdrucks) — nach den Nomen 2026-10-31
  'Knecht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: veraltend Landarbeiter / abwertend unterwürfiger Diener) — nach den Nomen 2026-10-31
  'Knick', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Biegung, Falz / norddt. Wallhecke / «einen Knick in der Optik haben») — nach den Nomen 2026-10-31
  'Kniff', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Trick, Kunstgriff / Kneifen / Falte, Knick im Papier) — nach den Nomen 2026-10-31
  'Knirps', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. kleiner Junge / Taschenschirm (Markenname)) — nach den Nomen 2026-10-31
  'Knopf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kleiderknopf / Taste, Schaltknopf / österr. Knoten) — nach den Nomen 2026-10-31
  'Knoten', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schlinge, Verknotung / Medizin: Verdickung im Gewebe / Seefahrt: Geschwindigkeitsmaß) — nach den Nomen 2026-10-31
  'Kodex', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Regelwerk, Verhaltenskodex / alte Handschrift) — nach den Nomen 2026-10-31
  'Kohl', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gemüse / ugs. Unsinn «Kohl reden») — nach den Nomen 2026-10-31
  'Kohle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Brennstoff / ugs. Geld / Zeichenkohle) — nach den Nomen 2026-10-31
  'Kollaboration', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zusammenarbeit mit dem Feind / bildungsspr. Zusammenarbeit allgemein) — nach den Nomen 2026-10-31
  'Kollaps', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Medizin: Kreislaufzusammenbruch / übertragen Zusammenbruch eines Systems) — nach den Nomen 2026-10-31
  'Kollektiv', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gemeinschaft, Gruppe / DDR: Produktionsgemeinschaft / Statistik: Gesamtheit) — nach den Nomen 2026-10-31
  'Kollision', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zusammenstoß von Fahrzeugen / Widerstreit, z. B. von Interessen oder Terminen) — nach den Nomen 2026-10-31
  'Kolloquium', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: wissenschaftliches Gespräch, Tagung / österr. mündliche Prüfung an der Uni) — nach den Nomen 2026-10-31
  'Kolonie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gebiet unter Fremdherrschaft / Siedlung, z. B. Künstlerkolonie, Gartenkolonie / Biologie: Verband von Lebewesen) — nach den Nomen 2026-10-31
  'Kolonne', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fahrzeugkolonne / Arbeitstrupp / senkrechte Zahlenreihe) — nach den Nomen 2026-10-31
  'Koloss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Riesenstandbild / ugs. riesiger Mensch oder Gegenstand) — nach den Nomen 2026-10-31
  'Kolumne', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Druckspalte / regelmäßiger Meinungsbeitrag in der Zeitung) — nach den Nomen 2026-10-31
  'Komiker', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Künstler, der Leute zum Lachen bringt / ugs. abwertend jemand, den man nicht ernst nimmt) — nach den Nomen 2026-10-31
  'Kommando', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Befehl / Befehlsgewalt «das Kommando haben» / militärische Einheit, Sonderkommando) — nach den Nomen 2026-10-31
  'Kommentar', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stellungnahme, Meinungsbeitrag / Erläuterungswerk, z. B. zu einem Gesetz / ugs. Bemerkung) — nach den Nomen 2026-10-31
  'Kommissar', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kriminalbeamter / EU-Kommissar / staatlich Beauftragter) — nach den Nomen 2026-10-31
  'Kommissariat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Polizeidienststelle / Amt eines Kommissars) — nach den Nomen 2026-10-31
  'Kommissarin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen wie Kommissar: Kriminalbeamtin / EU-Kommissarin) — nach den Nomen 2026-10-31
  'Kommission', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausschuss, Gremium / EU-Kommission / Handel: «in Kommission» verkaufen) — nach den Nomen 2026-10-31
  'Kommune', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gemeinde / Wohngemeinschaft (1968er) / historisch Pariser Kommune) — nach den Nomen 2026-10-31
  'Kompanie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: militärische Einheit / veraltet Handelsgesellschaft, «& Co.») — nach den Nomen 2026-10-31
  'Kompetenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fähigkeit, Sachverstand / Zuständigkeit, Befugnis) — nach den Nomen 2026-10-31
  'Komplex', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gebäudekomplex, zusammenhängendes Ganzes / Psychologie: Minderwertigkeitskomplex) — nach den Nomen 2026-10-31
  'Komposition', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musikwerk, das Komponieren / Aufbau, Gestaltung eines Kunstwerks) — nach den Nomen 2026-10-31
  'Kondition', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: körperliche Leistungsfähigkeit / meist Pl. Geschäftsbedingungen «Konditionen») — nach den Nomen 2026-10-31
  'Konfiguration', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gestaltung, Anordnung / EDV: Einstellungen eines Systems / Chemie, Astronomie: räumliche Anordnung) — nach den Nomen 2026-10-31
  'Konglomerat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gemisch, Ansammlung / Geologie: Gestein / Wirtschaft: Mischkonzern) — nach den Nomen 2026-10-31
  'Kongress', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fachtagung / Parlament der USA «der Kongress») — nach den Nomen 2026-10-31
  'Konkurrenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wettbewerb, Rivalität / die Konkurrenten, Konkurrenzfirma «zur Konkurrenz gehen» / Sport: Wettkampf) — nach den Nomen 2026-10-31
  'Konsequenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Folge «Konsequenzen ziehen» / Folgerichtigkeit, Beharrlichkeit «mit Konsequenz») — nach den Nomen 2026-10-31
  'Konserve', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Konservendose mit Inhalt / Blutkonserve / übertragen «Musik aus der Konserve») — nach den Nomen 2026-10-31
  'Konsistenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beschaffenheit, Dichte (z. B. Teig) / Widerspruchsfreiheit, Beständigkeit) — nach den Nomen 2026-10-31
  'Konsole', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wandvorsprung, Ablage / Spielkonsole / Bedienpult, EDV) — nach den Nomen 2026-10-31
  'Konsorte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: meist Pl., abwertend Mittäter «und Konsorten» / Bankwesen: Mitglied eines Konsortiums) — nach den Nomen 2026-10-31
  'Konstante', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mathematik, Physik: unveränderliche Größe / übertragen beständiger Faktor) — nach den Nomen 2026-10-31
  'Konstellation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zusammentreffen von Umständen, Lage / Astronomie: Stellung der Gestirne) — nach den Nomen 2026-10-31
  'Konstitution', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: körperliche Verfassung / Staatsverfassung / Chemie: Aufbau eines Moleküls) — nach den Nomen 2026-10-31
  'Konstruktion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bauart, das Konstruieren / Sprachwissenschaft: Satzkonstruktion / Mathematik: geometrische Konstruktion) — nach den Nomen 2026-10-31
  'Konsul', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: diplomatischer Vertreter / Geschichte: römischer Konsul) — nach den Nomen 2026-10-31
  'Konsulat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Dienststelle eines Konsuls / Geschichte: Amt und Amtszeit eines römischen Konsuls) — nach den Nomen 2026-10-31
  'Konsultation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beratung, Untersuchung durch Arzt oder Fachmann / Politik: gemeinsame Beratung von Regierungen) — nach den Nomen 2026-10-31
  'Kontakt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verbindung, Beziehung «Kontakt haben» / Berührung / Elektrotechnik: Kontaktstelle) — nach den Nomen 2026-10-31
  'Konter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: Gegenangriff / Boxen: Konterschlag / übertragen: schlagfertige Antwort) — nach den Nomen 2026-10-31
  'Kontext', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sprachwissenschaft: umgebender Text / Zusammenhang, Umfeld) — nach den Nomen 2026-10-31
  'Kontinent', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erdteil / Festland «auf dem Kontinent» im Gegensatz zu Inseln) — nach den Nomen 2026-10-31
  'Kontingent', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anteil, Menge, Quote / Militär: Truppenkontingent) — nach den Nomen 2026-10-31
  'Kontra', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kartenspiel: Gegenansage / übertragen «Kontra geben» = widersprechen / «das Pro und Kontra») — nach den Nomen 2026-10-31
  'Kontrahent', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gegner, Widersacher / Recht: Vertragspartner) — nach den Nomen 2026-10-31
  'Kontrapunkt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musik: Satztechnik / übertragen: Gegenpol, Gegengewicht) — nach den Nomen 2026-10-31
  'Kontrast', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: starker Gegensatz / Optik, Fernsehen: Helligkeitsunterschied) — nach den Nomen 2026-10-31
  'Kontrastprogramm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fernsehen: gleichzeitig laufendes Gegenprogramm / übertragen: ganz andere Erfahrung, Gegensatz) — nach den Nomen 2026-10-31
  'Kontrolle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Überprüfung, Überwachung / Beherrschung, Gewalt «die Kontrolle verlieren») — nach den Nomen 2026-10-31
  'Kontrollstelle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ort, an dem kontrolliert wird / Behörde, Stelle mit Aufsichtsfunktion) — nach den Nomen 2026-10-31
  'Konvent', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Versammlung der Mitglieder eines Klosters / Zusammenkunft, Gremium (Verfassungskonvent) / Studentenverbindung) — nach den Nomen 2026-10-31
  'Konvention', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: völkerrechtliches Abkommen «Genfer Konvention» / Regel des Umgangs, Gepflogenheit) — nach den Nomen 2026-10-31
  'Konvergenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Annäherung, Übereinstimmung / Mathematik, Biologie: Fachbegriff) — nach den Nomen 2026-10-31
  'Konvergenzkriterium', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wirtschaft: EU-Kriterien für den Euro / Mathematik: Kriterium für Konvergenz) — nach den Nomen 2026-10-31
  'Konversion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Religion: Übertritt / Chemie, Physik: Umwandlung / Sprachwissenschaft / Wirtschaft: Umwandlung, militärische Flächen) — nach den Nomen 2026-10-31
  'Konzentration', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: geistige Sammlung / Zusammenballung, Wirtschaft / Chemie: Gehalt eines Stoffes) — nach den Nomen 2026-10-31
  'Konzept', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rohfassung, Entwurf «aus dem Konzept bringen» / Plan, Programm) — nach den Nomen 2026-10-31
  'Konzeption', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Leitidee, Entwurf eines Werkes / Medizin: Empfängnis) — nach den Nomen 2026-10-31
  'Konzert', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musikaufführung / Komposition für Soloinstrument und Orchester «Klavierkonzert» / übertragen: Zusammenwirken «Konzert der Mächte») — nach den Nomen 2026-10-31
  'Konzession', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: behördliche Genehmigung, Lizenz / Zugeständnis) — nach den Nomen 2026-10-31
  'Konzil', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kirchenversammlung / Hochschulgremium) — nach den Nomen 2026-10-31
  'Koordination', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abstimmung, Zusammenspiel / Medizin: Zusammenwirken der Muskeln / Chemie: Koordinationsverbindung) — nach den Nomen 2026-10-31
  'Kopf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Körperteil / Person, Anführer «der Kopf der Bande» / oberer Teil «Kopf des Briefes») — nach den Nomen 2026-10-31
  'Kopie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abschrift, Fotokopie / Nachbildung eines Kunstwerks, Imitat / Film, Fotografie: Abzug) — nach den Nomen 2026-10-31
  'Koppelung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Koppeln, Verbindung, Verknüpfung / Technik: Vorrichtung zum Koppeln) — nach den Nomen 2026-10-31
  'Kopplung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Koppeln, Verbindung, Verknüpfung / Technik: Vorrichtung zum Koppeln) — nach den Nomen 2026-10-31
  'Koralle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Meerestier / Schmuck aus Korallen) — nach den Nomen 2026-10-31
  'Korb', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: geflochtener Behälter / Basketball: Korb / Ablehnung «einen Korb geben») — nach den Nomen 2026-10-31
  'Korps', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Militär: Truppenverband / diplomatisches Korps / Studentenverbindung) — nach den Nomen 2026-10-31
  'Korrektur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Berichtigung, Verbesserung / Druckwesen: Korrekturfahne, Korrekturlesen) — nach den Nomen 2026-10-31
  'Korrespondent', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Journalist, Auslandsberichterstatter / Kaufmann für Geschäftsbriefe «Fremdsprachenkorrespondent») — nach den Nomen 2026-10-31
  'Korrespondentin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Journalistin, Auslandsberichterstatterin / Kauffrau für Geschäftsbriefe «Fremdsprachenkorrespondentin») — nach den Nomen 2026-10-31
  'Korrespondenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Briefwechsel, Schriftverkehr / gehoben: Übereinstimmung) — nach den Nomen 2026-10-31
  'Korridor', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Flur, Gang / Landstreifen, Luftkorridor / übertragen: Spielraum «Zinskorridor») — nach den Nomen 2026-10-31
  'Korsett', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mieder / Medizin: Stützkorsett / übertragen: einengende Vorschriften) — nach den Nomen 2026-10-31
  'Kosmetik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schönheitspflege / übertragen: oberflächliche Verbesserung «reine Kosmetik») — nach den Nomen 2026-10-31
  'Kosmos', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Weltall / Philosophie, übertragen: geordnete Welt, eigene Welt «der Kosmos des Autors») — nach den Nomen 2026-10-31
  'Kostbarkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kostbarer Gegenstand / das Kostbarsein, hoher Wert) — nach den Nomen 2026-10-31
  'Kostprobe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kleine Menge zum Probieren / übertragen: Beispiel, Probe «eine Kostprobe seines Könnens») — nach den Nomen 2026-10-31
  'Kot', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Exkremente / veraltet: Schmutz, Schlamm) — nach den Nomen 2026-10-31
  'Krabbe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Krebstier mit breitem Körper / umgangssprachlich: Garnele, Nordseekrabbe / umgangssprachlich: kleines Kind) — nach den Nomen 2026-10-31
  'Krach', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lärm / Streit «Krach haben» / Wirtschaft: Zusammenbruch, Börsenkrach) — nach den Nomen 2026-10-31
  'Kracher', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Feuerwerkskörper / umgangssprachlich: Erfolg, Knaller) — nach den Nomen 2026-10-31
  'Kraftakt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Darbietung von Körperkraft / übertragen: große Anstrengung) — nach den Nomen 2026-10-31
  'Krampf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Muskelkrampf / umgangssprachlich: Unsinn, krampfhaftes Bemühen «so ein Krampf») — nach den Nomen 2026-10-31
  'Kran', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hebevorrichtung, Baukran / landschaftlich: Wasserhahn) — nach den Nomen 2026-10-31
  'Kranke', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Kranke, ein Kranker) — nach den Nomen 2026-10-31
  'Krankenstand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: vor allem österr.: Zeit der Arbeitsunfähigkeit «im Krankenstand sein» / Anzahl der Kranken in einem Betrieb) — nach den Nomen 2026-10-31
  'Krankheitsfall', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: «im Krankheitsfall» = wenn jemand krank wird / einzelner Fall einer Krankheit) — nach den Nomen 2026-10-31
  'Kranz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gebinde aus Blumen, Zweigen / ringförmiges Gebäck «Frankfurter Kranz» / Kreis, Ring) — nach den Nomen 2026-10-31
  'Kratzer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schramme, Kratzspur / Technik: Kratzeisen, Werkzeug) — nach den Nomen 2026-10-31
  'Krawall', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufruhr, Tumult (meist Plural «Krawalle») / umgangssprachlich: Lärm, Krach «Krawall machen») — nach den Nomen 2026-10-31
  'Kreation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Modeschöpfung, Modell / allgemein: Schöpfung, Erfindung) — nach den Nomen 2026-10-31
  'Kreatur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschöpf, Lebewesen / abwertend: Mensch, bedauernswertes Wesen / willenloses Werkzeug eines anderen) — nach den Nomen 2026-10-31
  'Krebs', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Krebstier / Krankheit, bösartiger Tumor / Sternbild, Tierkreiszeichen) — nach den Nomen 2026-10-31
  'Kreide', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kalkgestein / Schreibkreide / Geologie: Erdzeitalter / Redewendung «in der Kreide stehen» = Schulden haben) — nach den Nomen 2026-10-31
  'Kreis', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: geometrische Figur / Gruppe von Menschen «Freundeskreis» / Verwaltungsbezirk, Landkreis) — nach den Nomen 2026-10-31
  'Kreisel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spielzeug / umgangssprachlich: Kreisverkehr / Technik: Gyroskop) — nach den Nomen 2026-10-31
  'Kreislauf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Medizin: Blutkreislauf «Kreislaufprobleme» / Zyklus, Wasserkreislauf, Wirtschaftskreislauf) — nach den Nomen 2026-10-31
  'Indian', // zurückgestellt: zurückgestellt: österr./bayr. für Truthahn — Plural und Aussprache nicht sicher (Regel 14) 2026-10-29
  'Industriellenvereinigung', // zurückgestellt: zurückgestellt: v. a. Name einer Organisation (Industriellenvereinigung, Österreich) — keine Eigennamen-Karte nach Regel 18, nicht bauen 2026-10-29
  'Innenministerkonferenz', // zurückgestellt: zurückgestellt: Name einer Einrichtung (Ständige Konferenz der Innenminister, Deutschland) — keine Eigennamen-Karte nach Regel 18, nicht bauen 2026-10-29
  'Input', // zurückgestellt: zurückgestellt: Genus schwankt (der oder das Input) — Regel 14 2026-10-29
  'Interpol', // zurückgestellt: Name einer Organisation (Internationale Kriminalpolizeiliche Organisation) — keine Eigennamen-Karte nach Regel 18, nicht bauen 2026-10-29
  'Interregio', // zurückgestellt: Name einer Zuggattung der Bahn (in Deutschland 2006 eingestellt, in der Schweiz weiter) — Markenname, Gebrauch je Land verschieden, nicht sicher (Regel 14/18) 2026-10-29
  'Intershop', // zurückgestellt: Name einer Ladenkette der DDR (historisch) — keine Eigennamen-Karte nach Regel 18, nicht bauen 2026-10-29
  'Investitionsbank', // zurückgestellt: meist Teil von Namen einzelner Förderbanken (Investitionsbank Berlin, Investitionsbank Schleswig-Holstein …) — als Gattungswort nicht sicher (Regel 14/18) 2026-10-29
  'Ischl', // zurückgestellt: der Ortsname lautet «Bad Ischl» (Lemma der Liste unvollständig, wie Haag ⇒ Den Haag) — Regel 14/18 2026-10-29
  'Jeep', // zurückgestellt: Markenname (Jeep®) — keine Eigennamen-Karte nach Regel 18, nicht bauen 2026-10-29
  'Joghurt', // zurückgestellt: Genus schwankt (der, das; österr. auch die Joghurt) — Regel 14 2026-10-29
  'Johanniter', // zurückgestellt: Mitglied eines Ordens bzw. Name einer Hilfsorganisation (Johanniter-Unfall-Hilfe) — keine Eigennamen-Karte nach Regel 18, nicht bauen 2026-10-29
  'Kajak', // zurückgestellt: Genus schwankt (das Kajak, auch der Kajak) — Regel 14 2026-10-29
  'Kalaschnikow', // zurückgestellt: nach einer Person benannte Waffe (Michail Kalaschnikow), Gattungsname/Markenname nicht sicher — Regel 14/18 2026-10-29
  'Kalle', // zurückgestellt: Bedeutung unsicher (Rufname für Karl / Gaunersprache) — kein klares Gattungswort, Regel 14 2026-10-29
  'Kammergericht', // zurückgestellt: Name eines bestimmten Gerichts (Oberlandesgericht Berlin, historisch Reichskammergericht) — keine Eigennamen-Karte nach Regel 18 2026-10-29
  'Kamp', // zurückgestellt: Bedeutung unsicher (Fluss in Niederösterreich / nordd. eingezäuntes Feldstück) — Regel 14 2026-10-29
  'Kanten', // zurückgestellt: landschaftlich (nordd.: Anschnitt des Brotes) und gleich geschrieben wie der Plural von «Kante» — Regel 14 2026-10-29
  'Kappel', // zurückgestellt: kein Gattungswort; Orts- oder Familienname (Kappel am Albis u. a.) — Regel 14/18 2026-10-29
  'Karabach', // zurückgestellt: Lemma unvollständig/schwankend (meist «Bergkarabach», auch Nagorny-Karabach) — Regel 14/18 2026-10-29
  'Kart', // zurückgestellt: Genus/Plural nicht sicher (der Kart / das Kart, Go-Kart) — Regel 14 2026-10-29
  'Kauder', // zurückgestellt: Bedeutung unsicher (landschaftlich: Werg, Flachsabfall / Kurzform von Kauderwelsch?) — kein sicheres Gattungswort, Regel 14 2026-10-30
  'Kaugummi', // zurückgestellt: Genus schwankt (der oder das Kaugummi, österr. meist das) — Regel 14 2026-10-30
  'Keks', // zurückgestellt: Genus regional verschieden (der Keks, österr. das Keks) — Regel 14 2026-10-30
  'Ketchup', // zurückgestellt: Genus schwankt (der oder das Ketchup) — Regel 14 2026-10-30
  'Kinderschutzbund', // zurückgestellt: Name einer bestimmten Organisation (Deutscher Kinderschutzbund) — keine Eigennamen-Karte nach Regel 18 2026-10-30
  'Kirchner', // zurückgestellt: Bedeutung unsicher (veraltet/landschaftlich: Küster, Mesner / häufiger Familienname) — Regel 14 2026-10-30
  'Klar', // zurückgestellt: österr. Kurzform für Eiklar (das Klar); Plural und Gebrauch als eigenes Stichwort nicht sicher — Regel 14 2026-10-30
  'Klauenseuche', // zurückgestellt: fast nur in «Maul- und Klauenseuche» gebraucht — Lemma als Einzelwort nicht sicher, Regel 14 2026-10-30
  'Klein', // zurückgestellt: als Nomen unklar (das Klein = Gänseklein? / Familienname) — Bedeutung nicht sicher, Regel 14 2026-10-30
  'Kleinfeld', // zurückgestellt: Bedeutung und Gebrauch als Einzelwort nicht sicher (Sport: kleines Spielfeld? Kleinfeldfußball) — Regel 14 2026-10-30
  'Knesset', // zurückgestellt: Name einer Einrichtung (Parlament Israels) — keine Eigennamen-Karte nach Regel 18, nicht bauen 2026-10-31
  'Knight', // zurückgestellt: englischer Adelstitel (Ritter, «Sir») — kein gebräuchliches deutsches Nomen; Gebrauch/Genus nicht sicher, Regel 14 2026-10-31
  'Knopp', // zurückgestellt: Familienname (z. B. Guido Knopp) — kein Nomen, keine Eigennamen-Karte nach Regel 18, nicht bauen 2026-10-31
  'Knorr', // zurückgestellt: Familien- und Markenname — kein Nomen, keine Eigennamen-Karte nach Regel 18, nicht bauen 2026-10-31
  'Kober', // zurückgestellt: regional (Korb) / Familienname — Bedeutung und Gebrauch nicht sicher, Regel 14 2026-10-31
  'Kolbe', // zurückgestellt: als Nomen unklar (Familienname, z. B. Georg Kolbe; oder Verwechslung mit «der Kolben») — Regel 14 2026-10-31
  'Kommunique', // zurückgestellt: Schreibweise unsicher (Duden: «Kommuniqué», auch «Kommunikee») — Lemma der Liste nicht sicher, Regel 14 2026-10-31
  'Kontaktgruppe', // zurückgestellt: Bedeutung je nach Bereich verschieden (Diplomatie: Staatengruppe in einem Konflikt / Gruppe von Kontaktpersonen) — als Gattungswort nicht sicher, Regel 14 2026-10-31
  'Kontrollamt', // zurückgestellt: vor allem Name einer Behörde (Kontrollamt der Stadt Wien, heute Stadtrechnungshof) — als Gattungswort nicht sicher, Regel 14/18 2026-10-31
  'Kontur', // zurückgestellt: Genus in der Fachsprache schwankend (die Kontur; Kunst auch der Kontur), meist Plural — Regel 14 2026-10-31
  'Kramer', // zurückgestellt: Familienname bzw. veraltet für «Krämer» — als Gattungswort nicht sicher, Regel 14/18 2026-10-31
  'Krankenschein', // zurückgestellt: früher Behandlungsschein der Krankenkasse (heute Versichertenkarte, e-card), umgangssprachlich auch Krankmeldung — Bedeutung und Markierung nicht sicher, Regel 14 2026-10-31
  'Krause', // zurückgestellt: vor allem Familienname; als Gattungswort selten (Halskrause, krauses Haar) — Bedeutung nicht sicher, Regel 14 2026-10-31
  'Kreisvorsitzende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Kreisvorsitzende, ein Kreisvorsitzender) — nach den Nomen 2026-10-31
  'Kreisvorsitzender', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (stark gebeugte Form von «der/die Kreisvorsitzende») — nach den Nomen 2026-10-31
  'Kreisverwaltungsreferat', // zurückgestellt: Name einer Behörde (KVR in München) — als Gattungswort nicht sicher, Regel 14/18 2026-10-31
  'Krem', // zurückgestellt: Genus schwankend (die oder der Krem; eingedeutschte Schreibung von «Creme») — Lemma und Genus nicht sicher, Regel 14 2026-10-31
  'Kreml', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Burganlage in russischen Städten / der Moskauer Kreml als Sitz und Sinnbild der russischen Regierung) — nach den Nomen 2026-10-31
  'Kremser', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: offener Pferdewagen für Ausflüge / Einwohner von Krems) — nach den Nomen 2026-10-31
  'Kreuz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zeichen aus zwei Balken, christliches Symbol / unterer Rücken «Kreuzschmerzen» / Spielkartenfarbe / Autobahnkreuz / Musik: Vorzeichen) — nach den Nomen 2026-10-31
  'Kreuzer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kriegsschiff / historische Münze / Segeljacht für längere Fahrten) — nach den Nomen 2026-10-31
  'Kreuzfeuer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Militär: Beschuss von mehreren Seiten / übertragen: «im Kreuzfeuer der Kritik stehen») — nach den Nomen 2026-10-31
  'Kreuzung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Straßenkreuzung / Biologie: Kreuzung von Rassen oder Sorten) — nach den Nomen 2026-10-31
  'Kreuzweg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wegkreuzung / Religion: Leidensweg Jesu, Kreuzwegstationen) — nach den Nomen 2026-10-31
  'Kreuzzug', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschichte: Kriegszüge des Mittelalters / übertragen: leidenschaftlicher Kampf für oder gegen etwas) — nach den Nomen 2026-10-31
  'Krida', // zurückgestellt: österreichischer Rechtsbegriff (betrügerische/fahrlässige Krida = Insolvenzdelikt) — Plural und Gebrauch nicht sicher, Regel 14 2026-10-31
  'Kriegsgegner', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gegner des Krieges, Pazifist / Feind im Krieg, gegnerische Kriegspartei) — nach den Nomen 2026-10-31
  'Kriegsrecht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Völkerrecht für den Krieg / Ausnahmerecht, Militärherrschaft «das Kriegsrecht verhängen») — nach den Nomen 2026-10-31
  'Kriminalbeamter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der Kriminalbeamte, ein Kriminalbeamter) — nach den Nomen 2026-10-31
  'Kriminalist', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beamter der Kriminalpolizei / Fachmann der Kriminalistik) — nach den Nomen 2026-10-31
  'Krippe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Futterkrippe für Tiere / Weihnachtskrippe / Kinderkrippe, Kita für Kleinkinder) — nach den Nomen 2026-10-31
  'Kris', // zurückgestellt: Fachwort (malaiischer Dolch) bzw. Kurzform — Bedeutung und Gebrauch im Deutschen nicht sicher, Regel 14 2026-10-31
  'Kriterium', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Prüfstein, Merkmal für eine Entscheidung / Radsport: Rundstreckenrennen) — nach den Nomen 2026-10-31
  'Kritik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beanstandung, Tadel / Besprechung eines Buches oder Films, Rezension / Philosophie: kritische Prüfung) — nach den Nomen 2026-10-31
  'Kritiker', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: jemand, der etwas kritisiert / Rezensent, Literatur- oder Filmkritiker) — nach den Nomen 2026-10-31
  'Kritikerin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: jemand, die etwas kritisiert / Rezensentin, Literatur- oder Filmkritikerin) — nach den Nomen 2026-10-31
  'Krisis', // zurückgestellt: veraltet für «Krise» bzw. medizinisches Fachwort (Wendepunkt einer Krankheit) — Markierung und Gebrauch nicht sicher, Regel 14 2026-10-31
  'Krone', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kopfschmuck eines Königs, Monarchie / Baumkrone / Zahnkrone / Währung, z. B. dänische Krone) — nach den Nomen 2026-10-31
  'Kronprinz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Thronfolger / übertragen: designierter Nachfolger in Partei oder Firma) — nach den Nomen 2026-10-31
  'Kronzeuge', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Recht: Mittäter, der gegen andere aussagt und milder bestraft wird / wichtigster Zeuge für etwas) — nach den Nomen 2026-10-31
  'Krug', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 3 (Homograph mit gleichem Artikel: der Krug «Gefäß mit Henkel» / der Krug «norddeutsch: Dorfwirtshaus») — nach den Nomen 2026-10-31
  'Kuckuck', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vogel / umgangssprachlich: Pfandsiegel des Gerichtsvollziehers / Ausruf «zum Kuckuck!», «Kuckuck!» beim Versteckspiel) — nach den Nomen 2026-10-31
  'Krupp', // zurückgestellt: vor allem Familien- und Firmenname; als Gattungswort nur medizinisch veraltet (Krupp = Kehlkopfdiphtherie) — Bedeutung nicht sicher, Regel 14/18 2026-10-31
  'Kubikmeter', // zurückgestellt: Genus schwankend (der oder das Kubikmeter, Duden) — wie Hektar/Hektoliter, Regel 14 2026-10-31
  'Kubikzentimeter', // zurückgestellt: Genus schwankend (der oder das Kubikzentimeter, Duden) — wie Kubikmeter, Regel 14 2026-10-31
  'Kugel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: runder Körper, Kugelform / Geschoss einer Schusswaffe / Sport: Kugelstoßen / eine Kugel Eis) — nach den Nomen 2026-10-31
  'Kulisse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Theater: bemalte Bühnenwand / übertragen: Hintergrund, Rahmen «vor der Kulisse der Alpen» / Schein, Fassade) — nach den Nomen 2026-10-31
  'Kult', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: religiöse Verehrung, Ritus / übertragen: übertriebene Verehrung, «Kult sein» = sehr beliebt) — nach den Nomen 2026-10-31
  'Kultur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kunst, Bildung, Lebensweise eines Volkes / Landwirtschaft: Anbau, Pflanzung / Biologie: Bakterienkultur) — nach den Nomen 2026-10-31
  'Kuhl', // zurückgestellt: kein gesichertes Nomen (Familienname; evtl. falsch für «kühl» oder Kuhle) — Regel 14 2026-10-31
  'Kulturbetrieb', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kulturleben insgesamt, der Kulturbetrieb einer Stadt / einzelne Kultureinrichtung als Betrieb) — nach den Nomen 2026-10-31
  'Kulturkampf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschichte: Konflikt zwischen Bismarck und der katholischen Kirche / übertragen: heftiger Streit um Werte in der Gesellschaft) — nach den Nomen 2026-10-31
  'Kulturlandschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: vom Menschen geprägte Landschaft / Gesamtheit der Kultureinrichtungen einer Region) — nach den Nomen 2026-10-31
  'Kulturrevolution', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschichte: die chinesische Kulturrevolution 1966–1976 / allgemein: tiefgreifender kultureller Umbruch) — nach den Nomen 2026-10-31
  'Kumpan', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: umgangssprachlich: Kamerad, Begleiter / abwertend: Mittäter, Komplize) — nach den Nomen 2026-10-31
  'Kumpel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bergmann / umgangssprachlich: Freund, Kamerad) — nach den Nomen 2026-10-31
  'Kultusministerkonferenz', // zurückgestellt: Name einer Organisation (KMK, Deutschland) — keine Gattungs- oder Eigennamen-Karte nach Regel 18 2026-10-31
  'Kundschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gesamtheit der Kunden / österreichisch auch: einzelner Kunde / veraltet: Erkundung, Nachricht) — nach den Nomen 2026-10-31
  'Kunst', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: bildende Kunst, Musik, Literatur / Können, Fertigkeit «die Kunst des Kochens» / Schulfach Kunst) — nach den Nomen 2026-10-31
  'Kunkel', // zurückgestellt: landschaftlich/veraltet für Spinnrocken, sonst Familienname — Bedeutung und Gebrauch nicht sicher, Regel 14 2026-10-31
  'Kunstbetrieb', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kunstwelt insgesamt, Kunstmarkt und Institutionen / einzelner Betrieb der Kunst — wie Kulturbetrieb) — nach den Nomen 2026-10-31
  'Kupfer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Metall / Kupfergeschirr / Kupferstich) — nach den Nomen 2026-10-31
  'Kupplung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Auto: Kupplung und Kupplungspedal / Anhängerkupplung, Verbindung zwischen Fahrzeugen) — nach den Nomen 2026-10-31
  'Kurator', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausstellungsmacher im Museum / Recht: Vormund, Pfleger / Verwaltungsbeamter einer Universität) — nach den Nomen 2026-10-31
  'Kuratorin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausstellungsmacherin im Museum / Recht: Vormundin, Pflegerin / Verwaltung einer Universität) — nach den Nomen 2026-10-31
  'Kurs', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lehrgang, Sprachkurs / Richtung, Route eines Schiffes oder Flugzeugs / Börse: Kurs einer Aktie, Wechselkurs / politische Linie) — nach den Nomen 2026-10-31
  'Kurskorrektur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Börse: Korrektur der Aktienkurse / Änderung von Richtung oder politischer Linie) — nach den Nomen 2026-10-31
  'Kursniveau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Börse: Höhe der Kurse / Niveau eines Sprach- oder Lehrkurses) — nach den Nomen 2026-10-31
  'Kursziel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Börse: erwarteter Aktienkurs / Navigation: Ziel einer Fahrt, eines Flugs) — nach den Nomen 2026-10-31
  'Kurve', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Straßenkurve / Mathematik: Kurve im Diagramm / ugs. Körperrundungen; «die Kurve kriegen») — nach den Nomen 2026-10-31
  'Kurzprogramm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Eiskunstlauf: Kurzprogramm / Waschmaschine, Gerät: kurzes Programm) — nach den Nomen 2026-10-31
  'Kurzschluss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Elektrik: Kurzschluss / ugs. unüberlegte Handlung im Affekt) — nach den Nomen 2026-10-31
  'Kuvert', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Briefumschlag, bes. österr. / gehoben veraltend: Gedeck bei Tisch) — nach den Nomen 2026-10-31
  'Label', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Etikett, Aufkleber / Plattenfirma / Marke, Modelabel) — nach den Nomen 2026-10-31
  'Labyrinth', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Irrgarten / Anatomie: Innenohr) — nach den Nomen 2026-10-31
  'Lacher', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Person, die lacht / kurzes Auflachen, «einen Lacher ernten») — nach den Nomen 2026-10-31
  'Laden', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 + 2 (mehrere Bedeutungen: Geschäft / Fensterladen / ugs. Betrieb «der Laden läuft»; dazu das Laden = Beladen, Aufladen) — nach den Nomen 2026-10-31
  'Lab', // zurückgestellt: Fachwort (das Lab = Labferment zur Käseherstellung) bzw. ugs. englische Kurzform «Lab» für Labor — gemeinte Bedeutung und Gebrauch nicht sicher, Regel 14 2026-10-31
  'Lady', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Dame, vornehme Frau / britischer Adelstitel «Lady») — nach den Nomen 2026-10-31
  'Lage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Situation / Ort, Position eines Hauses / Schicht «eine Lage Papier» / Musik: Tonlage / ugs. «eine Lage» = Runde Getränke) — nach den Nomen 2026-10-31
  'Lagebericht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bericht über die aktuelle Situation, Polizei/Militär / Wirtschaft: Lagebericht im Jahresabschluss) — nach den Nomen 2026-10-31
  'Lager', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Warenlager / Zelt-, Ferienlager / politisches Lager / Technik: Kugellager; Plural Lager/Läger) — nach den Nomen 2026-10-31
  'Lagerung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufbewahrung von Waren / Pflege: Lagerung des Patienten / Geologie: Schichtung) — nach den Nomen 2026-10-31
  'Laie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nichtfachmann / Kirche: Nichtgeistlicher) — nach den Nomen 2026-10-31
  'Lamento', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. abwertend Gejammer, Klage / Musik: Klagegesang) — nach den Nomen 2026-10-31
  'Lamm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: junges Schaf / Lammfleisch / Lammfell / Religion: Lamm Gottes) — nach den Nomen 2026-10-31
  'Land', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Staat / Bundesland / Festland / Ackerland, Boden / Gegensatz zur Stadt; Plural Länder/Lande) — nach den Nomen 2026-10-31
  'Landauer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kutschenart / Einwohner von Landau) — nach den Nomen 2026-10-31
  'Landesgruppe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bundestag: Abgeordnete eines Bundeslandes in einer Fraktion / regionale Untergliederung eines Verbandes) — nach den Nomen 2026-10-31
  'Landesmeister', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Meister eines Bundeslandes / nationaler Meister, «Europapokal der Landesmeister») — nach den Nomen 2026-10-31
  'Landesmeisterschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Meisterschaft eines Bundeslandes / nationale Meisterschaft — wie Landesmeister) — nach den Nomen 2026-10-31
  'Landespartei', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Landesorganisation einer Bundespartei / regionale Partei, nur in einem Land) — nach den Nomen 2026-10-31
  'Landesrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: österr. Mitglied der Landesregierung, Person / beratendes Gremium eines Landes) — nach den Nomen 2026-10-31
  'Landesschulrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: österr. Schulbehörde bis 2018 / Person: Schulaufsichtsbeamter) — nach den Nomen 2026-10-31
  'Landesvater', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: veraltet Landesherr, Fürst / scherzhaft Regierungschef eines Landes) — nach den Nomen 2026-10-31
  'Landesvorsitzende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Landesvorsitzende) — nach den Nomen 2026-10-31
  'Landesvorsitzender', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (stark gebeugte Form von «Landesvorsitzende» — gehört zu derselben Karte) — nach den Nomen 2026-10-31
  'Landeszentrale', // zurückgestellt: meist nur Teil von Behördennamen («Landeszentrale für politische Bildung») — als Einzelwort Bedeutung nicht sicher, Regel 14/18 2026-10-31
  'Landhaus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Haus auf dem Land / österr. Sitz von Landtag und Landesregierung) — nach den Nomen 2026-10-31
  'Landjugend', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Jugend auf dem Land insgesamt / Verband, Verein «die Landjugend») — nach den Nomen 2026-10-31
  'Landrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Deutschland: Leiter eines Landkreises, Person / Schweiz: Kantonsparlament in einigen Kantonen) — nach den Nomen 2026-10-31
  'Landschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gegend, Natur / Landschaftsgemälde / übertragen «die politische Landschaft») — nach den Nomen 2026-10-31
  'Landschaftsbild', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aussehen einer Landschaft / Landschaftsgemälde) — nach den Nomen 2026-10-31
  'Landsmannschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vereinigung von Heimatvertriebenen / Studentenverbindung) — nach den Nomen 2026-10-31
  'Landtagsabgeordnete', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Landtagsabgeordnete) — nach den Nomen 2026-10-31
  'Landtagsabgeordneter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (stark gebeugte Form von «Landtagsabgeordnete» — gehört zu derselben Karte) — nach den Nomen 2026-10-31
  'Landwirtschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wirtschaftszweig Agrarwirtschaft / einzelner landwirtschaftlicher Betrieb «eine kleine Landwirtschaft») — nach den Nomen 2026-10-31
  'Langzeitarbeitsloser', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (stark gebeugte Form von «der/die Langzeitarbeitslose», substantiviertes Adjektiv) — nach den Nomen 2026-10-31
  'Lappen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Putzlappen, Stück Stoff / Anatomie: Lungenlappen, Ohrläppchen / ugs. Führerschein / ugs. Geldschein) — nach den Nomen 2026-10-31
  'Larve', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Insektenlarve / veraltet: Maske, Gesichtsmaske) — nach den Nomen 2026-10-31
  'Last', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: schwere Ladung / Bürde, Belastung «zur Last fallen» / Plural Lasten: finanzielle Abgaben) — nach den Nomen 2026-10-31
  'Lastenausgleich', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: allgemein Ausgleich von Belastungen / BRD: Entschädigung für Kriegsschäden, Gesetz) — nach den Nomen 2026-10-31
  'Laterne', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lampe mit Gehäuse, Laterne zu Sankt Martin / Straßenlaterne / Bauwesen: Dachaufsatz) — nach den Nomen 2026-10-31
  'Latte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Holzlatte / Sport: Torlatte, Querlatte / ugs. Latte macchiato / vulgär) — nach den Nomen 2026-10-31
  'Lauf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Laufen, Wettlauf / Verlauf «im Lauf der Zeit» / Flusslauf / Gewehrlauf / Musik: Lauf) — nach den Nomen 2026-10-31
  'Laufbahn', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: berufliche Karriere / Sport: Laufbahn im Stadion) — nach den Nomen 2026-10-31
  'Laptop', // zurückgestellt: Genus schwankend (der oder das Laptop, Duden) — wie Kubikmeter, Regel 14 2026-10-31
  'Lauda', // zurückgestellt: Familienname (Niki Lauda) — kein Gattungswort und kein geografischer Name, Regel 18 2026-10-31
  'Laufsteg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Modenschau, Catwalk / schmaler Steg, Laufbrett) — nach den Nomen 2026-10-31
  'Laufwerk', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Computer: Laufwerk / Mechanik: Antriebswerk, Uhrwerk) — nach den Nomen 2026-10-31
  'Laufzeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gültigkeitsdauer eines Vertrags, Kredits / Spieldauer eines Films / Sport: gelaufene Zeit / IT: Laufzeit eines Programms) — nach den Nomen 2026-10-31
  'Laune', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stimmung «gute Laune» / Plural Launen: wechselnde Stimmungen, Einfälle «eine Laune der Natur») — nach den Nomen 2026-10-31
  'Laut', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ton, Geräusch / Sprachlaut, Phonetik) — nach den Nomen 2026-10-31
  'Laute', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 3 (Homograph: die Laute = Saiteninstrument ↔ die Laute = Plural von der Laut) — nach den Nomen 2026-10-31
  'Leader', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anführer, Bandleader / Sport, österr./schweiz.: Tabellenführer) — nach den Nomen 2026-10-31
  'Leben', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lebendigsein / Lebenszeit, Lebenslauf / Lebensweise, Alltag / Lebhaftigkeit «Leben in die Bude bringen») — nach den Nomen 2026-10-31
  'Learning', // zurückgestellt: kein selbstständiges deutsches Nomen (nur in Fügungen wie E-Learning, Machine Learning) — Gebrauch und Genus nicht sicher, Regel 14 2026-10-31
  'Lebensalter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Alter eines Menschen / Lebensabschnitt «im mittleren Lebensalter») — nach den Nomen 2026-10-31
  'Lebensart', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lebensweise / gutes Benehmen, Umgangsformen «keine Lebensart haben») — nach den Nomen 2026-10-31
  'Lebensdauer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Dauer des Lebens / Haltbarkeit, Nutzungsdauer eines Geräts) — nach den Nomen 2026-10-31
  'Lebensform', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Art des Zusammenlebens / Biologie: Organismus, Lebewesen) — nach den Nomen 2026-10-31
  'Lebensgemeinschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zusammenleben, eheähnliche Gemeinschaft / Biologie: Biozönose) — nach den Nomen 2026-10-31
  'Lebenslauf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verlauf des Lebens / schriftliche Darstellung, CV für Bewerbungen) — nach den Nomen 2026-10-31
  'Lebensraum', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Raum zum Leben eines Menschen, Volkes / Biologie: Biotop, Habitat / NS-Begriff) — nach den Nomen 2026-10-31
  'Lebensversicherung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Versicherungsvertrag auf den Todes-/Erlebensfall / Versicherungsgesellschaft) — nach den Nomen 2026-10-31
  'Lebenszeichen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zeichen, dass jemand lebt (Puls, Atmung) / Nachricht von jemandem «kein Lebenszeichen von sich geben») — nach den Nomen 2026-10-31
  'Leber', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Organ / Speise aus Tierleber «Leber mit Zwiebeln») — nach den Nomen 2026-10-31
  'Lech', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2 (Homograph: der Lech = Fluss ↔ Lech = Ort am Arlberg in Vorarlberg, ohne Artikel) — nach den Nomen 2026-10-31
  'Leckerbissen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: besonders feine Speise / übertragen: etwas Besonderes «ein musikalischer Leckerbissen») — nach den Nomen 2026-10-31
  'Leder', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Material aus Tierhaut / ugs. der Fußball «das Leder» / Fensterleder) — nach den Nomen 2026-10-31
  'Lederer', // zurückgestellt: veraltet/landschaftlich für Gerber, sonst Familienname — Gebrauch nicht sicher, Regel 14 2026-10-31
  'Lee', // zurückgestellt: Seemannssprache (die dem Wind abgewandte Seite), Genus schwankend (die oder das Lee) — Regel 14 2026-10-31
  'Leere', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1/4 (mehrere Bedeutungen: Leersein, leerer Raum / innere Leere, Gefühl; dazu substantiviertes «ins Leere») — nach den Nomen 2026-10-31
  'Leerlauf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Technik: Leerlauf des Motors, Gang / übertragen: Phase ohne Ergebnis) — nach den Nomen 2026-10-31
  'Leerstelle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: freie Stelle, Lücke / Sprachwissenschaft: Valenzstelle / Leerzeichen beim Schreiben) — nach den Nomen 2026-10-31
  'Legende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Heiligenlegende, Sage / Mythos um eine Person «eine lebende Legende» / Zeichenerklärung auf Karten) — nach den Nomen 2026-10-31
  'Legion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: römische Truppeneinheit / Fremdenlegion / gehoben: große Menge «Legion sein») — nach den Nomen 2026-10-31
  'Legitimation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Berechtigung, Rechtfertigung / Ausweis, Nachweis / Recht: Ehelicherklärung eines Kindes) — nach den Nomen 2026-10-31
  'Lehne', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rücken-/Armlehne / süddeutsch, österreichisch: Abhang, Hang) — nach den Nomen 2026-10-31
  'Lehrberuf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beruf des Lehrers / Ausbildungsberuf mit Lehre) — nach den Nomen 2026-10-31
  'Lehrbetrieb', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausbildungsbetrieb für Lehrlinge / Unterrichtsbetrieb an Schule, Hochschule) — nach den Nomen 2026-10-31
  'Lehrgeld', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: früher Gebühr für die Lehre / übertragen «Lehrgeld zahlen» = durch Schaden lernen) — nach den Nomen 2026-10-31
  'Lehrmeister', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Meister, der Lehrlinge ausbildet / übertragen: Vorbild «Das Leben ist der beste Lehrmeister») — nach den Nomen 2026-10-31
  'Lehrstunde', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Unterrichtsstunde / übertragen: lehrreiche Erfahrung, Lektion «eine Lehrstunde erteilen») — nach den Nomen 2026-10-31
  'Leib', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Körper «am eigenen Leib» / Bauch, Rumpf; dazu Leib Christi) — nach den Nomen 2026-10-31
  'Leibchen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: früher Mieder, Kinderleibchen / österr., schweiz.: Unterhemd, T-Shirt, Trikot) — nach den Nomen 2026-10-31
  'Leichter', // zurückgestellt: Seemannssprache (Lastkahn zum Leichtern) — sonst Komparativ von «leicht»; gemeintes Wort und Gebrauch nicht sicher, Regel 14 2026-10-31
  'Leichtgewicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: Gewichtsklasse / Sportler dieser Klasse / ugs. übertragen: unbedeutende Person, leichte Sache) — nach den Nomen 2026-10-31
  'Leichtigkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: geringes Gewicht / Mühelosigkeit «mit Leichtigkeit» / Unbeschwertheit) — nach den Nomen 2026-10-31
  'Leidenschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: starkes Gefühl, Begeisterung für etwas / heftige Liebe, Verlangen) — nach den Nomen 2026-10-31
  'Leidensgeschichte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschichte des Leidens eines Menschen / Christentum: Passion Christi) — nach den Nomen 2026-10-31
  'Leidensweg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: lange Zeit des Leidens / Christentum: Kreuzweg Christi) — nach den Nomen 2026-10-31
  'Leidtragende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv/Partizip: der/die Leidtragende, ein Leidtragender) — nach den Nomen 2026-10-31
  'Leidwesen', // zurückgestellt: nur in der festen Wendung «zu meinem/seinem Leidwesen» — wie im Handumdrehen, Regel 14 2026-10-31
  'Leinen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1/3 (mehrere Bedeutungen: Gewebe aus Flachs / Leinenzeug; dazu gleich geschrieben: die Leinen = Plural von die Leine) — nach den Nomen 2026-10-31
  'Leinwand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Malerleinwand / Projektionsfläche im Kino / Gewebe) — nach den Nomen 2026-10-31
  'Leis', // zurückgestellt: Fachwort (mittelalterliches geistliches Volkslied) bzw. Nebenform von «leise» — gemeintes Wort und Gebrauch nicht sicher, Regel 14 2026-10-31
  'Leisten', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2 (Homograph: der Leisten = Schuhmacherform «alles über einen Leisten schlagen» ↔ das Leisten = substantivierter Infinitiv von leisten) — nach den Nomen 2026-10-31
  'Leistung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ergebnis, Arbeitsleistung / Physik, Technik: Leistung in Watt / Dienstleistung, Versicherungsleistung, Zahlung) — nach den Nomen 2026-10-31
  'Leitfaden', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kurzes Lehrbuch, Anleitung / leitender Gedanke, roter Faden) — nach den Nomen 2026-10-31
  'Leitgeb', // zurückgestellt: österreichisch-mundartlich/veraltet für Wirt, sonst Familienname — Gebrauch nicht sicher, Regel 14 2026-10-31
  'Leitlinie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Grundsatz, Richtlinie / Verkehr: unterbrochene Linie auf der Fahrbahn / Mathematik) — nach den Nomen 2026-10-31
  'Leitmotiv', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musik, Literatur: wiederkehrendes Motiv / übertragen: Leitgedanke) — nach den Nomen 2026-10-31
  'Leitschiene', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: österr./schweiz.: Leitplanke / Technik, Bahn: führende Schiene) — nach den Nomen 2026-10-31
  'Leitung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Führung, Management / Rohrleitung, Stromleitung / Telefonleitung «in der Leitung sein») — nach den Nomen 2026-10-31
  'Lektion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Unterrichtsstunde, Kapitel im Lehrbuch / übertragen: Lehre, Zurechtweisung «jemandem eine Lektion erteilen») — nach den Nomen 2026-10-31
  'Lektor', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sprachlehrer an der Universität / Verlagslektor / kath. Kirche: Vorleser im Gottesdienst) — nach den Nomen 2026-10-31
  'Lenker', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lenkstange am Fahrrad / österr.: Fahrer eines Fahrzeugs / jemand, der etwas lenkt) — nach den Nomen 2026-10-31
  'Lenkung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Lenken, Steuerung, Führung / Technik: Lenkvorrichtung eines Fahrzeugs) — nach den Nomen 2026-10-31
  'Lenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: dichterisch: Frühling / ugs. «sich einen schönen Lenz machen» = faulenzen / Plural: Lebensjahre) — nach den Nomen 2026-10-31
  'Lenzing', // zurückgestellt: Ortsname in Oberösterreich, vor allem als Firmenname (Lenzing AG) bekannt — geografische Karte oder Firmenname nicht sicher, Regel 18 2026-10-31
  'Lesart', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Deutung, Interpretation / Philologie: Textvariante) — nach den Nomen 2026-10-31
  'Leslie', // zurückgestellt: Vorname — kein Gattungswort und kein geografischer Name, Regel 18 2026-10-31
  'Lesung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Autorenlesung / Parlament: Beratung eines Gesetzes «in erster Lesung» / Kirche: Lesung aus der Bibel) — nach den Nomen 2026-10-31
  'Let', // zurückgestellt: Fachwort Tennis (Netzaufschlag), Genus und Gebrauch nicht sicher — Regel 14 2026-10-31
  'Lethargie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Medizin: Schlafsucht, Bewusstseinstrübung / Teilnahmslosigkeit, Trägheit) — nach den Nomen 2026-10-31
  'Letten', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1/3 (der Letten = landschaftlich: Lehm, Ton ↔ die Letten = Plural von der Lette, Volk in Lettland) — nach den Nomen 2026-10-31
  'Letter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Druckbuchstabe / Druckwesen: Drucktype) — nach den Nomen 2026-10-31
  'Leuchte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lampe, Beleuchtungskörper / ugs. kluger Mensch «keine große Leuchte sein») — nach den Nomen 2026-10-31
  'Level', // zurückgestellt: Genus schwankend (der oder das Level, Duden) — wie Laptop, Regel 14 2026-10-31
  'Lew', // zurückgestellt: Währungseinheit Bulgariens (Plural Lewa) bzw. Vorname — gemeintes Wort nicht sicher, Regel 14 2026-10-31
  'Lex', // zurückgestellt: Fachwort (Gesetz, meist mit Namen: «Lex XY»), Gebrauch als Einzelwort nicht sicher — Regel 14 2026-10-31
  'Lexikon', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nachschlagewerk / Sprachwissenschaft: Wortschatz einer Sprache) — nach den Nomen 2026-10-31
  'Liaison', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Liebesbeziehung / Verbindung, Zusammenarbeit / Phonetik: Bindung im Französischen) — nach den Nomen 2026-10-31
  'Liberation', // zurückgestellt: kein gebräuchliches deutsches Nomen (veraltet für Befreiung bzw. englisch) — Regel 14 2026-10-31
  'Libero', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fußball: freier Abwehrspieler / Volleyball: Abwehrspezialist) — nach den Nomen 2026-10-31
  'Liberty', // zurückgestellt: englisches Wort, kein deutsches Nomen (allenfalls Name) — Regel 14 2026-10-31
  'Licht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Helligkeit / Lampe «das Licht ausmachen» / Kerze / übertragen «ans Licht kommen») — nach den Nomen 2026-10-31
  'Lichtbild', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Amtssprache: Passfoto / veraltend: Dia, Fotografie) — nach den Nomen 2026-10-31
  'Lichte', // zurückgestellt: nur in Fügungen («lichte Weite», «im Lichte von») bzw. Form von Licht — als eigenes Nomen nicht sicher, Regel 14 2026-10-31
  'Lichter', // zurückgestellt: nur Pluralform von «das Licht» (bzw. Seemannssprache Lastkahn) — kein eigenes Lemma sicher, Regel 14 2026-10-31
  'Lichterkette', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kette aus kleinen Lampen / Demonstration mit Kerzen, Menschenkette) — nach den Nomen 2026-10-31
  'Lichtspiel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: veraltet: Film, Kino «Lichtspieltheater» / Spiel des Lichts) — nach den Nomen 2026-10-31
  'Lido', // zurückgestellt: Fremdwort (Badestrand) bzw. Name (Lido di Venezia) — Bedeutung und Gebrauch nicht sicher, Regel 14 2026-10-31
  'Lieb', // zurückgestellt: veraltet/dichterisch (das Lieb = Geliebte) — Gebrauch und Genus nicht sicher, Regel 14 2026-10-31
  'Liebe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gefühl der Zuneigung / geliebte Person «meine große Liebe» / Liebe zu etwas, Hingabe / Sexualität) — nach den Nomen 2026-10-31
  'Liebesgeschichte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: erzählte Geschichte über Liebe / ugs. Liebesaffäre) — nach den Nomen 2026-11-01
  'Liebhaber', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geliebter, Liebespartner / Kenner, Freund einer Sache «Kunstliebhaber») — nach den Nomen 2026-11-01
  'Liebling', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: geliebte Person, Kosewort / bevorzugte Person «Liebling des Lehrers») — nach den Nomen 2026-11-01
  'Lieferung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Liefern / gelieferte Ware / Teil eines Werkes in Lieferungen) — nach den Nomen 2026-11-01
  'Liga', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: Spielklasse / Bund, Vereinigung «Liga der Nationen») — nach den Nomen 2026-11-01
  'Limburg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stadt an der Lahn / Provinz in Belgien bzw. den Niederlanden) — nach den Nomen 2026-11-01
  'Limes', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: römischer Grenzwall / Mathematik: Grenzwert) — nach den Nomen 2026-11-01
  'Limousine', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pkw mit Stufenheck, österr. auch normaler Pkw / lange Luxus-Limousine) — nach den Nomen 2026-11-01
  'Linie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Strich / Verkehrsverbindung «Linie 5» / Reihe / Richtung, Kurs «in erster Linie») — nach den Nomen 2026-11-01
  'Linke', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: die linke Hand / politische Linke) + Fall 1 — nach den Nomen 2026-11-01
  'Linkspartei', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: allgemein linke Partei / Name der Partei «Die Linke» bzw. Linkspartei.PDS) — nach den Nomen 2026-11-01
  'Linse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hülsenfrucht / optische Linse / Augenlinse) — nach den Nomen 2026-11-01
  'Linux', // zurückgestellt: Name eines Betriebssystems (Produkt/Marke) — Regel 18 2026-11-01
  'Lion', // zurückgestellt: englisches Wort bzw. Name, kein deutsches Nomen — Regel 14 2026-11-01
  'Liquidation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Auflösung einer Firma / Tötung / Honorarrechnung) — nach den Nomen 2026-11-01
  'Liquidierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Auflösung einer Firma / Tötung) — nach den Nomen 2026-11-01
  'Liter', // zurückgestellt: Artikel doppelt (der/das Liter, Duden) — Regel 14 2026-11-01
  'Literatur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Dichtung, schöne Literatur / Fachliteratur, Schriften zu einem Thema) — nach den Nomen 2026-11-01
  'Literaturbetrieb', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (wie Kulturbetrieb: Gesamtheit der Einrichtungen / Tätigkeit des Literaturmarkts) — nach den Nomen 2026-11-01
  'Literaturgeschichte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschichte der Literatur / Werk, das sie darstellt) — nach den Nomen 2026-11-01
  'Live', // zurückgestellt: kein Nomen (Adverb/Adjektiv «live»), als Nomen nicht sicher — Regel 14 2026-11-01
  'Lloyd', // zurückgestellt: Name (Firmen/Personen: Lloyd’s, Norddeutscher Lloyd) — Regel 18 2026-11-01
  'Lobby', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hotelhalle, Vorhalle / Interessengruppe) — nach den Nomen 2026-11-01
  'Lockerung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Lockern «Schraube, Muskeln» / Abschwächung von Regeln) — nach den Nomen 2026-11-01
  'Lodge', // zurückgestellt: Fremdwort (Unterkunft), Gebrauch und Genus im Deutschen nicht sicher — Regel 14 2026-11-01
  'Loft', // zurückgestellt: Artikel doppelt (der/das Loft, Duden) — Regel 14 2026-11-01
  'Loge', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Theaterloge / Pförtnerloge / Freimaurerloge) — nach den Nomen 2026-11-01
  'Logik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lehre vom Denken / Folgerichtigkeit «die Logik einer Sache») — nach den Nomen 2026-11-01
  'Logo', // zurückgestellt: Artikel doppelt (das/der Logo, Duden) — Regel 14 2026-11-01
  'Logos', // zurückgestellt: Fachwort (Philosophie/Theologie) bzw. Pluralform von «Logo» — als Lemma nicht sicher, Regel 14 2026-11-01
  'Lohn', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Arbeitsentgelt / Belohnung, Vergeltung «der Lohn für die Mühe») — nach den Nomen 2026-11-01
  'Lokal', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gaststätte / Raum, Versammlungslokal) — nach den Nomen 2026-11-01
  'Lolita', // zurückgestellt: Name (Romanfigur) bzw. übertragener Gebrauch für Mädchen — Gebrauch heikel/unsicher, Regel 14 2026-11-01
  'Lorbeer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pflanze / Gewürz «Lorbeerblatt» / übertragen Ruhm «Lorbeeren ernten») — nach den Nomen 2026-11-01
  'Los', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lotterielos / Schicksal / Warenposten) — nach den Nomen 2026-11-01
  'Lose', // zurückgestellt: als eigenes Lemma nicht sicher (Pluralform von «das Los»; Seemannssprache) — Regel 14 2026-11-01
  'Lost', // zurückgestellt: englisches Wort, kein deutsches Nomen — Regel 14 2026-11-01
  'Lotse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schiffslotse / Fluglotse / übertragen: Führer, Begleiter) — nach den Nomen 2026-11-01
  'Lotto', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zahlenlotterie / Gesellschaftsspiel mit Bildkarten) — nach den Nomen 2026-11-01
  'Lotus', // zurückgestellt: Schreibvariante (Duden: Hauptform «Lotos»), auch Marke — Regel 14 2026-11-01
  'Luft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gasgemisch, das wir atmen / Atem «Luft holen» / Spielraum «Luft haben») — nach den Nomen 2026-11-01
  'Luftdruck', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Druck der Atmosphäre / Reifendruck / Druckwelle einer Explosion) — nach den Nomen 2026-11-01
  'Lufthansa', // zurückgestellt: Name einer Firma (Fluggesellschaft) — Regel 18 2026-11-01
  'Luftlinie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kürzeste Entfernung «Luftlinie 10 km» / Fluggesellschaft) — nach den Nomen 2026-11-01
  'Lummer', // zurückgestellt: regional/Fachwort (Lendenstück), Bedeutung und Gebrauch nicht sicher — Regel 14 2026-11-01
  'Lust', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wunsch, Bedürfnis «Lust haben» / Freude / sexuelles Verlangen) — nach den Nomen 2026-11-01
  'Lustgarten', // zurückgestellt: heute v. a. Name (Berliner Lustgarten), sonst veraltet — Gebrauch nicht sicher, Regel 14 2026-11-01
  'Luzern', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stadt / Kanton Luzern) — nach den Nomen 2026-11-01
  'Mach', // zurückgestellt: Fachwort/Name (Mach-Zahl, Physiker Ernst Mach) — als eigenes Nomen nicht sicher, Regel 14 2026-11-01
  'Mache', // zurückgestellt: umgangssprachlich, fast nur in Wendungen («etwas in der Mache haben», «das ist nur Mache») — Regel 14 2026-11-01
  'Macht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einfluss, Herrschaft / Kraft, Stärke / mächtiger Staat «Großmacht») — nach den Nomen 2026-11-01
  'Madame', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: französische Anrede, Dame / ugs. Bordellwirtin) — nach den Nomen 2026-11-01
  'Madison', // zurückgestellt: Name (Stadt/Person, englisch) — Bezug nicht eindeutig, Regel 14/18 2026-11-01
  'Madonna', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gottesmutter Maria / Darstellung Marias in der Kunst) — nach den Nomen 2026-11-01
  'Mafia', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: sizilianische Verbrecherorganisation / übertragen jede mafiaähnliche Gruppe) — nach den Nomen 2026-11-01
  'Magazin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zeitschrift / Lager, Lagerraum / Patronenmagazin) — nach den Nomen 2026-11-01
  'Magd', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: veraltend Landarbeiterin / dichterisch veraltet Jungfrau) — nach den Nomen 2026-11-01
  'Magie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zauberei / Zauberkunst des Varietés / übertragen Faszination, Zauber) — nach den Nomen 2026-11-01
  'Magier', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zauberer, Zauberkünstler / Priester im alten Persien) — nach den Nomen 2026-11-01
  'Magister', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: akademischer Grad / Titel, österr. auch Apotheker / veraltet Lehrer) — nach den Nomen 2026-11-01
  'Magnet', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Eisen anziehender Körper / übertragen Anziehungspunkt «Publikumsmagnet») — nach den Nomen 2026-11-01
  'Magnum', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: große Weinflasche / Patrone, Revolver «Magnum») — nach den Nomen 2026-11-01
  'Mahl', // zurückgestellt: gehoben; Plural doppelt (Mähler/Mahle) und Gebrauch nur in Wendungen sicher — Regel 14 2026-11-01
  'Mahlzeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Essen / Gruß «Mahlzeit!») — nach den Nomen 2026-11-01
  'Mahnung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ermahnung / Zahlungserinnerung, Mahnbrief) — nach den Nomen 2026-11-01
  'Mahr', // zurückgestellt: veraltet/landschaftlich (Nachtmahr), Gebrauch nicht sicher — Regel 14 2026-11-01
  'Mailbox', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sprachbox am Telefon / elektronisches Postfach) — nach den Nomen 2026-11-01
  'Makedonien', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Staat Nordmazedonien / historische Region, griechische Region) — nach den Nomen 2026-11-01
  'Makulatur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Altpapier, Fehldruck / übertragen wertlos «etwas ist Makulatur») — nach den Nomen 2026-11-01
  'Mal', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 3 (Homograph gleicher Artikel: das Mal «Zeitpunkt, -mal» / das Mal «Zeichen, Fleck» — Plural Male/Mäler) — nach den Nomen 2026-11-01
  'Maler', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kunstmaler / Handwerker, Anstreicher) — nach den Nomen 2026-11-01
  'Malerei', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kunst des Malens / einzelnes Gemälde) — nach den Nomen 2026-11-01
  'Malerin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kunstmalerin / Handwerkerin, Anstreicherin) — nach den Nomen 2026-11-01
  'Malteser', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einwohner Maltas / Mitglied des Malteserordens, Hilfsdienst / Hunderasse) — nach den Nomen 2026-11-01
  'Mamma', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Medizin Brustdrüse / landschaftlich Mama) — nach den Nomen 2026-11-01
  'Management', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Leitung, Führung als Tätigkeit / die Führungskräfte eines Unternehmens) — nach den Nomen 2026-11-01
  'Manager', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Führungskraft im Unternehmen / Betreuer von Künstlern oder Sportlern) — nach den Nomen 2026-11-01
  'Managerin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Führungskraft im Unternehmen / Betreuerin von Künstlern oder Sportlern) — nach den Nomen 2026-11-01
  'Mandat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Auftrag, Vollmacht «Anwaltsmandat» / Sitz eines Abgeordneten) — nach den Nomen 2026-11-01
  'Mandatar', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bevollmächtigter / österr. Abgeordneter) — nach den Nomen 2026-11-01
  'Mandl', // zurückgestellt: österr./bair. ugs. für Männchen, Gebrauch und Plural nicht sicher — Regel 14 2026-11-01
  'Manier', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Art und Weise, Stil / Plural «Manieren» = Umgangsformen) — nach den Nomen 2026-11-01
  'Manifest', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Grundsatzerklärung, Programm / Seefahrt Ladungsverzeichnis) — nach den Nomen 2026-11-01
  'Manifestation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Sichtbarwerden / Medizin Auftreten einer Krankheit / schweiz. Kundgebung) — nach den Nomen 2026-11-01
  'Manipulation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: gezielte Beeinflussung / Handhabung, Handgriff / Medizin) — nach den Nomen 2026-11-01
  'Manko', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mangel, Nachteil / Kaufmannssprache Fehlbetrag) — nach den Nomen 2026-11-01
  'Mannequin', // zurückgestellt: Artikel doppelt (das/der Mannequin) — Regel 14 2026-11-01
  'Mannschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sportteam / Besatzung eines Schiffes, Flugzeugs / Truppe) — nach den Nomen 2026-11-01
  'Mantel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kleidungsstück / Hülle, Reifenmantel / Technik, Geometrie) — nach den Nomen 2026-11-01
  'Manufaktur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Betrieb mit Handarbeit / handgefertigtes Erzeugnis) — nach den Nomen 2026-11-01
  'Manuskript', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Handschrift / Druckvorlage / Notizen für eine Rede) — nach den Nomen 2026-11-01
  'Mappe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sammelmappe, Ordner / Schultasche, Aktentasche) — nach den Nomen 2026-11-01
  'Mara', // zurückgestellt: Tiername (Pampashase) oder Name — Bezug nicht eindeutig, Regel 14 2026-11-01
  'Marburg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stadt in Hessen / deutscher Name von Maribor, Slowenien) — nach den Nomen 2026-11-01
  'Marge', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Handelsspanne / Spielraum, Abstand) — nach den Nomen 2026-11-01
  'Marienkirche', // zurückgestellt: Kirchenname vieler Kirchen — kein allgemeines Nomen, Regel 14/18 2026-11-01
  'Marine', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Seestreitkräfte / Seewesen eines Staates / Malerei Seestück) — nach den Nomen 2026-11-01
  'Marionette', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gliederpuppe / übertragen willenloser Mensch) — nach den Nomen 2026-11-01
  'Marke', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Warenmarke / Briefmarke / Wertmarke, Grenzwert «Marke») — nach den Nomen 2026-11-01
  'Markenzeichen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Warenzeichen / übertragen typisches Kennzeichen einer Person) — nach den Nomen 2026-11-01
  'Markierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Markieren / Zeichen, Kennzeichnung) — nach den Nomen 2026-11-01
  'Markt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wochenmarkt, Marktplatz / Wirtschaft: Angebot und Nachfrage / Marktgemeinde) — nach den Nomen 2026-11-01
  'Marquis', // zurückgestellt: französischer Adelstitel, selten; Aussprache/Plural im Deutschen nicht sicher — Regel 14 2026-11-01
  'Marschrichtung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Richtung eines Marsches / übertragen Vorgehensweise, Kurs) — nach den Nomen 2026-11-01
  'Marschroute', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Weg eines Marsches / übertragen Strategie, Vorgehen) — nach den Nomen 2026-11-01
  'Martini', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 3 (Homograph: Martini «Martinstag, 11. November» / der Martini «Cocktail, Wermut») — nach den Nomen 2026-11-01
  'Martyrium', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Opfertod für den Glauben / übertragen große Qual) — nach den Nomen 2026-11-01
  'Masche', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schlinge beim Stricken, Netz / ugs. Trick) — nach den Nomen 2026-11-01
  'Maschine', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gerät / ugs. Flugzeug, Motorrad / Schreibmaschine) — nach den Nomen 2026-11-01
  'Maschinenbauer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ingenieur, Facharbeiter / Unternehmen des Maschinenbaus) — nach den Nomen 2026-11-01
  'Maschinerie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mechanismus, Antrieb / übertragen Apparat, Bürokratie) — nach den Nomen 2026-11-01
  'Maske', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gesichtsmaske, Schutzmaske / Theater, Verkleidung / Computer Eingabemaske) — nach den Nomen 2026-11-01
  'Masse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Menge, Menschenmenge / Physik Masse / breiige Mischung, Teig) — nach den Nomen 2026-11-01
  'Master', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: akademischer Grad, Masterstudium / Originalaufnahme / Spielleiter) — nach den Nomen 2026-11-01
  'Match', // zurückgestellt: Artikel doppelt (das Match; österr./schweiz. auch der Match) — Regel 14 2026-11-01
  'Material', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Werkstoff, Rohstoff / Unterlagen, Hilfsmittel, Beweismaterial) — nach den Nomen 2026-11-01
  'Materialismus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: philosophische Lehre / Einstellung, die nur Besitz schätzt) — nach den Nomen 2026-11-01
  'Materie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stoff, Physik / Gegenstand eines Fachgebiets, Thema) — nach den Nomen 2026-11-01
  'Matrix', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mathematik / Biologie, Technik Grundsubstanz, Form) — nach den Nomen 2026-11-01
  'Matsch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: breiiger Schmutz, Schneematsch / Kartenspiel) — nach den Nomen 2026-11-01
  'Mattscheibe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bildschirm, ugs. Fernseher / mattes Glas / ugs. «Mattscheibe haben» = benommen sein) — nach den Nomen 2026-11-01
  'Matz', // zurückgestellt: umgangssprachlich/Kosename, Gebrauch nicht sicher — Regel 14 2026-11-01
  'Mauer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wand aus Steinen / die Berliner Mauer / Sport Spielermauer beim Freistoß) — nach den Nomen 2026-11-01
  'Mauerbau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bau einer Mauer / Bau der Berliner Mauer 1961) — nach den Nomen 2026-11-01
  'Maul', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mund eines Tieres / derb Mund eines Menschen) — nach den Nomen 2026-11-01
  'Maulkorb', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Korb für Hunde / übertragen Redeverbot) — nach den Nomen 2026-11-01
  'Maulwurf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tier / übertragen eingeschleuster Spion) — nach den Nomen 2026-11-01
  'Mautner', // zurückgestellt: veraltet/österr. für Zöllner, auch Familienname — Gebrauch nicht sicher, Regel 14 2026-11-01
  'Maximum', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Höchstmaß, Höchstwert / Mathematik / Meteorologie Hochdruckgebiet) — nach den Nomen 2026-11-01
  'Maxwell', // zurückgestellt: Personenname / physikalische Einheit — kein sicheres Nomen, Regel 14/18 2026-11-01
  'Mechanik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Teilgebiet der Physik / Mechanismus, Getriebe einer Maschine) — nach den Nomen 2026-11-01
  'Mechanismus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: technische Vorrichtung / übertragen selbsttätiger Ablauf) — nach den Nomen 2026-11-01
  'Meditation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nachdenken, Betrachtung / religiöse Versenkung, Entspannungsübung) — nach den Nomen 2026-11-01
  'Medizin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Heilkunde / Arznei, Medikament) — nach den Nomen 2026-11-01
  'Mehr', // zurückgestellt: substantiviertes Zahlwort, fast nur in Wendungen («ein Mehr an …»), Plural nicht sicher — Regel 14 2026-11-01
  'Mehrwert', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nutzen, zusätzlicher Wert / Wirtschaft, Marx: Mehrwert) — nach den Nomen 2026-11-01
  'Mehrzahl', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: größerer Teil, Mehrheit / Grammatik: Plural) — nach den Nomen 2026-11-01
  'Meier', // zurückgestellt: Familienname / historisch Gutsverwalter — Gebrauch nicht sicher, Regel 14/18 2026-11-01
  'Meilenstein', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stein am Weg / übertragen wichtiger Abschnitt) — nach den Nomen 2026-11-01
  'Meister', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Handwerksmeister / Sieger, Champion / großer Könner, Lehrer) — nach den Nomen 2026-11-01
  'Meisterin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Handwerksmeisterin / Siegerin, Championesse / große Könnerin) — nach den Nomen 2026-11-01
  'Meisterklasse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Klasse für besonders Begabte an Musik-/Kunsthochschulen / Vorbereitungsklasse auf die Meisterprüfung) — nach den Nomen 2026-11-01
  'Meisterschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wettkampf um den Titel / Können, Vollendung) — nach den Nomen 2026-11-01
  'Meistertitel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Titel als Sieger einer Meisterschaft / Handwerksmeistertitel) — nach den Nomen 2026-11-01
  'Melange', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mischung / österr. Milchkaffee) — nach den Nomen 2026-11-01
  'Meldung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nachricht, Bericht / dienstliche Mitteilung, Anzeige / Anmeldung, Teilnahme) — nach den Nomen 2026-11-01
  'Melodram', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bühnenwerk mit Musikbegleitung / rührseliges Stück) — nach den Nomen 2026-11-01
  'Melone', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Frucht / steifer runder Hut) — nach den Nomen 2026-11-01
  'Membran', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Technik dünnes Blättchen / Biologie Häutchen) — nach den Nomen 2026-11-01
  'Memory', // zurückgestellt: Markenname (Spiel) — Regel 18 2026-11-01
  'Menge', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anzahl, Quantität / Menschenmenge / Mathematik) — nach den Nomen 2026-11-01
  'Menschenleben', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Leben eines Menschen, Todesopfer / Lebenszeit eines Menschen) — nach den Nomen 2026-11-01
  'Menschenrechtskommission', // zurückgestellt: Name einer Organisation (UN-Menschenrechtskommission) — Regel 18 2026-11-01
  'Menschlichkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Menschsein, menschliche Natur / humane Gesinnung) — nach den Nomen 2026-11-01
  'Mephisto', // zurückgestellt: literarische Figur / Eigenname (Teufel) — kein sicheres Nomen, Regel 14/18 2026-11-01
  'Messias', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Religion, Erlöser / übertragen Retter) — nach den Nomen 2026-11-01
  'Messlatte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Latte zum Messen, Sport / übertragen Maßstab) — nach den Nomen 2026-11-01
  'Metaller', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Metallarbeiter, umgangssprachlich / Fan von Heavy-Metal-Musik) — nach den Nomen 2026-11-01
  'Metamorphose', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Biologie Verwandlung von Tieren / allgemein Umgestaltung, Mythologie) — nach den Nomen 2026-11-01
  'Meteorit', // zurückgestellt: Deklination schwankend (des Meteoriten / des Meteorits) — Regel 14 2026-11-01
  'Meter', // zurückgestellt: Artikel doppelt (der/das Meter) — Regel 14 2026-11-01
  'Methodik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lehre von den Methoden / Unterrichtsmethode, Vorgehensweise) — nach den Nomen 2026-11-01
  'Metropolis', // zurückgestellt: seltene Nebenform von Metropole, Plural nicht sicher — Regel 14 2026-11-01
  'Metzler', // zurückgestellt: Familienname — kein sicheres Nomen, Regel 14/18 2026-11-01
  'Meute', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Jagdhunde / abwertend Menschengruppe) — nach den Nomen 2026-11-01
  'Mieterbund', // zurückgestellt: Name einer Organisation (Deutscher Mieterbund) — Regel 18 2026-11-01
  'Migration', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wanderung von Menschen / EDV Datenübertragung / Biologie Tierwanderung) — nach den Nomen 2026-11-01
  'Mika', // zurückgestellt: Vorname / unbekanntes Wort — kein sicheres Nomen, Regel 14/18 2026-11-01
  'Mikrokosmos', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Welt der Kleinstlebewesen / Mensch als kleine Welt, Philosophie) — nach den Nomen 2026-11-01
  'Mikrowelle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mikrowellengerät / Physik elektromagnetische Welle) — nach den Nomen 2026-11-01
  'Milde', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: mildes Wetter, Sanftheit / Nachsicht, Gnade) — nach den Nomen 2026-11-01
  'Milieu', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: soziales Umfeld / Rotlichtmilieu / Biologie Lebensraum) — nach den Nomen 2026-11-01
  'Milliliter', // zurückgestellt: Artikel doppelt (der/das Milliliter) — Regel 14 2026-11-01
  'Millimeter', // zurückgestellt: Artikel doppelt (der/das Millimeter) — Regel 14 2026-11-01
  'Mimi', // zurückgestellt: Vorname / Kosename — kein sicheres Nomen, Regel 14/18 2026-11-01
  'Mimus', // zurückgestellt: Fachwort (antike Posse/Darsteller), Plural und Gebrauch nicht sicher — Regel 14 2026-11-01
  'Mineral', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gestein, Mineralstoff / österr. Mineralwasser) — nach den Nomen 2026-11-01
  'Miniatur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kleines Bild, Buchmalerei / verkleinerte Nachbildung, Modell) — nach den Nomen 2026-11-01
  'Minimum', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mindestmaß / Tiefstwert, Mathematik, Meteorologie) — nach den Nomen 2026-11-01
  'Minus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fehlbetrag, Verlust / Nachteil / Minuszeichen) — nach den Nomen 2026-11-01
  'Mischling', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tier aus verschiedenen Rassen / Mensch, abwertend und NS-Begriff) — nach den Nomen 2026-11-01
  'Miss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: engl. Anrede Fräulein / Schönheitskönigin) — nach den Nomen 2026-11-01
  'Missa', // zurückgestellt: lateinischer Fachausdruck (Missa solemnis), kein gebräuchliches Nomen — Regel 14 2026-11-01
  'Missachtung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nichtbeachtung von Regeln / Geringschätzung einer Person) — nach den Nomen 2026-11-01
  'Missbrauch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: falscher Gebrauch / sexueller Missbrauch) — nach den Nomen 2026-11-01
  'Mission', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Auftrag / diplomatische Vertretung / Verbreitung des Glaubens) — nach den Nomen 2026-11-01
  'Misskredit', // zurückgestellt: nur in fester Wendung («in Misskredit bringen/geraten») — Regel 14 2026-11-01
  'Mitbewerber', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mitbewerber um eine Stelle / Konkurrent auf dem Markt) — nach den Nomen 2026-11-01
  'Mitleidenschaft', // zurückgestellt: nur in fester Wendung («in Mitleidenschaft ziehen») — Regel 14 2026-11-01
  'Mitreisende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv/Partizip: der/die Mitreisende) — nach den Nomen 2026-11-01
  'Mittagstisch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Esstisch zu Mittag / Mittagsmenü im Lokal / Mittagessen für Bedürftige) — nach den Nomen 2026-11-01
  'Mitte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mittelpunkt, Zentrum / politische Mitte / Zeitangabe «Mitte Mai») — nach den Nomen 2026-11-01
  'Mittelalter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Epoche 500–1500 / scherzhaft Menschen mittleren Alters) — nach den Nomen 2026-11-01
  'Mittelbau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: mittlerer Gebäudeteil / akademischer Mittelbau an Hochschulen) — nach den Nomen 2026-11-01
  'Mittelfeld', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spielfeldmitte, Mannschaftsteil / Mittelplatz in einer Rangliste) — nach den Nomen 2026-11-01
  'Mittelhand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anatomie Mittelhandknochen / Kartenspiel mittlerer Spieler) — nach den Nomen 2026-11-01
  'Mittelklasse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: soziale Mittelschicht / mittlere Preis- und Qualitätsklasse, z. B. Auto) — nach den Nomen 2026-11-01
  'Mittelschule', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen je Land: AT Pflichtschule 10–14 / DE z. T. Realschule / CH höhere Schule) — nach den Nomen 2026-11-01
  'Mittelstand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: soziale Mittelschicht / kleine und mittlere Unternehmen) — nach den Nomen 2026-11-01
  'Mittelstufe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: mittlere Schulklassen / mittleres Niveau eines Sprachkurses) — nach den Nomen 2026-11-01
  'Mixed', // zurückgestellt: englisches Fachwort (Tennis/Badminton «gemischtes Doppel»), Gebrauch als eigenes Nomen nicht sicher — Regel 14 2026-11-01
  'Mixtur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Arzneimischung / Mischung allgemein / Orgelregister) — nach den Nomen 2026-11-01
  'Moabiter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einwohner von Berlin-Moabit / Angehöriger des biblischen Volkes Moab) — nach den Nomen 2026-11-01
  'Mobilisierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mobilmachung, Aktivierung von Menschen / Pflege: Mobilisation von Patienten) — nach den Nomen 2026-11-01
  'Mode', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2 (Homograph mit anderem Artikel: die Mode «Kleidung» / der Mode «Betriebsart», EDV) — nach den Nomen 2026-11-01
  'Modehaus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bekleidungsgeschäft / Modeunternehmen, Designerlabel) — nach den Nomen 2026-11-01
  'Modell', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nachbildung / Typ eines Produkts / Fotomodell / wissenschaftliches Modell) — nach den Nomen 2026-11-01
  'Modem', // zurückgestellt: Artikel doppelt (das/der Modem) — Regel 14 2026-11-01
  'Moderation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Leitung einer Sendung oder Diskussion / veraltet Mäßigung) — nach den Nomen 2026-11-01
  'Moderator', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sendungs- und Diskussionsleiter / Kernphysik Bremssubstanz) — nach den Nomen 2026-11-01
  'Moderne', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: moderne Zeit / moderne Richtung in Kunst und Literatur) — nach den Nomen 2026-11-01
  'Modus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Art und Weise, Betriebsart / Grammatik Aussageweise) — nach den Nomen 2026-11-01
  'Mohn', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pflanze / Samen zum Backen) — nach den Nomen 2026-11-01
  'Mohr', // zurückgestellt: veraltet und diskriminierend; Ersatz wäre nur ein substantiviertes Adjektiv (Fall 4) — Lukas entscheidet 2026-11-01
  'Momentaufnahme', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Foto mit kurzer Belichtung / übertragen kurze Darstellung eines Zustands) — nach den Nomen 2026-11-01
  'Monitor', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bildschirm / medizinisches Überwachungsgerät / Strahlungsmessgerät) — nach den Nomen 2026-11-01
  'Monopoly', // zurückgestellt: Markenname eines Brettspiels — Regel 18 2026-11-01
  'Monsieur', // zurückgestellt: französische Anrede, kein eigenständiges deutsches Nomen — Regel 14 2026-11-01
  'Monstrum', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ungeheuer / ugs. riesiges, unförmiges Ding) — nach den Nomen 2026-11-01
  'Montage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zusammenbau, Einbau / Film- und Bildmontage); dazu Gleichform mit Plural von «Montag» — nach den Nomen 2026-11-01
  'Moos', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pflanze / ugs. Geld) — nach den Nomen 2026-11-01
  'Moral', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: sittliche Werte / Lehre einer Geschichte / Kampfgeist, Moral der Truppe) — nach den Nomen 2026-11-01
  'More', // zurückgestellt: Bedeutung/Gebrauch unklar (Mores «Sitten» nur in «jemanden Mores lehren») — Regel 14 2026-11-01
  'Morgenpost', // zurückgestellt: meist Zeitungsname (Berliner/Hamburger Morgenpost) — Regel 18 2026-11-01
  'Morgenstern', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Planet Venus am Morgenhimmel / mittelalterliche Schlagwaffe) — nach den Nomen 2026-11-01
  'Moslem', // zurückgestellt: ältere Nebenform von «Muslim»; Markierung (veraltend/abwertend empfunden) nicht sicher — Regel 14/17 2026-11-01
  'Most', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen je Region: unvergorener Fruchtsaft / AT, süddt. Obstwein) — nach den Nomen 2026-11-01
  'Motion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: CH parlamentarischer Antrag / veraltet Bewegung) — nach den Nomen 2026-11-01
  'Motiv', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beweggrund / Bildmotiv, Gegenstand eines Kunstwerks / Musik) — nach den Nomen 2026-11-01
  'Moto', // zurückgestellt: kein sicheres deutsches Nomen — Regel 14 2026-11-01
  'Motor', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Maschine / übertragen treibende Kraft, «Motor der Wirtschaft») — nach den Nomen 2026-11-01
  'Mount', // zurückgestellt: englisches Wort, nur in Namen (Mount Everest) — Regel 14/18 2026-11-01
  'Mulde', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geländevertiefung / Trog, Backmulde / Container, Absetzmulde) — nach den Nomen 2026-11-01
  'Multi', // zurückgestellt: Jargon-Kurzwort (multinationaler Konzern); Gebrauch und Plural nicht sicher — Regel 14 2026-11-01
  'Muschel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Weichtier, Schale / Hör- und Sprechmuschel des Telefons) — nach den Nomen 2026-11-01
  'Muse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Göttin der Künste / Inspiration; «die leichte Muse») — nach den Nomen 2026-11-01
  'Musica', // zurückgestellt: lateinisch, nur in festen Fügungen (Musica sacra/viva) — Regel 14 2026-11-01
  'Muslime', // zurückgestellt: Pluralform von «Muslim» bzw. seltene feminine Form (die Muslime) — Lemma unklar — Regel 14 2026-11-01
  'Muster', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verzierung, Dessin / Probe, Warenmuster / Vorlage, Vorbild) — nach den Nomen 2026-11-01
  'Mutation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Biologie Veränderung im Erbgut / Medizin Stimmbruch) — nach den Nomen 2026-11-01
  'Mutterland', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Herkunftsland / Kolonialmacht gegenüber Kolonien / Ursprungsland, «Mutterland des Fußballs») — nach den Nomen 2026-11-01
  'Mysterium', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geheimnis, Rätsel / Religion Geheimkult, Mysterienspiel) — nach den Nomen 2026-11-01
  'Mythos', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Göttersage / verklärte Person, Sache / falsche Vorstellung, «Es ist ein Mythos, dass …») — nach den Nomen 2026-11-01
  'Nachfrage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wirtschaft Bedarf, Nachfrage nach Waren / Erkundigung, Rückfrage) — nach den Nomen 2026-11-01
  'Nachlass', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erbe, hinterlassenes Vermögen / Preisnachlass, Rabatt / Nachlassen, Abnahme) — nach den Nomen 2026-11-01
  'Nachrede', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: «üble Nachrede», Verleumdung / Nachwort, Epilog) — nach den Nomen 2026-11-01
  'Nachrichtendienst', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geheimdienst / veraltend Nachrichtenagentur, Nachrichtenübermittlung) — nach den Nomen 2026-11-01
  'Nachsatz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nachschrift, Postskriptum / Grammatik nachgestellter Satz) — nach den Nomen 2026-11-01
  'Nachschlag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: zusätzliche Essensportion / Musik Verzierung) — nach den Nomen 2026-11-01
  'Nachsehen', // zurückgestellt: nur in fester Wendung «das Nachsehen haben» — Regel 14 2026-11-01
  'Nachspiel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Folgen, «ein gerichtliches Nachspiel» / Theater, Musik Epilog) — nach den Nomen 2026-11-01
  'Nachwuchs', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kinder einer Familie / junge Kräfte in Beruf, Sport) — nach den Nomen 2026-11-01
  'Nadel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nähnadel / Nadel von Nadelbäumen / Kanüle, Anstecknadel) — nach den Nomen 2026-11-01
  'Nagel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Metallstift / Finger-, Fußnagel) — nach den Nomen 2026-11-01
  'Naht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: genähte Verbindung / Medizin Wundnaht / Schweißnaht) — nach den Nomen 2026-11-01
  'Narbe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wundnarbe / Botanik Teil des Stempels) — nach den Nomen 2026-11-01
  'Narben', // zurückgestellt: Pluralform von «Narbe», keine eigene Grundform — Regel 14 2026-11-01
  'Nass', // zurückgestellt: «das Nass» nur gehoben/scherzhaft («das kühle Nass»); Gebrauch als Lernwort unsicher — Regel 14 2026-11-01
  'Nationalcoach', // zurückgestellt: Duden-Eintrag und Gebrauch (bes. CH, Sportjargon) nicht sicher — Regel 14 2026-11-01
  'Nationale', // zurückgestellt: österr. «das Nationale» (Personalien) — Genus und Gebrauch nicht sicher — Regel 14 2026-11-01
  'Nationalgalerie', // zurückgestellt: meist Name einer bestimmten Institution (Berlin, London) — Regel 18 2026-11-01
  'Nationalliga', // zurückgestellt: meist Name einer bestimmten Liga (CH, AT) — Regel 18 2026-11-01
  'Nationalrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Parlamentskammer AT/CH / Mitglied dieser Kammer) — nach den Nomen 2026-11-01
  'Nationalratsabgeordnete', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Nationalratsabgeordnete) — nach den Nomen 2026-11-01
  'Nationaltheater', // zurückgestellt: meist Name einer bestimmten Bühne (Mannheim, München, Prag) — Regel 18 2026-11-01
  'Natur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Natur, Umwelt / Wesen, Charakter, «von Natur aus» / Körperbeschaffenheit); Hinweis: 27 ältere Karten verweisen im wortnetz auf nomen_natur — nach den Nomen 2026-11-01
  'Naturschutzbund', // zurückgestellt: Name eines bestimmten Verbands (NABU) — Regel 18 2026-11-01
  'Navigation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kursbestimmung bei Schiff/Flugzeug / Bewegung durch Website, Menü) — nach den Nomen 2026-11-01
  'Navigator', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Navigationsoffizier / Navigationsgerät, Software) — nach den Nomen 2026-11-01
  'Nazi', // zurückgestellt: Kurzwort für Nationalsozialist; Duden-Markierung (abwertend?) nicht sicher — Regel 14/17 2026-11-01
  'Neandertaler', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Urmensch / ugs. abwertend grober Mensch) — nach den Nomen 2026-11-01
  'Nebel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wetter / Astronomie Sternnebel) — nach den Nomen 2026-11-01
  'Negativ', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fotonegativ / Gegenbild, Kehrseite; Homograph zu Adjektiv negativ) — nach den Nomen 2026-11-01
  'Negative', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: das Negative) — nach den Nomen 2026-11-01
  'Neger', // zurückgestellt: diskriminierend; Ersatz wäre ein Fall-4-Wort (der/die Schwarze) — wie Mohr, Entscheidung Lukas 2026-11-01
  'Nehmer', // zurückgestellt: als freies Nomen selten (meist in Komposita: Arbeitnehmer); Bedeutung unsicher — Regel 14 2026-11-01
  'Neige', // zurückgestellt: fast nur in festen Wendungen («zur Neige gehen», «bis zur Neige») — Regel 14 2026-11-01
  'Neigung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schräge, Gefälle / Vorliebe, Hang / Tendenz) — nach den Nomen 2026-11-01
  'Nelke', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Blume / Gewürznelke) — nach den Nomen 2026-11-01
  'Nerv', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nervenfaser / Plural Nerven: Belastbarkeit «die Nerven verlieren» / Blattnerv) — nach den Nomen 2026-11-01
  'Nest', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vogelnest / ugs. kleiner Ort «ein Nest» / Versteck) — nach den Nomen 2026-11-01
  'Net', // zurückgestellt: englisch, als deutsches Nomen nicht gesichert (Tennis: Netz) — Regel 14 2026-11-01
  'Netz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: geknüpftes Netz / Strom-, Verkehrsnetz / Internet, Mobilfunknetz) — nach den Nomen 2026-11-01
  'Netzwerk', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Computernetzwerk / Beziehungsnetz, soziales Netzwerk) — nach den Nomen 2026-11-01
  'Neuauflage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: neue Auflage eines Buches / übertragen Wiederholung «Neuauflage des Duells») — nach den Nomen 2026-11-01
  'Neubau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bau eines neuen Gebäudes / das neue Gebäude selbst) — nach den Nomen 2026-11-01
  'Neubauer', // zurückgestellt: vor allem Familienname; als Gattungswort (Neusiedler) unsicher — Regel 14 2026-11-01
  'Neuheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Neusein / neues Produkt, etwas Neues) — nach den Nomen 2026-11-01
  'Neuland', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: neu urbar gemachtes Land / übertragen unbekanntes Gebiet «Neuland betreten») — nach den Nomen 2026-11-01
  'Neuner', // zurückgestellt: umgangssprachlich/regional (Ziffer 9, Buslinie, österr. Schulnote); Gebrauch als Lernwort unsicher — Regel 14 2026-11-01
  'Neustadt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1/3 (mehrere Bedeutungen: neuer Stadtteil / zahlreiche Ortsnamen, z. B. Wiener Neustadt) — nach den Nomen 2026-11-01
  'Neustart', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Computer neu starten / Neuanfang) — nach den Nomen 2026-11-01
  'Newsletter', // zurückgestellt: Artikel doppelt (der/das Newsletter) — Regel 14 2026-11-01
  'Newtonmeter', // zurückgestellt: Artikel doppelt (das/der Newtonmeter, wie Meter) — Regel 14 2026-11-01
  'Nichts', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Leere, das Nichtsein / abwertend unbedeutender Mensch «ein Nichts») — nach den Nomen 2026-11-01
  'Niederlassung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Filiale / Ansiedlung, Niederlassungsbewilligung / Praxiseröffnung) — nach den Nomen 2026-11-01
  'Niederschlag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Regen, Schnee / Boxen K.-o.-Schlag / Chemie Bodensatz / «seinen Niederschlag finden») — nach den Nomen 2026-11-01
  'Niederschlagung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: gewaltsame Unterdrückung eines Aufstands / Einstellung eines Verfahrens, Erlass einer Forderung) — nach den Nomen 2026-11-01
  'Nimbus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Heiligenschein / Ansehen, Ruhm / Meteorologie Regenwolke) — nach den Nomen 2026-11-01
  'Nippon', // zurückgestellt: japanischer Landesname, im Deutschen kaum gebräuchlich (Japan) — Regel 14 2026-11-01
  'Nische', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mauernische / Marktnische, ökologische Nische) — nach den Nomen 2026-11-01
  'Niveau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Höhe, Höhenlage / Leistungs-, Sprachniveau / geistiger Anspruch «Niveau haben») — nach den Nomen 2026-11-01
  'Nix', // zurückgestellt: umgangssprachlich für «nichts» (Pronomen) bzw. «der Nix» Wassergeist — Wortart/Bedeutung unsicher — Regel 14 2026-11-01
  'Nomenklatura', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verzeichnis der Führungspositionen in der Sowjetunion / herrschende Führungsschicht) — nach den Nomen 2026-11-01
  'Nomination', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kath. Kirche Benennung für ein Amt / bes. schweiz. Nominierung) — nach den Nomen 2026-11-01
  'Nonne', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ordensfrau / Nachtfalter / Dachziegel) — nach den Nomen 2026-11-01
  'Norden', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1/3 (mehrere Bedeutungen: Himmelsrichtung / nördliche Gegend «der hohe Norden»; Homograph Norden, Stadt in Ostfriesland) — nach den Nomen 2026-11-01
  'Nordlicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Polarlicht / ugs. scherzhaft Norddeutscher) — nach den Nomen 2026-11-01
  'Norm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Regel, Maßstab / technische Norm DIN / Arbeits-, Leistungsnorm) — nach den Nomen 2026-11-01
  'Normal', // zurückgestellt: meist kurz für «Normalbenzin» (das Normal); Gebrauch und Lemma unsicher — Regel 14 2026-11-01
  'Normale', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1/4 (mehrere Bedeutungen: Mathematik die Normale (Senkrechte) / substantiviertes Adjektiv das Normale) — nach den Nomen 2026-11-01
  'Not', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Armut, Elend / Notlage, Gefahr / «mit knapper Not» / Notwendigkeit «ohne Not») — nach den Nomen 2026-11-01
  'Note', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schulnote / Musiknote / diplomatische Note / Banknote / persönliche Note) — nach den Nomen 2026-11-01
  'Nothilfe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hilfe in einer Notlage / schweiz. Nothilfe für abgewiesene Asylsuchende) — nach den Nomen 2026-11-01
  'Notierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Börsenkurs / Notenschrift in der Musik / das Notieren) — nach den Nomen 2026-11-01
  'Notiz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufzeichnung / kurze Zeitungsmeldung / «Notiz nehmen von») — nach den Nomen 2026-11-01
  'Notstand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Notlage / Rechtswesen: Notstand nach StGB / staatsrechtlich: Ausnahmezustand) — nach den Nomen 2026-11-02
  'Novelle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: literarische Erzählform / Gesetzesänderung) — nach den Nomen 2026-11-02
  'Nudel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Teigware / ugs. Person «eine ulkige Nudel») — nach den Nomen 2026-11-02
  'Nullnummer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Probeausgabe einer Zeitung / ugs. Reinfall, Fehlschlag / Sport 0:0) — nach den Nomen 2026-11-02
  'Nullpunkt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nullpunkt einer Skala, Gefrierpunkt / Tiefpunkt «auf dem Nullpunkt») — nach den Nomen 2026-11-02
  'Numerus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Grammatik Singular/Plural / Mathematik Zahl beim Logarithmus / Numerus clausus) — nach den Nomen 2026-11-02
  'Nummer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zahl, Telefonnummer / Ausgabe einer Zeitschrift / Auftritt im Programm / Größe «eine Nummer zu groß») — nach den Nomen 2026-11-02
  'Nuss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Frucht / ugs. Person «doofe Nuss» / «harte Nuss» schwierige Aufgabe) — nach den Nomen 2026-11-02
  'Nussbaum', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Baum / Holz «Möbel aus Nussbaum») — nach den Nomen 2026-11-02
  'Oase', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wasserstelle in der Wüste / übertragen Ort der Ruhe) — nach den Nomen 2026-11-02
  'Ob', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2 (Homograph mit anderem Artikel: der Ob, Fluss in Sibirien / das Ob «das Ob und Wie») — nach den Nomen 2026-11-02
  'Oberdorf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1/3 (mehrere Bedeutungen: oberer Teil eines Dorfes / häufiger Ortsname, z. B. Oberdorf in der Schweiz) — nach den Nomen 2026-11-02
  'Oberhand', // zurückgestellt: fast nur in festen Wendungen («die Oberhand gewinnen/behalten/haben») — Regel 14 2026-11-02
  'Oberklasse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Oberschicht der Gesellschaft / obere Schulklassen / Fahrzeugklasse, Luxusklasse) — nach den Nomen 2026-11-02
  'Oberkommandierender', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Partizip/Adjektiv: der/die Oberkommandierende) — nach den Nomen 2026-11-02
  'Oberland', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1/3 (mehrere Bedeutungen: höher gelegener Landesteil / Eigenname, z. B. Berner Oberland) — nach den Nomen 2026-11-02
  'Oberleitung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fahrleitung von Bahn/Straßenbahn / oberste Leitung, Führung) — nach den Nomen 2026-11-02
  'Oberschule', // zurückgestellt: Bedeutung je nach Land/Zeit verschieden (Sachsen: Mittel-/Realschule; früher: Gymnasium; DDR: POS/EOS) — Regel 14 2026-11-02
  'Oberst', // zurückgestellt: Plural und Deklination schwankend (die Obersten / die Oberste; des Obersts / des Obersten) — Regel 14 2026-11-02
  'Oberteil', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kleidungsstück für den Oberkörper / oberer Teil eines Gegenstands) — nach den Nomen 2026-11-02
  'Obi', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1/3 (mehrere Bedeutungen: Gürtel des Kimonos / Markenname einer Baumarktkette) — nach den Nomen 2026-11-02
  'Objekt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gegenstand / Grammatik: Satzergänzung / Immobilie / Kunstobjekt) — nach den Nomen 2026-11-02
  'Obligation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wertpapier, Schuldverschreibung / veraltet: Verpflichtung) — nach den Nomen 2026-11-02
  'Obolus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kleiner Geldbeitrag / altgriechische Münze) — nach den Nomen 2026-11-02
  'Ochs', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kastriertes Rind / ugs. Schimpfwort «dummer Ochs»; Nebenform von Ochse) — nach den Nomen 2026-11-02
  'Ochse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kastriertes Rind / ugs. Schimpfwort «dummer Ochse») — nach den Nomen 2026-11-02
  'Odeon', // zurückgestellt: meist Eigenname von Kinos/Konzerthäusern; als Gattungswort unsicher — Regel 14 2026-11-02
  'Odyssee', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1/3 (mehrere Bedeutungen: Epos Homers / übertragen lange Irrfahrt) — nach den Nomen 2026-11-02
  'Ofen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Heizofen / Backofen / technischer Ofen, Hochofen / ugs. «der Ofen ist aus») — nach den Nomen 2026-11-02
  'Ofenloch', // zurückgestellt: selten, Bedeutung/Gebrauch (Ofenöffnung, regional) unsicher — Regel 14 2026-11-02
  'Offenbarung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: religiöse Offenbarung, Johannesoffenbarung / Enthüllung / großartiges Erlebnis «eine Offenbarung sein») — nach den Nomen 2026-11-02
  'Offenbarungseid', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rechtswesen: eidesstattliche Versicherung über Vermögen / übertragen Eingeständnis des Scheiterns) — nach den Nomen 2026-11-02
  'Offensive', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: militärischer Angriff / Sport: Angriffsspiel / übertragen Kampagne «Bildungsoffensive») — nach den Nomen 2026-11-02
  'Oh', // zurückgestellt: substantivierte Interjektion «das Oh»; als Lernwort/Nomen unsicher — Regel 14 2026-11-02
  'Ohnmacht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bewusstlosigkeit / Machtlosigkeit, Hilflosigkeit) — nach den Nomen 2026-11-02
  'Ohrwurm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: eingängige Melodie / Insekt, Gemeiner Ohrwurm) — nach den Nomen 2026-11-02
  'Okkupation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: militärische Besetzung / Rechtswesen: Aneignung herrenloser Sachen) — nach den Nomen 2026-11-02
  'Oldtimer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: altes Auto, Flugzeug / ugs. scherzhaft älterer Mensch, langjähriges Mitglied) — nach den Nomen 2026-11-02
  'Olive', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Frucht / Olivenbaum) — nach den Nomen 2026-11-02
  'Olymp', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1/3 (mehrere Bedeutungen: Berg in Griechenland, Sitz der Götter / übertragen Spitze «der Olymp des Sports» / scherzhaft oberste Theatergalerie) — nach den Nomen 2026-11-02
  'Olympiade', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. Olympische Spiele / Zeitraum von vier Jahren / Wettbewerb, z. B. Mathematik-Olympiade) — nach den Nomen 2026-11-02
  'Olympiahalle', // zurückgestellt: Name eines bestimmten Gebäudes (München), kein geografischer Name nach Regel 18 — Regel 14 2026-11-02
  'Olympiapark', // zurückgestellt: Name einer bestimmten Anlage (München u. a.), kein geografischer Name nach Regel 18 — Regel 14 2026-11-02
  'Oma', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Großmutter / ugs., oft abwertend: alte Frau) — nach den Nomen 2026-11-02
  'Oman', // zurückgestellt: Artikel schwankend (Oman / der Oman: «in Oman» / «im Oman») — Regel 14 2026-11-02
  'Omega', // zurückgestellt: Buchstabe des griechischen Alphabets; Lernwortkarte/Gebrauch unsicher (auch Zeichen für Ohm) — Regel 14 2026-11-02
  'Opa', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Großvater / ugs., oft abwertend: alter Mann) — nach den Nomen 2026-11-02
  'Oper', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musikwerk / Opernhaus / Institution, Ensemble) — nach den Nomen 2026-11-02
  'Operation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: chirurgischer Eingriff / militärische Operation / Mathematik, Rechenoperation) — nach den Nomen 2026-11-02
  'Opfer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschädigter, Verletzter / religiöses Opfer / Verzicht «Opfer bringen») — nach den Nomen 2026-11-02
  'Opposition', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Parteien außerhalb der Regierung / Widerstand, Gegensatz / Astronomie: Gegenstellung) — nach den Nomen 2026-11-02
  'Optik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lehre vom Licht / Linsensystem eines Geräts / Aussehen, äußerer Eindruck «aus optischen Gründen») — nach den Nomen 2026-11-02
  'Option', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wahlmöglichkeit / Börse: Optionsrecht / Recht auf Vorkauf) — nach den Nomen 2026-11-02
  'Opus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: künstlerisches Werk / nummeriertes Musikwerk «op. 27») — nach den Nomen 2026-11-02
  'Orakel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ort der Weissagung, z. B. Delphi / rätselhafte Weissagung) — nach den Nomen 2026-11-02
  'Oratorium', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: musikalisches Werk / Gebetsraum) — nach den Nomen 2026-11-02
  'Orden', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Auszeichnung, Medaille / religiöse Gemeinschaft, Ordensgemeinschaft) — nach den Nomen 2026-11-02
  'Order', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Befehl, Anweisung / Kaufmannssprache: Auftrag, Bestellung) — nach den Nomen 2026-11-02
  'Ordinariat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: bischöfliche Verwaltungsbehörde / ordentliche Professur) — nach den Nomen 2026-11-02
  'Ordinarius', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ordentlicher Professor / katholische Kirche: Bischof als Inhaber der Amtsgewalt) — nach den Nomen 2026-11-02
  'Ordination', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Priesterweihe / österr. Arztpraxis, Sprechstunde / Verordnung) — nach den Nomen 2026-11-02
  'Ordner', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aktenordner / Person, die bei Veranstaltungen für Ordnung sorgt / Computer: Verzeichnis) — nach den Nomen 2026-11-02
  'Ordnung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ordentlichkeit / Regelsystem, Vorschrift / Biologie: Rangstufe / «in Ordnung») — nach den Nomen 2026-11-02
  'Organ', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Körperorgan / Einrichtung, Behörde / Zeitung als Sprachrohr / ugs. Stimme) — nach den Nomen 2026-11-02
  'Organisation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Organisieren / Vereinigung, Verband) — nach den Nomen 2026-11-02
  'Orchestra', // zurückgestellt: Fachwort (Tanzplatz im antiken Theater) bzw. Schreibvariante; Gebrauch als Lernwort unsicher — Regel 14 2026-11-02
  'Organismus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lebewesen / gegliedertes Ganzes, System «der Organismus des Staates») — nach den Nomen 2026-11-02
  'Orgie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ausschweifendes Fest / übertragen Exzess «eine Orgie der Gewalt») — nach den Nomen 2026-11-02
  'Orient', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorderer und Mittlerer Osten / veraltet: Osten als Himmelsrichtung) — nach den Nomen 2026-11-02
  'Orientierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Orientierungssinn, Zurechtfinden / Ausrichtung, Einstellung «politische Orientierung» / Information, Überblick) — nach den Nomen 2026-11-02
  'Original', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Urfassung, echtes Werk / ugs. eigenwilliger Mensch «ein Original») — nach den Nomen 2026-11-02
  'Orthodoxie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: orthodoxe Kirche, Glaube / strenge Rechtgläubigkeit, Festhalten an Lehrmeinungen) — nach den Nomen 2026-11-02
  'Orlean', // zurückgestellt: seltener Farbstoff (Annatto); Gebrauch, Genus und Lernwert unsicher — Regel 14 2026-11-02
  'Ortsgemeinde', // zurückgestellt: Bedeutung je nach Land/Bundesland verschieden (Rheinland-Pfalz: Teil einer Verbandsgemeinde; Schweiz: politische Gemeinde) — wie Gemeindevorstand, Regel 14 2026-11-02
  'Oscar', // zurückgestellt: Name eines Filmpreises (kein geografischer Eigenname) — Regel 18 2026-11-02
  'Osten', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Himmelsrichtung / östliches Gebiet / Osteuropa, Ostblock / ugs. ehemalige DDR) — wie Norden — nach den Nomen 2026-11-02
  'Ostler', // zurückgestellt: umgangssprachlich für Ostdeutsche; Markierung (abwertend oder nicht) unsicher — Regel 14/17 2026-11-02
  'Oststaat', // zurückgestellt: Bedeutung unsicher (Staat im Osten / ehemaliger Ostblockstaat / Ostküstenstaat der USA) — Regel 14 2026-11-02
  'Outdoor', // zurückgestellt: als selbständiges Nomen unsicher (meist nur Bestimmungswort: Outdoorjacke, Outdoorsport) — Regel 14 2026-11-02
  'Output', // zurückgestellt: Artikel schwankend (der/das Output) — wie Input, Regel 14 2026-11-02
  'Ozon', // zurückgestellt: Artikel schwankend (das Ozon fachsprachlich / der Ozon umgangssprachlich) — Regel 14 2026-11-02
  'Paar', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1/3 (mehrere Bedeutungen: zwei zusammengehörige Personen/Dinge «ein Paar Schuhe» / Liebespaar; dazu «ein paar» = einige) — nach den Nomen 2026-11-02
  'Paarkreuz', // zurückgestellt: Fachwort aus dem Tischtennis (Mannschaftsaufstellung); Lernwert/Gebrauch unsicher — Regel 14 2026-11-02
  'Paarung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Begattung bei Tieren / Zusammenstellung, Spielpaarung im Sport) — nach den Nomen 2026-11-02
  'Packung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verpackung, Schachtel «eine Packung Milch» / Umschlag, Wickel in der Medizin / ugs. hohe Niederlage) — nach den Nomen 2026-11-02
  'Page', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2 (der Page «junger Diener, Hoteldiener» / ugs. die Page «Webseite») — nach den Nomen 2026-11-02
  'Paisley', // zurückgestellt: Musterbezeichnung (auch Stadtname); Genus und Lernwert unsicher — Regel 14 2026-11-02
  'Pak', // zurückgestellt: militärische Abkürzung (Panzerabwehrkanone); Lernwert/Gebrauch unsicher — Regel 14 2026-11-02
  'Paket', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Postsendung / Packung, Bündel «ein Paket Papier» / Gesamtheit von Maßnahmen «Sparpaket» / Aktienpaket) — nach den Nomen 2026-11-02
  'Pale', // zurückgestellt: kein gebräuchliches deutsches Nomen (Bedeutung unklar) — Regel 14 2026-11-02
  'Palette', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Farbpalette des Malers / Auswahl, Vielfalt «eine breite Palette» / Transportpalette) — nach den Nomen 2026-11-02
  'Palmengarten', // zurückgestellt: meist Name einer Anlage (Palmengarten Frankfurt), kein geografischer Eigenname — wie Hofgarten, Regel 18 2026-11-02
  'Panel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Diskussionsrunde, Podium / feste Befragtengruppe in der Marktforschung / Bedienfeld, Verkleidungsplatte) — nach den Nomen 2026-11-02
  'Panzer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kampfpanzer, gepanzertes Fahrzeug / Schutzhülle, z. B. der Schildkröte / Rüstung) — nach den Nomen 2026-11-02
  'Papagei', // zurückgestellt: Deklination schwankend (des Papageis / des Papageien; Plural Papageien, seltener Papageie) — wie Meteorit/Oberst, Regel 14 2026-11-02
  'Paper', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: schriftliche Unterlage, Thesenpapier / wissenschaftlicher Aufsatz) — nach den Nomen 2026-11-02
  'Papier', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Material / Schriftstück, Dokument «die Papiere» / Wertpapier) — nach den Nomen 2026-11-02
  'Parabel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: lehrhafte Erzählung, Gleichnis / Kurve in der Mathematik) — nach den Nomen 2026-11-02
  'Paradigma', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Denkmuster, Modell in der Wissenschaft / Sprachwissenschaft: Flexionsmuster) — nach den Nomen 2026-11-02
  'Paragleiter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gleitschirm als Gerät / Person, die damit fliegt) — nach den Nomen 2026-11-02
  'Parallele', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: parallele Linie in der Mathematik / vergleichbarer Fall, Entsprechung) — nach den Nomen 2026-11-02
  'Parasit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schmarotzer in der Biologie / abwertend für einen Menschen, der auf Kosten anderer lebt) — nach den Nomen 2026-11-02
  'Pardon', // zurückgestellt: Artikel schwankend (der/das Pardon); meist nur als Ausruf «Pardon!» — Regel 14 2026-11-02
  'Parker', // zurückgestellt: kein gebräuchliches Nomen (Familienname/Marke; «der Parker» = Parkender unsicher) — Regel 14 2026-11-02
  'Parkett', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Holzfußboden / vordere Sitzreihen im Theater / Börsenparkett, öffentliche Bühne) — nach den Nomen 2026-11-02
  'Parlamentsabgeordnete', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Parlamentsabgeordnete, ein Parlamentsabgeordneter) — nach den Nomen 2026-11-02
  'Parlamentssitz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mandat, Sitz im Parlament / Ort, an dem das Parlament tagt) — nach den Nomen 2026-11-02
  'Part', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anteil «seinen Part beitragen» / Rolle, Stimme in Musik oder Theater) — nach den Nomen 2026-11-02
  'Partei', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: politische Partei / Prozess- oder Vertragspartei / Mietpartei «Partei ergreifen») — nach den Nomen 2026-11-02
  'Parteigenosse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mitglied einer (Arbeiter-)Partei / historisch: Mitglied der NSDAP) — nach den Nomen 2026-11-02
  'Parteilinke', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4/1 (die Parteilinke «linker Flügel einer Partei» / der/die Parteilinke «Person», wie ein Adjektiv gebeugt) — nach den Nomen 2026-11-02
  'Parteivorsitzende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Parteivorsitzende) — nach den Nomen 2026-11-02
  'Parteivorsitzender', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (stark gebeugte Form von «der Parteivorsitzende») — nach den Nomen 2026-11-02
  'Parteivorstand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Leitungsgremium einer Partei / Mitglied dieses Gremiums) — nach den Nomen 2026-11-02
  'Parterre', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erdgeschoss / Sitzplätze im Theater) — nach den Nomen 2026-11-02
  'Partie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spiel «eine Partie Schach» / Teil, Abschnitt / Heiratspartner «eine gute Partie» / Warenposten) — nach den Nomen 2026-11-02
  'Partisane', // zurückgestellt: Listeneintrag unklar: «die Partisane» = alte Stoßwaffe; gemeint vielleicht «der Partisan» (Kämpfer) — Regel 14 2026-11-02
  'Partner', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lebenspartner / Geschäftspartner, Teilhaber / Mitspieler, Gegenüber) — wie Freund — nach den Nomen 2026-11-02
  'Partnerin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (wie Partner: Lebenspartnerin / Geschäftspartnerin / Mitspielerin) — nach den Nomen 2026-11-02
  'Partnerschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zusammenleben, Lebensgemeinschaft / eingetragene Partnerschaft / Zusammenarbeit, Städtepartnerschaft) — nach den Nomen 2026-11-02
  'Pas', // zurückgestellt: Fachwort aus dem Ballett (Tanzschritt); Lernwert/Gebrauch unsicher — Regel 14 2026-11-02
  'Passage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einkaufspassage / Abschnitt eines Textes oder Musikstücks / Überfahrt, Durchgang) — nach den Nomen 2026-11-02
  'Passer', // zurückgestellt: Fachwort aus der Drucktechnik bzw. Sport-Jargon; Bedeutung/Lernwert unsicher — Regel 14 2026-11-02
  'Passion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Leidenschaft / Leidensgeschichte Jesu, Passionsmusik) — nach den Nomen 2026-11-02
  'Pasta', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Paste, streichbare Masse (Plural Pasten) / italienische Teigwaren) — nach den Nomen 2026-11-02
  'Patchwork', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Flickenarbeit aus Stoff / übertragen: Zusammengesetztes «Patchworkfamilie») — nach den Nomen 2026-11-02
  'Patent', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schutzrecht für eine Erfindung / Urkunde, Befähigungsnachweis «Kapitänspatent») — nach den Nomen 2026-11-02
  'Pathologie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lehre von den Krankheiten / Krankenhausabteilung, Institut / krankhafte Veränderung) — nach den Nomen 2026-11-02
  'Patriarch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kirchenoberhaupt, Titel / Stammvater, autoritäres Familienoberhaupt) — nach den Nomen 2026-11-02
  'Patriarchat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gesellschaftsordnung mit Vorrang des Mannes / Amt, Bezirk eines Patriarchen) — nach den Nomen 2026-11-02
  'Patrone', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Munition / Druckerpatrone, Tintenpatrone) — nach den Nomen 2026-11-02
  'Patzer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kleiner Fehler / abwertend: jemand, der patzt, schwacher Schachspieler) — nach den Nomen 2026-11-02
  'Paukenschlag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schlag auf die Pauke / übertragen: aufsehenerregendes Ereignis) — nach den Nomen 2026-11-02
  'Pavillon', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Festzelt / Gartenhäuschen / Ausstellungsbau, Nebengebäude) — nach den Nomen 2026-11-02
  'Pech', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: zähe schwarze Masse, Teer / Unglück, Missgeschick) — nach den Nomen 2026-11-02
  'Pegel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wasserstandsmesser / Wasserstand / Niveau, z. B. Lärm- oder Alkoholpegel) — nach den Nomen 2026-11-02
  'Pechstein', // zurückgestellt: Fachwort der Geologie (vulkanisches Glas); persische Fachbezeichnung unsicher — Regel 14 2026-11-02
  'Pegasus', // zurückgestellt: Name aus der Mythologie bzw. Sternbild — kein geografischer Name (Regel 18); Karte unsicher — Regel 14 2026-11-02
  'Pelz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fell eines Tieres / Kleidungsstück aus Fell, Pelzmantel) — nach den Nomen 2026-11-02
  'Pendant', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gegenstück, Entsprechung / veraltend: Ohrgehänge) — nach den Nomen 2026-11-02
  'Penner', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen, salopp abwertend: Obdachloser / verschlafener, langsamer Mensch) — nach den Nomen 2026-11-02
  'Pension', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ruhestand, Ruhegehalt / kleines Gästehaus, Unterkunft mit Verpflegung) — nach den Nomen 2026-11-02
  'Performance', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: künstlerische Aktion, Darbietung / Leistung, z. B. eines Fonds, Computers) — nach den Nomen 2026-11-02
  'Periode', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zeitabschnitt / Menstruation / Mathematik: periodische Ziffernfolge) — nach den Nomen 2026-11-02
  'Peripherie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Randgebiet, Stadtrand / EDV: Peripheriegeräte / Mathematik: Umfangslinie) — nach den Nomen 2026-11-02
  'Perser', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einwohner Persiens / Perserteppich) — nach den Nomen 2026-11-02
  'Person', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mensch, Einzelwesen / Figur in Drama, Roman / Grammatik: erste, zweite, dritte Person) — nach den Nomen 2026-11-02
  'Personalie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Plural «Personalien» = Angaben zur Person / Entscheidung über eine Besetzung) — nach den Nomen 2026-11-02
  'Personalrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Personalvertretung im öffentlichen Dienst / Mitglied dieser Vertretung) — nach den Nomen 2026-11-02
  'Personalunion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verbindung mehrerer Ämter in einer Person / Geschichte: Staatenverbindung unter einem Monarchen) — nach den Nomen 2026-11-02
  'Personenwagen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Personenkraftwagen, Pkw / Eisenbahnwagen für Reisende) — nach den Nomen 2026-11-02
  'Personenzug', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zug für Reisende / früher: langsamer Nahverkehrszug, der überall hält) — nach den Nomen 2026-11-02
  'Perspektive', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: räumliche Darstellung / Blickwinkel, Sichtweise / Aussicht für die Zukunft) — nach den Nomen 2026-11-02
  'Perversion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: sexuelle Abweichung / übertragen: Verkehrung ins Gegenteil, z. B. «Perversion des Rechts») — nach den Nomen 2026-11-02
  'Petit', // zurückgestellt: Fachwort der Typografie (Schriftgrad); Lernwert/Gebrauch unsicher — Regel 14 2026-11-02
  'Petroleum', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Leuchtöl, Kerosin / veraltet: Erdöl) — nach den Nomen 2026-11-02
  'Pfad', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: schmaler Weg / EDV: Dateipfad) — nach den Nomen 2026-11-02
  'Pfand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sicherheit, verpfändeter Gegenstand / Flaschenpfand, Leergutgebühr) — nach den Nomen 2026-11-02
  'Pfanne', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bratpfanne / Dachziegel «Dachpfanne» / Anatomie: Gelenkpfanne) — nach den Nomen 2026-11-02
  'Pfarramt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Amt des Pfarrers / Büro, Dienststelle der Pfarrei) — nach den Nomen 2026-11-02
  'Pfarrgemeinderat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gremium der Pfarrgemeinde / Mitglied dieses Gremiums) — nach den Nomen 2026-11-02
  'Pfefferspray', // zurückgestellt: Artikel schwankend (das/der Pfefferspray) — Regel 14 2026-11-02
  'Pfeife', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Trillerpfeife / Tabakspfeife / Orgelpfeife / salopp: Versager) — nach den Nomen 2026-11-02
  'Pfeil', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschoss für Bogen / Richtungszeichen) — nach den Nomen 2026-11-02
  'Pferd', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tier / Turngerät / Schachfigur «Springer») — nach den Nomen 2026-11-02
  'Pfiff', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ton beim Pfeifen / umgangssprachlich: besonderer Reiz, Schwung «mit Pfiff») — nach den Nomen 2026-11-02
  'Pflanze', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gewächs / umgangssprachlich: Person, z. B. «eine seltsame Pflanze») — nach den Nomen 2026-11-02
  'Pflanzung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Pflanzen / Plantage, bepflanzte Fläche) — nach den Nomen 2026-11-02
  'Pflaster', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wundpflaster / Straßenbelag aus Steinen) — nach den Nomen 2026-11-02
  'Pflege', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Betreuung von Kranken und Alten / Instandhaltung, Pflege von Dingen / Aufnahme eines Kindes «in Pflege») — nach den Nomen 2026-11-02
  'Pflegedienst', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bereich der Krankenpflege / Unternehmen, z. B. ambulanter Pflegedienst) — nach den Nomen 2026-11-02
  'Pflegegeld', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geldleistung für Pflegebedürftige / Geld für Pflegeeltern) — nach den Nomen 2026-11-02
  'Pfleger', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Krankenpfleger / Tierpfleger / Recht: Vormund, Pfleger) — nach den Nomen 2026-11-02
  'Pflegerin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Krankenpflegerin / Tierpflegerin / Recht: Pflegerin, Vormund) — nach den Nomen 2026-11-02
  'Pflicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufgabe, Verpflichtung / Sport: Pflichtübung, Pflichtteil) — nach den Nomen 2026-11-02
  'Pforte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tor, Eingang / Pförtnerloge, Empfang z. B. im Krankenhaus) — nach den Nomen 2026-11-02
  'Pfote', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fuß eines Tieres / salopp: Hand) — nach den Nomen 2026-11-02
  'Pfund', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gewichtseinheit, 500 Gramm / britische Währung) — nach den Nomen 2026-11-02
  'Phalanx', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schlachtordnung / geschlossene Front / Anatomie: Fingerglied) — nach den Nomen 2026-11-02
  'Phantom', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Trugbild, Gespenst / Medizin: Übungsmodell / unbekannter gesuchter Täter) — nach den Nomen 2026-11-02
  'Phase', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abschnitt einer Entwicklung / Elektrotechnik: Phase / Mondphase) — nach den Nomen 2026-11-02
  'Philharmonie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Orchester / Konzerthaus) — nach den Nomen 2026-11-02
  'Philharmoniker', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Plural: philharmonisches Orchester / Mitglied dieses Orchesters) — nach den Nomen 2026-11-02
  'Philosophie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wissenschaft / persönliche Grundhaltung, z. B. «Firmenphilosophie») — nach den Nomen 2026-11-02
  'Phrase', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: abgegriffene Redensart / Sprachwissenschaft: Wortgruppe / Musik: Sinneinheit) — nach den Nomen 2026-11-02
  'Pichler', // zurückgestellt: Familienname, kein gebräuchliches Nomen — Regel 14 2026-11-02
  'Pickel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hautpustel / Spitzhacke, Eispickel) — nach den Nomen 2026-11-02
  'Pickerl', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen, österreichisch: Aufkleber / Autobahnvignette bzw. Begutachtungsplakette) — nach den Nomen 2026-11-02
  'Pieper', // zurückgestellt: umgangssprachlich für Funkrufempfänger bzw. Familienname; Bedeutung/Gebrauch unsicher — Regel 14 2026-11-02
  'Piercing', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Durchstechen der Haut / der eingesetzte Schmuck) — nach den Nomen 2026-11-02
  'Pietsch', // zurückgestellt: Familienname, kein gebräuchliches Nomen — Regel 14 2026-11-02
  'Pille', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tablette / Antibabypille «die Pille») — nach den Nomen 2026-11-02
  'Piller', // zurückgestellt: kein gebräuchliches Nomen (Familienname?) — Regel 14 2026-11-02
  'Pilote', // zurückgestellt: kein gebräuchliches deutsches Nomen; gemeint vielleicht «der Pilot» — Regel 14 2026-11-02
  'Pilz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schwammerl, Speisepilz / Pilzinfektion, z. B. Fußpilz) — nach den Nomen 2026-11-02
  'Pin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1/2 (mehrere Bedeutungen und Artikel: die PIN = Geheimzahl / der Pin = Anstecknadel, Kegel) — nach den Nomen 2026-11-02
  'Pionier', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wegbereiter / Soldat der Pioniertruppe) — nach den Nomen 2026-11-02
  'Pipa', // zurückgestellt: kein gebräuchliches deutsches Nomen (chinesisches Saiteninstrument? Kröte?); Bedeutung unsicher — Regel 14 2026-11-02
  'Piste', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Skipiste / Rollbahn auf dem Flugplatz / Rennstrecke) — nach den Nomen 2026-11-02
  'Planungsreferat', // zurückgestellt: meist Name einer Behörde (Referat für Stadtplanung und Bauordnung, München) — wie Kreisverwaltungsreferat, Regel 18 — 2026-11-02
  'Plasma', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Physik: ionisiertes Gas / Medizin: Blutplasma) — nach den Nomen 2026-11-02
  'Plateau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hochebene / Stillstand einer Entwicklung, z. B. Leistungsplateau) — nach den Nomen 2026-11-02
  'Plattform', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: erhöhte Fläche, Bahnsteig / Grundlage, Basis / Internetplattform) — nach den Nomen 2026-11-02
  'Platz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ort, Stadtplatz / Sitzplatz / Raum / Rang, Platzierung) — nach den Nomen 2026-11-02
  'Platzhirsch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: stärkster Hirsch eines Reviers / übertragen: dominierende Person oder Firma) — nach den Nomen 2026-11-02
  'Platzierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rang in einem Wettbewerb / Aufstellen, Anordnen, z. B. von Waren oder Werbung) — nach den Nomen 2026-11-02
  'Platzverweis', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: Feldverweis / Polizei: Anordnung, einen Ort zu verlassen) — nach den Nomen 2026-11-02
  'Player', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abspielgerät, z. B. MP3-Player / Akteur auf dem Markt) — nach den Nomen 2026-11-02
  'Pleite', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zahlungsunfähigkeit / umgangssprachlich: Reinfall, Misserfolg) — nach den Nomen 2026-11-02
  'Plot', // zurückgestellt: Artikel schwankend (der/das Plot) — Regel 14 — 2026-11-02
  'Plus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pluszeichen / Überschuss, Gewinn / Vorteil) — nach den Nomen 2026-11-02
  'Podest', // zurückgestellt: Artikel schwankend (das Podest, landschaftlich/österreichisch auch der Podest) — Regel 14 — 2026-11-02
  'Podium', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: erhöhte Bühne / die Diskussionsrunde auf dem Podium) — nach den Nomen 2026-11-02
  'Poesie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Dichtkunst, Dichtung / poetischer Zauber, Stimmung) — nach den Nomen 2026-11-02
  'Pogrom', // zurückgestellt: Artikel schwankend (der/das Pogrom) — Regel 14 — 2026-11-02
  'Pokal', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Siegerpokal / Trinkgefäß mit Fuß / Pokalwettbewerb) — nach den Nomen 2026-11-02
  'Poker', // zurückgestellt: Artikel schwankend (das Poker, österreichisch auch der Poker) — Regel 14 — 2026-11-02
  'Polarisierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spaltung einer Gesellschaft in Lager / Physik: Polarisation, Ausrichtung) — nach den Nomen 2026-11-02
  'Politik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Staatsführung, Politik eines Landes / berechnendes Vorgehen, Taktik) — nach den Nomen 2026-11-02
  'Polizeibeamter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Polizeibeamte, ein Polizeibeamter) — nach den Nomen 2026-11-02
  'Polster', // zurückgestellt: Artikel und Plural schwankend (das Polster, österreichisch der Polster, Plural auch Pölster) — Regel 14 — 2026-11-02
  'Pont', // zurückgestellt: kein gebräuchliches deutsches Nomen (französisch «Brücke»; Namensbestandteil) — Regel 14 — 2026-11-02
  'Ponte', // zurückgestellt: kein gebräuchliches deutsches Nomen (italienisch «Brücke»; Namensbestandteil) — Regel 14 — 2026-11-02
  'Portal', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: großes Tor, Eingang / Internetportal) — nach den Nomen 2026-11-02
  'Portefeuille', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: veraltet Brieftasche / Geschäftsbereich eines Ministers / Wertpapierbestand) — nach den Nomen 2026-11-02
  'Porter', // zurückgestellt: Artikel schwankend (der/das Porter, Biersorte) — Regel 14 — 2026-11-02
  'Portfolio', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wertpapierbestand / Mappe mit Arbeitsproben / Produktpalette) — nach den Nomen 2026-11-02
  'Portrait', // zurückgestellt: Schreibvariante von «das Porträt» (eigene Karte nach Regel 5 wäre doppelt) — Regel 14 — 2026-11-02
  'Position', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stelle, Lage / berufliche Stellung / Standpunkt / Posten einer Liste) — nach den Nomen 2026-11-02
  'Positionierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufstellen an einer Stelle / Marktpositionierung / Stellungnahme) — nach den Nomen 2026-11-02
  'Post', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1/2 (mehrere Bedeutungen und Artikel: die Post = Postdienst, Briefe, Postamt / der Post = Beitrag in sozialen Medien) — nach den Nomen 2026-11-02
  'Postauto', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fahrzeug der Post / schweizerisch: Postbus, Linienbus) — nach den Nomen 2026-11-02
  'Postbank', // zurückgestellt: Name eines Unternehmens (Bank) — Regel 18 — 2026-11-02
  'Postbeamter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Postbeamte, ein Postbeamter) — nach den Nomen 2026-11-02
  'Posten', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stelle, Amt / Wachposten / Warenposten, Rechnungsposten) — nach den Nomen 2026-11-02
  'Poster', // zurückgestellt: Artikel schwankend (das Poster, auch der Poster) — Regel 14 — 2026-11-02
  'Postgewerkschaft', // zurückgestellt: meist Name einer Organisation (Deutsche Postgewerkschaft, bis 2001) — Regel 18 — 2026-11-02
  'Postmoderne', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1/4 (Epoche der Kunst und Philosophie / wie «die Moderne» möglicherweise adjektivisch gebeugt) — nach den Nomen 2026-11-02
  'Postulat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Forderung / Philosophie: unbeweisbare Annahme / schweizerisch: parlamentarischer Auftrag) — nach den Nomen 2026-11-02
  'Potenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mathematik: Potenz / Zeugungsfähigkeit / Leistungsfähigkeit) — nach den Nomen 2026-11-02
  'Pott', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen, umgangssprachlich: Topf / großes Schiff / «der Pott» = Ruhrgebiet) — nach den Nomen 2026-11-02
  'Pound', // zurückgestellt: englisches Wort (britisches Pfund), kein gebräuchliches deutsches Nomen — Regel 14 — 2026-11-02
  'Powerplay', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Eishockey: Überzahlspiel / allgemein: Angriff mit großem Druck) — nach den Nomen 2026-11-02
  'Praktik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verfahrensweise, Methode / meist Plural, abwertend: unerlaubte Machenschaften) — nach den Nomen 2026-11-02
  'Praktiker', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mensch mit praktischer Erfahrung / umgangssprachlich: praktischer Arzt, Allgemeinmediziner) — nach den Nomen 2026-11-02
  'Prater', // zurückgestellt: Name eines Parks/Vergnügungsgeländes in Wien, kein geografischer Eigenname — wie Palmengarten, Regel 18 — 2026-11-02
  'Praxis', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Arztpraxis, Kanzlei / praktische Erfahrung / Anwendung, Wirklichkeit) — nach den Nomen 2026-11-02
  'Preis', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kaufpreis / Auszeichnung, Gewinn) — nach den Nomen 2026-11-02
  'Preisspanne', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spanne zwischen niedrigstem und höchstem Preis / Handelsspanne zwischen Einkaufs- und Verkaufspreis) — nach den Nomen 2026-11-02
  'Presse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Druck-/Pressmaschine / Zeitungen, Journalismus / Saftpresse / ugs. Paukschule) — nach den Nomen 2026-11-02
  'Prim', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fechten: Prim-Stellung / Musik: Prime, erster Ton / kath. Liturgie: Morgengebet) — nach den Nomen 2026-11-02
  'Primarius', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: österr. Primararzt / Musik: Primgeiger im Streichquartett / veraltet: Hauptpfarrer) — nach den Nomen 2026-11-02
  'Primo', // zurückgestellt: Fachwort Musik (erste Stimme beim vierhändigen Klavierspiel), Genus/Plural und Gebrauch als Nomen unsicher — Regel 14 — 2026-11-02
  'Prise', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kleine Menge, «eine Prise Salz» / Seerecht: erbeutetes Schiff) — nach den Nomen 2026-11-02
  'Prix', // zurückgestellt: nur in festen Fügungen (Grand Prix), kein eigenständiges deutsches Nomen — Regel 14 — 2026-11-02
  'Probe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Test, Prüfung / Muster, Stichprobe (Blutprobe) / Theater-, Musikprobe) — nach den Nomen 2026-11-02
  'Produkt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erzeugnis, Ware / Ergebnis, Folge / Mathematik: Ergebnis einer Multiplikation) — nach den Nomen 2026-11-02
  'Produktion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Herstellung / hergestellte Menge / Film-, Theaterproduktion als Werk / Abteilung im Betrieb) — nach den Nomen 2026-11-02
  'Produzent', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hersteller, Erzeuger / Film-, Musikproduzent) — nach den Nomen 2026-11-02
  'Professor', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hochschullehrer / österr. Titel für Lehrer an höheren Schulen) — nach den Nomen 2026-11-02
  'Professorin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (wie «Professor»: Hochschullehrerin / österr. Titel für Lehrerinnen an höheren Schulen) — nach den Nomen 2026-11-02
  'Profil', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Seitenansicht / Reifenprofil / Persönlichkeit, Ausprägung / Nutzerprofil) — nach den Nomen 2026-11-02
  'Profilierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: sich profilieren, Ansehen gewinnen / mit Profil versehen, technisch) — nach den Nomen 2026-11-02
  'Programm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fernseh-, Veranstaltungsprogramm / Computerprogramm / Parteiprogramm, Plan) — nach den Nomen 2026-11-02
  'Projektion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bild auf Leinwand / Psychologie: Übertragung eigener Gefühle / Mathematik, Kartografie: Abbildung) — nach den Nomen 2026-11-02
  'Promille', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tausendstel / ugs. Blutalkoholgehalt) — nach den Nomen 2026-11-02
  'Prominenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gesamtheit der Prominenten / das Prominentsein) — nach den Nomen 2026-11-02
  'Promoter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Veranstalter von Konzerten, Boxkämpfen / Verkaufsförderer) — nach den Nomen 2026-11-02
  'Propagandist', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: wer Propaganda macht / Wirtschaft: Werbefachmann, Produktvorführer) — nach den Nomen 2026-11-02
  'Proporz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verteilung von Ämtern nach Parteienstärke / österr., schweiz.: Verhältniswahl) — nach den Nomen 2026-11-02
  'Prospekt', // zurückgestellt: Artikel in Österreich auch «das Prospekt»; dazu mehrere Bedeutungen (Werbeheft / Bühnenhintergrund / Straße in Russland) — 2026-11-02
  'Prostituierte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Prostituierte) — nach den Nomen 2026-11-02
  'Protagonist', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hauptfigur, Hauptdarsteller / Vorkämpfer) — nach den Nomen 2026-11-02
  'Protagonistin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (wie «Protagonist»: Hauptfigur / Vorkämpferin) — nach den Nomen 2026-11-02
  'Protektorat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schirmherrschaft / Schutzgebiet unter Herrschaft eines anderen Staates) — nach den Nomen 2026-11-02
  'Prothese', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: künstliches Glied / Zahnersatz / Sprachwissenschaft: Vorsetzen eines Lautes) — nach den Nomen 2026-11-02
  'Protokoll', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Niederschrift einer Sitzung / diplomatische Regeln / EDV: Übertragungsregeln) — nach den Nomen 2026-11-02
  'Prototyp', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: erstes Modell, Technik / Urbild, Inbegriff eines Typs) — nach den Nomen 2026-11-02
  'Provinz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verwaltungsgebiet / oft abwertend: ländliche Gegend fern der Großstadt) — nach den Nomen 2026-11-02
  'Prozent', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hundertstel / Plural ugs.: Rabatt, Gewinnanteil «Prozente bekommen») — nach den Nomen 2026-11-02
  'Prozess', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gerichtsverfahren / Vorgang, Entwicklung) — nach den Nomen 2026-11-02
  'Psychiatrie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fachgebiet der Medizin / psychiatrische Klinik, Abteilung) — nach den Nomen 2026-11-02
  'Psychologie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wissenschaft vom Seelenleben / Gespür für Menschen, «mit viel Psychologie») — nach den Nomen 2026-11-02
  'Pub', // zurückgestellt: Artikel doppelt (der/das Pub) — wie Poster, Plot — 2026-11-02
  'Puck', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 3 (Homograph, gleicher Artikel: Puck «Kobold» / Puck «Eishockeyscheibe») — nach den Nomen 2026-11-02
  'Pudel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hunderasse / Kegeln: Fehlwurf) — nach den Nomen 2026-11-02
  'Puffer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Eisenbahn: Stoßdämpfer / EDV: Zwischenspeicher / Kartoffelpuffer / Reserve) — nach den Nomen 2026-11-02
  'Pulp', // zurückgestellt: Bedeutung/Gebrauch unsicher (Fruchtmark / Schundliteratur «Pulp Fiction»), kein gebräuchliches deutsches Nomen — Regel 14 — 2026-11-02
  'Pulver', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: feiner Staub / Schießpulver / salopp: Geld) — nach den Nomen 2026-11-02
  'Pulverfass', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fass mit Schießpulver / übertragen: Krisenherd) — nach den Nomen 2026-11-02
  'Pumpe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gerät zum Fördern von Flüssigkeit/Luft / salopp: Herz) — nach den Nomen 2026-11-02
  'Punk', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Protestbewegung / Punkrock / Punker als Person) — nach den Nomen 2026-11-02
  'Punkt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Satzzeichen / Stelle, Ort / Wertungseinheit / Thema einer Liste) — nach den Nomen 2026-11-02
  'Puppe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spielzeug / Entwicklungsstadium von Insekten / ugs. Mädchen) — nach den Nomen 2026-11-02
  'Putz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wandverputz / veraltend: Kleidung, Schmuck; ugs. «auf den Putz hauen») — nach den Nomen 2026-11-02
  'Pyramide', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: geometrischer Körper / Bauwerk in Ägypten / übertragen: Alterspyramide, Hierarchie) — nach den Nomen 2026-11-02
  'Python', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2 (Homograph: der Python «Riesenschlange» / Python «Programmiersprache»; Plural Pythons/Pythonen) — nach den Nomen 2026-11-02
  'Quadrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Viereck / Mathematik: zweite Potenz) — nach den Nomen 2026-11-02
  'Quadratur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mathematik / «Quadratur des Kreises» = unlösbare Aufgabe / Astronomie) — nach den Nomen 2026-11-02
  'Qualifikation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: berufliche Befähigung / Sport: Ausscheidungswettbewerb) — nach den Nomen 2026-11-02
  'Qualifizierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Weiterbildung / Sport: das Sich-Qualifizieren / Einstufung) — nach den Nomen 2026-11-02
  'Quantensprung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Physik / übertragen: großer Fortschritt) — nach den Nomen 2026-11-02
  'Quantum', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Menge, Anteil / Physik: Quant) — nach den Nomen 2026-11-02
  'Quadratmeter', // zurückgestellt: Artikel doppelt (der/das Quadratmeter) — wie Meter, Millimeter — 2026-11-02
  'Quartett', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musikstück/Gruppe für vier / Kartenspiel) — nach den Nomen 2026-11-02
  'Quartier', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Unterkunft / österr./schweiz.: Stadtviertel / Militär: Truppenunterkunft) — nach den Nomen 2026-11-02
  'Quell', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (dichterisch für Quelle: Wasserquelle / Ursprung) — nach den Nomen 2026-11-02
  'Quelle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wasserquelle / Informationsquelle / Ursprung) — nach den Nomen 2026-11-02
  'Querdenker', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: unkonventioneller Denker / seit 2020 abwertend: Gegner der Corona-Maßnahmen) — nach den Nomen 2026-11-02
  'Querschnitt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schnitt quer zur Achse / repräsentativer Überblick) — nach den Nomen 2026-11-02
  'Querverbindung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verkehrsverbindung / gedanklicher Zusammenhang) — nach den Nomen 2026-11-02
  'Quintett', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musikstück für fünf / Gruppe von fünf Musikern) — nach den Nomen 2026-11-02
  'Quittung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Empfangsbestätigung / übertragen: unangenehme Folge) — nach den Nomen 2026-11-02
  'Quarterback', // zurückgestellt: englisches Fachwort (American Football), Aussprache und Gebrauch im Deutschen unsicher — Regel 14 — 2026-11-02
  'Quast', // zurückgestellt: Bedeutung regional unsicher (breiter Pinsel / Quaste) — Regel 14 — 2026-11-02
  'Quere', // zurückgestellt: nur in fester Wendung («jemandem in die Quere kommen») — 2026-11-02
  'Quote', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anteil, Rate / festgelegter Anteil (Frauenquote) / Einschaltquote) — nach den Nomen 2026-11-02
  'Rabatte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2 (Homograph: die Rabatte «schmales Beet» / Plural von «der Rabatt») — nach den Nomen 2026-11-02
  'Rachen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schlund beim Menschen / Maul großer Raubtiere) — nach den Nomen 2026-11-02
  'Radfahrer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: wer Rad fährt / ugs. abwertend: wer nach oben buckelt und nach unten tritt) — nach den Nomen 2026-11-02
  'Radfahrerin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (wie Radfahrer: wer Rad fährt / ugs. abwertend) — nach den Nomen 2026-11-02
  'Radierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Technik des Radierens / so hergestelltes Bild) — nach den Nomen 2026-11-02
  'Radikal', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Chemie: freies Radikal / Mathematik: Wurzel; dazu Verwechslung mit «der/die Radikale», Fall 4) — nach den Nomen 2026-11-02
  'Rabbi', // zurückgestellt: Titel/Anrede jüdischer Gelehrter, Plural doppelt (Rabbinen/Rabbis); gebräuchlich ist «Rabbiner» — Regel 14 — 2026-11-02
  'Radar', // zurückgestellt: Artikel doppelt (der/das Radar) — 2026-11-02
  'Radio', // zurückgestellt: Artikel regional doppelt (süddt./österr./schweiz. auch «der Radio») und mehrere Bedeutungen (Gerät / Rundfunk) — 2026-11-02
  'Radius', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mathematik: Halbmesser / Reichweite, Aktionsradius) — nach den Nomen 2026-11-02
  'Raffinesse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schlauheit, Durchtriebenheit / meist Plural: technische Feinheit) — nach den Nomen 2026-11-02
  'Rahmen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bilderrahmen / Fahrzeuggestell / übertragen: Rahmen, Umfang) — nach den Nomen 2026-11-02
  'Rahmenprogramm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Begleitprogramm einer Veranstaltung / Förderprogramm, z. B. der EU) — nach den Nomen 2026-11-02
  'Rakete', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Weltraumrakete / Waffe / Feuerwerkskörper) — nach den Nomen 2026-11-02
  'Radl', // zurückgestellt: Plural regional unsicher (die Radl / die Radln), dazu Mundartwort — Regel 14 — 2026-11-02
  'Rampe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: schräge Auffahrt / Laderampe / Bühnenrand) — nach den Nomen 2026-11-02
  'Rampenlicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bühnenbeleuchtung / übertragen: Öffentlichkeit) — nach den Nomen 2026-11-02
  'Rang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stellung, Stufe / Theater: Galerie / Sport: Platzierung) — nach den Nomen 2026-11-02
  'Ranger', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufseher im Nationalpark / Soldat einer US-Spezialeinheit) — nach den Nomen 2026-11-02
  'Rallye', // zurückgestellt: Artikel regional doppelt (die Rallye, schweiz. das Rallye) — 2026-11-02
  'Rambo', // zurückgestellt: aus einem Filmtitel, umgangssprachlich; Markierung unsicher — Regel 14 — 2026-11-02
  'Ramsau', // zurückgestellt: mehrere Orte gleichen Namens (Ramsau am Dachstein / bei Berchtesgaden), Artikel unsicher (die Ramsau) — Regel 14 — 2026-11-02
  'Ranch', // zurückgestellt: Plural doppelt (Ranchs/Ranches), Aussprache doppelt — Regel 14 — 2026-11-02
  'Randal', // zurückgestellt: kein gebräuchliches Nomen (üblich: die Randale) — Regel 14 — 2026-11-02
  'Range', // zurückgestellt: Bedeutung/Gebrauch unsicher (landschaftlich «wildes Kind» / engl. range) — Regel 14 — 2026-11-02
  'Rank', // zurückgestellt: regional (schweiz.), meist nur in Wendungen («den Rank finden») — Regel 14 — 2026-11-02
  'Rappen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2 (Homograph: der Rappen «Schweizer Münze» / Plural von «der Rappe» «schwarzes Pferd») — nach den Nomen 2026-11-02
  'Rapport', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bericht, Meldung / Psychologie: Beziehung, Kontakt) — nach den Nomen 2026-11-02
  'Raps', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2 (Homograph: der Raps «Pflanze» / Plural von «der Rap») — nach den Nomen 2026-11-02
  'Raserei', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: zu schnelles Fahren / Tobsucht, Wut) — nach den Nomen 2026-11-02
  'Rasse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tierrasse / Menschen: heute problematisch; dazu ugs. «Rasse haben») — nach den Nomen 2026-11-02
  'Rat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ratschlag / Gremium / Titel, Person) — nach den Nomen 2026-11-02
  'Rate', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Teilzahlung / Quote, Anteil) — nach den Nomen 2026-11-02
  'Ratgeber', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Person, die rät / Buch mit Ratschlägen) — nach den Nomen 2026-11-02
  'Rapp', // zurückgestellt: keine gebräuchliche Form (üblich: der Rappe) — Regel 14 — 2026-11-02
  'Rating', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bonitätseinstufung / Verfahren zur Einschätzung) — nach den Nomen 2026-11-02
  'Rationalisierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wirtschaft: Effizienzsteigerung / Psychologie: nachträgliche Rechtfertigung) — nach den Nomen 2026-11-02
  'Ratsvorsitzende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Ratsvorsitzende) — nach den Nomen 2026-11-02
  'Ratte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tier / abwertend: gemeiner Mensch) — nach den Nomen 2026-11-02
  'Raub', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Rauben / Beute, «ein Raub der Flammen») — nach den Nomen 2026-11-02
  'Raucher', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Person, die raucht / ugs. Raucherabteil) — nach den Nomen 2026-11-02
  'Raum', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zimmer / Platz, Fläche / Weltraum / Gebiet, Region) — nach den Nomen 2026-11-02
  'Raupe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Insektenlarve / Kettenfahrzeug, Planierraupe) — nach den Nomen 2026-11-02
  'Rausch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Trunkenheit, Drogenrausch / übertragen: Begeisterung, Taumel) — nach den Nomen 2026-11-02
  'Reaktion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Antwort auf etwas / Chemie / Politik: Reaktionäre) — nach den Nomen 2026-11-02
  'Rauscher', // zurückgestellt: Bedeutung regional unsicher (Sturm, junger Wein) bzw. Familienname — Regel 14 — 2026-11-02
  'Rave', // zurückgestellt: Artikel doppelt (der/das Rave) — 2026-11-02
  'Realisierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verwirklichung / Wirtschaft: Umwandlung in Geld / Erkennen) — nach den Nomen 2026-11-02
  'Realismus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: wirklichkeitsnahe Haltung / Kunst- und Literaturepoche / Philosophie) — nach den Nomen 2026-11-02
  'Realist', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: nüchtern denkender Mensch / Vertreter des Realismus in Kunst und Literatur) — nach den Nomen 2026-11-02
  'Rechner', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Computer / Taschenrechner / Person, die gut rechnet) — nach den Nomen 2026-11-02
  'Rechnung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zahlungsaufforderung / Berechnung; «etwas in Rechnung stellen») — nach den Nomen 2026-11-02
  'Recht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rechtsordnung, Gesetze / Anspruch, Befugnis «das Recht auf …» / Rechtswissenschaft; dazu «recht haben») — nach den Nomen 2026-11-03
  'Rechtsschutz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schutz durch die Gerichte / kurz für Rechtsschutzversicherung) — nach den Nomen 2026-11-03
  'Recke', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2 (Homograph: der Recke «Held» / Plural von «das Reck») — nach den Nomen 2026-11-03
  'Redaktion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Redigieren / Gesamtheit der Redakteure / Büro, Raum) — nach den Nomen 2026-11-03
  'Rede', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ansprache / das Reden, Gespräch «Davon ist keine Rede» / Grammatik: direkte, indirekte Rede) — nach den Nomen 2026-11-03
  'Reduktion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verringerung / Chemie: Elektronenaufnahme / Philosophie, Zurückführung) — nach den Nomen 2026-11-03
  'Reeperbahn', // zurückgestellt: Straßenname in Hamburg (kein geografischer Name nach Regel 18) — 2026-11-03
  'Referat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vortrag, schriftliche Arbeit / Abteilung in einer Behörde) — nach den Nomen 2026-11-03
  'Referee', // zurückgestellt: Fremdwort aus dem Sport (Schiedsrichter); Gebrauch/Region unsicher — Regel 14 — 2026-11-03
  'Referent', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vortragender / Sachbearbeiter, Berater in Behörde / Sprachwissenschaft: Bezugsobjekt) — nach den Nomen 2026-11-03
  'Referentin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vortragende / Sachbearbeiterin, Beraterin in Behörde) — nach den Nomen 2026-11-03
  'Referenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Empfehlung, Zeugnis / Bezug, Verweis / Vergleichsgröße) — nach den Nomen 2026-11-03
  'Reflex', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: unwillkürliche Reaktion des Körpers / Widerschein, Lichtreflex) — nach den Nomen 2026-11-03
  'Reflexion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Physik: Zurückwerfen von Licht, Schall / Nachdenken, Überlegung) — nach den Nomen 2026-11-03
  'Reformation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kirchenreform im 16. Jh. / gehoben: Erneuerung, Umgestaltung) — nach den Nomen 2026-11-03
  'Reformator', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Begründer der Reformation (Luther u. a.) / allgemein: Erneuerer) — nach den Nomen 2026-11-03
  'Reformstaat', // zurückgestellt: Bedeutung/Gebrauch unsicher (Staat mit Reformen / Reformstaaten Osteuropas), kein fester Duden-Eintrag — Regel 14 — 2026-11-03
  'Regale', // zurückgestellt: nur Plural von «das Regal»; als eigenes Wort (Orgelregister «das Regal», Pl. Regale) unsicher — Regel 14 — 2026-11-03
  'Regel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorschrift, Norm / Gewohnheit «in der Regel» / Menstruation) — nach den Nomen 2026-11-03
  'Regelung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Regeln, Ordnen / festgelegte Vorschrift, Vereinbarung / Technik: Steuerung) — nach den Nomen 2026-11-03
  'Regeneration', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erholung / Biologie: Neubildung von Gewebe / Technik: Wiederaufbereitung) — nach den Nomen 2026-11-03
  'Regent', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: regierender Fürst / Stellvertreter eines minderjährigen oder verhinderten Herrschers) — nach den Nomen 2026-11-03
  'Regentschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Herrschaft eines Regenten / stellvertretende Herrschaft) — nach den Nomen 2026-11-03
  'Regie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spielleitung bei Film, Theater / Verwaltung, Leitung «in eigener Regie») — nach den Nomen 2026-11-03
  'Regierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gesamtheit der Minister, Kabinett / das Regieren, Herrschaft / Regierungszeit) — nach den Nomen 2026-11-03
  'Regierungsbeamter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der Regierungsbeamte / ein Regierungsbeamter) — nach den Nomen 2026-11-03
  'Regierungsrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schweiz: Kantonsregierung bzw. ihr Mitglied / Deutschland, Österreich: Beamtentitel) — nach den Nomen 2026-11-03
  'Regime', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: abwertend: undemokratische Regierung / Ordnung, Lebensweise «Diätregime»; Plural Regime/Regimes) — nach den Nomen 2026-11-03
  'Regiment', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Herrschaft, Leitung «ein strenges Regiment führen» (Pl. Regimente) / Truppeneinheit (Pl. Regimenter)) — nach den Nomen 2026-11-03
  'Regionalverband', // zurückgestellt: Bedeutung je nach Land und Bereich verschieden (Planungsverband, Sport- oder Wirtschaftsverband) — Regel 14 — 2026-11-03
  'Register', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verzeichnis, amtliche Liste / Orgel: Pfeifenreihe / Stimm- und Sprachlage) — nach den Nomen 2026-11-03
  'Registrierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Eintragung, Anmeldung / Aufzeichnung (Messgerät) / Orgel: Wahl der Register) — nach den Nomen 2026-11-03
  'Regulierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einstellung, Steuerung (Technik) / Begradigung eines Flusses / staatliche Regelung der Wirtschaft) — nach den Nomen 2026-11-03
  'Regung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: leichte Bewegung / Gefühl, innere Empfindung) — nach den Nomen 2026-11-03
  'Rehabilitation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: medizinische und berufliche Wiedereingliederung / Wiederherstellung des Ansehens) — nach den Nomen 2026-11-03
  'Rehabilitierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wiederherstellung des Ansehens, der Rechte / Wiedereingliederung, Reha) — nach den Nomen 2026-11-03
  'Rehe', // zurückgestellt: nur Plural von «das Reh» (eigene Karte) — 2026-11-03
  'Reibung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Physik: Widerstand beim Reiben / Spannung, Streit zwischen Menschen) — nach den Nomen 2026-11-03
  'Reich', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Herrschaftsgebiet, Imperium «das Römische Reich» / übertragen: Bereich «das Reich der Träume»; historisch: das Deutsche Reich) — nach den Nomen 2026-11-03
  'Reichsbahn', // zurückgestellt: Name eines Unternehmens (Deutsche Reichsbahn) — Regel 18 — 2026-11-03
  'Reichstag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: historisches Parlament / Gebäude in Berlin, heute Sitz des Bundestags) — nach den Nomen 2026-11-03
  'Reife', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Reifsein von Obst / geistige Reife eines Menschen / Schulabschluss «mittlere Reife») — nach den Nomen 2026-11-03
  'Reifen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Autoreifen / Ring, Spielreifen; dazu Homograph «das Reifen» zu reifen) — nach den Nomen 2026-11-03
  'Reigen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rundtanz / übertragen: Folge, Reihe «ein Reigen von Festen») — nach den Nomen 2026-11-03
  'Reihe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Linie, Sitzreihe / Serie, Buchreihe / «an der Reihe sein» / Mathematik) — nach den Nomen 2026-11-03
  'Reimer', // zurückgestellt: Familienname bzw. selten (Reimschmied) — Regel 14 — 2026-11-03
  'Reine', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: das Reine «ins Reine schreiben», der/die Reine) — nach den Nomen 2026-11-03
  'Reinigung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Säubern / chemische Reinigung, Geschäft) — nach den Nomen 2026-11-03
  'Reisende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv/Partizip: der/die Reisende, ein Reisender) — nach den Nomen 2026-11-03
  'Reisezeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fahrtdauer / günstige Jahreszeit zum Reisen, Urlaubszeit) — nach den Nomen 2026-11-03
  'Reiz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sinnesreiz, Stimulus / Anziehungskraft, Charme «der Reiz des Neuen») — nach den Nomen 2026-11-03
  'Rektor', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schulleiter, v. a. Deutschland / Leiter einer Universität) — nach den Nomen 2026-11-03
  'Rektorin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schulleiterin / Leiterin einer Universität) — nach den Nomen 2026-11-03
  'Rekurs', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rechtsmittel, Einspruch (AT/CH) / bildungssprachlich: Rückgriff, Bezugnahme) — nach den Nomen 2026-11-03
  'Relation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beziehung, Verhältnis «in Relation zu» / Mathematik, Logik: Relation) — nach den Nomen 2026-11-03
  'Relativ', // zurückgestellt: Fachwort der Grammatik (Relativpronomen/-adverb), Gebrauch selten und unsicher — Regel 14 — 2026-11-03
  'Relegation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: Entscheidungsspiele um Auf-/Abstieg / Verweis von der Schule, Hochschule) — nach den Nomen 2026-11-03
  'Relief', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kunst: erhabenes Bildwerk / Geografie: Oberflächengestalt des Geländes) — nach den Nomen 2026-11-03
  'Rem', // zurückgestellt: veraltete Maßeinheit der Strahlendosis (heute Sievert); Fachwort, Gebrauch unsicher — Regel 14 — 2026-11-03
  'Reminiszenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erinnerung von Bedeutung / Anklang, Ähnlichkeit «eine Reminiszenz an …») — nach den Nomen 2026-11-03
  'Remise', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schuppen, Wagenschuppen / Schach (veraltet): Remis) — nach den Nomen 2026-11-03
  'Renaissance', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kunstepoche des 15./16. Jh. / Wiederbelebung, Wiederaufleben «eine Renaissance erleben») — nach den Nomen 2026-11-03
  'Rendezvous', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verabredung, Treffen von Verliebten / Raumfahrt: Begegnung zweier Raumfahrzeuge) — nach den Nomen 2026-11-03
  'Renner', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: umgangssprachlich: Verkaufsschlager / Rennpferd) — nach den Nomen 2026-11-03
  'Rennstall', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stall mit Rennpferden / Motor- und Radsport: Rennteam) — nach den Nomen 2026-11-03
  'Rep', // zurückgestellt: Bedeutung unsicher (Kurzwort: Republikaner, z. B. für Republikaner) — Regel 14 — 2026-11-03
  'Replik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erwiderung, Entgegnung / Kunst: Nachbildung eines Originals durch den Künstler) — nach den Nomen 2026-11-03
  'Report', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bericht, Dokumentation / Börse: Kursaufschlag beim Termingeschäft) — nach den Nomen 2026-11-03
  'Reproduktion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Biologie: Fortpflanzung / Nachbildung, Kopie eines Kunstwerks / Wiedergabe) — nach den Nomen 2026-11-03
  'Republikaner', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anhänger der Republik / Mitglied der Republikanischen Partei, z. B. in den USA) — nach den Nomen 2026-11-03
  'Requiem', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Totenmesse / musikalisches Werk für diese Messe) — nach den Nomen 2026-11-03
  'Reservat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schutzgebiet für Tiere und Pflanzen / Siedlungsgebiet für Ureinwohner) — nach den Nomen 2026-11-03
  'Reservation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: schweizerisch/veraltet: Reservierung / Gebiet für Ureinwohner in Nordamerika) — nach den Nomen 2026-11-03
  'Reserve', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorrat, Rücklage / Militär: Reservisten / Sport: Ersatzmannschaft / Zurückhaltung «jemanden aus der Reserve locken») — nach den Nomen 2026-11-03
  'Reservoir', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sammelbecken, Wasserspeicher / übertragen: Vorrat, Reservebestand) — nach den Nomen 2026-11-03
  'Residenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wohnsitz eines Fürsten, Bischofs / Hauptstadt mit Herrschersitz / gehoben: Wohnsitz) — nach den Nomen 2026-11-03
  'Resignation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufgeben, Mutlosigkeit / Amtssprache veraltet: Rücktritt) — nach den Nomen 2026-11-03
  'Resistenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Widerstand / Medizin, Biologie: Widerstandsfähigkeit gegen Erreger, Medikamente) — nach den Nomen 2026-11-03
  'Resolution', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Entschließung, Beschluss / Medizin: Rückbildung) — nach den Nomen 2026-11-03
  'Resonanz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Physik, Musik: Mitschwingen / Widerhall, Reaktion, Zustimmung «große Resonanz finden») — nach den Nomen 2026-11-03
  'Respekt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Achtung, Wertschätzung / Scheu, Furcht «Respekt vor dem Wasser haben») — nach den Nomen 2026-11-03
  'Ressort', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschäfts-, Zuständigkeitsbereich eines Ministers / Abteilung einer Zeitung, Redaktion) — nach den Nomen 2026-11-03
  'Retour', // zurückgestellt: als Nomen unsicher (Adverb «retour» = zurück; die Retoure = zurückgeschickte Ware; österr. ugs. Rückfahrkarte) — Regel 14 — 2026-11-03
  'Rettung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Retten, Rettung aus Gefahr / österreichisch: Rettungsdienst, Krankenwagen «die Rettung rufen») — nach den Nomen 2026-11-03
  'Revanche', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vergeltung, Rache / Sport, Spiel: Rückspiel, Gelegenheit zur Revanche) — nach den Nomen 2026-11-03
  'Reverenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ehrerbietung «jemandem seine Reverenz erweisen» / Verbeugung) — nach den Nomen 2026-11-03
  'Revier', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Polizeirevier / Jagdrevier, Gebiet eines Tieres / Bergbau, «das Revier» = Ruhrgebiet) — nach den Nomen 2026-11-03
  'Revision', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Überprüfung, Kontrolle / Recht: Rechtsmittel gegen ein Urteil / Druck: letzte Korrektur) — nach den Nomen 2026-11-03
  'Revisor', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wirtschafts-, Buchprüfer / Druckwesen: Korrektor der letzten Fahne) — nach den Nomen 2026-11-03
  'Revolution', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: politischer Umsturz / umwälzende Neuerung «eine Revolution in der Medizin» / Astronomie: Umlauf) — nach den Nomen 2026-11-03
  'Revue', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bühnenshow mit Musik und Tanz / Titel von Zeitschriften «etwas Revue passieren lassen») — nach den Nomen 2026-11-03
  'Rezept', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kochrezept / ärztliche Verordnung für Medikamente / übertragen: Mittel, Methode «ein Rezept gegen …») — nach den Nomen 2026-11-03
  'Rezeption', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Empfang im Hotel / Aufnahme eines Werkes durch Publikum, Wissenschaft) — nach den Nomen 2026-11-03
  'Rezeptur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pharmazie: Zubereitung nach Rezept / Arbeitsraum in der Apotheke / Zusammensetzung, Rezept eines Produkts) — nach den Nomen 2026-11-03
  'Rhythmik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: rhythmischer Charakter, Rhythmus / Lehre vom Rhythmus / rhythmische Erziehung) — nach den Nomen 2026-11-03
  'Rhythmus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musik: Takt, Gliederung / Sprache, Vers: Rhythmus / regelmäßige Wiederkehr «Tagesrhythmus») — nach den Nomen 2026-11-03
  'Richtung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Himmelsrichtung, Weg «in Richtung Bahnhof» / Strömung, Tendenz «politische Richtung») — nach den Nomen 2026-11-03
  'Rick', // zurückgestellt: Bedeutung regional/selten (Stange, Gestell; Familienname) — Regel 14 — 2026-11-03
  'Riege', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Turnen: Mannschaft, Gruppe / übertragen: Gruppe von Personen «die alte Riege») — nach den Nomen 2026-11-03
  'Riegel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verschluss an Tür, Fenster / Schokoriegel, Müsliriegel / Bauwesen, Kleidung) — nach den Nomen 2026-11-03
  'Riemer', // zurückgestellt: veraltete Berufsbezeichnung (Riemenmacher) bzw. Familienname — Regel 14 — 2026-11-03
  'Rind', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tier, Hausrind / ohne Plural: Rindfleisch «vom Rind») — nach den Nomen 2026-11-03
  'Rinde', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Baumrinde / Brotrinde, Käserinde / Anatomie: Hirnrinde) — nach den Nomen 2026-11-03
  'Ring', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schmuckring / Boxring / Ringstraße «der Ring» in Wien / Kreis, Verbindung) — nach den Nomen 2026-11-03
  'Ringen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sportart Ringen / Kampf, Bemühen «das Ringen um eine Lösung») — nach den Nomen 2026-11-03
  'Rippe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anatomie: Knochen im Brustkorb / Fleisch: Rippchen / Technik: Rippe am Heizkörper, Blattrippe) — nach den Nomen 2026-11-03
  'Riss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spalt, Sprung «ein Riss in der Wand» / technische Zeichnung «Grundriss» / übertragen: Bruch in einer Beziehung) — nach den Nomen 2026-11-03
  'Rist', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fußrücken, Spann / Handrücken / Widerrist bei Tieren) — nach den Nomen 2026-11-03
  'Rita', // zurückgestellt: Personenname (Vorname) — kein Eigenname nach Regel 18 — 2026-11-03
  'Ritter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: mittelalterlicher Krieger / Ordensritter, Adelstitel «Ritter von …»; dazu «arme Ritter» (Speise)) — nach den Nomen 2026-11-03
  'Ritual', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: religiöser Brauch, Zeremonie / feste Gewohnheit «mein Morgenritual») — nach den Nomen 2026-11-03
  'Ritz', // zurückgestellt: als Nomen unsicher (regional für die Ritze, Kratzer; Name eines Hotels) — Regel 14 — 2026-11-03
  'Robe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: festliches Abendkleid / Amtstracht von Richtern, Anwälten, Geistlichen) — nach den Nomen 2026-11-03
  'Robinson', // zurückgestellt: Personenname (Robinson Crusoe) bzw. Gattungsname «ein Robinson» selten — Regel 14 — 2026-11-03
  'Rochade', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schach: Rochade von König und Turm / Sport, Politik: Platz- oder Positionstausch) — nach den Nomen 2026-11-03
  'Rocker', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rockmusiker, Rockfan / Mitglied einer Motorradbande) — nach den Nomen 2026-11-03
  'Rogner', // zurückgestellt: Fachwort (weiblicher Fisch mit Rogen), selten — Regel 14 — 2026-11-03
  'Rohr', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Röhre, Leitung / Schilf, Bambus «das Rohr» / Lauf einer Waffe; österr. Backrohr = Backofen) — nach den Nomen 2026-11-03
  'Rolle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rolle im Theater, Funktion / Walze, Spule «eine Rolle Klopapier» / Turnübung) — nach den Nomen 2026-11-03
  'Roller', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tretroller, Motorroller / Farbroller / Brecher, Welle) — nach den Nomen 2026-11-03
  'Romane', // zurückgestellt: als Listeneintrag unsicher (Plural von «der Roman» oder seltenes Nomen «der Romane» = Angehöriger eines romanischsprachigen Volkes) — Regel 14 — 2026-11-03
  'Romantik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kunst- und Literaturepoche um 1800 / romantische Stimmung, Gefühl) — nach den Nomen 2026-11-03
  'Romantiker', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Künstler der Romantik / romantischer, schwärmerischer Mensch) — nach den Nomen 2026-11-03
  'Romanze', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kurze Liebesbeziehung / Musikstück, Gedicht) — nach den Nomen 2026-11-03
  'Romeo', // zurückgestellt: Personenname (Romeo und Julia) — kein Eigenname nach Regel 18 — 2026-11-03
  'Rosenkranz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gebetskette / das Gebet selbst «den Rosenkranz beten») — nach den Nomen 2026-11-03
  'Rotation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Drehung (Physik) / regelmäßiger Wechsel, Turnus / Fruchtfolge) — nach den Nomen 2026-11-03
  'Rotlicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: rotes Ampellicht / Infrarotlampe (Therapie) / Rotlichtmilieu) — nach den Nomen 2026-11-03
  'Rotstift', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: roter Stift / übertragen: Kürzung «den Rotstift ansetzen») — nach den Nomen 2026-11-03
  'Rottweiler', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hunderasse / Einwohner von Rottweil) — nach den Nomen 2026-11-03
  'Routine', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gewohnheit, gleichförmiger Ablauf / Erfahrung, Übung «Routine haben» / EDV: Programmroutine) — nach den Nomen 2026-11-03
  'Ruch', // zurückgestellt: gehoben/veraltend (Ruf, übler Beigeschmack), selten — Regel 14 — 2026-11-03
  'Ruder', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Riemen zum Rudern / Steuerruder / übertragen: Führung «am Ruder sein») — nach den Nomen 2026-11-03
  'Rudolph', // zurückgestellt: Personenname (Vorname) — kein Eigenname nach Regel 18 — 2026-11-03
  'Ruf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rufen, Schrei / Ansehen, Reputation «einen guten Ruf haben» / Berufung «einen Ruf an die Universität») — nach den Nomen 2026-11-03
  'Rufer', // zurückgestellt: selten (nur in Wendungen wie «ein Rufer in der Wüste») — Regel 14 — 2026-11-03
  'Ruhe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stille «Ruhe bitte!» / Erholung, Ausruhen / Gelassenheit «die Ruhe bewahren») — nach den Nomen 2026-11-03
  'Rum', // zurückgestellt: Artikel doppelt (der Rum, österr. auch das Rum) — Regel 14 — 2026-11-03
  'Rumpf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Oberkörper / Schiffsrumpf / Flugzeugrumpf) — nach den Nomen 2026-11-03
  'Rund', // zurückgestellt: selten/gehoben (das Rund = Kreis, Rundung; Stadion-Rund) — Regel 14 — 2026-11-03
  'Runde', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: Durchgang, Spielrunde / Rundgang, Strecke / Gruppe von Menschen / eine Runde Getränke) — nach den Nomen 2026-11-03
  'Rundfunkrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufsichtsgremium einer Rundfunkanstalt / Mitglied dieses Gremiums) — nach den Nomen 2026-11-03
  'Rundschau', // zurückgestellt: meist nur in Namen von Zeitungen und Sendungen («Frankfurter Rundschau»), sonst selten — Regel 14 — 2026-11-03
  'Rundumschlag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schlag nach allen Seiten / übertragen: pauschale Kritik an allen) — nach den Nomen 2026-11-03
  'Rundung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wölbung, runde Form / Mathematik: Runden einer Zahl) — nach den Nomen 2026-11-03
  'Runge', // zurückgestellt: Fachwort (Stütze am Wagen), selten; auch Familienname — Regel 14 — 2026-11-03
  'Rus', // zurückgestellt: historischer Name (die Kiewer Rus), kein geografischer Eigenname nach Regel 18 — Regel 14 — 2026-11-03
  'Rusch', // zurückgestellt: Bedeutung unsicher (regional/Familienname) — Regel 14 — 2026-11-03
  'Rush', // zurückgestellt: als deutsches Nomen selten, Bedeutung unsicher (Ansturm, Hauptverkehrszeit «Rushhour») — Regel 14 — 2026-11-03
  'Russlanddeutsche', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Russlanddeutsche, ein Russlanddeutscher) — nach den Nomen 2026-11-03
  'Rute', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gerte, Zweig (auch Krampusrute) / Angelrute / Wünschelrute; Jägersprache: Schwanz) — nach den Nomen 2026-11-03
  'Saalbau', // zurückgestellt: selten (Gebäude mit großem Saal; oft Name von Veranstaltungshäusern) — Regel 14 — 2026-11-03
  'Saat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Saatgut, Samen / das Säen / junge Pflanzen auf dem Feld) — nach den Nomen 2026-11-03
  'Sabena', // zurückgestellt: Firmenname (ehemalige belgische Fluggesellschaft) — Regel 18 — 2026-11-03
  'Sache', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gegenstand, Ding / Angelegenheit «eine wichtige Sache» / Recht: Rechtssache; Plural «Sachen» = Kleidung, Besitz) — nach den Nomen 2026-11-03
  'Sack', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: großer Beutel «ein Sack Kartoffeln» / derb: Hodensack; Schimpfwort «blöder Sack») — nach den Nomen 2026-11-03
  'Sackgasse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Straße ohne Durchfahrt / übertragen: ausweglose Lage «in eine Sackgasse geraten») — nach den Nomen 2026-11-03
  'Safe', // zurückgestellt: Artikel doppelt (der Safe, auch: das Safe) — Regel 14 — 2026-11-03
  'Saft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fruchtsaft / Pflanzensaft, Bratensaft / ugs.: Strom, Energie «kein Saft mehr im Akku») — nach den Nomen 2026-11-03
  'Saga', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: altisländische Prosaerzählung / lange Familien- oder Filmgeschichte) — nach den Nomen 2026-11-03
  'Sakko', // zurückgestellt: Artikel doppelt (das Sakko, auch: der Sakko) — Regel 14 — 2026-11-03
  'Salami', // zurückgestellt: Artikel doppelt (die Salami, schweizerisch auch: der Salami) — Regel 14 — 2026-11-03
  'Salon', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Empfangszimmer / Geschäft «Friseursalon, Kosmetiksalon» / Ausstellung, Messe «Automobilsalon») — nach den Nomen 2026-11-03
  'Salve', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: gleichzeitiges Abfeuern von Schüssen / übertragen: Lachsalve, Beifallssalve) — nach den Nomen 2026-11-03
  'Samariter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einwohner Samarias (Bibel) / hilfsbereiter Mensch «barmherziger Samariter» / Sanitäter, Mitglied eines Samariterbundes) — nach den Nomen 2026-11-03
  'Samba', // zurückgestellt: Artikel doppelt (die Samba, auch/österreichisch: der Samba) — Regel 14 — 2026-11-03
  'Samen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pflanzensamen / Sperma) — nach den Nomen 2026-11-03
  'Sammler', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Person, die etwas sammelt «Briefmarkensammler» / Jäger und Sammler (Frühgeschichte) / Technik: Sammelbehälter) — nach den Nomen 2026-11-03
  'Sammlung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: gesammelte Gegenstände, Kollektion / Geldsammlung, Spendenaktion / innere Konzentration) — nach den Nomen 2026-11-03
  'Sampler', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musik-Kompilation (CD) / elektronisches Gerät zum Samplen) — nach den Nomen 2026-11-03
  'Sander', // zurückgestellt: Fachwort (Geologie: Schwemmfläche) bzw. Familienname, selten — Regel 14 — 2026-11-03
  'Sandler', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: österr. ugs. Obdachloser, Stadtstreicher / abwertend: Versager, Nichtsnutz) — nach den Nomen 2026-11-03
  'Sandsack', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: mit Sand gefüllter Sack (Hochwasserschutz) / Boxsack (Training)) — nach den Nomen 2026-11-03
  'Sandwich', // zurückgestellt: Artikel doppelt (das Sandwich, auch: der Sandwich) — Regel 14 — 2026-11-03
  'Sanierer', // zurückgestellt: selten (Person, die ein Unternehmen oder Gebäude saniert), Bedeutung je nach Bereich — Regel 14 — 2026-11-03
  'Sanierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Renovierung von Gebäuden / wirtschaftliche Sanierung eines Unternehmens / Altlasten-, Umweltsanierung) — nach den Nomen 2026-11-03
  'Sanierungsfall', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: sanierungsbedürftiges Gebäude / Unternehmen in der Krise) — nach den Nomen 2026-11-03
  'Sanierungskonzept', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen wie «Sanierung»: Gebäude / Unternehmen / Umwelt) — nach den Nomen 2026-11-03
  'Sanierungsplan', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen wie «Sanierung»: Gebäude / Unternehmen; österr. Insolvenzrecht: Sanierungsplan) — nach den Nomen 2026-11-03
  'Sanierungsprogramm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen wie «Sanierung»: Gebäude / Unternehmen / Staatsfinanzen) — nach den Nomen 2026-11-03
  'Sanktion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Strafmaßnahme «Sanktionen gegen ein Land» / Rechtssprache: Billigung, Bestätigung) — nach den Nomen 2026-11-04
  'Satan', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: der Teufel (Religion) / übertragen: boshafter Mensch «ein Satan») — nach den Nomen 2026-11-04
  'Satellit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: künstlicher Raumflugkörper / Himmelskörper, Mond / übertragen: abhängiger Staat «Satellitenstaat») — nach den Nomen 2026-11-04
  'Sattel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Reitsattel / Fahrradsattel / Bergsattel, Pass) — nach den Nomen 2026-11-04
  'Satz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Grammatik / Sprung «mit einem Satz» / Tennis, Volleyball / Musik / Bodensatz / Tarif, Steuersatz) — nach den Nomen 2026-11-04
  'Sauer', // zurückgestellt: als Nomen unsicher (Adjektiv «sauer»; Familienname) — Regel 14 — 2026-11-04
  'Sauerei', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen, derb: Schmutz, Unordnung / Gemeinheit, Skandal / Zote) — nach den Nomen 2026-11-04
  'Schablone', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorlage zum Zeichnen, Ausschneiden / übertragen: Klischee, starres Muster) — nach den Nomen 2026-11-04
  'Schachspiel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Spiel Schach / Brett mit Figuren / einzelne Partie) — nach den Nomen 2026-11-04
  'Schachtel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Karton, Behälter / abwertend: «alte Schachtel» (ältere Frau)) — nach den Nomen 2026-11-04
  'Schachzug', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zug im Schachspiel / übertragen: geschickte Maßnahme «ein kluger Schachzug») — nach den Nomen 2026-11-04
  'Schade', // zurückgestellt: veraltete Nebenform von «der Schaden», nur noch in festen Wendungen («es soll dein Schade nicht sein») — Regel 14 — 2026-11-04
  'Schaf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tier / übertragen: gutmütiger, einfältiger Mensch «du Schaf»; «schwarzes Schaf») — nach den Nomen 2026-11-04
  'Schale', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Obst-, Eierschale / flaches Gefäß, Schüssel / österr.: Tasse «eine Schale Kaffee») — nach den Nomen 2026-11-04
  'Schalk', // zurückgestellt: veraltend, fast nur in fester Wendung («ihm sitzt der Schalk im Nacken») — Regel 14 — 2026-11-04
  'Schalke', // zurückgestellt: Name (Stadtteil von Gelsenkirchen, Fußballverein FC Schalke 04) — Regel 18 — Regel 14 — 2026-11-04
  'Schallmauer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Physik: Schallgeschwindigkeit «die Schallmauer durchbrechen» / übertragen: Grenze, Rekordmarke) — nach den Nomen 2026-11-04
  'Schalter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Licht-, Stromschalter / Bank-, Post-, Fahrkartenschalter) — nach den Nomen 2026-11-04
  'Schaltstelle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: technische Schaltanlage / übertragen: Zentrale, Machtzentrum «die Schaltstellen der Macht») — nach den Nomen 2026-11-04
  'Schaltung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: elektrische Schaltung / Gangschaltung (Auto, Fahrrad) / Liveschaltung (Fernsehen)) — nach den Nomen 2026-11-04
  'Scham', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gefühl der Scham / gehoben: äußere Geschlechtsteile) — nach den Nomen 2026-11-04
  'Schandfleck', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: hässliches Gebäude, das die Umgebung verschandelt / Person oder Sache, die Schande bringt «der Schandfleck der Familie») — nach den Nomen 2026-11-04
  'Schattenseite', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Seite im Schatten / übertragen: Nachteil «die Schattenseiten des Ruhms») — nach den Nomen 2026-11-04
  'Schattierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schattieren in der Malerei / Farbton, Nuance / übertragen: Richtung, Spielart «Politiker aller Schattierungen») — nach den Nomen 2026-11-04
  'Schatz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: wertvolle Dinge, Schatztruhe / Kosewort «mein Schatz») — nach den Nomen 2026-11-04
  'Schau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausstellung, Messe / Vorführung, Show / «zur Schau stellen» (zeigen); ugs. «eine Schau abziehen») — nach den Nomen 2026-11-04
  'Schaub', // zurückgestellt: selten (landschaftlich: Strohbündel) bzw. Familienname — Regel 14 — 2026-11-04
  'Schaufel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Werkzeug zum Graben / Turbinen-, Radschaufel / Jägersprache: Geweih) — nach den Nomen 2026-11-04
  'Schauspiel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Theaterstück, Drama / Schauspielkunst / übertragen: Anblick, Spektakel «ein Schauspiel der Natur») — nach den Nomen 2026-11-04
  'Schauspielerei', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. Beruf des Schauspielers / abwertend: Verstellung, Theater «Das ist doch alles Schauspielerei») — nach den Nomen 2026-11-04
  'Scheibe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Brot-, Wurstscheibe / Glasscheibe, Fenster / runde flache Platte, Zielscheibe) — nach den Nomen 2026-11-04
  'Scheich', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: arabischer Herrscher, Stammesoberhaupt / ugs. salopp: Freund, Liebhaber) — nach den Nomen 2026-11-04
  'Schein', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Licht, Lichtschein / äußerer Anschein «der Schein trügt» / Geldschein / Bescheinigung «Krankenschein, Führerschein») — nach den Nomen 2026-11-04
  'Scheinwerferlicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Licht eines Scheinwerfers / übertragen: öffentliche Aufmerksamkeit «im Scheinwerferlicht stehen») — nach den Nomen 2026-11-04
  'Scheitel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Haarscheitel / höchster Punkt, Scheitelpunkt (Mathematik) / gehoben: Kopf «vom Scheitel bis zur Sohle») — nach den Nomen 2026-11-04
  'Schenk', // zurückgestellt: veraltet (Mundschenk, Wirt) bzw. Familienname — Regel 14 — 2026-11-04
  'Schenkel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Oberschenkel, Bein / Schenkel eines Winkels, einer Zange) — nach den Nomen 2026-11-04
  'Schenker', // zurückgestellt: selten (Person, die schenkt) bzw. Familienname — Regel 14 — 2026-11-04
  'Scherben', // zurückgestellt: regionale Nebenform (süddt./österr. «der Scherben» = die Scherbe; Fachsprache: Blumentopf, Keramik), Lemma unsicher — Regel 14 — 2026-11-04
  'Scherbenhaufen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Haufen aus Scherben / übertragen: Trümmer, Scheitern «vor einem Scherbenhaufen stehen») — nach den Nomen 2026-11-04
  'Schere', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schneidewerkzeug / Krebsschere / übertragen: wachsender Abstand «die Schere zwischen Arm und Reich») — nach den Nomen 2026-11-04
  'Scherer', // zurückgestellt: selten (Schafscherer) bzw. Familienname — Regel 14 — 2026-11-04
  'Scheuer', // zurückgestellt: landschaftlich für «die Scheune» bzw. Familienname, Gebrauch unsicher — Regel 14 — 2026-11-04
  'Schicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lage, Schicht Farbe / Arbeitsschicht «Nachtschicht» / gesellschaftliche Schicht) — nach den Nomen 2026-11-04
  'Schichte', // zurückgestellt: österreichische Nebenform von «die Schicht», selten — Regel 14 — 2026-11-04
  'Schieber', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Riegel, Regler / ugs.: Schwarzhändler / Bettschieber (Bettpfanne) / Tanz) — nach den Nomen 2026-11-04
  'Schiedsrichter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: Unparteiischer / Recht: Mitglied eines Schiedsgerichts, Schlichter) — nach den Nomen 2026-11-04
  'Schiene', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bahngleis / Medizin: Schiene zum Ruhigstellen / Führungsschiene, Leiste / übertragen: Bereich «auf der politischen Schiene») — nach den Nomen 2026-11-04
  'Schiff', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wasserfahrzeug / Kirchenschiff (Langhaus)) — nach den Nomen 2026-11-04
  'Schiffbruch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Untergang eines Schiffes / übertragen: Scheitern «mit einem Plan Schiffbruch erleiden») — nach den Nomen 2026-11-04
  'Schikane', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: böswillige Behinderung, Quälerei / Motorsport: Schikane (Kurvenkombination) / ugs. «mit allen Schikanen» (mit allem Komfort)) — nach den Nomen 2026-11-04
  'Schill', // zurückgestellt: Bedeutung unsicher (österr. Name für den Zander; Familienname) — Regel 14 — 2026-11-04
  'Schimmel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schimmelpilz / weißes Pferd) — nach den Nomen 2026-11-04
  'Schimmer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: schwacher Glanz, Lichtschein / Spur, Andeutung «ein Schimmer Hoffnung»; ugs. «keinen blassen Schimmer haben») — nach den Nomen 2026-11-04
  'Schinken', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fleischware / ugs.: dickes Buch, großes Gemälde) — nach den Nomen 2026-11-04
  'Schippe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schaufel / ugs. «jemanden auf die Schippe nehmen» / Pik (Spielkarten) / ugs.: Schmollmund) — nach den Nomen 2026-11-04
  'Schirm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Regenschirm / Bildschirm, Lampenschirm / Mützenschirm / übertragen: Schutz) — nach den Nomen 2026-11-04
  'Schirmer', // zurückgestellt: Familienname — Regel 14 — 2026-11-04
  'Schizophrenie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Medizin: psychische Krankheit / bildungssprachlich: Widersinnigkeit, Widerspruch «die Schizophrenie dieser Politik») — nach den Nomen 2026-11-04
  'Schlachtfeld', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ort einer Schlacht / ugs. übertragen: große Unordnung «die Küche war ein Schlachtfeld») — nach den Nomen 2026-11-04
  'Schlag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hieb / Herzschlag, Glockenschlag / Stromschlag, Schlaganfall / Schicksalsschlag / österr. Schlagobers / Menschenschlag) — nach den Nomen 2026-11-04
  'Schlagabtausch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Boxen: Austausch von Schlägen / übertragen: heftiges Wortgefecht) — nach den Nomen 2026-11-04
  'Schlager', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: populäres Lied, Schlagermusik / übertragen: Verkaufsschlager, Erfolg) — nach den Nomen 2026-11-04
  'Schlagkraft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: körperliche Kraft zum Schlagen / Kampfkraft einer Armee / übertragen: Wirksamkeit «die Schlagkraft eines Arguments») — nach den Nomen 2026-11-04
  'Schlaglicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Malerei, Fotografie: starkes Licht / übertragen: «ein Schlaglicht auf etwas werfen» (deutlich zeigen)) — nach den Nomen 2026-11-04
  'Schlagwort', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Parole, Slogan / Stichwort, Schlüsselwort (Katalog, Register)) — nach den Nomen 2026-11-04
  'Schlamassel', // zurückgestellt: Artikel doppelt (der Schlamassel, österr. auch: das Schlamassel) — Regel 14 — 2026-11-04
  'Schlammschlacht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport im Schlamm, Spiel auf schlammigem Platz / übertragen: Streit mit gegenseitigen Beschimpfungen (Politik, Scheidung)) — nach den Nomen 2026-11-04
  'Schlange', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tier / Warteschlange «Schlange stehen» / abwertend: falscher, hinterhältiger Mensch) — nach den Nomen 2026-11-04
  'Schlauch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wasserschlauch / Fahrradschlauch / ugs.: langer schmaler Raum; «auf dem Schlauch stehen» (nicht verstehen)) — nach den Nomen 2026-11-04
  'Schleicher', // zurückgestellt: selten (abwertend: heimtückischer Mensch) bzw. Familienname, Gebrauch unsicher — Regel 14 — 2026-11-04
  'Schleier', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kopf-, Brautschleier / übertragen: Dunst, Nebelschleier; «den Schleier lüften») — nach den Nomen 2026-11-04
  'Schlepper', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Traktor, Zugmaschine / Schleppschiff / Schleuser (Menschenschmuggler) / ugs.: Kundenfänger) — nach den Nomen 2026-11-04
  'Schlepptau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abschleppseil / übertragen «jemanden im Schlepptau haben» (mit sich führen)) — nach den Nomen 2026-11-04
  'Schleuse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kanalschleuse für Schiffe / Luft-, Hygieneschleuse (Krankenhaus, Labor) / übertragen: «die Schleusen öffnen») — nach den Nomen 2026-11-04
  'Schlich', // zurückgestellt: Singular kaum gebräuchlich; fast nur in «jemandem auf die Schliche kommen» (Plural) bzw. Fachwort (Erzschlamm) — Regel 14 — 2026-11-04
  'Schlinge', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schlaufe, Fangschlinge (Falle) / Armschlinge (Medizin) / übertragen: «den Kopf aus der Schlinge ziehen») — nach den Nomen 2026-11-04
  'Schlitten', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rodelschlitten / ugs.: großes Auto / Technik: Schlitten einer Maschine) — nach den Nomen 2026-11-04
  'Schloss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gebäude (Palast, Burg) / Türschloss) — nach den Nomen 2026-11-04
  'Schlupfloch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Öffnung zum Durchschlüpfen / Versteck / übertragen: Gesetzeslücke) — nach den Nomen 2026-11-04
  'Schluss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ende / Folgerung («zu dem Schluss kommen»); «Schluss machen» (Beziehung beenden)) — nach den Nomen 2026-11-04
  'Schlusslicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rücklicht am Fahrzeug / übertragen: Letzter, Tabellenletzter) — nach den Nomen 2026-11-04
  'Schlussmann', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: Torwart / letzter Läufer einer Staffel / Letzter einer Reihe) — nach den Nomen 2026-11-04
  'Schlusspunkt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Punkt am Satzende / übertragen: Abschluss, Ende («einen Schlusspunkt setzen»)) — nach den Nomen 2026-11-04
  'Schlussrang', // zurückgestellt: besonders schweizerisch (Platzierung am Ende), Gebrauch unsicher — Regel 14 — 2026-11-04
  'Schmankerl', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: süddt./österr.: Leckerbissen, besonderes Gericht / übertragen: besonderer Höhepunkt, Zugabe) — nach den Nomen 2026-11-04
  'Schmelz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zahnschmelz / Glasur, Email / Wohlklang der Stimme) — nach den Nomen 2026-11-04
  'Schmerz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: körperlicher Schmerz / seelischer Schmerz, Kummer; meist Plural «Schmerzen») — nach den Nomen 2026-11-04
  'Schmerzgrenze', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Grenze, ab der man Schmerz spürt / übertragen: Grenze des Erträglichen, z. B. beim Preis) — nach den Nomen 2026-11-04
  'Schmuck', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schmuckstücke (Ringe, Ketten) / Verzierung, Dekoration (Weihnachtsschmuck)) — nach den Nomen 2026-11-04
  'Schnabel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vogelschnabel / ugs.: Mund («Halt den Schnabel!») / Ausguss einer Kanne) — nach den Nomen 2026-11-04
  'Schnauze', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tiermaul / derb: Mund («die Schnauze voll haben») / ugs.: Vorderteil von Auto, Flugzeug) — nach den Nomen 2026-11-04
  'Schnecke', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tier / Gebäck (Zimtschnecke) / Gehörschnecke im Ohr) — nach den Nomen 2026-11-04
  'Schneewittchen', // zurückgestellt: Name einer Märchenfigur (Personenname) — keine Eigennamen-Karte nach Regel 18 — Regel 14 — 2026-11-04
  'Schneid', // zurückgestellt: Artikel doppelt (der Schneid, bayr./österr. die Schneid), umgangssprachlich — Regel 14 — 2026-11-04
  'Schneise', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Waldschneise / Flugschneise / übertragen: «eine Schneise schlagen») — nach den Nomen 2026-11-04
  'Schneller', // zurückgestellt: Bedeutung unsicher (landschaftlich: Murmel, Schnipser; sonst Komparativ «schneller») — Regel 14 — Regel 14 — 2026-11-04
  'Schnellschuss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: schneller Schuss / ugs.: übereilte Entscheidung, Schnellprodukt) — nach den Nomen 2026-11-04
  'Schnellverfahren', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Recht: beschleunigtes Strafverfahren / allgemein: schnelle Methode) — nach den Nomen 2026-11-04
  'Schnickschnack', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: überflüssiges Beiwerk, wertloses Zeug / ugs.: dummes Gerede) — nach den Nomen 2026-11-04
  'Schnitt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schnittwunde / Haarschnitt / Durchschnitt («im Schnitt») / Filmschnitt / Schnittmuster) — nach den Nomen 2026-11-04
  'Schnitte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Brotscheibe, belegtes Brot / österr.: Waffel / ugs.: attraktive Frau) — nach den Nomen 2026-11-04
  'Schnitzel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2/3 (Homograph: das Schnitzel (Fleisch) / das/der Schnitzel (Papierschnitzel, Stückchen)) — nach den Nomen 2026-11-04
  'Schnitzer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Holzschnitzer / ugs.: Fehler, Patzer) — nach den Nomen 2026-11-04
  'Schober', // zurückgestellt: landschaftlich (Heuhaufen, Feldscheune) bzw. Familienname, Gebrauch unsicher — Regel 14 — 2026-11-04
  'Scholle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fisch (Plattfisch) / Eisscholle / Erdscholle / gehoben: Heimatboden) — nach den Nomen 2026-11-04
  'Schonung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: rücksichtsvolle Behandlung / Erholung / junger, eingezäunter Wald) — nach den Nomen 2026-11-04
  'Schotter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Steinchen, Kies / ugs.: Geld) — nach den Nomen 2026-11-04
  'Schranke', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bahnschranke, Schlagbaum / übertragen: Grenze («in Schranken weisen»)); österr. auch «der Schranken» — nach den Nomen 2026-11-04
  'Schranz', // zurückgestellt: Bedeutung unsicher (Familienname; Musikrichtung «Schranz») — Regel 14 — Regel 14 — 2026-11-04
  'Schraube', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Befestigungsschraube / Schiffsschraube, Propeller / ugs.: «eine Schraube locker haben») — nach den Nomen 2026-11-04
  'Schreiben', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Schreiben = Brief, Schriftstück / Tätigkeit des Schreibens (nominalisiertes Verb)) — nach den Nomen 2026-11-04
  'Schreiber', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verfasser / Schriftführer, Kanzlist / ugs.: Stift zum Schreiben) — nach den Nomen 2026-11-04
  'Schreibweise', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rechtschreibung eines Wortes / Stil eines Autors) — nach den Nomen 2026-11-04
  'Schreier', // zurückgestellt: umgangssprachlich (Schreihals) bzw. Familienname, Gebrauch unsicher — Regel 14 — 2026-11-04
  'Schrift', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Handschrift / Schriftsystem, Schriftart / Schriften = Werke, Publikationen) — nach den Nomen 2026-11-04
  'Schritt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schritt beim Gehen / Maßnahme («der nächste Schritt») / Schritttempo / Schritt der Hose) — nach den Nomen 2026-11-04
  'Schrittmacher', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Herzschrittmacher (Medizin) / Tempomacher im Sport / übertragen: Vorreiter) — nach den Nomen 2026-11-04
  'Schrott', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Altmetall / ugs.: wertloses Zeug, Unsinn) — nach den Nomen 2026-11-04
  'Schub', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Antriebskraft (Physik, Rakete) / Krankheitsschub / Gruppe, Ladung («ein Schub Gäste»)) — nach den Nomen 2026-11-04
  'Schuld', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verantwortung für Fehler («Schuld haben») / Geldschuld (meist Plural «Schulden»)) — nach den Nomen 2026-11-04
  'Schulgemeinde', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gemeinschaft von Schülern, Eltern, Lehrern / schweiz.: kommunaler Schulbezirk mit eigener Verwaltung) — nach den Nomen 2026-11-04
  'Schulrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schulaufsichtsbeamter (Person) / Gremium, Schulbehörde (bes. schweiz.)) — nach den Nomen 2026-11-04
  'Schulze', // zurückgestellt: Familienname bzw. veraltet für Dorfvorsteher (Schultheiß) — Regel 14 — Regel 14 — 2026-11-04
  'Schuppen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gartenschuppen (Hütte) / Plural von «die Schuppe» (Fisch-, Kopfschuppen) / ugs.: Lokal, Disco) — nach den Nomen 2026-11-04
  'Schuss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schuss aus einer Waffe / Torschuss / kleine Menge («ein Schuss Milch») / «in Schuss» (in Ordnung)) — nach den Nomen 2026-11-04
  'Schutztruppe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Truppe zum Schutz einer Bevölkerung, z. B. UN-Schutztruppe / historisch: Kolonialtruppe des Deutschen Reichs) — nach den Nomen 2026-11-04
  'Schwachsinn', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. abwertend: Unsinn / Medizin veraltet: Intelligenzminderung — zudem abwertend) — nach den Nomen 2026-11-04
  'Schwaiger', // zurückgestellt: Bedeutung unsicher (bairisch: Senner, Viehwirt; sonst Familienname) — Regel 14 — 2026-11-04
  'Schwalbe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vogel / Fußball: vorgetäuschtes Foul) — nach den Nomen 2026-11-04
  'Schwamm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Putz-/Badeschwamm / süddt./österr.: Pilz / Hausschwamm (Holzfäule) / Meerestier) — nach den Nomen 2026-11-04
  'Schwangere', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: die Schwangere / eine Schwangere) — nach den Nomen 2026-11-04
  'Schwanz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schwanz eines Tieres / Ende, Schluss einer Reihe / vulgär: Penis) — nach den Nomen 2026-11-04
  'Schwarm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gruppe von Tieren (Vögel, Fische, Bienen) / ugs.: heimlich verehrte Person) — nach den Nomen 2026-11-04
  'Schwarzafrikaner', // zurückgestellt: Bezeichnung wird teils als diskriminierend empfunden; Bewertung unsicher — Regel 14 — 2026-11-04
  'Schwarzer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der Schwarze / ein Schwarzer; zudem österr.: «ein kleiner Schwarzer» = Mokka) — nach den Nomen 2026-11-04
  'Schwebe', // zurückgestellt: fast nur in der festen Wendung «in der Schwebe» — Regel 14 — 2026-11-04
  'Schweiger', // zurückgestellt: selten (nur «der große Schweiger») bzw. Familienname — Regel 14 — 2026-11-04
  'Schwein', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tier / Schimpfwort für Menschen / ugs. «Schwein haben» = Glück haben) — nach den Nomen 2026-11-04
  'Schweinchen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kleines Schwein / Kindersprache: schmutziges Kind; vgl. Meerschweinchen) — nach den Nomen 2026-11-04
  'Schweinerei', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. Schmutz, Unordnung / Gemeinheit, Skandal / Zote) — nach den Nomen 2026-11-04
  'Schwelle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Türschwelle / Grenzwert («Schwelle zu») / Eisenbahnschwelle) — nach den Nomen 2026-11-04
  'Schwere', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gewicht, Schwerkraft / Schwere eines Verbrechens, einer Krankheit / Schwierigkeit) — nach den Nomen 2026-11-04
  'Schwergewicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gewichtsklasse im Sport / Person in dieser Klasse / übertragen: wichtige Person, Hauptgewicht) — nach den Nomen 2026-11-04
  'Schwerpunkt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Physik: Massenmittelpunkt / Hauptgewicht, Fokus («Schwerpunkt auf»)) — nach den Nomen 2026-11-04
  'Schwerverletzter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Schwerverletzte / ein Schwerverletzter) — nach den Nomen 2026-11-04
  'Schwester', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschwister / Krankenschwester, Pflegerin / Ordensschwester) — nach den Nomen 2026-11-04
  'Schwimmer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Person, die schwimmt / Technik: Schwimmkörper (Vergaser, Spülkasten) / Angeln: Pose) — nach den Nomen 2026-11-04
  'Schwindel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gleichgewichtsstörung (Medizin) / Betrug, Lüge) — nach den Nomen 2026-11-04
  'Schwinge', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: gehoben: Flügel / landschaftlich: flacher Korb / Technik: Schwingarm) — nach den Nomen 2026-11-04
  'Schwinger', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Boxen: Schlag mit gestrecktem Arm / schweiz.: Ringer beim Schwingen) — nach den Nomen 2026-11-04
  'Schwitze', // zurückgestellt: selten; meist «Mehlschwitze» (Küche) — Regel 14 — 2026-11-04
  'Schwund', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abnahme, Verlust / Warenverlust (Handel) / Medizin: Muskelschwund, Atrophie) — nach den Nomen 2026-11-04
  'Schwung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bewegung, Schwungkraft / Elan, Begeisterung / ugs.: Menge («ein Schwung Bücher»)) — nach den Nomen 2026-11-04
  'Scientologe', // zurückgestellt: Mitglied einer bestimmten Organisation (Organisationsname, Regel 18) — Regel 14 — 2026-11-04
  'Scientology', // zurückgestellt: Name einer Organisation (Regel 18) — Regel 14 — 2026-11-04
  'Scout', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pfadfinder / Talentsucher im Sport, in der Mode) — nach den Nomen 2026-11-04
  'Screen', // zurückgestellt: Anglizismus (Bildschirm, Jargon); Gebrauch als Lernwort unsicher — Regel 14 — 2026-11-04
  'Sechs', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ziffer 6 / Schulnote «ungenügend» (Deutschland) / Linie 6) — nach den Nomen 2026-11-04
  'Sechser', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. Ziffer 6 / sechs Richtige im Lotto / Schulnote / Buslinie) — nach den Nomen 2026-11-04
  'Sechszylinder', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Motor mit sechs Zylindern / Auto mit diesem Motor) — nach den Nomen 2026-11-04
  'Seebad', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Badeort an der See / Bad im Meer) — nach den Nomen 2026-11-04
  'Seele', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Seele, Psyche / Mensch («keine Seele») / Herz, Mittelpunkt («die Seele des Vereins»)) — nach den Nomen 2026-11-04
  'Segen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: religiöser Segen / ugs.: Zustimmung («seinen Segen geben») / Glück, Wohltat («ein Segen»)) — nach den Nomen 2026-11-04
  'Segler', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Person, die segelt / Segelflugzeug, Segelschiff / Vogel (Mauersegler)) — nach den Nomen 2026-11-04
  'Segnung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Segnen / meist Plural, oft ironisch: Vorzüge («die Segnungen der Technik»)) — nach den Nomen 2026-11-04
  'Seher', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Prophet, Wahrsager / Jägersprache: Auge des Wildes) — nach den Nomen 2026-11-04
  'Sehne', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anatomie: Sehne / Bogensehne / Geometrie: Verbindungsstrecke) — nach den Nomen 2026-11-04
  'Seidel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bierglas / österr.: Maß, 0,3 Liter Bier / veraltetes Flüssigkeitsmaß) — nach den Nomen 2026-11-04
  'Seifenblase', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Blase aus Seifenwasser / übertragen: Illusion, die schnell platzt) — nach den Nomen 2026-11-04
  'Seilschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bergsteiger am selben Seil / abwertend: Gruppe, die sich gegenseitig Vorteile verschafft) — nach den Nomen 2026-11-04
  'Seite', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Seite eines Körpers, Raums / Buchseite / Partei, Standpunkt («auf meiner Seite»)) — nach den Nomen 2026-11-04
  'Seitenhieb', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fechten: seitlicher Hieb / übertragen: spitze Bemerkung) — nach den Nomen 2026-11-04
  'Seitenlinie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: Spielfeldbegrenzung / Nebenlinie einer Familie / Nebenstrecke der Bahn) — nach den Nomen 2026-11-04
  'Seitenwechsel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: Wechsel der Spielfeldhälfte / Wechsel zur Gegenpartei) — nach den Nomen 2026-11-04
  'Sektion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abteilung, Bereich / Medizin: Leichenöffnung, Obduktion) — nach den Nomen 2026-11-04
  'Sektor', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bereich (Wirtschaftssektor) / Geometrie: Kreisausschnitt / Besatzungssektor (Berlin, Wien)) — nach den Nomen 2026-11-04
  'Sekundenschnelle', // zurückgestellt: nur in der festen Wendung «in Sekundenschnelle» — Regel 14 — 2026-11-04
  'Selbstbewusstsein', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Selbstvertrauen / Philosophie: Bewusstsein von sich selbst) — nach den Nomen 2026-11-04
  'Selbstkontrolle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beherrschung der eigenen Gefühle / Kontrolle einer Branche durch sich selbst («freiwillige Selbstkontrolle»)) — nach den Nomen 2026-11-04
  'Selektion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Auswahl / Biologie: natürliche Auslese / historisch: Selektion in NS-Lagern) — nach den Nomen 2026-11-04
  'Seltenheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: seltenes Vorkommen / seltener Gegenstand, Rarität) — nach den Nomen 2026-11-04
  'Semester', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Studienhalbjahr / ugs.: Student im … Semester; «ein älteres Semester» = älterer Mensch) — nach den Nomen 2026-11-04
  'Seminar', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lehrveranstaltung, Kurs / Universitätsinstitut / Priesterseminar) — nach den Nomen 2026-11-04
  'Senat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Parlamentskammer / Landesregierung in Berlin, Hamburg, Bremen / Richterkollegium / Universitätsgremium) — nach den Nomen 2026-11-04
  'Send', // zurückgestellt: Bedeutung unsicher (Name des Volksfests in Münster; veraltet: Sendgericht) — Regel 14 — 2026-11-04
  'Sender', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Radio-/Fernsehsender / technisches Gerät, Sendeanlage / Absender) — nach den Nomen 2026-11-04
  'Sendling', // zurückgestellt: Stadtteil von München bzw. veraltet für «Abgesandter» — Regel 14 — 2026-11-04
  'Sendung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Radio-/Fernsehsendung / Postsendung, Lieferung / gehoben: Auftrag, Mission) — nach den Nomen 2026-11-04
  'Senior', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: älterer Mensch / Sport: Seniorenklasse / Vater bzw. Firmengründer (im Gegensatz zu Junior)) — nach den Nomen 2026-11-04
  'Seniorin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ältere Frau / Sport: Seniorenklasse) — nach den Nomen 2026-11-04
  'Senkung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Herabsetzung (Preise, Steuern) / Absinken des Bodens / Medizin: Blutsenkung / Verslehre) — nach den Nomen 2026-11-04
  'Senn', // zurückgestellt: Plural/Deklination unsicher (-e bzw. österr. -en), regional (Alpen) — Regel 14 — 2026-11-04
  'Senna', // zurückgestellt: Bedeutung unsicher (Heilpflanze/Abführmittel bzw. Personenname) — Regel 14 — 2026-11-04
  'Sensation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: aufsehenerregendes Ereignis / Medizin, Psychologie: Empfindung) — nach den Nomen 2026-11-04
  'Sequenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abfolge, Reihe / Film: Szenenfolge / Musik: Tonfolge / Kartenspiel) — nach den Nomen 2026-11-04
  'Serge', // zurückgestellt: Artikel unsicher (die/der Serge, Stoff), selten — Regel 14 — 2026-11-04
  'Sergeant', // zurückgestellt: Aussprache und Deklination doppelt (frz. -en/-en bzw. engl. -s/-s) — Regel 14 — 2026-11-04
  'Serie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Reihe, Folge / Fernsehserie / Produktionsserie) — nach den Nomen 2026-11-04
  'Serra', // zurückgestellt: Bedeutung unsicher (Name/Gebirgsbezeichnung, kein gebräuchliches Nomen) — Regel 14 — 2026-11-04
  'Serum', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Blutserum / Impfserum, Gegengift); Plural Seren/Sera — nach den Nomen 2026-11-04
  'Sessel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Polstersessel / österr.: Stuhl) — nach den Nomen 2026-11-04
  'Sex', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschlechtsverkehr / Sexualität / Sex-Appeal) — nach den Nomen 2026-11-04
  'Sextett', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musikstück für sechs Stimmen / Gruppe von sechs Musikern) — nach den Nomen 2026-11-04
  'Show', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Unterhaltungssendung, Vorführung / ugs.: Getue («eine Show abziehen»)) — nach den Nomen 2026-11-04
  'Shuttle', // zurückgestellt: Artikel doppelt (der/das Shuttle) — Regel 14 — 2026-11-04
  'Sichel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Werkzeug / Mondsichel) — nach den Nomen 2026-11-04
  'Sicherheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schutz vor Gefahr / Gewissheit / Bürgschaft, Pfand (Kredit)) — nach den Nomen 2026-11-04
  'Sicherheitsfrage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Frage der Sicherheit / Kontrollfrage beim Passwort) — nach den Nomen 2026-11-04
  'Sicherstellung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beschlagnahme durch die Polizei / Gewährleistung) — nach den Nomen 2026-11-04
  'Sicherung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: elektrische Sicherung / Schutz, Absicherung / Datensicherung / Sicherung an der Waffe) — nach den Nomen 2026-11-04
  'Sicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sichtweite, Aussicht / Sichtweise («aus meiner Sicht») / Zeitraum («auf lange Sicht»)) — nach den Nomen 2026-11-04
  'Sichtung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erblicken (eines Tieres, UFOs) / prüfendes Durchsehen von Unterlagen) — nach den Nomen 2026-11-04
  'Sieben', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2 (Homograph: die Sieben «Ziffer, Note, Linie» / das Sieben «Sieben von Mehl») — nach den Nomen 2026-11-04
  'Siedlung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wohnsiedlung am Stadtrand / Niederlassung, Ansiedlung) — nach den Nomen 2026-11-04
  'Siegeszug', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zug der Sieger / übertragen: erfolgreiche Verbreitung («Siegeszug des Smartphones»)) — nach den Nomen 2026-11-04
  'Sierra', // zurückgestellt: geografischer Namensteil (Sierra Nevada …), kein selbstständiges Nomen — Regel 14 — 2026-11-04
  'Signal', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zeichen, Hinweis / Eisenbahnsignal / Funk- und Messsignal) — nach den Nomen 2026-11-04
  'Signatur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Unterschrift, digitale Signatur / Buchsignatur in der Bibliothek / Kartenzeichen) — nach den Nomen 2026-11-04
  'Signet', // zurückgestellt: Aussprache und Plural doppelt (frz. -s bzw. -e) — Regel 14 — 2026-11-04
  'Silk', // zurückgestellt: Bedeutung unsicher (kein gebräuchliches deutsches Nomen) — Regel 14 — 2026-11-04
  'Silo', // zurückgestellt: Artikel doppelt (der/das Silo) — Regel 14 — 2026-11-04
  'Simulation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nachbildung, Computersimulation / Vortäuschung einer Krankheit) — nach den Nomen 2026-11-04
  'Sinai', // zurückgestellt: Bezug unsicher (Halbinsel bzw. Berg Sinai; Artikelgebrauch) — Regel 14 — 2026-11-04
  'Sinn', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sinnesorgan (Sehen, Hören …) / Bedeutung, Zweck / Verständnis, Gespür («Sinn für Humor»)) — nach den Nomen 2026-11-04
  'Sintflut', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: biblische Flut / übertragen: riesige Menge («eine Sintflut von Briefen»)) — nach den Nomen 2026-11-04
  'Sirene', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Warnsignal, Alarmanlage / Mythologie: Fabelwesen / Zoologie: Seekuh) — nach den Nomen 2026-11-04
  'Site', // zurückgestellt: Anglizismus (Website), Gebrauch als eigenes Nomen unsicher — Regel 14 — 2026-11-04
  'Sitte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Brauch, Gewohnheit / Plural: Moral, Anstand («gute Sitten»)) — nach den Nomen 2026-11-04
  'Sitz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sitzplatz / Firmensitz, Amtssitz / Sitz im Parlament / Passform der Kleidung) — nach den Nomen 2026-11-04
  'Sitzung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Versammlung, Besprechung / Behandlungstermin (Therapie) / Sitzung beim Maler) — nach den Nomen 2026-11-04
  'Sixt', // zurückgestellt: Firmenname (Regel 18) — Regel 14 — 2026-11-04
  'Skala', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Messskala / Bandbreite, Abstufung («Farbskala») / Musik: Tonleiter) — nach den Nomen 2026-11-04
  'Skat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kartenspiel / die zwei verdeckt abgelegten Karten); Plural -e/-s — nach den Nomen 2026-11-04
  'Skizze', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: schnelle Zeichnung / Entwurf, kurze Darstellung eines Textes) — nach den Nomen 2026-11-04
  'Skorpion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tier / Sternzeichen) — nach den Nomen 2026-11-04
  'Skript', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorlesungsskript / Drehbuch / Computerskript); Plural -s/-en — nach den Nomen 2026-11-04
  'Slip', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Unterhose / Seemannssprache: Slipanlage für Schiffe) — nach den Nomen 2026-11-04
  'Snow', // zurückgestellt: kein selbstständiges deutsches Nomen (nur in Zusammensetzungen) — Regel 14 — 2026-11-04
  'Soccer', // zurückgestellt: Anglizismus, im Deutschen kaum gebräuchlich — Regel 14 — 2026-11-04
  'Society', // zurückgestellt: Anglizismus (High Society); Gebrauch als Lernwort unsicher — Regel 14 — 2026-11-04
  'Sockel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Unterbau einer Statue, eines Hauses / Lampenfassung / Grundbetrag («Sockelbetrag»)) — nach den Nomen 2026-11-04
  'Socken', // zurückgestellt: Lemma/Artikel doppelt (die Socke / der Socken, österr. der Socken) — Regel 14 — 2026-11-04
  'Sog', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: saugende Strömung / übertragen: Anziehungskraft («in den Sog geraten»)) — nach den Nomen 2026-11-04
  'Sohle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fuß-/Schuhsohle / Boden eines Tals, Flusses («Talsohle») / Bergbau: Stollenboden) — nach den Nomen 2026-11-04
  'Soja', // zurückgestellt: Artikel unsicher (die/das Soja) — Regel 14 — 2026-11-04
  'Solo', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musik: Solopartie / Sport: Alleingang / Kartenspiel); Plural -s/Soli — nach den Nomen 2026-11-04
  'Sommernachtstraum', // zurückgestellt: Werktitel (Shakespeare «Ein Sommernachtstraum»), kein allgemeines Nomen — Regel 14 — 2026-11-04
  'Sommertheater', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Theateraufführung im Sommer / übertragen: politisches Gezänk in der Sommerpause) — nach den Nomen 2026-11-04
  'Sommerzeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Jahreszeit Sommer / Uhrzeitumstellung, MESZ) — nach den Nomen 2026-11-04
  'Sonde', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Medizin: Schlauch, Magensonde / Raumsonde / Messsonde) — nach den Nomen 2026-11-04
  'Sonderausgabe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: besondere Ausgabe einer Zeitung, eines Buches / Steuerrecht: Sonderausgaben (absetzbare Kosten)) — nach den Nomen 2026-11-04
  'Sonderbeauftragter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Partizip: der/die Sonderbeauftragte, ein Sonderbeauftragter) — nach den Nomen 2026-11-04
  'Sondergesandte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Partizip: der/die Sondergesandte) — nach den Nomen 2026-11-04
  'Sonderklasse', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: besondere Qualitätsstufe («der Sonderklasse») / österr. Krankenhaus: Privatstation / Schule: Sonderklasse) — nach den Nomen 2026-11-04
  'Sonderpreis', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ermäßigter Preis / besondere Auszeichnung, Preis einer Jury) — nach den Nomen 2026-11-04
  'Sonnenschein', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Licht der Sonne / ugs. Kosewort für einen geliebten Menschen, «mein Sonnenschein») — nach den Nomen 2026-11-04
  'Sopran', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: hohe Stimmlage / Sängerin mit dieser Stimme / Stimmgruppe im Chor) — nach den Nomen 2026-11-04
  'Sorge', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kummer, Besorgnis / Fürsorge, Bemühen um jmdn. («für etw. Sorge tragen»)) — nach den Nomen 2026-11-04
  'Sorgenkind', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kind, um das man sich sorgt / übertragen: Problembereich («Sorgenkind der Firma»)) — nach den Nomen 2026-11-04
  'Sowjet', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rat (Organ) in der Sowjetunion / Plural ugs.: «die Sowjets» = die Sowjetunion, ihre Führung) — nach den Nomen 2026-11-04
  'Spaghetti', // zurückgestellt: Pluraletantum (die Spaghetti); Artikel der Liste (der) passt nicht, Kartenform unklar — Regel 14 — 2026-11-04
  'Spalier', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gitter für Pflanzen / Reihe von Menschen («Spalier stehen»)) — nach den Nomen 2026-11-04
  'Spalte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Riss, Felsspalte / Textspalte, Tabellenspalte) — nach den Nomen 2026-11-04
  'Spaltung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spalten (Holz, Kernspaltung) / Teilung einer Gruppe, Partei, Gesellschaft) — nach den Nomen 2026-11-04
  'Spanne', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zeitspanne / Preis-, Handelsspanne / Handspanne (Maß)) — nach den Nomen 2026-11-04
  'Spanner', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gerät zum Spannen (Schuhspanner) / ugs. abwertend: Voyeur / Schmetterling (Zoologie)) — nach den Nomen 2026-11-04
  'Spannung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Neugier, Nervenkitzel / Konflikt, gespannte Lage / Elektrotechnik: elektrische Spannung) — nach den Nomen 2026-11-04
  'Spannweite', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Flügelspannweite / Weite einer Brücke / übertragen: Bandbreite) — nach den Nomen 2026-11-04
  'Sparte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschäftsbereich, Branche, Fachgebiet / Rubrik einer Zeitung) — nach den Nomen 2026-11-04
  'Spatz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vogel (Sperling) / ugs. Kosewort für ein Kind); Deklination schwankend — nach den Nomen 2026-11-04
  'Speerspitze', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spitze eines Speers / übertragen: Vorreiter, Spitze einer Bewegung) — nach den Nomen 2026-11-04
  'Speicher', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Dachboden / Lagerhaus, Silo / Datenspeicher, Energiespeicher) — nach den Nomen 2026-11-04
  'Speise', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gericht, Essen / landschaftlich: Mörtel (Bau)) — nach den Nomen 2026-11-04
  'Spektrum', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Physik: Farbspektrum / übertragen: Bandbreite, Vielfalt) — nach den Nomen 2026-11-04
  'Spekulation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vermutung ohne Beweis / Finanzgeschäft mit Kursgewinnen) — nach den Nomen 2026-11-04
  'Spender', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Person, die Geld spendet / Blut-, Organspender / Gerät: Seifen-, Handtuchspender) — nach den Nomen 2026-11-04
  'Spider', // zurückgestellt: Anglizismus (Roadster, offener Sportwagen), Gebrauch als Lernwort unsicher — Regel 14 — 2026-11-04
  'Sperre', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Absperrung, Schranke / Sport: Spielsperre / Blockierung (Handy-, Kontosperre)) — nach den Nomen 2026-11-04
  'Sperrung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schließen einer Straße / Blockieren eines Kontos, einer Karte) — nach den Nomen 2026-11-04
  'Spezies', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Biologie: Art / ugs. scherzhaft: Sorte Mensch) — nach den Nomen 2026-11-04
  'Spezifikation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: genaue technische Beschreibung / Wirtschaft: Aufstellung, Liste / Logik: Einteilung) — nach den Nomen 2026-11-04
  'Spiegel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Glas, in dem man sich sieht / Höhe, Konzentration (Wasser-, Blutzuckerspiegel) / Revers am Anzug) — nach den Nomen 2026-11-04
  'Spiegelung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Reflexion von Licht / Medizin: Endoskopie (Magenspiegelung)) — nach den Nomen 2026-11-04
  'Spiel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spielen, Game / Wettkampf, Match / Technik: Spielraum zwischen Teilen) — nach den Nomen 2026-11-04
  'Spielart', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Art zu spielen / Variante, Abart) — nach den Nomen 2026-11-04
  'Spielball', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ball zum Spielen / übertragen: jemand, der anderen ausgeliefert ist) — nach den Nomen 2026-11-04
  'Spieler', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Teilnehmer an einem Spiel, Sportler / Glücksspieler) — nach den Nomen 2026-11-04
  'Spielerei', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: dauerndes Spielen / leichte Sache, Kleinigkeit / überflüssiges Zubehör, Gadget) — nach den Nomen 2026-11-04
  'Spielerin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Teilnehmerin an einem Spiel, Sportlerin / Glücksspielerin) — nach den Nomen 2026-11-04
  'Spielgemeinschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tippgemeinschaft beim Lotto / Sport: Zusammenschluss von Vereinen) — nach den Nomen 2026-11-04
  'Spielleiter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Leiter eines Spiels, Quizmaster / Theater: Regisseur) — nach den Nomen 2026-11-04
  'Spielplan', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Programm eines Theaters / Sport: Terminplan der Spiele / Brett eines Brettspiels) — nach den Nomen 2026-11-04
  'Spielraum', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Freiraum, Handlungsspielraum / Technik: Spiel zwischen Teilen) — nach den Nomen 2026-11-04
  'Spielwiese', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wiese zum Spielen / übertragen: Feld zum Ausprobieren) — nach den Nomen 2026-11-04
  'Spielzeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Saison (Theater, Sport) / Dauer eines Spiels, Films) — nach den Nomen 2026-11-04
  'Spike', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Metallstift an Sohle oder Reifen / Laufschuh mit Spikes) — nach den Nomen 2026-11-04
  'Spin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Physik: Eigendrehimpuls / Sport: Drall eines Balls / Politik: gezielte Deutung, Spin) — nach den Nomen 2026-11-04
  'Spinner', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. verrückter Mensch / Arbeiter in einer Spinnerei / Angeln: Köder) — nach den Nomen 2026-11-04
  'Spinnerei', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fabrik zum Spinnen von Garn / ugs. verrückte Idee) — nach den Nomen 2026-11-04
  'Spion', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Agent, der spioniert / Guckloch in der Tür) — nach den Nomen 2026-11-04
  'Spirale', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schraubenlinie, Spirale / Verhütungsmittel (Spirale) / übertragen: Preis-, Gewaltspirale) — nach den Nomen 2026-11-04
  'Spirit', // zurückgestellt: Anglizismus (Geist, Schwung), Gebrauch und Genus als Lernwort unsicher — Regel 14 — 2026-11-04
  'Spitz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hunderasse / ugs. leichter Rausch / spitzes Ende) — nach den Nomen 2026-11-04
  'Spitze', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: spitzes Ende, Gipfel / Führung, Spitzenposition / Gewebe aus Garn (Klöppelspitze) / ugs. Spitze! = toll) — nach den Nomen 2026-11-04
  'Spitzenzeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zeit der stärksten Belastung, Stoßzeit / Sport: Bestzeit) — nach den Nomen 2026-11-04
  'Sporn', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Reiten: Metallbügel am Stiefel / Medizin: Knochenauswuchs (Fersensporn) / Botanik, Zoologie: spitzer Fortsatz) — nach den Nomen 2026-11-04
  'Sport', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: körperliche Betätigung, Sportart, Schulfach / Liebhaberei, Hobby («sich einen Sport daraus machen»)) — nach den Nomen 2026-11-04
  'Sportfreund', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anhänger des Sports / Sportkamerad, auch Anrede) — nach den Nomen 2026-11-04
  'Sporthilfe', // zurückgestellt: meist Name der Stiftung Deutsche Sporthilfe (Organisation, Regel 18); als allgemeines Lernwort unsicher — Regel 14 — 2026-11-04
  'Sportschule', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausbildungsstätte für Trainer und Sportlehrer, Lehrgangszentrum / Schule mit Sportschwerpunkt) — nach den Nomen 2026-11-04
  'Sportstudio', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fitnessstudio / Fernsehstudio für Sportsendungen) — nach den Nomen 2026-11-04
  'Sportwagen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: schnelles Auto / Kinderwagen zum Sitzen, Buggy) — nach den Nomen 2026-11-04
  'Spot', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Werbespot / Scheinwerfer, Spotlight / ugs. Ort, Platz (Surfspot)) — nach den Nomen 2026-11-04
  'Sprache', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sprache eines Volkes, Deutsch, Persisch / Fähigkeit zu sprechen / Ausdrucksweise, Stil) — nach den Nomen 2026-11-04
  'Sprachlosigkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sprachlossein vor Staunen / Unfähigkeit, miteinander zu reden) — nach den Nomen 2026-11-04
  'Sprachrohr', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Megafon, Schalltrichter / übertragen: Person, die die Meinung anderer vertritt) — nach den Nomen 2026-11-04
  'Spray', // zurückgestellt: Artikel doppelt (das/der Spray) — Regel 14 — 2026-11-04
  'Sprechchor', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: gemeinsames Rufen einer Menge / Gruppe, die im Chor spricht (Theater)) — nach den Nomen 2026-11-04
  'Sprecher', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pressesprecher, Wortführer / Nachrichtensprecher, Synchronsprecher / Linguistik: wer spricht) — nach den Nomen 2026-11-04
  'Sprecherin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pressesprecherin, Wortführerin / Nachrichtensprecherin, Synchronsprecherin) — nach den Nomen 2026-11-04
  'Sprengel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kirchspiel, Pfarrbezirk / österr. Amts-, Schulbezirk) — nach den Nomen 2026-11-04
  'Sprenger', // zurückgestellt: Bedeutung unsicher (Rasensprenger / Person, die sprengt) — Regel 14 — 2026-11-04
  'Sprengkraft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wirkung einer Explosion / übertragen: Konfliktpotenzial) — nach den Nomen 2026-11-04
  'Sprengstoff', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: explosiver Stoff / übertragen: brisantes Thema, Zündstoff) — nach den Nomen 2026-11-04
  'Springen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Springen als Tätigkeit / Sport: Wettbewerb (Skispringen)) — nach den Nomen 2026-11-04
  'Springer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sportler, der springt / Schach: Pferd, Springer / Arbeit: Aushilfskraft für wechselnde Stellen) — nach den Nomen 2026-11-04
  'Sprint', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kurzstreckenlauf, Spurt / Projektarbeit (IT): kurzer Arbeitszyklus) — nach den Nomen 2026-11-04
  'Sprinter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kurzstreckenläufer / Kleintransporter (Markenname)) — nach den Nomen 2026-11-04
  'Sprit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ugs. Treibstoff, Benzin / ugs. Alkohol, Schnaps) — nach den Nomen 2026-11-04
  'Spritze', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Injektion, Spritze beim Arzt / Gerät zum Spritzen (Feuerwehrspritze, Spritzbeutel)) — nach den Nomen 2026-11-04
  'Spross', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pflanzentrieb / Nachkomme, Sohn) — nach den Nomen 2026-11-04
  'Spruch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Satz, Spruch, Motto / Urteil (Schiedsspruch, Richterspruch)) — nach den Nomen 2026-11-04
  'Sprung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Springen, Satz / Riss in Glas oder Porzellan) — nach den Nomen 2026-11-04
  'Sprungbrett', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Brett zum Springen (Schwimmbad, Turnen) / übertragen: Ausgangspunkt für Karriere) — nach den Nomen 2026-11-04
  'Spuk', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geistererscheinung / ugs. abwertend: Lärm, Unfug) — nach den Nomen 2026-11-04
  'Spur', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abdruck, Spur / Fahrspur / sehr kleine Menge (eine Spur Salz)) — nach den Nomen 2026-11-04
  'Sputnik', // zurückgestellt: Eigenname (Satellit), kein geografischer Name — Regel 18 — 2026-11-04
  'Staat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Land als politische Einheit / Bundesstaat, Gliedstaat (USA) / veraltend: Prunk, festliche Kleidung («Staat machen»)) — nach den Nomen 2026-11-04
  'Staatsamt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: öffentliches Amt im Staat / österr. historisch: Ministerium 1918–1920) — nach den Nomen 2026-11-04
  'Staatsduma', // zurückgestellt: Eigenname (Parlament Russlands), kein geografischer Name — Regel 18 — 2026-11-04
  'Staatsgewalt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Herrschaftsgewalt des Staates / eine der drei Gewalten (Legislative, Exekutive, Judikative)) — nach den Nomen 2026-11-04
  'Staatsliga', // zurückgestellt: österr. Bezeichnung einer Sportliga je Sportart, Gebrauch als Lernwort unsicher — Regel 14 — 2026-11-04
  'Staatsminister', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Minister eines Landes (Bayern, Sachsen) / Bund: Staatssekretär mit Titel Staatsminister) — nach den Nomen 2026-11-04
  'Staatspolizei', // zurückgestellt: Bedeutung je Land/Zeit unterschiedlich (österr. Verfassungsschutz / historisch politische Polizei) — Regel 14 — 2026-11-04
  'Staatsrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gremium, Regierungsorgan / Mitglied, Titel) — nach den Nomen 2026-11-04
  'Staatsschutz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schutz des Staates / polizeiliche Abteilung für politische Straftaten) — nach den Nomen 2026-11-05
  'Staatssicherheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sicherheit des Staates allgemein / DDR: Kurzform für Staatssicherheitsdienst, die Stasi) — nach den Nomen 2026-11-05
  'Staatssicherheitsdienst', // zurückgestellt: Eigenname (Geheimdienst der DDR), kein geografischer Name — Regel 18 — 2026-11-05
  'Staatsvertrag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: völkerrechtlicher Vertrag zwischen Staaten / Vertrag zwischen Bundesländern / österr.: Staatsvertrag von 1955) — nach den Nomen 2026-11-05
  'Stab', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stock, Stange / Gruppe von Offizieren oder Beratern einer Leitung) — nach den Nomen 2026-11-05
  'Stachel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Dorn einer Pflanze / Giftstachel eines Insekts / Spitze am Draht; übertragen: etwas Kränkendes) — nach den Nomen 2026-11-05
  'Stadthaus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verwaltungsgebäude einer Stadt / Wohnhaus in der Stadt, Townhouse) — nach den Nomen 2026-11-05
  'Stadtrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gremium der Stadtverwaltung / Mitglied dieses Gremiums) — nach den Nomen 2026-11-05
  'Stadtrecht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: historisch: Recht einer Siedlung, Stadt zu sein / für eine Stadt geltendes Recht) — nach den Nomen 2026-11-05
  'Stadtsenat', // zurückgestellt: Bedeutung je Land unterschiedlich (österr. Kollegialorgan der Stadtregierung / Senat einer Stadt in DE) — Regel 14 — 2026-11-05
  'Stadtverordnete', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Partizip: der/die Stadtverordnete, ein Stadtverordneter) — nach den Nomen 2026-11-05
  'Stadtverordneter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Partizip: der/die Stadtverordnete, ein Stadtverordneter) — nach den Nomen 2026-11-05
  'Staffel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Staffellauf im Sport / Folge einer Fernsehserie / Einheit der Luftwaffe) — nach den Nomen 2026-11-05
  'Stamm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Baumstamm / Volksstamm / Wortstamm / feste Gruppe, z. B. Stammkunden) — nach den Nomen 2026-11-05
  'Stammbuch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Familienstammbuch / historisch: Album für Erinnerungsverse) — nach den Nomen 2026-11-05
  'Stammhaus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: erstes Geschäftshaus einer Firma / Herkunftshaus eines Adelsgeschlechts) — nach den Nomen 2026-11-05
  'Stammplatz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Platz, den jemand immer einnimmt / Sport: fester Platz in der Mannschaft) — nach den Nomen 2026-11-05
  'Stammsitz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hauptsitz einer Firma / Herkunftsort einer Familie oder eines Adelsgeschlechts) — nach den Nomen 2026-11-05
  'Stand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Stehen / Verkaufsstand / Zustand, Niveau / gesellschaftliche Schicht) — nach den Nomen 2026-11-05
  'Standbein', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bein, auf dem man steht / übertragen: wirtschaftliche Grundlage) — nach den Nomen 2026-11-05
  'Standbild', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Statue / angehaltenes Bild bei Film oder Video) — nach den Nomen 2026-11-05
  'Stande', // zurückgestellt: Bedeutung unsicher (landschaftlich «Bottich» oder nur Form von «Stand») — Regel 14 — 2026-11-05
  'Standesbeamter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Standesbeamte, ein Standesbeamter) — nach den Nomen 2026-11-05
  'Standfestigkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stabilität eines Gegenstands / übertragen: Charakterfestigkeit) — nach den Nomen 2026-11-05
  'Standortbestimmung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bestimmung der eigenen Position (Navigation) / übertragen: Klärung der eigenen Lage) — nach den Nomen 2026-11-05
  'Stange', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stab, Stange / Stange Zigaretten / «eine Stange Geld») — nach den Nomen 2026-11-05
  'Stapel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Haufen, Stoß / Schiffbau: «vom Stapel laufen») — nach den Nomen 2026-11-05
  'Start', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beginn eines Rennens / Abflug eines Flugzeugs / Anfang allgemein) — nach den Nomen 2026-11-05
  'Starter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Teilnehmer eines Rennens / Person, die das Startsignal gibt / Anlasser beim Auto / Vorspeise) — nach den Nomen 2026-11-05
  'Startgeld', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Teilnahmegebühr / Geld, das ein Sportler fürs Antreten bekommt) — nach den Nomen 2026-11-05
  'Starthilfe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hilfe beim Anlassen eines Autos / finanzielle Hilfe für den Anfang) — nach den Nomen 2026-11-05
  'Startloch', // zurückgestellt: fast nur in der Wendung «in den Startlöchern stehen» — Regel 14 — 2026-11-05
  'Startplatz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Platz eines Teilnehmers beim Start / Ort, von dem Flugzeuge oder Raketen starten) — nach den Nomen 2026-11-05
  'Startschuss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schuss als Startsignal / übertragen: offizieller Beginn) — nach den Nomen 2026-11-05
  'Statik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Teilgebiet der Mechanik / Stabilität eines Bauwerks) — nach den Nomen 2026-11-05
  'Station', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Haltestelle / Abteilung im Krankenhaus / Stelle, Etappe / Forschungs- oder Sendestation) — nach den Nomen 2026-11-05
  'Statistik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wissenschaft / einzelne Zusammenstellung von Zahlen) — nach den Nomen 2026-11-05
  'Statt', // zurückgestellt: nur in festen Wendungen («an Kindes statt», «an Eides statt») — Regel 14 — 2026-11-05
  'Staude', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: mehrjährige Pflanze / südd., österr.: Strauch, Busch) — nach den Nomen 2026-11-05
  'Stecher', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kupferstecher / Abzugsvorrichtung bei Gewehren / derb: Liebhaber) — nach den Nomen 2026-11-05
  'Steckbrief', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fahndungsplakat / kurze Beschreibung einer Person oder Sache) — nach den Nomen 2026-11-05
  'Steckenpferd', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kinderspielzeug / übertragen: Hobby) — nach den Nomen 2026-11-05
  'Stefan', // zurückgestellt: Personenname, kein geografischer Name — Regel 18 — 2026-11-05
  'Steg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: schmale Brücke / Bootsanlegestelle / Teil eines Saiteninstruments) — nach den Nomen 2026-11-05
  'Steig', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: schmaler, steiler Weg / regional: Bahn- oder Bussteig) — nach den Nomen 2026-11-05
  'Steiger', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufsicht im Bergbau / Hubsteiger, Hebebühne) — nach den Nomen 2026-11-05
  'Steigerung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erhöhung / Grammatik: Komparation der Adjektive) — nach den Nomen 2026-11-05
  'Stein', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gestein, Stein / Obstkern / Spielstein / Edelstein) — nach den Nomen 2026-11-05
  'Steinbock', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wildtier in den Alpen / Sternzeichen) — nach den Nomen 2026-11-05
  'Steinmetz', // zurückgestellt: Deklination schwankend (des Steinmetzes/Steinmetzen, Plural Steinmetze/Steinmetzen) — Regel 14 — 2026-11-05
  'Steinwurf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wurf eines Steins / übertragen: kurze Entfernung «einen Steinwurf entfernt») — nach den Nomen 2026-11-05
  'Stelle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ort, Platz / Arbeitsstelle / Behörde, Amt / Textstelle) — nach den Nomen 2026-11-05
  'Stellenwert', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bedeutung, Wichtigkeit / Mathematik: Wert einer Ziffer nach ihrer Stelle) — nach den Nomen 2026-11-05
  'Stellung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Körperhaltung / Position im Beruf / Meinung («Stellung nehmen») / militärische Stellung) — nach den Nomen 2026-11-05
  'Stelze', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stange zum Gehen / österr.: Schweinsstelze, Eisbein) — nach den Nomen 2026-11-05
  'Stempel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gerät zum Stempeln / Abdruck, Poststempel / Teil der Blüte) — nach den Nomen 2026-11-05
  'Stengel', // zurückgestellt: alte Schreibung (heute «Stängel») — Lemma unsicher, Regel 14 — 2026-11-05
  'Step', // zurückgestellt: Bedeutung unsicher (Stepptanz / Step-Aerobic) — Regel 14 — 2026-11-05
  'Sterbe', // zurückgestellt: kein eigenständiges Wort (nur Bestimmungswort «Sterbe-») — Regel 14 — 2026-11-05
  'Sterblichkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Sterblichsein / Sterberate) — nach den Nomen 2026-11-05
  'Sternbild', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gruppe von Sternen am Himmel / umgangssprachlich: Sternzeichen) — nach den Nomen 2026-11-05
  'Sternchen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kleiner Stern / Zeichen * / junger Filmstar) — nach den Nomen 2026-11-05
  'Steuermann', // zurückgestellt: Plural schwankend (Steuerleute/Steuermänner) und Bedeutung je Bereich (Schifffahrt / Rudersport) — Regel 14 — 2026-11-05
  'Steuerung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Steuern / Steuervorrichtung, Steuerungssystem) — nach den Nomen 2026-11-05
  'Stich', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Insektenstich / Messerstich / Nähstich / Kupferstich / Kartenspiel) — nach den Nomen 2026-11-05
  'Stichwort', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen mit verschiedenem Plural: Eintrag im Wörterbuch «Stichwörter» / Einsatzwort, Notiz «Stichworte») — nach den Nomen 2026-11-05
  'Stickerei', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Sticken / gestickte Arbeit) — nach den Nomen 2026-11-05
  'Stiefkind', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kind des Ehepartners / übertragen: vernachlässigte Sache) — nach den Nomen 2026-11-05
  'Steven', // zurückgestellt: Fachwort Schiffbau (Vorder-/Achtersteven) und zugleich Vorname — Bedeutung/Gebrauch unsicher, Regel 14 — 2026-11-05
  'Stiel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Griff eines Werkzeugs / Stängel einer Pflanze / Fuß eines Glases) — nach den Nomen 2026-11-05
  'Stier', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: männliches Rind / Sternzeichen) — nach den Nomen 2026-11-05
  'Stiftung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einrichtung mit Vermögen / das Stiften, Schenkung) — nach den Nomen 2026-11-05
  'Stigma', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schandmal, Brandmal / Wundmal Christi / Biologie: Atemöffnung, Narbe) — nach den Nomen 2026-11-05
  'Stimme', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Klang beim Sprechen/Singen / Stimme bei einer Wahl / Meinung / Musik: Stimme einer Partitur) — nach den Nomen 2026-11-05
  'Stimmung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gemütslage, Atmosphäre / Musik: Stimmung eines Instruments) — nach den Nomen 2026-11-05
  'Stoff', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Substanz, Material / Gewebe, Textil / Thema, Lernstoff / ugs. Rauschgift) — nach den Nomen 2026-11-05
  'Stollen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gang im Bergwerk / Weihnachtsgebäck / Stollen am Fußballschuh) — nach den Nomen 2026-11-05
  'Stolperstein', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Hindernis / Gedenkstein für NS-Opfer) — nach den Nomen 2026-11-05
  'Stopp', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Halt, Unterbrechung / Sport: Stoppball) — nach den Nomen 2026-11-05
  'Story', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Handlung einer Geschichte / Bericht, Reportage / ugs. erfundene Geschichte) — nach den Nomen 2026-11-05
  'Stockerl', // zurückgestellt: Plural schwankend (die Stockerl / die Stockerln) — Regel 14 — 2026-11-05
  'Stolle', // zurückgestellt: Nebenform von «der Stollen» (Gebäck), Lemma unsicher — Regel 14 — 2026-11-05
  'Strafantrag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Antrag des Staatsanwalts auf eine bestimmte Strafe / Antrag des Verletzten auf Strafverfolgung) — nach den Nomen 2026-11-05
  'Straffung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Straffmachen, z. B. der Haut / übertragen: Kürzung, Vereinfachung von Abläufen) — nach den Nomen 2026-11-05
  'Strafgefangene', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv/Partizip: der/die Strafgefangene) — nach den Nomen 2026-11-05
  'Strafgericht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gericht für Strafsachen / gehoben: Bestrafung, Strafgericht Gottes) — nach den Nomen 2026-11-05
  'Strahl', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lichtstrahl / Wasserstrahl / Mathematik: Halbgerade) — nach den Nomen 2026-11-05
  'Strang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Seil, Strick / Bündel von Fäden, Nerven / Gleisstrang / Handlungsstrang) — nach den Nomen 2026-11-05
  'Strecke', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wegstück, Entfernung / Bahnstrecke / Mathematik: Strecke / Jägersprache) — nach den Nomen 2026-11-05
  'Streich', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schabernack / gehoben, veraltet: Schlag, «auf einen Streich») — nach den Nomen 2026-11-05
  'Streichen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (substantivierter Infinitiv mit mehreren Bedeutungen: Anstreichen mit Farbe / Durchstreichen, Kürzen / Streicheln) — nach den Nomen 2026-11-05
  'Streichquartett', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ensemble aus vier Streichern / Komposition für dieses Ensemble) — nach den Nomen 2026-11-05
  'Streifen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: schmales Stück, Linie / ugs. Film) — nach den Nomen 2026-11-05
  'Streiflicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: seitlich einfallendes Licht / kurze, treffende Schilderung) — nach den Nomen 2026-11-05
  'Streifzug', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wanderung, Erkundung / übertragen: kurzer Überblick) — nach den Nomen 2026-11-05
  'Streif', // zurückgestellt: Lemma unsicher: gehobene Nebenform von «der Streifen» und Name der Kitzbüheler Skiabfahrt — Regel 14 — 2026-11-05
  'Streuung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Streuen, Verteilen / Physik: Streuung von Strahlen / Statistik: Abweichung) — nach den Nomen 2026-11-05
  'Strich', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Linie / Pinselstrich, Bogenstrich / ugs. Straßenprostitution) — nach den Nomen 2026-11-05
  'Strip', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kurzform für Striptease / Comicstreifen / Pflasterstreifen) — nach den Nomen 2026-11-05
  'Strohhalm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: einzelner Halm Stroh / Trinkhalm / übertragen: letzte Hoffnung) — nach den Nomen 2026-11-05
  'Striptease', // zurückgestellt: Genus schwankt (der oder das Striptease) — Regel 14 — 2026-11-05
  'Strohmann', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: vorgeschobene Person / Strohpuppe, Vogelscheuche / Kartenspiel) — nach den Nomen 2026-11-05
  'Strom', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: elektrischer Strom / großer Fluss / Strömung, Menge «ein Strom von Menschen») — nach den Nomen 2026-11-05
  'Stromerzeuger', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Unternehmen, das Strom erzeugt / Gerät, Generator) — nach den Nomen 2026-11-05
  'Strudel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wasserwirbel / Mehlspeise, Apfelstrudel) — nach den Nomen 2026-11-05
  'Struck', // zurückgestellt: Familienname / Bedeutung als Gattungswort unsicher — Regel 14/18 — 2026-11-05
  'Stube', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wohnzimmer, Zimmer / Raum in der Kaserne) — nach den Nomen 2026-11-05
  'Studie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: wissenschaftliche Untersuchung / Kunst: Entwurf, Skizze, Übungsstück) — nach den Nomen 2026-11-05
  'Studierende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Partizip: der/die Studierende) — nach den Nomen 2026-11-05
  'Studio', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufnahme-/Fernsehstudio / Fitnessstudio / Atelier / Einzimmerwohnung) — nach den Nomen 2026-11-05
  'Stufe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Treppenstufe / Niveau, Stadium / Grammatik: Steigerungsstufe) — nach den Nomen 2026-11-05
  'Stuhl', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sitzmöbel / Medizin: Stuhlgang, Kot / «der Heilige Stuhl») — nach den Nomen 2026-11-05
  'Stunde', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: 60 Minuten / Unterrichtsstunde / Zeitpunkt, «die Stunde der Wahrheit») — nach den Nomen 2026-11-05
  'Sturz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Fallen / Absetzung einer Regierung / starkes Sinken, Kurssturz / Bau: Fenstersturz) — nach den Nomen 2026-11-05
  'Styling', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Formgebung, Design / Frisur, Make-up, Kleidung) — nach den Nomen 2026-11-05
  'Subjekt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Grammatik: Satzgegenstand / Philosophie: erkennendes Wesen / abwertend: Person) — nach den Nomen 2026-11-05
  'Substanz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stoff, Materie / das Wesentliche, Gehalt / Vermögen, «von der Substanz leben») — nach den Nomen 2026-11-05
  'Sucher', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: suchende Person / Kamera: Sucher, Bildfenster) — nach den Nomen 2026-11-05
  'Sudetendeutsche', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Sudetendeutsche) — nach den Nomen 2026-11-05
  'Suite', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zimmerflucht im Hotel / Musik: Folge von Sätzen) — nach den Nomen 2026-11-05
  'Sujet', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gegenstand künstlerischer Darstellung / österr.: Werbemotiv) — nach den Nomen 2026-11-05
  'Suff', // zurückgestellt: ugs.; Bedeutung (Trunksucht / Rausch) und Gebrauch fast nur in «im Suff» unsicher — Regel 14 — 2026-11-05
  'Summa', // zurückgestellt: nur lateinisch in festen Wendungen («in summa», «summa cum laude») — Regel 14 — 2026-11-05
  'Surfer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wellenreiter, Windsurfer / ugs.: Internetsurfer) — nach den Nomen 2026-11-05
  'Synthese', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verbindung, Zusammenführung / Chemie: Aufbau einer Verbindung / Philosophie: Synthese von These und Antithese) — nach den Nomen 2026-11-05
  'System', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ordnungsprinzip, Methode / politisches System, Regime / technisches System, Computersystem / Biologie, z. B. Nervensystem) — nach den Nomen 2026-11-05
  'Systematik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: planmäßige Ordnung, Darstellung / Biologie: Einteilung der Lebewesen) — nach den Nomen 2026-11-05
  'Szenario', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Theater/Film: Szenenfolge, Entwurf / angenommener Ablauf künftiger Ereignisse) — nach den Nomen 2026-11-05
  'Szenarium', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Theater: Szenenfolge, Regiebuch / angenommener Ablauf künftiger Ereignisse) — nach den Nomen 2026-11-05
  'Szene', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abschnitt eines Stücks/Films / Schauplatz, Vorgang / Streit, «eine Szene machen» / Milieu, z. B. Drogenszene) — nach den Nomen 2026-11-05
  'Szenerie', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bühnenbild / Landschaft, Schauplatz) — nach den Nomen 2026-11-05
  'Tabellendritte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Tabellendritte) — nach den Nomen 2026-11-05
  'Tableau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gemälde, wirkungsvolles Bild / Theater: Gruppenbild / österr.: Übersichtstafel) — nach den Nomen 2026-11-05
  'Tafel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schultafel / Tafel Schokolade / festlich gedeckter Tisch / Lebensmittelausgabe «die Tafel») — nach den Nomen 2026-11-05
  'Tageskarte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Speisekarte des Tages / Fahr- oder Eintrittskarte für einen Tag) — nach den Nomen 2026-11-05
  'Tagessatz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Strafrecht: Einheit der Geldstrafe / täglicher Betrag, Tagespauschale) — nach den Nomen 2026-11-05
  'Tagblatt', // zurückgestellt: regional (bes. schweizerisch) bzw. sonst veraltet, meist nur in Zeitungsnamen — Gebrauch/Markierung unsicher, Regel 14 — 2026-11-05
  'Talent', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Begabung / begabter Mensch, «ein junges Talent») — nach den Nomen 2026-11-05
  'Talfahrt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fahrt ins Tal / starker Rückgang, Abschwung, z. B. an der Börse) — nach den Nomen 2026-11-05
  'Tai', // zurückgestellt: Bedeutung unklar (Volk/Sprachgruppe, Bestandteil von «Tai-Chi»?) — Regel 14 — 2026-11-05
  'Take', // zurückgestellt: Genus schwankt (der oder das Take) — Regel 14 — 2026-11-05
  'Talsohle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Boden eines Tals / Tiefpunkt einer Entwicklung, z. B. der Konjunktur) — nach den Nomen 2026-11-05
  'Tandem', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fahrrad für zwei / Sprachtandem, Zweiergespann) — nach den Nomen 2026-11-05
  'Tank', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Behälter für Flüssigkeiten / veraltet: Panzer) — nach den Nomen 2026-11-05
  'Tarif', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Preis, Gebühr, z. B. Strom- oder Handytarif / ausgehandelte Lohnhöhe, Tarifvertrag) — nach den Nomen 2026-11-05
  'Tanzbein', // zurückgestellt: nur in fester Wendung «das Tanzbein schwingen» — Regel 14 — 2026-11-05
  'Tasche', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tragetasche, Handtasche / Hosentasche, Jackentasche) — nach den Nomen 2026-11-05
  'Tatbestand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sachverhalt, Gegebenheit / Recht: Straftatbestand) — nach den Nomen 2026-11-05
  'Task', // zurückgestellt: Anglizismus (EDV); Genus und Gebrauch unsicher (der/die Task) — Regel 14 — 2026-11-05
  'Taumel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schwindel, Schwanken / Rausch, z. B. Freudentaumel) — nach den Nomen 2026-11-05
  'Tausender', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tausendeuroschein / Zahl, Stelle der Tausender / Berg über 1000 m) — nach den Nomen 2026-11-05
  'Tauwetter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wetter mit Schneeschmelze / politische Entspannung) — nach den Nomen 2026-11-05
  'Tauziehen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Spiel mit einem Seil / zähes Ringen, Machtkampf) — nach den Nomen 2026-11-05
  'Taxe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gebühr, Abgabe, z. B. Kurtaxe / Nebenform von «Taxi») — nach den Nomen 2026-11-05
  'Tauer', // zurückgestellt: kein gebräuchliches Einzelwort (nur Gebirgsname im Plural «die Tauern») — Regel 14/18 — 2026-11-05
  'Technik', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Technik als Fachgebiet, Maschinen und Geräte / Methode, Verfahren, z. B. Atemtechnik) — nach den Nomen 2026-11-08
  'Teddy', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Teddybär / Plüschstoff, Teddyfutter) — nach den Nomen 2026-11-08
  'Techno', // zurückgestellt: Genus schwankt (der oder das Techno) — Regel 14 — 2026-11-08
  'Teil', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 2 (Homograph mit anderem Artikel: der Teil «Anteil, Bereich» / das Teil «Einzelstück, Bauteil») — nach den Nomen 2026-11-08
  'Teilchen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kleines Stück / Physik: Elementarteilchen / regional: Gebäckstück) — nach den Nomen 2026-11-08
  'Teilnahme', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Teilnehmen / Interesse / Mitgefühl, Anteilnahme) — nach den Nomen 2026-11-08
  'Teilnehmer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: wer an etwas teilnimmt / Inhaber eines Telefonanschlusses) — nach den Nomen 2026-11-08
  'Teilnehmerin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (wie Teilnehmer: wer an etwas teilnimmt / Inhaberin eines Telefonanschlusses) — nach den Nomen 2026-11-08
  'Telefax', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fernkopie / Faxgerät) — nach den Nomen 2026-11-08
  'Telefonaktion', // zurückgestellt: Bedeutung und Gebrauch unsicher (kein klarer Wörterbucheintrag) — Regel 14 — 2026-11-08
  'Telekom', // zurückgestellt: Firmenname (Deutsche Telekom) — Regel 18 — 2026-11-08
  'Temperament', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wesensart, Charakter / Lebhaftigkeit, Schwung) — nach den Nomen 2026-11-08
  'Tempo', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschwindigkeit / Musik: Zeitmaß, Pl. Tempi / ugs. Papiertaschentuch nach Markenname) — nach den Nomen 2026-11-08
  'Term', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mathematik/Logik: Ausdruck / Physik: Energiezustand / Fachausdruck) — nach den Nomen 2026-11-08
  'Terminator', // zurückgestellt: Filmtitel bzw. Fachwort (Astronomie: Tag-Nacht-Grenze); Gebrauch als Lernwort unsicher — Regel 14/18 — 2026-11-08
  'Terra', // zurückgestellt: nur in lateinischen Wendungen (Terra incognita) — Regel 14 — 2026-11-08
  'Terrain', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gelände / Baugrundstück / übertragen: Bereich, z. B. «das Terrain sondieren») — nach den Nomen 2026-11-08
  'Terror', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gewalt, Schreckensherrschaft / ugs. Zank, großes Aufheben) — nach den Nomen 2026-11-08
  'Testament', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: letzter Wille / Bibel: Altes und Neues Testament) — nach den Nomen 2026-11-08
  'Tester', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Person, die etwas testet / Probepackung, z. B. Parfümtester / Prüfgerät) — nach den Nomen 2026-11-08
  'Texter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verfasser von Werbetexten / Verfasser von Liedtexten) — nach den Nomen 2026-11-08
  'Textil', // zurückgestellt: als Singular «das Textil» selten, meist nur Plural «Textilien»; Gebrauch unsicher — Regel 14 — 2026-11-08
  'Theater', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schauspielhaus, Aufführung / ugs. Aufregung, Getue: «Theater machen») — nach den Nomen 2026-11-08
  'Theatertreffen', // zurückgestellt: meist Name eines Festivals (Berliner Theatertreffen); allgemeiner Gebrauch unsicher — Regel 14/18 — 2026-11-08
  'Thema', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gegenstand, Gesprächsstoff / Musik: Melodie, die variiert wird) — nach den Nomen 2026-11-08
  'Therme', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Thermalbad / antike Badeanlage / österr. Gastherme, Heizgerät) — nach den Nomen 2026-11-08
  'Thermometer', // zurückgestellt: Genus schwankt (das Thermometer, österr./schweiz. auch der) — Regel 14 — 2026-11-08
  'Thesis', // zurückgestellt: selten, Nebenform von «These» bzw. Fachwort (Metrik); Gebrauch unsicher — Regel 14 — 2026-11-08
  'Thing', // zurückgestellt: Bedeutung unsicher (germanische Volksversammlung / ugs. Anglizismus «Ding») — Regel 14 — 2026-11-08
  'Thon', // zurückgestellt: nur schweizerisch für «Thunfisch»; Genus und Gebrauch unsicher — Regel 14 — 2026-11-08
  'Tick', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Marotte, Eigenart / Medizin: Tic, Zucken / ugs. «ein Tick»: ein bisschen) — nach den Nomen 2026-11-08
  'Ticker', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fernschreiber, Nachrichtenticker / Liveticker im Internet) — nach den Nomen 2026-11-08
  'Tief', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tiefdruckgebiet / Tiefpunkt, z. B. ein seelisches Tief) — nach den Nomen 2026-11-08
  'Tiefgang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schiff: Eintauchtiefe / übertragen: gedankliche Tiefe) — nach den Nomen 2026-11-08
  'Tiefschlag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Boxen: unerlaubter Schlag unter die Gürtellinie / übertragen: schwerer Schicksalsschlag) — nach den Nomen 2026-11-08
  'Tilgung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rückzahlung einer Schuld / Beseitigung, Löschung, z. B. Tilgung aus dem Register) — nach den Nomen 2026-11-08
  'Tip', // zurückgestellt: alte Schreibung von «Tipp» (Rechtschreibreform 1996) — Regel 14 — 2026-11-08
  'Titel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Name eines Buches, Films / akademischer Grad, z. B. Doktortitel / Sport: Meistertitel) — nach den Nomen 2026-11-08
  'Tobel', // zurückgestellt: Genus schwankt (der oder das Tobel); regional (südd./österr./schweiz.) — Regel 14 — 2026-11-08
  'Tochter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: weibliches Kind / Wirtschaft: Tochterfirma) — nach den Nomen 2026-11-08
  'Toilette', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: WC, Klo / gehoben: das Ankleiden, festliche Kleidung) — nach den Nomen 2026-11-08
  'Toleranz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Duldsamkeit gegenüber anderen / Technik: zulässige Abweichung / Medizin: Widerstandsfähigkeit) — nach den Nomen 2026-11-08
  'Tonhalle', // zurückgestellt: meist Eigenname eines Konzertsaals (Tonhalle Zürich, Düsseldorf) — Regel 14/18 — 2026-11-08
  'Tonne', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gewichtseinheit 1000 kg / großer Behälter, z. B. Mülltonne) — nach den Nomen 2026-11-08
  'Tony', // zurückgestellt: Personenname bzw. Theaterpreis (Tony Award) — Regel 14/18 — 2026-11-08
  'Tornado', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wirbelsturm / Kampfflugzeug «Tornado») — nach den Nomen 2026-11-08
  'Torso', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rumpf des Körpers / Statue ohne Kopf und Glieder / übertragen: Bruchstück) — nach den Nomen 2026-11-08
  'Tory', // zurückgestellt: Fremdwort (brit. Konservativer); Plural schwankt (Torys/Tories) — Regel 14 — 2026-11-08
  'Toto', // zurückgestellt: Genus schwankt (das oder der Toto) — Regel 14 — 2026-11-08
  'Touch', // zurückgestellt: Anglizismus, umgangssprachlich; Gebrauch und Bedeutung schwankend — Regel 14 — 2026-11-08
  'Tour', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausflug, Reise / ugs. Art und Weise, z. B. «auf die krumme Tour» / Technik: Umdrehung, «auf Touren kommen») — nach den Nomen 2026-11-08
  'Tracht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: traditionelle Kleidung, z. B. Dirndl / «eine Tracht Prügel» / Imkerei: Bienentracht) — nach den Nomen 2026-11-08
  'Track', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musikstück auf einer CD / Rennstrecke, Pfad) — nach den Nomen 2026-11-08
  'Train', // zurückgestellt: veraltet (militärisch: Tross, Nachschub); Gebrauch unsicher — Regel 14 — 2026-11-08
  'Trainer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sportlehrer, Coach / schweiz.: Trainingsanzug) — nach den Nomen 2026-11-08
  'Trakt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gebäudeteil, Flügel / Medizin: Verdauungstrakt / Landstrich) — nach den Nomen 2026-11-08
  'Traktat', // zurückgestellt: Genus schwankt (der oder das Traktat) — Regel 14 — 2026-11-08
  'Tran', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fischöl / ugs. «im Tran sein»: benommen, verschlafen) — nach den Nomen 2026-11-08
  'Transfer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geldüberweisung / Spielerwechsel / Beförderung von Reisenden / Psychologie: Übertragung) — nach den Nomen 2026-11-08
  'Transformation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Umwandlung, Wandel / Fachsprache: Mathematik, Linguistik, Elektrotechnik) — nach den Nomen 2026-11-08
  'Transparenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Durchsichtigkeit / Offenheit, Nachvollziehbarkeit, z. B. in der Politik) — nach den Nomen 2026-11-08
  'Transvestit', // zurückgestellt: Bezeichnung teils als veraltet/abwertend empfunden; Einordnung (anstoessig) unsicher — Regel 14/17 — 2026-11-08
  'Trapp', // zurückgestellt: Familienname (Familie von Trapp); kein gebräuchliches Nomen — Regel 14/18 — 2026-11-08
  'Traube', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Weintraube / Blütenstand / übertragen: Menschentraube) — nach den Nomen 2026-11-08
  'Trauerspiel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tragödie (Theater) / ugs. etwas Klägliches, Jämmerliches) — nach den Nomen 2026-11-08
  'Trauner', // zurückgestellt: regionales Fachwort (Salzschiff auf der Traun) bzw. Name; Gebrauch unsicher — Regel 14 — 2026-11-08
  'Treffer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schuss, der trifft / Tor im Sport / Gewinnlos / Suchergebnis) — nach den Nomen 2026-11-08
  'Treiben', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gewimmel, buntes Durcheinander / abwertend: Tun, Machenschaften) — nach den Nomen 2026-11-08
  'Treiber', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: EDV: Gerätetreiber / Jagd: wer das Wild treibt / Viehtreiber) — nach den Nomen 2026-11-08
  'Trauma', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: seelische Erschütterung / Medizin: körperliche Verletzung, z. B. Schädel-Hirn-Trauma) — nach den Nomen 2026-11-08
  'Treppchen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kleine Treppe / Sport ugs.: Siegerpodest, «aufs Treppchen») — nach den Nomen 2026-11-08
  'Treuhand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Recht: Verwaltung fremden Vermögens / Kurzform für die Treuhandanstalt) — nach den Nomen 2026-11-08
  'Trichter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gerät zum Einfüllen / Krater, z. B. Bombentrichter) — nach den Nomen 2026-11-08
  'Trieb', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: innerer Antrieb, Instinkt / Pflanze: junger Spross) — nach den Nomen 2026-11-08
  'Triebfeder', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Technik: Antriebsfeder / übertragen: Beweggrund, Motiv) — nach den Nomen 2026-11-08
  'Trip', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausflug, kurze Reise / ugs.: Drogenrausch) — nach den Nomen 2026-11-08
  'Tritt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stoß mit dem Fuß / Schritt / Trittstufe, kleine Leiter) — nach den Nomen 2026-11-08
  'Trittbrettfahrer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: wer auf dem Trittbrett mitfährt / abwertend: wer vom Einsatz anderer profitiert) — nach den Nomen 2026-11-08
  'Trockenheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: trockene Beschaffenheit (Haut, Luft) / Dürre, regenarme Zeit) — nach den Nomen 2026-11-08
  'Troika', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: russisches Dreigespann / Dreiergruppe in der Politik, z. B. EU-Troika) — nach den Nomen 2026-11-08
  'Troll', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fabelwesen / Internet: wer absichtlich provoziert) — nach den Nomen 2026-11-08
  'Trommel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musikinstrument / Technik: Waschmaschinen-, Kabel-, Revolvertrommel) — nach den Nomen 2026-11-08
  'Tropfen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: kleine Flüssigkeitsmenge / Plural: Medikament in Tropfenform / ugs.: Wein, «ein guter Tropfen») — nach den Nomen 2026-11-08
  'Tropus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rhetorik: bildlicher Ausdruck / Musik: Erweiterung eines liturgischen Gesangs) — nach den Nomen 2026-11-08
  'Trottoir', // zurückgestellt: Plural schwankt (Trottoirs/Trottoire); regional (schweiz., südd.) — Regel 14 — 2026-11-08
  'Trumpf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kartenspiel: stechende Farbe/Karte / übertragen: entscheidender Vorteil) — nach den Nomen 2026-11-08
  'Trunk', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: gehoben: Getränk, Schluck / Trinken, Trunksucht) — nach den Nomen 2026-11-08
  'Truppe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Militär: Truppen / Theater-, Artistengruppe / ugs.: Mannschaft, Team) — nach den Nomen 2026-11-08
  'Tube', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Behälter (Zahnpasta) / Medizin: Eileiter, Ohrtrompete) — nach den Nomen 2026-11-08
  'Tuch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen mit verschiedenem Plural: Stück Stoff, Tuch (Tücher) / Stoffart (Tuche)) — nach den Nomen 2026-11-08
  'Trust', // zurückgestellt: Plural schwankt (Trusts, seltener Truste) — Regel 14 — 2026-11-08
  'Turbo', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Technik: Turbolader / ugs. übertragen: Beschleunigung, «den Turbo einlegen») — nach den Nomen 2026-11-08
  'Turbulenz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Physik/Luftfahrt: Luftwirbel / übertragen: Unruhe, Wirren) — nach den Nomen 2026-11-08
  'Turm', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bauwerk / Schachfigur) — nach den Nomen 2026-11-08
  'Tunnel', // zurückgestellt: Plural schwankt (Tunnel/Tunnels); südd./österr. auch «das Tunell» — Regel 14 — 2026-11-08
  'Turnus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: regelmäßige Reihenfolge, Wechsel / österr.: praktische Ausbildungszeit der Ärzte) — nach den Nomen 2026-11-08
  'Typ', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Art, Modell / ugs.: Mann, Kerl; Genitiv schwankt: des Typs / des Typen) — nach den Nomen 2026-11-08
  'Type', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Druckbuchstabe / ugs.: seltsamer Mensch, «eine komische Type») — nach den Nomen 2026-11-08
  'Tyrann', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gewaltherrscher / übertragen: herrschsüchtiger Mensch, «Haustyrann» / Zoologie: Vogelart) — nach den Nomen 2026-11-08
  'Tyrannei', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gewaltherrschaft / übertragen: herrisches, willkürliches Verhalten) — nach den Nomen 2026-11-08
  'Uhr', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gerät zur Zeitmessung / ohne Plural bei Zeitangaben: «um drei Uhr») — nach den Nomen 2026-11-08
  'Ultra', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Politik: Extremist / Sport: fanatischer Fußballfan) — nach den Nomen 2026-11-08
  'Ultraschall', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Physik: Schall über der Hörgrenze / Medizin: Ultraschalluntersuchung) — nach den Nomen 2026-11-08
  'Tutti', // zurückgestellt: Fachwort der Musik; Plural schwankt (Tuttis/Tutti) — Regel 14 — 2026-11-08
  'Ultimatum', // zurückgestellt: Plural schwankt (Ultimaten/Ultimatums) — Regel 14 — 2026-11-08
  'Umbau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Umbauen eines Gebäudes / umgebautes Gebäude / übertragen: Umgestaltung, z. B. des Sozialstaats); Plural schwankt (Umbauten/Umbaue) — nach den Nomen 2026-11-08
  'Umbruch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: grundlegende Veränderung / Druckwesen: Seitenumbruch / Landwirtschaft: Umpflügen) — nach den Nomen 2026-11-08
  'Umfahrung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Umfahren / österr., schweiz.: Umgehungsstraße) — nach den Nomen 2026-11-08
  'Umfang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geometrie, Körper: Umfang (Länge der Begrenzung) / Ausmaß, Menge) — nach den Nomen 2026-11-08
  'Umgang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kontakt mit Menschen / Handhabung, «Umgang mit Geld» / Kirche: Prozession / Architektur: Rundgang) — nach den Nomen 2026-11-08
  'Umgehung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Umgehen einer Regel / Umgehungsstraße) — nach den Nomen 2026-11-08
  'Umkehr', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Umkehren, Zurückgehen / gehoben: innere Wandlung) — nach den Nomen 2026-11-08
  'Umkehrung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Umdrehung der Reihenfolge / Fachsprache: Musik, Mathematik, Grammatik) — nach den Nomen 2026-11-08
  'Umkreis', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Umgebung, «im Umkreis von 10 km» / Geometrie: Kreis um ein Vieleck) — nach den Nomen 2026-11-08
  'Umlauf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geldumlauf, Zirkulation / Umdrehung, Bahn eines Himmelskörpers / Rundschreiben / Medizin: Nagelbettentzündung) — nach den Nomen 2026-11-08
  'Umsatz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wirtschaft: Verkaufserlös / Fachsprache: Stoff- und Energieumsatz, z. B. Grundumsatz) — nach den Nomen 2026-11-08
  'Umschichtung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Umschichten (Stapel) / Strukturveränderung in Gesellschaft oder Finanzen) — nach den Nomen 2026-11-08
  'Umsatzvolumen', // zurückgestellt: Plural schwankt (Umsatzvolumen/Umsatzvolumina) — Regel 14 — 2026-11-08
  'Umschau', // zurückgestellt: nur in fester Wendung «Umschau halten» (gehoben) — Regel 14 — 2026-11-08
  'Umschlag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Briefumschlag / Buchumschlag / Medizin: Wickel, Kompresse / Wirtschaft: Güterumschlag / plötzliche Änderung) — nach den Nomen 2026-11-08
  'Umschulung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausbildung für einen neuen Beruf / Wechsel auf eine andere Schule) — nach den Nomen 2026-11-08
  'Umschwung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: plötzliche Wende / Turnen: Schwung um das Reck) — nach den Nomen 2026-11-08
  'Umsetzung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verwirklichung, Durchführung / Versetzung (Person, Pflanze) / Umwandlung (Energie, Stoff)) — nach den Nomen 2026-11-08
  'Umstand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gegebenheit / Plural: Aufwand, «Umstände machen» / «in anderen Umständen» = schwanger) — nach den Nomen 2026-11-08
  'Umtrieb', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Plural abwertend: Machenschaften / schweiz.: Aufwand, Betriebsamkeit) — nach den Nomen 2026-11-08
  'Umwelt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Natur, Lebensraum / die Menschen in jemandes Umgebung) — nach den Nomen 2026-11-08
  'Umweltbundesamt', // zurückgestellt: Name einer Behörde — Regel 14/18 — 2026-11-08
  'Umzug', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wohnungswechsel / Festzug, Parade) — nach den Nomen 2026-11-08
  'Unbill', // zurückgestellt: gehoben, selten; Plural/Gebrauch unsicher («die Unbilden des Wetters») — Regel 14 — 2026-11-08
  'Unding', // zurückgestellt: nur in fester Wendung «ein Unding sein» — Regel 14 — 2026-11-08
  'Unendlichkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: unendliche Weite, Ewigkeit / Mathematik: das Unendliche) — nach den Nomen 2026-11-08
  'Ungemach', // zurückgestellt: gehoben, selten; Markierung (veraltend?) unsicher — Regel 14/17 — 2026-11-08
  'Ungnade', // zurückgestellt: fast nur in fester Wendung «in Ungnade fallen» — Regel 14 — 2026-11-08
  'Union', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bund, Vereinigung (z. B. EU) / in Deutschland: CDU und CSU) — nach den Nomen 2026-11-08
  'Unionist', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mitglied/Anhänger von CDU/CSU / Nordirland: Unionist / Geschichte USA) — nach den Nomen 2026-11-08
  'Unit', // zurückgestellt: Anglizismus; Bedeutung schwankt (Einheit, Team, Lerneinheit) — Regel 14 — 2026-11-08
  'Unkenntlichkeit', // zurückgestellt: fast nur in fester Wendung «bis zur Unkenntlichkeit» — Regel 14 — 2026-11-08
  'Unkenruf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ruf der Unke / pessimistische Vorhersage) — nach den Nomen 2026-11-08
  'Unruhe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ruhelosigkeit, Lärm / Besorgnis / Pl. Unruhen = Aufruhr) — nach den Nomen 2026-11-08
  'Unschuld', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schuldlosigkeit / Reinheit, Naivität / Jungfräulichkeit) — nach den Nomen 2026-11-08
  'Unsicherheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: fehlende Sicherheit, Gefahr / Ungewissheit / fehlendes Selbstvertrauen) — nach den Nomen 2026-11-08
  'Unstimmigkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fehler, Widerspruch / Meinungsverschiedenheit) — nach den Nomen 2026-11-08
  'Unter', // zurückgestellt: Bedeutung unsicher (Spielkarte «der Unter»?) — Regel 14 — 2026-11-08
  'Unterbau', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fundament eines Bauwerks / Grundlage, Basis) — nach den Nomen 2026-11-08
  'Unterbezirk', // zurückgestellt: Fachbegriff der Partei-/Verwaltungsgliederung, Gebrauch unsicher — Regel 14 — 2026-11-08
  'Untergang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sinken eines Schiffes / Ende, Zusammenbruch / Untergehen der Sonne) — nach den Nomen 2026-11-08
  'Untergrund', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Boden, Erdreich / politischer Untergrund / Hintergrund, Unterlage) — nach den Nomen 2026-11-08
  'Unterhalt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Lebensunterhalt / Unterhaltszahlung / Instandhaltung) — nach den Nomen 2026-11-08
  'Unterhaltung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gespräch / Vergnügen, Entertainment / Instandhaltung) — nach den Nomen 2026-11-08
  'Unterlage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schriftstück, Pl. Unterlagen / etwas, das man unterlegt) — nach den Nomen 2026-11-08
  'Unterland', // zurückgestellt: meist regionaler Name (Zürcher/Bozner Unterland), Gebrauch unsicher — Regel 14/18 — 2026-11-08
  'Unternehmen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Firma, Betrieb / Vorhaben, Aktion) — nach den Nomen 2026-11-08
  'Unternehmung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorhaben, Ausflug / Firma) — nach den Nomen 2026-11-08
  'Unterordnung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Unterordnen / Biologie: Kategorie unter der Ordnung) — nach den Nomen 2026-11-08
  'Untersatz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Unterlage, Untersetzer / «fahrbarer Untersatz» = Auto / Logik: Unterprämisse) — nach den Nomen 2026-11-08
  'Unterschicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: soziale Schicht / untere Lage, Schicht) — nach den Nomen 2026-11-08
  'Untersuchung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ärztliche Untersuchung / Ermittlung / wissenschaftliche Studie) — nach den Nomen 2026-11-08
  'Untertan', // zurückgestellt: Genitiv schwankt (des Untertans/des Untertanen) — Regel 14 — 2026-11-08
  'Untertitel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: zweiter Titel eines Buches / eingeblendeter Text im Film) — nach den Nomen 2026-11-08
  'Unterton', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: mitschwingender Ton (Musik) / leiser Beiklang, z. B. Ironie) — nach den Nomen 2026-11-08
  'Unterwasser', // zurückgestellt: als Nomen selten (Wasserbau); meist nur Bestimmungswort «Unterwasser-» — Regel 14 — 2026-11-08
  'Unterwelt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Totenreich (Mythologie) / kriminelles Milieu) — nach den Nomen 2026-11-08
  'Untreue', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Treulosigkeit in der Beziehung / Rechtssprache: Vermögensdelikt) — nach den Nomen 2026-11-08
  'Unwesen', // zurückgestellt: nur in fester Wendung «sein Unwesen treiben» — Regel 14 — 2026-11-08
  'Unwille', // zurückgestellt: Nominativ schwankt (Unwille/Unwillen), gemischte Deklination — Regel 14 — 2026-11-08
  'Unzucht', // zurückgestellt: veraltend/Rechtssprache, sexueller Bereich; Markierung unsicher — Regel 14/17 — 2026-11-08
  'Ural', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 3 (Homograph gleicher Artikel: der Ural = Gebirge / Fluss) — nach den Nomen 2026-11-08
  'Urgestein', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: ursprüngliches Gestein / langjähriges, typisches Mitglied einer Gruppe) — nach den Nomen 2026-11-08
  'Urne', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gefäß für Asche / Wahlurne) — nach den Nomen 2026-11-08
  'Urteil', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gerichtsentscheidung / Meinung, Beurteilung) — nach den Nomen 2026-11-08
  'Uta', // zurückgestellt: Personenname — Regel 18 — 2026-11-08
  'Vakuum', // zurückgestellt: Plural doppelt (Vakua/Vakuen) — Regel 14 — 2026-11-08
  'Val', // zurückgestellt: Bedeutung unsicher — Regel 14 — 2026-11-08
  'Vampir', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Blut saugendes Gespenst / Fledermausart) — nach den Nomen 2026-11-08
  'Vandale', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Angehöriger eines germanischen Volkes / zerstörungswütiger Mensch) — nach den Nomen 2026-11-08
  'Variable', // zurückgestellt: Deklination schwankt (zwei Variable/Variablen, wie ein Adjektiv) — Regel 14 — 2026-11-08
  'Variation', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abwandlung / Musik: Variationen eines Themas / Biologie) — nach den Nomen 2026-11-08
  'Vega', // zurückgestellt: Eigenname (Stern/Person) — Regel 18 — 2026-11-08
  'Vehikel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: (altes) Fahrzeug / Mittel zum Zweck) — nach den Nomen 2026-11-08
  'Veilchen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Blume / ugs. blaues Auge) — nach den Nomen 2026-11-08
  'Velvet', // zurückgestellt: Genus unsicher (der/das), selten — Regel 14 — 2026-11-08
  'Ventil', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: technisches Ventil / Musikinstrument / Ausweg für Gefühle) — nach den Nomen 2026-11-08
  'Verabredung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Treffen, Date / Vereinbarung, Absprache) — nach den Nomen 2026-11-08
  'Verabschiedung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abschied / Beschluss eines Gesetzes) — nach den Nomen 2026-11-08
  'Verankerung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: technische Befestigung / feste Einbindung, z. B. im Gesetz) — nach den Nomen 2026-11-08
  'Veranlagung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Anlage, Neigung / Steuerveranlagung) — nach den Nomen 2026-11-08
  'Verarbeitung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bearbeitung von Material/Daten / seelisches Verarbeiten / Qualität der Ausführung) — nach den Nomen 2026-11-08
  'Verband', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vereinigung, Organisation / Wundverband) — nach den Nomen 2026-11-08
  'Verbandsgemeinde', // zurückgestellt: regionaler Verwaltungsbegriff (Rheinland-Pfalz u. a.) — Regel 14 — 2026-11-08
  'Verbandsliga', // zurückgestellt: Spielklasse im regionalen Sport, Gebrauch unsicher — Regel 14 — 2026-11-08
  'Verbauung', // zurückgestellt: Bedeutung/Gebrauch regional unsicher (österr./schweiz.) — Regel 14 — 2026-11-08
  'Verbesserung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Besserwerden / Korrektur eines Fehlers, Schulverbesserung) — nach den Nomen 2026-11-08
  'Verbindlichkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verpflichtung, Pl. Schulden / bindende Wirkung / Freundlichkeit) — nach den Nomen 2026-11-08
  'Verbindung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kontakt, Zusammenhang / Verkehrsverbindung / chemische Verbindung / Studentenverbindung) — nach den Nomen 2026-11-08
  'Verbleib', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufenthaltsort / das Verbleiben) — nach den Nomen 2026-11-08
  'Verbrennung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Verbrennen / Brandwunde / Einäscherung) — nach den Nomen 2026-11-08
  'Verbund', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zusammenschluss, z. B. Verkehrsverbund / technische Verbindung) — nach den Nomen 2026-11-08
  'Verderben', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Untergang, Unglück / Schlechtwerden von Lebensmitteln) — nach den Nomen 2026-11-08
  'Verdichtung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bebauung, Nachverdichtung / Zusammenpressen (Technik) / Verstärkung) — nach den Nomen 2026-11-08
  'Verehrer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mann, der eine Frau umwirbt / Bewunderer, Fan) — nach den Nomen 2026-11-08
  'Verehrung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: religiöse Verehrung / Bewunderung) — nach den Nomen 2026-11-08
  'Vereinigung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Organisation, Bund / das Vereinigen, z. B. deutsche Einheit) — nach den Nomen 2026-11-08
  'Vereinnahmung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Einnahme von Geld / Inanspruchnahme für eigene Zwecke) — nach den Nomen 2026-11-08
  'Vereinsvorsitzende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Vereinsvorsitzende) — nach den Nomen 2026-11-08
  'Verfahren', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Methode, Technik / Gerichtsverfahren) — nach den Nomen 2026-11-08
  'Verfall', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zerfall, Niedergang / Ablauf der Gültigkeit) — nach den Nomen 2026-11-08
  'Verfassung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Grundgesetz eines Staates / körperlicher oder seelischer Zustand) — nach den Nomen 2026-11-08
  'Verfassungsschutz', // zurückgestellt: Name einer Behörde (Deutschland) — Regel 14/18 — 2026-11-08
  'Verfolger', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: wer jemanden verfolgt, jagt / Unterdrücker / Sport: Verfolgerfeld) — nach den Nomen 2026-11-08
  'Verfolgung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Jagd, Nachsetzen / politische Verfolgung / Strafverfolgung) — nach den Nomen 2026-11-08
  'Verhaltenskodex', // zurückgestellt: Plural doppelt (Verhaltenskodizes/-kodexe) — Regel 14 — 2026-11-08
  'Vergangenheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: vergangene Zeit / Grammatik: Vergangenheitsform) — nach den Nomen 2026-11-08
  'Vergehen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Straftat, Verstoß / das Vergehen der Zeit) — nach den Nomen 2026-11-08
  'Vergessenheit', // zurückgestellt: fast nur in fester Wendung «in Vergessenheit geraten» — Regel 14 — 2026-11-08
  'Vergewaltigung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: sexuelle Gewalttat / übertragen: gewaltsame Missachtung) — nach den Nomen 2026-11-08
  'Vergleich', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Vergleichen / Rechtssprache: gütliche Einigung) — nach den Nomen 2026-11-08
  'Verhandlung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gespräch zur Einigung / Gerichtsverhandlung) — nach den Nomen 2026-11-08
  'Verhandlungstag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tag einer Gerichtsverhandlung / Tag von Verhandlungen) — nach den Nomen 2026-11-08
  'Verhinderung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Verhindern / das Verhindertsein, Abwesenheit) — nach den Nomen 2026-11-08
  'Verkauf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Verkaufen / Verkaufsabteilung) — nach den Nomen 2026-11-08
  'Verkehr', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Straßenverkehr / Umgang, Kontakt / Geschlechtsverkehr) — nach den Nomen 2026-11-08
  'Verkehrstote', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Verkehrstote) — nach den Nomen 2026-11-08
  'Verkleidung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kostüm / Abdeckung, Täfelung) — nach den Nomen 2026-11-08
  'Verkleinerung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Verkleinern / Grammatik: Verkleinerungsform) — nach den Nomen 2026-11-08
  'Verlangen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: starker Wunsch, Sehnsucht / Forderung, «auf Verlangen») — nach den Nomen 2026-11-08
  'Verlass', // zurückgestellt: nur in fester Wendung «auf jemanden ist Verlass» — Regel 14 — 2026-11-08
  'Verlauf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ablauf, Entwicklung / Richtung einer Linie / Browserverlauf) — nach den Nomen 2026-11-08
  'Verlegenheit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Befangenheit, Scham / schwierige Lage) — nach den Nomen 2026-11-08
  'Verlegung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ortswechsel, z. B. Patientenverlegung / Verschiebung eines Termins / Verlegen von Leitungen) — nach den Nomen 2026-11-08
  'Verleih', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Verleihen / Firma, z. B. Fahrradverleih, Filmverleih) — nach den Nomen 2026-11-08
  'Verleiher', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: wer etwas verleiht / Filmverleih-Firma) — nach den Nomen 2026-11-08
  'Verletzung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wunde, Verwundung / Verstoß gegen Regeln, Rechte) — nach den Nomen 2026-11-08
  'Verlust', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Verlieren / finanzieller Verlust / Tod eines Menschen, Pl. Verluste im Krieg) — nach den Nomen 2026-11-08
  'Verlustzone', // zurückgestellt: fast nur in fester Wendung «in die Verlustzone geraten / in der Verlustzone» — Regel 14 — 2026-11-08
  'Vermehrung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zunahme / Fortpflanzung (Biologie)) — nach den Nomen 2026-11-08
  'Vermittler', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schlichter in einem Streit / Makler, Agent) — nach den Nomen 2026-11-08
  'Vermittlung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Schlichtung / Arbeitsvermittlung / Telefonzentrale) — nach den Nomen 2026-11-08
  'Vernehmlassung', // zurückgestellt: Bedeutung (schweiz.: Verlautbarung / Stellungnahme im Vernehmlassungsverfahren) nicht eindeutig — Regel 14 — 2026-11-08
  'Verordnung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rechtsvorschrift / ärztliche Verordnung eines Medikaments) — nach den Nomen 2026-11-08
  'Verpackungsverordnung', // zurückgestellt: Name einer bestimmten Rechtsvorschrift (DE, seit 2019 Verpackungsgesetz) — Regel 18/14 — 2026-11-08
  'Verpflichtung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pflicht / Engagement eines Künstlers, Spielers / Pl. finanzielle Verbindlichkeiten) — nach den Nomen 2026-11-08
  'Versager', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mensch, der versagt / Ding, das nicht funktioniert, z. B. Fehlzündung, Flop) — nach den Nomen 2026-11-08
  'Verschiebung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufschub eines Termins / räumliche Verlagerung, Verrückung) — nach den Nomen 2026-11-08
  'Verschleierung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vertuschung / das Tragen eines Schleiers) — nach den Nomen 2026-11-08
  'Verschleppung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Entführung, Deportation / Verzögerung eines Verfahrens / Verbreitung einer Krankheit) — nach den Nomen 2026-11-08
  'Verschluss', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Deckel, Verschlussvorrichtung / Kameraverschluss / «unter Verschluss») — nach den Nomen 2026-11-08
  'Versenkung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Versenken eines Schiffes / Bühnenversenkung, «in der Versenkung verschwinden» / innere Versenkung) — nach den Nomen 2026-11-08
  'Versetzung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Versetzung an einen anderen Arbeitsort / Versetzung in die nächste Klasse) — nach den Nomen 2026-11-08
  'Versicherte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Versicherte) — nach den Nomen 2026-11-08
  'Versicherung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vertrag gegen Schaden / Versicherungsgesellschaft / Beteuerung, eidesstattliche Versicherung) — nach den Nomen 2026-11-08
  'Versorger', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Firma, die Strom/Wasser liefert / Ernährer einer Familie) — nach den Nomen 2026-11-08
  'Versorgung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Belieferung mit Strom/Wasser/Waren / Pflege, medizinische Versorgung / Altersversorgung, Pension) — nach den Nomen 2026-11-08
  'Verstimmung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Verärgerung zwischen Menschen / Magenverstimmung / verstimmtes Instrument) — nach den Nomen 2026-11-08
  'Versuch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bemühen, etwas zu tun / wissenschaftliches Experiment / Rugby: Versuch) — nach den Nomen 2026-11-08
  'Verteidiger', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Strafverteidiger, Anwalt / Abwehrspieler im Sport / wer etwas verteidigt) — nach den Nomen 2026-11-08
  'Verteidigerin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Strafverteidigerin, Anwältin / Abwehrspielerin im Sport) — nach den Nomen 2026-11-08
  'Verteidigung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abwehr eines Angriffs, Militär / Strafverteidigung vor Gericht / Abwehr im Sport / Verteidigung einer Doktorarbeit) — nach den Nomen 2026-11-08
  'Vertiefung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Vertiefen von Wissen, Beziehungen / Mulde, vertiefte Stelle) — nach den Nomen 2026-11-08
  'Vertrauensfrage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Frage des Vertrauens / parlamentarische Vertrauensfrage des Regierungschefs) — nach den Nomen 2026-11-08
  'Vertraulichkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geheimhaltung, Diskretion / vertrauliche, intime Art, Pl. Vertraulichkeiten) — nach den Nomen 2026-11-08
  'Vertreter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Repräsentant / Handelsvertreter, Verkäufer / Stellvertreter) — nach den Nomen 2026-11-08
  'Vertreterin', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Repräsentantin / Handelsvertreterin / Stellvertreterin) — nach den Nomen 2026-11-08
  'Vertretung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stellvertretung, Vertretungslehrer / Interessenvertretung, Botschaft / Handelsvertretung) — nach den Nomen 2026-11-08
  'Verurteilung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: gerichtliches Urteil, Schuldspruch / moralische Verurteilung, Ablehnung) — nach den Nomen 2026-11-08
  'Verwahrung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Aufbewahrung, Obhut / Sicherungsverwahrung / «Verwahrung einlegen» = Protest) — nach den Nomen 2026-11-08
  'Verwaltung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Verwalten / Behörde, Verwaltungsabteilung) — nach den Nomen 2026-11-08
  'Verwaltungsrat', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gremium, schweiz. Aufsichtsorgan einer AG / Mitglied dieses Gremiums) — nach den Nomen 2026-11-08
  'Verwandtschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: alle Verwandten / verwandtschaftliche Beziehung / Ähnlichkeit, Wesensverwandtschaft) — nach den Nomen 2026-11-08
  'Verweigerer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: wer etwas verweigert / Kriegsdienstverweigerer) — nach den Nomen 2026-11-08
  'Verweis', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rüge, Tadel / Hinweis auf eine andere Stelle / Schulverweis) — nach den Nomen 2026-11-08
  'Verwerfung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ablehnung / geologische Verwerfung / Verziehen von Holz) — nach den Nomen 2026-11-08
  'Verwicklung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Beteiligung, Verstrickung / Komplikation, Schwierigkeit) — nach den Nomen 2026-11-08
  'Verzahnung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zähne eines Zahnrads, technisch / enge Verbindung, Verflechtung) — nach den Nomen 2026-11-08
  'Viech', // zurückgestellt: umgangssprachlich/regional (bayr., österr.), Wertung (abwertend oder liebevoll) unsicher — Regel 14 — 2026-11-08
  'Vieh', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nutztiere, Rinder / abwertend über Menschen) — nach den Nomen 2026-11-08
  'Vielseitigkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vielseitigsein eines Menschen, Geräts / Reitsport-Disziplin «Vielseitigkeitsreiten») — nach den Nomen 2026-11-08
  'Vier', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ziffer vier / Schulnote / Straßenbahn-, Buslinie 4) — nach den Nomen 2026-11-08
  'Vierer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ruderboot für vier / Schulnote / vier Richtige im Lotto / Ziffer, regional) — nach den Nomen 2026-11-08
  'Vierschanzentournee', // zurückgestellt: Name einer bestimmten Sportveranstaltung (Skispringen) — Regel 18/14 — 2026-11-08
  'Vierziger', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Mann in den Vierzigern / die Vierzigerjahre / Wein eines Jahrgangs) — nach den Nomen 2026-11-08
  'Vignette', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Autobahn-Mautplakette (AT, CH) / Zierbild in Büchern, Fotografie) — nach den Nomen 2026-11-08
  'Violinkonzert', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musikstück für Violine und Orchester / Konzertveranstaltung mit Violine) — nach den Nomen 2026-11-08
  'Violoncello', // zurückgestellt: Plural doppelt (Violoncelli/Violoncellos) — Regel 14 — 2026-11-08
  'Virus', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1/2 (mehrere Bedeutungen: Krankheitserreger / Computervirus; Artikel das, ugs. auch der) — nach den Nomen 2026-11-08
  'Visier', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Teil des Helms / Zielvorrichtung einer Waffe) — nach den Nomen 2026-11-08
  'Vision', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zukunftsvorstellung / Erscheinung, Trugbild) — nach den Nomen 2026-11-08
  'Visite', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Arztvisite im Krankenhaus / veraltend: Besuch) — nach den Nomen 2026-11-08
  'Vista', // zurückgestellt: Bedeutung unsicher (Ausblick, gehoben? / Produktname «Windows Vista») — Regel 14/18 — 2026-11-08
  'Visum', // zurückgestellt: Plural doppelt (Visa/Visen) — Regel 14 — 2026-11-08
  'Vita', // zurückgestellt: Plural doppelt (Viten/Vitae) — Regel 14 — 2026-11-08
  'Vogel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tier / ugs. Mensch «ein komischer Vogel» / ugs. Flugzeug; «einen Vogel haben») — nach den Nomen 2026-11-09
  'Vogler', // zurückgestellt: Bedeutung/Gebrauch unsicher (veraltet «Vogelfänger» / Familienname) — Regel 14 — 2026-11-09
  'Vogt', // zurückgestellt: historischer Titel mit je nach Epoche/Region verschiedener Bedeutung (Landvogt, Burgvogt, Kirchenvogt) — Regel 14 — 2026-11-09
  'Vokabel', // zurückgestellt: Artikel doppelt (die Vokabel; österr. auch das Vokabel) — Regel 14 — 2026-11-09
  'Volk', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Nation, Volksgruppe / die einfachen Leute, Menge / Bienenvolk) — nach den Nomen 2026-11-09
  'Volksarmee', // zurückgestellt: meist Name (Nationale Volksarmee der DDR; Volksbefreiungsarmee) — Regel 18/14 — 2026-11-09
  'Volkshaus', // zurückgestellt: Bedeutung unsicher (Arbeiterversammlungshaus, Gemeinschaftszentrum; oft Eigenname) — Regel 14 — 2026-11-09
  'Volkskammer', // zurückgestellt: Name (Parlament der DDR) — Regel 18/14 — 2026-11-09
  'Volkskongress', // zurückgestellt: Name (Nationaler Volkskongress der Volksrepublik China) — Regel 18/14 — 2026-11-09
  'Volksmund', // zurückgestellt: fast nur in fester Wendung «im Volksmund» — Regel 14 — 2026-11-09
  'Volkssport', // zurückgestellt: Plural unsicher (Volkssporte?/Volkssportarten), oft ironisch übertragen — Regel 14 — 2026-11-09
  'Volkstheater', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: volkstümliche Theatergattung / Theaterhaus, oft Eigenname wie Volkstheater Wien) — nach den Nomen 2026-11-09
  'Volkswirtschaft', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wirtschaft eines Landes / Wirtschaftswissenschaft, VWL) — nach den Nomen 2026-11-09
  'Vollendung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abschluss, Fertigstellung / Vollkommenheit, Perfektion; «nach Vollendung des 18. Lebensjahres») — nach den Nomen 2026-11-09
  'Volley', // zurückgestellt: fast nur in «aus dem Volley/volley» (Sport), Gebrauch als Nomen unsicher — Regel 14 — 2026-11-09
  'Volleyball', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sportart / der Ball — wie Handball, Basketball) — nach den Nomen 2026-11-09
  'Vollstrecker', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: wer ein Urteil/Testament vollstreckt / Sport: Torschütze) — nach den Nomen 2026-11-09
  'Volltreffer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: direkter Treffer / ugs. großer Erfolg) — nach den Nomen 2026-11-09
  'Volumen', // zurückgestellt: Plural doppelt (Volumen/Volumina), mehrere Bedeutungen (Rauminhalt / Umfang, Menge / Buchband) — Regel 14 — 2026-11-09
  'Voodoo', // zurückgestellt: Schreibung/Artikel unsicher (der Voodoo, auch Wodu/Vodou) — Regel 14 — 2026-11-09
  'Voranschlag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kostenvoranschlag, Schätzung / österr. Budget, Haushaltsplan) — nach den Nomen 2026-11-09
  'Voraussicht', // zurückgestellt: fast nur in festen Wendungen («aller Voraussicht nach», «in weiser Voraussicht») — Regel 14 — 2026-11-09
  'Vorbehalt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Bedenken, Zweifel / Einschränkung, Bedingung «unter Vorbehalt») — nach den Nomen 2026-11-09
  'Vordermann', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Person, die vor einem steht / Wendung «auf Vordermann bringen» = in Ordnung bringen) — nach den Nomen 2026-11-09
  'Vorderhand', // zurückgestellt: als Nomen unklar (Kartenspiel / Pferd); meist Adverb «vorderhand» — Regel 14 — 2026-11-09
  'Vorentscheidung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: vorläufige Entscheidung / Sport: Szene, die das Spiel praktisch entscheidet) — nach den Nomen 2026-11-09
  'Vorfall', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ereignis, Zwischenfall / Medizin: Prolaps, z. B. Bandscheibenvorfall — wichtig für Pflege) — nach den Nomen 2026-11-09
  'Vorfeld', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: «im Vorfeld» = vorher / Flughafen: Vorfeld, Abstellfläche) — nach den Nomen 2026-11-09
  'Vorgabe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Richtlinie, Zielvorgabe / Sport: Vorsprung, Handicap) — nach den Nomen 2026-11-09
  'Vorgang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ablauf, Prozess / Ereignis / Amtssprache: Akte, Vorgang) — nach den Nomen 2026-11-09
  'Vorgeschichte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Urgeschichte, Prähistorie / Vorgeschichte eines Ereignisses / Medizin: Anamnese — wichtig für Pflege) — nach den Nomen 2026-11-09
  'Vorgriff', // zurückgestellt: fast nur in fester Wendung «im Vorgriff auf» — Regel 14 — 2026-11-09
  'Vorhand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Tennis-Schlag / Kartenspiel: wer zuerst ausspielt / Vorderbeine des Pferdes) — nach den Nomen 2026-11-09
  'Vorkommen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Auftreten, Vorhandensein / Lagerstätte von Rohstoffen, z. B. Erdölvorkommen) — nach den Nomen 2026-11-09
  'Vorlage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Muster, Template / das Vorlegen eines Dokuments / Gesetzesvorlage / Sport: Torvorlage) — nach den Nomen 2026-11-09
  'Vorlauf', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sport: Vorlauf, erste Runde / Vorlaufzeit / Heizung: Vorlauf) — nach den Nomen 2026-11-09
  'Vorleistung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Leistung im Voraus / Wirtschaft: Vorleistungen, bezogene Güter) — nach den Nomen 2026-11-09
  'Vormarsch', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: militärisches Vorrücken / übertragen «auf dem Vormarsch sein» = sich ausbreiten) — nach den Nomen 2026-11-09
  'Vorpommer', // zurückgestellt: Bedeutung/Gebrauch unsicher (Einwohnerbezeichnung? Duden-Eintrag unklar) — Regel 14 — 2026-11-09
  'Vorrang', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Priorität / österr. Verkehr: Vorfahrt) — nach den Nomen 2026-11-09
  'Vorsatz', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Absicht, gute Vorsätze / Recht: Vorsatz, vorsätzlich / Buchbinderei: Vorsatzblatt) — nach den Nomen 2026-11-09
  'Vorschein', // zurückgestellt: nur in fester Wendung «zum Vorschein kommen/bringen» — Regel 14 — 2026-11-09
  'Vorschub', // zurückgestellt: fast nur in fester Wendung «Vorschub leisten»; sonst Technik (Vorschub einer Maschine) — Regel 14 — 2026-11-09
  'Vorsitzende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Vorsitzende) — nach den Nomen 2026-11-09
  'Vorsitzender', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv, stark gebeugte Form von «Vorsitzende») — nach den Nomen 2026-11-09
  'Vorsorge', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorkehrung, Vorbeugung / Altersvorsorge, finanzielle Absicherung / ugs. Vorsorgeuntersuchung) — nach den Nomen 2026-11-09
  'Vorspann', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Film: Vorspann, Titel am Anfang / Zugtiere, die zusätzlich vorgespannt werden / Einleitung eines Textes) — nach den Nomen 2026-11-09
  'Vorspiel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Musik: Präludium / Vorspielen bei einer Aufnahmeprüfung / Liebesspiel / Vorgeschichte) — nach den Nomen 2026-11-09
  'Vorsprung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abstand, Vorteil vor anderen / vorspringender Teil, z. B. Felsvorsprung) — nach den Nomen 2026-11-09
  'Vorstand', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Leitungsgremium einer Firma, eines Vereins / Mitglied, Leiter; österr. auch Vorstand einer Abteilung) — nach den Nomen 2026-11-09
  'Vorstandsvorsitzende', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Vorstandsvorsitzende) — nach den Nomen 2026-11-09
  'Vorstandsvorsitzender', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv, stark gebeugte Form von «Vorstandsvorsitzende») — nach den Nomen 2026-11-09
  'Vorstellung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Idee, Bild im Kopf / Aufführung im Theater, Kino / das Sich-Vorstellen, Bewerbungsgespräch) — nach den Nomen 2026-11-09
  'Vortrag', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Rede, Referat / Darbietung eines Musikstücks, Gedichts / Buchhaltung: Übertrag) — nach den Nomen 2026-11-09
  'Vortritt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorrang beim Gehen «den Vortritt lassen» / schweiz. Verkehr: Vorfahrt) — nach den Nomen 2026-11-09
  'Voruntersuchung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: medizinische Untersuchung vor einer Behandlung — wichtig für Pflege / Recht: vorläufige Ermittlung) — nach den Nomen 2026-11-09
  'Vorwahl', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Telefonvorwahl / Vorwahlen, Primaries) — nach den Nomen 2026-11-09
  'Vorwort', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorrede eines Buches, Pl. -e / österr. Grammatik: Präposition, Pl. -wörter) — nach den Nomen 2026-11-09
  'Vorzeichen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Omen, Anzeichen / Mathematik: Plus-/Minuszeichen / Musik: Versetzungszeichen) — nach den Nomen 2026-11-09
  'Vorzimmer', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Vorraum eines Büros, Sekretariat / österr. Diele, Flur einer Wohnung) — nach den Nomen — 2026-11-09
  'Votum', // zurückgestellt: Plural doppelt (Voten/Vota), meist gehoben/fachsprachlich — Regel 14 — 2026-11-09
  'Vox', // zurückgestellt: Bedeutung/Gebrauch als Nomen unsicher (lat. «Stimme»; sonst Sendername) — Regel 14 — 2026-11-09
  'Waage', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Gerät zum Wiegen / Sternzeichen / Turnen: Standwaage) — nach den Nomen — 2026-11-09
  'Wache', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wachdienst / Wachposten, Person / Polizeiwache) — nach den Nomen — 2026-11-09
  'Wachmann', // zurückgestellt: Plural doppelt (Wachmänner/Wachleute); österr. auch veraltend für Polizist — Regel 14 — 2026-11-09
  'Wachzimmer', // zurückgestellt: österr. für Polizeidienststelle, heute meist «Polizeiinspektion» — Gebrauch/Markierung unsicher — Regel 14 — 2026-11-09
  'Wagen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Auto / Eisenbahnwagen / Karren, Kutsche; Plural auch südd./österr. Wägen) — nach den Nomen — 2026-11-09
  'Wagenburg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kreis aus Wagen zur Verteidigung / Siedlung aus Bauwagen; übertragen: Abschottung) — nach den Nomen — 2026-11-09
  'Waggon', // zurückgestellt: Plural doppelt (Waggons, österr. auch Waggone), Schreibung auch Wagon — Regel 14 — 2026-11-09
  'Wahl', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Abstimmung, Election / Auswahl, Entscheidung / Qualität «erste Wahl») — nach den Nomen — 2026-11-09
  'Wahlberechtigter', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Wahlberechtigte, stark gebeugte Form) — nach den Nomen — 2026-11-09
  'Wahlrecht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Recht zu wählen / Gesamtheit der Vorschriften über Wahlen) — nach den Nomen — 2026-11-09
  'Wahnsinn', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geisteskrankheit / große Unvernunft / ugs. Ausruf «Wahnsinn!» = toll) — nach den Nomen — 2026-11-09
  'Wahrnehmung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sinneswahrnehmung / Wahrnehmung von Interessen, Aufgaben, Terminen) — nach den Nomen — 2026-11-09
  'Waldstatt', // zurückgestellt: historisch, meist Plural «die Waldstätte» (Urkantone der Schweiz) — Gebrauch des Singulars unsicher — Regel 14 — 2026-11-09
  'Walkman', // zurückgestellt: Markenname (Regel 18), Plural doppelt (Walkmans/Walkmen) — 2026-11-09
  'Wallach', // zurückgestellt: Plural doppelt (Wallache, österr. Wallachen) — Regel 14 — 2026-11-09
  'Walter', // zurückgestellt: Personenname (Regel 18) — 2026-11-09
  'Walz', // zurückgestellt: nur in fester Wendung «auf der Walz sein» — Regel 14 — 2026-11-09
  'Walze', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Zylinder, Teil einer Maschine / Straßenwalze / Drehorgel) — nach den Nomen — 2026-11-09
  'Wanderung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wandertour, Ausflug / Migration von Tieren, Völkern) — nach den Nomen — 2026-11-09
  'Wandlung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Veränderung / kath. Liturgie: Wandlung in der Messe) — nach den Nomen — 2026-11-09
  'Wank', // zurückgestellt: Bedeutung unsicher (Bergname? Nomen kaum gebräuchlich) — Regel 14 — 2026-11-09
  'Want', // zurückgestellt: Bedeutung/Herkunft unsicher (kein gebräuchliches deutsches Nomen) — Regel 14 — 2026-11-09
  'Wanze', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Insekt, Bettwanze / Abhörgerät) — nach den Nomen — 2026-11-09
  'Warentest', // zurückgestellt: Plural unsicher (Warentests/Warenteste), oft nur als Name «Stiftung Warentest» — Regel 14/18 — 2026-11-09
  'Warte', // zurückgestellt: gehoben, meist übertragen «von höherer Warte aus»; Sternwarte/Aussichtsturm — Gebrauch unsicher — Regel 14 — 2026-11-09
  'Warteschleife', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Flugzeug kreist vor der Landung / Telefon: Wartemusik) — nach den Nomen — 2026-11-09
  'Wasser', // zurückgestellt: Plural doppelt (Wasser/Wässer, je nach Bedeutung) — Regel 14; häufiges Wort, Entscheidung Lukas — 2026-11-09
  'Wasserball', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sportart Wasserpolo / Ball zum Spielen im Wasser) — nach den Nomen — 2026-11-09
  'Wasserglas', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Trinkglas / Chemie: Natriumsilikat) — nach den Nomen — 2026-11-09
  'Wassermann', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Sternzeichen / Wassergeist im Märchen) — nach den Nomen — 2026-11-09
  'Wasserspiel', // zurückgestellt: meist Plural «Wasserspiele» (Springbrunnenanlage); Bedeutung im Singular unsicher — Regel 14 — 2026-11-09
  'Waterloo', // zurückgestellt: Ortsname, meist übertragen «sein Waterloo erleben» (vernichtende Niederlage) — Regel 14/18 — 2026-11-09
  'Wechsel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Veränderung, Austausch / Geldwechsel / Wertpapier «Wechsel» / Jägersprache: Wildwechsel) — nach den Nomen — 2026-11-09
  'Wechselbad', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Kneipp-Anwendung warm/kalt / übertragen «Wechselbad der Gefühle») — nach den Nomen — 2026-11-09
  'Wechsler', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geldwechsler, Person / Automat für Münzen / CD-Wechsler) — nach den Nomen — 2026-11-09
  'Wedel', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Staubwedel / Palmwedel / Jägersprache: Schwanz beim Wild) — nach den Nomen — 2026-11-09
  'Weg', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Pfad, Straße / Strecke, Route / Methode, Mittel «auf diesem Weg») — nach den Nomen — 2026-11-09
  'Wehrmacht', // zurückgestellt: Name der deutschen Streitkräfte 1935–1945 (historischer Eigenname); allgemeine Bedeutung «Streitkräfte» veraltet — Regel 14/18 — 2026-11-09
  'Wehrmann', // zurückgestellt: schweiz. für Soldat bzw. historisch; Gebrauch unsicher — Regel 14 — 2026-11-09
  'Weib', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: veraltet/landschaftlich «Frau» / abwertend «Frau» / veraltet «Ehefrau») — nach den Nomen — 2026-11-09
  'Weibchen', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: weibliches Tier / abwertend: Frau als Sexualobjekt) — nach den Nomen — 2026-11-09
  'Weibel', // zurückgestellt: schweiz. (Amtsdiener, Unteroffizier); Bedeutung/Gebrauch unsicher — Regel 14 — 2026-11-09
  'Weiblichkeit', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: das Weiblichsein / scherzhaft: alle Frauen) — nach den Nomen — 2026-11-09
  'Weichenstellung', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Stellen der Eisenbahnweiche / übertragen: Richtungsentscheidung) — nach den Nomen — 2026-11-09
  'Weihnachtsgeschichte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: biblische Geburtsgeschichte Jesu / Erzählung, die zu Weihnachten spielt) — nach den Nomen — 2026-11-09
  'Wein', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Getränk / Weinrebe, Weintrauben «Wein anbauen») — nach den Nomen — 2026-11-09
  'Weinfeld', // zurückgestellt: kein gebräuchliches Nomen, wohl Ortsname — Regel 14/18 — 2026-11-09
  'Weingarten', // zurückgestellt: landschaftlich für Weinberg, auch Ortsname — Gebrauch unsicher — Regel 14 — 2026-11-09
  'Weinkeller', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Keller zur Lagerung von Wein / Weinlokal im Keller) — nach den Nomen — 2026-11-09
  'Weinprobe', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Weinverkostung / kleine Menge Wein zum Probieren) — nach den Nomen — 2026-11-09
  'Weinzierl', // zurückgestellt: Familienname — Regel 14/18 — 2026-11-09
  'Weitblick', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fernsicht / Voraussicht, Klugheit) — nach den Nomen — 2026-11-09
  'Weite', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Ausdehnung, Ferne / Breite eines Kleidungsstücks / Sport: erreichte Entfernung) — nach den Nomen — 2026-11-09
  'Weitsicht', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Fernsicht / Voraussicht) — nach den Nomen — 2026-11-09
  'Welle', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wasserwelle / Haarwelle / Technik: Antriebswelle / Physik: Radiowelle) — nach den Nomen — 2026-11-09
  'Weller', // zurückgestellt: Bedeutung unsicher (Bautechnik «Strohlehm» / Familienname) — Regel 14 — 2026-11-09
  'Welt', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Erde / alle Menschen «die ganze Welt» / Lebensbereich «die Welt des Sports») — nach den Nomen — 2026-11-09
  'Weltbank', // zurückgestellt: Name einer Organisation (Weltbank) — Regel 18 — 2026-11-09
  'Weltcup', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Wettbewerbsserie / Pokal als Preis) — nach den Nomen — 2026-11-09
  'Weltgeschichte', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 1 (mehrere Bedeutungen: Geschichte der Menschheit / ugs. scherzhaft «Welt»: in der Weltgeschichte herumreisen) — nach den Nomen — 2026-11-09
  'Weltgesundheitsorganisation', // zurückgestellt: Name einer Organisation (WHO) — Regel 18 — 2026-11-09
  'Weltgruppe', // zurückgestellt: Bedeutung unsicher (Sport: höchste Gruppe, z. B. Davis Cup) — Regel 14 — 2026-11-09
  'Welthandelsorganisation', // zurückgestellt: Name einer Organisation (WTO) — Regel 18 — 2026-11-09
  'Weltorganisation', // zurückgestellt: meist Teil von Organisationsnamen (UNO, WHO), allgemeine Bedeutung unsicher — Regel 14/18 — 2026-11-09
  'Weltranglistenerste', // Vier-Fälle-Liste (Lukas 2026-10-19): Fall 4 (substantiviertes Adjektiv: der/die Weltranglistenerste) — nach den Nomen — 2026-11-09
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
  final anzahl = args.isNotEmpty ? int.parse(args.first) : 20;
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
