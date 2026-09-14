# PLAN — VOX

> ⚠️ **2026-09-13 — Umbau zur reinen Web-App:** android/ios/macos/linux/windows, RevenueCat (Abos) und lokale Notifications wurden entfernt. VOX läuft nur noch als kostenlose Flutter-Web-App auf GitHub Pages (DB: drift + SQLite-WASM). Ältere Einträge unten beschreiben teils den früheren nativen Stand.
> ⚠️ **2026-09-13 — Habit/Routine entfernt, Root-in-Verlinkung.** VOX bleibt dauerhaft ein eigenes Repo (`github.com/lukasylilli/vox`), getrennt von Root-in (`github.com/lukasylilli/Root-in`, live unter `lukasylilli.github.io/Root-in/`) — bewusst KEIN Code-Merge, damit Nutzer, die nur die Routine-App brauchen, sie eigenständig nutzen können. In Selbstlernen ersetzt die Karte **„Routine"** die frühere „Habit Maker"-Karte und öffnet Root-in per Link in einem neuen Tab (`core/constants/app_links.dart` → `rootInUrl`, geöffnet über `core/utils/external_link_opener.dart`). Entfernt: `habit_maker_screen.dart`, `habit_stats_screen.dart`, `habit_day_selector_widget.dart`, `streak_chart_widget.dart`, `core/database/dao/habit_dao.dart`, alle Habit-Provider in `selbstlernen_controller.dart` und die „verknüpfte Gewohnheit"-Auswahl im Pomodoro-Timer (Pomodoro selbst bleibt unverändert als eigenständiger Fokus-Timer). Die Drift-Tabellen `Habits`/`HabitSessions` bleiben vorerst im Schema (kein Downgrade) — unbenutzt, entfernbar in einer künftigen Migration. ⚠️ **Lehre:** `package:web` darf nie ungeschützt importiert werden — bricht `flutter test` auf der VM, `flutter analyze` merkt es nicht. Bedingter Export nach Root-in-Vorbild (`external_link_opener_io.dart` / `_web.dart`).
> ⚠️ **2026-09-15 — Voll-Audit von Code + Daten (Claude, direkt über die GitHub-API).** Befunde, die die Planung ändern:
> **(1) Die `✓ `-Markierungen in `old files Lukasalmani/Wörter/*.txt` sind NICHT mehr die Wahrheit.** Gezählt: `assets/vocab/` enthält **87 Karten** (alle `schema: "3.0"`, kein kaputtes JSON) — davon **76 Verben**; markiert ist aber nur `✓ warten` (+ 3 Adjektive, 1 Nomen). 45 dieser Verbkarten stehen unmarkiert in den txt-Listen, 31 stehen dort gar nicht (sie stammen aus dem Dativ/Akkusativ-Deck, nicht aus dem alphabetischen Backlog). ⇒ **Neue Regel: einzige Wahrheit ist `assets/vocab/`; die `✓ `-Marken werden daraus abgeleitet (Sync-Skript), nicht mehr von Hand gesetzt.**
> **(2) Harte Obergrenze im Laufzeit-Pfad gefunden.** `lib/features/vokabular/controllers/vokabular_controller.dart` lädt beim Start **jede** Datei aus `assets/vocab/` über den `AssetManifest` und dekodiert sie vollständig in den Speicher. Bei 87 Karten unauffällig, bei einigen Tausend startet die Web-App nicht mehr sinnvoll. ⇒ **V.2 (`vocab.db`) ist keine „später"-Aufgabe mehr, sondern die Voraussetzung für die Automatisierung** (siehe فاز A).
> **(3) Doku-Drift korrigiert:** B-3 / R-1.1 sind im Code längst erledigt (`stripPreposition()` in `word_list_item.dart`) und werden hier auf ✅ gesetzt. Die README nennt unter „Selbstlernen" noch „Gewohnheiten, Streaks" — seit 2026-09-13 falsch (Habit entfernt, Root-in-Link).
> **(4) Entscheidung des Nutzers 2026-09-15:** Die Wörter werden **weiter alphabetisch** abgearbeitet (nicht nach Häufigkeit sortiert) — der Durchsatz kommt aus der Automatisierung, nicht aus der Reihenfolge.

# پلن کامل صفر تا انتشار اپ یادگیری آلمانی برای فارسی‌زبانان
# آپدیت: 2026-09-15

---

## 🎯 وضعیت فعلی (2026-09-15)
| فاز | وضعیت | خلاصه |
|-----|-------|-------|
| **G — Grammatik Vollausbau** | G1+G2 ✅ / G3–G8 باز | کاتالوگ ۹۳ موضوع + LektionScreen live (۴ درس واقعی)؛ نقشه: `GRAMMATIK_MAP.md` |
| **B — Buttons (Puzzling)** | ✅ | همه دکمه‌ها reference به `vox_button.dart`؛ ۰ دکمه خام؛ همه quiz options → VoxOptionButton |
| **L — L10n: زبان فقط از Settings** | ✅ | ۶ سوییچ حذف، Dual-Display صفر، AppL10n تنها منبع |
| **L2 — Massen-Lokalisierung** | ✅ | ۶۴۱→۴۱ رشته FA در UI (کاتالوگ ۵۳۷=۵۳۷)؛ باقی در L3 |
| **L3 — Content-Zweisprachigkeit** | ✅ | **همه محتواها FA+EN** (JSON + صفحات + دیتابیس)؛ audit ۰؛ کاتالوگ ۵۶۵=۵۶۵؛ helper AppL10n.loc؛ MemorizeItems.meaningEn (schema v2) |
| **V — Vokabular-DB (۲۵٬۰۰۰ کلمه)** | Stufen ۱–۵ ✅ · **۸۷ کارت** (۰٫۳٪ از ~۲۶٬۲۰۰) · گلوگاه = سرعت، نه کد | Pipeline کامل و سالم: SUPER-PROMPT v3.0 → `import_inbox/` → `tool/vokabular_import.dart` → اپ. از ۱۴ جولای تا ۱۵ سپتامبر (۲ ماه) فقط چند کلمه اضافه شد ⇒ **فاز A (خودکارسازی) باز شد.** باز: V.2 `vocab.db` (حالا **پیش‌شرط**، نه اختیاری) · اتصال Leitner به imLeitner · V.5 توزیع |
| ۱۶ — انتشار و QA نهایی | باز | آخرین فاز قبل از launch |

**قدم‌های بعدی (2026-09-15):** ⓪ **فاز S** — ذخیره‌سازی داده‌ی کاربر (S.1 ✅، S.0 بلاک) ① **فاز A** — A.1/A.2/A.3/A.5 ✅ · A.4 بلاک (مجوز Workflows در توکن) ② **V.2** `vocab.db` — قبل از اینکه تعداد کارت‌ها از چند صد بگذرد، وگرنه startup می‌شکند ③ G3–G6 (استخراج محتوای ۸۴ درس) ④ فاز ۱۶ launch/QA

---

## INHALTSVERZEICHNIS (فهرست مطالب)

| # | بخش | لینک |
|---|-----|------|
| 1 | اطلاعات کلی | [→](#اطلاعات-کلی) |
| 2 | Status Legend | [→](#status-legend) |
| 3 | خلاصه فازهای کامل | [→](#فاز-۰-تا-۱۵--زیرساخت-و-ویژگی‌های-اصلی-) |
| 4 | باگ‌های فعلی | [→](#️-باگ‌های-فعلی) |
| 5 | فاز R — Refactor & UX | [→](#فاز-r--refactor--ux-فاز-جاری--بعد-از-رفع-باگ‌ها) |
| 6 | Design System (DS) | [→](#فاز-ds--design-system--یک-بار-برای-همیشه) |
| 6b | فاز ARCH — Architecture Hub | [→](#فاز-arch--architecture-hub--زیرساخت-مرکزی-2026-07-04) |
| 6c | **فاز G — Grammatik Vollausbau** (G1 ✅) | [→](#فاز-g--grammatik-vollausbau-تمام-گرامر-زبان-آلمانی-g1-) |
| 6d | **فاز B — Buttons: Puzzling** ✅ | [→](#فاز-b--buttons-puzzling-prinzip--2026-07-07) |
| 6e | **فاز L — L10n: زبان فقط از Settings** ✅ | [→](#فاز-l--l10n-زبان-فقط-از-settings-step-1--audit--2026-07-07) |
| 6f | **فاز L2 — Massen-Lokalisierung** ✅ | [→](#فاز-l2--massen-lokalisierung-هیچ-fa-در-حالت-en-l2-ae--l2-f-باز-2026-07-07) |
| 6g | **فاز L3 — Content-Zweisprachigkeit** ✅ | [→](#فاز-l3--content-zweisprachigkeit-همه-محتواها-faen-l3-ad--e-باز-2026-07-07) |
| 6h3 | **فاز S — ذخیره‌سازی داده‌ی کاربر** (باز) | [→](#فاز-s--speicherung-der-nutzerdaten-باز-شد-2026-09-15) |
| 6h2 | **فاز A — خودکارسازی ورود کلمات** (باز) | [→](#فاز-a--automatisierung-der-worterfassung-باز-شد-2026-09-15) |
| 6h | **فاز V — Vokabular-DB (۲۵k)** (طراحی ✅) | [→](#فاز-v--vokabular-datenbank-آرشیو-بزرگ-۲۵۰۰۰-کلمه-طراحی-نهایی--پیاده‌سازی-باز-2026-07-08) |
| 7 | Phase 13 — Redemittel 1010 ✅ | [→](#phase-13--redemittel-1010--2026-07-04) |
| 8 | Phase 12 — Unregelmäßige Verben ✅ | [→](#phase-12--unregelmäßige-verben--2026-07-03) |
| 9 | Phase 11 — Verben mit Präp. ✅ | [→](#phase-11--verben-mit-präpositionen--2026-07-03) |
| 10 | Phase 10 — Trennbar ✅ | [→](#phase-10--trennbare--untrennbare-verben--2026-07-03) |
| 11 | Phase 9 — Reflexivverben ✅ | [→](#phase-9--reflexivverben--2026-07-03) |
| 12 | Phase 8 — انتشار | [→](#phase-8--انتشار-فاز-۱۶) |
| 13 | ترتیب اجرا | [→](#ترتیب-اجرا--phaseهای-بهینه) |
| 14 | فازهای تکمیل‌شده (آرشیو) | [→](#فازهای-تکمیل‌شده-آرشیو) |
| 15 | تصمیمات تکنیکی | [→](#تصمیمات-تکنیکی) |

---

## اطلاعات کلی
- نام اپ: VOX
- پروژه Flutter: vox
- پلتفرم هدف: iOS + Android
- زبان رابط: فارسی / انگلیسی (قابل تغییر در settings)
- زبان هدف: آلمانی
- رویکرد: آفلاین‌محور، بدون AI، parser متنی

---

## STATUS LEGEND
[x] = done  [ ] = planned  [~] = in progress  [!] = blocked

---

## فاز ۰ تا ۱۵ — زیرساخت و ویژگی‌های اصلی ✅
(همه فازهای اولیه کامل شده‌اند — جزئیات در آرشیو پایین)

---

## ⚠️ باگ‌های فعلی

### B-1: خطای Flutter — color + decoration در Container ✅
- وضعیت: رفع شد (2026-06-29)

### B-2: خطای SQLite — UNIQUE constraint در words ✅
- وضعیت: رفع شد (2026-06-29)

### B-3: Wortschatz — نمایش کلمه با حرف اضافه در لیست ✅
- مشکل: کلمات Präpositionen مثل "das Engagement für" در لیست Wortschatz نمایش داده می‌شدند
- رفع: `stripPreposition(german)` در `word_list_item.dart` (۲۱ حرف اضافه) — در لیست فقط "das Engagement"؛ detail view کامل می‌ماند
- وضعیت: **رفع شده — تأیید با خواندن کد در Audit 2026-09-15** (قبلاً اشتباهاً «باز» ثبت شده بود)

### B-4: Grammatik home — لینک به صفحه لیست به جای گرامر ✅
- مشکل: `_GrammarSection` tiles به list screens می‌رفتند (konnektoren، dativ، praep)
- رفع: لینک‌ها به grammar screens تغییر کردند + NVV اضافه شد
- وضعیت: رفع شد (2026-06-29)

---

## فاز R — Refactor & UX (فاز جاری — بعد از رفع باگ‌ها)

### R-1: Wortschatz — نمایش پاک کلمه در لیست
- [x] R-1.1 ✅ (تأیید 2026-09-15) `word_list_item.dart`: `german` با `stripPreposition(german)` نمایش داده می‌شود
  - حرف اضافه‌ها: `für`, `auf`, `an`, `über`, `mit`, `von`, `zu`, `bei`, `nach`, `aus`, `in`, `um`
  - اگر `german` = "das Engagement für" → display: "das Engagement"
  - detail view: همه اطلاعات شامل حرف اضافه باقی می‌ماند
- [ ] R-1.2 `word_detail_screen.dart`: کلیک روی کلمه → همه اطلاعات:
  - معنا (FA + EN)، مثال‌ها، صدا (TTS)
  - دکمه Leitner، دکمه دسته‌بندی، دکمه favorit، گرامر

### R-2: Auswendiglernen — Präpositionen list باید full form نشان دهد
- [ ] R-2.1 لیست "Nomen · Verb · Adjektiv + Präpositionen": فرمت: `lemma · حرف_اضافه`
  - مثال: "abhängen · abhängig · die Abhängigkeit von"
  - این فرمت را تغییر نده — کاربر می‌خواهد حرف اضافه را در لیست ببیند
- [ ] R-2.2 کلیک روی هر آیتم → detail view کامل:
  - معنا (FA + EN)، مثال‌ها، صدا (TTS)
  - دکمه Leitner، دسته‌بندی، favorit

### R-3: Auswendiglernen — ساختار جدید صفحه اصلی
- [ ] R-3.1 حذف section headers (Verben، Satzbau und Konnektoren، Wortschatz، Redemittel)
- [ ] R-3.2 فقط یک لیست ساده از deck‌ها:
  ```
  • Satzkonnektoren
  • Dativ und Akkusativ Verben
  • Nomen-Verb-Verbindungen (NVV)
  • Nomen · Verb · Adjektiv + Präpositionen
  • Unregelmäßige Verben
  • Relativsatz
  • Redewendungen (کارت‌های شخصی)
  • ... (بقیه deck‌ها)
  ──────────────────────────
  PRÜFUNGEN (عنوان جداکننده)
  • Goethe B2 Redemittel
  • ÖSD B2 Redemittel
  • ÖSD C1 Redemittel
  • 1010 Redemittel
  • ...
  ```
- [ ] R-3.3 deck‌های "coming soon" را نشان بده ولی غیرفعال (قفل)

### R-3b: Grammatik — لینک‌های موضوعی ✅ (2026-06-29)
- `grammatik_home_screen.dart` → بخش "بخش‌های ویژه گرامر":
  - Konnektoren → `/konnektoren/grammar` ✅
  - Dativ/Akkusativ → `/dativ-verben/grammar` ✅
  - NVV → `/nvv/grammar` ✅ (صفحه جدید ساخته شد)
  - Präpositionen → `/praepositionen/grammar` ✅ (صفحه جدید ساخته شد)
- **اصل**: Grammatik home فقط ارجاع می‌دهد — هر صفحه گرامر در feature folder خودش است

### R-3c: Prüfungen — بخش تمرین‌های موضوعی ✅ (2026-06-29)
- `pruefungen_home_screen.dart` → بخش "تمرین‌های موضوعی" اضافه شد:
  - Konnektoren → `/konnektoren/quiz` ✅
  - Dativ/Akkusativ → `/dativ-verben/quiz` ✅
  - NVV → `/nvv/quiz` ✅
  - Präpositionen → `/praepositionen/quiz` ✅
- همه quiz routes حالا خودشان داده را بارگذاری می‌کنند اگر `extra` null باشد (Consumer loader)
- **اصل**: Prüfungen فقط ارجاع می‌دهد — هر quiz در feature folder خودش است

### R-4: Filter / Sort UI — یکپارچه در همه صفحات
**هدف:** همه صفحات محتوا یک ظاهر یکسان دارند، ولی گزینه‌های فیلتر به محتوای همان صفحه تعلق دارند.
**تعداد کشوها**: نامحدود — هر صفحه تعداد کشوهایی که نیاز دارد را به `FilterAccordion` می‌دهد.

**ساختار عمودی هر صفحه:**
```
┌─────────────────────────────────┐
│  [🔍 SearchBar                ] │  ← همیشه اول
│  [📝 Prüfung]  [📖 Grammatik] │  ← دکمه‌های ثابت (اگر موجود)
│  ┌─ Niveau ──────────────────┐  │
│  │  [A1] [A2] [B1] [B2] ... │  │  ← کشو ۱ (accordion)
│  └────────────────────────────┘  │
│  ┌─ Art ─────────────────────┐  │
│  │  [Nullposition] [Nebensatz│  │  ← کشو ۲ (محتوا از صفحه)
│  └────────────────────────────┘  │
│  ┌─ Thema ────────────────────┐  │  ← کشو ۳ (اگر مرتبط)
│  └────────────────────────────┘  │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  │
│  [نتایج فیلترشده]               │
└─────────────────────────────────┘
```

**⚠️ اصل مهم — گزینه‌های فیلتر باید با محتوای صفحه تطابق داشته باشند:**

| صفحه | کشو ۱ (Niveau) | کشو ۲ (Art/Kasus/...) | کشو ۳ |
|------|----------------|------------------------|--------|
| Konnektoren | A1 A2 B1 B2 C1 | Nullposition، Nebensatz، Hauptsatz، Adverbial | Semantik (kausal، konzessiv، temporal...) |
| Dativ Verben | A1 A2 B1 B2 | Dativ، Akkusativ | — |
| NVV | A1 A2 B1 B2 C1 | — | Thema (Arbeit، Gesellschaft...) |
| Präpositionen | A1 A2 B1 B2 C1 | an، auf، für، mit، über، von، zu... | Verb/Nomen/Adjektiv |
| Wortschatz | A1 A2 B1 B2 C1 | Verb، Nomen، Adjektiv، Konnektor... | — |

**ویژگی‌های فیلتر:**
- Multi-select (ترکیبی): می‌توان A1 + B2 + Nullposition همزمان انتخاب کرد
- Accordion کشویی: باز/بسته با animation
- وضعیت انتخاب: chip‌های فعال زیر accordion
- دکمه "پاک کردن همه" وقتی فیلتری فعال است

**⚠️ اصل component isolation:**
- `filter_accordion.dart` فقط ظاهر و رفتار کشو را می‌داند — هیچ چیز از محتوا نمی‌داند
- هر Screen محتوای کشوها را به‌عنوان `List<FilterOption>` از بیرون به `FilterAccordion` می‌دهد
- هیچ Screen‌ای نباید کد ظاهر دکمه‌ها را درون خودش داشته باشد

- [ ] R-4.1 `core/widgets/filter_accordion.dart` — کامپوننت جدید
  - params: `label:String`، `options:List<FilterOption>`، `selected:Set<String>`، `onChanged`
- [ ] R-4.2 `core/widgets/filter_chip_bar.dart` — نمایش فیلترهای فعال + پاک کردن
- [ ] R-4.3 اعمال در: Konnektoren، NVV، Dativ Verben، Präpositionen، Wortschatz
  - هر Screen فقط `FilterOption`‌های خودش را تعریف می‌کند و به widget می‌دهد

### ⭐ اصل معماری پایه: Component Isolation (ارجاع‌دهی)
> این یکی از ارکان اصلی معماری اپ است. **هر Session باید این را رعایت کند.**

**قانون:** هیچ Screen‌ای اجازه ندارد کد ظاهر (رنگ، شکل، سایز، padding) یک کامپوننت قابل ارجاع را درون خودش داشته باشد.

**درست:**
```dart
// در Screen فقط استفاده می‌کنیم:
VoxButton.primary(label: 'ذخیره', onPressed: _save)
FilterAccordion(label: 'Niveau', options: [FilterOption('A1'), FilterOption('B2')])
```

**غلط:**
```dart
// در Screen کد ظاهر نداریم:
ElevatedButton(
  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: ...),
  child: Text('ذخیره'),
)
```

**فایل‌های کامپوننت (تنها مکان کد ظاهر):**
- `core/widgets/vox_button.dart` — تمام انواع دکمه
- `core/widgets/vox_badge.dart` — تمام انواع badge
- `core/widgets/filter_accordion.dart` — کشوی فیلتر
- `core/widgets/filter_chip_bar.dart` — نمایش فیلترهای فعال
- `core/theme/app_decorations.dart` — BoxDecoration‌های مشترک
- `core/constants/app_colors.dart` — رنگ‌ها
- `core/widgets/article_badge.dart` — badge آرتیکل (der/die/das)

### R-5: دکمه‌ها و UI یکپارچه (Design System)
- [x] R-5.1 `core/widgets/vox_button.dart` ✅ (2026-07-07 — فاز B کامل، پایین را ببین)
- [x] R-5.2 `core/widgets/vox_badge.dart` — انواع badge (level، type، article) ✅
- [x] R-5.3 `core/theme/app_decorations.dart` — BoxDecoration‌های مشترک ✅

### فاز B — Buttons: Puzzling-Prinzip ✅ (2026-07-07)
> خواسته کاربر: **همه‌چیز در اپ فقط از «صفحه دکمه» استفاده می‌کند** — هیچ screen ای
> کد دکمه ندارد (reference نه کپی). و دکمه‌ها روی **System-Widgets** متریال ساخته
> شوند تا با هر آپدیت فریمورک/پلتفرم خودکار به‌روز شوند (نه شکل دستی‌کشیده).
> منبع طراحی: `old files Lukasalmani/1/Button` — نسخه «اجزای رسمی» (buttonStyle های سیستمی).

- [x] B.1 `vox_button.dart` بازنویسی کامل — تنها منبع همه دکمه‌ها:
      · VoxButton: primary(Filled) · tonal(Filled.tonal/Soft) · secondary(Outlined) ·
        text(Ghost) · success(سبز) · destructive(قرمز پر) · destructiveOutlined(قرمز خط) ·
        header · small — با size(S/M/L مثل controlSize) + expand + **loading** + tooltip
      · VoxIconButton: plain/filled/tonal/outlined (سازنده‌های سیستمی IconButton.*) +
        iconSize/padding/color + isSelected/selectedIcon (تاگل سیستمی M3)
      · VoxFab / VoxFab.extended
      · VoxOptionButton: گزینه آزمون — idle/selected/correct/wrong (سبز/قرمز مرکزی)
      · قبلاً VoxButton.small با InkWell+Container دستی بود → الان System-tonal ✂️
- [x] B.2 کل اپ sweep شد — **۰ دکمه خام در features**:
      · ~۵۵ Label-Button (Filled/Outlined/Text) → VoxButton.* (همه styleFrom های inline حذف)
      · ۵۲ IconButton → VoxIconButton · ۶ FAB → VoxFab
      · جفت‌های سبز/قرمز (leitner، memorize) → success/destructiveOutlined
      · دیالوگ‌ها (categories، books، habit) → text/primary/destructive
      · CTA های fromHeight(52) → size: large + expand
      · دکمه‌های دستی quiz (grammar، konnektoren، dativ، reflexiv، trennbar) → VoxOptionButton
      · vorlagen: snackbar دستی → VoxSnackBar.copied
      · core/widgets: grammar_link + quiz_launch حالا داخلاً VoxButton اند
- [x] B.3 flutter analyze: No issues ✅
- [x] B.4 ✅ (2026-07-07) گزینه‌های آزمون ListTile-based (nvv، praep، redemittel، unregelm، verb-praep)
      → VoxOptionButton (idle/selected/correct/wrong). حالا هر ۱۱ quiz screen از VoxOptionButton
      استفاده می‌کنند — ۰ ListTile گزینه باقی ماند.
- [~] B.4-alt باقی‌مانده (بعداً): Word-Chips (wortstellung، dativ) → vox_chip؛ قدیمی:
      RadioListTile) → VoxOptionButton برای یکدستی کامل؛ Word-Chips (wortstellung، dativ) → vox_chip
- **قانون از این به بعد**: دکمه جدید = فقط reference به vox_button.dart؛
  `grep -rE 'IconButton\(|TextButton|OutlinedButton|FilledButton|FloatingActionButton' lib/features`
  باید همیشه ۰ نتیجه غیر-Vox بدهد.

### R-6: دوزبانه — Audit کامل (FA + EN) ✅ (2026-06-30)
**هدف:** همه متن‌های app قابلیت نمایش در هر دو زبان FA و EN دارند

- [x] R-6.1 بررسی `app_l10n.dart` — همه کلیدها موجود در FA و EN (100+ keys)
- [x] R-6.2 بررسی `auswendiglernen_home_screen.dart` + memorize_card_widget.dart
- [x] R-6.3 بررسی `konnektoren_home_screen.dart` + همه lesen screens
- [x] R-6.4 بررسی `dativ_verben_*` screens — همه برچسب‌ها
- [x] R-6.5 بررسی `nvv_*` screens — همه برچسب‌ها
- [x] R-6.6 بررسی `praepositionen_*` screens — همه برچسب‌ها
- [x] R-6.7 بررسی `grammatik_*` screens — همه برچسب‌ها (exercise + quiz + lesson)
- [x] R-6.8 بررسی `leitner_*` screens + leitner_add_button.dart + flash_card_widget.dart
- [x] R-6.9 بررسی `pruefungen_*` screens — همه برچسب‌ها
- [x] R-6.10 بررسی `selbstlernen_*` screens، sprechen، schreiben stubs
- [x] R-6.11 `home_screen.dart` + core widgets (vox_error_widget، grammar_link_button، quiz_launch_button)
- [x] R-6.12 `settings_screen.dart` + more screens (import، subscription، sozialmedien)
- ⚠️ Dynamic strings با $variable intentionally left — نیاز به ICU system جداگانه

### R-7: جداسازی محتوا از UI (Content Files)
**هدف:** هر موضوع محتوایی فایل داده مستقل دارد — بدون نیاز به لمس UI برای آپدیت محتوا

- [ ] R-7.1 `assets/data/konnektoren_data.json` — ✅ موجود — مستقل از UI
- [ ] R-7.2 `assets/data/dativ_akkusativ_data.json` — ✅ موجود
- [ ] R-7.3 `assets/data/nvv_data.json` — ✅ موجود
- [ ] R-7.4 `assets/data/praepositionen_data.json` — ✅ موجود
- [x] R-7.5 `assets/data/redemittel_goethe_b2.json` — ✅ ۶۱ عبارت (2026-07-04)
- [x] R-7.6 `assets/data/redemittel_oesd_b2.json` — ✅ ۱۲۱ عبارت (2026-07-04)
- [ ] R-7.7 `assets/data/redemittel_oesd_c1.json` — [ ] باید ساخته شود
- [x] R-7.8 `assets/data/redemittel_1010.json` — ✅ ۹۰۸ عبارت (2026-07-04)
- [ ] R-7.9 `lib/core/content/content_registry.dart` — ثبت همه منابع محتوا + seed

---

## فاز ۱۶ — انتشار و QA نهایی [ ]
- [ ] 16.1 تست دستی iOS Simulator
- [ ] 16.2 تست دستی Android Emulator
- [ ] 16.3 تست RTL فارسی همه صفحات
- [ ] 16.4 تست آفلاین (airplane mode)
- [ ] 16.5 آیکون 1024×1024 در assets/images/app_icon.png
- [ ] 16.6 dart run flutter_launcher_icons
- [ ] 16.7 dart run flutter_native_splash:create
- [ ] 16.8 RevenueCat API keys واقعی در main.dart
- [ ] 16.9 App Store Connect + Google Play metadata
- [ ] 16.10 flutter build ios --release + flutter build appbundle --release
- [ ] 16.11 TestFlight + internal Android test track
- [ ] 16.12 submit review

---

## ترتیب اجرا — Phase‌های بهینه

> **چرا این ترتیب؟** هر phase پایه phase بعدی است. Design System باید اول باشد چون همه widgets به آن وابسته‌اند. Filter UI بعد از Design System می‌آید. محتوا و audit آخر می‌آیند چون به کد ثابت نیاز دارند.

### Phase 1 — باگ‌های فوری ✅ (2026-06-29)
- [x] B-1: Container color+decoration → رفع شد
- [x] B-2: SQLite UNIQUE constraint → رفع شد
- [x] B-3b: Grammatik home links → رفع شد
- [x] B-3c: Prüfungen topic quizzes → رفع شد
- [x] B-3: Wortschatz word display — `stripPreposition()` در `word_list_item.dart`

### Phase 2 — Design System ✅ (2026-06-29)
- [x] `core/widgets/vox_button.dart` — primary، secondary، small، text، header، VoxIconButton
- [x] `core/widgets/vox_badge.dart` — level، wordType، colored
- [x] `core/theme/app_decorations.dart` — card، cardSolid، cardGradient، chip، headerStrip، sectionHeader، iconCircle، infoBanner
- [x] `word_list_item.dart` → `_LevelChip` ersetzt durch `VoxBadge.level`

### Phase 3 — Filter Components ✅ (2026-06-29)
- [x] `core/widgets/filter_accordion.dart` — label، options، selected، onChanged، animation
- [x] `core/widgets/filter_chip_bar.dart` — activeFilters Map، onRemove، onClearAll

### Phase 4 — Content Screens با Filter جدید
> وابسته به Phase 3
- [x] R-1: Wortschatz word display fix (strip preposition)
- [x] R-4.3: اعمال Filter در Konnektoren ✅ (2026-06-29)
- [x] R-4.3: اعمال Filter در Dativ Verben ✅ (2026-06-29)
- [x] R-4.3: اعمال Filter در NVV ✅ (2026-06-29)
- [x] R-4.3: اعمال Filter در Präpositionen ✅ (2026-06-29)
- [x] R-4.3: اعمال Filter در Wortschatz ✅ (2026-06-29)

### Phase 5 — Auswendiglernen Restructure ✅ (2026-06-29)
- [x] R-3.1: حذف section headers (Verben، Satzbau، Wortschatz، Redemittel)
- [x] R-3.2: لیست flat + جداکننده "PRÜFUNGEN" + Redemittel exam-prep در انتها
- [x] R-3.3: coming-soon decks نشان داده می‌شوند با lock icon
- [ ] R-2: Präpositionen Auswendiglernen cards — full form (lemma · حرف‌اضافه) — future

### Phase 6 — Data & Content Files ✅ (2026-06-29)
- [x] R-7.5 redemittel_goethe_b2.json — ✅ ۶۱ عبارت واقعی (Vortrag + Diskussion) (2026-07-04)
  - deck فعال در Auswendiglernen → `/redemittel-goethe-b2`
  - صفحه generic جدید: `redemittel_exam_list_screen.dart` (برای ÖSD B2/C1 هم استفاده می‌شود)
  - quiz + detail از صفحات 1010 بازاستفاده می‌شوند (extra pass)
- [x] R-7.6 redemittel_oesd_b2.json — ✅ ۱۲۱ عبارت واقعی در ۲۰ بخش (2026-07-04)
  - منبع: PDF فارسی ÖSD B2 (متن خراب OCR — عبارات استاندارد بازسازی شدند)
  - بخش‌ها: Zustimmen، Meinung، Zweifel، Widersprechen، Vor/Nachteile، Vermutungen،
    Beschwerdebrief (۴ بخش)، Meinungstext A/B (۴ بخش)، Mündlich 1–3 (۶ بخش)
  - deck فعال: flag `deck.oesd_b2` → live · route `/redemittel-oesd-b2`
  - همان RedemittelExamListScreen + quiz/detail بازاستفاده (مثل Goethe B2)
  - example fields خالی (منبع مثال ندارد) — detail screen conditional است ✓
  - distractors: خودکار از هم‌بخشی‌ها ساخته شدند (برای quiz)
- [x] R-7.7 redemittel_oesd_c1.json — ۶ entry، schema کامل
- [x] R-7.8 redemittel_1010.json — ۹۰۸ عبارت، schema کامل با fill_blank + distractors ✅ (2026-07-04)
- [x] R-7.9 content_registry.dart — مرجع متمرکز همه منابع محتوا
- [x] RedemittelItem model + controller (4 FutureProviders) ✅

### Phase 7 — Bilingual Audit ✅ (2026-06-30)
> بعد از Phase 2-4 (چون badge/button ممکن است labels داشته باشند)
- [x] R-6: بررسی کامل همه صفحات برای FA+EN (~45 فایل، 100+ کلید localization)

### فاز DS — Design System — یک بار برای همیشه
> هدف: هر کامپوننت UI یک فایل اختصاصی دارد.
> وقتی بعداً style را عوض کنی → فقط یک فایل تغییر می‌کند → کل اپ یک شکل می‌شود.

#### DS-1: Tokens (فایل‌های stub آماده شده — 2026-07-04)
```
lib/core/constants/
  app_colors.dart        [x]  LIVE — رنگ فعلی (کار می‌کند)
  app_sizes.dart         [x]  LIVE — سایز فعلی (کار می‌کند)
  vox_colors.dart        [ ]  stub — نسل بعدی: CEFR colors، register، semantic
  vox_typography.dart    [ ]  stub — همه TextStyle tokens
  vox_icons.dart         [ ]  stub — VoxIcons.quiz، .grammar، .play، ...

lib/core/theme/
  app_theme.dart         [x]  LIVE
  app_decorations.dart   [x]  LIVE
  vox_animations.dart    [ ]  stub — VoxDurations، VoxCurves، VoxTransitions
```

#### DS-2: Components (فایل‌های موجود — کامل)
```
lib/core/widgets/
  vox_button.dart        [x]  LIVE — primary، secondary، small، text، header، icon، fab
  vox_badge.dart         [x]  LIVE — level، wordType، article variants
  article_badge.dart     [x]  LIVE — der/die/das pill badge
  filter_accordion.dart  [x]  LIVE — filter group with chips + animation
  filter_chip_bar.dart   [x]  LIVE — active filter chips row
  vox_error_widget.dart  [x]  LIVE — compact + full error state
  vox_loading_widget.dart[x]  LIVE — shimmer + label loading
  audio_play_button.dart [x]  LIVE — TTS toggle
  leitner_add_button.dart[x]  LIVE — add to Leitner
  grammar_link_button.dart[x] LIVE — navigate to grammar
  quiz_launch_button.dart[x]  LIVE — navigate to quiz
  global_search_bar.dart [x]  LIVE — global search icon (AppBar only)
```

#### DS-3: Components (فایل‌های stub — 2026-07-04 ساخته شدند)
```
lib/core/widgets/
  vox_search_field.dart  [ ]  stub — per-screen search input (replaces inline TextFields)
  vox_list_tile.dart     [ ]  stub — VoxListTile، VoxPhraseListTile، VoxDeckListTile، ...
  vox_section_header.dart[ ]  stub — .simple()، .withIcon()، .collapsible()، .labeled()
  vox_empty_state.dart   [ ]  stub — .noResults()، .noData()، .comingSoon()، .error()
  vox_card.dart          [ ]  stub — VoxCard، VoxGradientCard، VoxInfoCard، VoxDetailCard
  vox_chip.dart          [ ]  stub — VoxCefrChip، VoxRegisterChip، VoxTopicChip، ...
  vox_dialog.dart        [ ]  stub — .confirm()، .input()، .quizResult()، .comingSoon()
  vox_divider.dart       [ ]  stub — VoxDivider، VoxLabeledDivider، VoxSectionSpacer
  vox_bottom_bar.dart    [ ]  stub — VoxBottomBar، VoxWordDetailBar، VoxQuizActionBar
  vox_text_field.dart    [ ]  stub — VoxTextField، VoxMultilineField، VoxClozeField
  vox_snack_bar.dart     [ ]  stub — .show()، .success()، .error()، .comingSoon()، .copied()
  vox_app_bar.dart       [ ]  stub — VoxListAppBar، VoxDetailAppBar، VoxQuizAppBar
  vox_progress.dart      [ ]  stub — VoxQuizProgressBar (۱۲ quiz screen)، VoxStepDots،
                                      VoxCompletionRing، VoxLeitnerBoxBar، VoxStreakCounter

lib/core/constants/
  vox_colors.dart        [ ]  stub — همه رنگ‌ها: primary، section، CEFR، article، register،
                                      wordType، semantic، quizFeedback — یک‌جا همه رنگ‌ها
```

#### DS-4: نحوه استفاده (بعد از نوشتن کد)
هر stub بعد از نوشتن کد باید در همه صفحاتی که inline همان کامپوننت دارند جایگزین شود.
**اولویت پیاده‌سازی:**
1. `vox_colors.dart` — اول tokens، بعد widgets (پایه همه چیز)
2. `vox_search_field.dart` — بیشترین تکرار (۹ صفحه)
3. `vox_progress.dart` — VoxQuizProgressBar (۱۲ quiz screen، بالاترین duplication)
4. `vox_chip.dart` — CEFR chips همه جا استفاده می‌شود
5. `vox_empty_state.dart` — هر list screen یکی دارد
6. `vox_snack_bar.dart` — ساده‌ترین refactor
7. `vox_dialog.dart` — quiz result dialogs یکسان شوند
8. `vox_section_header.dart` — بعد از قبلی‌ها
9. بقیه در آینده

### فاز ARCH — Architecture Hub — زیرساخت مرکزی (2026-07-04)
> هدف: هر سرویس/ابزار مرکزی یک فایل دارد — Screens فقط import می‌کنند.
> مکمل فاز DS: آنجا UI مرکزی شد، اینجا Logic/Infra مرکزی می‌شود.

#### ARCH-A: Skeleton ✅ (2026-07-04) — ۹ stub ساخته شد
```
lib/core/config/
  app_env.dart            [ ]  stub — env/secrets (معادل .env) — RevenueCat keys، RSS URL
lib/core/network/
  api_client.dart         [ ]  stub — تنها نقطه ورود HTTP (timeout، headers، ApiException)
lib/core/utils/
  formatters.dart         [ ]  stub — ارقام فارسی (۹۰۸)، تاریخ، درصد، مدت — الان hardcoded!
lib/core/services/ (جدید)
  feature_flags.dart      [ ]  stub — comingSoon/live/premium مرکزی — الان در deck lists hardcoded
  cache_service.dart      [ ]  stub — TTL cache برای RSS/remote (offline-first fallback)
  app_logger.dart         [ ]  stub — logging مرکزی (debug verbose، release silent)
  permission_service.dart [ ]  stub — notifications الان، microphone/speech برای Sprechen
test/helpers/
  mock_data_factory.dart  [ ]  stub — fixture مرکزی همه model‌ها + in-memory db
.github/workflows/
  ci.yml                  [ ]  stub — analyze + test هر push — ⚠️ اول git init لازم است
```
**معادل‌های موجود (چیزی نساختیم):** main.dart، pubspec.yaml، Riverpod (di/store)،
app_router+app_routes، app_database، subscription_service (auth)، app_l10n (i18n)،
app_theme+tokens، widget_test. **N/A:** AuthInterceptor، cryptoUtils، JSBridge (بدون نیاز فعلی).

#### ARCH-B: Implementation — ترتیب وابستگی ✅ B1–B11 (2026-07-04)
- [x] B1  `vox_colors.dart` — LIVE — CEFR/register/article/wordType/quiz tokens
      متصل شد: vox_badge، ۹ صفحه detail/list، ۳ home-screen level lists
- [x] B2  `formatters.dart` — LIVE — faDigits، countLabel، outOf، percent، relativeDate، timer
      متصل شد: ۱۱ صفحه (count labels + quiz result strings)
- [x] B3  `app_env.dart` — LIVE — RevenueCat keys via --dart-define (main.dart پاک شد)
- [x] B4  `app_logger.dart` — LIVE — AppLogger(tag) + loggerProvider
- [x] B5  `feature_flags.dart` — LIVE — همه ۲۳ فلگ deck/feature
      متصل شد: auswendiglernen decks (enum _Status حذف شد) + content_registry (isReady getter)
- [x] B6  `cache_service.dart` — LIVE — file-based TTL + getStale (offline fallback)
- [x] B7  `api_client.dart` — LIVE — ApiException typed + logging
      متصل شد: rss_service (cache→network→stale) + lesen_controller (rssServiceProvider)
- [x] B8  `permission_service.dart` — LIVE — notifications (mic/speech برای Sprechen آماده)
- [x] B9  `vox_search_field` — LIVE — متصل شد: **۱۱ list screen** (۹ template + ۲ redemittel)
- [x] B10 `vox_progress` (VoxQuizProgressBar + VoxStepDots) + `vox_empty_state` — LIVE
      متصل شد: **۱۱ quiz screen** progress + ۲ empty state
- [x] B11 `vox_snack_bar` + `vox_dialog` (quizResult/confirm/info) + `vox_chip`
      (VoxRegisterDot + VoxCountPill) — LIVE
      متصل شد: comingSoon snackbar + **۹ quiz result dialog** + redemittel chips
- [ ] B12 `mock_data_factory` + unit tests + git init + CI فعال — بعدی

#### ARCH-C: Integration — اتصال Feature‌ها به مرکز ✅ عمده (2026-07-04)
> از طریق B9–B11 انجام شد — هر الگوی تکراری با نسخه مرکزی جایگزین شد:
- [x] Suchfelder: konnektoren، dativ، nvv، praepositionen، reflexiv، trennbar،
      verb_praep، unregelm، wortschatz، redemittel_1010، redemittel_exam
- [x] Quiz-Progress: همان ۹ + grammatik + cloze + exam_simulation
- [x] Result-Dialoge: ۹ quiz (redemittel، unregelm، reflexiv، trennbar، verb_praep،
      konnektoren، dativ، praepositionen، nvv)
- [x] رنگ‌ها: CEFR/register switches حذف شدند (۱۲ مکان → VoxColors)
- [x] Flags: comingSoon مرکزی شد
- [ ] باقی‌مانده (بعدی): vox_list_tile، vox_card، vox_app_bar، vox_section_header،
      vox_bottom_bar، vox_text_field در صفحات قدیمی‌تر (leitner، hoeren، lesen، more)

#### استپ‌های stub جدید (2026-07-04 — کد بعداً):
```
lib/core/utils/
  debouncer.dart      [ ]  stub — search-as-you-type debounce (۹۰۸ آیتم!)
  validators.dart     [ ]  stub — form validation مرکزی (add_word، import، habit)
  extensions.dart     [ ]  stub — StringX.stripPreposition، ContextX.cs/tt، ListX
lib/core/services/
  backup_service.dart [ ]  stub — export/import کل داده کاربر (Leitner، کلمات، عادت‌ها)
```

#### استراتژی Integration (قانون برای همه صفحات آینده)
- صفحات جدید (Profile، Category، Product...) از روز اول **فقط import** می‌کنند:
  `VoxButton.primary(...)` · `VoxColors.cefrB2` · `Formatters.faDigits(n)` · `FeatureFlags.isLive(key)`
- **هرگز** local duplicate: رنگ، TextStyle، فرمت ارقام، دکمه، dialog درون screen تعریف نمی‌شود
- تغییر یک فایل مرکزی → کل اپ یکجا آپدیت می‌شود (همان اصل ۱ — Component Isolation)
- مرجع‌ها: PLAN.md (این فاز) + PROJECT_MAP.md (بخش Architecture Hub + Design System)

### Phase 14 — Modalverben ✅ (2026-07-04)
> دو خروجی از یک قلم: deck فلش‌کارتی + موضوع گرامری A1–C2

- [x] 14.1 `assets/data/modalverben_data.json` — ۷ فعل (können، müssen، dürfen، wollen،
      sollen، mögen، möchten) با صرف کامل Präsens/Präteritum، همه زمان‌ها
      (Perfekt، Ersatzinfinitiv، Plusquamperfekt، Futur I، Konjunktiv II)،
      معنی fa+en، مثال با برچسب زمان، نکته
- [x] 14.2 `assets/data/modalverben_grammar.json` — ۹ بخش سطح‌بندی‌شده A1→C2:
      A1 مبانی+Satzklammer+صرف · A2 گذشته+möchten/wollen · B1 Ersatzinfinitiv+نفی
      · B2 **Passiv mit Modalverben (از منبع کاربر)** · C1 کاربرد ذهنی · C2 جایگزین‌ها
- [x] 14.3 feature folder `lib/features/modalverben/` — model + controller + ۳ صفحه:
      list (flashcards) · detail (جدول صرف + زمان‌ها + مثال‌ها) · grammar (ExpansionTile + VoxBadge.level)
- [x] 14.4 زبان صفحات جدید از locale اپ پیروی می‌کند (fa یا en — نه هر دو هم‌زمان) ✓
- [x] 14.5 verdrahtet: routes `/modalverben` (+grammar +detail) · flag `deck.modalverben` live
      · deck فعال در Auswendiglernen · tile در Grammatik home · content_registry
- ⚠️ **منبع ارسالی کاربر در واقع مطلب Passiv بود** — بخش Passiv+Modal استفاده شد؛
      بقیه در `old files Lukasalmani/passiv_grammar_quelle.md` ذخیره شد → فاز Passiv (پایین)

### Phase 15 — Grammatik-Themen (generisch) ✅ (2026-07-05)
> زیرساخت: **یک** صفحه generic برای همه موضوعات مستقل گرامر.
> موضوع جدید = ۱ فایل JSON + ۱ سطر در Register — بدون کد جدید!

- [x] 15.1 زیرساخت generic:
      · `grammatik/models/grammar_topic.dart` — GrammarTopicSection + **Register** (`grammarTopics`)
      · `grammatik/screens/grammar_topic_screen.dart` — یک صفحه برای همه (VoxBadge.level +
        ExpansionTile، locale-aware fa/en)
      · route: `/grammatik/thema/:topicId` (قبل از `:level` تعریف شد)
- [x] 15.2 **Passiv** (۹ بخش B1–C1) — قواعد ساخت Akk/Dat، ۶ قانون es، Vorgangs/Zustands/
      Modal/Lassen/Rezipienten/sich-lassen با همه زمان‌ها — از منبع کاربر
- [x] 15.3 **zu und dass** (۱۱ بخش B1–C1) — دو فعل، فاعل یکسان/متفاوت، ohne/anstatt zu+dass،
      um...zu/damit، مُدال+dass، so/zu، zu+um...zu، zu+als dass (+KII!)، حذف es، ترکیب‌ها
- [x] 15.4 **Tempusformen** (۴ بخش B2–C1) — جدول Aktionszeit: حال/آینده/گذشته/مستقل از زمان
      با کارکرد واقعی هر Tempus
- [x] 15.5 **Dativ oder Akkusativ (Kasus)** (۹ بخش A1–B1) — جدول آرتیکل/ضمیر، حروف اضافه
      Dat/Akk/Wechsel، قواعد nach/zu/von/in/an/auf + استثناها، افعال سه گروه، نکات (Hause!)
- [x] 15.6 Modalverben-Grammatik به صفحه generic refactor شد (صفحه اختصاصی حذف شد ✂️)
- [x] 15.7 ۴ tile جدید در Grammatik home
- منابع پاک‌سازی‌شده: passiv_grammar_quelle.md (قبلی) + منابع 2026-07-05 در JSON ها ساختاریافته

### فاز G — Grammatik Vollausbau (تمام گرامر زبان آلمانی) [G1 ✅]
> هدف: صفحه Grammatik کل گرامر آلمانی را پوشش دهد و مرحله‌به‌مرحله کامل شود.
> **نقشه مرجع: `GRAMMATIK_MAP.md`** — کاتالوگ ۹۳ موضوع + ۴ نمای مرتب‌سازی.
> منبع فعلی: `old files Lukasalmani/1/Grammatik` (۸۴ درس کامل سه‌زبانه با جدول/مثال/تمرین).
> منابع بیشتر بعداً از کاربر می‌رسد → فقط Katalog-Eintrag + Content-JSON اضافه می‌شود.
> اصل: کاتالوگ = تنها منبع حقیقت؛ نماها فقط سورت متفاوت همان کاتالوگ‌اند (reference نه کپی).
> ⚠️ در پایان هر Stufe: هم `GRAMMATIK_MAP.md` هم همین فاز آپدیت شود.

- [x] **G1** زیرساخت کاتالوگ ✅ (2026-07-06)
      · `assets/data/grammatik_katalog.json` — themen(15) + satzglieder(7) + eintraege(93)
      · `grammatik/models/grammar_catalog.dart` — مدل‌ها + آیکون/رنگ Thema
      · `grammatik/controllers/grammar_catalog_controller.dart` — katalogProvider +
        grammatikSortModeProvider (persist با shared_preferences: 'grammatik_sort_mode')
      · `grammatik_home_screen.dart` بازسازی — SegmentedButton با ۴ نما:
        Niveau (۶ کارت) · Thema (۱۵) · Lektionen (مسیر خطی ۱..۸۴ + Vertiefung) · Satzglieder (۷)
      · `grammatik_katalog_screen.dart` — یک صفحه پارامتریک `/grammatik/katalog/:view/:key`
      · eintrag با route → push؛ بدون route → snackbar «به‌زودی»
      · ۱۴ ورودی live (بخش‌های موجود: trennbar، reflexiv، unregelm، modalverben، kasus،
        konnektoren، dativ-verben، verb-praep، praep-cluster، nvv، redemittel، passiv/tempus/zu-dass)
- [x] **G2** ✅ (2026-07-07) `GrammatikLektionScreen` — رندر Content-JSON:
      · مدل `grammatik_lektion.dart` (ExplanationBlock/Example/Table/Lektion — سه‌زبانه)
      · controller `grammatik_lektion_controller.dart` — همه فایل‌های content را می‌خواند و
        بر اساس slug ایندکس می‌کند (لیست `_contentFiles`؛ G3–G6 فقط یک خط اضافه می‌کنند)
      · screen: بلوک‌ها (DE ثابت + FA/EN فعال) + جداول (DataTable) + مثال‌ها + verwandte
      · route `/grammatik/lektion/:slug` (قبل از `:level`) + AppRoutes.grammatikLektion
      · **۴ لکسیون واقعی live شد** (verben-grundlagen: konjugation-praesens، verb-sein،
        verb-haben، regelmaessige-verben) — از منبع استخراج شد → assets/data/grammatik/
      · pubspec: `assets/data/grammatik/` اضافه شد (زیرپوشه غیررکورسیو)
      · flutter test: سبز · analyze: سبز
- [~] **G2-alt** (نکته برای G3): منبع `old files Lukasalmani/1/Grammatik` ناقص/آشفته است —
      فقط ۴ لکسیون کامل parse شد. G3–G6 باید محتوای کامل ۸۴ درس را با دقت استخراج کنند.
- [ ] **G2-old** `GrammatikLektionScreen` — رندر Content-JSON (explanationBlocks سه‌زبانه +
      examples + tables + relatedSlugs) در `/grammatik/lektion/:slug`
- [ ] **G3** ایمپورت محتوا I: verben-grundlagen(9) + tempus(5) + passiv(4) + konjunktiv(7)
      → `assets/data/grammatik/<thema>.json` + آپدیت route در کاتالوگ
- [ ] **G4** ایمپورت محتوا II: verbergaenzungen(5) + ergaenzungssaetze(3) + nomen(6) + artikel(6)
- [ ] **G5** ایمپورت محتوا III: adjektive(4) + adverbien(4) + pronomen(5) + praepositionen(5)
- [ ] **G6** ایمپورت محتوا IV: satzlehre(9) + nebensaetze(7) + temporalsaetze(5) → همه ۸۴ درس live
- [ ] **G7** تمرین‌ها: GrammarExercise per درس (منبع exerciseSlugs دارد) + آزمون ترکیبی هر Niveau
- [ ] **G8** یکپارچه‌سازی: Global Search + لینک Leitner + گلاسری A–Z + منابع جدید کاربر

### فاز V — Vokabular-Datenbank (آرشیو بزرگ ~۲۶٬۰۰۰ کلمه) [طراحی نهایی ✅ / پیاده‌سازی باز] (2026-07-08)
> خواسته کاربر: آرشیو بزرگ کلمات. **هر کلمه ~۱۰۰ جمله** (DE/FA/EN). کاربر **هر بار یک کلمه**
> می‌فرستد و Claude آن را با همه اطلاعات ذخیره می‌کند. اپ باید **آفلاین** بماند، **سریع load**
> شود، و **چند سورت هم‌زمان** داشته باشد (A1–C2، Akkusativ، Adjektive، …).

**📂 منبع کلمات (خام): `old files Lukasalmani/Wörter/`**
لیست کامل کلمات آلمانی (منبع GitHub AlleDeutschenWoerter — `LICENSE.txt` باید رعایت شود):
| فایل | نوع | تعداد |
|------|-----|-------|
| `substantiv_singular_der.txt` | اسم مذکر (der) | ۵٬۷۶۰ |
| `substantiv_singular_die.txt` | اسم مؤنث (die) | ۵٬۷۹۷ |
| `substantiv_singular_das.txt` | اسم خنثی (das) | ۳٬۰۵۲ |
| `substantiv_singular_alle.txt` | همه اسم‌ها (ترکیب سه‌تای بالا) | ۱۴٬۶۰۹ |
| `Adjektive.txt` | صفت | ۶٬۸۴۹ |
| `Verben_regelmaesig.txt` | فعل باقاعده | ۳٬۰۳۸ |
| `Verben_unregelmaeßig_Infinitiv.txt` | فعل بی‌قاعده | ۱٬۷۱۱ |
| **مجموع** (der+die+das+adj+verben) | | **~۲۶٬۲۰۰** |
⚠️ فایل‌های txt فقط **کلمه‌ی خام** (یک کلمه در هر خط) — بدون معنی/آرتیکل/سطح. باید غنی شوند.

**🔧 Prompt تبدیل: `old files Lukasalmani/Wort prompt` (SUPER-PROMPT v1.0)**
این Prompt **schema کامل صفحه‌ی هر کلمه** را تعریف می‌کند (= همان schema که منتظرش بودیم):
- ورودی: **یک** کلمه‌ی آلمانی · خروجی: **یک** JSON-Objekt کامل (بدون markdown/توضیح)
- زبان: همه فیلدهای ترجمه دوزبانه `{ "fa":…, "en":… }`؛ آلمانی تغییرناپذیر
- `id` = `wortart_lemma` (ä→ae, ö→oe, ü→ue, ß→ss) — مثلاً `verb_zerstreuen`
- سه بخش در یک object: (۱) کارت پایه + جزئیات هر Wortart (۲) **Grammatikon** (سیستم آیکون:
  رنگ/شکل/پرشدگی/marker + Paradigma کامل) (۳) **Wortnetz** (خانواده‌ی واژه ۱۵–۲۵ مورد)
- فیلدها: Grunddaten، Beispiele (حداقل ۲: A1/A2 + B1/B2؛ کاربر تا ~۱۰۰ گسترش می‌دهد)،
  `haeufige_fehler` (ویژه فارسی‌زبانان)، `luecken_uebung`، Synonyme/Antonyme، Niveau (A1–C2)،
  `box:1` + `nextReviewDate:null` (Leitner — اپ مدیریت می‌کند)
- **جریان کار: هر کلمه → از Prompt رد می‌شود → JSON خروجی → طبق معماری زیر ذخیره می‌شود.**

**🎨 Grammatikon — سیستم آیکون (اصل Puzzling، مثل vox_button.dart) [فونداسیون ✅ 2026-07-08]**
> تصمیم کاربر: بخش `visualisierung` در Prompt فقط **معنی** را می‌دهد (`shape: "raute"`)؛
> **نمایش** (اینکه raute چطور رسم می‌شود) در یک Spec مرکزی. تغییر design = یک فایل، نه هزاران JSON.
- `lib/core/grammatikon/grammatikon_spec.dart` ✅ — همه ثابت‌ها: رنگ‌ها (maskulin سبز/feminin
  نارنجی/neutral لیلا/plural قرمز/verb خاکستری/kontur/weiss)، هندسه (quadrat/raute/dreieck/
  ellipse/kreis/kapsel/blob…)، نسبت‌ها (klein 60٪/doppel 50٪/kapsel-innen 40٪)، rahmen
  (normal 2.5/dick 5/sehr_dick 8)، streifen، marker. + helper: genusFarbe()، rahmenBreite().
- `lib/core/grammatikon/perfekt_builder.dart` ✅ — Perfekt از hilfsverb+partizip2 ساخته می‌شود
  (deterministic) → **دیگر در JSON ذخیره نمی‌شود**.
- [x] **V.icon** `grammatikon_painter.dart` (CustomPainter) ✅ (2026-07-14) — enum های JSON را
  می‌خواند، فقط از `GrammatikonSpec` رسم می‌کند. + `grammatikon_resolver.dart` (مغز: کارت JSON
  schema 2.0 + Kontext → Descriptor) + widget `WortSymbol(card:, size:, kasus:, form:, ...)`.
  ۳ تست سبز (هر Wortart + Kasus/Form flektiert + Resolver logic). **این «مرحله ۱» نقشه‌ی
  Wortschatz کاربر است — به Flutter port شد (کاربر کد React Native/Expo فرستاده بود؛ پروژه Flutter است).**
  رنگ/فرم منبع واحد: `GrammatikonSpec` (تغییر design = یک فایل). Farbe=Genus، Form=Kasus،
  Textur=Formtyp — نماد هرگز در داده ذخیره نمی‌شود، همیشه از wortart+details محاسبه می‌شود.

**🗺️ نقشه‌ی Wortschatz کاربر (۵ مرحله، 2026-07-14) — همه به Flutter نه React Native:**
- [x] **مرحله ۱** سیستم طراحی: WortSymbol + Resolver خودکار (کارت→نماد) ✅ = V.icon بالا
- [x] **مرحله ۲** ✅ (2026-07-14) متن رنگی + کارت لیست — ۳ فایل در `lib/core/grammatikon/`:
  · `endung_resolver.dart` — splitEndung (Automatik/explizit، Stamm ≥ ۲) + splitPraefix (ge-/trennbar)
  · `wort_text.dart` — widget `WortText(wort:, endung:, praefix:, color:)`: Stamm در Theme-Farbe،
    Endung رنگی+bold، Präfix bold+italic؛ آلمانی همیشه LTR؛ color=null → فقط bold (dark-safe)
  · `wort_card.dart` — widget `WortCard(card:, onTap:)`: نماد | آرتیکل رنگی + کلمه + ترجمه | VoxBadge
    + «صندوق n». **بهبودها نسبت به کد RN کاربر**: پارامتر sprache حذف (فاز L: زبان فقط از AppL10n.isFa،
    'beide' ممنوع)؛ رنگ از GrammatikonResolver (نه جدول Genus دوم)؛ Theme-aware (نه hardcoded #fff)؛
    Card/InkWell idiom پروژه؛ کلید l10n جدید `leitner_fach` (FA+EN)؛ helper جدید `Formatters.digits`
    (locale-aware — faDigits بی‌قید بود). تست: `test/wort_text_card_test.dart` (۸ تست سبز، FA+EN).
- [x] **مرحله ۳** ✅ (2026-07-14) صفحات Vokabular-Archiv — `lib/features/vokabular/`:
  **⚠️ Update 2026-07-14 (تصمیم کاربر): آرشیو جدا حذف شد** — لیست کارت‌ها در **«Alle Wörter»**
  (`wortschatz_list_screen.dart`) merge شد (دو منبع در یک لیست الفبایی؛ فیلترها مشترک؛
  نگاشت WordType→wortart). `vokabular_home_screen` و `vokabular_liste_screen` + routes
  `/vokabular`،`/vokabular/liste` حذف؛ فقط `/vokabular/wort/:id` مانده. جزئیات: PROJECT_MAP.md.
  ⏳ باز: صفحه‌ی نمایش Kategorien شخصی + فیلتر Themen (با حذف home بی‌ورودی شدند).
  · **اصل کاربر: Wortschatz ≠ Leitner** — هیچ import خودکاری به لایتنر نیست؛ فقط دکمه
    «Leitner hinzufügen» flag می‌زند؛ Kategorien = لیست‌های شخصی فقط با Wort-ID ها.
  · `controllers/vokabular_controller.dart` — لود کارت‌ها از `assets/vocab/<wortart>/<id>.json`
    (AssetManifest)؛ **پل به V.3**: بعداً فقط این provider با prebuilt vocab.db عوض می‌شود.
    + `vokabId(wortart, wort)` (قانون ۵ ID: آرتیکل حذف، ä→ae/ß→ss) + جستجوی DE/FA/EN.
  · `controllers/vokabular_user_state.dart` — **user state جدا از content read-only**
    (بهبود مهم نسبت به کد RN که flag را داخل خود کارت می‌نوشت): Leitner-Map (box/nextReview)
    + Kategorien؛ SharedPreferences (V.3 → drift کنار vocab.db، API ثابت)؛ `_ready`-Gate ضد race.
  · `widgets/wort_actions.dart` — 🔊 = **AudioPlayButton موجود** (نه expo-speech!) + Leitner-Toggle
    + Kategorien-BottomSheet (ساخت/toggle)؛ فقط VoxButton/VoxIconButton؛ snackbar از کلیدهای موجود.
  · `screens/vokabular_home_screen.dart` — جستجو + Wortarten-Grid (شمارنده، VoxColors.wordType)
    + Niveau/Themen-Chips + Meine Kategorien. `screens/vokabular_liste_screen.dart` — فیلتر از
    query params (wortart|niveau|thema|kategorie|suche)، WortCard + WortActions kompakt (trailing-Slot).
  · Routes: `/vokabular`, `/vokabular/liste?typ=&wert=`, `/vokabular/wort/:id` (static قبل از param).
    ورودی: tile «Vokabular-Archiv» در Wortschatz-Home. pubspec: ۱۰ پوشه‌ی assets/vocab/<wortart>/.
- [x] **مرحله ۴** ✅ (2026-07-14) Wort-Seite — قلب بخش:
  **Update 2026-07-14 (خواسته‌ی کاربر):** ① سکشن **«Gegenteil»** (فیلد `antonyme`) دقیقاً بعد از
  Synonyme — فقط واژه + معنی (یک زبان از Settings)، بدون مثال/توضیح؛ Prompt Regel 10 هم
  به‌روز شد (اگر Gegenteil رایج وجود دارد، همیشه بده). ② **Freitext-Notiz با رنگ هر کلمه**:
  `widgets/wort_notiz.dart` — `WortNotizSektion` (نمایش RichText) + BottomSheet-Editor:
  کلمه را در TextField لمس/انتخاب کن → دایره‌ی رنگ (۶ رنگ + Standard)؛ live رنگی از طریق
  `_NotizController.buildTextSpan`؛ ذخیره: `VokabNotiz {text, farben: WortIndex→نامِ رنگ}` در
  `vokabular_user_state` (کلید `vokab_user_notizen_v1`؛ متن خالی = حذف). فقط VoxButton/VoxIconButton.
  · `screens/wort_seite_screen.dart` — کوپف (WortSymbol + آرتیکل رنگی + IPA + VoxBadge) →
    ترجمه (فقط زبان فعال، فاز L) → WortActions بزرگ → Beispiele → Details → Synonyme/Antonyme/
    Komposita → **Wortnetz گروهی کلیک‌پذیر**: id از `vokabId()` مشتق می‌شود (schema 2.0 فیلد id_ref
    ندارد — deterministic)؛ موجود → push (ناوبری زنجیره‌ای)؛ غایب → dialog + جستجو.
  · `widgets/wortseite_bausteine.dart` — Sektion/Zeile/BeispielBlock/Tabelle + `vokabUeb()`
    (**یک** ترجمه، نه fa+en همزمان — اصلاح Dual-Display کد RN)؛ همه null-safe (قانون ۳).
  · `widgets/details_renderer.dart` — ۱۰ Wortart (nomen…partikel)؛ **Perfekt از PerfektBuilder
    ساخته می‌شود، هرگز ذخیره نه** (قانون ۷)؛ اصطلاحات گرامری آلمانی = محتوا (تغییرناپذیر).
  · ۱۲ کلید l10n جدید (FA+EN پاریتی: vokabular_sub، in_leitner، kategorien_sheet_title…).
  · Demo-Wort `assets/vocab/verb/verb_lernen.json` (**Platzhalter** — با اولین کلمه‌ی واقعی کاربر
    از SUPER-PROMPT جایگزین/تکمیل می‌شود). تست: `test/vokabular_test.dart` (۸ تست).
- [x] **مرحله ۵** ✅ (2026-07-14) Import-Pipeline — **SUPER-PROMPT v3.0** (تصمیم کاربر):
  · schema v3.0: **JSON-Array ۱–۱۰ کلمه** per batch؛ فیلد جدید `etymologie` — **از 2026-07-14
    دوزبانه `{fa, en}`** (باگ کاربر: در حالت EN گلاس فارسی دیده می‌شد؛ Prompt Regel 12 + validator
    Warnung + `anmerkung` فقط آلمانی)؛ **Wortnetz تخت**:
    دقیقاً ۵ ارجاع با `id_ref`؛ Beispiele دقیقاً ۲ (کلمه‌ی هدف در جمله — Lückentext)؛
    بدون Perfekt/Genitiv (اپ می‌سازد). ⇒ **V.0 بسته**: ~۱۰۰ جمله منتفی، جدول sentences فعلاً نه.
    **Regel 15 (2026-07-14، خواسته‌ی کاربر) — Rektion/feste Präposition:** برای **Verb/Adjektiv/Nomen**
    اگر حرف اضافه‌ی ثابت وجود دارد، `rektion` (فعل) / `mit_praeposition` (صفت/اسم) **هرگز null یا
    خالی یا بدون Präposition نباشد** — همیشه Präposition + Kasus دقیق (Akk/Dat) در muster
    (مثل warten auf + Akk · stolz auf + Akk · die Angst vor + Dat) + یک جمله‌ی نمونه‌ی روشن
    با ترجمه‌ی {fa, en}. فقط وقتی واقعاً حرف اضافه‌ی ثابت ندارد: [].
  · **`lib/features/vokabular/data/vokab_schema.dart`** — reines Dart، **یک منبع** برای اپ+تول:
    vokabId (از controller منتقل شد، re-export ماند) + `vokabParseBatch` (Fences-tolerant،
    Einzelobjekt→Array) + `vokabPruefeKarte`: فاتال (wortart/wort/uebersetzung fa+en/niveau/details)
    → هرگز نوشته نمی‌شود؛ قابل‌تعمیر → normalisiert+Warnung (id طبق قانون ۵، box→1،
    nextReviewDate→null، konjugation.perfekt/details.genitiv حذف، id_ref تصحیح، قانون ۹ چک).
  · **`tool/vokabular_import.dart`** (CLI): `dart run tool/vokabular_import.dart` → پیش‌فرض
    `import_inbox/*.json`؛ گزینه‌ها `--dry-run` / `--update` / `--out`؛ Duplikat-Schutz
    (existiert → übersprungen، **idempotent**)؛ Fehlerbericht کامل؛ exit 1 روی خطا.
    `import_inbox/README.md` = دستورالعمل. **E2E تأیید شد** (typo-id/box/genitiv/id_ref
    normalisiert، کارت خراب رد شد، اجرای دوم همه skip).
  · اپ v3.0 شد: Wort-Seite → Wortnetz تخت + `id_ref` (fallback: مشتق؛ gruppen قدیمی flatten)
    + Sektion «Wortbildung» (etymologie)؛ demo `verb_lernen.json` → v3.0 (۵ ارجاع id_ref).
  · تست: `test/vokab_schema_test.dart` (۹ تست) — مجموع suite ۲۹ ✅.
  · **جریان کار از این پس**: کاربر batch می‌سازد → `import_inbox/` → یک فرمان → کلمات در اپ.
  **باز مانده (بعد از حجم‌گیری):** ① حالت یادگیری/Leitner فقط imLeitner بخواند ② V.2 build-script
  → vocab.db وقتی تعداد کلمات زیاد شد (لود asset فعلی تا چند صد کلمه کافی است) ③ V.5 توزیع.

**▶️ جریان ورود کلمات — شروع شد 2026-07-14 (برای هر کلمه دقیقاً همین ۶ قدم):**
منبع کلمات: `old files Lukasalmani/Wörter/*.txt` (۸ فایل خام). ترتیب کاری فعلی: **Adjektive.txt** اول.
1. **کلمه‌ی بعدی** = اولین خط **بدون** پیشوند `✓ ` در فایل txt فعال.
2. کلمه از **SUPER-PROMPT v3.0** (`old files Lukasalmani/Wort prompt`) رد می‌شود → کارت کامل JSON
   (Array؛ ۱–۱۰ کلمه per batch مجاز). Niveau طبق GER؛ فیلدهای نامربوط null؛ دقیقاً ۲ Beispiel +
   Wortnetz ۵×id_ref.
3. خروجی → `import_inbox/batch_<YYYY-MM-DD>_<gruppe>_<nnn>.json` (مثال: `batch_2026-07-14_adjektive_001.json`).
4. `dart run tool/vokabular_import.dart` → گزارش: **Fehler** = کارت نوشته نشد (تولید مجدد)؛
   **Warnung** = خودکار اصلاح شد (قابل قبول). هدف: ۰ Fehler / ۰ Warnung.
5. نتیجه: `assets/vocab/<wortart>/<id>.json` — **هر کلمه = ۱ فایل مستقل = صفحه‌ی خودش در اپ**
   (route `/vokabular/wort/:id`)؛ همین فایل‌ها بعداً عیناً به cloud/توزیع Android+iOS می‌روند (V.5).
6. **مارک کردن**: در فایل txt، خط کلمه پیشوند `✓ ` می‌گیرد (مثال: `✓ aalartig`). batch-فایل در
   import_inbox بعد از import قابل حذف است (منبع حقیقت = assets/vocab/).
**پیشرفت در PLAN/MAP ثبت نمی‌شود (تصمیم کاربر 2026-07-14):** این دو سند فقط «چگونه» را نگه می‌دارند.
⚠️ **اصلاح 2026-09-15 (Audit):** مارک‌های `✓ ` دستی از واقعیت عقب افتاده بودند (۸۷ کارت موجود، ۶ مارک).
**قانون جدید: تنها منبع حقیقت = `assets/vocab/`.** مارک‌های `✓ ` دیگر دستی زده نمی‌شوند، بلکه
`tool/sync_backlog.py` آن‌ها را از روی فایل‌های موجود بازسازی می‌کند (قدم ۶ پایین خودکار شد).

**🧩 D — Deck-Vervollständigung nach Wort-prompt-Standard (۸ دِک زنده، 2026-07-15):**
هدف: ۸ دِک زنده‌ی Auswendiglernen (Konnektoren، Dativ+Akk، Präp-Cluster، Unregelm، Trennbar،
Reflexiv، Verb+Präp، Modalverben) مطابق معیارهای SUPER-PROMPT v3.0 (`old files Lukasalmani/Wort prompt`):
Regel 2 (همه‌ی ترجمه‌ها زوج {fa,en})، Regel 9 (جمله‌ی نمونه، کلمه‌ی هدف قابل‌تشخیص + ترجمه)،
Regel 14 (فرم‌ها در سطح Duden)، Regel 15 (حرف اضافه‌ی ثابت همیشه با Kasus دقیق + جمله‌ی نمونه).
**قانون کاربر: هیچ محتوایی (معنی/جمله‌ی موجود) حذف نمی‌شود — فقط تکمیل و تصحیح.**
- [x] **Audit (2026-07-15، اسکریپت روی ۸ فایل assets/data):**
  · ۷ دِک **پاس**: Konnektoren ۱۸۶ · Dativ+Akk ۱۱۰ · Unregelm ۱۷۰ · Trennbar ۱۱۰ · Reflexiv ۱۱۴ ·
    Verb+Präp ۷۲ · Modalverben ۷ — بعد از note_en-Nachrüstung 2026-07-15 دوزبانه‌ی کامل؛
    Kasus همه‌جا موجود (trennbar/konnektoren چک شد)؛ کلمه‌ی هدف در همه‌ی جمله‌ها (صرف‌شده) هست.
  · **۱ نقص واقعی: praepositionen_data.json** (دِک «Nomen · Verb · Adjektiv + Präposition»):
    **۱۳۴ عضو از ۳۸۳ بدون جمله‌ی نمونه** (اغلب اسم/صفت‌های هم‌خانواده‌ی فعل کلاستر) → نقض Regel 15.
    Detail-Screen و Quiz هر دو جمله‌ی per-member را نمایش می‌دهند ⇒ نقص برای کاربر مرئی است.
- [x] **اجرا ✅ (2026-07-15):** ۱۳۴ جمله‌ی {de, fa, en} با الگوی روشن Lemma + Präposition + Kasus
  به آرایه‌ی `examples` کلاسترها اضافه شد (کلیدهای member_lemma/member_preposition؛ مورد خاص:
  «das Interesse» در کلاستر ۵۵ دو بار — an+Dat و für+Akk — هرکدام جمله‌ی مخصوص خودش).
- [x] **تأیید ✅ (2026-07-15):** Re-Audit = ۰ عضو بدون جمله؛ flutter analyze پاک؛ ۳۳ تست سبز.
  **⇒ فاز D بسته: هر ۸ دِک زنده حالا استاندارد Wort prompt را پاس می‌کنند. هیچ محتوایی حذف نشد.**

**📦 نتیجه مهم برای ذخیره‌سازی: JSON ذخیره‌شده «لاغرتر» از خروجی خام Prompt است.**
هنگام ذخیره، بخش‌های قابل‌اشتقاق strip می‌شوند:
- `render_tokens` (پیکسل‌ها) → حذف؛ در `GrammatikonSpec` است.
- `details.konjugation.perfekt` → حذف؛ `PerfektBuilder` می‌سازد.
- فقط enum های معنایی می‌مانند (shape/fuellung/rahmen/marker/farbe_hex). ⇒ فایل کلمه کوچک‌تر،
  design متمرکز. (build-script V.2 این strip را انجام می‌دهد.)

**⏳ منتظر کاربر (تنها نکته باز schema):** آیا Prompt به ~۱۰۰ جمله گسترش می‌یابد
(الان حداقل ۲)؟ اگر بله، بخش `beispiele` در schema باید آرایه‌ی بزرگ بپذیرد + جمله‌ها در
جدول `sentences` (نه در فایل کلمه) ذخیره شوند تا لیست سریع بماند.

**محاسبه مقیاس (تعیین‌کننده معماری):**
- ۲۵٬۰۰۰ کلمه + متادیتا ≈ ۱۵–۲۵ MB (بی‌مشکل)
- ۲۵٬۰۰۰ × ۱۰۰ جمله = **۲٬۵۰۰٬۰۰۰ جمله** × (DE+FA+EN) ≈ **~۶۰۰ MB** ← گلوگاه اصلی
- ⇒ الگوی فعلی (seed کردن JSON در startup) از کار می‌افتد. باید prebuilt SQLite باشد.

**اصل کلیدی: سورت فقط روی «کلمات» است، نه «جمله‌ها».**
همه سورت‌ها (A1–C2، kasus، wortart) فقط به **صفات کلمه** مربوط‌اند. ۱۰۰ جمله فقط محتوای
صفحه‌ی detail است ⇒ **لیست کلمات فقط words را load می‌کند (همیشه سریع)**؛ جمله‌ها **lazy**
فقط هنگام باز کردن کلمه load می‌شوند.

**معماری تصمیم‌گیری‌شده — جدایی «منبع» از «Laufzeit»:**

| | منبع (Git، قابل‌ویرایش) | Laufzeit (اپ، سریع) |
|---|---|---|
| فرم | **۱ فایل JSON برای هر کلمه**، پوشه بر اساس wordType | **۱ فایل prebuilt `vocab.db`** (SQLite) |
| افزودن | کاربر ۱ کلمه می‌فرستد → Claude ۱ فایل می‌سازد (بدون بازنویسی) | build-script دوباره db را می‌سازد |
| سورت | بی‌ربط | query/index — **هرگز فایل جدا** |

- **منبع**: `assets/vocab/<wordType>/<slug>.json` — خودکفا (متادیتا + ۱۰۰ جمله در همان فایل).
  git-friendly، افزودنی، هر کلمه یک فایل مستقل. فیلد `tags` (level:a1، kasus:akkusativ،
  type:adjektiv، thema:…) → سورت‌های نامحدود بعدی فقط یک tag/query‌اند، بدون تغییر داده.
- **build-script** (روی دستگاه dev، نه در اپ): همه فایل‌های کلمه → **یک** `assets/vocab.db`:
  - `words` (~۲۵k ردیف، indexed) — german/wordType/level/article/meaningFa/meaningEn/…
  - `word_tags` (word_id, tag) — برای سورت‌های flexible چند‌به‌چند
  - `sentences` (id, word_id, de, fa, en) — ۲٫۵M ردیف، **فقط lazy load**
- اپ `vocab.db` را asset می‌کند، **یک‌بار** در first-launch کپی می‌کند (نه seed سطر‌به‌سطر) →
  فوری آماده. هر سورت = query indexed روی همان **یک** جدول (چند index هم‌زمان).

**هم‌زیستی با داده‌های موجود (خواسته کاربر):**
- فایل‌های قدیمی (dativ، akkusativ، konnektoren، …) **بدون تغییر** می‌مانند — هدفشان متفاوت است،
  در جداول خودشان. ستون `source` در `words` (`'vocab'` vs `'feature'`) → «ترکیب» بعدی فقط
  یک filter است، بدون migration. (نحوه‌ی ترکیب نهایی را کاربر بعداً تصمیم می‌گیرد.)
- در نتیجه ممکن است در Wortschatz دو منبع کلمه هم‌زمان دیده شود — عمدی و قابل‌ترکیب.

**سقف صادقانه (تصمیم بعدی):** ~۶۰۰ MB آفلاین > حد App Store (iOS ~۲۰۰ MB).
نقطه‌ی تصمیم گرد ~۵٬۰۰۰–۸٬۰۰۰ کلمه: یا **جمله‌های کمتر در bundle** (مثلاً ۱۰ در اپ، بقیه در منبع)
یا **`.db` جداگانه‌ی قابل‌دانلود** (اپ کوچک، کلمات آفلاین، جمله‌ها نجات). **ساختار فایل کلمه در
هر دو حالت یکسان است** — فقط build-script تصمیم می‌گیرد چند جمله وارد bundle شود.
توزیع نهایی (ZIP / Apple CloudKit) بعداً.

- [x] **V.0** ✅ (2026-07-14) schema نهایی = **SUPER-PROMPT v3.0** (کاربر تصمیم گرفت):
      Array ۱–۱۰ کلمه، دقیقاً ۲ Beispiel (نه ~۱۰۰ جمله — جدول sentences فعلاً منتفی)،
      Wortnetz = ۵ ارجاع تخت با id_ref، فیلد etymologie. tag ها بعداً از فیلدها (V.2).
- [x] **V.1** ✅ (2026-07-14) ساختار پوشه `assets/vocab/<wortart>/<id>.json` (۱۰ پوشه در pubspec)
      + نگاشت Prompt→ذخیره = `vokab_schema.dart` (Validierung/Normalisierung) + demo `verb_lernen`؛
      کلمات واقعی از این پس via `import_inbox/` + `tool/vokabular_import.dart` (مرحله ۵ بالا)
- [ ] **V.2** build-script (Dart/Python): فایل‌های کلمه → `vocab.db` (words/word_tags/sentences + index ها)
      + خواندن txt های `Wörter/` برای backlog کلمات (کدام غنی شده، کدام نه)
      ⚠️ **ارتقا به «پیش‌شرط» (Audit 2026-09-15):** `vokabular_controller` همه‌ی کارت‌ها را در startup
      می‌خواند ⇒ بدون V.2 خودکارسازی (فاز A) اپ را می‌شکند. سقف امن تا آن زمان ~۵۰۰ کارت.
- [ ] **V.3** اپ: کپی prebuilt `vocab.db` در first-launch (نه seed) + DAO + provider های سورت
- [ ] **V.4** UI: **لیست فقط words (سریع/paginated)** + detail با جمله‌های lazy + **چند سورت هم‌زمان**
      (A1–C2 / kasus / wortart / thema — هر کدام index+query روی همان جدول)
- [ ] **V.5** تصمیم توزیع (کاربر + Claude با هم): **ZIP** یا **Apple CloudKit** یا db قابل‌دانلود یا
      bundle با جمله‌های کمتر — با توجه به سقف ~۶۰۰ MB و حد App Store. ساختار فایل کلمه در همه
      حالات یکسان است؛ فقط build-script/توزیع فرق می‌کند. (زمان تصمیم: وقتی حجم بزرگ شد.)
- **قانون**: هر کلمه‌ی جدید = **۱ فایل** (از `Wort prompt`، بدون بازنویسی بقیه)؛ سورت = query نه فایل؛
  آلمانی تغییرناپذیر؛ FA+EN از ابتدا (اصل ۵ MAP)؛ جمله‌ها هرگز در لیست load نمی‌شوند.

### فاز S — Speicherung der Nutzerdaten [باز شد 2026-09-15]
> **Anlass:** Frage des Nutzers — wo liegen Fortschritt, Kategorien und Karteninhalte?
> **Befund (Code gelesen, nicht geraten):** ausschließlich im Browser des Nutzers, und dort
> auf **zwei** Ablagen verteilt. Es gibt **keinerlei Sicherung** — `core/services/backup_service.dart`
> ist ein Stub ohne eine Zeile Code.

**Ist-Zustand:**
| Ablage | Was liegt drin |
|---|---|
| drift/SQLite-WASM (IndexedDB, DB-Name `vox`) | `LeitnerCards` (Box, nextReview) für die **alten** Wortschatz-Wörter · `Words`/`Books`/`WordBooks` (eigene Wörter) · `UserCategories`/`CategoryWords` |
| SharedPreferences (localStorage) | `vokab_user_leitner_v1` (Leitner der **neuen** Archiv-Karten) · `vokab_user_kategorien_v1` · `vokab_user_notizen_v1` · Einstellungen (`theme_mode`, `current_level`, `daily_goal_min`, `ui_language`, tts) · Grammatik-Katalog-Fortschritt |

⚠️ **Der Leitner-Fortschritt liegt in zwei Ablagen in zwei Formaten.** Solange das so ist, muss
jede Sicherung, jede Synchronisierung und jede Migration **doppelt** geschrieben werden.

**Risiko (belegt):** Safari löscht die script-writable Ablagen (IndexedDB, localStorage) nach
sieben Tagen Safari-Nutzung **ohne Interaktion mit der Seite** — jede echte Interaktion setzt den
Zähler zurück, und zur Startseite hinzugefügte Web-Apps sind ausgenommen. Für die iPhone-Nutzer
von VOX heißt das: eine Woche nicht geöffnet ⇒ Fortschritt **still** weg. Dazu: „Browserdaten
löschen" trifft alles, und ein anderes Gerät kennt nichts.

**Entscheidung des Nutzers 2026-09-15 — drei Orte, EIN Zuhause:**
| Ort | Rolle |
|---|---|
| **Browser** | Zuhause — die App liest und schreibt immer nur hier |
| **Server (Supabase, geteilt mit Root-in)** | automatische Kopie; Daten sind winzig (nur Nutzerzustand, keine Wörter) ⇒ dauerhaft im Gratis-Tarif |
| **Datei (Export/Import)** | Rettungsnetz von Hand — muss **immer** allein genügen |
⇒ Die App liest **nie** direkt von Server oder Datei; beide dienen nur der Wiederherstellung.
⚠️ **Der Server darf nie das einzige Netz sein.** Zielgruppe sind Persischsprachige; ein Backend
kann per Anordnung über Nacht verschwinden (Supabase war Februar 2026 in Indien acht Tage lang
gesperrt, Auth komplett tot). Der Offline-Weg muss vollständig und selbsttragend bleiben.

**Konfliktregel (Nutzerentscheidung 2026-09-15): „höchstes Fach gewinnt".**
Beim Zusammenführen zweier Stände wird **nicht** der jüngste Zeitstempel genommen, sondern je
Karte das höhere Leitner-Fach. Begründung: Lernfortschritt geht nur vorwärts; so geht Offline-
Arbeit nie verloren. Für Notizen und Kategorien gilt Vereinigung statt Überschreiben.

**Gemeinsame Sicherungs-Hülle (Vertrag mit Root-in, kein geteilter Code):**
`{ "version": <int>, "exportedAt": <ISO>, "app": "vox" | "root-in", "payload": { … } }`
Gleiche Hülle, unterschiedliche Nutzlast. In beiden PLAN-Dateien festgehalten.

- [ ] **S.0 EINE Ablage** — `vokab_user_*` von localStorage nach drift; `LeitnerCards` so
      erweitern, dass es beide Wortquellen trägt (Archiv-Karten haben Text-IDs wie
      `adjektiv_stolz`, die alten Wörter eine Int-ID); Migration ohne Datenverlust.
      ⚠️ **BLOCKIERT** — jede Drift-Änderung braucht `build_runner` (`app_database.g.dart`,
      ~8.000 Zeilen). Claude hat kein Dart, und der nötige CI-Workflow lässt sich nicht pushen
      (PAT ohne „Workflows"-Recht, siehe فاز A / A.4). **Ein Recht löst beide Blockaden.**
- [x] **S.1 `persist()` + PWA** ✅ (2026-09-15) — `core/utils/persistent_storage.dart`
      (bedingter Export wie `external_link_opener`), aus `main.dart` gerufen. Aus Root-in
      übernommen, Herkunft im Dateikopf vermerkt, `tool/check_vendored.py` überwacht Abweichungen.
- [ ] **S.2 Export/Import** — `backup_service.dart` ausbauen (heute Stub), Hülle wie oben
- [ ] **S.3 Supabase-Konto** — `auth_service.dart` aus Root-in übernehmen (~90 % allgemein);
      `auth.users` geteilt, aber **jedes Repo besitzt seine eigenen Tabellen**:
      `schema.sql` bleibt in Root-in, VOX bekommt ein eigenes `supabase/vox_tables.sql`
- [ ] **S.4** Ehrlicher Hinweis in den Einstellungen, solange S.2/S.3 fehlen

**Reihenfolge ist zwingend: S.0 vor S.2 und S.3** — sonst wird jeder Serializer zweimal geschrieben.

---

### فاز A — Automatisierung der Worterfassung [باز شد 2026-09-15]
> **مسئله (اندازه‌گیری‌شده، نه حدس):** Pipeline سالم است؛ گلوگاه **انسانی** است. از ۲۰۲۶-۰۷-۱۴ تا
> ۲۰۲۶-۰۹-۱۵ — دو ماه — تعداد کارت‌ها به ۸۷ رسید (۰٫۳٪ از ~۲۶٬۲۰۰). با همین آهنگ پروژه هرگز تمام نمی‌شود.
> **تصمیم کاربر:** ترتیب **الفبایی** می‌ماند؛ سرعت از خودکارسازی می‌آید.

**اصل راهنما: فقط «تولید» خودکار می‌شود، نه «اعتبارسنجی».** اعتبارسنجی همچنان تنها و تنها
`vokabPruefeKarte` در `lib/features/vokabular/data/vokab_schema.dart` است (یک منبع برای اپ + تول + CI).
هیچ منطق validation دومی نوشته نمی‌شود — هر ابزار کمکی فقط «pre-flight» است و حرف آخر را Dart می‌زند.

- [x] **A.1 `tool/backlog.py`** ✅ (2026-09-15) — backlog reader: از `old files Lukasalmani/Wörter/*.txt` و
      `assets/vocab/` حساب می‌کند **کلمه‌ی بعدی کدام است** (بر اساس فایل‌های موجود، نه مارک‌ها).
      خروجی: لیست N کلمه‌ی بعدی به ترتیب الفبا + گزارش پوشش per Wortart.
- [x] **A.2 `tool/sync_backlog.py`** ✅ (2026-09-15) — **اجرا شد: ۴۵ مارک نو، ۰ حذف؛ اجرای دوم بدون تغییر (idempotent)** — مارک‌های `✓ ` را از روی `assets/vocab/` بازسازی می‌کند
      (رفع ناهماهنگی Audit). idempotent؛ `--dry-run` دارد.
- [x] **A.3 `tool/generate_words.py`** ✅ (2026-09-15) — با `--dry-run` تست شد؛ سقف امن ۵۰۰ کارت سخت‌کد شده (`--grenze`) — Generator: N کلمه از A.1 می‌گیرد، SUPER-PROMPT v3.0 را
      از `old files Lukasalmani/Wort prompt` می‌خواند (**یک منبع** — کپی نمی‌شود)، batch را به
      Anthropic API می‌فرستد، خروجی را pre-flight می‌کند و در `import_inbox/` می‌نویسد.
      ⚠️ نیاز به `ANTHROPIC_API_KEY` (Secret) — هزینه دارد و باید شفاف گزارش شود.
- [!] **A.4 `.github/workflows/vokabular-autofill.yml`** — **بلاک: توکن اجازه ندارد.** فایل نوشته و YAML-تست شده، ولی `PUT` با «Resource not accessible by personal access token» رد شد: fine-grained PAT برای `.github/workflows/` مجوز جداگانه‌ی **«Workflows: Read and write»** می‌خواهد (فقط «Contents» کافی نیست). راه‌حل: یا مجوز به توکن اضافه شود، یا Lukas فایل را یک‌بار دستی در GitHub بسازد. — `workflow_dispatch` (+ اختیاری `schedule`):
      A.3 → `dart run tool/vokabular_import.dart` (اعتبارسنجی واقعی) → A.2 → `flutter analyze` +
      `flutter test` → commit. **اگر Fehler > 0 یا تست قرمز: هیچ چیز commit نمی‌شود.**
      ورودی‌ها: `anzahl` (چند کلمه)، `gruppe` (adjektive/verben/nomen)، `dry_run`.
- [x] **A.5** ✅ گزارش: هر اجرا یک خلاصه در Job-Summary (چند کلمه، چند Warnung، هزینه‌ی تقریبی).

**⚠️ ترتیب اجباری:** A.1/A.2 بی‌خطرند و می‌توانند همین حالا بروند. **A.3/A.4 نباید قبل از V.2
فعال شوند** — چون `vokabular_controller` همه‌ی کارت‌ها را در startup می‌خواند و یک اجرای موفق
با چند هزار کلمه اپ زنده را می‌شکند. سقف امن فعلی: **~۵۰۰ کارت**.

---

### فاز L — L10n: زبان فقط از Settings [Step 1 ✅ Audit — 2026-07-07]
> قوانین کاربر (blueprint 2026-07-07):
> ۱. آلمانی تغییرناپذیر است (محتوای یادگیری) — هرگز ترجمه/تغییر نشود.
> ۲. زبان دوم داینامیک: FA یا EN — کاربر انتخاب می‌کند.
> ۳. FA و EN هرگز هم‌زمان روی صفحه نباشند؛ تغییر زبان فوری کل اپ را آپدیت کند.
> ۴. تغییر زبان **فقط** از Settings — هر سوییچ دیگری حذف شود.

**نتیجه Audit (Step 1 — کد تغییر نکرد):**
- ✅ زیرساخت موجود و کافی — «LocalizationManager» جدید لازم نیست:
  · `settingsProvider.uiLanguage` (fa/en، persist در shared_preferences، فقط در Settings ست می‌شود)
  · `app.dart` → `MaterialApp.router(locale: resolvedLocale)` → تغییر زبان بدون restart کل اپ را rebuild می‌کند
  · `AppL10n.t(context, key)` — کاتالوگ مرکزی برچسب‌ها FA/EN (فاز R-6 همه صفحات را پوشش داد)
  · `AppL10n.meaning(context, fa:, en:)` — برای محتوا؛ فعلاً فقط در ۱۱ فایل استفاده شده
- ✅ الگوی مرجع صحیح: modalverben + unregelm + grammar_topic (locale-aware)
- ❌ **۶ سوییچ زبان غیرمجاز خارج از Settings** — `_showFa` state + دکمه AppBar («نمایش انگلیسی/فارسی»):
  dativ_verben_detail · konnektor_detail · verb_praep_detail · trennbar_detail ·
  nvv_detail (+ دکمه EN/FA دوم داخل body!) · reflexiv_detail
- ❌ **۵+ صفحه Dual-Display** (FA و EN هم‌زمان):
  word_detail (meaningFa+meaningEn پشت هم) · flash_card_widget (لایتنر) ·
  word_popup_card (Lesen) · praep_cluster_detail (هدر) ·
  redemittel_1010_detail (کارت جدای 'English' + مثال fa+en)
  → در Step 3 هر batch دوباره فایل‌به‌فایل چک می‌شود (لیست بالا حداقل است)

**Roadmap:**
- [x] **L-Step1** Audit + معماری + آپدیت Plan/Map ✅ (2026-07-07)
- [x] **L-Step2** ✅ (2026-07-07) پاریتی کاتالوگ: fa=en=251 کلید، صفر اختلاف (اسکریپت اجرا شد)
      + helper جدید `AppL10n.isFa(context)` (برای widget های فرزند که flag می‌گیرند)
      + حذف هر ۶ سوییچ غیرمجاز (`_showFa` state + دکمه AppBar + دکمه دوم داخل nvv)
- [x] **L-Step3a** ✅ همان ۶ detail: همه ternary ها → `AppL10n.meaning` / `showFa: AppL10n.isFa(context)`
- [x] **L-Step3b** ✅ word_detail (dual حذف + ۶ عنوان hardcoded فارسی → کلیدهای جدید کاتالوگ:
      pronunciation/conjugation/etymology/common_errors/grammar_note) + word_list_item
      (لیست الان زبان فعال را نشان می‌دهد + plural_label) + flash_card + word_popup.
      memorize_card تغییری نخواست (داده DB تک‌زبانه است، dual نیست)
- [x] **L-Step3c** ✅ redemittel_1010_detail (کارت‌های جدای فارسی/English → یک کارت «زبان فعال»،
      _ExampleCard فقط زبان فعال، مثال/نکته → کلیدهای example/note_label) + praep_cluster_detail
      (هدر + _ExampleTile فقط زبان فعال)
- [x] **L-Step3d** ✅ sweep نهایی — همه گیت‌ها پاس (2026-07-07):
      · Gate1 سوییچ محلی: ۰ (فقط کامنت doc در app_l10n)
      · Gate2 Dual-Display: ۰ (تنها hit، locale-driven showFa در konnektor است — درست)
      · Gate3 ست‌کردن uiLanguage خارج از Settings: ۰
      · Gate4 پاریتی کاتالوگ: fa=en=251
      · Gate5 adoption: ۲۳ فایل feature از AppL10n.meaning/isFa استفاده می‌کنند
      · flutter analyze: No issues
- **قانون/گیت دائمی**: `grep -rn '_showFa' lib/features` = ۰؛ هیچ رندر هم‌زمان
  `meaningFa`+`meaningEn` (و مشابه En/Fa) خارج از `AppL10n.meaning` در UI؛
  زبان فقط از Settings (settingsProvider.uiLanguage)؛ آلمانی هرگز localize نمی‌شود.

### فاز L2 — Massen-Lokalisierung: «هیچ FA در حالت EN» [L2-A..E ✅ / L2-F باز] (2026-07-07)
> شکایت کاربر: با انتخاب English هنوز خیلی جاها فارسی است. Audit: **۶۴۱ رشته FA hardcoded در ۹۸ فایل**
> که هرگز از کاتالوگ رد نمی‌شدند. نتیجه بعد از L2: **لایه UI کامل — ۶۴۱ → ۴۱ (همه ۴۱ عمدی)**.

- [x] **L2-A** Auto-Replace با reverse-catalog (تطبیق دقیق) + حلقه تعمیر خودکار
      (خطاهای const/context → revert همان خط + import خودکار)
- [x] **L2-B** کاتالوگ ۲۵۱ → **۵۳۳ کلید** (fa=en، صفر اختلاف) — دیکشنری دستی ~۲۸۰ ترجمه EN
- [x] **L2-C** الگوی «Key در ساختار const، ترجمه در Render»:
      · **FilterAccordion/FilterChipBar labels از AppL10n.t رد می‌شوند** (fallback: کلید ناشناخته
        → همان رشته برمی‌گردد؛ لیبل‌های آلمانی دست‌نخورده می‌مانند) — همه فیلترها یکجا
      · vox_dialog/vox_empty_state defaults → کلید؛ vox_snack_bar (comingSoon/copied)
      · deck list حفظیات، more/selbstlernen/pruefungen/exam_type/sozialmedien/vorlagen/settings
- [x] **L2-D** Interpolation ها: helper جدید **`AppL10n.tf(ctx, key, {'n': ...})`** با {placeholder}
      (صندوق $box، $x از $y درست، شروع مرور...، imported: n، ...)
- [x] **L2-E** لایه‌های بدون context:
      · مدل‌ها: labelFa های enum (konnektor ×۱۹، caseType، verbClass، reflexiv/trennbar، pomodoro،
        روزهای هفته) → **کلید برمی‌گردانند**، UI با t() ترجمه می‌کند
      · **Formatters.useFa** (از app.dart با هر تغییر locale ست می‌شود): ارقام فارسی/لاتین،
        تاریخ نسبی، ٪/% — در حالت EN دیگر «۱۲۳» دیده نمی‌شود
      · **AppL10n.activeLang + ts(key)**: ترجمه استاتیک برای notification_service
- [x] گیت‌ها: analyze سبز؛ پاریتی ۵۳۳=۵۳۳؛ باقیمانده UI = ۴۱ رشته **عمدی**:
      formatters (شاخه‌های FA پشت useFa)، content_registry (seed دیتابیس)، parser_registry
      و import_screen (نمونه‌های فرمت با کلمه فارسی)، «فارسی» به‌عنوان نام زبان (settings/redemittel)
- [→] **L2-F** در فاز L3 ادغام شد (پایین — L3-D)

### فاز L3 — Content-Zweisprachigkeit: همه محتواها FA+EN [کامل ✅] (2026-07-07)
> شکایت کاربر: بعضی صفحات هنوز **محتوایشان** فارسی است (مثال ۱: Auswendiglernen →
> unregelmäßige Verben → معنی جمله‌ی مثال؛ مثال ۲: Grammatik → trennbare Verben).
> Audit کامل انجام شد — دو کلاس مشکل:
> **A) کد**: داده EN دارد ولی Screen فقط `Fa` را render می‌کند (ارزان — کد)
> **B) داده**: JSON اصلاً فیلد `_en` ندارد یا خالی است (نگارش EN لازم)
> **نتیجه: هر دو کلاس حل شد. asset-audit = ۰ فیلد fa بدون en. کاتالوگ ۵۶۵=۵۶۵.
> precise-gate (Text مستقیم روی رشته FA) = ۰ در صفحات content. analyze سبز.**

- [x] **L3-A** رفع کلاس A — Screen ها که EN موجود را نادیده می‌گرفتند ✅ (2026-07-07):
      · unregelm_detail + unregelm_quiz: exampleFa → AppL10n.meaning ← **مثال ۱ کاربر**
      · trennbar_grammar_screen: کاملاً دوزبانه شد ← **مثال ۲ کاربر** — JSON از اول
        title_en/overview_en/explanation_en/tips_en/... داشت، Screen فقط `_fa` می‌خواند!
        + الگوی helper `_loc(context, map, 'base')` معرفی شد (en با fallback به fa)
        + باگ: `_ExPair` کلیدهای ناموجود (trennbar_fa/untrennbar_fa) می‌خواند —
        جفت‌های مثال اصلاً render نمی‌شدند → به کلیدهای واقعی (verb_separable/
        meaning_separable_fa/en/...) وصل شد
      · dativ_quiz ×۲ · verb_praep_quiz ×۲ · praep_quiz (meaningEn/exampleEn به
        _QuizItem اضافه شد) · nvv_quiz (مثال + **گزینه‌های آزمون** locale-aware —
        با AppL10n.activeLang چون _buildOptions در initState اجرا می‌شود)
      · add_word preview · dativ_grammar مثال‌ها (ex['fa']/['en'])
      · flutter analyze: سبز ✅
- [x] **L3-B** ✅ داده‌های کوچک + مدل کاتالوگ گرامر:
      · `grammatik_katalog.json` → satzglieder[] فیلد en اضافه شد (۷)
      · مدل `KatalogEintrag`+`KatalogSatzglied` حالا `en` می‌خوانند →
        `katalog_eintrag_tile` + home tiles locale-aware (AppL10n.meaning)
      · `dativ_akkusativ_grammar.json` → title_en اضافه شد
- [x] **L3-C** ✅ نگارش EN برای همه JSON های ناقص (asset-audit نهایی = ۰):
      · redemittel_1010/redemittel/goethe_b2/oesd_b2: **۱٬۱۸۴ section_title_en**
        (dedup: فقط ۱۲۳ عنوان یکتا ترجمه شد → روی همه اعمال) + مدل sectionTitleEn +
        controller grouping + هر دو list screen locale-aware
      · unregelm_verb_grammar (۷۱) · reflexiv_data non_reflexive (۵۴) ·
        verb_praep_grammar (۳۵) · reflexiv_grammar (۵۴) · konnektoren_grammar (۷۱) ·
        konnektoren_rich (۱۲۱ — +مدل GrammarSummary/ConfusableContrast/TranslationExercise en)
      · **helper مرکزی `AppL10n.loc(context, map, 'base')`** ساخته شد (Puzzling) →
        screens: reflexiv/unregelm/verb_praep/konnektoren/dativ _grammar + trennbar +
        konnektor_detail (structure/position/mistake/difference En) + konnektoren_quiz (promptEn)
- [x] **L3-D** ✅ (= L2-F سابق) همه رشته‌های hardcoded محتوا در ۱۰ صفحه دوزبانه شدند:
      · تیترهای تکراری section → کلید کاتالوگ (full_explanation, key_tips, ...)
      · محتوای یکتا → `AppL10n.meaning(context, fa:, en:)` inline یا رکورد +En field:
        fragen (Q&A رکورد +qEn/aEn) · privacy · leitfaden (رکورد +labelEn/descEn/skillsEn) ·
        nvv_grammar · praep_grammar · redemittel_1010_grammar (patternMeta → ۶-tuple +en) ·
        konnektoren/dativ/verb_praep _grammar
      · لیست‌های کلمات آلمانی (nvv/praep collocations): جداکننده ، → , (محتوا آلمانی است)
      · precise-gate: هیچ `Text('رشته‌ی FA')` مستقیم بدون meaning باقی نماند
- [x] **L3-E** ✅ (2026-07-07) لایه دیتابیس/ورودی:
      · MemorizeItems ستون `meaningEn` nullable اضافه شد + **schemaVersion 1→2 با
        onUpgrade migration** (addColumn) + build_runner regen
      · UI locale-aware: memorize_card (back)، cloze_practice، category_items (subtitle)،
        search_controller (activeLang) — همه با AppL10n.meaning / activeLang
      · import_service فیلد `meaning_en` را می‌خواند + نمونه JSON در import_screen به‌روز شد
- **⭐ قانون دائمی (از الان برای همیشه — در MAP اصل ۵ هم ثبت شد):**
  هر محتوای جدید از **اول** دوزبانه اضافه می‌شود:
  ۱) JSON: هر فیلد متنی زبان دوم = جفت `*_fa` + `*_en` (آلمانی `*_de` جدا و تغییرناپذیر)
  ۲) Screen: هرگز `xxxFa` مستقیم render نشود — فقط AppL10n.meaning/isFa یا الگوی `_loc`
  ۳) برچسب UI: فقط کلید کاتالوگ، هم‌زمان در fa و en
  ۴) گیت‌های پایان کار: analyze سبز · پاریتی کاتالوگ · asset-audit (هیچ `_fa` بدون `_en`
     در فایل جدید) · grep render مستقیم Fa = ۰

### Phase 13 — Redemittel 1010 ✅ (2026-07-04)
- [x] assets/data/redemittel_1010.json — ۹۰۸ عبارت از ۹۳ بخش (Diskussion · Essay · Brief · Bewerbung · Vortrag · Grafik ...)
      فیلدها: phrase_de/fa/en، section_title_de/fa، grammar_pattern، register، cefr_level، topic،
      structure_after، example_de/fa/en، fill_blank_target، distractors، note
- [x] lib/features/redemittel/models/redemittel_item.dart — model غنی با همه فیلدها
- [x] lib/features/redemittel/controllers/redemittel_controller.dart — FutureProvider + Redemittel1010Filter + filteredProvider + groupBySectionTitle
- [x] lib/features/redemittel/screens/redemittel_1010_list_screen.dart — لیست با جستجو + ۴ فیلتر (CEFR/Topic/Register/Grammar) + section grouping + FAB quiz
- [x] lib/features/redemittel/screens/redemittel_1010_detail_screen.dart — detail با badges + example card + grammar structure
- [x] lib/features/redemittel/screens/redemittel_1010_quiz_screen.dart — ۴ نوع (multiChoice/matchMeaning/fillBlank/wordOrder)
- [x] lib/features/redemittel/screens/redemittel_1010_grammar_screen.dart — pattern cards با توضیح + register overview
- [x] AppRoutes: /redemittel-1010، /quiz، /grammar، /:phraseId
- [x] app_router.dart: routes کامل Redemittel1010
- [x] auswendiglernen_home_screen.dart: deck فعال «1010 Redemittel» (comingSoon → active)
- [x] grammatik_home_screen.dart: tile Redemittel 1010 → /grammar

### Phase 12 — Unregelmäßige Verben ✅ (2026-07-03)
- [x] assets/data/unregelm_verb_data.json — ۱۷۰ فعل (stark/gemischt/modal/irregular)، encoding-fixed
- [x] assets/data/unregelm_verb_grammar.json — ۱۱ بخش گرامری (verb_types → tips)
- [x] lib/features/unregelm_verben/models/unregelm_verb.dart — model با VerbClass + PerfektAuxiliary enum
- [x] lib/features/unregelm_verben/controllers/unregelm_controller.dart — FutureProvider + filter (level/class/topic)
- [x] lib/features/unregelm_verben/screens/unregelm_list_screen.dart — لیست با جستجو + فیلتر (Niveau/Typ/Thema)
- [x] lib/features/unregelm_verben/screens/unregelm_detail_screen.dart — principal parts table + auxiliary badge
- [x] lib/features/unregelm_verben/screens/unregelm_quiz_screen.dart — ۴ نوع (MC/match/word-order/cloze-Präteritum)
- [x] lib/features/unregelm_verben/screens/unregelm_grammar_screen.dart — ۱۱ نوع section با dispatcher
- [x] lib/features/unregelm_verben/widgets/verb_class_badge.dart — badge per class + AuxiliaryBadge
- [x] AppRoutes: /unregelm-verben، quiz، grammar، /:verbId
- [x] app_router.dart: routes کامل UnregelmVerben
- [x] auswendiglernen_home_screen.dart: deck فعال «Unregelmäßige Verben» (comingSoon حذف)
- [x] grammatik_home_screen.dart: tile Unregelmäßige Verben
- [x] app_l10n.dart: کلیدهای unregelm_title و search_unregelm

### Phase 11 — Verben mit Präpositionen ✅ (2026-07-03)
- [x] assets/data/verb_praep_data.json — ۷۲ فعل با حرف اضافه ثابت (Akk/Dat)، encoding-fixed
- [x] assets/data/verb_praep_grammar.json — ۹ بخش گرامری (what_and_why → tips)
- [x] lib/features/verb_praep/models/verb_praep.dart — model با PrepositionCase enum + VerbPraepParts
- [x] lib/features/verb_praep/controllers/verb_praep_controller.dart — FutureProvider + filter (level/case/topic)
- [x] lib/features/verb_praep/screens/verb_praep_list_screen.dart — لیست با جستجو + فیلتر (Niveau/Kasus/Thema)
- [x] lib/features/verb_praep/screens/verb_praep_detail_screen.dart — detail با wo-compound و preposition_with_person
- [x] lib/features/verb_praep/screens/verb_praep_quiz_screen.dart — ۴ نوع سوال (MC/match/word-order/cloze-prep)
- [x] lib/features/verb_praep/screens/verb_praep_grammar_screen.dart — ۹ نوع section با dispatcher
- [x] lib/features/verb_praep/widgets/prep_case_badge.dart — badge آبی/سبز per Akkusativ/Dativ
- [x] AppRoutes: /verb-praep، /verb-praep/quiz، /verb-praep/grammar، /verb-praep/:verbId
- [x] app_router.dart: routes کامل VerbPraep
- [x] auswendiglernen_home_screen.dart: deck فعال «Verben mit Präpositionen»
- [x] grammatik_home_screen.dart: tile Verben mit Präpositionen
- [x] app_l10n.dart: کلیدهای verb_praep_title و search_verb_praep

### Phase 10 — Trennbare / Untrennbare Verben ✅ (2026-07-03)
- [x] assets/data/trennbar_data.json — ۱۱۰ فعل (trennbar/untrennbar/wechselpraefix)، encoding-fixed
- [x] assets/data/trennbar_grammar.json — overview، categories، grammar_rules، prefix_meaning_table، tips
- [x] lib/features/trennbar_verben/models/trennbar_verb.dart — model با PrefixType enum
- [x] lib/features/trennbar_verben/controllers/trennbar_controller.dart — FutureProvider + filter
- [x] lib/features/trennbar_verben/screens/trennbar_list_screen.dart — لیست با جستجو + فیلتر
- [x] lib/features/trennbar_verben/screens/trennbar_detail_screen.dart — detail + ناوبری prev/next
- [x] lib/features/trennbar_verben/screens/trennbar_quiz_screen.dart — ۴ نوع سوال (MC/match/word-order/cloze)
- [x] lib/features/trennbar_verben/screens/trennbar_grammar_screen.dart — categories + rules + prefix table + tips
- [x] lib/features/trennbar_verben/widgets/prefix_type_badge.dart — badge رنگی per نوع
- [x] AppRoutes: /trennbar، /trennbar/quiz، /trennbar/grammar، /trennbar/:verbId
- [x] app_router.dart: routes کامل Trennbarverben
- [x] auswendiglernen_home_screen.dart: deck فعال‌سازی (حذف comingSoon)
- [x] grammatik_home_screen.dart: tile Trennbare / Untrennbare Verben
- [x] app_l10n.dart: کلیدهای trennbar_title و search_trennbar

### Phase 9 — Reflexivverben ✅ (2026-07-03)
- [x] assets/data/reflexiv_data.json — ۱۱۴ فعل انعکاسی (echte/unechte/dativ_reflexive)
- [x] assets/data/reflexiv_grammar.json — ۱۰ بخش گرامری
- [x] lib/features/reflexiv_verben/models/reflexiv_verb.dart — model با ReflexivityType enum
- [x] lib/features/reflexiv_verben/controllers/reflexiv_controller.dart — FutureProvider + filter
- [x] lib/features/reflexiv_verben/screens/reflexiv_list_screen.dart — لیست با جستجو + فیلتر
- [x] lib/features/reflexiv_verben/screens/reflexiv_detail_screen.dart — detail + ناوبری prev/next
- [x] lib/features/reflexiv_verben/screens/reflexiv_quiz_screen.dart — ۴ نوع سوال (MC/match/word-order/cloze)
- [x] lib/features/reflexiv_verben/screens/reflexiv_grammar_screen.dart — ۱۰ بخش گرامری
- [x] lib/features/reflexiv_verben/widgets/reflexivity_type_badge.dart — badge رنگی per نوع
- [x] AppRoutes: /reflexiv، /reflexiv/quiz، /reflexiv/grammar، /reflexiv/:verbId
- [x] app_router.dart: routes کامل Reflexivverben
- [x] auswendiglernen_home_screen.dart: deck فعال‌سازی Reflexivverben (حذف comingSoon)
- [x] app_l10n.dart: کلیدهای reflexiv_title و search_reflexiv

### Phase 8 — انتشار (فاز ۱۶)
> بعد از همه phase‌های بالا
- [ ] 16.1 تست دستی iOS Simulator
- [ ] 16.2 تست دستی Android Emulator
- [ ] 16.3 تست RTL فارسی همه صفحات
- [ ] 16.4 تست آفلاین (airplane mode)
- [x] 16.5 آیکون در assets/images/app_icon.png + app_icon_fg.png ✅ (2026-07-03) — 1254×1254px
- [x] 16.6 dart run flutter_launcher_icons ✅ (2026-07-03) — Android adaptive + iOS generated
- [x] 16.7 dart run flutter_native_splash:create ✅ (2026-06-30) — light #F5F5FA / dark #0A0A0F
- [x] 16.8 RevenueCat API keys واقعی در main.dart ✅ (2026-06-30) — test_*** (Key entfernt)
- [x] 16.8b RevenueCat SDK کامل ✅ (2026-06-30)
      purchases_ui_flutter اضافه، subscription_service.dart (Riverpod)، paywall + customer center
- [ ] 16.9 App Store Connect + Google Play metadata
- [ ] 16.10 flutter build ios --release + flutter build appbundle --release
- [ ] 16.11 TestFlight + internal Android test track
- [ ] 16.12 submit review

---

## فازهای تکمیل‌شده (آرشیو)
| فاز | عنوان | وضعیت |
|-----|--------|--------|
| ۰   | Foundation | ✅ |
| ۱   | Wortschatz | ✅ |
| ۲   | Leitner | ✅ |
| ۳   | User Categories | ✅ |
| ۴   | Grammatik | ✅ |
| ۵   | Lesen | ✅ |
| ۶   | Hören | ✅ |
| ۷   | Auswendiglernen | ✅ |
| ۸   | Prüfungen | ✅ |
| ۹   | Selbstlernen | ✅ |
| ۱۰  | More/Settings | ✅ |
| ۱۱  | Global Search | ✅ |
| ۱۲  | Import | ✅ |
| ۱۳  | Sprechen/Schreiben stubs | ✅ |
| ۱۴  | Polish & QA | ✅ کد (تست دستی باقی) |
| ۱۵  | Launch prep | ✅ کد (signing + store باقی) |
| R13 | Redemittel 1010 — ۹۰۸ عبارت | ✅ 2026-07-04 |

---

## تصمیمات تکنیکی
| موضوع | تصمیم | دلیل |
|-------|--------|------|
| State | flutter_riverpod (manual) | بدون codegen boilerplate |
| DB | drift (SQLite) | type-safe، offline |
| Router | go_router | declarative، deep link |
| Audio | just_audio + flutter_tts | بهترین Flutter audio |
| Charts | fl_chart | محبوب‌ترین Flutter chart |
| Subscriptions | RevenueCat | iOS+Android یک SDK |
| Font | Vazirmatn (google_fonts) | FA+DE+EN یک فونت |
| Color API | withValues(alpha:) | withOpacity deprecated |
| L10n | strings در app_l10n.dart | بدون .arb files |
| DAO | Plain Dart class | بدون @DriftAccessor |
| Upsert | DoUpdate(target:[german,wordType]) | UNIQUE constraint صحیح |
