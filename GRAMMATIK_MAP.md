# GRAMMATIK_MAP — VOX
# Vollständige Seiten-Map des Grammatik-Bereichs
# Stand: 2026-07-06 · Stufe G1 umgesetzt

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
│      └─ /uebung                 [Stufe G6] Übungen zur Lektion
│
├─ /grammatik/lesson/:lessonId    LessonDetailScreen (DB-Lektionen, Alt-System)
│      └─ /exercise · /quiz
├─ /grammatik/quiz-niveau/:level  [Stufe G7] kombiniertes Niveau-Quiz
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
| `assets/data/grammatik/<thema>.json` | Content-JSONs der Kern-Lektionen (dreisprachig; Schema: explanationBlocks/examples/tables/relatedSlugs). ab G2: verben-grundlagen.json (4 live); G3–G6 folgen. **pubspec: `assets/data/grammatik/` deklariert (nicht rekursiv!)** |
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
| **G3** | Content-Import I: verben-grundlagen (9) + tempus (5) + passiv (4) + konjunktiv (7) | [ ] |
| **G4** | Content-Import II: verbergaenzungen (5) + ergaenzungssaetze (3) + nomen (6) + artikel (6) | [ ] |
| **G5** | Content-Import III: adjektive (4) + adverbien (4) + pronomen (5) + praepositionen (5) | [ ] |
| **G6** | Content-Import IV: satzlehre (9) + nebensaetze (7) + temporalsaetze (5) → **alle 84 live** | [ ] |
| **G7** | Übungen pro Lektion (Quelle enthält exerciseSlugs) + kombiniertes Niveau-Quiz A1–C2 | [ ] |
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
| 7 | `imperativ` | Der Imperativ | حالت امری | A1·A2 | verben | praedikat | geplant |
| 8 | `perfekt` | Das Perfekt | زمان Perfekt (گذشتهٔ نقلی) | A1·A2 | tempus | praedikat | geplant |
| 9 | `nominativergaenzung` | Die Nominativergänzung | متمم Nominativ | A1·A2 | verbergaenzungen | ergaenzungen | geplant |
| 10 | `akkusativergaenzung` | Die Akkusativergänzung | متمم Akkusativ | A1 | verbergaenzungen | ergaenzungen | geplant |
| 11 | `genusbestimmung` | Genusbestimmung | تشخیص جنسیت دستوری اسم | A1 | nomen | nominalgruppe | geplant |
| 12 | `pluralbildung` | Die Pluralbildung | ساخت شکل جمع اسم | A1·A2 | nomen | nominalgruppe | geplant |
| 13 | `bestimmter-unbestimmter-artikel` | Bestimmter und unbestimmter Artikel | آرتیکل معین و نامعین | A1 | artikel | nominalgruppe | geplant |
| 14 | `possessivartikel` | Der Possessivartikel | آرتیکل ملکی | A1·A2 | artikel | nominalgruppe | geplant |
| 15 | `zahlwoerter` | Zahlwörter | اعداد | A1·A2 | adjektive | attribute | geplant |
| 16 | `lokaladverbien` | Lokaladverbien | قید مکان | A1·A2 | adverbien | angaben | geplant |
| 17 | `temporaladverbien` | Temporaladverbien | قید زمان | A1·A2 | adverbien | angaben | geplant |
| 18 | `personalpronomen` | Personalpronomen | ضمیر شخصی | A1 | pronomen | nominalgruppe | geplant |
| 19 | `praepositionen-akkusativ` | Präpositionen mit Akkusativ | حرف‌اضافه با Akkusativ | A1·A2 | praepositionen | angaben | geplant |
| 20 | `praepositionen-dativ` | Präpositionen mit Dativ | حرف‌اضافه با Dativ | A1·A2 | praepositionen | angaben | geplant |
| 21 | `fragewoerter` | Fragewörter | کلمات پرسشی | A1·A2 | satzlehre | satzverbindung | geplant |
| 22 | `die-vier-faelle` | Die vier Fälle (Kasus) | چهار حالت دستوری (Kasus) | A1·A2·B1 | satzlehre | ergaenzungen | LIVE → `/grammatik/thema/kasus` |
| 23 | `negation-verneinung` | Negation (Verneinung) | نفی (Verneinung) | A1·A2 | satzlehre | angaben | geplant |
| 24 | `satzarten` | Satzarten | انواع جمله | A1·A2 | satzlehre | satzverbindung | geplant |
| 25 | `unregelmaessige-verben` | Unregelmäßige Verben | افعال بی‌قاعده | A2·B1 | verben | praedikat | LIVE → `/unregelm-verben/grammar` |
| 26 | `reflexive-verben` | Reflexive Verben | افعال انعکاسی | A2·B1 | verben | praedikat | LIVE → `/reflexiv/grammar` |
| 27 | `praeteritum` | Das Präteritum | زمان Präteritum (گذشتهٔ ساده) | A2·B1 | tempus | praedikat | geplant |
| 28 | `hoeflichkeit-konjunktiv` | Höflichkeit mit Konjunktiv II | مؤدبانه‌گویی با کونیونکتیو II | A2·B1 | konjunktiv | praedikat | geplant |
| 29 | `dativergaenzung` | Die Dativergänzung | متمم Dativ | A2 | verbergaenzungen | ergaenzungen | geplant |
| 30 | `dativ-akkusativ-ergaenzung` | Dativ- und Akkusativergänzung | متمم دوگانهٔ Dativ و Akkusativ | A2·B1 | verbergaenzungen | ergaenzungen | geplant |
| 31 | `dass-saetze` | Dass-Sätze | جملات متممی با «dass» | A2·B1 | ergaenzungssaetze | ergaenzungen | geplant |
| 32 | `indirekte-fragesaetze` | Indirekte Fragesätze | سؤالات غیرمستقیم | A2·B1 | ergaenzungssaetze | ergaenzungen | geplant |
| 33 | `komposita` | Komposita | اسم‌های مرکب | A2·B1 | nomen | nominalgruppe | geplant |
| 34 | `nullartikel` | Der Nullartikel | بدون آرتیکل (Nullartikel) | A2·B1 | artikel | nominalgruppe | geplant |
| 35 | `demonstrativartikel` | Der Demonstrativartikel | آرتیکل اشاره | A2·B1 | artikel | nominalgruppe | geplant |
| 36 | `indefinitartikel` | Der Indefinitartikel | آرتیکل نامعین کمّی | A2·B1 | artikel | nominalgruppe | geplant |
| 37 | `interrogativartikel` | Der Interrogativartikel | آرتیکل پرسشی | A2·B1 | artikel | nominalgruppe | geplant |
| 38 | `adjektivdeklination` | Die Adjektivdeklination | صرف صفت (Adjektivdeklination) | A2·B1·B2 | adjektive | attribute | geplant |
| 39 | `komparativ-superlativ` | Komparativ und Superlativ | صفت تفضیلی و عالی | A2·B1 | adjektive | attribute | geplant |
| 40 | `modaladverbien` | Modaladverbien | قید حالت/کیفیت | A2·B1 | adverbien | angaben | geplant |
| 41 | `indefinitpronomen` | Indefinitpronomen | ضمیر نامعین | A2·B1 | pronomen | nominalgruppe | geplant |
| 42 | `wechselpraepositionen` | Wechselpräpositionen | حرف‌اضافهٔ دوگانه (Wechselpräpositionen) | A2·B1 | praepositionen | angaben | geplant |
| 43 | `lokale-temporale-praepositionen` | Lokale und temporale Präpositionen | حرف‌اضافهٔ مکانی و زمانی | A2·B1 | praepositionen | angaben | geplant |
| 44 | `konjunktionen` | Konjunktionen (koordinierend) | حروف ربط هم‌پایه‌ساز | A2·B1 | satzlehre | satzverbindung | geplant |
| 45 | `nebensaetze-einfuehrung` | Einführung in Nebensätze | مقدمهٔ جملات وابسته (Nebensätze) | A2·B1 | satzlehre | satzverbindung | geplant |
| 46 | `kausalsaetze` | Kausalsätze | جملات علّی (بیان دلیل) | A2·B1 | nebensaetze | satzverbindung | geplant |
| 47 | `konditionalsaetze` | Konditionalsätze (real) | جملات شرطی (واقعی) | A2·B1 | nebensaetze | satzverbindung | geplant |
| 48 | `wenn-als` | Wenn oder als? | تفاوت «wenn» و «als» | A2·B1 | nebensaetze | satzverbindung | geplant |
| 49 | `waehrend-temporal` | Während (temporal) | «während» (به‌معنای زمانی) | A2·B1 | nebensaetze | satzverbindung | geplant |
| 50 | `bevor-nachdem` | Bevor und nachdem | «bevor» و «nachdem» | A2·B1 | nebensaetze | satzverbindung | geplant |
| 51 | `plusquamperfekt` | Das Plusquamperfekt | زمان ماقبل ماضی (Plusquamperfekt) | B1·B2 | tempus | praedikat | geplant |
| 52 | `futur-1` | Das Futur I | زمان آیندهٔ ساده (Futur I) | B1 | tempus | praedikat | geplant |
| 53 | `vorgangspassiv` | Das Vorgangspassiv | مجهول جریانی (Vorgangspassiv) | B1·B2 | passiv | praedikat | geplant |
| 54 | `zustandspassiv` | Das Zustandspassiv | مجهول حالتی (Zustandspassiv) | B1·B2 | passiv | praedikat | geplant |
| 55 | `konjunktiv-2-gegenwart` | Konjunktiv II – Gegenwart | کونیونکتیو II — زمان حال | B1·B2 | konjunktiv | praedikat | geplant |
| 56 | `wunschsaetze` | Wunschsätze | جملات آرزویی | B1·B2 | konjunktiv | praedikat | geplant |
| 57 | `irreale-bedingungssaetze` | Irreale Bedingungssätze | جملات شرطی غیرواقعی | B1·B2 | konjunktiv | praedikat | geplant |
| 58 | `praepositionalergaenzung` | Die Präpositionalergänzung | متمم حرف‌اضافه‌ای | B1·B2 | verbergaenzungen | ergaenzungen | geplant |
| 59 | `infinitivsaetze` | Infinitivsätze mit 'zu' | جملات مصدری با «zu» | B1·B2 | ergaenzungssaetze | ergaenzungen | geplant |
| 60 | `n-deklination` | Die n-Deklination | صرف اسم با -n (n-Deklination) | B1·B2 | nomen | nominalgruppe | geplant |
| 61 | `genitiv` | Der Genitiv | حالت Genitiv (مالکیت) | B1·B2 | nomen | nominalgruppe | geplant |
| 62 | `partizipien-als-adjektive` | Partizipien als Adjektive | Partizip به‌عنوان صفت | B1·B2 | adjektive | attribute | geplant |
| 63 | `partikeln` | Partikeln (Modalpartikeln) | واژه‌های تأکیدی (Partikeln) | B1·B2 | adverbien | angaben | geplant |
| 64 | `demonstrativpronomen` | Demonstrativpronomen | ضمیر اشاره | B1·B2 | pronomen | nominalgruppe | geplant |
| 65 | `relativpronomen-relativsaetze` | Relativpronomen und Relativsätze | ضمیر موصولی و جملات موصولی | B1·B2 | pronomen | attribute | geplant |
| 66 | `pronomen-es` | Das Pronomen 'es' | ضمیر «es» | B1·B2 | pronomen | nominalgruppe | geplant |
| 67 | `praepositionen-genitiv` | Präpositionen mit Genitiv | حرف‌اضافه با Genitiv | B1·B2 | praepositionen | angaben | geplant |
| 68 | `attribute` | Attribute | صفات و وابسته‌های توصیفی (Attribute) | B1·B2 | satzlehre | attribute | geplant |
| 69 | `satzverbindende-adverbien` | Satzverbindende Adverbien | قیدهای ربطی | B1·B2 | satzlehre | satzverbindung | geplant |
| 70 | `angaben` | Angaben | قیدهای اضافی (Angaben) | B1·B2 | satzlehre | angaben | geplant |
| 71 | `konzessivsaetze` | Konzessivsätze | جملات امتیازی/تقابلی (وجود مانع) | B1·B2 | nebensaetze | satzverbindung | geplant |
| 72 | `finalsaetze` | Finalsätze | جملات هدف (غایی) | B1·B2 | nebensaetze | satzverbindung | geplant |
| 73 | `adversativsaetze` | Adversativsätze | جملات تقابلی | B1·B2 | nebensaetze | satzverbindung | geplant |
| 74 | `seitdem-sobald` | Seitdem und sobald | «seitdem» و «sobald» | B1·B2 | nebensaetze | satzverbindung | geplant |
| 75 | `solange-bis` | Solange und bis | «solange» و «bis» | B1·B2 | nebensaetze | satzverbindung | geplant |
| 76 | `futur-2` | Das Futur II | زمان آیندهٔ کامل (Futur II) | B2·C1 | tempus | praedikat | geplant |
| 77 | `passiversatz` | Passiversatzformen | جایگزین‌های مجهول | B2·C1 | passiv | praedikat | geplant |
| 78 | `nicht-passivfaehige-verben` | Nicht passivfähige Verben | افعال غیرقابل‌مجهول‌شدن | B2 | passiv | praedikat | geplant |
| 79 | `konjunktiv-2-vergangenheit` | Konjunktiv II – Vergangenheit | کونیونکتیو II — زمان گذشته | B2·C1 | konjunktiv | praedikat | geplant |
| 80 | `irreale-vergleichssaetze` | Irreale Vergleichssätze | جملات مقایسه‌ای غیرواقعی | B2·C1 | konjunktiv | praedikat | geplant |
| 81 | `nominalisierung` | Nominalisierung | اسم‌سازی از فعل و صفت | B2·C1 | nomen | nominalgruppe | geplant |
| 82 | `modalsaetze` | Modalsätze | جملات حالت/شیوه | B2·C1 | nebensaetze | satzverbindung | geplant |
| 83 | `konsekutivsaetze` | Konsekutivsätze | جملات نتیجه‌ای | B2·C1 | nebensaetze | satzverbindung | geplant |
| 84 | `konjunktiv-1` | Konjunktiv I – Indirekte Rede | کونیونکتیو I — نقل قول غیرمستقیم | C1·C2 | konjunktiv | praedikat | geplant |
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
