# PROJECT MAP — VOX
# نقشه کامل پروژه برای ناوبری سریع در هر session
# آپدیت: 2026-09-20 دور ۴ (✅ L.5f: کلیک روی کلمه — `core/wort/{wort_form,klick_wort,klick_wort_provider}.dart` + `core/widgets/{wort_popup,klick_wort_text}.dart`؛ وصل به Lesen/Grammatik-Lektion/Redemittel-Detail/Konnektor/Unregelm/Wort-Seite/Karaoke؛ `clickable_word_text`/`word_popup_card`/`wordLookupProvider` حذف؛ `test/klick_wort_test.dart`) · قبلی: 2026-09-20 دور ۳ (فقط یادداشت: Root-in «Phase 32 — Wochenplan» روی main؛ کد و ساختار VOX تغییر نکرد) · قبلی: 2026-09-20 دور ۲ (⏳ L.5f در حال انجام — کامپوننت مشترک «کلیک روی کلمه»: `core/widgets/wort_popup.dart`، `klick_wort_text.dart`، `core/wort/klick_wort.dart`؛ نتیجه در ورودی بعدی) · قبلی: 2026-09-20 (فاز P: صفحه‌ی `/more/profil` — حساب/امنیت/اطلاعات شخصی/آرشیو/پشتیبان؛ قرارداد پشتیبان v4 `profil`؛ `_KontoKarte`/`_SicherungKarte` از settings به widgets منتقل) · قبلی: 2026-09-19 (دور چهارم — فلگ `hidden` واقعاً اعمال می‌شود [feature_flags · home_screen · auswendiglernen_home_screen · test/feature_flags_test]؛ doc-drift فاز ۱۶/RevenueCat پاک شد) · دور سوم همان روز: فقط ثبت — دروازه‌های انتشار؛ جزئیات: PLAN.md → «آخرین جلسه» · قبلی: 2026-09-18 (ادامه ۶ — L.1e: نگهبان شناسه‌ی کلمه‌های همراه اپ؛ RTL بسته؛ اصل «یک محتوا، چند ورودی» + A-1 ثبت؛ آفلاین باز)
#
# ⚠️ 2026-09-19 (اصلاح یادداشت آفلاین): «precache شدنی است» فقط برای ~۷٫۵MB فعلی (۸۷ کارت) درست است. کارت ~۴KB ⇒ ~۲۶٬۲۰۰ کارت ≈ ~۱۰۰MB
#   (ارقام خود PLAN) ⇒ پیش‌بارگذاری همه‌ی کارت‌ها همچنان گزینه نیست؛ فقط دارایی‌های ثابت + فهرست + کارتِ بازشده. تحلیل است نه تصمیم. جزئیات: PLAN → L.3.
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
# ⚠️ 2026-09-13: Umbau zur reinen Web-App — android/ios/macos/linux/windows, RevenueCat & Notifications entfernt; ältere Einträge beschreiben teils den nativen Stand
# ⚠️ 2026-09-13: Habit/Routine entfernt — Root-in (eigenes Repo, lukasylilli.github.io/Root-in/) übernimmt das, verlinkt aus Selbstlernen ("Routine"-Karte, core/constants/app_links.dart + core/utils/external_link_opener.dart). Pomodoro bleibt unverändert.
# ❗ Wort-Prompt: EIN Wort = EINE Karte. Alle Übersetzungen stehen zweisprachig {fa,en} in
#   derselben Datei; die App zeigt laut Einstellungen genau eine Sprache (vokabUeb/AppL10n.isFa).
#   Das Aussehen der Wortseite steht NICHT im Prompt, sondern in core/grammatikon/ und
#   features/vokabular/screens/wort_seite_screen.dart. Details: PLAN.md → فاز S.
#
# ⚠️ 2026-09-15 Audit (Claude, über GitHub-API): ۲۵۳ فایل Dart (بدون .g.dart) · ~۴۱٬۴۰۰ خط
#   · assets/vocab/ = ۸۷ کارت، همه schema 3.0، بدون JSON خراب (۷۶ verb · ۳ adjektiv · ۸ بقیه)
#   · ⚠️ vokabular_controller.dart همه کارت‌ها را در startup می‌خواند ⇒ سقف امن ~۵۰۰ کارت؛ V.2 پیش‌شرط شد
#     ✅ V.2 (2026-09-16): حل شد — شروع فقط assets/vocab_index.json (ساخته‌ی tool/vokab_index.dart در هر workflow، commit نمی‌شود)؛ کارت کامل lazy
#   · ⚠️ مارک‌های ✓ در Wörter/*.txt از واقعیت عقب‌اند ⇒ منبع حقیقت = assets/vocab/ (tool/sync_backlog.py)
#   · B-3 / R-1.1 در کد رفع شده‌اند (stripPreposition در word_list_item.dart) — در BACKLOG اصلاح شد
#   · ✅ README (2026-09-18): خط قدیمی «Selbstlernen — Gewohnheiten, Streaks» به Pomodoro/Lernpfad/Vorlagen + Root-in-Link اصلاح شد
#   · فاز A (خودکارسازی ورود کلمات) باز شد — PLAN.md → «فاز A»
#   · فاز S (ذخیره‌سازی داده‌ی کاربر) — S.0–S.6 ✅ (S.6 feste Listen-id 2026-09-16, DB v7, Vertrag v3)؛ باز: S.3 Konto löschen
#
# 🚀 2026-09-16 تصمیم Lukas — ترتیب جدید (PLAN.md → «فاز LAUNCH»):
#   اپ زودتر و به‌صورت نسخه‌ی نهایی منتشر می‌شود؛ کلمه‌ها آخرین مرحله‌اند و بعد از انتشار روزانه اضافه می‌شوند.
#   L.1 امنیت لایتنر (S.6 ✅, V.2, نگهبان شناسه‌ها, تست مهاجرت) → L.2 کامل بودن محتوا → L.3 انتشار → L.4 کلمه‌ها
#   Audit محتوا: Redemittel/Goethe/ÖSD B2/Konnektoren/NVV/Präp/Dativ = کامل نسبت به منبع.
#   ✅ L.2c (2026-09-16): گرامر ۸۴/۸۴ درس live (assets/data/grammatik/ ۱۷ فایل) — تمرین‌ها: G7a/G7b ✅، G7c/G7d باز.
#     🔁 L.2c بازبینی مستقل (2026-09-16، جلسه‌ی بعد): منبع «old files Lukasalmani/1/Grammatik» = ۱۷ سند درس (۸۴ درس، ۳۳۶ تمرین،
#        _index هر سند = درس‌های واقعی‌اش) + ۲ سند تنظیمات آزمون سطح (questionsPerLevel 10، passThreshold 0.7 ⇒ برای G7)؛
#        هر ۱۷ سند بایت‌به‌بایت = assets/data/grammatik/ · ۷۹ route درس + ۵ صفحه‌ی ویژه = ۸۴ · چیزی کم نیست.
#   ✅ ÖSD C1 (2026-09-18): ۱۱۲ عبارت از منبع Lukas ساخته و زنده شد (route + flag live) · A1/A2 Wortschatz (۱٬۰۶۳ کلمه در old files/1، در اپ استفاده نشده) ·
#   deckهای «به‌زودی» در core/services/feature_flags.dart (Lukas منبع هر کدام را یکی‌یکی می‌فرستد)
#     ⏳ 2026-09-18: ÖSD C1 ✅ رسید و منتشر شد؛ درخواست باز بعدی = یکی از deckهای باقی‌مانده. بدون منبع تا انتشار ⇒ deck پنهان.
#     ⇒ تنها کار باز L.2؛ بعد از آن L.3 (تست RTL، آفلاین، آیکون/manifest، حریم خصوصی — README ✅ 2026-09-18).
# 📘 L.6 (از 2026-09-18): درس‌های گرامر کتاب‌های Lukas یکی‌یکی می‌رسند. شماره‌ی او ≠ شماره‌ی اپ ⇒ نگاشت در PLAN.md → L.6 (+ GRAMMATIK_MAP).
#   ⚠️ کپی‌رایت: هیچ جمله/تمرینی از کتاب کپی نمی‌شود — فقط موضوع؛ متن و مثال و تمرین از نو نوشته می‌شود.
#   رسیده: درس ۱ (Grammatik aktiv, Personalpronomen) ⇒ assets/data/grammatik/pronomen.json → `personalpronomen`. تمرین‌ها: ۳۴۲ = ۳۳۶ + ۶.
#   🧩 L.2e/G7 — ⚠️ تصمیم تازه‌ی Lukas (2026-09-18): گرامر ✅ → تمرین گرامر G7a–G7c ✅ → **انتشار** → G7d/G7e →
#     کلمه‌ها → تمرین کلمه‌ها. (تصمیم 2026-09-16 «تمرین‌ها قبل از انتشار» با این جایگزین شد.)
#     ✅ G7a (2026-09-16): ۳۳۶ تمرین منبع در هر درس — /grammatik/lektion/:slug/uebung
#     ✅ G7b (2026-09-16): آزمون سطح — /grammatik/quiz-niveau/:level (assets/data/grammatik_niveautest.json)
#     ✅ G7c (2026-09-16): تمرین از ۵۰۴ جمله‌ی مثال (models/beispiel_uebungen.dart) — نوبت درس = ۴ منبع + ۶ ساخته‌شده، مخلوط
#     باز: G7d ردمیتل · G7e ذخیره‌ی نتیجه‌ی آزمون (Lukas: بله → بخش آینده‌ی «دست‌یافته‌ها»)
#   L.2b: A1/A2 Wortschatz = جزو فاز کلمه‌ها؛ قبل از انتشار فقط چند کارت نمونه از هر نوع
#   Lukas: «منابع همه‌چیز با من، برنامه‌نویسی با تو» ⇒ برای محتوا (گرامر، deckها، …) منبع را از او بخواه.
#   ⛔ استثنا: کارت‌های کلمه را همیشه Claude طبق «old files Lukasalmani/Wort prompt» می‌سازد — تبدیل منابع Lukas رد شد (2026-09-16).
#   ⚠️ شناسه‌ی کارت منتشرشده در assets/vocab/ هرگز حذف/عوض نشود — لایتنر کاربر به آن اشاره می‌کند.
#     ✅ L.1b (2026-09-16): test/migration_test.dart hebt jede veröffentlichte DB-Fassung (2…6) mit echten Daten auf die aktuelle.
#     ✅ L.1a (2026-09-16): نگهبان CI (tool/vokab_ids_pruefen.dart) با فهرست سایت زنده مقایسه می‌کند ⇒ حذف = ساخت قرمز.
# 🌐 2026-09-16 L.3a — زبان شروع: پیش‌فرض انگلیسی، فقط روی دستگاه فارسی‌زبان فارسی.
#   تنها منبع قاعده: core/l10n/geraete_sprache.dart · انتخاب کاربر در Settings (ui_language) همیشه مقدم.
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
| 28b | **Profil & Konto (P)** — Zeilen in „Wo die Nutzerdaten liegen" | [→](#-wo-die-nutzerdaten-liegen-فاز-s-2026-09-15) |
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
```
screens/
  auswendiglernen_home_screen.dart [x]  — flat ListView (_learningDecks + _PruefungenDivider + _pruefungenDecks)؛ deckهای `hidden` فیلتر می‌شوند (2026-09-19)
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
  fragen_screen.dart          [x] (در lib/features/fragen/) — ۸ FAQ با InkWell expansion
  sozialmedien_screen.dart    [x] (در lib/features/sozialmedien/) — Telegram/Instagram/YouTube
controllers/
  settings_controller.dart    [x]  — AppSettings model (themeMode،ttsRate،currentLevel،...)
                                     SettingsNotifier AsyncNotifier، settingsProvider
  profil_controller.dart      [x]  — **P** `profilProvider` (AsyncNotifier، `speichern()`)، `archivUebersichtProvider`،
                                     `passwortNeuProvider` + `passwortWiederherstellungStarterProvider` (از `app.dart` دیده می‌شود)
widgets/
  profil_angaben_karte.dart   [x]  — **P.1** نام/تلفن/آدرس‌ها؛ `_AdresseDialog`؛ یک «ذخیره» = کل فرم
  profil_konto_karte.dart     [x]  — **P.2** `ProfilKontoKarte` (ورود/ثبت‌نام/فراموشی رمز/ایمیل/همگام/خروج) + `PasswortAendernKarte`
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
| `features/more/screens/settings_screen.dart` → `_SpeicherKarte` | zeigt diese Einladung unter «داده‌ی من» |
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
| `core/services/auth_service.dart` | **S.3 ✅** — einzige Stelle, die `supabase_flutter` kennt. ⚠️ **Kein Benutzername** (`profiles` gehört Root-in) und **kein `deleteAccount()`** (löscht `auth.users` und damit auch den Root-in-Bestand desselben Menschen). Gibt `AuthResult` zurück statt zu werfen; `AuthIssue` wird in der Oberfläche übersetzt, nicht hier |
| `supabase/vox_tables.sql` | **S.3 ✅** — `vox_backups`, eine Zeile je Konto. ⚠️ **Nicht** `backups` — die gehört Root-in und hat dieselbe `user_id` als Primärschlüssel; geteilt hieße: eine App überschreibt die Sicherung der anderen. `touch_updated_at()` zeichengleich zu `schema.sql` in Root-in — Änderung immer in BEIDEN Dateien |
| `features/more/widgets/profil_konto_karte.dart` → `ProfilKontoKarte` (bis P.2: `_KontoKarte` in settings_screen; `_kontoFehlerText` → `konto_texte.dart`) | **S.3 Schritt 2 ✅** — anmelden/registrieren/abmelden; nur sichtbar bei `kontoAktivProvider`. `AuthIssue` wird hier übersetzt (`_kontoFehlerText`). Noch **ohne** Cloud-Kopie — das ist Schritt 3 |
| `core/services/feature_flags.dart` | **L.2d** — deckهای «به‌زودی»: قبل از انتشار یا پر شوند یا `hidden` (نسخه‌ی نهایی دکمه‌ی بی‌محتوا ندارد) |
| `core/backup/cloud_abgleich.dart` | **S.3 Schritt 3** — holen → zusammenführen → nur bei Änderung hochladen; kennt kein Supabase |
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

### [2026-09-16] L.2c: Tabellen von „verb-sein"/„verb-haben" nicht darstellbar
- Die Quelle schreibt `columns` mal mit, mal ohne Überschrift der Beschriftungsspalte; DataTable verlangt
  gleich viele Zellen wie Spalten. `GrammatikTable.fromJson` vereinheitlicht, `istStimmig` schützt die Anzeige.

### [2026-09-16] L.1b: Index `user_categories_uid` war für drift unsichtbar
- In S.6 per rohem SQL angelegt ⇒ Schema-Vergleich hätte ihn als „überzählig" gemeldet und drift kannte ihn nicht.
  Jetzt `@TableIndex` (gleicher Name, gleiche Definition, keine neue Fassung).

### [2026-09-16] V.2: App-Start las jede Wortkarte einzeln
- `vokabular_controller.dart` lud beim Start alle Dateien aus `assets/vocab/` (im Browser je eine Anfrage) ⇒
  Grenze ~500 Wörter. Jetzt ein Wortindex + Einzelkarte beim Öffnen (siehe `tool/vokab_index.dart`).
- Nebenbei: Archiv-Karten zeigten in der Liste immer „Fach 1" (festes `box: 1` der Datei) — entfällt.
- ⚠️ Neuer Workflow mit `flutter analyze`/`test`/`build` ⇒ vorher `dart run tool/vokab_index.dart`, sonst
  fehlt das Asset `assets/vocab_index.json`.

### [2026-09-16] S.6: Umbenennen einer Liste kostete beim Abgleich Wörter
- Die id einer eigenen Liste war ihr Name ⇒ Umbenennen = „alte Liste weg"; Wörter, die ein anderes
  Gerät inzwischen in die alte Liste legte, verschwanden. Jetzt feste `uid` (DB v7, Vertrag v3) —
  siehe „Wo die Nutzerdaten liegen" → S.6

### [2026-09-15] S.5: Sicherung trug ~830 App-Wörter; Entfernungen kamen beim Zusammenführen zurück
- `Words.ausApp` (vom Seed gesetzt) + `Mitgliedschaften` (Ereignisse), Vertrag v2 — siehe „Wo die Nutzerdaten liegen"

### [2026-09-15] B-12: Sicherung verlor die B-10-Grammatikfelder eigener Wörter
- `user_state_repository.dart`: `regelmaessig`/`trennbar`/`grammatikDetail` in `_wortZuJson` und `anwenden()`
- ⚠️ Neue Spalte in einer Nutzer-Tabelle ⇒ im selben Commit die Fassade nachziehen

### [2026-09-15] B-11: App und Sicherung lasen verschiedene Ablagen
- Store (`vokabular_user_state.dart`) las noch SharedPreferences, die Fassade seit S.0b/S.0c drift;
  Einspielen leerte die alten Schlüssel ⇒ leerer Leitner/Listen in der App
- Store geht jetzt nur über die Fassade (`archivLesen()` …), `uebergangAbschliessen()` beim Laden,
  `neuLaden()` nach dem Einspielen; Tests in `test/vokabular_test.dart`

### [2026-09-15] Puzzling-Bruch in den Einstellungen (فاز S)
- `settings_screen.dart`: fünf rohe Buttons (`_SicherungKarte` aus S.2, `_KontoKarte` aus S.3
  Schritt 2) → `VoxButton.tonal/secondary/primary/text` + `VoxIconButton`
- Neu: `test/puzzling_buttons_test.dart` — die grep-Regel aus فاز B ist jetzt eine CI-Prüfung

### [2026-06-30] Phase 8 (جزئی): RevenueCat SDK کامل + Native Splash — ⛔ RevenueCat später entfernt (2026-09-13)
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

### L.5a [ایده، هنوز قطعی نیست — 2026-09-17]: صفحه‌ی پیشرفت (درصد) در VOX
- مشابه جدول‌ها/درصدهای Root-in، ولی **صفحه‌ی مستقل و مخصوص VOX** — کپی کد از Root-in ممنوع؛
  دو ریپو همیشه جدا (اصل ثابت `ways-of-working`)
- معیار دقیق پیشرفت (کلمه‌ها؟ گرامر؟ تمرین‌ها؟ کلی؟) و جای دقیق صفحه (داخل L.5d یا جدا) هنوز با Lukas مشخص نشده
- جزئیات کامل → PLAN.md → L.5a

### L.5b [باز — 2026-09-17]: ترجمه‌ی جمله‌به‌جمله در Lesen، از جمله اخبار
- زیر هر جمله‌ی متن خواندن (و بخش اخبار)، معنی‌اش نوشته شود — FA یا EN، بسته به `AppL10n.activeLang`
- محتمل‌ترین فایل‌های درگیر: `lib/features/lesen/screens/...`، هر ویجت رندر متن Lesen/اخبار
- جزئیات کامل → PLAN.md → L.5b

### L.5c [باز — 2026-09-17]: تبدیل همه‌ی محتوای آموزشی به تمرین، به‌شدت متنوع
- گسترش زیرساخت **G7** (فعلاً فقط گرامر: G7a–G7c ✅، G7d/G7e باز) به همه‌ی محتوا: Redemittel، Lesen،
  Hören، Auswendiglernen و بیشتر
- هدف: بیشترین تنوع نوع تمرین ممکن (چندگزینه‌ای، جفت‌کردن، درست/غلط، چیدن کلمه، جای‌خالی، شنیداری، …)
- اجرا بعد از تکمیل G7d/G7e برای گرامر (L.2e)
- جزئیات کامل → PLAN.md → L.5c

### L.5d [باز — 2026-09-17]: صفحه‌ی کامل اکانت کاربری
- یک صفحه‌ی مستقل: اطلاعات حساب + آرشیوها + سطح کاربر — فعلاً پخش در More/Settings
- جزئیات کامل → PLAN.md → L.5d

### L.5e [باز — 2026-09-17]: هر بخش محتوایی بعد از مطالعه یک آزمون دارد
- پوشش کامل، نه فقط گرامر: هر متن Lesen/اخبار بعد از خواندن آزمون دارد؛ الگوی G7a+G7b (تمرین هر درس +
  آزمون هر سطح) برای بقیه‌ی بخش‌ها هم تکرار می‌شود
- تفاوت با L.5c: L.5c = تنوع نوع تمرین، L.5e = هیچ بخشی بدون آزمون پایانی نماند
- جزئیات کامل → PLAN.md → L.5e

### L.5f [✅ 2026-09-20]: کامپوننت مشترک «کلیک روی کلمه» در کل اپ (ساخته شد — تفصیل: core/widgets/klick_wort_text.dart + wort_popup.dart بالا)
- رفتار یکسان همه‌جا: کلیک روی هر کلمه → پاپ‌آپ کوچک → کلیک روی پاپ‌آپ → `wort_seite_screen.dart` کامل
  باز می‌شود (چک معنی یا افزودن به لایتنر از همان‌جا)
- باید یک ویجت/کامپوننت مشترک باشد (اصل Component Isolation)، نه پیاده‌سازی جدا در هر صفحه؛ همه‌ی
  صفحاتی که کلمه نشان می‌دهند (Lesen، Hören، Redemittel، گرامر، جمله‌های مثال، …) باید همین را reference کنند
- محتمل‌ترین جای پیاده‌سازی: یک widget جدید در `core/widgets/` که popup + navigation به route کلمه را می‌سازد
- جزئیات کامل → PLAN.md → L.5f

### L.5g [باز — 2026-09-19]: ساختار دو لایه‌ی Lesen و اخبار (سطح · ترجمه‌ی زیر متن · پاپ‌آپ · تمرین)
- کل Lesen، نه فقط اخبار: سطح A1–C2 برای هر متن/خبر (اخبار RSS فعلاً بدون سطح: `news_screen.dart`)
- **لایه‌ی خودکار (پیش‌نویس)** (همه‌ی متن‌ها): ترجمه‌ی زیر متن FA/EN طبق `AppL10n.activeLang` (L.5b) + کلیک کلمه ⇒ پاپ‌آپ ⇒
  `wort_seite_screen.dart` (L.5f ✅ 2026-09-20: `KlickWortText` → `showWortPopup` → صفحه‌ی کلمه)
- **لایه‌ی دست‌ساز (پیش‌نویس)** (فقط متن‌های از قبل آماده): تمرین · کلمات مهم · آزمون (L.5e) · نکات گرامری متن — اختیاری، نبودش بخش را پنهان می‌کند
- ⛔ باز: منبع سطح برای اخبار خودکار + سرویس ترجمه‌ی جمله‌ها برای اخبار خودکار (با کد تنها ممکن نیست)
- ⛔⛔ **تصمیم مهم و باز، فقط با Lukas** (2026-09-19): (۱) چند متن آماده‌شده؟ (۲) از کجا می‌آیند؟ (۳) کدام قابلیت‌ها فقط‌مال
  همین متن‌های محدود است؟ (۴) کدام قابلیت‌ها مال همه‌ی متن‌هاست؟ — تقسیم «خودکار/دست‌ساز» بالا فقط پیش‌نویس است؛
  Claude باید بپرسد و حدس نزند
- جزئیات کامل → PLAN.md → L.5g

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
