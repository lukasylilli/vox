# GRAMMATIK_MAP — VOX
# Vollständige Seiten-Map des Grammatik-Bereichs
# Stand: 2026-09-16 · Stufen G1–G6 umgesetzt (alle 84 Kern-Lektionen live) · G7a: 336 Übungen live · G7b: Niveau-Test A1–C2 live

> **Pflegeregeln (bei jeder Stufe aktualisieren!):**
> 1. Neue Inhalte ⇒ Eintrag im Master-Katalog unten **und** in `assets/data/grammatik_katalog.json` ergänzen/Status ändern.
> 2. Stufen-Fortschritt ⇒ Abschnitt „Stufenplan" hier + فاز G in `PLAN.md` abhaken.
> 3. Jede Änderung ⇒ Zeile im Änderungsprotokoll (unten).
> 4. Quelle der 84 Kern-Lektionen: `old files Lukasalmani/1/Grammatik` (vollständige JSON-Inhalte, dreisprachig DE/FA/EN, mit Tabellen + Beispielen + Übungen). Weitere Quellen folgen vom Nutzer.
> 5. **⭐ Zweisprachigkeits-Pflicht (فاز L3, PROJECT_MAP اصل ۵):** Jeder neue Inhalt wird von
>    Anfang an FA **und** EN angelegt — beim G3–G6-Import MÜSSEN die `*En`-Felder der Quelle
>    (titleEN, bodyEN, meaningEN, headingEN, …) mit importiert werden; Screens rendern nie
>    `*Fa` direkt (nur `AppL10n.meaning`/`isFa`/`_loc`-Muster). Deutsch bleibt unantastbar.

---

## 1. Prinzip

Der Grammatik-Bereich soll **die gesamte deutsche Grammatik** abdecken und wächst stufenweise.
Ein einziger **Katalog** (`assets/data/grammatik_katalog.json`) ist die Quelle der Wahrheit:
jeder Grammatik-Inhalt der App ist genau **ein Eintrag** darin — egal ob der Inhalt als
eigenes Feature (Konnektoren, NVV, …), als generisches Thema (`/grammatik/thema/:id`) oder
später als Katalog-Lektion gerendert wird. Die Ansichten sind nur **verschiedene Sortierungen
desselben Katalogs** (Referenz, keine Kopie — wie bei `words`).

**Neuer Inhalt = 1 Katalog-Eintrag (+ ggf. 1 Content-JSON). Keine neuen Screens nötig.**

## 2. Seiten-Map (Routen)

```
/grammatik                        GrammatikHomeScreen
│                                 └─ Ansicht-Umschalter (persistiert):
│                                    Niveau · Thema · Lektionen · Satzglieder
│
├─ /grammatik/katalog/:view/:key  GrammatikKatalogScreen (parametrisch, EIN Screen)
│      view = niveau    key = a1|a2|b1|b2|c1|c2     (gruppiert nach Thema)
│      view = thema     key = verben|tempus|…        (15 Themen)
│      view = satzglied key = praedikat|…            (7 Gruppen)
│      Eintrag-Tap:  route gesetzt → push(route) · sonst → „به‌زودی"-Snackbar
│
├─ /grammatik/thema/:topicId      GrammarTopicScreen (generisch, Phase 15)
│      live: passiv · zu-dass · tempusformen · kasus · modalverben
│
├─ /grammatik/lektion/:slug       [Stufe G2] GrammatikLektionScreen (parametrisch)
│      rendert Content-JSON: explanationBlocks + examples + tables + related
│      └─ /uebung                 [G7a ✅] GrammatikUebungScreen — Übungen der Lektion nacheinander
│
├─ /grammatik/lesson/:lessonId    LessonDetailScreen (DB-Lektionen, Alt-System)
│      └─ /exercise · /quiz
├─ /grammatik/quiz-niveau/:level  [G7b ✅] GrammatikNiveauTestScreen — Einführung → 10 Zufallsfragen → bestanden ab 70 %
│      Einstieg: NiveauTestKarte oben in /grammatik/katalog/niveau/:key
└─ /grammatik/:level              LevelLessonsScreen (DB-Lektionen pro Niveau)
       erreichbar als „Lektionen & Übungen"-Kachel in der Niveau-Ansicht

Externe Grammatik-Screens (eigene Features, im Katalog referenziert):
/konnektoren/grammar · /dativ-verben/grammar · /nvv/grammar
/praepositionen/grammar · /reflexiv/grammar · /trennbar/grammar
/verb-praep/grammar · /unregelm-verben/grammar · /modalverben/grammar
/redemittel-1010/grammar
```

**GoRouter-Reihenfolge:** `katalog/:view/:key`, `thema/:topicId`, `lektion/:slug`,
`lesson/:lessonId`, `quiz-niveau/:level` **vor** `:level` registrieren.

## 3. Sortier-Ansichten (vom Nutzer umschaltbar)

| Ansicht | Gruppierung | Inhalt |
|---|---|---|
| **Niveau** | A1–C2 (6 Karten) | Einträge, deren `niveaus` das Level enthalten; in der Liste nach Thema gruppiert. Zusatz-Kachel → DB-Lektionen (`/grammatik/:level`) |
| **Thema** | 15 Themen | verben · tempus · passiv · konjunktiv · verbergaenzungen · ergaenzungssaetze · nomen · artikel · adjektive · adverbien · pronomen · praepositionen · satzlehre · nebensaetze · wendungen |
| **Lektionen** | linearer Lernpfad | Lektion 1–84 (sortiert: Mindest-Niveau → didaktische Blockfolge der Quelle) + Abschnitt „Vertiefung & Überblick" (Einträge ohne Nummer) |
| **Satzglieder** | 7 Gruppen | praedikat · ergaenzungen · nominalgruppe · attribute · angaben · satzverbindung · sonstiges |
| *(später)* Alphabetisch | A–Z Glossar | Stufe G8, billig aus dem Katalog ableitbar |

Der gewählte Modus wird in `shared_preferences` gespeichert (`grammatik_sort_mode`).

## 4. Datenarchitektur

| Datei | Rolle |
|---|---|
| `assets/data/grammatik_katalog.json` | **Master-Katalog**: `themen[]`, `satzglieder[]`, `eintraege[]` (slug, de, fa, en, niveaus, thema, satzglied, lektion, route) |
| `assets/data/grammatik/<thema>.json` | Content-JSONs der Kern-Lektionen (dreisprachig; Schema: explanationBlocks/examples/tables/relatedSlugs). seit G3–G6 (2026-09-16): **17 Dateien, 84 Lektionen** (verben-grundlagen, verben-erweitert, tempus, passiv, konjunktiv, verbergaenzungen, ergaenzungssaetze, nomen, artikel, adjektive, adverbien, pronomen, praepositionen, satzlehre-misc, satzlehre-grundlagen, nebensaetze-semantisch, temporalsaetze — Namen wie in der Quelle); Liste `grammatikContentFiles` im Controller. **pubspec: `assets/data/grammatik/` deklariert (nicht rekursiv!)** |
| `lib/features/grammatik/models/grammatik_lektion.dart` | G2: Lektion-Content-Model (Block/Example/Table) |
| `lib/features/grammatik/controllers/grammatik_lektion_controller.dart` | G2: lädt `_contentFiles`, indexiert nach slug |
| `lib/features/grammatik/screens/grammatik_lektion_screen.dart` | G2: Renderer (route `/grammatik/lektion/:slug`) |
| `lib/features/grammatik/models/grammar_catalog.dart` | Models: `GrammatikKatalog`, `KatalogEintrag`, `KatalogThema`, `KatalogSatzglied` |
| `lib/features/grammatik/controllers/grammar_catalog_controller.dart` | `katalogProvider` (Asset laden) + `grammatikSortModeProvider` (persistiert) |
| `lib/features/grammatik/screens/grammatik_home_screen.dart` | Home mit 4 Ansichten |
| `lib/features/grammatik/screens/grammatik_katalog_screen.dart` | parametrische Liste |

**Status-Logik im Katalog:** `route != null` ⇒ live (Navigation) · `route == null` ⇒ geplant
(Snackbar). Ab G2/G3 bekommen importierte Lektionen `route: /grammatik/lektion/<slug>`.

## 5. Stufenplan (Details: PLAN.md → فاز G)

| Stufe | Inhalt | Status |
|---|---|---|
| **G1** | Katalog-JSON (93 Einträge) + Models + Controller + Home mit 4 Ansichten + Katalog-Screen + Router | ✅ 2026-07-06 |
| **G2** | `GrammatikLektionScreen` — Renderer für Content-JSON (Blocks, Beispiele, Tabellen, related) | ✅ 2026-07-07 |
| **G3** | Content-Import I: verben-grundlagen (9) + tempus (5) + passiv (4) + konjunktiv (7) | ✅ 2026-09-16 |
| **G4** | Content-Import II: verbergaenzungen (5) + ergaenzungssaetze (3) + nomen (6) + artikel (6) | ✅ 2026-09-16 |
| **G5** | Content-Import III: adjektive (4) + adverbien (4) + pronomen (5) + praepositionen (5) | ✅ 2026-09-16 |
| **G6** | Content-Import IV: satzlehre (9) + nebensaetze (7) + temporalsaetze (5) → **alle 84 live** | ✅ 2026-09-16 |
| **G7a** | 336 Übungen der Quelle (5 Arten) in jeder Lektion, Route `/grammatik/lektion/:slug/uebung` | ✅ 2026-09-16 |
| **G7b** | Kombiniertes Niveau-Quiz A1–C2 (Quelle: 10 Fragen, Bestehen ab 70 %) | ✅ 2026-09-16 |
| **G7c** | Übungen aus den Beispielsätzen der Lektionen (nur Formen, die ohne Raten richtig sind) | [ ] |
| **G7d** | Übungen für Redemittel und weitere Decks | [ ] |
| **G8** | Integration: Global Search, Leitner-Verknüpfung, Glossar A–Z, neue Nutzer-Quellen einpflegen | [ ] |

Bei jeder Stufe: Status-Spalten hier + Katalog-JSON + PLAN.md aktualisieren.

## 6. Master-Katalog (93 Einträge)

Lekt. = Position im linearen Lernpfad („Lektionen"-Ansicht) · — = Vertiefung/Überblick (unnummeriert)

| Lekt. | Slug | Titel (DE) | عنوان (FA) | Niveau | Thema | Satzglied | Status |
|---|---|---|---|---|---|---|---|
| 1 | `konjugation-praesens` | Konjugation im Präsens | صرف فعل در زمان حال | A1 | verben | praedikat | LIVE → `/grammatik/lektion/konjugation-praesens` |
| 2 | `verb-sein` | Das Verb 'sein' | فعل «sein» (بودن) | A1 | verben | praedikat | LIVE → `/grammatik/lektion/verb-sein` |
| 3 | `verb-haben` | Das Verb 'haben' | فعل «haben» (داشتن) | A1 | verben | praedikat | LIVE → `/grammatik/lektion/verb-haben` |
| 4 | `regelmaessige-verben` | Regelmäßige Verben | افعال باقاعده | A1 | verben | praedikat | LIVE → `/grammatik/lektion/regelmaessige-verben` |
| 5 | `trennbare-verben` | Trennbare Verben | افعال جداشدنی | A1·A2 | verben | praedikat | LIVE → `/trennbar/grammar` |
| 6 | `modalverben` | Modalverben | افعال وجهی | A1·A2 | verben | praedikat | LIVE → `/modalverben/grammar` |
| 7 | `imperativ` | Der Imperativ | حالت امری | A1·A2 | verben | praedikat | LIVE → `/grammatik/lektion/imperativ` |
| 8 | `perfekt` | Das Perfekt | زمان Perfekt (گذشتهٔ نقلی) | A1·A2 | tempus | praedikat | LIVE → `/grammatik/lektion/perfekt` |
| 9 | `nominativergaenzung` | Die Nominativergänzung | متمم Nominativ | A1·A2 | verbergaenzungen | ergaenzungen | LIVE → `/grammatik/lektion/nominativergaenzung` |
| 10 | `akkusativergaenzung` | Die Akkusativergänzung | متمم Akkusativ | A1 | verbergaenzungen | ergaenzungen | LIVE → `/grammatik/lektion/akkusativergaenzung` |
| 11 | `genusbestimmung` | Genusbestimmung | تشخیص جنسیت دستوری اسم | A1 | nomen | nominalgruppe | LIVE → `/grammatik/lektion/genusbestimmung` |
| 12 | `pluralbildung` | Die Pluralbildung | ساخت شکل جمع اسم | A1·A2 | nomen | nominalgruppe | LIVE → `/grammatik/lektion/pluralbildung` |
| 13 | `bestimmter-unbestimmter-artikel` | Bestimmter und unbestimmter Artikel | آرتیکل معین و نامعین | A1 | artikel | nominalgruppe | LIVE → `/grammatik/lektion/bestimmter-unbestimmter-artikel` |
| 14 | `possessivartikel` | Der Possessivartikel | آرتیکل ملکی | A1·A2 | artikel | nominalgruppe | LIVE → `/grammatik/lektion/possessivartikel` |
| 15 | `zahlwoerter` | Zahlwörter | اعداد | A1·A2 | adjektive | attribute | LIVE → `/grammatik/lektion/zahlwoerter` |
| 16 | `lokaladverbien` | Lokaladverbien | قید مکان | A1·A2 | adverbien | angaben | LIVE → `/grammatik/lektion/lokaladverbien` |
| 17 | `temporaladverbien` | Temporaladverbien | قید زمان | A1·A2 | adverbien | angaben | LIVE → `/grammatik/lektion/temporaladverbien` |
| 18 | `personalpronomen` | Personalpronomen | ضمیر شخصی | A1 | pronomen | nominalgruppe | LIVE → `/grammatik/lektion/personalpronomen` |
| 19 | `praepositionen-akkusativ` | Präpositionen mit Akkusativ | حرف‌اضافه با Akkusativ | A1·A2 | praepositionen | angaben | LIVE → `/grammatik/lektion/praepositionen-akkusativ` |
| 20 | `praepositionen-dativ` | Präpositionen mit Dativ | حرف‌اضافه با Dativ | A1·A2 | praepositionen | angaben | LIVE → `/grammatik/lektion/praepositionen-dativ` |
| 21 | `fragewoerter` | Fragewörter | کلمات پرسشی | A1·A2 | satzlehre | satzverbindung | LIVE → `/grammatik/lektion/fragewoerter` |
| 22 | `die-vier-faelle` | Die vier Fälle (Kasus) | چهار حالت دستوری (Kasus) | A1·A2·B1 | satzlehre | ergaenzungen | LIVE → `/grammatik/thema/kasus` |
| 23 | `negation-verneinung` | Negation (Verneinung) | نفی (Verneinung) | A1·A2 | satzlehre | angaben | LIVE → `/grammatik/lektion/negation-verneinung` |
| 24 | `satzarten` | Satzarten | انواع جمله | A1·A2 | satzlehre | satzverbindung | LIVE → `/grammatik/lektion/satzarten` |
| 25 | `unregelmaessige-verben` | Unregelmäßige Verben | افعال بی‌قاعده | A2·B1 | verben | praedikat | LIVE → `/unregelm-verben/grammar` |
| 26 | `reflexive-verben` | Reflexive Verben | افعال انعکاسی | A2·B1 | verben | praedikat | LIVE → `/reflexiv/grammar` |
| 27 | `praeteritum` | Das Präteritum | زمان Präteritum (گذشتهٔ ساده) | A2·B1 | tempus | praedikat | LIVE → `/grammatik/lektion/praeteritum` |
| 28 | `hoeflichkeit-konjunktiv` | Höflichkeit mit Konjunktiv II | مؤدبانه‌گویی با کونیونکتیو II | A2·B1 | konjunktiv | praedikat | LIVE → `/grammatik/lektion/hoeflichkeit-konjunktiv` |
| 29 | `dativergaenzung` | Die Dativergänzung | متمم Dativ | A2 | verbergaenzungen | ergaenzungen | LIVE → `/grammatik/lektion/dativergaenzung` |
| 30 | `dativ-akkusativ-ergaenzung` | Dativ- und Akkusativergänzung | متمم دوگانهٔ Dativ و Akkusativ | A2·B1 | verbergaenzungen | ergaenzungen | LIVE → `/grammatik/lektion/dativ-akkusativ-ergaenzung` |
| 31 | `dass-saetze` | Dass-Sätze | جملات متممی با «dass» | A2·B1 | ergaenzungssaetze | ergaenzungen | LIVE → `/grammatik/lektion/dass-saetze` |
| 32 | `indirekte-fragesaetze` | Indirekte Fragesätze | سؤالات غیرمستقیم | A2·B1 | ergaenzungssaetze | ergaenzungen | LIVE → `/grammatik/lektion/indirekte-fragesaetze` |
| 33 | `komposita` | Komposita | اسم‌های مرکب | A2·B1 | nomen | nominalgruppe | LIVE → `/grammatik/lektion/komposita` |
| 34 | `nullartikel` | Der Nullartikel | بدون آرتیکل (Nullartikel) | A2·B1 | artikel | nominalgruppe | LIVE → `/grammatik/lektion/nullartikel` |
| 35 | `demonstrativartikel` | Der Demonstrativartikel | آرتیکل اشاره | A2·B1 | artikel | nominalgruppe | LIVE → `/grammatik/lektion/demonstrativartikel` |
| 36 | `indefinitartikel` | Der Indefinitartikel | آرتیکل نامعین کمّی | A2·B1 | artikel | nominalgruppe | LIVE → `/grammatik/lektion/indefinitartikel` |
| 37 | `interrogativartikel` | Der Interrogativartikel | آرتیکل پرسشی | A2·B1 | artikel | nominalgruppe | LIVE → `/grammatik/lektion/interrogativartikel` |
| 38 | `adjektivdeklination` | Die Adjektivdeklination | صرف صفت (Adjektivdeklination) | A2·B1·B2 | adjektive | attribute | LIVE → `/grammatik/lektion/adjektivdeklination` |
| 39 | `komparativ-superlativ` | Komparativ und Superlativ | صفت تفضیلی و عالی | A2·B1 | adjektive | attribute | LIVE → `/grammatik/lektion/komparativ-superlativ` |
| 40 | `modaladverbien` | Modaladverbien | قید حالت/کیفیت | A2·B1 | adverbien | angaben | LIVE → `/grammatik/lektion/modaladverbien` |
| 41 | `indefinitpronomen` | Indefinitpronomen | ضمیر نامعین | A2·B1 | pronomen | nominalgruppe | LIVE → `/grammatik/lektion/indefinitpronomen` |
| 42 | `wechselpraepositionen` | Wechselpräpositionen | حرف‌اضافهٔ دوگانه (Wechselpräpositionen) | A2·B1 | praepositionen | angaben | LIVE → `/grammatik/lektion/wechselpraepositionen` |
| 43 | `lokale-temporale-praepositionen` | Lokale und temporale Präpositionen | حرف‌اضافهٔ مکانی و زمانی | A2·B1 | praepositionen | angaben | LIVE → `/grammatik/lektion/lokale-temporale-praepositionen` |
| 44 | `konjunktionen` | Konjunktionen (koordinierend) | حروف ربط هم‌پایه‌ساز | A2·B1 | satzlehre | satzverbindung | LIVE → `/grammatik/lektion/konjunktionen` |
| 45 | `nebensaetze-einfuehrung` | Einführung in Nebensätze | مقدمهٔ جملات وابسته (Nebensätze) | A2·B1 | satzlehre | satzverbindung | LIVE → `/grammatik/lektion/nebensaetze-einfuehrung` |
| 46 | `kausalsaetze` | Kausalsätze | جملات علّی (بیان دلیل) | A2·B1 | nebensaetze | satzverbindung | LIVE → `/grammatik/lektion/kausalsaetze` |
| 47 | `konditionalsaetze` | Konditionalsätze (real) | جملات شرطی (واقعی) | A2·B1 | nebensaetze | satzverbindung | LIVE → `/grammatik/lektion/konditionalsaetze` |
| 48 | `wenn-als` | Wenn oder als? | تفاوت «wenn» و «als» | A2·B1 | nebensaetze | satzverbindung | LIVE → `/grammatik/lektion/wenn-als` |
| 49 | `waehrend-temporal` | Während (temporal) | «während» (به‌معنای زمانی) | A2·B1 | nebensaetze | satzverbindung | LIVE → `/grammatik/lektion/waehrend-temporal` |
| 50 | `bevor-nachdem` | Bevor und nachdem | «bevor» و «nachdem» | A2·B1 | nebensaetze | satzverbindung | LIVE → `/grammatik/lektion/bevor-nachdem` |
| 51 | `plusquamperfekt` | Das Plusquamperfekt | زمان ماقبل ماضی (Plusquamperfekt) | B1·B2 | tempus | praedikat | LIVE → `/grammatik/lektion/plusquamperfekt` |
| 52 | `futur-1` | Das Futur I | زمان آیندهٔ ساده (Futur I) | B1 | tempus | praedikat | LIVE → `/grammatik/lektion/futur-1` |
| 53 | `vorgangspassiv` | Das Vorgangspassiv | مجهول جریانی (Vorgangspassiv) | B1·B2 | passiv | praedikat | LIVE → `/grammatik/lektion/vorgangspassiv` |
| 54 | `zustandspassiv` | Das Zustandspassiv | مجهول حالتی (Zustandspassiv) | B1·B2 | passiv | praedikat | LIVE → `/grammatik/lektion/zustandspassiv` |
| 55 | `konjunktiv-2-gegenwart` | Konjunktiv II – Gegenwart | کونیونکتیو II — زمان حال | B1·B2 | konjunktiv | praedikat | LIVE → `/grammatik/lektion/konjunktiv-2-gegenwart` |
| 56 | `wunschsaetze` | Wunschsätze | جملات آرزویی | B1·B2 | konjunktiv | praedikat | LIVE → `/grammatik/lektion/wunschsaetze` |
| 57 | `irreale-bedingungssaetze` | Irreale Bedingungssätze | جملات شرطی غیرواقعی | B1·B2 | konjunktiv | praedikat | LIVE → `/grammatik/lektion/irreale-bedingungssaetze` |
| 58 | `praepositionalergaenzung` | Die Präpositionalergänzung | متمم حرف‌اضافه‌ای | B1·B2 | verbergaenzungen | ergaenzungen | LIVE → `/grammatik/lektion/praepositionalergaenzung` |
| 59 | `infinitivsaetze` | Infinitivsätze mit 'zu' | جملات مصدری با «zu» | B1·B2 | ergaenzungssaetze | ergaenzungen | LIVE → `/grammatik/lektion/infinitivsaetze` |
| 60 | `n-deklination` | Die n-Deklination | صرف اسم با -n (n-Deklination) | B1·B2 | nomen | nominalgruppe | LIVE → `/grammatik/lektion/n-deklination` |
| 61 | `genitiv` | Der Genitiv | حالت Genitiv (مالکیت) | B1·B2 | nomen | nominalgruppe | LIVE → `/grammatik/lektion/genitiv` |
| 62 | `partizipien-als-adjektive` | Partizipien als Adjektive | Partizip به‌عنوان صفت | B1·B2 | adjektive | attribute | LIVE → `/grammatik/lektion/partizipien-als-adjektive` |
| 63 | `partikeln` | Partikeln (Modalpartikeln) | واژه‌های تأکیدی (Partikeln) | B1·B2 | adverbien | angaben | LIVE → `/grammatik/lektion/partikeln` |
| 64 | `demonstrativpronomen` | Demonstrativpronomen | ضمیر اشاره | B1·B2 | pronomen | nominalgruppe | LIVE → `/grammatik/lektion/demonstrativpronomen` |
| 65 | `relativpronomen-relativsaetze` | Relativpronomen und Relativsätze | ضمیر موصولی و جملات موصولی | B1·B2 | pronomen | attribute | LIVE → `/grammatik/lektion/relativpronomen-relativsaetze` |
| 66 | `pronomen-es` | Das Pronomen 'es' | ضمیر «es» | B1·B2 | pronomen | nominalgruppe | LIVE → `/grammatik/lektion/pronomen-es` |
| 67 | `praepositionen-genitiv` | Präpositionen mit Genitiv | حرف‌اضافه با Genitiv | B1·B2 | praepositionen | angaben | LIVE → `/grammatik/lektion/praepositionen-genitiv` |
| 68 | `attribute` | Attribute | صفات و وابسته‌های توصیفی (Attribute) | B1·B2 | satzlehre | attribute | LIVE → `/grammatik/lektion/attribute` |
| 69 | `satzverbindende-adverbien` | Satzverbindende Adverbien | قیدهای ربطی | B1·B2 | satzlehre | satzverbindung | LIVE → `/grammatik/lektion/satzverbindende-adverbien` |
| 70 | `angaben` | Angaben | قیدهای اضافی (Angaben) | B1·B2 | satzlehre | angaben | LIVE → `/grammatik/lektion/angaben` |
| 71 | `konzessivsaetze` | Konzessivsätze | جملات امتیازی/تقابلی (وجود مانع) | B1·B2 | nebensaetze | satzverbindung | LIVE → `/grammatik/lektion/konzessivsaetze` |
| 72 | `finalsaetze` | Finalsätze | جملات هدف (غایی) | B1·B2 | nebensaetze | satzverbindung | LIVE → `/grammatik/lektion/finalsaetze` |
| 73 | `adversativsaetze` | Adversativsätze | جملات تقابلی | B1·B2 | nebensaetze | satzverbindung | LIVE → `/grammatik/lektion/adversativsaetze` |
| 74 | `seitdem-sobald` | Seitdem und sobald | «seitdem» و «sobald» | B1·B2 | nebensaetze | satzverbindung | LIVE → `/grammatik/lektion/seitdem-sobald` |
| 75 | `solange-bis` | Solange und bis | «solange» و «bis» | B1·B2 | nebensaetze | satzverbindung | LIVE → `/grammatik/lektion/solange-bis` |
| 76 | `futur-2` | Das Futur II | زمان آیندهٔ کامل (Futur II) | B2·C1 | tempus | praedikat | LIVE → `/grammatik/lektion/futur-2` |
| 77 | `passiversatz` | Passiversatzformen | جایگزین‌های مجهول | B2·C1 | passiv | praedikat | LIVE → `/grammatik/lektion/passiversatz` |
| 78 | `nicht-passivfaehige-verben` | Nicht passivfähige Verben | افعال غیرقابل‌مجهول‌شدن | B2 | passiv | praedikat | LIVE → `/grammatik/lektion/nicht-passivfaehige-verben` |
| 79 | `konjunktiv-2-vergangenheit` | Konjunktiv II – Vergangenheit | کونیونکتیو II — زمان گذشته | B2·C1 | konjunktiv | praedikat | LIVE → `/grammatik/lektion/konjunktiv-2-vergangenheit` |
| 80 | `irreale-vergleichssaetze` | Irreale Vergleichssätze | جملات مقایسه‌ای غیرواقعی | B2·C1 | konjunktiv | praedikat | LIVE → `/grammatik/lektion/irreale-vergleichssaetze` |
| 81 | `nominalisierung` | Nominalisierung | اسم‌سازی از فعل و صفت | B2·C1 | nomen | nominalgruppe | LIVE → `/grammatik/lektion/nominalisierung` |
| 82 | `modalsaetze` | Modalsätze | جملات حالت/شیوه | B2·C1 | nebensaetze | satzverbindung | LIVE → `/grammatik/lektion/modalsaetze` |
| 83 | `konsekutivsaetze` | Konsekutivsätze | جملات نتیجه‌ای | B2·C1 | nebensaetze | satzverbindung | LIVE → `/grammatik/lektion/konsekutivsaetze` |
| 84 | `konjunktiv-1` | Konjunktiv I – Indirekte Rede | کونیونکتیو I — نقل قول غیرمستقیم | C1·C2 | konjunktiv | praedikat | LIVE → `/grammatik/lektion/konjunktiv-1` |
| — | `tempusformen-ueberblick` | Tempusformen im Überblick | کدام زمان برای کدام کار؟ | A2·B1·B2 | tempus | praedikat | LIVE → `/grammatik/thema/tempusformen` |
| — | `passiv-ueberblick` | Passiv im Überblick | مجهول — ساخت، es، ۶ نوع مجهول | B1·B2 | passiv | praedikat | LIVE → `/grammatik/thema/passiv` |
| — | `zu-dass` | zu und dass | دو فعل در یک جمله — zu، dass، um...zu، damit | A2·B1 | ergaenzungssaetze | ergaenzungen | LIVE → `/grammatik/thema/zu-dass` |
| — | `konnektoren` | Konnektoren | کانکتورها و روابط جمله‌ای | B1·B2 | satzlehre | satzverbindung | LIVE → `/konnektoren/grammar` |
| — | `dativ-verben` | Dativ- und Akkusativ-Verben | افعال با Dativ و Akkusativ | A2·B1 | verbergaenzungen | ergaenzungen | LIVE → `/dativ-verben/grammar` |
| — | `verb-praep` | Verben mit Präpositionen | افعال با حرف اضافه‌ی ثابت | B1·B2 | praepositionen | ergaenzungen | LIVE → `/verb-praep/grammar` |
| — | `praepositionen-cluster` | Präpositionen-Cluster (Verb/Adjektiv/Nomen) | فعل/صفت/اسم با حرف اضافه | B1·B2 | praepositionen | ergaenzungen | LIVE → `/praepositionen/grammar` |
| — | `nvv` | Nomen-Verb-Verbindungen | ترکیب‌های اسم-فعل (NVV) | B2·C1 | wendungen | praedikat | LIVE → `/nvv/grammar` |
| — | `redemittel-1010` | Redemittel (1010) | ۹۰۸ عبارت کاربردی — Diskussion · Essay · Brief | B2·C1 | wendungen | sonstiges | LIVE → `/redemittel-1010/grammar` |

## 7. Änderungsprotokoll

| Datum | Stufe | Änderung |
|---|---|---|
| 2026-07-06 | G0/G1 | Map erstellt aus `old files Lukasalmani/1/Grammatik` (84 Kern-Lektionen extrahiert) + 9 Bestands-Einträge verknüpft. Katalog-Infrastruktur mit 4 Sortier-Ansichten implementiert. |
| 2026-07-07 | G2 | `GrammatikLektionScreen` + Model + Controller + Route `/grammatik/lektion/:slug` gebaut. 4 echte Lektionen aus verben-grundlagen importiert (assets/data/grammatik/verben-grundlagen.json) → live geschaltet. Quelle ist teils unvollständig; G3–G6 extrahieren die restlichen 80 Lektionen. |
| 2026-07-07 | — | Querschnitt (فاز B/L/L2): Grammatik-Screens auf VoxButton/VoxOptionButton umgestellt; alle UI-Labels der Grammatik-Screens laufen über AppL10n (FA/EN aus Settings); `grammatik_katalog.json`-Einträge haben `en`-Titel (Modell liest sie noch nicht — bei G2 mit einbauen: Eintrag-Untertitel locale-aware statt fix `fa`). |
| 2026-09-16 | G3–G6 | **Alle 84 Kern-Lektionen live.** Die Quelle war NICHT unvollständig (Notiz vom 2026-07-07 korrigiert): sie enthält 17 vollständige JSON-Dokumente, die sich einzeln herauslösen lassen (je ab dem `{` vor `"_index"`); das schon vorhandene `verben-grundlagen.json` ist mit dem Quell-Dokument byte-gleich. Übernommen **unverändert**, Dateinamen aus den Quell-Hinweisen `Resources/JSON/Grammar/<name>.json`. 75 Katalog-Einträge bekamen `route: /grammatik/lektion/<slug>`. **Bewusst unverändert:** 5 Einträge mit eigenem Feature-Screen (trennbare-verben, modalverben, unregelmaessige-verben, reflexive-verben, die-vier-faelle) — ihre Lektion ist über `/grammatik/lektion/<slug>` und die Querverweise erreichbar. **Gefunden und behoben:** die Quelle schreibt `columns` auf zwei Arten (mit/ohne Überschrift der Beschriftungsspalte) — `GrammatikTable.fromJson` vereinheitlicht das; vorher konnten die Tabellen von `verb-sein`/`verb-haben` nicht gezeichnet werden. 3 Tabellen mit `style: interactiveGrid` (Adjektivdeklination) werden als normale Tabelle gezeigt; das Üben daran gehört zu G7. 8 Querverweise der Quelle zeigen auf Slugs ohne Lektion (z. B. `temporalsaetze`, `artikel`) — sie werden wie bisher still ausgelassen, nicht geraten. Wächter: `test/grammatik_lektionen_test.dart` (Dateien ↔ Liste, Lektion ↔ Katalog, Tabellen darstellbar, dreisprachig, alle 84 Lektionen in EN und FA gezeichnet). |
| 2026-09-16 | G7a | **336 Übungen live** (multipleChoice 85 · fillBlank 82 · wordOrder 67 · transform 51 · matching 51), Daten **unverändert** aus `assets/data/grammatik/*.json` (`exercises`). Modell + einzige Bewertungsstelle: `models/grammatik_uebung.dart`; Anzeige: `widgets/uebung_karte.dart` (deutscher Text immer LTR), Folge + Ergebnis: `widgets/uebungs_sitzung.dart` (für G7b wiederverwendbar), Seite: `screens/grammatik_uebung_screen.dart`; Knopf „تمرین این درس (n)" oben und unten in jeder Lektion. **Befunde der Quelle, im Code aufgefangen:** `alternatives` bei fillBlank sind immer falsche Wahlmöglichkeiten (82/82) · 4 wordOrder mit überzähligem/großgeschriebenem Kärtchen (ex-interr-4, ex-indefpron-4, ex-waehrend-4, ex-genitiv-4) ⇒ übrige Kärtchen erlaubt, Vergleich ohne Groß-/Kleinschreibung und Satzzeichen · 7 matching mit gleichen rechten Werten ⇒ Auswahl aus den verschiedenen Werten · **`ex-komp-1…4` gibt es zweimal** (komparativ-superlativ und komposita) ⇒ eindeutig ist nur Lektion + id (`schluessel`). transform wird streng geprüft (nur Leerzeichen/Anführungszeichen/Schlusszeichen egal); „نمایش جواب" zählt als falsch. Ergebnisse werden nicht gespeichert (Training, kein Lernstand). Wächter: `test/grammatik_uebungen_test.dart` (alle 336 lesbar, je Lektion genau `exerciseSlugs`, eigene Lösung richtig / falsche falsch, jede Übung in EN und FA per Tippen gelöst, Sitzung zählt). |
| 2026-09-16 | G7b | **Niveau-Test A1–C2 live.** Einstellungen: `assets/data/grammatik_niveautest.json` — das Quell-Dokument, das sich selbst „einzige Quelle der Einstellungen" nennt, **unverändert** übernommen (10 Fragen, 70 %, A1–C2; das zweite, gleichlautende Konfig-Dokument der Quelle unterscheidet sich nur in der Beschreibung). Modell: `models/grammatik_niveautest.dart` (Prüfung der Einstellungen, Vorrat, Ziehen); Seite: `screens/grammatik_niveautest_screen.dart` (Einführung → Sitzung mit Bestehensgrenze → „آزمون تازه" zieht neu) + `NiveauTestKarte` oben in der Niveau-Ansicht des Katalogs; Route `quiz-niveau/:level` vor `:level`. **Entscheidung (Claude):** Fragen **ohne `transform`** — frei getippt und streng verglichen wäre eine andere richtige Formulierung im Test ein Fehler. Vorrat je Niveau: A1 86 · A2 146 · B1 170 · B2 107 · C1 24 · **C2 nur 3** (eine einzige C2-Lektion in der Quelle) ⇒ der C2-Test hat 3 Fragen; nichts wird aufgefüllt. Ergebnis wird **nicht gespeichert** (offene Frage an Lukas). Wächter: `test/grammatik_niveautest_test.dart`. |
