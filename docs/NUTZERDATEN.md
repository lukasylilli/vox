# NUTZERDATEN — داده‌ی کاربر کجاست (فاز S)

> ذخیره‌سازی، پشتیبان، حساب و همگام‌سازی. قبل از هر تغییر در داده‌ی کاربر خوانده شود.
> منبع: `PROJECT_MAP.md` تا کامیت `b1ee0346` (2026-11-10، بسته‌ی ۳ ممیزی) — متن عیناً منتقل شده، هیچ خطی حذف نشده.

## 💾 Wo die Nutzerdaten liegen (فاز S, 2026-09-15)

⚠️ **Wichtigster Abschnitt für alles, was Fortschritt anfasst.** Details: PLAN.md → فاز S.

| Ablage | Inhalt | Datei |
|---|---|---|
| drift/SQLite-WASM (IndexedDB, DB `vox`) | `LeitnerCards` (alte Wortschatz-Wörter) · `Words`/`Books`/`WordBooks` · `UserCategories`/`CategoryWords` | `core/database/app_database.dart` |
| drift (seit S.0b/S.0c, App liest es seit **B-11**) | `ArchivLeitner` · `ArchivKategorien` · `ArchivKategorieWoerter` (Archivkarten) | Zugriff nur über `core/backup/user_state_repository.dart` |
| SharedPreferences (localStorage) | `vokab_user_notizen_v1` (echte Ablage) · `vokab_user_leitner_v1` / `vokab_user_kategorien_v1` (nur Altbestand — wird beim Laden übernommen und geleert) | Schlüssel-Konstanten in `core/backup/user_state_repository.dart` |
| SharedPreferences (localStorage) | `theme_mode`, `tts_rate`, `tts_language`, `current_level`, `daily_goal_min`, `ui_language` (fehlt ⇒ Gerätesprache, L.3a) | `features/more/controllers/settings_controller.dart` |

✅ **S.0b+S.0c (2026-09-16): Archivkarten-Leitner UND Archiv-Listen liegen jetzt in drift**
(`ArchivLeitner` bzw. `ArchivKategorien`/`ArchivKategorieWoerter`), nicht mehr in
SharedPreferences. Ein Übergangspfad in `user_state_repository.dart` übernimmt einmalig alte
Bestände aus `vokab_user_leitner_v1`/`vokab_user_kategorien_v1`. Nur Notizen bleiben bewusst
in SharedPreferences (Freitext). **Neuer Code fasst diese Ablagen nie direkt an** — nur über
die Fassade, die allein `NutzerZustand` nach außen zeigt.
⚠️ Drei Orte, EIN Zuhause: Browser = Zuhause, Server + Datei = nur Wiederherstellung.
   Die App liest nie direkt von Server oder Datei. Konfliktregel: **höchstes Leitner-Fach gewinnt.**

| Datei | Zweck |
|---|---|
| `core/utils/persistent_storage.dart` (+ `_io`/`_web`) | **S.1 ✅** — bittet den Browser um dauerhaften Speicher; bedingter Export wie `external_link_opener`. Aus Root-in kopiert, Herkunft (Repo/Pfad/Commit) im Dateikopf. ⚠️ Der `_web`-Teil ist eine **zeichengleiche** Kopie — beim Nachziehen nicht umbenennen |
| `core/utils/install_state.dart` (+ `install_hinweis.dart`, `_io`/`_web`) | **S.1b ✅** — erkennt, ob VOX als Web-App installiert ist, sonst Anleitung je Plattform. Der Aufzählungstyp liegt bewusst in einer eigenen Datei (sonst Import-Kreis mit der Weiche) |
| `core/utils/dokument_sprache.dart` (+ `_io`/`_web`) | **L.3a ✅** (2026-09-16) — setzt `<html lang>` auf die aktive Oberflächensprache (aus `app.dart`), damit der Browser keine falsche Übersetzung anbietet. Bedingter Export wie `external_link_opener`. `web/index.html` startet mit `lang="en"` |
| `web/locale_guard.js` | **L.3b ✅** (2026-09-23) — läuft in `web/index.html` **vor** `flutter_bootstrap.js`. Die Flutter-Engine baut beim Start `new Intl.Locale()` für jede Browsersprache und stürzt bei ungültigem BCP-47 ab (z. B. Chromium/Linux mit POSIX-Locale: `en-US@posix`). Das Skript bereinigt nur dann `navigator.languages`/`language` (`@…`/`.…` weg, `_`→`-`, leer ⇒ `["en"]`); gültige Sprachen bleiben unberührt. Startsprache entscheidet weiter allein `geraete_sprache.dart`. Gleiche Datei in Root-in |
| `web/telegram_guard.js` | **L.3c ✅** (2026-09-24 دور ۶۴) — läuft in `web/index.html` **nach** `locale_guard.js`, **vor** `flutter_bootstrap.js`. Nur wenn die Adresse `tgWebAppData` enthält (Start als Telegram-Mini-App): per `document.write` synchron das offizielle SDK `telegram.org/js/telegram-web-app.js` laden (es liest `location.hash` selbst ⇒ `Telegram.WebApp.initData`), danach Adresse per `history.replaceState` säubern (`#/pfad?tgWebAppData=…` ⇒ `#/pfad`, sonst ohne `#`). Sonst go_router: „GoException: no routes for location". Normale Starts: kein SDK, keine Änderung. ⚠️ Nutzerdaten nur aus `Telegram.WebApp.initData`, nie aus der Adresse — Dart liest heute gar keine Telegram-Daten (`Uri.base` nur für Supabase-Mail-Links in `main.dart`) |
| `web/index.html` (ثبت SW) | **L.3 ✅** (2026-09-24) — بعد از `load` فایل `vox_sw.js` را ثبت می‌کند (scope = `/vox/`). Flutter-SW خاموش است (`--pwa-strategy=none`)، چون در 3.44 خودش را unregister می‌کند و `vox_sw.js` را در همان scope کنار می‌زد |
| `tool/pwa/workbox_config.cjs` | **L.3 ✅** — **تنها منبع** رفتار آفلاین: فهرست پیش‌بارگذاری (همه‌چیز جز کارت‌ها/`vocab_formen`/`*.symbols`/skwasm)، `PFLICHT` (فایل‌هایی که بدونشان آفلاین شروع نمی‌شود)، runtime: `vox-woerter` (StaleWhileRevalidate) + `vox-schriften` (fonts.gstatic). skipWaiting خاموش، clientsClaim روشن |
| `tool/pwa/sw_bauen.cjs` | **L.3 ✅** — بعد از `flutter build web` در deploy: پرچم‌ها را در `flutter_bootstrap.js` چک می‌کند (بدون serviceWorkerSettings، `useLocalCanvasKit: true`)، هر هشدار Workbox یا فایل اجباری غایب ⇒ قرمز؛ بعد `build/web/vox_sw.js` |
| `tool/pwa/offline_test.cjs` | **L.3 ✅** — Chrome واقعی (`CHROME_PATH`): آنلاین ⇒ worker فعال ⇒ Offline + goto ⇒ همه‌ی فایل‌های بسته با fetch آفلاین ⇒ پنجره‌ی تازه آفلاین. ملاک «VOX بالا آمد» = `#vox-loading` حذف شده. ⚠️ `page.reload()` در Playwright با Offline از SW رد می‌شود ⇒ `goto` · **مرحله‌ی ۵ (L.3c):** هر آدرس در پنجره‌ی تازه، آفلاین: `#tgWebAppData=…` ⇒ بدون tgWebAppData، `#/wortschatz?tgWebAppData=…` ⇒ `#/wortschatz`، `#/` و `#/wortschatz` مثل قبل؛ هر پیام GoException ⇒ قرمز |
| `tool/pwa/package.json` + `package-lock.json` | **L.3 ✅** — workbox-build 7.4.1 + playwright-core 1.55.0 (بدون مرورگر؛ Chrome خود ubuntu-latest). `node_modules` در `.gitignore` |
| `features/more/screens/settings_screen.dart` → `_SpeicherKarte` | zeigt diese Einladung unter «داده‌ی من» |
| `test/praep_vollform_test.dart` | **R-2.1 (2026-09-22)** — `PraepCluster.vollform`: gemeinsame Präposition einmal am Ende, sonst je Wort; prüft alle 185 echten Cluster |
| `test/konto_loeschen_test.dart` | **L.1d (2026-09-22)** — Knopf «حذف حساب»: Dialog nennt Root-in · Abbrechen löscht nichts · deleted / unavailable (eigene Sicherung + abmelden) / failed · `deleteAccount()` ohne Server = failed. Auth/Ablage/Abgleich ersetzt, kein Netz |
| `test/l10n_paritaet_test.dart` | hält FA/EN-Schlüssel synchron. MaterialApp-Aufbau **muss** `Global*Localizations` nutzen — `Default*Localizations` kennen kein Farsi |
| `core/backup/nutzer_zustand.dart` | **S.0a-1 ✅ — DER VERTRAG.** Was einem Nutzer gehört + Hülle `{version, exportedAt, app, payload}` + `zusammenfuehren()` („höchstes Fach gewinnt" — seit 2026-11-10 mit Ausnahme: eine spätere falsche Antwort gewinnt, `LeitnerStand.zusammen`). Reines Dart, ohne drift/prefs/Flutter. ⚠️ Leitner-IDs sind Text (`adjektiv_stolz`, `eigen:<wort>\|<wortart>`) — die drift-Nummer gehört NIE in eine Sicherung |
| `test/nutzer_zustand_test.dart` | 12 Fälle, darunter: älterer Stand mit höherem Fach gewinnt; a+b == b+a; Notizen werden nie zusammengeklebt |
| `core/backup/user_state_repository.dart` | **S.0a-2 ✅, S.0b ✅ — DIE FASSADE.** Einzige Stelle, die weiß, wo der Nutzerzustand liegt (Archivkarten seit S.0b in drift/`ArchivLeitner`, mit Übergangspfad aus SharedPreferences). `lesen()` / `anwenden()`. Löscht nie etwas; sichert nur Einstellungen aus `einstellungsSchluessel` |
| `.github/workflows/build-runner.yml` | führt `dart run build_runner build` aus der Ferne aus, committet nur bei grünem analyze+test — für jede künftige Drift-Änderung, nicht nur S.0b. **Seit L.1b** zusätzlich: Schema-Abzüge aller Fassungen ab `ERSTE_FASSUNG=2` aus der Git-Geschichte (je Fassung ein Arbeitsbaum des letzten Commits mit dieser `schemaVersion`) → `drift_schemas/` → `test/generated_migrations/`; Fehlertexte als Annotation. Braucht `fetch-depth: 0` |
| `drift_schemas/drift_schema_vN.json` | **L.1b** — Schema jeder veröffentlichten Fassung (2…aktuell), erzeugt von `build-runner.yml`, **nie von Hand** |
| `test/generated_migrations/` | **L.1b** — von `drift_dev schema generate` erzeugt (`GeneratedHelper.versions`), nie von Hand |
| `tool/ci_fehler_melden.sh` | **L.1b** — Fehlertext eines roten CI-Schritts → eine GitHub-Annotation (filtert Stapelzeilen und drifts Mehrfach-DB-Hinweis) |
| `.github/workflows/pubspec-lock.yml` | **S.3 ✅** — Gegenstück dazu für `flutter pub get`: frischt `pubspec.lock` aus der Ferne auf und committet es. ⚠️ Das Lockfile ist hier nicht kosmetisch — `web/sqlite3.wasm`/`web/drift_worker.js` müssen zu den dort festgehaltenen drift-/sqlite3-Fassungen passen |
| `test/user_state_repository_test.dart` | prüft gegen eine echte In-Memory-Datenbank, u. a. simulierter Gerätewechsel und doppeltes Einspielen |
| `core/services/backup_service.dart` | **S.2 ✅** — `exportieren()` / `einspielen()`. Kennt nur die Fassade und `datei_io`, keine Ablage |
| `core/backup/datei_io.dart` (+ `_io`/`_web`) | Datei auswählen und ablegen. `textDateiWaehlen` aus Root-in übernommen; `textDateiSpeichern` ist ein Blob-Download — **bewusst ohne share_plus**, damit `pubspec.lock` unberührt bleibt |
| `features/more/widgets/sicherung_karte.dart` → `SicherungKarte` (bis P.3: `_SicherungKarte` in settings_screen) | die zwei Schaltflächen. ⚠️ Alle Meldungstexte werden VOR dem `await` aufgelöst (`use_build_context_synchronously`) |
| `features/more/widgets/sicherung_karte.dart` → `datenOrtSchluessel()` (re-export in settings_screen) | **S.4 ✅ (2026-09-16)** — ehrlicher Satz in `_SicherungKarte`, wo die Daten liegen: ohne Server `backup_only_here`, mit Server ohne Anmeldung `backup_only_here_signin`, angemeldet nichts. Test: `test/datenort_hinweis_test.dart` |
| `test/persistent_storage_test.dart` | prüft, dass auf der Dart-VM die io-Fassung greift |
| `core/constants/app_config.dart` | **S.3 ✅** — `SUPABASE_URL`/`SUPABASE_ANON_KEY` aus `--dart-define`. ⚠️ **Leer = kein Server**: keine Anmeldung, kein Netzaufruf. Ein `--dart-define` versteckt nichts (im Web per Textsuche in `main.dart.js` auffindbar) — der `anon`-Schlüssel darf das, `service_role` niemals |
| `core/utils/anmelde_adresse.dart` (+`_io`/`_web`) | **2026-09-23** — `entferneAnmeldeReste()`: nach `Supabase.initialize`, **قبل از runApp** (`main.dart`) بقایای لینک ایمیل را از آدرس برمی‌دارد (`?link=passwort`، `#access_token…`، `#error…`، `#sb=`، `?code=`) با `history.replaceState`؛ مسیر واقعی `#/…` می‌ماند. منطق در `anmelde_ruecklauf.dart`. Weiche wie `dokument_sprache.dart` |
| `core/utils/anmelde_ruecklauf.dart` | **نو 2026-09-23** — خالص (بدون مرورگر، تست‌پذیر): `AnmeldeRuecklauf {keiner, passwortLinkUngueltig}` · `anmeldeRuecklauf(Uri)` (فقط با نشانه‌ی `link=passwort`؛ اگر بعد از شروع Supabase هنوز `access_token`/`error…` در `#` باشد ⇒ نامعتبر) · `bereinigteAnmeldeAdresse(Uri)` · تست: `test/anmelde_ruecklauf_test.dart` (آدرس‌های واقعی سرور) |
| `core/services/auth_service.dart` | **S.3 ✅** — einzige Stelle, die `supabase_flutter` kennt. ⚠️ **Kein Benutzername** (`profiles` gehört Root-in). **`deleteAccount()` ✅ L.1d (2026-09-22)** · **`sendPasswordReset()` implizit (2026-09-23): eigener kurzlebiger `GoTrueClient(flowType: implicit)` nur für diese Anfrage ⇒ Link trägt die Sitzung im `#`, gilt in jedem Browser (PKCE-Verifier fehlte in anderem Browser). Der `token_hash`-Weg (2026-09-22) ist entfernt — Vorlagen sind im Gratis-Tarif auch per API gesperrt** → `AccountDeletion {deleted, unavailable, failed}`, zeichengleich zu Root-in — löscht `auth.users` = Konto in **beiden** Apps (Entscheidung Lukas). Gibt `AuthResult` zurück statt zu werfen; `AuthIssue` wird in der Oberfläche übersetzt, nicht hier |
| `supabase/vox_tables.sql` | **S.3 ✅** — `vox_backups`, eine Zeile je Konto. ⚠️ **Nicht** `backups` — die gehört Root-in und hat dieselbe `user_id` als Primärschlüssel; geteilt hieße: eine App überschreibt die Sicherung der anderen. `touch_updated_at()` **und (L.1d, §5) `delete_own_account()`** zeichengleich zu `schema.sql` in Root-in — Änderung immer in BEIDEN Dateien · ⏸️ فاز M: جدول‌های بسته/کد/دسترسی این‌جا با پیشوند `vox_` و `on delete cascade` (PLAN «💎 فاز M») |
| `features/more/widgets/profil_konto_karte.dart` → `ProfilKontoKarte` (bis P.2: `_KontoKarte` in settings_screen; `_kontoFehlerText` → `konto_texte.dart`) | **S.3 Schritt 2 ✅** — anmelden/registrieren/abmelden; nur sichtbar bei `kontoAktivProvider`. `AuthIssue` wird hier übersetzt (`_kontoFehlerText`). Noch **ohne** Cloud-Kopie — das ist Schritt 3 |
| `core/services/feature_flags.dart` | **L.2d** — deckهای «به‌زودی»: قبل از انتشار یا پر شوند یا `hidden` (نسخه‌ی نهایی دکمه‌ی بی‌محتوا ندارد) |
| `core/backup/cloud_abgleich.dart` | **S.3 Schritt 3** — holen → zusammenführen → nur bei Änderung hochladen; kennt kein Supabase. `CloudAblage.loeschen()` (L.1d): nur eigene `vox_backups`-Zeile — Notweg, wenn `delete_own_account()` fehlt |
| `core/services/cloud_ablage_supabase.dart` | echte `CloudAblage` (`vox_backups`); zweite und letzte Datei mit `supabase_flutter` |
| `features/more/controllers/konto_abgleich.dart` | wann abgeglichen wird (Anmeldung/Start, alle 5 Min., Knopf); `kontoAbgleichStarterProvider` in `app.dart` |
| `test/cloud_abgleich_test.dart` | Abgleich mit Server im Speicher: zwei Geräte, Entfernen, „zu neu", offline |
| `test/feature_flags_test.dart` | **L.2d** (2026-09-19) — `FeatureState.hidden` wirkt wirklich: Lookup-Regel, widerspruchsfreie Prädikate, und Quelltext-Wächter, dass Home-Kacheln Sprechen/Schreiben und beide Auswendiglernen-Listen `isVisible` abfragen (vorher las sie niemand — „verstecken" wäre wirkungslos gewesen) |
| `test/puzzling_buttons_test.dart` | **B.5** — kein roher Material-Button in `lib/features/`. Entstanden, weil `_SicherungKarte` und `_KontoKarte` die Regel unbemerkt gebrochen hatten |
| `test/auth_service_test.dart` | Fehlercode-Zuordnung (kann **still** brechen: „E-Mail vergeben" → „unbekannter Fehler") + Nachweis, dass ohne Konfiguration nichts geworfen und nichts gesendet wird |
| `core/backup/nutzer_profil.dart` | **P.1 (2026-09-20)** — `NutzerProfil`/`ProfilAdresse`/`ProfilFehler`, `telefonGueltig`, `normalisiereZiffern`, `NutzerProfil.spaeteres` (ادغام: آخرین ویرایش، کامل). Reines Dart. ⚠️ **Keine E-Mail hier** (gehört `auth.users`) |
| `core/backup/pruefungs_ergebnis.dart` | **T.1 (2026-09-25)** — `PruefungsErgebnis`/`PruefungsTeil`، `neuePruefungsId` (`pr:#`+32 hex)، `listeLesen` (بخشنده)، `listeSchreiben` (مرتب)، `vereinigen` (فقط افزودن)، **دور ۸۷:** `zeitLimitSekunden`/`zeitAbgelaufen`، `teilReihenfolge`/`teileGeordnet` (ترتیب کارنامه)، `vollstaendig()` (فقط آزمون کامل). Reines Dart. قرارداد **Fassung 5**؛ ذخیره: `kPruefungenKey`=`vox_pruefungen_v1` + `pruefungenLesen`/`pruefungMerken` در `user_state_repository.dart`؛ Provider: `features/pruefungen/controllers/pruefungs_ergebnisse_controller.dart`. ⚠️ پاسخ‌ها هرگز ذخیره نمی‌شوند. |
| `core/backup/nutzer_zustand.dart` → `profil` | **Vertrag Fassung 4 (P.1)** — Feld nur im JSON, wenn vorhanden; Fassung 1–3 lesbar; leeres Profil mit neuerem Zeitpunkt gewinnt |
| `core/backup/user_state_repository.dart` → `kProfilKey` (`vox_profil_v1`) | Profil in SharedPreferences; `lesen()` liest, `anwenden()` Schritt (6) schreibt. ⚠️ bewusst **nicht** in `einstellungsSchluessel` (dort „eigener Stand gewinnt" ⇒ neues Gerät bekäme das Profil nie) |
| `core/services/auth_service.dart` (P.2) | + `changePassword` · `changeEmail` · `sendPasswordReset` · `signOutEverywhere` · `watchPasswordRecovery`; `AuthIssue.samePassword`/`reauthNeeded`. ⚠️ Passwort/E-Mail gelten für **beide** Apps (`auth.users` geteilt) |
| `core/constants/app_links.dart` → `voxUrl` | Rücksprung-Adresse für Mails; **muss** in Supabase → Redirect URLs stehen, sonst landet der Link auf der Site URL (= Root-in) |
| `core/constants/app_links.dart` → `voxPasswortUrl` (2026-09-23) | `…/vox/?link=passwort` — Rücksprung der Passwort-Mail. **Muss zeichengleich** in Supabase → Redirect URLs stehen (eingetragen 2026-09-23); fehlt sie, landet der Link auf der Site URL (`localhost:3000`). Test prüft den Text |
| `features/more/…` (Profil-Seite) | siehe Baum `lib/features/more/` oben; Route `AppRoutes.profil` = `/more/profil`; Einstieg: More (erste Zeile) + Einstellungen → `_ProfilKachel` |
| `test/pomodoro_screen_test.dart` | **B-14b** — صفحه: ۳ سوییچ (پیش‌فرض‌ها + تغییر وضعیت Notifier)، بنر پایان فاز (en/fa) |
| `test/pomodoro_test.dart` | **B-14 + B-14b** — Pomodoro با ساعت و دستگاه جعلی: قفل صفحه، پایان فاز حین قفل، pause، ساعت به عقب، reset، استراحت بلند، ذخیره/بازیابی، ورودی خراب؛ wake-lock، صدا+بنر، شروع خودکار (قفل ۱۱۷ دقیقه، ۲۱ روز)، skip، سوییچ‌ها ذخیره می‌شوند |
| `test/profil_test.dart` · `test/profil_controller_test.dart` | **P** — Telefon/Bereinigen/JSON/Zusammenführen/Vertrag v4 (+ v3 lesbar)/Passwortregel/Auth-Codes · Notifier (bereinigt, Zeitpunkt, Ungültiges schreibt nichts) |
| **Nicht gebaut** | **Konto löschen** — offen L.1d (löscht `auth.users` ⇒ auch Root-in) |

✅ **S.5 (2026-09-15): Entfernungen und App-Wörter.**
| Stelle | Rolle |
|---|---|
| `core/backup/nutzer_zustand.dart` → `Mitgliedschaft` | Vertrag v2: letzte Handlung entscheidet „drin oder nicht"; Fach weiter „höchstes gewinnt" |
| `core/database/app_database.dart` → `Mitgliedschaften` + Helfer | Tabelle (art · schluessel · wort · drin · `amMs`) und `…Merken()`-Methoden. ⚠️ `amMs` = Millisekunden, kein DateTimeColumn (drift speichert sonst Sekunden) |
| `Words.ausApp` | nur der Seed setzt es (`vocab_seeded_v3`); solche Wörter gehen nie in eine Sicherung |
| `LeitnerDao` · `CategoryDao` · `WordDao` · `ImportService` · Fassade (Archiv) | **jede** Aufnahme/Entfernung schreibt ein Ereignis. ⚠️ Neue Stelle, die aufnimmt/entfernt ⇒ ebenfalls protokollieren, sonst kommt die Entfernung beim Abgleich zurück |
| `user_state_repository.dart` → `_entfernen()` | setzt eingehende Entfernungen in allen Tabellen um |

✅ **S.6 (2026-09-16): feste Listen-id.**
| Stelle | Rolle |
|---|---|
| `UserCategories.uid` + `nameAmMs` (`app_database.dart`) | feste id und Zeitpunkt des Namens; Index `user_categories_uid`; **Migration v7** trägt für alte Listen `eigen:<Name>` ein (= bisherige id) |
| `eigeneListenId(UserCategory)` (`app_database.dart`) | **einzige** Stelle, die aus einer Zeile die Listen-id macht |
| `neueEigeneListenId()` (`nutzer_zustand.dart`) | neue id `eigen:#<32 Hex>` — nur `CategoryDao.insertCategory` ruft sie |
| `KategorieStand.nameAm` | Vertrag v3: später vergebener Name gewinnt; ohne `nameAm` = älter als jede Umbenennung |
| `CategoryDao.updateCategory` | Umbenennen = nur Name + Zeitpunkt; die id bleibt |
| `test/migration_v7_test.dart` | echte Datei im Stand 6 → neu geöffnet: alte ids bleiben, doppelter Name ⇒ neue id, Index wirkt |
| `test/migration_test.dart` | **L.1b** — jede Fassung 2…6 mit Nutzerdaten → aktuelle Fassung: Schema exakt (drift `SchemaVerifier`), Leitner/Listen/Ereignisse erhalten |
| `UserCategories` → `@TableIndex(user_categories_uid)` | **L.1b** — der Index aus S.6 ist jetzt Teil des drift-Schemas (vorher rohes SQL, für die Schema-Prüfung unsichtbar) |
⚠️ Eine eigene Liste **nie** über ihren Namen suchen — immer über `uid`. Der Name ist nur Anzeige.

⚠️ **Jede Änderung an einer Drift-Tabelle braucht `dart run build_runner build`**
(`app_database.g.dart`, ~8.000 Zeilen, versioniert). Claude hat kein Dart im Container —
dafür gibt es `.github/workflows/build-runner.yml`. ✅ Seit dem PAT mit „Workflows: Read and
write" ist diese Blockade weg (S.0b/S.0c und فاز A / A.4 sind erledigt).
⚠️ **Seit L.1b:** Schema-Änderung ⇒ `schemaVersion` erhöhen + Migration + `build-runner.yml` auf dem Zweig — er legt
auch den Schema-Abzug der neuen Fassung an; `test/migration_test.dart` prüft sie dann von selbst.
⚠️ Schema-Änderung und `build_runner`-Lauf **unmittelbar hintereinander** schicken — sonst steht
ein Zwischenstand auf `main`, der nicht übersetzt, und jeder Commit auf `main` ist eine
Veröffentlichung.

---
