# PROJECT MAP — VOX
# نقشه کامل پروژه برای ناوبری سریع در هر session
# آپدیت: 2026-09-23 دور ۲۵ — خلاصه‌سازی دوم (درخواست Lukas): کارنامه‌ی دورها به یک خط کوتاه شد؛ متن کامل قبلی: `git show a078dc2:PROJECT_MAP.md`.
#   تازه‌ها در همین روز: web/locale_guard.js · leitnerEintraegeProvider (لایتنر دو منبع، B-13) · wende_karte.dart + archiv_flash_card.dart · WortZeile در wort_card.dart
#   · wort_popup.dart (_WortKopf تلفظ، _LadenFehlgeschlagen) · deutschLinksbuendig + DeutschRichText (core/widgets/deutsch_text.dart) · vokab_formen.dart ⇒ assets/vocab_formen/.
# دور ۲۶–۲۷: DeutschMitEtikett (deutsch_text.dart) · جدول/ردیف‌های آلمانی deckها Directionality(ltr) · Wrap(textDirection: ltr) در همه‌ی تمرین‌های مرتب‌کردن · نگهبان deutscher_text_waechter_test با ~۴۰ فیلد.
# دور ۲۸: +۱۰ کارت صفت در assets/vocab/adjektiv/ (aalglatt … abbildbar) ⇒ آرشیو ۹۷ کارت؛ منبع: old files Lukasalmani/Wörter/Adjektive.txt (✓ = ساخته‌شده).
# دور ۲۹: روال «ده کلمه جدید» ⇒ بخش «📚 کلمه‌ها» همین فایل + tool/naechste_woerter.dart (تازه).
# دور ۳۰: ترتیب فهرست‌های کلمه (Lukas) در tool/naechste_woerter.dart؛ abatisch کنار گذاشته می‌ماند.
# دور ۳۳ (2026-09-24): L.3 آفلاین ⇒ tool/pwa/ (تازه: workbox_config.cjs · sw_bauen.cjs · offline_test.cjs · package.json/lock) ⇒ build/web/vox_sw.js ·
#   web/index.html ثبت vox_sw.js · deploy-web.yml: --pwa-strategy=none --no-web-resources-cdn + دو مرحله‌ی تازه (worker، تست آفلاین Chrome).
# دور ۳۴ (2026-09-24): +۱۰ کارت (abenteuerlich … abfällig) در assets/vocab/ ⇒ آرشیو ۱۱۷. aberhundert/abertausend ⇒ numerale (wortartKorrektur).
# دور ۳۵ (2026-09-24): +۱۰ کارت (abgabenfrei … abgelegen) در assets/vocab/ ⇒ آرشیو ۱۲۷. abgefuckt mit Hinweis «vulgär».
# دور ۳۶ (2026-09-24): +۱۰ کارت (abgemacht … abhold) در assets/vocab/ ⇒ آرشیو ۱۳۷. 
# 🚀 کارهای باز قبل از انتشار (فهرست کامل): PLAN.md → «🚀 قبل از انتشار». بعد از انتشار: PLAN.md → «⏭️ بعد از انتشار».
#
# ⚠️ 2026-09-19 (اصلاح یادداشت آفلاین): «precache شدنی است» فقط برای ~۷٫۵MB فعلی (۸۷ کارت) درست است. کارت ~۴KB ⇒ ~۲۶٬۲۰۰ کارت ≈ ~۱۰۰MB
#   (ارقام خود PLAN) ⇒ پیش‌بارگذاری همه‌ی کارت‌ها همچنان گزینه نیست؛ فقط دارایی‌های ثابت + فهرست + کارتِ بازشده. جزئیات: PLAN → L.3.
#   ✅ 2026-09-24 اجرا شد: tool/pwa/workbox_config.cjs (تنها منبع تقسیم پیش‌بارگذاری / هنگام استفاده).
#
# 🔒 قاعده: هر چیزی که **داده‌ی کاربر به آن اشاره می‌کند** باید قبل از انتشار نگهبان داشته باشد —
#   بعد از انتشار عوض‌کردنش یعنی از دست رفتن پیشرفت کاربر. وضعیت: کارت آرشیو ✅ L.1a · مهاجرت DB ✅ L.1b ·
#   لیست‌های شخصی ✅ S.6 · قرارداد پشتیبان ✅ S.5 · کلمه‌های همراه اپ ✅ L.1e (2026-09-18).
#
# 🧭 قاعده‌ی ثابت هر چت جدید (Lukas، 2026-09-18) — این بخش را حذف نکن:
#   ۱) اول چت: هر چهار فایل (vox/PLAN.md، vox/PROJECT_MAP.md، Root-in/PLAN.md، Root-in/MAP.md) را
#      تازه از api.github.com بخوان، نه از حافظه.  ۲) اولین قدم باز را بدون پرسیدن انجام بده.
#   ۳) آخر هر کار و آخر هر چت: در PLAN و MAP همان ریپو ورودی کوتاه بنویس + خط «آخرین جلسه» در PLAN را تازه کن.
#      کاری که ثبت نشود، برای چت بعدی وجود ندارد. فهرست مطالب و Hinweise حفظ می‌شوند.
#
# ⭐ اصل معماری «یک محتوا، چند ورودی» (Lukas، 2026-09-18) — هم‌ردیف Component Isolation:
#   هر واحد محتوا (تمرین، کلمه، عبارت، متن) یک‌بار ساخته و ذخیره می‌شود و از چند در دیده می‌شود.
#   هرگز برای نمایش دوم، نسخه‌ی دوم ساخته نشود — وگرنه اصلاح باید دوبار انجام شود و دو نسخه واگرا می‌شوند.
#   نمونه: تمرین گرامر ← (۱) در Grammatik بعد از آموزشِ همان موضوع، (۲) در Prüfungen با دسته‌بندی
#   سطح / موضوع / هفت مهارت. جزئیات کامل + تقسیم کار در PLAN.md بخش «یک محتوا، چند ورودی» و A-1.
#   هفت مهارت (Lukas، 2026-09-18): ۱ کلمه · ۲ گرامر · ۳ چیزهای حفظی (Redemittel، افعال بی‌قاعده،
#   حروف اضافه‌ی ثابت با فعل/اسم/صفت، ترکیب‌های ثابت فعل+اسم) · ۴ نوشتن · ۵ خواندن · ۶ شنیدن · ۷ حرف زدن.
#   ⚠️ اینکه هر پوشه‌ی features زیر کدام مهارت می‌نشیند هنوز حدس Claude است — در A-1 با Lukas تأیید شود.
#   ⚠️ شکاف شناخته‌شده: pruefungen_home_screen فقط بر اساس سازمان آزمون (Goethe/telc/ÖSD) چیده شده؛
#   سه محور دسته‌بندی هنوز آنجا نیستند و ۳۴۵ تمرین گرامر از Prüfungen دیده نمی‌شوند.
#
# ⚠️ 2026-09-13: فقط Flutter-Web روی GitHub Pages (بومی/RevenueCat/Notifications حذف). Habit/Routine ⇒ Root-in، ریپوی جدا؛
#   تنها اتصال: لینک Routine در core/constants/app_links.dart.
# ❗ Wort-Prompt: EIN Wort = EINE Karte. Alle Übersetzungen stehen zweisprachig {fa,en} in
#   derselben Datei; die App zeigt laut Einstellungen genau eine Sprache (vokabUeb/AppL10n.isFa).
#   Das Aussehen der Wortseite steht NICHT im Prompt, sondern in core/grammatikon/ und
#   features/vokabular/screens/wort_seite_screen.dart. Details: PLAN.md → فاز S.
#   ⛔ استثنا: کارت‌های کلمه را همیشه Claude طبق «old files Lukasalmani/Wort prompt» می‌سازد — تبدیل منابع Lukas رد شد (2026-09-16).
#   ⚠️ شناسه‌ی کارت منتشرشده در assets/vocab/ هرگز حذف/عوض نشود — لایتنر کاربر به آن اشاره می‌کند.
#   ⚠️ کپی‌رایت: هیچ جمله/تمرینی از کتاب کپی نمی‌شود — فقط موضوع؛ متن و مثال و تمرین از نو نوشته می‌شود.
# 🌐 زبان شروع: پیش‌فرض انگلیسی، فقط روی دستگاه فارسی‌زبان فارسی — تنها منبع: core/l10n/geraete_sprache.dart.
# 🎯 وضعیت (2026-09-23): ۳۰۰ فایل Dart (۱۸۲ features + ۱۱۶ core) · DB schema v7 · ۳۰۹ تست سبز · analyze سبز.
#   کارهای باز و کارنامه‌ی جلسه‌ها: PLAN.md بالای فایل.

---

## INHALTSVERZEICHNIS (فهرست مطالب)

> خودکار از سرتیترهای همین فایل ساخته شد (2026-09-23 دور ۲۵). ✅ = کامل · ⛔ = منسوخ.

- [📚 کلمه‌ها — روال «ده کلمه جدید» (فایل‌ها و پیشرفت)](#-کلمه‌ها--روال-ده-کلمه-جدید-فایل‌ها-و-پیشرفت)
- [TECH STACK](#tech-stack)
- [STATUS LEGEND](#status-legend)
- [ROOT FILES](#root-files)
- [lib/ — COMPLETE FILE TREE](#lib--complete-file-tree)
  - [lib/main.dart [x]](#libmaindart-x)
  - [lib/app.dart [x]](#libappdart-x)
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

---

## 📚 کلمه‌ها — روال «ده کلمه جدید» (فایل‌ها و پیشرفت)

> روال کامل (مراحل ۱–۸ و قاعده‌ها): **PLAN.md → «📚 روال ده کلمه جدید»**. دستور Lukas: «ده کلمه جدید وارد کن». ترتیب فهرست هرگز عوض نمی‌شود.

- پرامپت کلمه: [`old files Lukasalmani/Wort prompt`](https://github.com/lukasylilli/vox/blob/main/old%20files%20Lukasalmani/Wort%20prompt)
- فهرست‌ها: [`old files Lukasalmani/Wörter/`](https://github.com/lukasylilli/vox/tree/main/old%20files%20Lukasalmani/W%C3%B6rter) — فعلی: `Adjektive.txt` (`✓ ` = کارت ساخته شد؛ مرجع واقعی وجود کارت: `assets/vocab/`)
- `tool/naechste_woerter.dart` — ۱۰ کلمه‌ی بعدی (رد: کارت موجود + `zurueckgestellt`؛ `wortartKorrektur` = Wortart درست برای برچسب غلط فهرست، مثل aberhundert ⇒ numerale) · `tool/vokabular_import.dart` — JSON-Array ⇒ `assets/vocab/<wortart>/<id>.json` (اعتبارسنجی با `vokab_schema.dart`) · `tool/vokab_index.dart` — `assets/vocab_index.json` + `assets/vocab_formen/`
- **ترتیب فهرست‌ها (Lukas):** Adjektive ⇒ Verben_unregelmaeßig_Infinitiv ⇒ Verben_regelmaesig ⇒ substantiv_singular_alle — در `tool/naechste_woerter.dart` (`listen`). کلمه‌ی نامطمئن ⇒ `zurueckgestellt` + گزارش.
- **اسم‌ها (Lukas 2026-09-24):** نام شهرها ⇒ فقط تلفظ + معنی + آرتیکل (نوع کارت کوتاه، هنوز در schema نیست) · ⛔ قبل از شروع فهرست اسم‌ها درباره‌ی اسم‌های بدون آرتیکل از Lukas بپرس.
- **پیشرفت (2026-09-24 دور ۳۶):** آخرین کلمه‌ی ساخته‌شده **abhold** · بعدی **abhängig** · کنار گذاشته: abatisch، abdikativ · آرشیو: ۱۳۷ کارت.

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
  wortschatz_list_screen.dart  [x]  — «Alle Wörter» = لیست ادغامی دو منبع: allWordsProvider (DB → WordListItem)
                                      + vokabularProvider (assets/vocab → WortCard+WortActions → /vokabular/wort/:id)؛
                                      سورت الفبایی مشترک (بدون Artikel)؛ SearchBar + FilterAccordion (Niveau، Wortart،
                                      نگاشت _typZuWortart) + FilterChipBar؛ query param `suche`؛ route: /wortschatz/list
  book_list_screen.dart        [x]  — allBooksProvider + FAB + _addBook dialog
  book_words_screen.dart       [x]  — wordsByBookProvider(bookId) + ListView
  level_words_screen.dart      [x]  — wordsByLevelProvider + _LevelPickerBar (legacy، هنوز در router)
  type_words_screen.dart       [x]  — wordsByTypeProvider + _TypePickerBar (legacy، هنوز در router)
  word_detail_screen.dart      [x]  — همه فیلدها conditional + BottomBar: (2026-09-22: دکمه‌ی «favorit» جدا وجود ندارد — دسته‌بندی/فهرست جایش است)
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
  sozialmedien_screen.dart    [x] (در lib/features/sozialmedien/) — Telegram/Instagram/YouTube
controllers/
  settings_controller.dart    [x]  — AppSettings model (themeMode،ttsRate،currentLevel،...)
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
screens/sozialmedien_screen.dart   [x]  — ۳ کانال با copy link
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
| `web/index.html` (ثبت SW) | **L.3 ✅** (2026-09-24) — بعد از `load` فایل `vox_sw.js` را ثبت می‌کند (scope = `/vox/`). Flutter-SW خاموش است (`--pwa-strategy=none`)، چون در 3.44 خودش را unregister می‌کند و `vox_sw.js` را در همان scope کنار می‌زد |
| `tool/pwa/workbox_config.cjs` | **L.3 ✅** — **تنها منبع** رفتار آفلاین: فهرست پیش‌بارگذاری (همه‌چیز جز کارت‌ها/`vocab_formen`/`*.symbols`/skwasm)، `PFLICHT` (فایل‌هایی که بدونشان آفلاین شروع نمی‌شود)، runtime: `vox-woerter` (StaleWhileRevalidate) + `vox-schriften` (fonts.gstatic). skipWaiting خاموش، clientsClaim روشن |
| `tool/pwa/sw_bauen.cjs` | **L.3 ✅** — بعد از `flutter build web` در deploy: پرچم‌ها را در `flutter_bootstrap.js` چک می‌کند (بدون serviceWorkerSettings، `useLocalCanvasKit: true`)، هر هشدار Workbox یا فایل اجباری غایب ⇒ قرمز؛ بعد `build/web/vox_sw.js` |
| `tool/pwa/offline_test.cjs` | **L.3 ✅** — Chrome واقعی (`CHROME_PATH`): آنلاین ⇒ worker فعال ⇒ Offline + goto ⇒ همه‌ی فایل‌های بسته با fetch آفلاین ⇒ پنجره‌ی تازه آفلاین. ملاک «VOX بالا آمد» = `#vox-loading` حذف شده. ⚠️ `page.reload()` در Playwright با Offline از SW رد می‌شود ⇒ `goto` |
| `tool/pwa/package.json` + `package-lock.json` | **L.3 ✅** — workbox-build 7.4.1 + playwright-core 1.55.0 (بدون مرورگر؛ Chrome خود ubuntu-latest). `node_modules` در `.gitignore` |
| `features/more/screens/settings_screen.dart` → `_SpeicherKarte` | zeigt diese Einladung unter «داده‌ی من» |
| `test/praep_vollform_test.dart` | **R-2.1 (2026-09-22)** — `PraepCluster.vollform`: gemeinsame Präposition einmal am Ende, sonst je Wort; prüft alle 185 echten Cluster |
| `test/konto_loeschen_test.dart` | **L.1d (2026-09-22)** — Knopf «حذف حساب»: Dialog nennt Root-in · Abbrechen löscht nichts · deleted / unavailable (eigene Sicherung + abmelden) / failed · `deleteAccount()` ohne Server = failed. Auth/Ablage/Abgleich ersetzt, kein Netz |
| `test/l10n_paritaet_test.dart` | hält FA/EN-Schlüssel synchron. MaterialApp-Aufbau **muss** `Global*Localizations` nutzen — `Default*Localizations` kennen kein Farsi |
| `core/backup/nutzer_zustand.dart` | **S.0a-1 ✅ — DER VERTRAG.** Was einem Nutzer gehört + Hülle `{version, exportedAt, app, payload}` + `zusammenfuehren()` („höchstes Fach gewinnt"). Reines Dart, ohne drift/prefs/Flutter. ⚠️ Leitner-IDs sind Text (`adjektiv_stolz`, `eigen:<wort>\|<wortart>`) — die drift-Nummer gehört NIE in eine Sicherung |
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
| `supabase/vox_tables.sql` | **S.3 ✅** — `vox_backups`, eine Zeile je Konto. ⚠️ **Nicht** `backups` — die gehört Root-in und hat dieselbe `user_id` als Primärschlüssel; geteilt hieße: eine App überschreibt die Sicherung der anderen. `touch_updated_at()` **und (L.1d, §5) `delete_own_account()`** zeichengleich zu `schema.sql` in Root-in — Änderung immer in BEIDEN Dateien |
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
| `core/backup/nutzer_zustand.dart` → `profil` | **Vertrag Fassung 4 (P.1)** — Feld nur im JSON, wenn vorhanden; Fassung 1–3 lesbar; leeres Profil mit neuerem Zeitpunkt gewinnt |
| `core/backup/user_state_repository.dart` → `kProfilKey` (`vox_profil_v1`) | Profil in SharedPreferences; `lesen()` liest, `anwenden()` Schritt (6) schreibt. ⚠️ bewusst **nicht** in `einstellungsSchluessel` (dort „eigener Stand gewinnt" ⇒ neues Gerät bekäme das Profil nie) |
| `core/services/auth_service.dart` (P.2) | + `changePassword` · `changeEmail` · `sendPasswordReset` · `signOutEverywhere` · `watchPasswordRecovery`; `AuthIssue.samePassword`/`reauthNeeded`. ⚠️ Passwort/E-Mail gelten für **beide** Apps (`auth.users` geteilt) |
| `core/constants/app_links.dart` → `voxUrl` | Rücksprung-Adresse für Mails; **muss** in Supabase → Redirect URLs stehen, sonst landet der Link auf der Site URL (= Root-in) |
| `core/constants/app_links.dart` → `voxPasswortUrl` (2026-09-23) | `…/vox/?link=passwort` — Rücksprung der Passwort-Mail. **Muss zeichengleich** in Supabase → Redirect URLs stehen (eingetragen 2026-09-23); fehlt sie, landet der Link auf der Site URL (`localhost:3000`). Test prüft den Text |
| `features/more/…` (Profil-Seite) | siehe Baum `lib/features/more/` oben; Route `AppRoutes.profil` = `/more/profil`; Einstieg: More (erste Zeile) + Einstellungen → `_ProfilKachel` |
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

| فایل | زبان | کار |
|------|------|-----|
| `tool/vokab_ids_pruefen.dart` | Dart | **L.1a** — Wächter: vergleicht den Index der **Live-Seite** mit dem frisch gebauten; fehlt eine veröffentlichte id ⇒ exit 1. Läuft in `deploy-web.yml` und `pruefen.yml` nach „Wortindex bauen". Handauslassung nur über `workflow_dispatch`-Eingabe `ohne_id_waechter` |
| `tool/vokab_index.dart` | Dart | **V.2** — baut `assets/vocab_index.json` aus `assets/vocab/`. Läuft in **jedem** Workflow direkt vor `flutter analyze`; Ergebnis nie committet (`.gitignore`). exit 1 bei unlesbarer/falsch abgelegter Karte oder doppelter id |
| `tool/naechste_woerter.dart` | Dart | **L.4 (2026-09-23)** — nennt die nächsten N Wörter der aktuellen Wortliste ohne Karte (Reihenfolge der Datei, `zurueckgestellt` = unsichere Wörter für Lukas). Routine: «📚 کلمه‌ها» oben / PLAN.md |
| `tool/vokabular_import.dart` | Dart | **verbindliche Prüfung** — Konverter-Output → `assets/vocab/<wortart>/<id>.json`. Nutzt `vokabPruefeKarte()` aus `lib/features/vokabular/data/vokab_schema.dart`. Duplikat-Schutz, idempotent, exit 1 bei Fehlern |
| `tool/backlog.py` | Python | **A.1** — welches Wort ist als Nächstes dran? Leitet den Stand aus `assets/vocab/` ab (nicht aus den ✓-Marken). `--stand` / `--naechste N` / `--gruppe` / `--json`. Spiegelt `vokabId()` zeichengenau |
| `tool/sync_backlog.py` | Python | **A.2** — schreibt die ✓-Marken in `Wörter/*.txt` aus `assets/vocab/` neu. idempotent, `--dry-run` |
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
⛔ **A.6 (2026-09-16): Welcher Weg die Wörter erzeugt, entscheidet Lukas.** Optionen: API
(`vokabular-autofill.yml`, kostet Geld) · von Hand im Chat mit Claude · Claude Code — oder gemischt.
Details und Schätzung: PLAN.md → فاز A → A.6. **Claude beginnt damit nie von sich aus, sondern fragt
Lukas, sobald es so weit ist** (vor dem ersten echten Lauf bzw. nach V.2). Der dafür nötige
„nur-Import"-Weg (Karten in `import_inbox/` → Dart-Prüfung + Tests in GitHub → Commit) existiert
noch nicht und wird erst nach dieser Entscheidung gebaut.

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
