# PROJECT MAP — VOX
# نقشه کامل پروژه برای ناوبری سریع در هر session
# 🚫 قاعده‌ی ثابت (Lukas، 2026-10-15): کار روی VOX (به‌ویژه وارد کردن کلمه‌ها) هیچ ربطی به Root-in ندارد — فایل‌ها و کد Root-in نه خوانده، نه بررسی، نه تغییر داده می‌شوند. تنها ارتباط: یک دکمه در VOX به اپ Root-in (`lib/core/constants/app_links.dart` → `rootInUrl`). جزئیات: PLAN.md بالا.

> 🗂️ **خلاصه‌سازی (2026-11-10، بسته‌ی ۳ ممیزی، تأیید Lukas):** MAP فقط «معماری، اصل‌ها و نقش پوشه‌ها» است. شرح فایل به فایل، داده‌ی کاربر و تاریخچه **عیناً و بدون حذف** به `docs/` رفت (جدول «📁 کجا چه چیزی هست»). نسخه‌ی کامل قبلی: `git show b1ee0346:PROJECT_MAP.md`.

## INHALTSVERZEICHNIS (فهرست مطالب)

1. 📁 کجا چه چیزی هست
2. TECH STACK · STATUS LEGEND
3. 🗂️ پوشه‌های lib/ (شمارش از خود ریپو)
4. 🎨 Wo Form und Farbe der Wörter festgelegt sind (Grammatikon)
5. ⚙️ Arbeiten über die GitHub-API
6. tool/ — Werkzeuge
7. BUGS FIXED · BACKLOG
8. ⭐ اصول معماری پایه
9. KEY CONVENTIONS
10. DATABASE TABLES

## 📁 کجا چه چیزی هست

| موضوع | فایل | کی خوانده شود |
|---|---|---|
| شرح فایل به فایل (ROOT FILES، درخت lib/، Design System، Architecture Hub) | `docs/DATEIEN.md` | قبل از تغییر در یک بخش کد، همان بخش |
| داده‌ی کاربر، پشتیبان، حساب (فاز S) | `docs/NUTZERDATEN.md` | قبل از هر تغییر در داده‌ی کاربر |
| روال دور کلمه — فایل‌ها و پیشرفت | `docs/WORTROUTINE.md` (بخش دوم) | فقط در کار کلمه |
| تاریخچه‌ی تغییرهای MAP | `docs/MAP_VERLAUF.md` | هنگام نیاز |
| وضعیت و قدم‌های باز | `PLAN.md` | اول هر چت |

ارجاع‌های قدیمی مثل «PROJECT_MAP.md → wortschatz_grammatikon.dart» حالا در `docs/DATEIEN.md` هستند.

---

## TECH STACK
- Flutter Web — reine Web-App, gehostet auf GitHub Pages (seit 2026-09-13)
- State: flutter_riverpod (manual providers — بدون @Riverpod codegen)
- DB: drift (type-safe SQLite; im Browser via WASM: web/sqlite3.wasm + web/drift_worker.js) + drift_dev + build_runner
- Router: go_router
- Audio: just_audio (playback) + flutter_tts (TTS German)
- L10n: flutter_localizations (FA/EN) — strings در app_l10n.dart، بدون .arb
- Charts: fl_chart
- HTTP/RSS: http + xml
- Fonts: google_fonts (Vazirmatn for FA+DE+EN)

---

## STATUS LEGEND
[x] = done  [ ] = planned  [~] = in progress  [!] = blocked

---

## 🗂️ پوشه‌های lib/ (شمارش از خود ریپو، 2026-11-10)

| پوشه | تعداد فایل |
|---|---|
| `lib/core/backup/` | 8 |
| `lib/core/constants/` | 9 |
| `lib/core/content/` | 1 |
| `lib/core/database/` | 13 |
| `lib/core/grammatikon/` | 7 |
| `lib/core/l10n/` | 2 |
| `lib/core/models/` | 2 |
| `lib/core/network/` | 1 |
| `lib/core/parsers/` | 5 |
| `lib/core/router/` | 1 |
| `lib/core/services/` | 12 |
| `lib/core/theme/` | 3 |
| `lib/core/utils/` | 22 |
| `lib/core/widgets/` | 29 |
| `lib/core/wort/` | 4 |
| `lib/features/auswendiglernen/` | 7 |
| `lib/features/categories/` | 4 |
| `lib/features/dativ_verben/` | 9 |
| `lib/features/fragen/` | 1 |
| `lib/features/grammatik/` | 25 |
| `lib/features/hoeren/` | 8 |
| `lib/features/home/` | 4 |
| `lib/features/konnektoren/` | 9 |
| `lib/features/leitner/` | 8 |
| `lib/features/lesen/` | 6 |
| `lib/features/modalverben/` | 4 |
| `lib/features/more/` | 13 |
| `lib/features/nvv/` | 6 |
| `lib/features/praepositionen/` | 6 |
| `lib/features/pruefungen/` | 7 |
| `lib/features/redemittel/` | 7 |
| `lib/features/reflexiv_verben/` | 7 |
| `lib/features/schreiben/` | 1 |
| `lib/features/selbstlernen/` | 11 |
| `lib/features/sozialmedien/` | 1 |
| `lib/features/sprechen/` | 1 |
| `lib/features/trennbar_verben/` | 7 |
| `lib/features/unregelm_verben/` | 7 |
| `lib/features/verb_praep/` | 7 |
| `lib/features/vokabular/` | 14 |
| `lib/features/wortschatz/` | 21 |

شرح هر فایل: `docs/DATEIEN.md`.

---

## 🎨 Wo Form und Farbe der Wörter festgelegt sind (Grammatikon)

**Nirgends in den Daten.** Symbol, Füllung und Farbe werden zur Laufzeit aus `wortart` +
`details` berechnet und nie in den Wort-JSONs gespeichert. Design ändern = diese zwei Dateien
anfassen, nie die Karten.

| Datei | Rolle |
|---|---|
| `core/grammatikon/grammatikon_resolver.dart` | **das Gehirn** — Karte (+ Kasus/Genus/Numerus/Form) → `GrammatikonDescriptor{shape, fuellung, color, marker, innen}` |
| `core/grammatikon/grammatikon_spec.dart` | **das Aussehen** — Farbwerte, Maße jeder Grundform, Rahmenbreiten, Streifen, Marker |
| `core/grammatikon/grammatikon_painter.dart` | zeichnet den Descriptor |
| `core/grammatikon/wort_card.dart` | Listeneintrag; **Endungsfarbe kommt aus demselben Resolver** — keine zweite Genus→Farbe-Tabelle |
| `core/grammatikon/wort_text.dart` + `endung_resolver.dart` | farbige Endungen im Wort |

**Grundregeln:** FORM = Kasus (Nominativ `quadrat` · Akkusativ `raute` · Dativ `dreieck_links` ·
Genitiv `ellipse`), FARBE = Genus. Verben laufen über eine eigene Formenreihe:
Modalverb `blob_zahnrad` · trennbar+regelmäßig `doppel_kreis` · trennbar+unregelmäßig
`doppel_blob` · regelmäßig `kreis` · **unregelmäßig `blob_wellig`**. `stern` gehört allein der
Partikel. Beispiel: `helfen` (unregelmäßig, nicht trennbar) → `blob_wellig`, gefüllt, Verb-Grau;
`gestatten` (regelmäßig) → `kreis`, gefüllt.

✅ **B-9 gelöst (2026-09-15): es gibt nur noch EIN Artikel-Farbsystem.** Vorher galt:

| Artikel | `core/constants/article_colors.dart` (alte Wortschatz-Liste) | `grammatikon_spec.dart` (Vokabular-Archiv) |
|---|---|---|
| der | blau `#1E6FDB` | grün `#5DA283` |
| die | rot `#DB1E1E` | orange `#E39F4E` |
| das | grün `#1EDB6F` | lila `#7A4B96` |
| Plural | — | rot `#D85E5C` |

Das Grammatikon-System hat gewonnen. `core/constants/article_colors.dart` hält **keine eigenen
Farbwerte mehr**, sondern reicht `GrammatikonSpec.maskulin/feminin/neutral/plural` durch; alle
acht nutzenden Dateien (Liste, Badge, Leitner-Karte, Lese-Popup, Detail- und Hinzufügen-Seite,
`vox_colors.dart`) bekamen die neuen Farben ohne eigene Änderung.
**Farbe ändern = ausschließlich `grammatikon_spec.dart`.** `test/artikelfarben_test.dart` hält
das fest.

**Symbol in der Wortschatz-Liste** — `features/wortschatz/widgets/wortschatz_grammatikon.dart`
bildet `WordModel` auf eine Resolver-Karte ab. ✅ **B-10 (2026-09-16):** `Words` hat jetzt
`regelmaessig`/`trennbar`/`grammatikDetail` (alle nullable). Verb und Präposition bekommen
weiterhin nur MIT diesen Feldern ein Symbol (fehlt es — z. B. bei älteren Zeilen oder manchen
Eingabeformaten — bleibt es bei „lieber kein Symbol als ein falsches"). Konnektor bekommt
IMMER eins, weil der Resolver dafür einen echten Standardfall hat. Nomen brauchen weiterhin
einen Artikel.

ℹ️ Kleinere Doku-Drift: der Kopf von `grammatikon_resolver.dart` nennt noch „Schema 2.0",
die Karten sind 3.0.

---

## ⚙️ Arbeiten über die GitHub-API (Lehren 2026-09-15)

- **Ein Arbeitsschritt = EIN Commit.** Über die Git-Data-API (blobs → tree → commit → ref),
  nicht über mehrere `PUT /contents`. Einzel-Pushes erzeugen Zwischenstände, die nicht
  übersetzen (Datei exportiert auf eine noch fehlende Datei) und lösen je einen Deploy aus,
  der den vorigen abbricht.
- **Die CI-Logs sind von Claude aus nicht lesbar** — GitHub liefert sie von
  `*.blob.core.windows.net`, das nicht in der Netz-Freigabe steht.
  ✅ **Gelöst seit L.1b (2026-09-16):** `tool/ci_fehler_melden.sh` schreibt den Fehlertext roter Schritte
  (build_runner, Schema-Abzug, Analyze, Test) als Annotation. Lesen:
  `GET api.github.com/repos/lukasylilli/vox/actions/runs/<run>/jobs` → Job-id →
  `GET …/check-runs/<job-id>/annotations`. Vorhanden in `build-runner.yml` und `pruefen.yml`
  (nicht in `deploy-web.yml`). Ohne Annotation gilt weiter: Ursache aus dem Diff erschließen. **Darum in Dart nur Konstrukte verwenden, die im Repo schon
  vorkommen**, und übernommenen Code zeichengleich kopieren.
- Jeder Commit auf `main` ist eine Veröffentlichung (deploy-web.yml). **Deshalb seit S.3:
  riskante Änderungen zuerst auf einen Zweig.** `.github/workflows/pruefen.yml` läuft auf jedem
  Zweig außer `main` (pub get → analyze → test → `flutter build web`, ohne zu veröffentlichen).
  Vor allem eine Änderung an `pubspec.yaml` ließ sich vorher nirgends prüfen, weil Claude kein
  `pub get` ausführen kann — der erste ehrliche Test war bisher immer schon der Ernstfall.
- **Workflow-Dateien brauchen ein eigenes PAT-Recht.** Ein Tree über die Git-Data-API, der einen
  Pfad unter `.github/workflows/` enthält, wird ohne „Workflows: Read and write" mit
  `403 Resource not accessible by personal access token` abgelehnt — die Blobs entstehen
  vorher trotzdem, der Fehler kommt erst beim Tree. Nicht alle vorliegenden Token haben das
  Recht; beim 403 schlicht das andere probieren.
- **Artefakte aus Actions sind von Claude aus nicht herunterladbar** (`*.blob.core.windows.net`,
  nicht in der Netz-Freigabe) — dieselbe Grenze wie bei den Logs. Was zurück ins Repository
  soll, muss der Workflow selbst committen, nicht als Artefakt ablegen.
- **Workflows von Hand anstoßen (`workflow_dispatch`) geht nur mit einem der beiden Token** — das
  andere bekommt `403`. Beim 403 das andere probieren (2026-09-16, S.6).
- **Ein Commit, den ein Workflow selbst schreibt (z. B. `build-runner.yml`), startet keine weiteren
  Workflows** — auf dem Zweig läuft danach also kein `pruefen.yml` von allein. Für den Web-Bau vor
  dem Zusammenführen `pruefen.yml` per Dispatch auf den Zweig anstoßen (2026-09-16, S.6).
- **`| tee` in einem `run:` verschluckt Fehler.** Die Standard-Shell von GitHub ist `bash -e` **ohne**
  `pipefail` — der Schritt ist grün, auch wenn der Befehl vor `tee` scheitert. Jeder Schritt mit `| tee`
  beginnt deshalb mit `set -o pipefail` (L.1a, 2026-09-16; offen in `vokabular-autofill.yml`, siehe A.6).
- **Wächter immer mit einer Gegenprobe prüfen:** auf einem Wegwerf-Zweig den verbotenen Fall herstellen und
  sehen, dass genau der Wächter-Schritt rot wird — erst dann gilt er als wirksam (L.1a).
- **Textersetzung per Skript: Teilzeichenketten beachten.** S.5 (2026-09-15): ein Ersatz für
  `      final companion` (6 Leerzeichen) traf auch die Zeile mit 8 Leerzeichen — doppelter
  Parameter, `analyze` rot im build-runner-Lauf. Vor jedem `replace` die Treffer **zeilengenau**
  zählen (`^` verankern), nicht nur die Anzahl.
- **Nichts neu erfinden, was im Repo schon funktioniert.** Zwei rote Läufe am 2026-09-15 kamen
  genau daher: in `main.dart` `unawaited`/`catchError` statt des bewährten try/catch, und im
  neuen Test `Default*Localizations` statt der in `test/vokabular_test.dart` erprobten
  `Global*Localizations` (die kennen kein Farsi). Vor jeder neuen Datei: nachsehen, wie das
  Repo dasselbe bereits löst, und diese Form übernehmen.

---

## tool/ — Werkzeuge (فاز A, 2026-09-15)

- `tool/vokab_qualitaet.dart` — **فاز Q.2 (2026-10-11):** بازبینی **محتوای** کارت‌ها (ترجمه fa/en، IPA، سطح مثال‌ها، Steigerung، مترادف/متضاد، wortnetz). فقط گزارش؛ ساختار/id همچنان فقط در `vokab_schema.dart`. فهرست کارت‌های بازه‌ی Sonnet: `tool/qualitaet/q_liste.txt`. وضعیت و نتیجه: PLAN → «🔍 فاز Q».

| فایل | زبان | کار |
|------|------|-----|
| `tool/vokab_ids_pruefen.dart` | Dart | **L.1a** — Wächter: vergleicht den Index der **Live-Seite** mit dem frisch gebauten; fehlt eine veröffentlichte id ⇒ exit 1. Läuft in `deploy-web.yml` und `pruefen.yml` nach „Wortindex bauen". Handauslassung nur über `workflow_dispatch`-Eingabe `ohne_id_waechter` |
| `tool/vokab_index.dart` | Dart | **V.2** — baut `assets/vocab_index.json` aus `assets/vocab/`. Läuft in **jedem** Workflow direkt vor `flutter analyze`; Ergebnis nie committet (`.gitignore`). exit 1 bei unlesbarer/falsch abgelegter Karte oder doppelter id |
| `tool/naechste_woerter.dart` | Dart | **L.4 (2026-09-23)** — nennt die nächsten N Wörter der aktuellen Wortliste ohne Karte (Reihenfolge der Datei, `zurueckgestellt` = unsichere Wörter für Lukas). `--abhaken` (2026-09-24): ✓ in allen Listen für jedes Wort mit Karte (gleiche vokabId + wortartKorrektur). Routine: «📚 کلمه‌ها» oben / PLAN.md **2026-10-31:** Standard 20 statt 10 (Lukas: Runde = 20 Wörter) |
| `docs/WORTRUNDEN.md` | md | **2026-10-31 (Archiv)** — die ausführlichen Berichte aller Wortrunden (früher PLAN-Kopf + MAP «📚 کلمه‌ها»), wörtlich verschoben, nichts gelöscht. Neue Sitzungsberichte nur hier (neueste oben). Nicht am Chat-Anfang lesen; Regeln/Lehren stehen in PLAN «📚 روال» |
| `tool/wort_runde.sh` | sh | **L.4 (2026-09-24 دور ۶۳)** — Routine-Schritte 5–7 in EINEM Aufruf, gleiche Befehle/Reihenfolge: Dry-Run (muss «Fehler: 0 · Warnungen: 0») ⇒ Import ⇒ vokab_index ⇒ `--abhaken` ⇒ analyze ⇒ test ⇒ nächste Wörter. Erstes Problem ⇒ Abbruch. **2026-10-26:** `--teil 1|2|3` = dieselben Schritte in drei Aufrufen (1: bis analyze · 2: Tests ohne `grammatik_uebungen_test.dart` · 3: diese Datei + nächste Wörter) für Zeitlimits pro Befehl. **2026-10-31:** `--teil daten` = Dry-Run ⇒ Import ⇒ Index ⇒ ✓ ⇒ nächste Wörter, nur Dart-SDK, ohne analyze/test (laufen in deploy-web.yml vor dem Deploy); Abbruch, wenn lib/, test/, pubspec.* oder analysis_options.yaml geändert sind. Alle `dart run tool/…` ⇒ `dart tool/…` (kein automatischer pub-Lauf) |
| `tool/dart_umgebung.sh` | sh | **L.4 (2026-10-31)** — `source tool/dart_umgebung.sh`: lädt nur das Dart-SDK in der Version, die zur Flutter-Version in `deploy-web.yml` gehört (aus der Flutter-Release-Liste, nie von Hand), setzt PATH und schreibt eine minimale `.dart_tool/package_config.json` (`package:vox` ⇒ `lib/`, languageVersion aus pubspec). Eine von pub erzeugte Datei bleibt unangetastet. Für Wortrunden ohne Flutter |
| `tool/vokabular_import.dart` | Dart | **verbindliche Prüfung** — Konverter-Output → `assets/vocab/<wortart>/<id>.json`. Nutzt `vokabPruefeKarte()` aus `lib/features/vokabular/data/vokab_schema.dart`. Duplikat-Schutz, idempotent, exit 1 bei Fehlern |
| `tool/backlog.py` | Python | **A.1** — welches Wort ist als Nächstes dran? Leitet den Stand aus `assets/vocab/` ab (nicht aus den ✓-Marken). `--stand` / `--naechste N` / `--gruppe` / `--json`. Spiegelt `vokabId()` zeichengenau |
| `tool/sync_backlog.py` | Python | **A.2** — schreibt die ✓-Marken in `Wörter/*.txt` aus `assets/vocab/` neu. idempotent, `--dry-run` · ⚠️ kennt `wortartKorrektur` nicht (entfernt ✓ der numerale-Wörter) ⇒ für die Routine NICHT benutzen, stattdessen `naechste_woerter.dart --abhaken` |
| `tool/generate_words.py` | Python | **A.3** — nächste N Wörter → SUPER-PROMPT v3.0 → Anthropic API → `import_inbox/`. Pre-Flight nur grob; **validiert NICHT** (das macht Dart). Sicherheitsgrenze 500 Karten |
| `tool/check_vendored.py` | Python | **فاز S** — meldet, wenn eine aus Root-in kopierte Datei dort inzwischen geändert wurde (Vergleich über den `commit`-Vermerk im Dateikopf). Meldet nur, entscheidet nie |
| `tool/webtest_ci.py`, `tool/webtest_serve.sh` | Python/sh | Web-Testlauf |

⚠️ **Eine Validierungsquelle:** `vokab_schema.dart`. Die Python-Werkzeuge dürfen nie eine zweite
Prüflogik bekommen — sie bereiten nur vor und räumen nach.
⚠️ `tool/backlog.py` enthält eine Kopie der ID-Regel 5 (`vokab_id()`). Ändert sich `vokabId()` in
Dart, **muss** sie hier mitgezogen werden, sonst greift der Duplikat-Schutz nicht.
✅ **`.github/workflows/vokabular-autofill.yml` liegt seit 2026-09-16 im Repo** (فاز A / A.4) —
möglich wurde das durch das PAT mit „Workflows: Read and write". Bevor ein echter Lauf Kosten
verursacht, fehlt noch das Secret `ANTHROPIC_API_KEY`.
✅ **V.2 erledigt (2026-09-16)** — die technische Grenze ist weg; `--grenze 500` in `generate_words.py` bleibt als Kostenschutz bis A.6.
⚠️ **A.4-Befund:** Push aus `vokabular-autofill.yml` (GITHUB_TOKEN) startet `deploy-web.yml` NICHT — vor dem ersten echten Lauf lösen (PLAN.md → فاز A).
~~⚠️ **A.3/A.4 erst nach V.2 scharfschalten**~~ — `vokabular_controller` liest beim Start jede Karte;
ein erfolgreicher Lauf mit mehreren tausend Wörtern bricht die laufende App. Grenze: ~500 Karten.
✅ **A.6 entschieden (Lukas 2026-09-23):** Claude baut die Karten im Chat nach dem Wort-Prompt, je «ده کلمه جدید»
(PLAN.md → «📚 روال», Werkzeug `tool/wort_runde.sh`). API-Weg (`vokabular-autofill.yml`, `generate_words.py`) bleibt ungenutzt.

---

## BUGS FIXED

> هر مورد یک خط؛ شرح کامل: `git show afad3ab:PROJECT_MAP.md`.

- ✅ [2026-09-16] L.2c: Tabellen von „verb-sein"/„verb-haben" nicht darstellbar
- ✅ [2026-09-16] L.1b: Index `user_categories_uid` war für drift unsichtbar
- ✅ [2026-09-16] V.2: App-Start las jede Wortkarte einzeln
- ✅ [2026-09-16] S.6: Umbenennen einer Liste kostete beim Abgleich Wörter
- ✅ [2026-09-15] S.5: Sicherung trug ~830 App-Wörter; Entfernungen kamen beim Zusammenführen zurück
- ✅ [2026-09-15] B-12: Sicherung verlor die B-10-Grammatikfelder eigener Wörter
- ✅ [2026-09-15] B-11: App und Sicherung lasen verschiedene Ablagen
- ✅ [2026-09-15] Puzzling-Bruch in den Einstellungen (فاز S)
- ✅ [2026-06-30] Phase 8 (جزئی): RevenueCat SDK کامل + Native Splash — ⛔ RevenueCat später entfernt (2026-09-13)
- ✅ [2026-06-30] Phase 7: Bilingual Audit — 100+ localization keys اضافه شدند
- ✅ [2026-06-29] B-4: Grammatik home لینک اشتباه + Prüfungen topic quiz
- ✅ [2026-06-29] B-1: Container color + decoration conflict
- ✅ [2026-06-29] B-2: SQLite UNIQUE constraint 2067

## BACKLOG / UPCOMING CHANGES

> مرجع کامل و به‌روز: PLAN.md. اینجا فقط وضعیت (2026-09-23):

- ✅ **انجام شد:** B-3 · R-1 (full form = R-2.1، 2026-09-22) · R-3 · R-4 · R-5 · R-6 · R-7 · L.5f (2026-09-20) · L.5d (عملاً با فاز P؛ فقط «سطح کاربر» نیامده)
- ⏳ **بعد از انتشار:** R-2.2 (detail view کامل Präpositionen) · L.5b ترجمه‌ی زیر متن · L.5c تمرین از همه‌ی محتوا · L.5e آزمون بعد از هر بخش
- ⏸️ **بعد از همه‌ی مراحل کلمه:** مرحله‌ی آخر (۴) شبکه‌ی کلمات ⇒ (۵) کنترل نهایی کلمات (PLAN «🕸️» و «✅»)
- ⏸️ **بعد از تمام شدن همه‌ی بخش‌ها، قبل از بازبینی نهایی:** فاز M محتوای فروشی (بسته‌ها + کد دسترسی، PLAN «💎 فاز M»)
- ⏸️ **بعد از تمام شدن کل اپ:** فاز K درس‌بندی + تمرین/آزمون + مدال Lernpfad (PLAN «🎓 فاز K»)
- ⛔ **تصمیم Lukas لازم:** L.5a صفحه‌ی پیشرفت · L.5g ⛔⛔ ساختار دو لایه‌ی Lesen/اخبار (قبل از شروع بپرس، حدس نزن)
- ⚠️ `core/content/content_registry.dart` فعلاً فقط فهرست است؛ هیچ فایلی import‌اش نمی‌کند (2026-09-22).

---

## ⭐ اصول معماری پایه (هر Session باید رعایت شود)

### اصل ۱: Component Isolation (ارجاع‌دهی) — مهم‌ترین قانون
**قانون:** هیچ Screen‌ای اجازه ندارد کد ظاهر (رنگ، شکل، سایز، padding) یک کامپوننت قابل ارجاع را درون خودش تعریف کند.

- کد ظاهر دکمه‌ها → فقط در `core/widgets/vox_button.dart`
- کد ظاهر badge‌ها → فقط در `core/widgets/vox_badge.dart`
- کد ظاهر فیلترها → فقط در `core/widgets/filter_accordion.dart`
- رنگ‌ها → فقط در `core/constants/app_colors.dart`
- BoxDecoration‌های مشترک → فقط در `core/theme/app_decorations.dart`

Screen‌ها فقط این کامپوننت‌ها را **صدا می‌زنند** — کد ظاهر نمی‌نویسند.

### اصل ۲: One Screen — Two Locations (یک صفحه، دو مکان نمایش)
هیچ صفحه‌ای دوبار ساخته نمی‌شود — فقط ارجاع داده می‌شود:

| صفحه | مکان اول | مکان دوم |
|------|-----------|-----------|
| `konnektoren_grammar_screen.dart` | Konnektoren home → grammar | Grammatik home → Konnektoren |
| `dativ_grammar_screen.dart` | Dativ home → grammar | Grammatik home → Dativ |
| `nvv_grammar_screen.dart` | NVV home → grammar | Grammatik home → NVV |
| `praepositionen_grammar_screen.dart` | Präp home → grammar | Grammatik home → Präp |
| `konnektoren_quiz_screen.dart` | Konnektoren home → quiz | Prüfungen → Konnektoren quiz |
| `dativ_verben_quiz_screen.dart` | Dativ home → quiz | Prüfungen → Dativ quiz |
| `nvv_quiz_screen.dart` | NVV home → quiz | Prüfungen → NVV quiz |
| `praepositionen_quiz_screen.dart` | Präp home → quiz | Prüfungen → Präp quiz |

**نکته فنی**: quiz routes اکنون اگر `extra` null باشد، داده را خودشان از provider بارگذاری می‌کنند (Consumer loader در `app_router.dart`)

### اصل ۳: Content-Aware Filters (فیلتر متناسب با محتوا)
فیلترهای هر صفحه باید با محتوای همان صفحه تطابق داشته باشند.
**تعداد کشوها نامحدود** — هر صفحه `List<FilterOption>` خودش را تعریف می‌کند.

| صفحه | کشو ۱ (Niveau) | کشو ۲ (Art/Kasus) | کشو ۳ |
|------|----------------|-------------------|--------|
| Konnektoren | A1–C1 | Nullposition، Nebensatz، Hauptsatz | Semantik (kausal، konzessiv...) |
| Dativ Verben | A1–B2 | Dativ، Akkusativ | — |
| NVV | A1–C1 | — | Thema |
| Präpositionen | A1–C1 | an، auf، für، mit، über، von، zu... | Verb/Nomen/Adjektiv |
| Wortschatz | A1–C1 | Verb، Nomen، Adjektiv، Konnektor... | — |

`FilterAccordion` ظاهر ثابت دارد — محتوای گزینه‌ها از هر Screen به آن داده می‌شود (`List<FilterOption>`).

### اصل ۴: آپدیت فوری نقشه و پلن
بعد از **هر تغییر** (فایل جدید، حذف، تغییر ساختار):
1. `PROJECT_MAP.md` → ورودی فایل مربوطه آپدیت شود
2. `PLAN.md` → تیک بزن یا task جدید اضافه کن
این دو فایل مثل منو/فهرست راهنما هستند — باید همیشه به‌روز باشند.

### ⭐ اصل ۵: هر محتوای جدید از اول دوزبانه (فارسی + انگلیسی) — فاز L3
> قانون کاربر (2026-07-07): همه محتواها و تغییرات آینده باید **از ابتدا و بدون خطا**
> دوزبانه اضافه شوند. آلمانی همیشه دست‌نخورده.

**Definition of Done برای هر محتوای جدید:**
1. **JSON-Asset**: هر فیلد متنیِ زبان دوم همیشه **جفت** است: `*_fa` **و** `*_en`
   (هرگز فقط fa؛ en خالی هم ممنوع). آلمانی: `*_de` جدا و تغییرناپذیر.
2. **Screen**: هیچ‌وقت `xxxFa` مستقیم render نشود — فقط از این سه راه:
   `AppL10n.meaning(context, fa:, en:)` · `AppL10n.isFa(context)` ·
   الگوی `_loc(context, map, 'base')` (نمونه: trennbar_grammar_screen)
   ⚠️ در `initState` از `AppL10n.activeLang` استفاده کن، نه context (نمونه: nvv_quiz)
3. **برچسب UI جدید**: فقط کلید کاتالوگ — و کلید هم‌زمان در هر دو map (fa و en) در
   `app_l10n.dart` اضافه شود (گیت پاریتی).
4. **گیت‌ها قبل از اتمام کار** (باید صفر/سبز باشند):
   · `flutter analyze`
   · پاریتی کاتالوگ: تعداد کلیدهای fa == en
   · اسکریپت asset-audit: هیچ `*_fa` بدون `*_en` در JSON جدید
   · `grep -rnE "\\.(example|meaning|title|explanation)Fa" lib/features --include='*.dart' | grep Text` → هر hit باید داخل AppL10n.meaning باشد

---

## KEY CONVENTIONS

### سر هر فایل dart:
```dart
// FILE: lib/features/wortschatz/screens/word_detail_screen.dart
// DEPS: word_controller.dart, word_model.dart, article_badge.dart
// EXPORTS: WordDetailScreen
// PURPOSE: جزئیات کامل کلمه + دکمه‌های action (audio، leitner، category، quiz)
```

### آرتیکل رنگ‌ها (ArticleColors):
- der → 0xFF1E6FDB (blue)
- die → 0xFFDB1E1E (red)
- das → 0xFF1EDB6F (green)
- null → Colors.grey

### withValues vs withOpacity:
- همیشه `color.withValues(alpha: x)` — نه `withOpacity(x)` (deprecated)

### Provider pattern:
- دیتابیس: `databaseProvider` در word_controller.dart (singleton با onDispose)
- DAO providers: `wordDaoProvider`، `leitnerDaoProvider`، `categoryDaoProvider`
- هر فاز controller خودش را دارد، از databaseProvider می‌خواند

### Drift imports:
- در DAO ها: `import 'package:drift/drift.dart';` (کامل)
- در controller ها که فقط Value لازم دارند: `import 'package:drift/drift.dart' show Value;`

### دسته‌های کاربر:
- ارجاعی (wordIds only) — نه کپی کلمه
- CategoryWords(categoryId, wordId) با composite PK

### Navigation:
- push برای صفحه‌های داخل یک بخش: `context.push('/wortschatz/word/$id')`
- go برای تغییر بخش اصلی: `context.go(AppRoutes.wortschatz)`
- extra برای data: `context.push('/path', extra: data)` → `state.extra as Type?`

---

## DATABASE TABLES (drift — schema v7)
> ⚠️ تغییر فقط با: `schemaVersion` بالا + migration + اجرای `build-runner.yml` روی شاخه (L.1b). جدول‌ها از `@DriftDatabase` در `core/database/app_database.dart` (بررسی 2026-09-23).
```
words                    — جدول اصلی (unique: {german, wordType}) + regelmaessig/trennbar/grammatikDetail (B-10)
books · word_books       — کتاب‌ها + many-to-many
user_categories          — لیست‌های شخصی (uid ثابت، S.6) · category_words — many-to-many
leitner_cards            — لایتنر کلمه‌های همراه اپ/خودی
archiv_leitner           — لایتنر کارت‌های آرشیو (کلید متنی wortId، S.0b)
archiv_kategorien · archiv_kategorie_woerter — لیست‌های آرشیو (S.0c)
mitgliedschaften         — عضویت‌ها و حذف‌ها با زمان (S.5)
grammar_lessons · memorize_items (meaningEn، L3-E) · reading_texts · audio_items
habits · habit_sessions  — فقط برای سازگاری DB؛ Habit از 2026-09-13 در UI نیست (Root-in)
```
