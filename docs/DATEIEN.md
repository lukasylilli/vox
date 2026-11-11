# DATEIEN — شرح فایل به فایل (ROOT، lib/، Design System، Architecture Hub)

> شرح دستی هر فایل و هر بخش کد. ⚠️ ممیزی 2026-11-10: ۶۸ فایل موجود این‌جا نیستند و ۲۱ نام این‌جا دیگر وجود ندارند — مرجع نهایی همیشه خود ریپو است.
> 🗑️ **2026-11-11 حذف شدند (هیچ فایلی صدایشان نمی‌زد؛ در تاریخچه‌ی Git می‌مانند):** `core/constants/vox_icons.dart` · `vox_typography.dart` · `core/content/content_registry.dart` · `core/theme/app_decorations.dart` · `vox_animations.dart` · `core/utils/debouncer.dart` · `extensions.dart` · `validators.dart` · `core/widgets/grammar_link_button.dart` · `placeholder_section_screen.dart` · `vox_app_bar.dart` · `vox_bottom_bar.dart` · `vox_card.dart` · `vox_divider.dart` · `vox_list_tile.dart` · `vox_section_header.dart` · `vox_text_field.dart`. شرح آن‌ها در پایین دیگر معتبر نیست.
> منبع: `PROJECT_MAP.md` تا کامیت `b1ee0346` (2026-11-10، بسته‌ی ۳ ممیزی) — متن عیناً منتقل شده، هیچ خطی حذف نشده.

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
⚠️ S.3 Schritt 2 (2026-09-15): ruft `AuthService().initialize()` in try/catch — ohne Secrets nur `false`, nie ein Startfehler
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
                                 (G7a 2026-09-16: همه‌ی factoryها پارامتر اختیاری `key` دارند — برای تست)
                                 اصل Puzzling: هیچ screen ای کد دکمه ندارد — فقط reference
                                 همه variant ها روی System-Widgets متریال (آپدیت خودکار با فریمورک):
                                 VoxButton: primary/tonal/secondary/text/success/destructive/
                                   destructiveOutlined/header/small + size(S/M/L) + expand + loading
                                 VoxIconButton: plain/filled/tonal/outlined + isSelected/selectedIcon
                                 VoxFab + VoxFab.extended
                                 VoxOptionButton: گزینه آزمون (idle/selected/correct/wrong) — همه ۱۱ quiz [B.4 ✅]
                                   + `istDeutsch` (2026-09-18): label آلمانی ⇒ DeutschText (LTR)؛
                                     پیش‌فرض false، پس گزینه‌های ترجمه‌ای رفتارشان عوض نشد
                                 منبع طراحی: old files Lukasalmani/1/Button (نسخه System-APIs)
                                 🛡 Wächter: test/puzzling_buttons_test.dart — roher Button in
                                   lib/features ⇒ CI rot (B.5, 2026-09-15)
  vox_badge.dart          [x]  — VoxBadge.level(level) — colored، wordType، colored variants
  deutsch_text.dart       [x]  — ⭐ DeutschText (2026-09-18، باگ RTL Lukas): متن **آلمانی** با
                                 textDirection.ltr + textAlign.left **ثابت**، نه ارث‌بری از Directionality.
                                 چرا: با locale=fa کل اپ RTL می‌شود و یک Text ساده باعث می‌شد جمله‌ی آلمانی
                                 به لبه‌ی راست بچسبد و نقطه‌ی پایان در سمت چپ (ظاهراً اولِ جمله) بیفتد.
                                 قاعده: هر محتوای آلمانی ⇒ DeutschText؛ ترجمه‌ی fa/en ⇒ Text عادی.
                                 🛡 test/deutsch_text_test.dart. مشابه قبلی: wort_text.dart (از قبل ltr داشت)
                                 اعمال‌شده در: redemittel_exam_list · redemittel_1010_detail/list/quiz/grammar
                                 · grammatik_lektion_screen (عنوان، **پاراگراف توضیح b.bodyDe**، تیتر بلوک،
                                   جمله‌ی نمونه، و جدول‌ها: سرستون + rowLabel + خانه‌ها) · word_list_item
                                   (uebung_karte از قبل درست بود)
                                 ⚠️ درس: دور اول b.bodyDe جا افتاد و Lukas دوباره گزارش داد ⇒ در هر فایل
                                   باید **همه‌ی** Text(ها شمرده شوند، نه فقط آن‌هایی که به چشم می‌آیند.
                                 ✅ **کامل شد (2026-09-18):** VoxOptionButton پارامتر `istDeutsch` گرفت
                                   (پیش‌فرض false ⇒ ترجمه‌ها دست‌نخورده)، ۱۰ صفحه‌ی کوییز وصل شدند
                                   (`istDeutsch: q.type != _QuizType.matchMeaning`؛ nvv عمداً نه، چون
                                   گزینه‌هایش ترجمه‌اند)، و ۱۴ جای باقی‌مانده در features جارو شد.
                                 🛡🛡 **test/deutscher_text_waechter_test.dart** — فیلد آلمانی داخل
                                   Text( خالی در lib/features ⇒ CI قرمز (الگوی B.5، دو استثنای مستند)
  klick_wort_text.dart    [x]  — ⭐ KlickWortText (L.5f، 2026-09-20): مثل DeutschText (LTR/left ثابت) ولی **هر کلمه
                                  قابل‌کلیک** ⇒ showWortPopup. پارامترها: markiert (زیرخط/رنگ؛ فقط Leser)،
                                  auswaehlbar (SelectableText.rich؛ Leser)، style، maxLines، overflow.
                                  StatefulWidget: TapGestureRecognizerها فقط با تغییر متن ساخته و در dispose آزاد می‌شوند.
                                  ⚠️ فقط در صفحه‌های Detail/Leser؛ نه در ردیف‌های لیستِ خودکلیک‌پذیر.
                                  اعمال‌شده در: text_reader_screen · grammatik_lektion_screen (b.bodyDe، e.german) ·
                                  redemittel_1010_detail (مثال + متن آلمانی) · konnektor_detail (exampleDe) ·
                                  unregelm_detail (exampleDe) · wortseite_bausteine BeispielBlock.
                                  (Karaoke: GestureDetector مستقیم روی هر کلمه → showWortPopup)
  wort_popup.dart         [x]  — ⭐ showWortPopup(context, rohWort) (L.5f): مرحله ۱ = BottomSheet؛ مرحله ۲ = کلیک روی ردیف ⇒
                                  push به صفحه‌ی کامل (Archiv: `/vokabular/wort/:id` = WortSeiteScreen؛ DB قدیمی:
                                  `/wortschatz/word/:id`). ظاهر = WortCard + WortActions(kompakt) / WordListItem +
                                  Audio + LeitnerAddButton — بدون طراحی جدا. بدون نتیجه ⇒ «not_in_dictionary» +
                                  دکمه‌ی `search_in_vokabular` ⇒ `/wortschatz/list?suche=<کلمه>`. حداکثر ۸ نتیجه.
                                  router قبل از باز شدن sheet گرفته می‌شود (context بعد از بستن معتبر نیست).
  ── core/wort/ (L.5f — reines Dart + Provider، بدون UI) ──
  wort_form.dart          [x]  — wortBereinigt · wortSchluessel (Groß/Klein؛ artikel فقط در چندکلمه‌ای؛ حرف اضافه‌ی آخر؛
                                  **بدون تشخیص صورت صرف‌شده — حدس نیست**) · stripPreposition (از word_list_item منتقل شد؛ آنجا re-export)
  klick_wort.dart         [x]  — zerlegeText(text) → KlickToken(text, istWort)؛ join(tokens)==text
  klick_wort_provider.dart[x]  — vokabIndexNachSchluesselProvider · klickWortTrefferProvider(schluessel):
                                  اول آرشیو (همه‌ی هم‌شکل‌ها)، فقط در نبودش DB قدیمی (WordDao.search + فیلتر هم‌کلید)
                                  · KlickWortTreffer(archiv|datenbank).pfad · klickWortMaxTreffer=8
                                  🛡 test/klick_wort_test.dart (tokenizer، کلید، provider، KlickWortText، popup بدون نتیجه)
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
  feature_flags.dart      [x]  LIVE — ۲۳ فلگ — حالت‌ها live/comingSoon/**hidden** (hidden از 2026-09-19 واقعاً اعمال می‌شود: isHidden/isVisible/resolve/keys) — استفاده: auswendiglernen decks + home-Kacheln Sprechen/Schreiben +
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
app_router + app_routes · app_database (db) · ~~subscription_service (auth/RevenueCat)~~ [⛔ entfernt 2026-09-13] ·
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
subscription_service.dart [⛔] — ENTFERNT 2026-09-13: Datei existiert nicht mehr (Web-App ist kostenlos). Früher: RevenueCat Riverpod integration (2026-06-30)
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
                       activeLang پیش‌فرض 'en' (L.3a — قبل از اولین build)
geraete_sprache.dart [x] — L.3a (2026-09-16) **تنها منبع زبان شروع**: GeraeteSprache.aus(locales)
                       (زبان نامعتبر مرورگر پیش از Engine در web/locale_guard.js تمیز می‌شود — L.3b)
                       → 'fa' فقط اگر اولین زبانِ پشتیبانی‌شده‌ی دستگاه fa/prs باشد، وگرنه 'en'
                       (rueckfall). GeraeteSprache.aktuell = PlatformDispatcher.locales.
                       استفاده: settings_controller._load (بدون ui_language) + app.dart (حین بارگذاری).
                       نتیجه ذخیره نمی‌شود — تا انتخاب کاربر، دنبال دستگاه. تست: geraete_sprache_test.dart
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
screens/home_screen.dart       [x]  — SliverAppBar + SliverGrid 3×4، 12 SectionData (Sprechen/Schreiben شرطی با `FeatureFlags.isVisible`، 2026-09-19)
widgets/section_grid_item.dart [x]  — gradient card + shadow، color.withValues(alpha:...)
```

#### lib/features/wortschatz/ [x]
```
screens/
  wortschatz_home_screen.dart  [x]  — stats banner + _MenuItem (Alle Wörter، Bücher، Leitner، Kategorien) + Add FAB
  wortschatz_list_screen.dart  [x]  — ⭐ اصل اول (دور ۶۳): **هر کارت ردیف خودش** (هیچ کارتی پنهان نمی‌شود)؛ Wortart/lemma از `data/altwort_karte.dart`. — «Alle Wörter» = لیست ادغامی دو منبع: allWordsProvider (DB → WordListItem)
                                      + vokabularProvider (assets/vocab → WortCard+WortActions → /vokabular/wort/:id)؛
                                      سورت الفبایی مشترک (بدون Artikel)؛ SearchBar + FilterAccordion (Niveau، Wortart،
                                      نگاشت _typZuWortart) + FilterChipBar؛ query param `suche`؛ route: /wortschatz/list
  book_list_screen.dart        [x]  — allBooksProvider + FAB + _addBook dialog — 🃏 فاز X: با Deckها یکی می‌شود (تصمیم ۱۴)
  book_words_screen.dart       [x]  — wordsByBookProvider(bookId) + ListView
  level_words_screen.dart      [x]  — wordsByLevelProvider + _LevelPickerBar (legacy، هنوز در router)
  type_words_screen.dart       [x]  — wordsByTypeProvider + _TypePickerBar (legacy، هنوز در router)
  word_detail_screen.dart      [x]  — ⭐ کلمه‌ی قبلی اپ با کارت پرامپتی ⇒ زیر بخش‌های قبلی کارت را **اضافه** نشان می‌دهد (`_KartenErweiterung` ← `WortKarteKopf`/`WortKarteAbschnitte`)؛ کارت صفحه‌ی خودش را هم دارد (اصل اول)؛ هیچ بخشی حذف نشد. — همه فیلدها conditional + BottomBar: (2026-09-22: دکمه‌ی «favorit» جدا وجود ندارد — دسته‌بندی/فهرست جایش است)
                                      LeitnerAddButton / دسته‌بندی / آزمون(placeholder)
  add_word_screen.dart         [x]  — TextField → ParserRegistry.parse → _ParsePreview → save — 🃏 فاز X.7: جای خود را به «درخواست کلمه» (تلگرام) می‌دهد؛ کاربر دیگر کلمه وارد نمی‌کند
controllers/
  altwort_karte_provider.dart  [x]  — altwortZuordnungProvider (فقط برای نمایش اضافه در word_detail_screen)
  word_controller.dart         [x]  — databaseProvider، wordDaoProvider
                                      allWordsProvider، wordsByLevel/Type/Book
                                      searchQueryProvider، searchResultsProvider
                                      wordByIdProvider
                                      ext WordToModel on Word → toModel()
                                      ext ModelToCompanion on WordModel → toCompanion()
                                      ⚠️ import 'package:drift/drift.dart' show Value;
data/
  altwort_karte.dart           [x]  — تنها منبع جفت «کلمه‌ی قدیمی اپ ↔ کارت» (بدون حدس) + altwortTypZuWortart + altwortLemma (فیلتر/مرتب‌سازی لیست)؛ اصل اول: هرگز هدایت/پنهان
widgets/
  word_list_item.dart          [x]  — card: ArticleColorIndicator + ArticleBadge + _LevelChip
  article_color_indicator.dart [x]  — نوار رنگی 4px سمت چپ (بر اساس article)
  conjugation_table.dart       [x]  — جدول 4 ردیف: Infinitiv/Präsens/Präteritum/Partizip II
```

#### lib/features/leitner/ [x]
> 🃏 **فاز X (PLAN، 2026-11-03, ⛔ طرح):** این بخش با deckهای درختی و انواع تمرین بازسازی می‌شود — قبل از هر تغییر بخش «🃏 فاز X» در PLAN را بخوان.
```
screens/
  leitner_home_screen.dart   [x]  — _DueBanner (gradient) + BoxProgressWidget + FAB مرور
                                    AppBar: آیکون آمار → leitnerStats
  leitner_review_screen.dart [x]  — ConsumerStatefulWidget: _loadCards در initState
                                    B-13: کارت‌های موعدرسیده از leitnerEintraegeProvider (هر دو منبع)؛
                                    AppWort ⇒ FlashCardWidget/LeitnerDao · Archiv ⇒ ArchivFlashCard/archivLeitnerBewerten
                                    FlashCardWidget + _AnswerButtons (درست/نمی‌دونستم)
                                    _SummaryScreen در پایان (score، pct، _StatCard)
  leitner_stats_screen.dart  [x]  — _StatChip × 3 + BoxProgressWidget + LinearProgressIndicator
                                    جدول upcoming reviews (group by days)
controllers/
  leitner_controller.dart    [x]  — B-13 (2026-09-23): LeitnerEintrag (AppWortEintrag | ArchivEintrag)،
                                    allLeitnerCardsProvider + archivLeitnerProvider ⇒ leitnerEintraegeProvider
                                    = **تنها فهرست** لایتنر؛ boxCountsProvider/dueCountProvider از آن مشتق و
                                    خودکار تازه می‌شوند. leitnerDaoProvider، isInLeitnerProvider، boxLabels، boxIntervals
                                    (dueCardsProvider/leitnerByBoxProvider بی‌استفاده بودند، حذف شدند)
widgets/
  wende_karte.dart           [x]  — B-13: چرخش سه‌بعدی مشترک همه‌ی کارت‌های مرور (Matrix4.rotateY، 400ms)
  archiv_flash_card.dart     [x]  — B-13: کارت مرور کارت آرشیو — جلو: WortSymbol + WortZeile + تلفظ؛
                                    پشت: ترجمه (فقط زبان تنظیمات) + دکمه‌ی صفحه‌ی کامل کلمه. فقط Index لازم دارد
  flash_card_widget.dart     [x]  — کلمه‌های قدیمی اپ؛ چرخش از wende_karte.dart
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
  beispiel_uebungen.dart       [x]  — G7c: BeispielUebungen.erzeuge(lek, Random) — یک تمرین برای هر جمله‌ی مثال،
                                      نوع تصادفی (bedeutung/satzWahl/richtigFalsch/matching/wordOrder با Vorgabe)؛
                                      anzahl(lek) مستقل از تصادف؛ istEinfach(satz) برای چیدن کلمه
  grammatik_niveautest.dart    [x]  — G7b: تنظیمات (از assets/data/grammatik_niveautest.json، کپی بی‌تغییر منبع)
                                      + vorrat(niveau, zufall:) فقط testTauglich (+ تمرین‌های مثال، G7c) + ziehe
  grammatik_uebung.dart        [x]  — G7a: GrammatikUebung (۵ نوع منبع) + **تنها جای بررسی جواب**
                                      (pruefeWahl/Reihenfolge/Umformung/Zuordnung). ausJson ⇒ null برای ناقص.
                                      G7c: +۳ نوع (bedeutung, satzWahl, richtigFalsch)، ausBeispiel, vorgabe,
                                      optionenFa/En, beispielDe/Fa/En, testTauglich
                                      ⚠️ id در منبع یکتا نیست (ex-komp-1…4 دو بار) ⇒ کلید = schluessel (درس/id).
                                      fillBlank.alternatives = گزینه‌ی غلط · wordOrder: تکه‌ی اضافه مجاز، بدون حروف بزرگ
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
                                      (فهرست grammatikContentFiles، ۱۷ فایل). **۸۴ درس live** (G3–G6، 2026-09-16).
                                      ⚠️ GrammatikTable.fromJson دو شکل «columns» منبع را یکی می‌کند؛ istStimmig.
                                      تست: test/grammatik_lektionen_test.dart (رسم هر ۸۴ درس در EN/FA).
  grammatik_niveautest_screen.dart [x] — G7b (2026-09-16): route /grammatik/quiz-niveau/:level — معرفی →
                                      UebungsSitzung(bestehensQuote, onNochmal). + NiveauTestKarte (بالای
                                      grammatik_katalog_screen در نمای niveau). بدون transform؛ نتیجه ذخیره نمی‌شود.
  grammatik_uebung_screen.dart [x]  — G7a (2026-09-16): route /grammatik/lektion/:slug/uebung — UebungsSitzung
                                      با تمرین‌های همان درس (grammatikLektionUebungenProvider) + G7c: ۶ تمرین
                                      ساخته‌شده، مخلوط (stelleDurchgangZusammen)، «دوباره» = نوبت تازه. دکمه‌ی ورود
                                      «تمرین این درس (n)» بالا و پایین grammatik_lektion_screen (_UebungStart).
  grammatik_katalog_screen.dart[x]  — G1: صفحه پارامتریک /grammatik/katalog/:view/:key
                                      niveau/satzglied → گروه‌بندی بر اساس Thema · thema → flat
                                      + کارت «Lektionen & Übungen» → /grammatik/:level (سیستم DB قدیم)
  level_lessons_screen.dart    [x]  — lessonsByLevelProvider، ListTile با sortOrder circle
  lesson_detail_screen.dart    [x]  — lessonByIdProvider، SelectableText body
                                      bottom bar: تمرین→exercise، آزمون→quiz (اگر exercises.isNotEmpty)
  grammar_exercise_screen.dart [x]  — ListView.separated همه تمرین‌ها، number circle + hint
  grammar_quiz_screen.dart     [x]  — یک تمرین در هر بار، _OptionButton feedback، QuizResultWidget
widgets/ (G7a)
  uebung_karte.dart            [x]  — UebungKarte: یک تمرین، ۵ نوع (VoxOptionButton / ActionChip / TextField /
                                      ChoiceChip)، بازخورد + توضیح؛ آلمانی همیشه LTR؛ onGeprueft دقیقاً یک بار
  uebungs_sitzung.dart         [x]  — UebungsSitzung: پیشرفت، «بعدی»، نتیجه + «دوباره»/«برگشت»؛
                               **T.1:** `onFertig(richtig, gesamt)` — یک بار در هر دور؛ خود جلسه چیزی ذخیره نمی‌کند.
                                      bestehensQuote + onNochmal (G7b). نتیجه ذخیره نمی‌شود.
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
widgets/
  ⚠️ clickable_word_text.dart + word_popup_card.dart **حذف شدند** (L.5f) ⇒ core/widgets/klick_wort_text.dart +
     core/widgets/wort_popup.dart. lesen_controller: wordLookupProvider حذف (جایگزین: core/wort/klick_wort_provider.dart)
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
> ⏭️ بعد از انتشار: **R-2.3** — همه‌ی deckهای این پوشه گسترش پیدا می‌کنند (مثال، ترجمه، تمرین …)، همراه R-2.2؛ فقط افزودن، هیچ حذف/کوتاه‌کردن (PLAN → R-2.3).
```
screens/
  auswendiglernen_home_screen.dart [x]  — flat ListView (_learningDecks + _PruefungenDivider + _pruefungenDecks)؛ deckهای `hidden` فیلتر می‌شوند (2026-09-19)
                                      ⏭️ R-2.2 (فقط برنامه، 2026-09-22): کلمه‌های همه‌ی این deckها ⇒ کارت پرامپت کلمه + صفحه‌ی کلمه (PLAN → «R-2.2 — برنامه»)
                                      🔒 قانون Lukas: کارت‌های این صفحه هرگز حذف نمی‌شوند، محتوایشان (مثال/توضیح/ترجمه) کم نمی‌شود — فقط گسترش.
                                      📋 لیست‌ها بدون تغییر: هر ردیف عبارتِ کامل («eine Entscheidung treffen»)، نه کلمه‌های جدا؛ کلمه‌ها فقط داخل جزئیات کلیک‌پذیر می‌شوند.
                                      🔗 «eine Entscheidung treffen» (کارت عبارت) ≠ «die Entscheidung» (کارت کلمه): دو صفحه‌ی جدا، فقط لینک از عبارت به کلمه. عبارت: تلفظ + لایتنر، شکل هندسی نه (تا تعریف Lukas).
                                      📋 بعد از انتشار، یکی‌یکی. کلمه‌ی تکی ⇒ کارت Vokabular (`vokabId`)؛ NVV/Redemittel ⇒ «کارت عبارت» (`wortart: ausdruck`، پرامپت دوم — هنوز ساخته نشده)
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
                                      ⚠️⚠️ **شکاف A-1 (2026-09-18):** این صفحه فقط بر اساس **سازمان
                                      آزمون** چیده شده. طبق اصل «یک محتوا، چند ورودی» باید سه محور
                                      دسته‌بندی هم داشته باشد: سطح / موضوع / هفت مهارت — و ۳۴۵ تمرین
                                      گرامر (که الان فقط از درس‌ها دیده می‌شوند) از اینجا هم پیدا باشند.
                                      فهرست دقیق «هفت مهارت» هنوز از Lukas گرفته نشده.
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
  pomodoro_screen.dart            [x]  — phase label + بنر «فاز تمام شد» (_EndeBanner) + timer + play/pause/reset/skip + ۳ SwitchListTile (روشن ماندن صفحه، شروع خودکار، صدا)
  leitfaden_screen.dart           [x]  — MountainProgressWidget + level cards با skill chips
                                         ⏸️ فاز K (2026-10-25): ته صفحه مدال‌های درس‌ها + صفحه‌ی Zertifikat هر سطح
  vorlagen_screen.dart            [x]  — ۶ قالب A1→C1، ExpansionTile، clipboard copy
controllers/
  selbstlernen_controller.dart    [x]  — allHabitsProvider، activeHabitsProvider، habitByIdProvider
                                         habitLast7DaysProvider، habitCompletedTodayProvider
                                         HabitActions (create/update/delete/toggleToday)، habitActionsProvider
                                         PomodoroState، PomodoroNotifier، pomodoroProvider، kPomodoroKey
                                         **B-14 (2026-10-05):** PomodoroNotifier با ساعت واقعی کار می‌کند (`_endsAt`؛ `_sync` با هر تیک و با resumed)،
                                         وضعیت در shared_preferences (`pomodoro_zustand_v1`) ذخیره و بازیابی می‌شود؛ `WidgetsBindingObserver`
                                         **B-14b:** PomodoroState += autoWeiter، wachHalten، klang، beendetePhase، beendetUm؛ setzeAutoWeiter/setzeWachHalten/setzeKlang؛
                                         `_phasenAbschliessen` (فازهای میانی از ساعت واقعی)، `_wachAbgleich`؛ PomodoroPhaseExt.endeKey
                                         dayNames[7]، PomodoroPhase enum با labelFa + defaultSeconds
services/                          **B-14b (2026-10-05)** — قابلیت‌های دستگاه، جدا از منطق زمان (export شرطی مثل install_state.dart)
  pomodoro_geraet.dart            [x]  — export: basis + (io | web با dart.library.js_interop)
  pomodoro_geraet_basis.dart      [x]  — قراردادها: BildschirmWach (halten/loslassen)، PomodoroKlang (vorbereiten/spielen)
  pomodoro_geraet_io.dart         [x]  — بدون مرورگر (تست/بومی): کاری نمی‌کند
  pomodoro_geraet_web.dart        [x]  — navigator.wakeLock + Web Audio (سه نت سینوسی، بدون فایل صوتی)
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
                                     **P.3 (2026-09-20):** حساب و پشتیبان دیگر اینجا نیستند — `_ProfilKachel` (→ `/more/profil`)
                                     + `_SpeicherKarte`؛ `datenOrtSchluessel` از widgets/sicherung_karte.dart re-export می‌شود
  profil_screen.dart          [x]  — **P** (2026-09-20) `/more/profil`: `_Kopf` (آواتار/نام/وضعیت) · حساب (فقط با سرور) ·
                                     `PasswortAendernKarte` (بالا اگر `passwortNeuProvider`) · اطلاعات شخصی · آرشیو · پشتیبان
  subscription_screen.dart    [⛔]  — ENTFERNT 2026-09-13: Datei existiert nicht mehr (kein Abo). Früher: ConsumerWidget، isProProvider + customerInfoProvider (2026-06-30)
                                      not subscribed → RevenueCatUI.presentPaywallIfNeeded('VOX Unlimited')
                                      subscribed → active badge + RevenueCatUI.presentCustomerCenter()
                                      restore با SnackBar موفقیت / PurchasesError handling
                                      ⚠️ paywall + customer center: method channel — بدون context arg
  import_screen.dart          [x]  — SegmentedButton type/format، TextField paste، ImportResult
  privacy_policy_screen.dart  [x]  — متن حریم خصوصی؛ **به‌روز شد (2026-09-18)**: بخش «حساب کاربری (اختیاری)»
                                     اضافه شد چون متن قدیمی از قبل S.3 بود و دیگر درست نبود (می‌گفت هیچ داده‌ای
                                     روی سرور نمی‌رود؛ الان با ساختن حساب، ایمیل + نسخه‌ی پشتیبان می‌رود)
                                     + **L.1d (2026-09-22)**: بخش «حذف حساب» (دکمه، Root-in هم پاک می‌شود، داده‌ی دستگاه می‌ماند)
  fragen_screen.dart          [x] (در lib/features/fragen/) — ۸ FAQ با InkWell expansion
  sozialmedien_screen.dart    [x] (در lib/features/sozialmedien/) — Telegram/Instagram/YouTube (حساب‌های LukasAlmani، 2026-11-10)
controllers/
  settings_controller.dart    [x]  — AppSettings model (themeMode،ttsRate،currentLevel،...) — theme_mode فقط عدد ۰–۲ (2026-09-26، localStorage مشترک با Root-in)
                                     SettingsNotifier AsyncNotifier، settingsProvider
  profil_controller.dart      [x]  — **P** `profilProvider` (AsyncNotifier، `speichern()`)، `archivUebersichtProvider`،
                                     `passwortNeuProvider` + `passwortWiederherstellungStarterProvider` (از `app.dart` دیده می‌شود)
widgets/
  profil_angaben_karte.dart   [x]  — **P.1** نام/تلفن/آدرس‌ها؛ `_AdresseDialog`؛ یک «ذخیره» = کل فرم
  profil_konto_karte.dart     [x]  — **P.2** `ProfilKontoKarte` (ورود/ثبت‌نام/فراموشی رمز/ایمیل/همگام/خروج/**حذف حساب L.1d ✅ 2026-09-22**) + `PasswortAendernKarte`
                                     + `passwortFehlerSchluessel()` (تابع خالص)
  profil_archiv_karte.dart    [x]  — **P.3** اعداد آرشیو (فقط‌خواندنی) + پرش به لایتنر/فهرست‌ها
  sicherung_karte.dart        [x]  — کارت پشتیبان (از settings منتقل) + `datenOrtSchluessel()`
  konto_texte.dart            [x]  — `kontoFehlerText()`، `profilFehlerText()` (ترجمه فقط اینجا)
```

#### lib/features/fragen/ [x]
```
screens/fragen_screen.dart         [x]  — ۸ سوال متداول با ExpansionTile style
```

#### lib/features/sozialmedien/ [x]
```
screens/sozialmedien_screen.dart   [x]  — ۴ لینک LukasAlmani (کانال، گروه، Instagram، YouTube) با copy link
```

#### lib/features/home/ [x]
```
screens/home_screen.dart           [x]  — SliverAppBar + SliverGrid 3×4، 12 SectionData (Sprechen/Schreiben شرطی با `FeatureFlags.isVisible`)
screens/search_results_screen.dart [x]  — TextField AppBar، _Highlighted، ListTile results
controllers/search_controller.dart [x]  — GlobalSearchNotifier، جستجو در words/lessons/items
widgets/section_grid_item.dart     [x]  — gradient card + shadow
```

#### lib/features/sprechen/ [x]
```
screens/sprechen_home_screen.dart  [x]  — stub "به زودی"  ⏭️ اولین محتوا: Redemittel für Texte und Präsentationen (PLAN L.2f)
```

#### lib/features/schreiben/ [x]
```
screens/schreiben_home_screen.dart [x]  — stub "به زودی"  ⏭️ اولین محتوا: Redemittel für Texte und Präsentationen (PLAN L.2f)
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
  praepositionen_home_screen.dart      [x]  — لیست clusters (Nomen · Verb · Adjektiv + Präp) · **R-2.1 (2026-09-22):** عنوان = `PraepCluster.vollform` (کلمه + حرف اضافه، `DeutschText`)، معنی زیرش؛ جست‌وجو روی lemma هم
  praep_cluster_detail_screen.dart     ⚠️  2026-09-22: صدا/لایتنر/دسته‌بندی ندارد ⇒ **R-2.2 (فقط برنامه)**: هر lemma به کارت Vokabular (`/vokabular/wort/:id`) وصل شود — نه صفحه‌ی دوم
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
**Data:** redemittel_1010.json (۹۰۸) · redemittel_goethe_b2.json (۶۱) · redemittel_oesd_b2.json (۱۲۱) · redemittel_oesd_c1.json (۱۱۲ ✅ 2026-09-18)
**منبع منتظر (PLAN L.2f، 2026-11-08):** `old files Lukasalmani/1/redemittel_texte_praesentationen.md` — Redemittel für Texte und Präsentationen (۲۰۳) ⇒ deck پنجم با `redemittel_exam_list_screen.dart` + همان صفحه در Schreiben/Sprechen؛ هنوز وارد اپ نشده.
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
seed_wortschluessel.dart [x] — ⭐ **L.1e (2026-09-18) — تنها منبع** استخراج `<german>|<wordType>` از آن
                               ۴ فایل. چرا: همین رشته، شناسه‌ی لایتنر کاربر است
                               (`nutzer_zustand.dart` → `eigen:<german>|<wordType>`). یک اصلاح تایپی یا
                               عوض‌شدن `word_class` ⇒ پیشرفت کاربر روی آن کلمه یتیم می‌شود.
                               `data_seed_service` حالا `mapWordClass` را از اینجا می‌گیرد (قبلاً کپی
                               محلی داشت) تا دو فرمول از هم جدا نشوند.
                               🛡🛡 `test/seed_wortschluessel_test.dart` + فهرست ۱٬۰۱۶ شناسه در
                               `test/daten/seed_schluessel_veroeffentlicht.txt` ⇒ گم‌شدن شناسه = CI قرمز.
                               ثبت کلمه‌های تازه: `dart run tool/seed_schluessel_schreiben.dart`
                               (عمداً از حذف شناسه امتناع می‌کند — نمی‌شود با آن نگهبان را خاموش کرد).
                               ⚠️ برخلاف L.1a داخل workflow نیست: توکن‌های PAT اجازه‌ی تغییر
                               `.github/workflows/` ندارند (403) ⇒ نگهبان داخل تست‌ها، بدون شبکه.
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
  · `controllers/vokabular_controller.dart` [x] — **V.2 (2026-09-16):** `vokabIndexProvider` (فهرست از
    `assets/vocab_index.json`، برای لیست/جستجو/شمارنده/نماد) · `vokabIndexByIdProvider` (id → مدخل فهرست؛
    «کلمه وجود دارد؟») · `vokabKarteProvider(id)` (کارت **کامل** از `assets/vocab/<wortart>/<id>.json`، فقط
    هنگام باز کردن صفحه‌ی کلمه) + `vokabId()` (قانون ۵) + `vokabKartePasst()` (جستجوی DE/FA/EN).
    ⚠️ مدخل فهرست ≠ کارت کامل: Beispiele/Konjugation/Wortnetz فقط در `vokabKarteProvider`.
  · `controllers/vokabular_user_state.dart` [x] — Leitner-Map (box/nextReviewDate) + Kategorien
    (فقط Wort-ID) + **Notizen** (`VokabNotiz {text, farben: WortIndex→Farbname}`، متن خالی=حذف)؛
    `_ready`-Gate. **Seit B-11: Leitner + Listen in drift, NUR über die Fassade**
    (`archivLesen()` usw. in `core/backup/user_state_repository.dart`); Notizen in
    SharedPreferences (`vokab_user_notizen_v1`). `neuLaden()` nach Einspielen/Abgleich.
  · `widgets/wort_notiz.dart` [x] ✅ 2026-07-14 — **Freitext-Notiz روی Wort-Seite** (user state):
    `WortNotizSektion` نمایش RichText رنگی + BottomSheet-Editor (کلمه لمس/انتخاب → VoxIconButton
    دایره‌ی رنگی، ۶ رنگ `notizFarben` + Standard)؛ live-رنگ با `_NotizController.buildTextSpan`؛
    helper های خالص `notizSpans`/`notizWortIndizes` (تست‌شده).
  · `widgets/wort_actions.dart` [x] — 🔊 AudioPlayButton (موجود) + Leitner-Toggle + Kategorien-
    BottomSheet؛ فقط Vox-کامپوننت‌ها؛ snackbar کلیدهای added_to_leitner/removed_from_leitner.
  · `widgets/wortseite_bausteine.dart` [x] — Sektion/Zeile/BeispielBlock/Tabelle + `vokabUeb()`
    (یک زبان، فاز L). `widgets/details_renderer.dart` [x] — ۱۰ Wortart؛ Perfekt از PerfektBuilder.
  · `screens/wort_seite_screen.dart` [x] (⭐ اصل اول: هر کارت همیشه همین صفحه‌ی خودش — هیچ هدایت به صفحه‌ی قدیمی. کاشی‌ها: `widgets/wort_karte_inhalt.dart`؛ Wortnetz کلیک‌پذیر، id مشتق از vokabId، push زنجیره‌ای؛
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
    · `data/vokab_index.dart` [x] **V.2** — reines Dart: قالب فهرست کلمات (`vokabIndexEintrag`,
      `vokabIndexBauen`, `vokabIndexLesen`, `vokabKartenPfad`) + `vokabIndexDetailFelder` (فیلدهایی از
      details که نماد لازم دارد — ⚠️ فیلد جدید در Resolver ⇒ اینجا هم؛ `test/vokab_index_test.dart` مراقب است).
      + **L.1a:** `vokabIndexIds` (بدون بررسی نسخه، برای فهرست سایت زنده) و `vokabVerloreneIds`.
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
- ✅ **Laufzeit — umgesetzt 2026-09-16 (V.2) als Wortindex, NICHT als `vocab.db`** (Web-only + 2 Beispiele je
  Karte ⇒ zweite SQLite-DB ohne Nutzen): `assets/vocab_index.json` beim Start, volle Karte lazy. Begründung:
  PLAN.md → فاز V → V.2. Der folgende Punkt ist die ältere Planung:
- ~~**Laufzeit (سریع)**~~ (überholt): build-script → یک **prebuilt SQLite `assets/vocab.db`**:
  `words` (~26k، indexed) + `word_tags` (m:n) + `sentences` (~2.6M، **lazy**).
  first-launch **یک‌بار کپی** (نه seed). **لیست فقط words (سریع/paginated)؛ جمله‌ها lazy.
  چند سورت هم‌زمان = چند index روی همان یک جدول. سورت = query نه فایل.**
- **هم‌زیستی**: فایل‌های feature قدیمی بدون تغییر؛ ستون `source` در words → ترکیب بعدی با filter.
- **توزیع (تصمیم مشترک کاربر+Claude، بعداً)**: **ZIP** / **Apple CloudKit** / db قابل‌دانلود /
  bundle با جمله‌های کمتر — به‌خاطر سقف ~۶۰۰ MB > حد store. ساختار فایل کلمه در همه حالات یکسان.
- ⏳ **تنها نکته باز schema**: تصمیم ~۱۰۰ جمله (Prompt الان حداقل ۲) + قرارداد نهایی tag ها.

---


## INHALTSVERZEICHNIS (فهرست مطالب)

> خودکار از سرتیترهای همین فایل ساخته شد (2026-10-22). نقشه‌ی کامل درخت `lib/`، `test/`، `tool/` و جدول‌های دیتابیس.

- [🗒️ تغییرات مهم اخیر (فشرده — خلاصه‌سازی چهارم، 2026-10-22)](#-تغییرات-مهم-اخیر-فشرده--خلاصه‌سازی-چهارم-2026-10-22)
- [📚 کلمه‌ها — روال «ده کلمه جدید» (فایل‌ها و پیشرفت)](#-کلمه‌ها--روال-ده-کلمه-جدید-فایل‌ها-و-پیشرفت)
- [TECH STACK](#tech-stack)
- [STATUS LEGEND](#status-legend)
- [ROOT FILES](#root-files)
- [lib/ — COMPLETE FILE TREE](#lib--complete-file-tree)
  - [lib/main.dart (x)](#libmaindart-x)
  - [lib/app.dart (x)](#libappdart-x)
  - [lib/core/](#libcore)
- [lib/core/Design System — Tokens](#libcoredesign-system--tokens)
- [lib/core/Design System — Components (موجود)](#libcoredesign-system--components-موجود)
- [lib/core/Design System — Components (B9–B11 اکثراً LIVE شدند — 2026-07-04)](#libcoredesign-system--components-b9b11-اکثرا-live-شدند--2026-07-04)
- [lib/core/Architecture Hub](#libcorearchitecture-hub)
  - [lib/features/](#libfeatures)
- [🎨 Wo Form und Farbe der Wörter festgelegt sind (Grammatikon)](#-wo-form-und-farbe-der-wörter-festgelegt-sind-grammatikon)
- [💾 Wo die Nutzerdaten liegen (فاز S, 2026-09-15)](#-wo-die-nutzerdaten-liegen-فاز-s-2026-09-15)
- [⚙️ Arbeiten über die GitHub-API (Lehren 2026-09-15)](#-arbeiten-über-die-github-api-lehren-2026-09-15)
- [tool/ — Werkzeuge (فاز A, 2026-09-15)](#tool--werkzeuge-فاز-a-2026-09-15)
- [BUGS FIXED](#bugs-fixed)
- [BACKLOG / UPCOMING CHANGES](#backlog--upcoming-changes)
- [⭐ اصول معماری پایه (هر Session باید رعایت شود)](#-اصول-معماری-پایه-هر-session-باید-رعایت-شود)
  - [اصل ۱: Component Isolation (ارجاع‌دهی) — مهم‌ترین قانون](#اصل-۱-component-isolation-ارجاع‌دهی--مهم‌ترین-قانون)
  - [اصل ۲: One Screen — Two Locations (یک صفحه، دو مکان نمایش)](#اصل-۲-one-screen--two-locations-یک-صفحه-دو-مکان-نمایش)
  - [اصل ۳: Content-Aware Filters (فیلتر متناسب با محتوا)](#اصل-۳-content-aware-filters-فیلتر-متناسب-با-محتوا)
  - [اصل ۴: آپدیت فوری نقشه و پلن](#اصل-۴-آپدیت-فوری-نقشه-و-پلن)
  - [⭐ اصل ۵: هر محتوای جدید از اول دوزبانه (فارسی + انگلیسی) — فاز L3](#-اصل-۵-هر-محتوای-جدید-از-اول-دوزبانه-فارسی--انگلیسی--فاز-l3)
- [KEY CONVENTIONS](#key-conventions)
  - [سر هر فایل dart:](#سر-هر-فایل-dart)
  - [آرتیکل رنگ‌ها (ArticleColors):](#آرتیکل-رنگ‌ها-articlecolors)
  - [withValues vs withOpacity:](#withvalues-vs-withopacity)
  - [Provider pattern:](#provider-pattern)
  - [Drift imports:](#drift-imports)
  - [دسته‌های کاربر:](#دسته‌های-کاربر)
  - [Navigation:](#navigation)
- [DATABASE TABLES (drift — schema v7)](#database-tables-drift--schema-v7)
