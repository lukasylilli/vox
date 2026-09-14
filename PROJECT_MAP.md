# PROJECT MAP — VOX
# نقشه کامل پروژه برای ناوبری سریع در هر session
# آپدیت: 2026-09-15
# ⚠️ 2026-09-13: Umbau zur reinen Web-App — android/ios/macos/linux/windows, RevenueCat & Notifications entfernt; ältere Einträge beschreiben teils den nativen Stand
# ⚠️ 2026-09-13: Habit/Routine entfernt — Root-in (eigenes Repo, lukasylilli.github.io/Root-in/) übernimmt das, verlinkt aus Selbstlernen ("Routine"-Karte, core/constants/app_links.dart + core/utils/external_link_opener.dart). Pomodoro bleibt unverändert.
# ⚠️ 2026-09-15 Audit (Claude, über GitHub-API): ۲۵۳ فایل Dart (بدون .g.dart) · ~۴۱٬۴۰۰ خط
#   · assets/vocab/ = ۸۷ کارت، همه schema 3.0، بدون JSON خراب (۷۶ verb · ۳ adjektiv · ۸ بقیه)
#   · ⚠️ vokabular_controller.dart همه کارت‌ها را در startup می‌خواند ⇒ سقف امن ~۵۰۰ کارت؛ V.2 پیش‌شرط شد
#   · ⚠️ مارک‌های ✓ در Wörter/*.txt از واقعیت عقب‌اند ⇒ منبع حقیقت = assets/vocab/ (tool/sync_backlog.py)
#   · B-3 / R-1.1 در کد رفع شده‌اند (stripPreposition در word_list_item.dart) — در BACKLOG اصلاح شد
#   · README قدیمی: «Selbstlernen — Gewohnheiten, Streaks» (Habit از 2026-09-13 حذف شده)
#   · فاز A (خودکارسازی ورود کلمات) باز شد — PLAN.md → «فاز A»
#
# 🎯 وضعیت: ۲۴۴ فایل Dart (۱۶۳ features + ۷۷ core) — analyze سبز
# فاز V (Vokabular-DB ۲۵k) طراحی شد — کجا کلمات ذخیره می‌شوند + معماری آینده: بخش «فاز V» + Services
# فازهای اخیر: G1 گرامر-کاتالوگ ✅ · B دکمه‌ها (Puzzling) ✅ · L زبان-فقط-Settings ✅
#              G2 LektionScreen ✅ · L2/L3 L10n ✅ (JSON+صفحات+دیتابیس)
#              همه محتوا FA+EN؛ asset-audit ۰؛ کاتالوگ ۵۶۵=۵۶۵؛ helper AppL10n.loc؛ schema v2
# جزئیات فازها: PLAN.md → «وضعیت فعلی» بالای فایل

---

## INHALTSVERZEICHNIS (فهرست مطالب)

| # | بخش | لینک |
|---|-----|------|
| 1 | Tech Stack | [→ Tech Stack](#tech-stack) |
| 2 | Root Files | [→ Root Files](#root-files) |
| 3 | Design System — Tokens | [→ constants/](#libcoredesign-system--tokens) |
| 4 | Design System — Components (موجود) | [→ widgets/ موجود](#libcoredesign-system--components-موجود) |
| 5 | Design System — Components (stub) | [→ widgets/ stub](#libcoredesign-system--components-stub) |
| 5b | Architecture Hub (stub) | [→ config/network/utils/services](#libcorearchitecture-hub-stub) |
| 6 | Theme & Decorations | [→ theme/](#libcoretheme) |
| 7 | Core Services | [→ services/](#libcoreservices) |
| 8 | Database | [→ database/](#libcoredatabase) |
| 9 | Router | [→ router/](#libcorerouter) |
| 10 | L10n | [→ l10n/](#libcorel10n) |
| 11 | Features — Wortschatz | [→](#libfeatureswortschatz-x) |
| 12 | Features — Leitner | [→](#libfeaturesleitner-x) |
| 13 | Features — Grammatik | [→](#libfeaturesgrammatik-x) |
| 14 | Features — Lesen | [→](#libfeatureslesen-x) |
| 15 | Features — Hören | [→](#libfeatureshoeren-x) |
| 16 | Features — Auswendiglernen | [→](#libfeaturesauswendiglernen-x) |
| 17 | Features — Prüfungen | [→](#libfeaturespruefungen-x) |
| 18 | Features — Selbstlernen | [→](#libfeaturesselbstlernen-x) |
| 19 | Features — Konnektoren | [→](#libfeatureskonnektoren-x) |
| 20 | Features — Dativ/Akkusativ | [→](#libfeaturesdativ_verben-x) |
| 21 | Features — NVV | [→](#libfeaturesnvv-x) |
| 22 | Features — Präpositionen | [→](#libfeaturespraepositionen-x) |
| 23 | Features — Reflexivverben | [→](#libfeaturesreflexiv_verben-x) |
| 24 | Features — Trennbar/Untrennbar | [→](#libfeaturestrennbar_verben-x) |
| 25 | Features — Verben mit Präp. | [→](#libfeaturesverb_praep-x) |
| 26 | Features — Unregelm. Verben | [→](#libfeaturesunregelm_verben-x) |
| 27 | Features — Redemittel 1010 | [→](#libfeaturesredemittel-x) |
| 27b | Features — Modalverben | [→](#libfeaturesmodalverben-x--2026-07-04) |
| 28 | Features — More / Home / Fragen | [→](#libfeaturesmore-x) |
| 29 | Database Tables | [→ Database Tables](#database-tables-drift--schema-v1--تغییر-نده) |
| 30 | Conventions | [→ Conventions](#key-conventions) |
| 31 | Bugs Fixed | [→ Bugs Fixed](#bugs-fixed) |
| 32 | Backlog | [→ Backlog](#backlog--upcoming-changes) |
| 33 | Architecture Principles | [→ Principles](#️-اصول-معماری-پایه-هر-session-باید-رعایت-شود) |

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

## ROOT FILES
```
pubspec.yaml            [x]  — همه dependencies (drift, riverpod, go_router, just_audio, ...)
analysis_options.yaml   [x]  — lint rules
PROJECT_MAP.md          [x]  — این فایل («Map»)
PLAN.md                 [x]  — پلن کامل صفر تا انتشار («Plan»)
GRAMMATIK_MAP.md        [x]  — نقشه کامل بخش گرامر: کاتالوگ ۹۳ موضوع، ۴ نما،
                               Stufenplan G1–G8، جدول Master + Änderungsprotokoll
test/widget_test.dart   [x]  — smoke test (VoxApp در ProviderScope)
```

---

## lib/ — COMPLETE FILE TREE

### lib/main.dart [x]
PURPOSE: entry point — WidgetsFlutterBinding + ProviderScope + VoxApp
⚠️ RevenueCat entfernt (2026-09-13) — die Web-App ist kostenlos, kein Abo-System

### lib/app.dart [x]
PURPOSE: VoxApp (ConsumerWidget) — MaterialApp.router، theme، locale، routerConfig

---

### lib/core/

---

## lib/core/Design System — Tokens
> فایل‌های token = مقادیر پایه که همه کامپوننت‌ها از آن‌ها می‌خوانند.
> تغییر یک token → تغییر خودکار در کل اپ.

```
constants/
  app_colors.dart      [x]  — رنگ ۱۲ بخش + primary palette — فعلاً فعال
  article_colors.dart  [x]  — der/die/das colors — فعلاً فعال
  app_routes.dart      [x]  — route path constants — فعلاً فعال
  app_sizes.dart       [x]  — spacing xs/sm/md/lg/xl، radius، iconSizes — فعلاً فعال

  vox_colors.dart      [ ]  stub — رنگ‌های کامل + CEFR + register + semantic + article
                             آینده: جایگزین app_colors.dart + article_colors.dart
  vox_typography.dart  [ ]  stub — همه TextStyle tokens (heading, body, badge, quiz)
  vox_icons.dart       [ ]  stub — semantic icon constants (VoxIcons.quiz, .grammar, ...)
```

---

## lib/core/Design System — Components (موجود)
> این کامپوننت‌ها کد دارند و live هستند.

```
widgets/
  vox_button.dart         [x]  — ⭐ بازنویسی کامل (فاز B — 2026-07-07): تنها منبع همه دکمه‌ها
                                 اصل Puzzling: هیچ screen ای کد دکمه ندارد — فقط reference
                                 همه variant ها روی System-Widgets متریال (آپدیت خودکار با فریمورک):
                                 VoxButton: primary/tonal/secondary/text/success/destructive/
                                   destructiveOutlined/header/small + size(S/M/L) + expand + loading
                                 VoxIconButton: plain/filled/tonal/outlined + isSelected/selectedIcon
                                 VoxFab + VoxFab.extended
                                 VoxOptionButton: گزینه آزمون (idle/selected/correct/wrong) — همه ۱۱ quiz [B.4 ✅]
                                 منبع طراحی: old files Lukasalmani/1/Button (نسخه System-APIs)
  vox_badge.dart          [x]  — VoxBadge.level(level) — colored، wordType، colored variants
  article_badge.dart      [x]  — pill badge رنگی برای der/die/das (prop: large)
  filter_accordion.dart   [x]  — FilterAccordion(label, options, selected, onChanged)
                                 FilterOption(value, label, icon?)
  filter_chip_bar.dart    [x]  — FilterChipBar(activeFilters, onRemove, onClearAll)
  vox_error_widget.dart   [x]  — VoxErrorWidget(error, onRetry?, compact?)
  vox_loading_widget.dart [x]  — VoxLoadingWidget(label?) + VoxSkeletonBlock(shimmer)
  audio_play_button.dart  [x]  — TTS toggle button (delegates to ttsServiceProvider)
  leitner_add_button.dart [x]  — compact / full LeitnerAddButton
  grammar_link_button.dart[x]  — navigate به /grammatik یا /grammatik/$level
  quiz_launch_button.dart [x]  — navigate به /grammatik/lesson/$id/quiz
  global_search_bar.dart  [x]  — GlobalSearchAction IconButton → /search (AppBar only)

theme/
  app_theme.dart          [x]  — AppTheme.light + AppTheme.dark (GoogleFonts.vazirmatn)
  app_decorations.dart    [x]  — AppDecorations.card/cardSolid/cardGradient/chip/
                                 headerStrip/sectionHeader/iconCircle/infoBanner
```

---

## lib/core/Design System — Components (B9–B11 اکثراً LIVE شدند — 2026-07-04)
> فایل‌های [x] کد دارند و در صفحات متصل شده‌اند. [ ] هنوز stub.

```
widgets/
  vox_search_field.dart   [x]  LIVE — VoxSearchField(controller, hint, onChanged?, showClear?)
                                      متصل: ۱۱ list screen (همه inline TextFieldها حذف شدند)
  vox_empty_state.dart    [x]  LIVE — .noResults()، .noData()، .comingSoon()
                                      متصل: redemittel lists
  vox_chip.dart           [x]  LIVE — VoxRegisterDot، VoxCountPill
                                      (CEFR badge = VoxBadge.level در vox_badge.dart)
  vox_dialog.dart         [x]  LIVE — .quizResult()، .confirm()، .info()
                                      متصل: ۹ quiz result dialog
  vox_snack_bar.dart      [x]  LIVE — .show()، .comingSoon()، .success()، .error()، .copied()
                                      متصل: auswendiglernen comingSoon
  vox_progress.dart       [x]  LIVE — VoxQuizProgressBar.title/.bar + VoxStepDots
                                      متصل: ۱۱ quiz/exam/cloze screen
  vox_list_tile.dart      [ ]  stub — VoxListTile، VoxPhraseListTile، VoxVerbListTile، ...
  vox_section_header.dart [ ]  stub — .simple()، .withIcon()، .collapsible()، .labeled()
  vox_card.dart           [ ]  stub — VoxCard، VoxGradientCard، VoxInfoCard، VoxDetailCard
  vox_divider.dart        [ ]  stub — VoxDivider، VoxLabeledDivider، VoxSectionSpacer
  vox_bottom_bar.dart     [ ]  stub — VoxBottomBar، VoxWordDetailBar، VoxQuizActionBar
  vox_text_field.dart     [ ]  stub — VoxTextField، VoxMultilineField، VoxClozeField
  vox_app_bar.dart        [ ]  stub — VoxListAppBar، VoxDetailAppBar، VoxQuizAppBar

constants/
  vox_colors.dart         [x]  LIVE — CEFR/article/register/wordType/semantic/quiz tokens
                                      متصل: vox_badge + ۱۲ مکان (همه switchهای رنگ حذف شدند)
  vox_typography.dart     [ ]  stub — TextStyle tokens: heading، body، badge، quiz variants
  vox_icons.dart          [ ]  stub — semantic icon constants (VoxIcons.quiz → Icon)

theme/
  vox_animations.dart     [ ]  stub — VoxDurations (fast/normal/slow)، VoxCurves، VoxTransitions
```

---

## lib/core/Architecture Hub
> زیرساخت مرکزی — مکمل Design System: آنجا UI، اینجا Logic/Infra.
> ✅ B1–B11 پیاده‌سازی و متصل شدند (2026-07-04) — جزئیات اتصال در PLAN.md فاز ARCH.

```
config/
  app_env.dart            [x]  LIVE — AppEnv.revenueCatKey* via --dart-define
                                      main.dart دیگر key hardcoded ندارد
network/
  api_client.dart         [x]  LIVE — ApiClient.getText/getJson، ApiException typed،
                                      timeout 15s، logging — استفاده: rss_service
utils/
  formatters.dart         [x]  LIVE — faDigits، countLabel، outOf، percent،
                                      relativeDate، minutesLabel، timer
                                      استفاده: ۱۱ صفحه + VoxDialog + VoxQuizProgressBar
  debouncer.dart          [ ]  stub — search debounce (بعدی)
  validators.dart         [ ]  stub — form validation مرکزی (بعدی)
  extensions.dart         [ ]  stub — StringX/ContextX/ListX (بعدی)
services/
  feature_flags.dart      [x]  LIVE — ۲۳ فلگ — استفاده: auswendiglernen decks +
                                      content_registry.isReady
  cache_service.dart      [x]  LIVE — file-based TTL + getStale — استفاده: rss_service
  app_logger.dart         [x]  LIVE — AppLogger(tag) + loggerProvider
  permission_service.dart [x]  LIVE — notifications؛ mic/speech آماده برای Sprechen
  backup_service.dart     [ ]  stub — export/import داده کاربر (بعدی)

test/helpers/
  mock_data_factory.dart  [ ]  stub — fixture همه model‌ها + in-memory drift db (B12)

.github/workflows/
  ci.yml                  [ ]  stub — analyze + test — ⚠️ پیش‌نیاز: git init (B12)
```

**معادل‌های موجود (دوباره ساخته نشدند):** main.dart · pubspec.yaml · Riverpod (di/store) ·
app_router + app_routes · app_database (db) · subscription_service (auth/RevenueCat) ·
app_l10n (i18n) · app_theme + tokens (theme) · widget_test (setupTests)
**N/A فعلاً:** AuthInterceptor · cryptoUtils · JSBridge

#### lib/core/database/
```
app_database.dart   [x]  — drift DB + همه ۱۲ table definition
                           Words, Books, WordBooks, UserCategories, CategoryWords,
                           LeitnerCards, GrammarLessons, MemorizeItems,
                           ReadingTexts, AudioItems, Habits, HabitSessions
                           schemaVersion=2، onCreate=createAll +
                           onUpgrade(from<2: addColumn MemorizeItems.meaningEn) — فاز L3-E
                           ⚠️ بعد از تغییر: dart run build_runner build
app_database.g.dart [x]  — generated (build_runner) — دست نزن
dao/
  word_dao.dart     [x]  — watchAll، watchByLevel، watchByType، watchByBook (join)
                           getById، search (lower().like())، insert، update، delete
                           addToBook، removeFromBook، watchAllBooks، insertBook
  leitner_dao.dart  [x]  — watchDue، watchAll، watchByBox، getDue، getByWordId
                           isInLeitner، countsByBox، countDue
                           addWord (box1، nextReview=tomorrow)
                           markCorrect (advance+1، max 5، nextReview=now+interval)
                           markWrong (reset box=1، nextReview=tomorrow)
                           removeCard — static const boxIntervals = [1,2,4,8,16]
  category_dao.dart [x]  — watchAll، getById، insertCategory، updateCategory
                           deleteCategory (cascade CategoryWords)
                           watchWordsByCategory، isWordInCategory، categoryIdsForWord
                           addWordToCategory، removeWordFromCategory
  grammar_dao.dart  [x]  — watchAll، watchByLevel، getAll، getByLevel، getById
                           countByLevel() → Map<String,int> (a1-c2 always present)
                           insert، update، delete
  pruefungen_dao.dart [x] — از GrammarLessons با level prefix "pruefung_{org}_{level}"
                           levelKey(org,level)، getByExam، watchByExam، countByLevel
                           insert، delete
  lesen_dao.dart    [x]  — watchAll، watchByLevel، getById، countByLevel، insert، update، delete
  hoeren_dao.dart   [x]  — watchAll، watchByLevel، getById، countByLevel، insert، update، delete
  habit_dao.dart    [x]  — watchAll، watchActive، getById، insertHabit، updateHabit
                           deleteHabit (cascade sessions)، setActive، incrementStreak، resetStreak
                           addSession، getSessionsInRange، wasCompletedToday، last7DaysCounts
```

#### lib/core/models/
```
word_model.dart     [x]  — enum WordType (9 values با label)
                           enum GermanLevel (a1-c2 با label)
                           class VerbConjugation { infinitiv, praesens, praeteritum, partizip }
                           class WordModel (همه فیلدها) + factory fromRaw()
lesson_model.dart   [x]  — enum ExerciseType { lueckentext, wortstellung }
                           class GrammarExercise.fromJson() / toJson()
                           class LessonModel.fromRaw(id,title,level,content,sortOrder)
                           content JSON: {"body":"...","exercises":[...]}
                           encodeContent() → JSON string
```

#### lib/core/parsers/
```
word_parser.dart          [x]  — فرمت استاندارد: Nomen (article detect)، simple (فارسی)، typed
connector_parser.dart     [x]  — marker "K" در field[1]، WordType.konnektor
irregular_verb_parser.dart[x]  — marker "UV" در field[1]، min 6 fields، VerbConjugation
nvv_parser.dart           [x]  — marker "NVV" در field[1]، level از field[3]
parser_registry.dart      [x]  — ParserRegistry.parse(input) → WordModel?
                                 switch روی _extractMarker → UV/K/NVV/default
                                 formatHint(ParseFormat) → راهنمای فرمت
```

#### lib/core/services/
```
tts_service.dart          [x]  — TtsService (NotifierProvider<TtsService, TtsPlayState>)
                                 speak، stop، toggle، setRate — language=de-DE، rate=0.85
                                 TtsPlayState: playing، currentText، rate، isPlayingText(text)
audio_service.dart        [x]  — AudioService (NotifierProvider<AudioService, AudioPlayState>)
                                 load(path)، play، pause، toggle، seek، seekBy، stop، setSpeed
                                 AudioPlayState: playing، position، duration، speed، currentPath، progress
rss_service.dart          [x]  — RssService.fetch(url) → List<RssItem>
                                 RssItem: title، description، link، pubDate، imageUrl
                                 _stripHtml، _parseDate (ISO + RFC 2822)
notification_service.dart [x]  — NotificationService static singleton
                                 showLeitnerReminder(count)، showHabitReminder(id,name)
import_service.dart       [x]  — ImportService: importWordsCsv، importWordsJson، importMemorizeJson
                                 ImportResult {imported, skipped, error}، importServiceProvider
subscription_service.dart [x]  — RevenueCat Riverpod integration (2026-06-30)
                                 customerInfoProvider (StreamProvider — listener-based stream)
                                 isProProvider (Provider<bool> — entitlement: 'VOX Unlimited')
                                 offeringsProvider (FutureProvider<Offerings?> — invalidatable)
                                 SubscriptionActions: purchase، restore، login، logout
```

#### lib/core/theme/
```
app_theme.dart  [x]  — AppTheme.light + AppTheme.dark
                       GoogleFonts.vazirmatnTextTheme()، Material 3، CardThemeData
```

#### lib/core/l10n/
```
app_l10n.dart   [x]  — themeModeProvider (StateProvider<ThemeMode>، default: dark)
                       AppL10n.t(context, key) → String (کاتالوگ FA/EN)
                       AppL10n.meaning(context, fa:, en:) → زبان فعال برای محتوا
                       supportedLocales = [Locale('fa'), Locale('en')]
                       AppL10n.isFa(context) → bool (فاز L — برای widget های فرزند)
                       زبان واقعی از settingsProvider.uiLanguage می‌آید (app.dart → locale:)
                       ✅ Phase 7 (2026-06-30): 100+ keys — همه UI strings استاتیک localize شدند
                       ✅ فاز L کامل (2026-07-07): کاتالوگ ۲۵۱=۲۵۱ کلید (پاریتی صفر اختلاف؛
                       کلیدهای جدید: pronunciation/conjugation/etymology/common_errors/
                       grammar_note/note_label) · هر ۶ سوییچ _showFa حذف شد · همه
                       Dual-Display ها تک‌زبانه شدند (word_detail، word_list_item، flash_card،
                       word_popup، nvv/praep/redemittel details) · ۲۳ فایل AppL10n.meaning/isFa
                       قانون: زبان فقط از Settings؛ آلمانی هرگز تغییر نمی‌کند؛
                       گیت: grep '_showFa' lib/features = ۰
                       ✅ فاز L2 (2026-07-07): کاتالوگ ۲۵۱→۵۳۳ کلید؛ ۶۴۱ رشته FA hardcoded
                       در ~۹۰ فایل لایه UI حذف/کلیددار شد. helper های جدید:
                       AppL10n.tf(ctx,key,{args}) · AppL10n.activeLang+ts(key) (بدون context)
                       Formatters.useFa (ارقام/تاریخ locale-aware، در app.dart ست می‌شود)
                       FilterAccordion/ChipBar/vox_dialog/vox_empty_state/vox_snack_bar
                       لیبل‌ها را از t() رد می‌کنند (کلید ناشناخته → بدون تغییر)
                       مدل‌های enum: labelFa → کلید برمی‌گرداند، UI با t() ترجمه می‌کند
                       ✅ فاز L3 A–D (2026-07-07): **همه محتواها FA+EN**. کاتالوگ ۵۶۵=۵۶۵.
                       helper مرکزی جدید: **AppL10n.loc(ctx, jsonMap, 'base')** — en با
                       fallback به fa (استاندارد خواندن JSON دوزبانه در Screens).
                       ۱٬۵۰۰+ فیلد en در assetها اضافه شد (redemittel titles ۱٬۱۸۴،
                       konnektoren_rich ۱۲۱، grammar JSONها). asset-audit = ۰ فیلد fa بدون en.
                       ۱۰ صفحه content (grammar/leitfaden/fragen/privacy) inline دوزبانه شدند.
                       گیت دقیق: هیچ Text('رشته FA') مستقیم در صفحات content.
                       ✅ L3-E: MemorizeItems.meaningEn (nullable) + schema v2 onUpgrade؛
                       memorize/cloze/category/search locale-aware؛ import meaning_en
                       ⚠️ Dynamic strings (با $variable interpolation) intentionally left as-is
                           مثال: '$count کارت'، 'صندوق $box'، '$score از $total درست'
                           دلیل: نیاز به ICU plural/interpolation system فراتر از key-value lookup
```

#### lib/core/router/
```
app_router.dart    [x]  — GoRouter — همه routes LIVE. نکات مهم:
                          ⚠️ Quiz routes: اگر extra=null باشد، Consumer loader داده را از provider می‌خواند
                              (konnektoren، dativ، nvv، praepositionen همه این pattern را دارند)
                          ⚠️ helper widgets در انتهای فایل: _LoadingScaffold، _ErrorScaffold
                          / → HomeScreen
                          /wortschatz → WortschatzHomeScreen
                            list (?suche=) — لیست ادغامی DB + Vokabular-Karten
                            add، level، type، books/:bookId، word/:wordId
                            categories/:categoryId → CategoryDetailScreen (extra=name)
                          /vokabular/wort/:id → WortSeiteScreen (فقط Wort-Seite؛ لیست در /wortschatz/list)
                          /leitner → LeitnerHomeScreen
                            review، stats
                          /grammatik → GrammatikHomeScreen
                            lesson/:lessonId → LessonDetailScreen (BEFORE :level)
                              exercise، quiz
                            katalog/:view/:key → GrammatikKatalogScreen (G1، BEFORE :level)
                            thema/:topicId → GrammarTopicScreen (BEFORE :level)
                            :level → LevelLessonsScreen
                          /lesen → LesenHomeScreen
                            news، text/:textId، :level (static before param)
                          /hoeren → HoerenHomeScreen
                            karaoke/:audioId، shadowing/:audioId، quiz/:audioId
                            :level → LevelAudioListScreen
                          /search → SearchResultsScreen(?q=)
                          /import → ImportScreen
                          /sprechen → SprechenHomeScreen
                          /schreiben → SchreibenHomeScreen
                          /fragen → FragenScreen
                          /sozialmedien → SozialmedienScreen
                          /more → MoreHomeScreen (settings، subscription)
route_guards.dart  [ ]  — فاز بعدی (subscription guard)
```

<!-- widgets/ is now documented in the Design System sections above -->

---

### lib/features/

#### lib/features/home/ [x]
```
screens/home_screen.dart       [x]  — SliverAppBar + SliverGrid 3×4، 12 SectionData
widgets/section_grid_item.dart [x]  — gradient card + shadow، color.withValues(alpha:...)
```

#### lib/features/wortschatz/ [x]
```
screens/
  wortschatz_home_screen.dart  [x]  — stats banner + _MenuItem (Alle Wörter، Bücher، Leitner، Kategorien) + Add FAB
  wortschatz_list_screen.dart  [x]  — «Alle Wörter» = لیست ادغامی دو منبع: allWordsProvider (DB → WordListItem)
                                      + vokabularProvider (assets/vocab → WortCard+WortActions → /vokabular/wort/:id)؛
                                      سورت الفبایی مشترک (بدون Artikel)؛ SearchBar + FilterAccordion (Niveau، Wortart،
                                      نگاشت _typZuWortart) + FilterChipBar؛ query param `suche`؛ route: /wortschatz/list
  book_list_screen.dart        [x]  — allBooksProvider + FAB + _addBook dialog
  book_words_screen.dart       [x]  — wordsByBookProvider(bookId) + ListView
  level_words_screen.dart      [x]  — wordsByLevelProvider + _LevelPickerBar (legacy، هنوز در router)
  type_words_screen.dart       [x]  — wordsByTypeProvider + _TypePickerBar (legacy، هنوز در router)
  word_detail_screen.dart      [x]  — همه فیلدها conditional + BottomBar:
                                      LeitnerAddButton / دسته‌بندی / آزمون(placeholder)
  add_word_screen.dart         [x]  — TextField → ParserRegistry.parse → _ParsePreview → save
controllers/
  word_controller.dart         [x]  — databaseProvider، wordDaoProvider
                                      allWordsProvider، wordsByLevel/Type/Book
                                      searchQueryProvider، searchResultsProvider
                                      wordByIdProvider
                                      ext WordToModel on Word → toModel()
                                      ext ModelToCompanion on WordModel → toCompanion()
                                      ⚠️ import 'package:drift/drift.dart' show Value;
widgets/
  word_list_item.dart          [x]  — card: ArticleColorIndicator + ArticleBadge + _LevelChip
  article_color_indicator.dart [x]  — نوار رنگی 4px سمت چپ (بر اساس article)
  conjugation_table.dart       [x]  — جدول 4 ردیف: Infinitiv/Präsens/Präteritum/Partizip II
```

#### lib/features/leitner/ [x]
```
screens/
  leitner_home_screen.dart   [x]  — _DueBanner (gradient) + BoxProgressWidget + FAB مرور
                                    AppBar: آیکون آمار → leitnerStats
  leitner_review_screen.dart [x]  — ConsumerStatefulWidget: _loadCards در initState
                                    FlashCardWidget + _AnswerButtons (درست/نمی‌دونستم)
                                    _SummaryScreen در پایان (score، pct، _StatCard)
  leitner_stats_screen.dart  [x]  — _StatChip × 3 + BoxProgressWidget + LinearProgressIndicator
                                    جدول upcoming reviews (group by days)
controllers/
  leitner_controller.dart    [x]  — leitnerDaoProvider، dueCardsProvider، allLeitnerCardsProvider
                                    leitnerByBoxProvider، boxCountsProvider، dueCountProvider
                                    isInLeitnerProvider، boxLabels، boxIntervals
widgets/
  flash_card_widget.dart     [x]  — 3D flip (Matrix4.rotateY، AnimationController 400ms)
                                    front: German + article badge + AudioPlayButton
                                    back: meaningFa + conjugation table + examples
  box_progress_widget.dart   [x]  — Row 5 رنگ‌دار با count + label + interval
```

#### lib/features/categories/ [x]
```
screens/
  category_list_screen.dart    [x]  — allCategoriesProvider + FAB + rename/delete dialogs
                                      navigate → /:categoryId با extra=name
  category_detail_screen.dart  [x]  — wordsByCategoryProvider + Dismissible (swipe حذف)
                                      _EmptyCategory با لینک به Wortschatz
controllers/
  category_controller.dart     [x]  — categoryDaoProvider، allCategoriesProvider
                                      wordsByCategoryProvider(categoryId)
                                      categoryIdsForWordProvider(wordId)
                                      isWordInCategoryProvider({categoryId, wordId})
widgets/
  add_to_category_sheet.dart   [x]  — showAddToCategorySheet(context, wordId)
                                      DraggableScrollableSheet + CheckboxListTile
                                      toggle membership + "جدید" inline create
```

#### lib/features/grammatik/ [x]
> ⭐ نقشه کامل بخش گرامر: **GRAMMATIK_MAP.md** (کاتالوگ ۹۳ موضوع، ۴ نمای مرتب‌سازی، Stufenplan G1–G8)
```
models/
  grammar_catalog.dart         [x]  — G1: GrammatikKatalog/KatalogEintrag/KatalogThema/KatalogSatzglied
                                      + icon/color per Thema، byNiveau/byThema/bySatzglied/lektionen
  grammar_topic.dart           [x]  — GrammarTopicSection + Register (grammarTopics)
screens/
  grammatik_home_screen.dart   [x]  — G1 بازسازی شد (2026-07-06): ChoiceChips ۴ نما
                                      (Niveau ۶ کارت گرادیانی · Thema ۱۵ · Lektionen مسیر خطی ۱..۸۴
                                      + Vertiefung · Satzglieder ۷) — همه از grammatik_katalog.json
  grammatik_lektion_screen.dart[x]  — G2: رندر Content-JSON یک لکسیون (route /grammatik/lektion/:slug)
                                      بلوک‌ها (DE ثابت + FA/EN فعال) + DataTable + مثال‌ها + verwandte
                                      مدل grammatik_lektion.dart + controller grammatik_lektion_controller.dart
                                      (لیست _contentFiles؛ G3–G6 خط اضافه می‌کنند). ۴ درس live.
  grammatik_katalog_screen.dart[x]  — G1: صفحه پارامتریک /grammatik/katalog/:view/:key
                                      niveau/satzglied → گروه‌بندی بر اساس Thema · thema → flat
                                      + کارت «Lektionen & Übungen» → /grammatik/:level (سیستم DB قدیم)
  level_lessons_screen.dart    [x]  — lessonsByLevelProvider، ListTile با sortOrder circle
  lesson_detail_screen.dart    [x]  — lessonByIdProvider، SelectableText body
                                      bottom bar: تمرین→exercise، آزمون→quiz (اگر exercises.isNotEmpty)
  grammar_exercise_screen.dart [x]  — ListView.separated همه تمرین‌ها، number circle + hint
  grammar_quiz_screen.dart     [x]  — یک تمرین در هر بار، _OptionButton feedback، QuizResultWidget
controllers/
  grammar_catalog_controller.dart [x] — G1: grammatikKatalogProvider (asset) +
                                      grammatikSortModeProvider (StateNotifier، persist در
                                      shared_preferences با کلید 'grammatik_sort_mode')
  grammar_controller.dart      [x]  — grammarDaoProvider، allLessonsProvider
                                      lessonsByLevelProvider، lessonByIdProvider، levelCountsProvider
                                      _toModel(GrammarLesson) → LessonModel
widgets/
  katalog_eintrag_tile.dart    [x]  — G1: سطر کاتالوگ — live→push(route) · geplant→snackbar «به‌زودی»
                                      Niveau badges + شماره لکسیون/آیکون Thema
  lueckentext_widget.dart      [x]  — template.split('___')، TextField inline، green/red feedback
  wortstellung_widget.dart     [x]  — source chips → answer chips، _check()، reset
  quiz_result_widget.dart      [x]  — _ScoreCircle (CircularProgressIndicator)
                                      wrongAnswers: List<WrongItem>، onRetry، onDone
```

#### lib/features/lesen/ [x]
```
screens/
  lesen_home_screen.dart     [x]  — _NewsCard banner → /lesen/news
                                    GridView 2col level cards، textLevelCountsProvider
  level_texts_screen.dart    [x]  — textsByLevelProvider، _TextTile (preview 100 chars)
  text_reader_screen.dart    [x]  — ReaderToolbar در AppBar.bottom، level chip، ClickableWordText
  news_screen.dart           [x]  — ExpansionTile cards، feed switcher (Tagesschau/DW)، copy link
controllers/
  lesen_controller.dart      [x]  — lesenDaoProvider، allTextsProvider، textsByLevelProvider
                                    textByIdProvider، textLevelCountsProvider
                                    rssFeedUrlProvider، rssItemsProvider (FutureProvider)
                                    readerFontSizeProvider (StateProvider، default 16.0)
                                    wordLookupProvider (exact match first)
widgets/
  clickable_word_text.dart   [x]  — tokenize با regex [a-zA-ZäöüÄÖÜß]+
                                    TapGestureRecognizer → showWordPopup، SelectableText.rich
  word_popup_card.dart       [x]  — showWordPopup(context, rawWord)
                                    _cleanWord: strip non-letter chars، wordLookupProvider
                                    TTS IconButton.filled + LeitnerAddButton، _NotFound widget
  reader_toolbar.dart        [x]  — PreferredSizeWidget (48px)
                                    TTS play/stop، _SpeedButton [0.5,0.75,0.85,1.0,1.25]
                                    font size ±2 (range 12-28)
```

#### lib/features/hoeren/ [x]
```
screens/
  hoeren_home_screen.dart      [x]  — GridView 2col، 6 colored cards، audioLevelCountsProvider
  level_audio_list_screen.dart [x]  — audioByLevelProvider، _AudioTile
                                      icons: karaoke/shadowing/quiz per item
  karaoke_screen.dart          [x]  — load audio in initState، KaraokeTextDisplay
                                      fallback _NoTranscript با play button
  shadowing_screen.dart        [x]  — _splitIntoSentences (by . ? !)
                                      play sentence → pause → mic prompt → next
  hoeren_quiz_screen.dart      [x]  — 20% کلمات blank، context 3 words قبل+بعد
                                      play context button، TextField fill-in، نتیجه
controllers/
  hoeren_controller.dart       [x]  — hoerenDaoProvider، allAudioProvider، audioByLevelProvider
                                      audioByIdProvider، audioLevelCountsProvider
                                      transcriptProvider، TranscriptWord {word,startMs,endMs}
                                      export AudioService، AudioPlayState، audioServiceProvider
widgets/
  karaoke_text_display.dart    [x]  — Wrap با AnimatedContainer، highlight word at posMs
                                      posMs >= startMs && posMs <= endMs
  audio_player_controls.dart   [x]  — PreferredSizeWidget (96px)
                                      Slider seek bar، ±10s، play/pause FilledButton circle
                                      _SpeedButton [0.5,0.75,1.0,1.25,1.5]
```

#### lib/features/auswendiglernen/ [x]
```
screens/
  auswendiglernen_home_screen.dart [x]  — flat ListView (_learningDecks + _PruefungenDivider + _pruefungenDecks)
                                          بدون section headers، جداکننده "PRÜFUNGEN" قبل از Redemittel
                                          coming-soon decks: lock icon، snackbar on tap
  category_items_screen.dart       [x]  — ExpansionTile list، action bar مرور/cloze
  memorize_card_screen.dart        [x]  — load snapshot، ValueKey per card، درست/نمیدونستم
                                          _SummaryScreen با CircularProgressIndicator
  cloze_practice_screen.dart       [x]  — ClozeFillWidget یک به یک، نتیجه درصدی
controllers/
  auswendiglernen_controller.dart  [x]  — memorizeCategories[15]، memorizeCategoryIconsFa[15]
                                          memorizeDaoProvider، itemsByCategoryProvider
                                          categoryCountsProvider، categoryItemsSnapshotProvider
widgets/
  memorize_card_widget.dart        [x]  — 3D flip Matrix4.rotateY 400ms
                                          _FrontFace: phrase + level chip
                                          _BackFace: meaning + examples (max 2)
                                          didUpdateWidget: reset on card change
  cloze_fill_widget.dart           [x]  — blank کلمه ≥3 حرف، inline TextField در Wrap
                                          green/red border feedback، onResult callback
```

#### lib/features/pruefungen/ [x]
```
screens/
  pruefungen_home_screen.dart  [x]  — ۳ OrgCard با gradient + level chips
                                      + بخش "تمرین‌های موضوعی": لیست _TopicQuizTile
                                      ⚠️ لینک‌ها به quiz screens می‌روند — نه صفحه جدید
                                      Konnektoren → /konnektoren/quiz (بدون extra، Consumer loader)
                                      Dativ → /dativ-verben/quiz (بدون extra، Consumer loader)
                                      NVV → /nvv/quiz (بدون extra، Consumer loader)
                                      Präpositionen → /praepositionen/quiz (بدون extra، Consumer loader)
  exam_type_screen.dart        [x]  — سطوح + count + _PrepGuide (tips per org)
  exam_simulation_screen.dart  [x]  — Timer.periodic countdown، سوال به سوال
                                      تایمر قرمز زیر ۳۰۰s، finish on expire
                                      ExamScoreWidget on done/expire
controllers/
  pruefungen_controller.dart   [x]  — enum ExamOrg { goethe, telc, oesd }
                                      ExamOrgExt: displayName، key، levels، timeLimitMinutes
                                      pruefungenDaoProvider، examLessonsProvider
                                      examLevelCountsProvider، examExercisesProvider
                                      ExamKey = ({org, level}) record type
widgets/
  exam_question_widget.dart    [x]  — LueckentextWidget + WortstellungWidget
                                      onAnswer(isCorrect, userAnswer) callback
                                      deterministic shuffle: Random(index)
  exam_score_widget.dart       [x]  — score circle، قبول/رد (threshold ۶۰٪)
                                      ۴ stat chips: درست/اشتباه/کل/زمان
```

#### lib/features/selbstlernen/ [x]
```
screens/
  selbstlernen_home_screen.dart   [x]  — ۴ gradient cards: Habit، Pomodoro، Lernpfad، Vorlagen
  habit_maker_screen.dart         [x]  — لیست + dialog ایجاد/ویرایش (name، days، shift)
  habit_stats_screen.dart         [x]  — header + streak chart + ثبت امروز
  pomodoro_screen.dart            [x]  — phase label + timer + play/pause/reset/skip + linked habit
  leitfaden_screen.dart           [x]  — MountainProgressWidget + level cards با skill chips
  vorlagen_screen.dart            [x]  — ۶ قالب A1→C1، ExpansionTile، clipboard copy
controllers/
  selbstlernen_controller.dart    [x]  — allHabitsProvider، activeHabitsProvider، habitByIdProvider
                                         habitLast7DaysProvider، habitCompletedTodayProvider
                                         HabitActions (create/update/delete/toggleToday)، habitActionsProvider
                                         PomodoroState، PomodoroNotifier، pomodoroProvider
                                         dayNames[7]، PomodoroPhase enum با labelFa + defaultSeconds
widgets/
  streak_chart_widget.dart        [x]  — fl_chart BarChart آخر ۷ روز، سبز/خاکستری
  mountain_progress_widget.dart   [x]  — CustomPainter: ۷ نقطه A1→C2، رنگ done/current/todo
  pomodoro_timer_widget.dart      [x]  — CircularProgressIndicator + timeLabel + session dots
  habit_day_selector_widget.dart  [x]  — ۷ AnimatedContainer دکمه Mo-So، toggle selection
```

#### lib/features/more/ [x]
```
screens/
  more_home_screen.dart       [x]  — ۳ section: اپ (settings/premium) / پشتیبانی / درباره
  settings_screen.dart        [x]  — SegmentedButton theme، Slider TTS rate/daily goal
                                     DropdownButton level/language، SwitchListTile notifications
  subscription_screen.dart    [x]  — ConsumerWidget، isProProvider + customerInfoProvider (2026-06-30)
                                      not subscribed → RevenueCatUI.presentPaywallIfNeeded('VOX Unlimited')
                                      subscribed → active badge + RevenueCatUI.presentCustomerCenter()
                                      restore با SnackBar موفقیت / PurchasesError handling
                                      ⚠️ paywall + customer center: method channel — بدون context arg
  import_screen.dart          [x]  — SegmentedButton type/format، TextField paste، ImportResult
  fragen_screen.dart          [x] (در lib/features/fragen/) — ۸ FAQ با InkWell expansion
  sozialmedien_screen.dart    [x] (در lib/features/sozialmedien/) — Telegram/Instagram/YouTube
controllers/
  settings_controller.dart    [x]  — AppSettings model (themeMode،ttsRate،currentLevel،...)
                                     SettingsNotifier AsyncNotifier، settingsProvider
```

#### lib/features/fragen/ [x]
```
screens/fragen_screen.dart         [x]  — ۸ سوال متداول با ExpansionTile style
```

#### lib/features/sozialmedien/ [x]
```
screens/sozialmedien_screen.dart   [x]  — ۳ کانال با copy link
```

#### lib/features/home/ [x]
```
screens/home_screen.dart           [x]  — SliverAppBar + SliverGrid 3×4، 12 SectionData
screens/search_results_screen.dart [x]  — TextField AppBar، _Highlighted، ListTile results
controllers/search_controller.dart [x]  — GlobalSearchNotifier، جستجو در words/lessons/items
widgets/section_grid_item.dart     [x]  — gradient card + shadow
```

#### lib/features/sprechen/ [x]
```
screens/sprechen_home_screen.dart  [x]  — stub "به زودی"
```

#### lib/features/schreiben/ [x]
```
screens/schreiben_home_screen.dart [x]  — stub "به زودی"
```

#### lib/features/konnektoren/ [x]
```
screens/
  konnektoren_home_screen.dart  [x]  — DefaultTabController (4 tabs: نوع/سطح/نقش/ترتیب)
                                        actions: quiz (نیاز به extra) ، grammar → /konnektoren/grammar
                                        _GroupedListView<G> — generic grouped list
                                        Section headers: _TypeHeader، _LevelHeader، _SemanticHeader، _WordOrderHeader
                                        ⚠️ header Containers: از decoration:BoxDecoration(color:) استفاده کن — نه color: مستقیم
                                        actions: grammar → /konnektoren/grammar، quiz
  konnektoren_detail_screen.dart [x]  — جزئیات یک Konnektor
  konnektoren_grammar_screen.dart[x]  — توضیحات گرامری Konnektoren
  konnektoren_quiz_screen.dart   [x]  — آزمون Konnektoren
controllers/
  konnektoren_controller.dart    [x]  — konnektorenProvider (watchAll)، konnektorenRichProvider
models/
  konnektor.dart                 [x]  — Konnektor model
                                        enum ConnectorType { koordinierend, subordinierend, adverbial, ... }
                                        ConnectorTypeExt: labelDe، labelFa
                                        enum SemanticRole { kausal، konzessiv، temporal، ... }
                                        SemanticRoleExt: labelFa
                                        enum WordOrderEffect { v2، endstellung، ... }
                                        WordOrderEffectExt: labelFa
                                        Konnektor.colorFor(ConnectorType, context) → Color
widgets/
  connector_type_badge.dart      [x]  — pill badge برای ConnectorType (small param)
```

#### lib/features/dativ_verben/ [x]
```
screens/
  dativ_verben_home_screen.dart  [x]  — لیست Dativ+Akkusativ Verben با filter
  dativ_verben_detail_screen.dart[x]  — جزئیات + conjugation table
controllers/
  dativ_verben_controller.dart   [x]  — dativVerbenProvider، filter توسط case_type
models/
  dativ_verb.dart                [x]  — DativVerb model از JSON
```

#### lib/features/nvv/ [x]
```
screens/
  nvv_home_screen.dart           [x]  — Nomen-Verb-Verbindungen list
                                        SearchBar + FilterAccordion (Niveau، Thema، Grammatik) + FilterChipBar + ListView
                                        AppBar: grammar + quiz icon buttons (no FAB)
  nvv_detail_screen.dart         [x]  — جزئیات NVV phrase
  nvv_grammar_screen.dart        [x]  — توضیح NVV، مقایسه با فعل ساده، افعال رایج، مثال
                                        route: /nvv/grammar ← Grammatik home ارجاع می‌دهد
  nvv_quiz_screen.dart           [x]  — quiz با self-loading (Consumer در router اگر extra=null)
                                        route: /nvv/quiz ← Prüfungen home ارجاع می‌دهد
controllers/
  nvv_controller.dart            [x]  — nvvPhrasesProvider، NvvFilter، filteredNvvProvider
models/
  nvv_phrase.dart                [x]  — NvvPhrase model
```

#### lib/features/praepositionen/ [x]
> **🧩 فاز D (Deck-Vervollständigung nach Wort-prompt-Standard) ✅ 2026-07-15 — جزئیات: PLAN.md بخش D:**
> Audit ۸ دِک زنده علیه SUPER-PROMPT v3.0 (Regel 2/9/14/15؛ **بدون حذف محتوا، فقط تکمیل**):
> ۷ دِک از ابتدا پاس (Konnektoren/Dativ+Akk/Unregelm/Trennbar/Reflexiv/Verb+Präp/Modalverben)؛
> تنها نقص `praepositionen_data.json` بود: ۱۳۴ عضو از ۳۸۳ بدون جمله‌ی نمونه (Regel 15) →
> **رفع شد**: برای هر عضو ۱ جمله‌ی {de,fa,en} با الگوی Lemma+Präp+Kasus در `examples`؛
> Re-Audit = ۰ عضو بدون جمله. حالا Detail-Screen و Quiz برای همه‌ی ۳۸۳ عضو جمله دارند.
```
screens/
  praepositionen_home_screen.dart      [x]  — لیست clusters (Nomen · Verb · Adjektiv + Präp)
                                             SearchBar + FilterAccordion (Niveau، Wortart، Kasus) + FilterChipBar + ListView
                                             AppBar: grammar + quiz icon buttons (no FAB)
  praep_cluster_detail_screen.dart     [x]  — جزئیات یک cluster
  praepositionen_grammar_screen.dart   [x]  — قانون Präpositionen، جدول حرف اضافه+کازوس، نکات
                                             route: /praepositionen/grammar ← Grammatik home ارجاع می‌دهد
  praepositionen_quiz_screen.dart      [x]  — quiz با self-loading (Consumer در router اگر extra=null)
                                             route: /praepositionen/quiz ← Prüfungen home ارجاع می‌دهد
controllers/
  praepositionen_controller.dart       [x]  — praepClusterProvider، PraepFilter، filteredPraepProvider
models/
  praepositionen_cluster.dart         [x]  — PraepositionenCluster، Member model
```

---

#### lib/features/reflexiv_verben/ [x] ✅ (2026-07-03)
```
screens/
  reflexiv_list_screen.dart    [x]  — ۱۱۴ فعل انعکاسی با SearchBar + FilterAccordion (Niveau، Typ، Thema)
                                      AppBar: grammar + quiz icon buttons
                                      route: /reflexiv ← auswendiglernen_home_screen
  reflexiv_detail_screen.dart  [x]  — جزئیات فعل: ReflexivityTypeBadge، جدول principal parts،
                                      Präposition، معنی FA/EN، مثال، note، ناوبری prev/next
                                      route: /reflexiv/:verbId
  reflexiv_quiz_screen.dart    [x]  — ۴ نوع سوال: multiChoice، matchMeaning، wordOrder، cloze
                                      route: /reflexiv/quiz (extra: List<ReflexivVerb>? — Consumer loader اگر null)
  reflexiv_grammar_screen.dart [x]  — ۱۰ بخش گرامری از reflexiv_grammar.json
                                      render: explanation + table + types + examples + note
                                      route: /reflexiv/grammar
controllers/
  reflexiv_controller.dart     [x]  — reflexivVerbenProvider (FutureProvider از JSON asset)
                                      reflexivGrammarProvider، ReflexivFilter، ReflexivFilterNotifier
                                      filteredReflexivVerbenProvider
widgets/
  reflexivity_type_badge.dart  [x]  — badge رنگی: echte=سبز، unechte=آبی، dativReflexive=بنفش
models/
  reflexiv_verb.dart           [x]  — ReflexivVerb، ReflexivityType enum، ReflexivPrincipalParts
```
**Data:** assets/data/reflexiv_data.json (۱۱۴ verb) + reflexiv_grammar.json (۱۰ sections)
**Routes:** AppRoutes.reflexiv · reflexivQuiz · reflexivGrammar · reflexivDetail(id)

---

#### lib/features/trennbar_verben/ [x] ✅ (2026-07-03)
```
screens/
  trennbar_list_screen.dart    [x]  — ۱۱۰ فعل با SearchBar + FilterAccordion — route: /trennbar
  trennbar_detail_screen.dart  [x]  — جزئیات فعل — route: /trennbar/:verbId
  trennbar_quiz_screen.dart    [x]  — quiz — route: /trennbar/quiz
  trennbar_grammar_screen.dart [x]  — گرامر — route: /trennbar/grammar
controllers/ + models/               — controller، فیلتر، TrennbarVerb model
```

#### lib/features/verb_praep/ [x] ✅ (2026-07-03)
```
screens/
  verb_praep_list_screen.dart    [x]  — ۷۲ فعل با حرف اضافه ثابت — route: /verb-praep
  verb_praep_detail_screen.dart  [x]  — جزئیات — route: /verb-praep/:verbId
  verb_praep_quiz_screen.dart    [x]  — quiz — route: /verb-praep/quiz
  verb_praep_grammar_screen.dart [x]  — گرامر — route: /verb-praep/grammar
controllers/ + models/                 — controller، فیلتر، VerbPraep model
```

#### lib/features/unregelm_verben/ [x] ✅ (2026-07-03)
```
screens/
  unregelm_list_screen.dart    [x]  — ۱۷۰ فعل نامنظم — route: /unregelm-verben
  unregelm_detail_screen.dart  [x]  — جزئیات + principal parts — route: /unregelm-verben/:verbId
  unregelm_quiz_screen.dart    [x]  — quiz — route: /unregelm-verben/quiz
  unregelm_grammar_screen.dart [x]  — گرامر — route: /unregelm-verben/grammar
controllers/ + models/               — controller، فیلتر، UnregelmVerb model
```

#### lib/features/redemittel/ [x] ✅ (2026-07-04)
```
screens/
  redemittel_1010_list_screen.dart    [x]  — ۹۰۸ عبارت، ۴ FilterAccordion (CEFR/Topic/Register/Grammar)
                                             route: /redemittel-1010
  redemittel_1010_detail_screen.dart  [x]  — جزئیات عبارت: badges، مثال، ساختار، note
                                             route: /redemittel-1010/:phraseId
  redemittel_1010_quiz_screen.dart    [x]  — ۴ نوع سوال: multiChoice، matchMeaning، fillBlank، wordOrder
                                             route: /redemittel-1010/quiz
  redemittel_1010_grammar_screen.dart [x]  — ۱۱ الگوی دستوری گروه‌بندی‌شده + register overview
                                             route: /redemittel-1010/grammar
  redemittel_exam_list_screen.dart    [x]  — generic برای deck‌های امتحانی (title + provider + basePath)
                                             فعال: Goethe B2 (۶۱) — /redemittel-goethe-b2
                                             فعال: ÖSD B2 (۱۲۱) — /redemittel-oesd-b2 (2026-07-04)
                                             آینده: ÖSD C1 با همین صفحه
controllers/
  redemittel_controller.dart          [x]  — ۴ FutureProvider (goethe_b2، oesd_b2، oesd_c1، 1010)
                                             + Redemittel1010Filter + groupBySectionTitle()
models/
  redemittel_item.dart                [x]  — RedemittelItem (rich + legacy flat format)
```
**Data:** redemittel_1010.json (۹۰۸) · redemittel_goethe_b2.json (۶۱) · redemittel_oesd_b2.json (۱۲۱) · oesd_c1 (placeholder)
**Routes:** redemittel1010 (+Quiz/Grammar/Detail) · redemittelGoetheB2 · redemittelOesdB2 (+Quiz/Detail)

#### lib/features/modalverben/ [x] ✅ (2026-07-04)
```
screens/
  modalverben_list_screen.dart    [x]  — deck فلش‌کارتی: ۷ فعل + معنی (locale-aware) + مثال
                                         route: /modalverben ← Auswendiglernen deck
  modalverben_detail_screen.dart  [x]  — جدول صرف Präsens/Präteritum + همه زمان‌ها
                                         (Perfekt، Ersatzinfinitiv، Plusquam، Futur، KII)
                                         + مثال‌ها با tense badge + نکته — /modalverben/:verbId
  modalverben_grammar_screen.dart [x]  — ۹ بخش A1→C2 با VoxBadge.level + ExpansionTile
                                         route: /modalverben/grammar ← Grammatik home
controllers/
  modalverben_controller.dart     [x]  — modalVerbenProvider + modalGrammarProvider (JSON)
models/
  modal_verb.dart                 [x]  — ModalVerb + ModalVerbExample + ModalGrammarSection
```
**Data:** modalverben_data.json (۷ فعل، همه زمان‌ها) + modalverben_grammar.json (۹ بخش A1–C2)
**⚠️ زبان:** این صفحات locale-aware هستند (fa **یا** en) — الگوی مرجع برای L10n-Audit
**نکته:** صفحه گرامر آن به GrammarTopicScreen generic منتقل شد (2026-07-05)

#### lib/features/grammatik/ — Grammatik-Themen (generisch) [x] ✅ (2026-07-05)
```
models/
  grammar_topic.dart          [x]  — GrammarTopicSection + GrammarTopicMeta
                                     + **grammarTopics Register** (۵ موضوع)
                                     موضوع جدید = ۱ JSON + ۱ سطر اینجا!
screens/
  grammar_topic_screen.dart   [x]  — یک صفحه generic برای همه موضوعات مستقل:
                                     VoxBadge.level + ExpansionTile + مثال‌ها
                                     locale-aware (fa یا en) — زبان فقط از Settings
                                     route: /grammatik/thema/:topicId
```
**موضوعات فعال (همه در Grammatik home):**
| topicId | عنوان | بخش‌ها | داده |
|---|---|---|---|
| passiv | Passiv | ۹ (B1–C1) | passiv_grammar.json |
| zu-dass | zu und dass | ۱۱ (B1–C1) | zu_dass_grammar.json |
| tempusformen | Tempusformen | ۴ (B2–C1) | tempusformen_grammar.json |
| kasus | Dativ oder Akkusativ | ۹ (A1–B1) | kasus_grammar.json |
| modalverben | Modalverben | ۹ (A1–C2) | modalverben_grammar.json |

---

#### lib/core/services/ — DataSeedService [x]
```
data_seed_service.dart  [x]  — یک‌بار seed از JSON asset به SQLite (flag: vocab_seeded_v1)
                               4 متد: _seedDativAkkusativ، _seedKonnektoren، _seedNvv، _seedPraepositionen
                               ⚠️ upsert: DoUpdate(target:[german,wordType]) — نه insertOnConflictUpdate
                               import: 'package:drift/drift.dart' show Value, DoUpdate;
```

#### ⚠️ کجا کلمات ذخیره می‌شوند (وضعیت فعلی — چند‌جایی/ناهمگون)
> منبع همه: `assets/data/*.json` (read-only، bundle). Laufzeit: `vox.db` در
> `getApplicationDocumentsDirectory()`.
- **جدول `Words`**: فقط ۴ فایل seed می‌شوند (dativ, konnektoren, nvv, praepositionen)
  + کلمات کاربر (AddWord → wordDao.insert) + import
- **مستقیم از JSON** (نه در جدول Words): trennbar, reflexiv, unregelm, verb_praep,
  modalverben, **redemittel** — هر controller فایل خودش را با `rootBundle.loadString` می‌خواند
- **جدول `MemorizeItems`**: فقط با import پر می‌شود (deck Redewendungen)
- ⇒ کلمات در ۳ محل ناهمگون‌اند. (اصل پروژه: «یک جدول words، چند نما» رعایت کامل نشده.)

#### 🗄️ فاز V — Vokabular-DB (~۲۶٬۰۰۰ کلمه، ~۱۰۰ جمله/کلمه) — طراحی نهایی، پیاده‌سازی باز
> جزئیات کامل + جدول تعداد کلمات + backlog: PLAN.md → فاز V. تصمیم معماری (2026-07-08):
- **منبع خام کلمات**: `old files Lukasalmani/Wörter/` — ۷ فایل txt (~۲۶٬۲۰۰ کلمه: اسم der/die/das،
  صفت، فعل باقاعده/بی‌قاعده). فقط کلمه‌ی خام (بدون معنی/آرتیکل/سطح). `LICENSE.txt` رعایت شود.
- **Prompt تبدیل**: `old files Lukasalmani/Wort prompt` (SUPER-PROMPT v1.0) — **schema کامل صفحه‌ی
  هر کلمه** را تعریف می‌کند: ورودی یک کلمه → خروجی یک JSON دوزبانه (fa/en) با کارت پایه +
  جزئیات Wortart + **Grammatikon** (آیکون: رنگ/شکل/پرشدگی) + **Wortnetz** (خانواده ۱۵–۲۵). id=wortart_lemma.
  **جریان: هر کلمه از Prompt رد می‌شود → JSON → strip → ۱ فایل ذخیره می‌شود.**
- **Grammatikon (سیستم آیکون، اصل Puzzling)** `lib/core/grammatikon/` [Stufe ۱ کامل ✅ 2026-07-14]:
  · `grammatikon_spec.dart` [x] — همه ثابت‌های render (رنگ/هندسه/rahmen/streifen/marker) +
    helper genusFarbe/rahmenBreite. JSON فقط enum معنایی می‌دهد؛ نمایش اینجاست.
  · `perfekt_builder.dart` [x] — Perfekt از hilfsverb+partizip2 (deterministic).
  · `grammatikon_resolver.dart` [x] ✅ 2026-07-14 — **مغز**: کارت JSON (schema 2.0) + Kontext
    (kasus/genus/numerus/form/attributiv) → `GrammatikonDescriptor`. Farbe=Genus، Form=Kasus،
    Textur=Formtyp. نماد هرگز ذخیره نمی‌شود — همیشه از wortart+details محاسبه (امن برای ۲۵k کلمه).
  · `grammatikon_painter.dart` [x] ✅ 2026-07-14 — CustomPainter؛ enum → رسم فقط از Spec (V.icon).
    + widget `WortSymbol(card:, size:, kasus:, form:, genus:, numerus:, attributiv:)`.
    تست: `test/grammatikon_symbol_test.dart` (۳ تست سبز). **Flutter، نه React Native.**
  · `endung_resolver.dart` [x] ✅ 2026-07-14 (Stufe ۲) — splitEndung(wort, [explizit]) heuristic
    (لیست endungen طولانی→کوتاه، Stamm ≥ ۲؛ explizit-mismatch → بدون رنگ) + splitPraefix.
  · `wort_text.dart` [x] ✅ 2026-07-14 — `WortText`: Duden-Bildsystem، Stamm Theme-Farbe /
    Endung رنگی+bold / Präfix bold+italic؛ DE همیشه LTR. Screens هرگز style اندونگ خودشان نمی‌سازند.
  · `wort_card.dart` [x] ✅ 2026-07-14 — `WortCard(card:, onTap:, trailing:)` آیتم لیست Vokabular-DB
    (schema 2.0). زبان فقط AppL10n.isFa (بدون sprache-prop/Dual)؛ رنگ اندونگ = همان
    GrammatikonResolver.resolve(card).color (یک منبع)؛ VoxBadge.level + کلید `leitner_fach`.
    تست: `test/wort_text_card_test.dart` (۸ تست، FA+EN). + helper `Formatters.digits` (locale-aware).

- **Vokabular-Karten (Feature, فاز V Stufen ۳+۴)** `lib/features/vokabular/` [✅ 2026-07-14]:
  **⚠️ تغییر 2026-07-14 (تصمیم کاربر): «Vokabular-Archiv» جدا حذف شد** — لیست کارت‌ها در
  **«Alle Wörter»** (`wortschatz_list_screen.dart`) merge شد: هر دو منبع (DB قدیمی + کارت‌های
  assets/vocab) در یک لیست الفبایی (Artikel در سورت نادیده)؛ کارت‌ها = WortCard + WortActions
  kompakt → tap → `/vokabular/wort/:id`. فیلترهای موجود (Niveau/Wortart) روی هر دو منبع
  (نگاشت WordType→wortart در `_typZuWortart`)؛ query param `suche` برای پیش‌پرشدن جستجو.
  Screens حذف‌شده: `vokabular_home_screen.dart`، `vokabular_liste_screen.dart`؛ Routes
  `/vokabular` و `/vokabular/liste` حذف؛ فقط `/vokabular/wort/:id` مانده. شمارنده‌ی
  Wortschatz-Home = DB + کارت‌ها. ⏳ باز: نمایش لیست Kategorien شخصی (فعلاً فقط افزودن از
  WortActions ممکن است، صفحه‌ی نمایش با حذف home از بین رفت)؛ فیلتر Themen.
  **اصل: Wortschatz ≠ Leitner** — کارت‌ها read-only (assets)، user state جدا؛ لایتنر فقط با flag.
  · `controllers/vokabular_controller.dart` [x] — کارت‌ها از `assets/vocab/<wortart>/<id>.json`
    (AssetManifest؛ پل: V.3 فقط این provider را با vocab.db عوض می‌کند) + `vokabId()` (قانون ۵)
    + `vokabKartePasst()` (جستجوی DE/FA/EN).
  · `controllers/vokabular_user_state.dart` [x] — Leitner-Map (box/nextReviewDate) + Kategorien
    (فقط Wort-ID) + **Notizen** (`VokabNotiz {text, farben: WortIndex→Farbname}`، متن خالی=حذف)؛
    SharedPreferences (کلیدها vokab_user_*_v1)؛ `_ready`-Gate؛ V.3 → drift.
  · `widgets/wort_notiz.dart` [x] ✅ 2026-07-14 — **Freitext-Notiz روی Wort-Seite** (user state):
    `WortNotizSektion` نمایش RichText رنگی + BottomSheet-Editor (کلمه لمس/انتخاب → VoxIconButton
    دایره‌ی رنگی، ۶ رنگ `notizFarben` + Standard)؛ live-رنگ با `_NotizController.buildTextSpan`؛
    helper های خالص `notizSpans`/`notizWortIndizes` (تست‌شده).
  · `widgets/wort_actions.dart` [x] — 🔊 AudioPlayButton (موجود) + Leitner-Toggle + Kategorien-
    BottomSheet؛ فقط Vox-کامپوننت‌ها؛ snackbar کلیدهای added_to_leitner/removed_from_leitner.
  · `widgets/wortseite_bausteine.dart` [x] — Sektion/Zeile/BeispielBlock/Tabelle + `vokabUeb()`
    (یک زبان، فاز L). `widgets/details_renderer.dart` [x] — ۱۰ Wortart؛ Perfekt از PerfektBuilder.
  · `screens/wort_seite_screen.dart` [x] (Wortnetz کلیک‌پذیر، id مشتق از vokabId، push زنجیره‌ای؛
    دکمه‌ی «جستجو در همه واژه‌ها» → `/wortschatz/list?suche=<wort>`). ترتیب سکشن‌ها:
    Synonyme → **«Gegenteil»** (فیلد antonyme؛ فقط واژه+معنی، یک زبان) → Komposita →
    Wortbildung → Wortnetz → **Meine Notiz** (WortNotizSektion).
  · Route `/vokabular/wort/:id` (تنها route این feature)؛ ورودی از لیست «Alle Wörter».
  · Assets: pubspec ۱۰ پوشه `assets/vocab/<wortart>/`؛ Demo `verb_lernen.json` (Platzhalter).
  · تست: `test/vokabular_test.dart` (۸ تست ✅ — id/جستجو/store/persistenz/asset-loader/renderer).
  · **[x] Stufe ۵ (Import) ✅ 2026-07-14**: schema **v3.0** (Array ۱–۱۰، etymologie **دوزبانه
    `{fa,en}`** از 2026-07-14 — String قدیمی فقط Warnung، نمایش fallback دارد؛ `anmerkung` فقط
    آلمانی، بدون گلاس FA/EN، Wortnetz ۵×`id_ref` تخت، دقیقاً ۲ Beispiel؛ **Regel 15** از
    2026-07-14: برای Verb/Adjektiv/Nomen با حرف اضافه‌ی ثابت، `rektion`/`mit_praeposition`
    اجباری — Präposition + Kasus دقیق + جمله‌ی نمونه، هرگز null/خالی). Pipeline:
    · `data/vokab_schema.dart` [x] — reines Dart (بدون Flutter-Import!)، یک منبع اپ+تول:
      vokabId + vokabParseBatch (Fences-tolerant) + vokabPruefeKarte (فاتال→رد؛
      id/box/perfekt/genitiv/id_ref → normalisiert+Warnung). vokabId از controller به اینجا
      منتقل شد (controller فقط re-export).
    · `tool/vokabular_import.dart` [x] — CLI: پیش‌فرض `import_inbox/*.json`؛ `--dry-run`/
      `--update`/`--out`؛ Duplikat-Schutz، idempotent، Fehlerbericht، exit 1 روی خطا.
    · `import_inbox/README.md` [x] — دستورالعمل جریان کار برای کاربر.
    · Wort-Seite v3.0 [x]: Wortnetz تخت + id_ref (fallback مشتق/gruppen-flatten) + Sektion
      Wortbildung (etymologie). Demo `verb_lernen.json` → v3.0.
    · تست `test/vokab_schema_test.dart` (۹) + E2E اجرا شد؛ کل suite = ۲۹ ✅.
  · **[▶️] Befüllung läuft (شروع 2026-07-14)** — منبع: `old files Lukasalmani/Wörter/*.txt`
    (۸ فایل خام؛ ترتیب فعلی: **Adjektive.txt** اول). جریان هر کلمه (جزئیات: PLAN.md بخش V
    «جریان ورود کلمات»): کلمه‌ی بعدی = اولین خط بدون `✓ ` در txt → SUPER-PROMPT v3.0
    (`old files Lukasalmani/Wort prompt`) → `import_inbox/batch_<datum>_<gruppe>_<nnn>.json` →
    `dart run tool/vokabular_import.dart` → `assets/vocab/<wortart>/<id>.json` → خط کلمه در txt
    پیشوند `✓ ` می‌گیرد. **هر کلمه = ۱ فایل مستقل = صفحه‌ی خودش** → عیناً قابل آپلود به cloud
    برای Android+iOS. پیشرفت فقط در txt (مارک `✓ `) ثبت می‌شود، نه اینجا (تصمیم کاربر 2026-07-14).
  **⚠️ JSON ذخیره‌شده لاغرتر از خروجی Prompt**: `render_tokens` (→ Spec) و `konjugation.perfekt`
  (→ PerfektBuilder) هنگام ذخیره strip می‌شوند. فقط enum معنایی می‌ماند.
- **منبع ذخیره (Git، افزودنی)**: `assets/vocab/<wortType>/<id>.json` — ۱ فایل برای هر کلمه،
  خودکفا (متادیتا + جمله‌ها). فیلد `tags` (level:/kasus:/type:/thema:) برای سورت. بدون بازنویسی بقیه.
- **Laufzeit (سریع)**: build-script → یک **prebuilt SQLite `assets/vocab.db`**:
  `words` (~26k، indexed) + `word_tags` (m:n) + `sentences` (~2.6M، **lazy**).
  first-launch **یک‌بار کپی** (نه seed). **لیست فقط words (سریع/paginated)؛ جمله‌ها lazy.
  چند سورت هم‌زمان = چند index روی همان یک جدول. سورت = query نه فایل.**
- **هم‌زیستی**: فایل‌های feature قدیمی بدون تغییر؛ ستون `source` در words → ترکیب بعدی با filter.
- **توزیع (تصمیم مشترک کاربر+Claude، بعداً)**: **ZIP** / **Apple CloudKit** / db قابل‌دانلود /
  bundle با جمله‌های کمتر — به‌خاطر سقف ~۶۰۰ MB > حد store. ساختار فایل کلمه در همه حالات یکسان.
- ⏳ **تنها نکته باز schema**: تصمیم ~۱۰۰ جمله (Prompt الان حداقل ۲) + قرارداد نهایی tag ها.

---

## BUGS FIXED

### [2026-06-30] Phase 8 (جزئی): RevenueCat SDK کامل + Native Splash
- `purchases_ui_flutter 8.11.0` اضافه شد
- `subscription_service.dart` ساخته شد — Riverpod providers (stream-based customer info)
- `subscription_screen.dart` بازنویسی شد — paywall + customer center + entitlement check
- `dart run flutter_native_splash:create` اجرا شد ✅
- ⚠️ `app_icon.png` هنوز نیاز است → بعد از آن `dart run flutter_launcher_icons`

### [2026-06-30] Phase 7: Bilingual Audit — 100+ localization keys اضافه شدند
- `app_l10n.dart`: همه کلیدهای UI استاتیک در FA + EN (add_to_leitner، remove_leitner_*، tap_to_reveal، box_distribution، category_empty، ...)
- ~45 فایل: import AppL10n اضافه، همه hardcoded Persian UI strings → AppL10n.t(context, key)
- Dialog contexts: در dialogs از ctx (dialog's BuildContext) نه context استفاده شد
- const: جاهایی که AppL10n.t() استفاده شد، const از parent حذف، به children بازگردانده شد
- ⚠️ Dynamic strings ($variable) intentionally left — نیاز به ICU plural system

### [2026-06-29] B-4: Grammatik home لینک اشتباه + Prüfungen topic quiz
- **مشکل Grammatik**: `_GrammarSection` tiles به list screens می‌رفتند
- **رفع**: لینک‌ها به grammar screens تغییر کردند + NVV اضافه شد
- **مشکل Prüfungen**: هیچ بخشی برای quiz‌های موضوعی وجود نداشت
- **رفع**: بخش "تمرین‌های موضوعی" با `_TopicQuizTile` اضافه شد
- **درس**: "One Screen Two Locations" — صفحه quiz یک بار ساخته شد، دو بار ارجاع داده شد

### [2026-06-29] B-1: Container color + decoration conflict
- فایل: `konnektoren_home_screen.dart`
- مشکل: `Container(color: x, decoration: BoxDecoration(...))` → Flutter assertion خطا
- رفع: همه header Containers از `decoration: BoxDecoration(color: x)` استفاده می‌کنند
- درس: **هرگز** `color:` و `decoration:` روی یک Container با هم نگذار

### [2026-06-29] B-2: SQLite UNIQUE constraint 2067
- فایل: `word_dao.dart` + `data_seed_service.dart`
- مشکل: `insertOnConflictUpdate` فقط روی PK (`id`) conflict resolve می‌کند، نه روی unique key `(german, wordType)`
- رفع: `DoUpdate((old) => companion, target: [_db.words.german, _db.words.wordType])`
- درس: وقتی table یک composite unique key دارد، باید `target:` را صریح مشخص کرد

---

## BACKLOG / UPCOMING CHANGES

### B-3 ✅ (تأیید Audit 2026-09-15): Wortschatz — حرف اضافه در display
- در کد رفع شده: `stripPreposition(german)` در `lib/features/wortschatz/widgets/word_list_item.dart`
  (مجموعه‌ی ۲۱ حرف اضافه؛ آخرین توکن اگر حرف اضافه بود حذف می‌شود)
- لیست: «das Engagement» · detail view: کامل با حرف اضافه
- ⚠️ تا 2026-09-15 اشتباهاً «فوری/باز» ثبت شده بود

### R-1 [ضروری]: Auswendiglernen Präpositionen — full form در لیست
- **درست**: لیست Auswendiglernen از Präpositionen → فرمت: "lemma · حرف‌اضافه"
- **مثال**: "abhängen · abhängig · die Abhängigkeit von"
- **تفاوت با B-3**: در Wortschatz حرف اضافه حذف می‌شود، در Auswendiglernen نشان داده می‌شود

### R-2 [ضروری]: Auswendiglernen detail view کامل
- کلیک روی هر آیتم → معنا (FA+EN)، مثال‌ها، TTS، Leitner، دسته‌بندی، favorit

### R-3 [مهم]: Auswendiglernen — ساختار جدید
- **حذف**: section headers (Verben، Satzbau، Wortschatz، Redemittel)
- **جایگزین**: یک لیست ساده از deck‌ها
- **ساختار نهایی**:
  ```
  • Satzkonnektoren
  • Dativ und Akkusativ Verben
  • Nomen-Verb-Verbindungen (NVV)
  • Nomen · Verb · Adjektiv + Präpositionen
  • Unregelmäßige Verben
  • ... (بقیه)
  ── PRÜFUNGEN ──
  • Goethe B2 Redemittel
  • ÖSD B2 Redemittel
  • ÖSD C1 Redemittel
  • 1010 Redemittel
  ```

### R-4 [مهم]: Filter UI یکپارچه در همه صفحات
- **ساختار**: SearchBar → (Prüfung + Grammatik دکمه‌ها) → accordion کشوها
- **accordion**: Niveau، Art، Thema — هر کدام قابل بسته/باز شدن
- **multi-select**: ترکیب A1+B2+Nullposition همزمان ممکن
- **chip bar**: نمایش فیلترهای فعال + دکمه "پاک کردن"
- **فایل‌های جدید**: `core/widgets/filter_accordion.dart`، `core/widgets/filter_chip_bar.dart`
- **⚠️ اصل**: محتوای گزینه‌ها از Screen داده می‌شود، ظاهر accordion در `filter_accordion.dart` است
- جدول گزینه‌های هر صفحه → ببین **اصل ۲: Content-Aware Filters** در بالای این فایل

### R-5 [مهم]: Design System — فایل‌های کامپوننت
- `core/widgets/vox_button.dart` — primary، secondary، small، icon، header variants
- `core/widgets/vox_badge.dart` — level، type، article badge variants
- `core/theme/app_decorations.dart` — card، chip، headerStrip BoxDecoration helpers
- **⚠️ اصل**: تمام کد ظاهر دکمه‌ها/badge‌ها باید از Screen‌ها به این فایل‌ها منتقل شود
- Screen‌ها فقط `VoxButton.primary(...)` صدا می‌زنند — style نمی‌نویسند

### R-6 ✅ (2026-06-30): Bilingual Audit — کامل شد
- همه ~45 فایل بررسی و 100+ کلید در app_l10n.dart (FA+EN) اضافه شدند
- تمام strings استاتیک UI → AppL10n.t(context, key)
- Dynamic strings (با $variable) intentionally left — نیاز به ICU system جداگانه

### R-7 [متوسط]: Content/Data جداسازی ✅ (2026-06-29)
- فایل‌های موجود: konnektoren_data.json، dativ_akkusativ_data.json، nvv_data.json، praepositionen_data.json، reflexiv_data.json، reflexiv_grammar.json ✅
- ساخته شدند: redemittel_goethe_b2.json (**۶۱ عبارت** 2026-07-04)، redemittel_oesd_b2.json (**۱۲۱ عبارت در ۲۰ بخش** 2026-07-04)، redemittel_oesd_c1.json (۶ placeholder)، redemittel_1010.json (**۹۰۸ عبارت** 2026-07-04) ✅
- `redemittel_exam_list_screen.dart` — صفحه generic برای deck‌های امتحانی (Goethe B2 + ÖSD B2 فعال، ÖSD C1 بعداً همین صفحه)
  - routes: `/redemittel-goethe-b2` و `/redemittel-oesd-b2` (+ `/quiz` + `/:phraseId`)
  - quiz و detail از صفحات 1010 بازاستفاده می‌شوند
  - ÖSD B2 بخش‌ها: بحث (۶) · Beschwerdebrief (۴) · Meinungstext (۴) · Mündlich 1–3 (۶)
- `core/content/content_registry.dart` — ثبت ۸ منبع محتوا با isReady flag ✅
- `features/redemittel/models/redemittel_item.dart` — model کامل ✅
- `features/redemittel/controllers/redemittel_controller.dart` — ۴ FutureProvider ✅
- محتوای کامل (100+ عبارت per exam) → content authoring جداگانه

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

## DATABASE TABLES (drift — schema v2 — تغییر نده)
```
words            — جدول اصلی (unique: {german, wordType})
books            — کتاب‌های درسی (unique: name)
word_books       — many-to-many: word ↔ book (PK: {wordId, bookId})
user_categories  — دسته‌های شخصی کاربر
category_words   — many-to-many: category ↔ word (PK: {categoryId, wordId})
leitner_cards    — کارت‌های لایتنر (wordId unique، box 1-5، nextReview)
grammar_lessons  — دروس گرامر (title، level، content، sortOrder)
memorize_items   — حفظیات (phrase، meaning=FA، meaningEn=nullable [L3-E]، examplesJson)
reading_texts    — متون Lesen (title، level، content، audioPath)
audio_items      — فایل‌های Hören (title، level، audioPath، transcript JSON)
habits           — عادت‌ها (name، daysJson، shift، streakCount، isActive)
habit_sessions   — جلسات (habitId، completedAt، durationMinutes)
```
