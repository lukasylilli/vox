# Schema — Verben/Adjektive/Nomen mit Präpositionen

## ساختار هر cluster

```json
{
  "id": 1,
  "cluster_id": "freuen",
  "meaning_fa": "خوشحال شدن / شادی",
  "meaning_en": "to be happy / joy",
  "cefr_level": "A2",
  "topic": "emotions",
  "members": [
    {
      "lemma": "sich freuen",
      "word_class": "verb",
      "preposition": "auf",
      "case": "akkusativ",
      "note": "آینده / انتظار"
    },
    {
      "lemma": "sich freuen",
      "word_class": "verb",
      "preposition": "über",
      "case": "akkusativ",
      "note": "گذشته / واقعه‌ای که اتفاق افتاده"
    },
    {
      "lemma": "die Freude",
      "word_class": "noun",
      "preposition": "über",
      "case": "akkusativ",
      "note": ""
    },
    {
      "lemma": "froh",
      "word_class": "adjective",
      "preposition": "über",
      "case": "akkusativ",
      "note": ""
    },
    {
      "lemma": "erfreut",
      "word_class": "adjective",
      "preposition": "über",
      "case": "akkusativ",
      "note": "رسمی‌تر"
    }
  ],
  "examples": [
    {
      "member_lemma": "sich freuen",
      "member_preposition": "auf",
      "de": "Sie freut sich auf den Urlaub.",
      "fa": "او منتظر تعطیلات است.",
      "en": "She's looking forward to the vacation."
    },
    {
      "member_lemma": "sich freuen",
      "member_preposition": "über",
      "de": "Er freut sich über das Geschenk.",
      "fa": "او از هدیه خوشحال است.",
      "en": "He's happy about the gift."
    }
  ],
  "confusable_with": [4, 12]
}
```

## فیلدها

| فیلد | توضیح |
|---|---|
| `id` | شناسه کلاستر |
| `cluster_id` | نام کوتاه برای ارجاع |
| `meaning_fa` | معنی کلی خانواده |
| `meaning_en` | معنی انگلیسی |
| `cefr_level` | سطح کلاستر (بر اساس پرکاربردترین member) |
| `topic` | موضوع |
| `members` | آرایه‌ای از همه ترکیب‌ها |
| `members[].lemma` | فعل/اسم/صفت |
| `members[].word_class` | verb / noun / adjective |
| `members[].preposition` | حرف اضافه |
| `members[].case` | akkusativ / dativ |
| `members[].note` | تفاوت معنایی اگر چند حرف اضافه دارد |
| `examples` | یک مثال به ازای هر member مهم |
| `confusable_with` | id کلاسترهای قابل اشتباه |

## استخراج برای تمرین (در Swift)

```swift
// فلت‌سازی برای تمرین جای‌خالی
struct PraepExerciseItem {
    let clusterId: Int
    let lemma: String
    let wordClass: String
    let preposition: String
    let grammaticalCase: String
    let exampleDe: String
    let exampleFa: String
    let exampleEn: String
}
```
