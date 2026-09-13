# UI/UX Design — ماژول Konnektoren

**وضعیت:** پیش‌نویس — نام کامپوننت‌های بصری موجود نیاز به تأیید لوکاس دارد (بخش ۶)

---

## ۱. معماری داده

```
konnektoren_data.json     ← لایه ۱: ۱۸۶ مدخل — فیلتر، جستجو، تمرین خودکار
konnektoren_rich.json     ← لایه ۲: ۲۲ مدخل کامل — صفحه اختصاصی هر کانکتور
konnektoren_grammar.json  ← گرامر ساختاری با ارجاع به id — صفحه گرامر
```

**اتصال بدون duplicate:**
- `Wortschatz`: فیلتر `type == connector` روی `konnektoren_data.json`
- `Grammatik`: `konnektoren_grammar.json` مستقیم
- موتور آزمون: `exercise_pool` از `konnektoren_rich.json` + ساخت خودکار از لایه ۱

---

## ۲. صفحه اول — Home (دسته‌بندی)

### Tab 1: بر اساس نوع (`connector_type`)

| نوع | تعداد | رنگ badge | توضیح |
|---|---|---|---|
| `nullposition` | ۶ | 🔵 آبی تیره | هیچ تأثیری روی ترتیب |
| `nebensatz` | ۵۲ | 🟢 سبز | فعل به آخر |
| `adverbial` | ۵۹ | 🟠 نارنجی | Inversion در Pos1 |
| `doppelkonnektor` | ۱۳ | 🟣 بنفش | دو بخشی |
| `praeposition` | ۳۹ | 🟤 قهوه‌ای | حرف اضافه + Genitiv/Dativ |
| `relativsatz` | ۱۷ | 🔴 قرمز | ضمیر نسبی + فعل آخر |

### Tab 2: بر اساس سطح (`cefr_level`)
A1 (6) → A2 (23) → B1 (56) → B2 (58) → C1 (42) → C2 (1)

### Tab 3: بر اساس نقش معنایی (`semantic_role`)
causal · concessive · temporal · conditional · consecutive · adversative · additive · alternative · modal · relative · correlative

### Tab 4: بر اساس تأثیر گرامری (`word_order_effect`)
- `verb_end` — فعل آخر (nebensatz + relativsatz)
- `inversion` — Inversion (adverbial)
- `no_change` — بدون تغییر (nullposition + praeposition)
- `variable` — بسته به موقعیت (doppelkonnektor)

---

## ۳. Card کانکتور در لیست

```
┌────────────────────────────────────────────────┐
│  weil                    [nebensatz] [A2]       │
│  چون، زیرا · because                           │
│  ─────────────────────────────────────────────  │
│  Ich bleibe zu Hause, weil es regnet.           │
└────────────────────────────────────────────────┘
```

**عناصر:**
- `connector` — فونت بزرگ
- Badge `connector_type` — رنگ از جدول بالا
- Badge `cefr_level`
- `meaning_fa` · `meaning_en` (toggle)
- `example_de` — یک خط

---

## ۴. صفحه اختصاصی هر کانکتور

ترتیب از بالا به پایین:

```
┌────────────────────────────────────────────────┐
│                    weil                         │
│            [nebensatz]  [A2]  [neutral]         │
│  ─────────────────────────────────────────────  │
│  چون، زیرا  ·  because                         │
│  ─────────────────────────────────────────────  │
│  📐 گرامر                                       │
│  ساختار: جمله + , + weil + فاعل + ... + فعل   │
│  ⚠️ weil ich bin müde ❌ → weil ich müde bin ✓  │
│  ─────────────────────────────────────────────  │
│  💡 مثال‌ها                                      │
│  Ich bleibe zu Hause, weil es [regnet].         │  ← رنگی
│  Sie lernt viel, weil sie die Prüfung          │
│      [bestehen will].                           │  ← رنگی
│  Er kommt nicht, weil er krank [ist].          │  ← رنگی
│  ─────────────────────────────────────────────  │
│  🔄 مقایسه با مشابه‌ها                           │
│  da    وقتی دلیل از قبل مشخص است               │
│  denn  فعل را جابجا نمی‌کند                    │
│  ─────────────────────────────────────────────  │
│  🏷️ [causal]  [inversion]  [general]            │
│  ─────────────────────────────────────────────  │
│  ◀ bevor                          nachdem ▶     │
└────────────────────────────────────────────────┘
```

**پیاده‌سازی `highlight`:**
فیلد `highlight` در لایه ۲ حاوی رشته‌ای است که در متن آلمانی باید رنگی نمایش داده شود. Swift با جستجوی این رشته در `example_de` و wrap کردن آن در `AttributedString` با رنگ accent این را پیاده‌سازی می‌کند.

**شرط نمایش لایه ۲:**
- اگر `id` در `konnektoren_rich.json` موجود بود → نمایش کامل
- اگر نبود → نمایش ساده (فقط لایه ۱: معنی + مثال + badge‌ها)

---

## ۵. موتور آزمون

### ۴ نوع تمرین از `exercise_pool`:

**۱. `fill_blank` — جای‌خالی**
```
Ich bleibe zu Hause, ___ es regnet.

[deshalb]  [weil ✓]  [obwohl]
```
- گزینه‌ها از `distractor_ids` + پاسخ درست → shuffle
- بازخورد فوری + توضیح کوتاه

**۲. `word_order` — ترتیب کلمات**
```
جمله: Er schläft früh, ___
کلمات: [weil] [er] [müde] [ist]
→ کشیدن و رها کردن به ترتیب درست
```

**۳. `multiple_choice` — چهارگزینه‌ای**
```
Er bleibt zu Hause, ___ er krank ist.
○ weil ✓
○ deshalb
○ trotzdem  
○ obwohl
```

**۴. `translation` — ترجمه**
```
نمی‌آید چون مریض است.
→ [Er kommt nicht, weil er krank ist.]
```

### منطق انتخاب سؤال:
- فیلتر اختیاری: `connector_type` / `cefr_level` / `semantic_role`
- اگر `exercise_pool` موجود: مستقیم از آن
- اگر نه: ساخت خودکار `fill_blank` از `example_de` + `confusable_with` به‌عنوان distractor

---

## ۶. کامپوننت‌های بصری

> **⚠️ قبل از نهایی‌سازی این بخش، تأیید لوکاس لازم است.**

### کامپوننت‌های احتمالاً موجود (از NVV/Dativ)
| نام احتمالی | کاربرد |
|---|---|
| `LevelBadgeView` | badge A1-C2 |
| `PrimaryButtonStyle` | دکمه‌های اصلی |
| `AppColors` | پالت رنگی |
| `CardView` | card کانکتور در لیست |

### کامپوننت‌های احتمالاً جدید (نیاز به ساخت)
| نام پیشنهادی | کاربرد | وضعیت |
|---|---|---|
| `ConnectorTypeBadge` | badge رنگی ۶ نوع | جدید — مشترک آینده |
| `WordOrderBadge` | badge verb_end/inversion/... | جدید — مشترک آینده |
| `HighlightedExampleView` | هایلایت کلمه در جمله آلمانی | جدید — مشترک آینده |
| `ConfusableContrastCard` | کارت مقایسه با مشابه‌ها | جدید — مشترک آینده |
| `DragDropWordOrder` | تمرین ترتیب کلمات | جدید — مختص این ماژول |

---

## ۷. Swift Data Model (پیشنهادی)

```swift
// لایه ۱
struct Konnektor: Codable, Identifiable {
    let id: Int
    let connector: String
    let connectorType: String
    let wordOrderEffect: String
    let semanticRole: String
    let partA: String?
    let partB: String?
    let caseGovernance: String?
    let meaningFa: String
    let meaningEn: String
    let register: String
    let cefrLevel: String
    let topic: String
    let exampleDe: String
    let exampleFa: String
    let exampleEn: String
    let confusableWith: [Int]
    let note: String
    
    enum CodingKeys: String, CodingKey {
        case id, connector
        case connectorType = "connector_type"
        case wordOrderEffect = "word_order_effect"
        case semanticRole = "semantic_role"
        case partA = "part_a"
        case partB = "part_b"
        case caseGovernance = "case_governance"
        case meaningFa = "meaning_fa"
        case meaningEn = "meaning_en"
        case register
        case cefrLevel = "cefr_level"
        case topic
        case exampleDe = "example_de"
        case exampleFa = "example_fa"
        case exampleEn = "example_en"
        case confusableWith = "confusable_with"
        case note
    }
}

// لایه ۲
struct KonnektorRich: Codable, Identifiable {
    let id: Int
    let connector: String
    let grammarSummary: GrammarSummary
    let examples: [RichExample]
    let confusableContrast: [ConfusableContrast]
    let exercisePool: [Exercise]
    
    // ... (CodingKeys مشابه)
}
```

---

## ۸. فایل‌های Xcode

| فایل | مسیر پیشنهادی | target membership |
|---|---|---|
| `konnektoren_data.json` | `Resources/Konnektoren/` | ✅ اپ |
| `konnektoren_rich.json` | `Resources/Konnektoren/` | ✅ اپ |
| `konnektoren_grammar.json` | `Resources/Konnektoren/` | ✅ اپ |
| `konnektoren_data.jsonl` | `Documentation/` | ❌ (فایل کاری) |
| `konnektoren_rich.jsonl` | `Documentation/` | ❌ (فایل کاری) |
| `konnektoren_master_prompt.md` | `Documentation/` | ❌ |
| `konnektoren_sources.md` | `Documentation/` | ❌ |
| `konnektoren_ui_design.md` | `Documentation/` | ❌ |

