# پرامپت اصلی پروژه: Konnektoren — تبدیل لیست به دیتای اپ Xcode + محتوای آموزشی + طراحی صفحات + آزمون

**این یک سند اجرایی برای خودِ Claude است، نه یک گفتگوی معمولی.** هر بار این سند آپلود شد، Claude مستقیم می‌رود سراغ «نقشه راه مرحله‌ای» (بخش ۱۲)، چک‌لیست را می‌بیند و از مرحله‌ی بعدیِ تیک‌نخورده ادامه می‌دهد — بدون سؤال اضافه، مگر چیزی واقعاً مبهم باشد.

---

## ۰. زمینه‌ی پروژه

این سومین زیرپروژه‌ی دیتای اپ زبان‌آموزی آلمانی لوکاسه (بعد از Nomen-Verb-Verbindung و Dativ-Akkusativ-Verben). موضوع: **Konnektoren** — کلماتی که جملات را به هم وصل می‌کنند یا موقعیت فعل را در جمله تعیین می‌کنند.

برخلاف دو پروژه‌ی قبلی که فقط JSON دیتا تولید کردند، این پروژه **دو لایه‌ی خروجی مستقل** دارد:

**لایه ۱ — JSON ساختاریافته (برای Xcode/Swift):**
داده‌ی خلاصه‌ی هر کانکتور برای فیلتر، جستجو، دسته‌بندی، و ساخت تمرین خودکار.

**لایه ۲ — JSON آموزشی غنی (برای صفحه‌ی اختصاصی هر کانکتور در اپ):**
محتوای کامل هر کانکتور — معنی، گرامر، مقایسه با مشابه‌ها، اشتباهات رایج، و چند مثال متنوع — به فرمت JSON قابل parse توسط Swift.

علاوه بر این، پروژه شامل **محتوای گرامری مستقل** و **طراحی UI/UX** هم هست (مثل پروژه‌ی Dativ).

---

## ۱. یادآوری خودکار — چه چیزی از پروژه‌های قبلی به ارث می‌رسد

### از NVV و Dativ عیناً تکرار می‌شود:
- فرمت کاری: **jsonl** قابل‌append/resume → در پایان تبدیل به **json** آرایه‌ای
- `id` برای هر مدخل، برای resume در گفتگوی جدید
- تعیین `cefr_level` / `register` / `topic` به‌صورت **per-item**
- فقط **یک** مثال اصلی در سطح خودِ cefr_level
- فیلد `note` پیش‌فرض خالی؛ فقط وقتی واقعاً ارزش‌افزوده دارد
- بعد از هر مرحله: `present_files` + توقف و انتظار تأیید لوکاس
- `meaning_en` و `example_en` باید **تازه نوشته شوند**
- مرحله‌ی مجزا برای افزودن موارد مهمی که در منبع خام نیستند
- **ID-based cross-referencing**: فایل گرامر و UI فقط به `id` ارجاع می‌دهند، نه رشته‌ی متنی
- **Design system reuse**: ارجاع به کامپوننت‌های بصری موجود اپ، نه طراحی از صفر
- چک کامل‌بودن لیست با حداقل ۳ سایت مرجع + مقایسه با منبع قوی (هدف >۹۰٪ همپوشانی)

### چیزهایی که این پروژه دارد و قبلی‌ها نداشتند:

| موضوع | توضیح |
|---|---|
| **دو لایه‌ی JSON** | لایه‌ی ۱ خلاصه برای Swift/فیلتر/تمرین، لایه‌ی ۲ محتوای آموزشی غنی برای صفحه‌ی اختصاصی |
| **`connector_type`** | هسته‌ی اصلی: `nullposition` / `nebensatz` / `adverbial` / `doppelkonnektor` / `praeposition` / `relativsatz` |
| **`word_order_effect`** | مهم‌ترین ویژگی دستوری: `verb_end` / `inversion` / `no_change` / `variable` |
| **`part_a` / `part_b`** | فقط برای `doppelkonnektor` — دو بخش جدا برای تمرین و توضیح گرامر |
| **`confusable_with`** | آرایه‌ای از id کانکتورهای هم‌معنی/قابل‌اشتباه — برای contrastive learning (مثل `deshalb` vs `weil` vs `daher`) |
| **محتوای آموزشی غنی (لایه ۲)** | ساختار ۷-بخشی بهینه‌شده برای هر کانکتور، قابل parse توسط Swift |
| **`semantic_role`** | نقش معنایی کانکتور: `causal` / `concessive` / `temporal` / `conditional` / `consecutive` / `adversative` / `additive` / `alternative` / `modal` و... |
| **Präpositionen با حالت دستوری** | فیلد `case_governance`: `dativ` / `genitiv` / `akkusativ` / `variable` — فقط برای `praeposition` |

---

## ۲. Schema لایه‌ی ۱ — JSON ساختاریافته (هر کانکتور = یک object)

```json
{
  "id": 1,
  "connector": "weil",
  "connector_type": "nebensatz",
  "word_order_effect": "verb_end",
  "semantic_role": "causal",
  "part_a": null,
  "part_b": null,
  "case_governance": null,
  "meaning_fa": "چون، زیرا",
  "meaning_en": "because",
  "register": "neutral",
  "cefr_level": "A2",
  "topic": "general",
  "example_de": "Ich bleibe zu Hause, weil es regnet.",
  "example_fa": "در خانه می‌مانم چون باران می‌بارد.",
  "example_en": "I'm staying home because it's raining.",
  "confusable_with": [12, 34],
  "note": ""
}
```

### توضیح فیلدها:

| فیلد | توضیح | الزامی؟ |
|---|---|---|
| `id` | شماره‌ی ردیابی (مستقل از NVV و Dativ) | بله |
| `connector` | کانکتور در حالت پایه (حروف کوچک) | بله |
| `connector_type` | یکی از ۶ نوع (بخش پایین) | بله |
| `word_order_effect` | اثر روی ترتیب فعل | بله |
| `semantic_role` | نقش معنایی | بله |
| `part_a` / `part_b` | فقط برای doppelkonnektor — مثلاً `"nicht nur"` / `"sondern auch"` | فقط doppelkonnektor |
| `case_governance` | فقط برای praeposition — حالت دستوری مفعول | فقط praeposition |
| `meaning_fa` | معنی فارسی | بله |
| `meaning_en` | معنی انگلیسی — **تازه نوشته شود** | بله |
| `register` | `formal` / `neutral` / `colloquial` | بله |
| `cefr_level` | A1 تا C2 | بله |
| `topic` | از enum بخش ۴ | بله |
| `example_de` | جمله‌ی مثال | بله |
| `example_fa` | ترجمه فارسی مثال | بله |
| `example_en` | ترجمه انگلیسی — **تازه نوشته شود** | بله |
| `confusable_with` | آرایه‌ای از `id`های کانکتورهای هم‌معنی/قابل‌اشتباه | نه — پیش‌فرض `[]` |
| `note` | الگوی دوگانه، استثنا، یا cross-ref مهم | نه — پیش‌فرض `""` |

### مقادیر enum برای `connector_type`:
- `nullposition` — فعل را جابجا نمی‌کند (aber, denn, oder, und, sondern, doch)
- `nebensatz` — فعل را به آخر می‌برد (weil, wenn, obwohl, bevor, während, ob...)
- `adverbial` — در Pos1 → فعل قبل از فاعل (deshalb, trotzdem, jedoch, danach...)
- `doppelkonnektor` — دو بخشی (nicht nur...sondern auch, weder...noch, je...desto...)
- `praeposition` — حرف اضافه با Dativ/Genitiv (gemäß, zufolge, trotz, wegen...)
- `relativsatz` — ضمیر نسبی — فعل به آخر (der, die, das, welcher, wer, was...)

### مقادیر enum برای `word_order_effect`:
- `verb_end` — فعل به انتها می‌رود (nebensatz, relativsatz)
- `inversion` — فاعل و فعل جا عوض می‌کنند (adverbial در Pos1)
- `no_change` — هیچ تغییری (nullposition)
- `variable` — بسته به موقعیت در جمله (doppelkonnektor، بعضی praeposition)

### مقادیر enum برای `semantic_role`:
`causal` | `concessive` | `temporal` | `conditional` | `consecutive` | `adversative` | `additive` | `alternative` | `modal` | `relative` | `prepositional` | `correlative`

---

## ۳. Schema لایه‌ی ۲ — JSON آموزشی غنی (هر کانکتور = یک object جدا)

این لایه برای صفحه‌ی اختصاصی هر کانکتور در اپ است. ساختار ۷-بخشی بهینه‌شده — بخش‌هایی که در فرمت `zufälligerweise` بودند اما بدردنخور بودند حذف شده‌اند:

```json
{
  "id": 1,
  "connector": "weil",
  "grammar_summary": {
    "structure_fa": "جمله اصلی + weil + فاعل + ... + فعل (آخر)",
    "position_note_fa": "weil همیشه Nebensatz می‌سازد — فعل حتماً آخر می‌رود",
    "common_mistake_fa": "weil ich bin müde ❌ → weil ich müde bin ✓"
  },
  "examples": [
    {
      "de": "Ich bleibe zu Hause, weil es regnet.",
      "fa": "در خانه می‌مانم چون باران می‌بارد.",
      "en": "I'm staying home because it's raining.",
      "highlight": "regnet"
    },
    {
      "de": "Sie lernt viel, weil sie die Prüfung bestehen will.",
      "fa": "زیاد درس می‌خواند چون می‌خواهد امتحان را قبول شود.",
      "en": "She studies a lot because she wants to pass the exam.",
      "highlight": "bestehen will"
    },
    {
      "de": "Er kommt nicht, weil er krank ist.",
      "fa": "نمی‌آید چون مریض است.",
      "en": "He's not coming because he's sick.",
      "highlight": "ist"
    }
  ],
  "confusable_contrast": [
    {
      "connector_id": 12,
      "connector": "da",
      "difference_fa": "da وقتی دلیل از قبل مشخص است استفاده می‌شود؛ weil برای دلیل جدید"
    },
    {
      "connector_id": 34,
      "connector": "deshalb",
      "difference_fa": "deshalb نتیجه را بیان می‌کند (Hauptsatz)؛ weil دلیل را (Nebensatz)"
    }
  ],
  "exercise_pool": [
    {
      "type": "fill_blank",
      "prompt_de": "Ich bleibe zu Hause, ___ es regnet.",
      "answer": "weil",
      "distractor_ids": [34, 7]
    },
    {
      "type": "word_order",
      "words": ["weil", "ich", "müde", "bin"],
      "correct": "weil ich müde bin",
      "context": "Er schläft früh, ___"
    },
    {
      "type": "multiple_choice",
      "prompt_de": "Er bleibt zu Hause, ___ er krank ist.",
      "options": ["weil", "deshalb", "trotzdem", "obwohl"],
      "answer_index": 0
    },
    {
      "type": "translation",
      "prompt_fa": "نمی‌آید چون مریض است.",
      "answer_de": "Er kommt nicht, weil er krank ist."
    }
  ]
}
```

### چرا این ۷ بخش؟ (تصمیم ضدِ روند نزولی)

**نگه داشته شد:**
- `grammar_summary` — هسته‌ی گرامری: ساختار + موقعیت + اشتباه رایج (سه چیز در یک بخش، بدون بادکردن)
- `examples` — ۳ مثال با `highlight` (فیلد هایلایت مستقیماً در UI برای رنگ‌کردن فعل استفاده می‌شود)
- `confusable_contrast` — تمایز با هم‌معنی‌ها (ارزش آموزشی بالا، با id-reference)
- `exercise_pool` — ۴ نوع تمرین آماده برای موتور آزمون

**حذف شد (از فرمت ۱۱-بخشی اصلی):**
- بخش «نسخه‌ی خلاصه برای حفظ سریع» — تکرار grammar_summary است
- بخش «بازنویسی با هم‌معنی‌ها» — این کار را confusable_contrast انجام می‌دهد و بهتر
- بخش «نکات معنایی و کاربردی» جداگانه — ادغام شد با grammar_summary
- بخش «نکات ریز گرامری» جداگانه — ادغام شد با grammar_summary
- مثال‌های ۸تایی — ۳ مثال کافی است؛ ۸ مثال از یک کانکتور روند نزولی است

**`highlight` field چیست:**
رشته‌ای از کلمه/کلماتی که در UI باید رنگی نمایش داده شوند (فعل انتهای Nebensatz، یا فعل جابجاشده). این مستقیماً توسط Swift parse می‌شود.

---

## ۴. راهنمای CEFR / Register / Topic

همان فلسفه‌ی NVV و Dativ، با این تذکر مخصوص Konnektoren:

- **Nullposition** (aber, und, oder...): عمدتاً A1-A2
- **Nebensatz پایه** (weil, wenn, dass, obwohl): A2-B1
- **Adverbial رایج** (deshalb, trotzdem, danach): B1
- **Nebensatz پیشرفته** (seitdem, sobald, sofern, indem): B2-C1
- **Doppelkonnektor** (je...desto, nicht nur...sondern auch): B1-B2
- **Präpositionen ادبی/رسمی** (angesichts, infolge, mittels): C1-C2
- **Relativsatz پایه** (der/die/das, wer, was): A2-B1
- **Relativsatz پیشرفته** (dessen, deren, denen, welcher): B1-B2

Topic enum: همان enum پروژه‌های قبلی (`general` | `work` | `school` | `health` | `travel` | `politics` | `economy` | `legal` | `emotions` | `relationships` | `daily-life` | `media-news`)

---

## ۵. فایل‌های خروجی

| فایل | محتوا | زمان تولید |
|---|---|---|
| `konnektoren_data.jsonl` | لایه ۱ — فایل کاری، یک خط = یک کانکتور | در طول پردازش |
| `konnektoren_data.json` | لایه ۱ — آرایه‌ی نهایی برای Xcode | پایان کار |
| `konnektoren_rich.jsonl` | لایه ۲ — فایل کاری محتوای غنی | در طول پردازش |
| `konnektoren_rich.json` | لایه ۲ — آرایه‌ی نهایی محتوای غنی | پایان کار |
| `konnektoren_grammar.json` | محتوای گرامری مستقل (مثل Dativ) | مرحله‌ی اختصاصی |
| `konnektoren_sources.md` | مستندسازی منابع، افزوده‌های Claude، درصد همپوشانی | مراحل ۱۰-۱۲ |
| `konnektoren_ui_design.md` | مشخصات صفحات + موتور آزمون + معماری اتصال | مراحل پایانی |

### نکته‌ی مهم: چرا دو فایل کاری جدا؟
لایه ۱ و لایه ۲ به‌صورت موازی پردازش می‌شوند — یعنی برای هر کانکتور، هم یک خط به `konnektoren_data.jsonl` اضافه می‌شود، هم یک خط به `konnektoren_rich.jsonl`. این کار از resume کردن اشتباه جلوگیری می‌کند: اگر کار قطع شد، آخرین `id` در هر دو فایل باید یکسان باشد.

---

## ۶. معماری اتصال به بخش‌های دیگر اپ

- **`Wortschatz`**: فیلتر `type == connector` روی `konnektoren_data.json` — بدون کپی دیتا
- **`Auswendiglernen/Konnektoren`**: صفحه‌ی اصلی این پروژه — لایه ۱ + لایه ۲ + گرامر + موتور آزمون
- **`Grammatik`**: فایل `konnektoren_grammar.json` رفرنس‌شده در دو جا — بدون کپی

---

## ۶ب. یکپارچگی بصری — ارجاع به کامپوننت‌های موجود

همان قانون پروژه‌ی Dativ (بخش ۶ب): قبل از هر مرحله‌ی طراحی، باید نام کامپوننت‌های بصری موجود از لوکاس تأیید شود. در فایل `konnektoren_ui_design.md` یک بخش «کامپوننت‌های استفاده‌شده» با دو ستون: موجود (با اسم دقیق) و جدید (با برچسب «جدید — مشترک آینده»).

**کامپوننت‌هایی که احتمالاً جدید هستند (در NVV و Dativ نبودند):**
- Badge رنگی `connector_type` (۶ رنگ برای ۶ نوع)
- Badge رنگی `word_order_effect` (برای نشان دادن اثر روی جمله)
- هایلایت inline متن آلمانی (برای `highlight` field در مثال‌ها)
- Card مقایسه‌ای (برای `confusable_contrast`)

---

## ۷. طراحی صفحه‌ی اول (Home)

دسته‌بندی که لوکاس خواسته + دسته‌بندی جدید مخصوص این پروژه:
1. **بر اساس نوع** (`connector_type`) — ۶ دسته با رنگ‌های متفاوت
2. **بر اساس سطح** (`cefr_level`) — A1 تا C2
3. **بر اساس نقش معنایی** (`semantic_role`) — causal, temporal, concessive...
4. **بر اساس اثر گرامری** (`word_order_effect`) — گروه‌بندی برای یادگیری قانون ترتیب کلمات

---

## ۸. طراحی صفحه‌ی اختصاصی هر کانکتور

عناصر صفحه (به ترتیب از بالا به پایین):
1. **کانکتور** (بزرگ) + badge رنگی `connector_type` + badge `cefr_level`
2. **معنی** فارسی/انگلیسی (toggle)
3. **خلاصه گرامری** (از `grammar_summary`) — ساختار + اشتباه رایج
4. **مثال‌های هایلایت‌شده** (۳ مثال از `examples`) — متن آلمانی با رنگ متفاوت روی کلمه‌ی `highlight`
5. **مقایسه با مشابه‌ها** (از `confusable_contrast`) — کارت‌های کوچک
6. **badge** register + topic + `word_order_effect`
7. **note** (در صورت وجود)
8. **دکمه‌های ناوبری** (بعدی/قبلی) + bookmark/mark-as-learned

---

## ۹. موتور آزمون

چهار نوع تمرین از `exercise_pool` (لایه ۲):
1. **`fill_blank`** — جای‌خالی با `distractor_ids` برای گزینه‌های اشتباه
2. **`word_order`** — مرتب‌کردن کلمات به‌هم‌ریخته (مخصوصاً برای تمرین ترتیب فعل)
3. **`multiple_choice`** — چهارگزینه‌ای
4. **`translation`** — ترجمه از فارسی به آلمانی

منطق رندوم: انتخاب کانکتور رندوم + نوع تمرین رندوم، با امکان فیلتر بر اساس `connector_type` / `cefr_level` / `semantic_role`.

---

## ۱۰. چک کامل‌بودن لیست خام (مرحله‌ی پیش از پردازش)

حداقل **۳ سایت مرجع** برای چک کامل‌بودن (مثل پروژه‌ی Dativ):
- deutsch.lingolia.com
- grammatiktraining.de
- schubert-verlag.de یا deutschakademie.de

نتیجه در `konnektoren_sources.md` ثبت می‌شود.

---

## ۱۱. افزودن موارد مهم توسط Claude

نمونه‌هایی که احتمالاً در منبع خام نیستند ولی مهم هستند:
- `denn` (Nullposition — اغلب با `weil` اشتباه گرفته می‌شود)
- `zumal` ، `sofern` ، `sobald` (Nebensatz پیشرفته‌ی B2)
- `einerseits...andererseits` (Doppelkonnektor)
- `infolge` ، `mithilfe` ، `aufgrund` (Präpositionen با Genitiv — C1)
- `weshalb` ، `weswegen` (Relativsatz/Nebensatz قابل‌اشتباه)

هر مورد اضافه‌شده در `konnektoren_sources.md` با دلیل ثبت می‌شود.

---

## ۱۲. مقایسه با منبع قوی — هدف >۹۰٪ همپوشانی

مثل پروژه‌ی Dativ — مقایسه با یک منبع آکادمیک معتبر، محاسبه‌ی درصد، ثبت در `konnektoren_sources.md`.

---

## ۱۳. نقشه راه مرحله‌ای کامل (چک‌لیست)

- [ ] **مرحله ۰ — Setup:** ساخت فایل‌های خالی `konnektoren_data.jsonl` و `konnektoren_rich.jsonl`. تأیید سند.
- [ ] **مرحله ۱ — Completeness check:** بررسی لیست خام با ۳ سایت مرجع (بخش ۱۰). شروع `konnektoren_sources.md`.
- [ ] **مرحله ۲ — افزودن موارد مهم:** افزودن کانکتورهای پرکاربرد غایب (بخش ۱۱) + ثبت در sources.
- [ ] **مرحله ۳ — مقایسه با منبع قوی:** محاسبه‌ی درصد همپوشانی (بخش ۱۲) + قفل‌کردن لیست نهایی + شماره‌گذاری id.
- [ ] **مرحله ۴ — پردازش دسته‌ای (Nullposition):** پردازش همه‌ی Nullposition کانکتورها → append به هر دو jsonl.
- [ ] **مرحله ۵ — پردازش دسته‌ای (Nebensatz):** پردازش همه‌ی Nebensatz کانکتورها → append به هر دو jsonl.
- [ ] **مرحله ۶ — پردازش دسته‌ای (Adverbial):** پردازش همه‌ی Adverbial کانکتورها → append به هر دو jsonl.
- [ ] **مرحله ۷ — پردازش دسته‌ای (Doppelkonnektor):** پردازش Doppelkonnektoren (با part_a/part_b) → append.
- [ ] **مرحله ۸ — پردازش دسته‌ای (Präpositionen):** پردازش با case_governance → append.
- [ ] **مرحله ۹ — پردازش دسته‌ای (Relativsatz):** پردازش ضمایر نسبی → append.
- [ ] **مرحله‌ی گرامر:** نوشتن `konnektoren_grammar.json` با ارجاع به id (نه تکرار رشته).
- [ ] **مرحله QA نهایی:** شمارش کل، چک فیلدهای خالی، چک id تکراری، چک confusable_with همه‌طرفه (اگر A به B اشاره دارد، B هم باید به A اشاره کند)، تبدیل jsonl → json. خلاصه‌ی آماری.
- [ ] **مرحله‌ی پرسش کامپوننت‌های بصری:** از لوکاس بپرس نام کامپوننت‌های موجود را (بخش ۶ب).
- [ ] **مرحله‌ی طراحی صفحه‌ی اول:** مشخصات دقیق (بخش ۷) در `konnektoren_ui_design.md`.
- [ ] **مرحله‌ی طراحی صفحه‌ی اختصاصی:** مشخصات دقیق (بخش ۸) در همان فایل.
- [ ] **مرحله‌ی طراحی موتور آزمون:** مشخصات چهار نوع تمرین (بخش ۹) در همان فایل.
- [ ] **مرحله‌ی معماری اتصال:** مستندسازی اتصال بدون‌duplicate (بخش ۶) در همان فایل.
- [ ] **مرحله‌ی تحویل نهایی:** نمایش همه‌ی فایل‌ها با `present_files`.

بعد از هر مرحله: توقف، نمایش فایل فعلی، انتظار تأیید لوکاس — مگر از قبل گفته باشد «همه مراحل را پشت‌سرهم انجام بده».

---

## ۱۴. نحوه‌ی Resume کردن در گفتگوی جدید

1. چک‌لیست بخش ۱۳ را ببین، آخرین مورد ✅ را پیدا کن.
2. هر دو فایل jsonl را با `view` بخوان، آخرین `id` را تأیید کن (باید در هر دو یکسان باشد).
3. اگر فایلی آپلود نشده ولی چک‌لیست می‌گوید مرحله‌ای تمام شده، از مرحله‌ی بعد شروع کن.
4. فیلد `confusable_with` را در QA نهایی چک کن که همه‌طرفه باشد (دو طرف رابطه هر دو باید به هم اشاره کنند).
5. بعد از هر مرحله توقف کن و منتظر تأیید بمان.

---

## ۱۵. داده‌ی خام منبع

### دسته ۱ — Nullposition Konnektoren
| # | Konnektor | معنی | مثال |
|---|---|---|---|
| - | denn | زیرا | Sie weinte, denn sie war traurig. |
| - | oder | یا | Willst du Tee oder Kaffee? |
| - | sondern | بلکه | Er kam nicht zu spät, sondern pünktlich. |
| - | und | و | Ich gehe einkaufen und danach koche ich. |
| - | aber | اما | Ich mag Pizza, aber ich esse sie nicht oft. |
| - | doch | با این حال | Er ist klein, doch er ist stark. |

### دسته ۲ — Nebensatz Konnektoren
| # | Konnektor | معنی | مثال |
|---|---|---|---|
| - | weil | چون | Ich bleibe zu Hause, weil es regnet. |
| - | wenn | اگر/وقتی | Wenn es regnet, bleibe ich zu Hause. |
| - | obwohl | با اینکه | Obwohl es regnet, gehe ich spazieren. |
| - | bevor | قبل از اینکه | Bevor wir gehen, müssen wir aufräumen. |
| - | während | در حالی که | Während ich lese, höre ich Musik. |
| - | ob | آیا | Ich weiß nicht, ob er kommt. |
| - | bis | تا | Warte, bis ich zurückkomme. |
| - | seitdem | از زمانی که | Seitdem ich hier wohne, fühle ich mich wohl. |
| - | da | چونکه | Da es regnet, bleiben wir zu Hause. |
| - | falls | در صورتی که | Falls es regnet, nehmen wir den Bus. |
| - | als | وقتی که (گذشته) | Als ich klein war, spielte ich oft draußen. |
| - | obgleich | اگرچه | Obgleich er müde war, arbeitete er weiter. |
| - | indem | با انجام دادن | Indem er lernte, wurde er besser. |
| - | dass | که | Ich hoffe, dass du kommst. |
| - | nachdem | بعد از اینکه | Nachdem er gegessen hatte, ging er schlafen. |
| - | so dass | به طوری که | Er lernte viel, so dass er die Prüfung bestand. |
| - | als dass | که | Es ist zu spät, als dass wir noch gehen könnten. |
| - | als ob | انگار که | Er tut, als ob er nichts wüsste. |
| - | als wenn | انگار که | Er redet, als wenn er alles wüsste. |
| - | außer wenn | مگر اینکه | Ich gehe hin, außer wenn es regnet. |
| - | um ... zu | برای اینکه | Ich lerne, um die Prüfung zu bestehen. |
| - | sobald | به محض اینکه | Ruf mich an, sobald du ankommst. |
| - | sofern | به شرطی که | Sofern es nicht regnet, gehen wir spazieren. |
| - | solange | تا زمانی که | Solange du lernst, wirst du erfolgreich sein. |
| - | sooft | هر چند وقت که | Sooft ich ihn sehe, freue ich mich. |
| - | soviel | تا آنجا که | Soviel ich weiß, ist das richtig. |
| - | soweit | تا آنجایی که | Soweit ich weiß, ist er im Urlaub. |
| - | damit | تا اینکه | Ich mache das, damit du glücklich bist. |
| - | insofern | از این جهت | Insofern das Wetter gut ist, machen wir ein Picknick. |
| - | obschon | اگرچه | Obschon er müde war, arbeitete er weiter. |
| - | ohne dass | بدون اینکه | Er ging, ohne dass er etwas sagte. |
| - | ohne zu | بدون اینکه | Er ging, ohne zu grüßen. |
| - | obzwar | اگرچه | Obzwar er krank war, ging er zur Arbeit. |
| - | selbst wenn | حتی اگر | Ich gehe, selbst wenn es regnet. |
| - | auch wenn | حتی اگر | Ich gehe, auch wenn es regnet. |
| - | wenn auch | اگرچه | Ich komme, wenn auch spät. |
| - | wenngleich | اگرچه | Wenngleich es kalt ist, gehe ich spazieren. |
| - | je nachdem | بسته به اینکه | Je nachdem, wie das Wetter ist, gehen wir raus. |
| - | statt dass | به جای اینکه | Statt dass er arbeitet, schläft er. |
| - | statt zu | به جای اینکه | Er ging ins Bett, statt zu arbeiten. |
| - | kaum dass | به محض اینکه | Kaum dass er kam, fing es an zu regnen. |
| - | außer zu | جز اینکه | Nichts zu tun, außer zu warten. |
| - | dadurch dass | به این خاطر که | Dadurch dass man langsam fährt, kann man Benzin sparen. |
| - | anstatt dass | به جای اینکه | Anstatt dass sie lernt, spielt sie. |
| - | außer dass | جز اینکه | Es gibt nichts Neues, außer dass wir gewonnen haben. |
| - | sowie | به محض اینکه | Sowie er kommt, beginnen wir. |
| - | ehe | قبل از اینکه | Ehe du gehst, ruf mich an. |
| - | weswegen | به خاطر اینکه | Ich habe Höhenangst, weswegen ich keine Lust auf Klettern habe. |
| - | weshalb | به خاطر اینکه | Erkläre mir bitte, weshalb du schon wieder zu spät bist. |
| - | seitdem | از آن زمان | Er lebt hier, seitdem er geboren wurde. |
| - | zumal | به خصوص که | Wir sollten gehen, zumal es spät wird. |

### دسته ۳ — Doppelkonnektoren
| # | Part A | Part B | معنی | مثال |
|---|---|---|---|---|
| - | nicht nur | sondern auch | نه تنها...بلکه | Er ist nicht nur klug, sondern auch freundlich. |
| - | weder | noch | نه...و نه | Weder das Wetter noch die Stimmung war gut. |
| - | entweder | oder | یا...یا | Entweder gehst du zur Party, oder du bleibst zu Hause. |
| - | je | desto | هرچه...به همان نسبت | Je mehr du lernst, desto besser wirst du. |
| - | zwar | aber | هرچند...اما | Es ist zwar teuer, aber es lohnt sich. |
| - | teils | teils | بخشی...بخشی | Der Film war teils spannend, teils langweilig. |
| - | sowohl | als auch | هم...و هم | Sowohl die Eltern als auch die Kinder waren begeistert. |
| - | mal | mal | گاهی...گاهی | Mal ist es sonnig, mal regnet es. |
| - | bald | bald | گاهی...گاهی | Bald lachte sie, bald weinte sie. |
| - | einerseits | andererseits | از یک طرف...از طرف دیگر | Einerseits will er reisen, andererseits hat er Angst vor Flugzeugen. |
| - | halb | halb | نیمه...نیمه | Halb zog sie ihn, halb sank er hin. |

### دسته ۴ — Adverbial Konnektoren (Konjunktionaladverbien)
| # | Konnektor | معنی | مثال |
|---|---|---|---|
| - | deshalb | به همین دلیل | Er ist krank, deshalb bleibt er zu Hause. |
| - | deswegen | به همین دلیل | Es regnet, deswegen bleiben wir drin. |
| - | daher | بنابراین | Es ist kalt, daher tragen wir Mäntel. |
| - | darum | بنابراین | Sie ist müde, darum schläft sie. |
| - | jedoch | اما | Ich habe viel gearbeitet, jedoch bin ich nicht müde. |
| - | trotzdem | با این حال | Es regnet, trotzdem gehen wir spazieren. |
| - | dennoch | با این حال | Es war schwer, dennoch haben wir es geschafft. |
| - | allerdings | البته | Allerdings habe ich es vergessen. |
| - | also | بنابراین | Es regnet und wir haben keinen Schirm, also werden wir nass. |
| - | folglich | در نتیجه | Er hat viel gelernt, folglich hat er die Prüfung bestanden. |
| - | infolgedessen | در نتیجه | Es gab einen Sturm, infolgedessen fiel der Strom aus. |
| - | danach | بعد از آن | Wir gehen essen. Danach gehen wir ins Kino. |
| - | dann | سپس | Ich mache meine Hausaufgaben, dann sehe ich fern. |
| - | anschließend | سپس | Wir essen, anschließend gehen wir spazieren. |
| - | vorher | قبل از آن | Ich rufe dich an, vorher muss ich arbeiten. |
| - | zuvor | پیش از این | Zuvor habe ich das nie gemacht. |
| - | währenddessen | در این میان | Sie kochte, währenddessen sah er fern. |
| - | währenddem | در این میان | Ich lernte, währenddem spielte er. |
| - | stattdessen | در عوض | Wir gehen nicht ins Kino, stattdessen bleiben wir zu Hause. |
| - | dagegen | در مقابل | Ich mag Kaffee, er dagegen trinkt lieber Tee. |
| - | demgegenüber | در مقابل | Ich bin müde, demgegenüber ist er voller Energie. |
| - | hingegen | در مقابل | Er ist reich, sie hingegen ist arm. |
| - | andernfalls | در غیر این صورت | Beeile dich, andernfalls verpasst du den Zug. |
| - | anderenfalls | در غیر این صورت | Du musst lernen, anderenfalls wirst du nicht bestehen. |
| - | ansonsten | در غیر این صورت | Du musst schneller sein, ansonsten verlieren wir. |
| - | sonst | وگرنه | Beeile dich, sonst verpassen wir den Zug. |
| - | dabei | در این حال | Er las ein Buch, dabei hörte er Musik. |
| - | dadurch | از طریق | Dadurch habe ich viele neue Freunde gefunden. |
| - | dafür | برای آن | Dafür danke ich dir. |
| - | insofern | از این لحاظ | Insofern ist alles in Ordnung. |
| - | insoweit | از این جهت | Insoweit stimme ich zu. |
| - | nämlich | یعنی | Ich bin spät dran, nämlich es gab viel Verkehr. |
| - | vielmehr | بلکه | Er ist kein Lehrer, vielmehr ein Berater. |
| - | sowie | و همچنین | Sie brachte Brot sowie Käse mit. |
| - | beziehungsweise | یا بهتر بگویم | Er kommt heute beziehungsweise morgen. |
| - | mithin | بنابراین | Es war schwer, mithin auch teuer. |
| - | darüber hinaus | علاوه بر این | Er ist klug, darüber hinaus sehr freundlich. |
| - | des Weiteren | علاوه بر این | Sie ist nett, des Weiteren hilfsbereit. |
| - | vorausgesetzt | به شرطی که | Vorausgesetzt, dass das Wetter gut ist, machen wir einen Ausflug. |
| - | angenommen | به فرض | Angenommen, wir finden keinen Parkplatz, müssen wir woanders parken. |
| - | es sei denn, dass | مگر اینکه | Wir kommen, es sei denn, dass es schneit. |

### دسته ۵ — Präpositionen با Dativ/Genitiv
| # | Konnektor | معنی | حالت | مثال |
|---|---|---|---|---|
| - | gemäß | مطابق | Dativ | Seinem Wunsch gemäß übernahm sein Sohn das Geschäft. |
| - | zufolge | بر اساس | Dativ | Dem Bericht zufolge wird es morgen regnen. |
| - | laut | به گفته | Dativ | Laut dem Arzt soll er im Bett bleiben. |
| - | nach | طبق | Dativ | Nach dem Plan werden wir um 10 Uhr beginnen. |
| - | außer | خارج از | Dativ | Außer mir hat niemand das Buch gelesen. |
| - | angesichts | با توجه به | Genitiv | Angesichts der Gefahr blieb er ruhig. |
| - | anlässlich | به مناسبت | Genitiv | Anlässlich seines Geburtstags gab es eine Feier. |
| - | aufgrund | به دلیل | Genitiv | Aufgrund des Wetters bleiben wir zu Hause. |
| - | infolge | در نتیجه | Genitiv | Infolge des Unfalls gab es Stau. |
| - | mittels | به وسیله | Genitiv | Mittels eines Tricks gewann er das Spiel. |
| - | trotz | با وجود | Genitiv | Trotz des Regens gingen wir spazieren. |
| - | wegen | به خاطر | Genitiv | Wegen des Sturms wurden die Flüge gestrichen. |
| - | zwecks | به منظور | Genitiv | Zwecks besserer Übersicht wurde die Tabelle neu erstellt. |
| - | während | در طی | Genitiv | Während des Spiels fiel ein Tor. |
| - | mangels | به دلیل کمبود | Genitiv | Mangels Beweisen wurde er freigesprochen. |
| - | innerhalb | در داخل | Genitiv | Innerhalb einer Woche müssen wir umziehen. |
| - | außerhalb | در خارج | Genitiv | Außerhalb der Stadt ist es ruhig. |
| - | anstatt | به جای | Genitiv | Anstatt des Buches kaufte ich eine Zeitschrift. |
| - | statt | به جای | Genitiv | Statt des Kuchens nahm ich ein Eis. |
| - | dank | به لطف | Genitiv | Dank deiner Hilfe konnten wir das Problem lösen. |
| - | hinsichtlich | از لحاظ | Genitiv | Hinsichtlich der Qualität ist dieses Produkt hervorragend. |
| - | anhand | بر اساس | Genitiv | Anhand der Beweise wurde er freigesprochen. |
| - | bezüglich | در رابطه با | Genitiv | Bezüglich deiner Anfrage haben wir keine Neuigkeiten. |
| - | mithilfe | با کمک | Genitiv | Mithilfe dieses Werkzeugs kann man die Aufgabe erledigen. |
| - | seitens | از سوی | Genitiv | Seitens des Managements gab es keine Einwände. |
| - | ungeachtet | بدون توجه | Genitiv | Ungeachtet seiner Müdigkeit arbeitete er weiter. |
| - | unweit | نزدیک | Genitiv | Der Supermarkt ist unweit seiner Wohnung. |
| - | jenseits | فراتر از | Genitiv | Jenseits der Realität. |
| - | kraft | به موجب | Genitiv | Kraft des Gesetzes ist dies verboten. |
| - | um ... willen | به خاطر | Genitiv | Um des Friedens willen sollten wir verhandeln. |
| - | abseits | خارج از | Genitiv | Sie parkte abseits der Hauptstraße. |
| - | anstelle | به جای | Genitiv | Ich werde Tee anstelle des Kaffees bestellen. |
| - | binnen | تا | Genitiv | Das Paket wird binnen einer Woche ankommen. |
| - | inmitten | در میان | Genitiv | Sie lebten inmitten einer blühenden Landschaft. |
| - | oberhalb/unterhalb | بالا/پایین | Genitiv | Die Schlafzimmer sind oberhalb des Wohnzimmers. |
| - | entlang | در طول | Genitiv/Akk | Sie geht entlang des Flusses. |
| - | inklusive | شامل | Genitiv | Inklusive des Mittagessens. |
| - | exklusive | بدون | Genitiv | Exklusive der Mitglieder. |

### دسته ۶ — Relativsätze
| # | Konnektor | کاربرد | مثال |
|---|---|---|---|
| - | der | مذکر/Nominativ | Der Mann, der dort steht, ist mein Lehrer. |
| - | die | مؤنث/Nominativ یا جمع | Die Frau, die singt, ist meine Mutter. |
| - | das | خنثی/Nominativ | Das Buch, das du liest, ist spannend. |
| - | den | مذکر/Akkusativ | Der Hund, den ich streichle, ist süß. |
| - | dem | مذکر یا خنثی/Dativ | Der Mann, dem ich helfe, ist alt. |
| - | dessen | مذکر یا خنثی/Genitiv | Der Mann, dessen Auto kaputt ist, wartet. |
| - | deren | مؤنث یا جمع/Genitiv | Die Frau, deren Kinder spielen, ist nett. |
| - | denen | جمع/Dativ | Die Kinder, denen wir helfen, sind glücklich. |
| - | welcher | مذکر (رسمی) | Der Hund, welcher bellt, ist groß. |
| - | welche | مؤنث/جمع (رسمی) | Die Katze, welche schnurrt, ist süß. |
| - | welches | خنثی (رسمی) | Das Auto, welches dort parkt, ist neu. |
| - | wer | کسی که | Wer viel lernt, besteht die Prüfung. |
| - | was | چیزی که | Das, was du sagst, ist wichtig. |
| - | wo | جایی که | Das Haus, wo ich wohne, ist alt. |
| - | wohin | به جایی که | Der Ort, wohin wir fahren, ist schön. |
| - | woher | از جایی که | Das Dorf, woher er kommt, ist klein. |
| - | wie | مانند | Mach es so, wie ich es dir gezeigt habe. |

**نکته‌های مهم برای مرحله‌ی پردازش:**
- `während` هم Nebensatz است هم Präposition — در schema باید جداگانه (دو id مختلف) وارد شود با `connector_type` متفاوت
- `sowie` هم Adverbial است (و همچنین) هم Nebensatz (به محض اینکه) — همین قانون
- `außer` هم Nullposition است (مگر) هم Präposition — همین قانون
- `obgleich` / `obschon` / `obzwar` / `wenngleich` معنی یکسان دارند — باید `confusable_with` داشته باشند
- `deshalb` / `deswegen` / `daher` / `darum` / `folglich` گروه هم‌معنی مهم هستند
- `andernfalls` / `anderenfalls` / `ansonsten` / `sonst` گروه هم‌معنی دیگر
- Doppelkonnektor `je...desto` گرامر متفاوتی دارد (Komparativ الزامی) — در note باید ذکر شود

