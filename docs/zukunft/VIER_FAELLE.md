# فهرست چهار حالت

> ⛔ قبل از شروع، اول دوباره از Lukas بپرس (بند «ج» و «د»).
> منبع: `PLAN.md` تا کامیت `7c8700d4` (2026-11-10، بسته‌ی ۳ ممیزی) — متن عیناً منتقل شده، هیچ خطی حذف نشده.

## 📋 فهرست چهار حالت (Lukas 2026-10-19) — بعد از تمام شدن اسم‌ها، ⛔ اول دوباره از Lukas بپرس

> چهار حالت: (۱) یک کلمه چند معنی · (۲) هم‌نویسه، آرتیکل متفاوت · (۳) هم‌نویسه، آرتیکل یکسان · (۴) اسم صفت‌گونه. خواسته‌ها و جزئیات: «📚 روال» ⇒ «⏸️ «چهار حالت»». این فهرست (جدول ۲ در `docs/ZURUECKGESTELLT.md`) و برچسب «Vier-Fälle-Liste» در `tool/naechste_woerter.dart` همیشه یکی‌اند.

### الف) کلمه‌های فهرست‌ها که ساخته نشدند

📦 **جدول کامل (363 ردیف، همه از `substantiv_singular_alle.txt`) به [`docs/ZURUECKGESTELLT.md`](docs/ZURUECKGESTELLT.md) ⇒ «جدول ۲» منتقل شد (2026-10-22، فقط جابه‌جایی).** ردیف تازه همان‌جا ته جدول اضافه می‌شود.
ستون‌ها: `#` · کلمه · فهرست · تاریخ · حالت/دلیل.

### ب) کارت‌های موجود که آن زمان بازنویسی می‌شوند (id می‌ماند)

> قاعده (Lukas 2026-10-19): این کارت‌ها پاک نمی‌شوند (id دائمی)، **ولی محتوایشان را می‌توان کامل تغییر داد** و برای هر کلمه‌ی مشابه با معنی متفاوت **یک کارت تازه** ساخته می‌شود.

| id | حالت | یادداشت |
|---|---|---|
| `nomen_birne` | ۱ | نمونه؛ `bedeutungen` (گلابی / لامپ) |
| `nomen_abbau` · `nomen_abbruch` · `nomen_abfahrt` · `nomen_abfall` · `nomen_abfuhr` · `nomen_abgabe` · `nomen_abgang` | ۱ | با `bedeutungen` (دور ۸۶۴–۸۶۹) |
| `nomen_abc` · `nomen_abdeckung` · `nomen_abendmahl` · `nomen_abfertigung` · `nomen_abfluss` · `nomen_abfrage` · `nomen_abgesang` · `nomen_abgrenzung` · `nomen_ablage` | ۱ (احتمالی) | چند معنی در یک فهرست ترجمه، بدون `bedeutungen` — بررسی شود |
| `nomen_see` + `nomen_see_die` | ۲ | نمونه (der See دریاچه / die See دریا) |
| `nomen_bank` + `nomen_bank_2` | ۳ | نمونه (نیمکت / بانک) |
| همه‌ی کارت‌هایی که در wortnetz به «die Bank» (بانک) اشاره دارند (Bank-ترکیب‌ها 2026-10-20 مثل `nomen_bankkonto`، و صفت/فعل‌های قبلی مثل `verb_tilgen`) | ۳ | `id_ref` امروز `nomen_bank` (= نیمکت) است؛ آن زمان به کارت معنای «بانک» وصل شود (2026-10-20) |
| `nomen_abgeordnete` | ۴ | نمونه «der/die Abgeordnete»؛ خواسته: بدون آرتیکل + ارجاع به درس گرامر |
| از نمونه‌ی 2026-11-11 (`docs/qualitaet/STICHPROBE_2026-11-11.md`): `nomen_mittellinie` · `adjektiv_diskret` · `adjektiv_verbindlich` · `adjektiv_heikel` · `verb_wuerfeln` · `verb_massieren` · `verb_kuppeln` · `verb_warten` (معنی «سرویس کردن» نیست) … | ۱ | تخمین: حدود ۴۰۰ صفت و ۸۰۰ فعل از این نوع — درخواست Lukas 2026-11-11: **این کارت‌های قبلاً واردشده اصلاح شوند** |
| همه‌ی صفت‌ها و فعل‌های موجود | ۱–۴ | خواسته‌ی (و): بعد از اسم‌ها همه بررسی و بازنویسی شوند (مثلاً tippen، verletzen) |


### ج) وضع کد فعلی برای هر حالت (ثبت 2026-10-19 بخش ۱۲، درخواست Lukas) — این کدها هست ولی **تأیید نشده**؛ هیچ کارت تازه‌ای از آن‌ها استفاده نمی‌کند

| حالت | کارت(های) نمونه | امروز چند صفحه؟ | صفحه‌ی کلمه | لیست «Alle Wörter» | Leitner | کد (فایل‌ها) | تست |
|---|---|---|---|---|---|---|---|
| **۱ — یک کلمه چند معنی** | `nomen_birne` (۱. گلابی ۲. لامپ) + `nomen_abbau` … `nomen_abgang` | **یک صفحه** برای همه‌ی معنی‌ها | سر صفحه «۲ معنی» + فهرست شماره‌دار؛ کنار هر مثال برچسب «معنی n» | ترجمه به‌صورت «۱. …   ۲. …» در یک ردیف | روی پشت کارت: معنای اول پررنگ («معنای اول کافی است») + بقیه کم‌رنگ زیرش؛ یک کارت لایتنر | فیلد `bedeutungen` + `beispiele[].bedeutung` (پرامپت قاعده‌ی ۲۰) · `vokab_schema.dart` (`vokabBedeutungen`، بررسی گروه‌ها/مثال‌ها) · `vokab_index.dart` (نسخه‌ی ۴، `bedeutungen`) · `wortseite_bausteine.dart` (`vokabBedeutungenTexte`، `vokabBedeutungenZeile`، `vokabNr`) · `wort_karte_inhalt.dart` · `core/grammatikon/wort_card.dart` · `leitner/widgets/archiv_flash_card.dart` · l10n `bedeutungen_anzahl` | `test/bedeutungen_test.dart` |
| **۲ — هم‌نویسه، آرتیکل متفاوت** | `nomen_see` (der See دریاچه) + `nomen_see_die` (die See دریا) | **چند صفحه** — هر معنی صفحه‌ی خودش | شماره‌ی بالانویس See¹ / See² + کادر هشدار «کلمه‌ی هم‌شکل با معنی دیگر» با لینک به صفحه‌ی دیگر | دو ردیف جدا، هر کدام با آرتیکل و رنگ خودش + بالانویس | دو کارت لایتنر جدا؛ کادر کوچک هشدار با لینک پشت کارت؛ روی کارت آرتیکل فرق را نشان می‌دهد | فیلد `homograph` (پرامپت قاعده‌ی ۱۹) · `vokab_schema.dart` (`vokabId(…, homograph:)`، `vokabHomographMuster`) · `vokab_index.dart` (`vokabHomographFamilien`، `homograph_nr`) · `vokabular_controller.dart` (`vokabHomographeProvider` — خانواده فقط از idها) · `widgets/homograph_hinweis.dart` (`HomographHinweis`) · `wort_card.dart` (`homographHoch`) · `wort_karte_inhalt.dart` · `archiv_flash_card.dart` | `test/homograph_familie_test.dart`، `test/vokab_eigenname_homograph_test.dart` |
| **۳ — هم‌نویسه، آرتیکل یکسان** | `nomen_bank` (نیمکت) + `nomen_bank_2` (بانک) | **چند صفحه** | همان حالت ۲: Bank¹ / Bank² + کادر هشدار با لینک | دو ردیف «die Bank¹» و «die Bank²» | دو کارت جدا؛ ⚠️ روی کارت فقط «die Bank» دیده می‌شود ⇒ کاربر نمی‌داند کدام معنی پرسیده شده (فقط بالانویس فرق می‌گذارد) | همان فایل‌های حالت ۲ (id با رقم: `_2` … `_9`) | همان |
| **۴ — اسم صفت‌گونه** | `nomen_abgeordnete` «der/die Abgeordnete» | **یک صفحه** برای هر دو جنس | «der» سبز + «/» + «die» نارنجی؛ جدول «Wie ein Adjektiv gebeugt» (ein Abgeordneter، eine Abgeordnete، die Abgeordneten …) که اپ حساب می‌کند | «der/die Abgeordnete» دو رنگ؛ نماد Grammatikon = طرح خالی سیاه (چون یک جنس ندارد) | یک کارت؛ جلوی کارت «der/die Abgeordnete» | `genus: "der/die"` + `deklinationstyp: "adjektivisch"` (قاعده‌ی ۲۱) · `vokab_schema.dart` (`vokabDeklinationstypen`) · `vokab_formen.dart` (`vokabAdjektivischeFormen` + شکل‌ها برای جست‌وجو) · `details_renderer.dart` · `grammatikon_resolver.dart` (`artikelFarbe`) · `wort_card.dart` + `wort_karte_inhalt.dart` (`artikelSpans`) · `core/wort/wort_form.dart` (`nomenArtikel`، `ohneNomenArtikel`) · `tool/naechste_woerter.dart` (`listenVerweis`: Abgeordneter ⇒ Abgeordnete) | `test/nomen_adjektivisch_test.dart` |

> خلاصه برای Lukas: **Birne (حالت ۱) و Abgeordnete (حالت ۴) فقط یک صفحه دارند؛ See/Bank (حالت ۲ و ۳) برای هر معنی صفحه‌ی جدا دارند.** هیچ‌کدام تأیید نشده‌اند.

### د) ⛔ یادآوری به Lukas — وقتی اسم‌ها تمام شد، **همه‌ی این‌ها را کامل بگو** تا با دیدن همه‌ی راه‌ها تصمیم بگیرد (Lukas 2026-10-19 بخش ۱۲)

1. **وضع فعلی** (جدول «ج» بالا): کدام کارت یک صفحه دارد (Birne، Abgeordnete) و کدام چند صفحه (See، Bank)؛ چند کارت در هر حالت ساخته شده و چند کلمه در فهرست «الف» منتظرند.
2. **راه‌های ممکن برای هر حالت** (هر کدام با مثال):
   - **حالت ۱ (چند معنی):** (الف) یک صفحه با معنی‌های شماره‌دار (امروز Birne) · (ب) **هر معنی یک کارت/صفحه‌ی جدا** (خواسته‌ی Lukas «ج»؛ مثلاً `nomen_birne` = گلابی + کارت تازه برای «لامپ») با خط «کلمه‌ی مشابه» + لینک و خط «چرا دو معنی» · (ج) ترکیبی: یک صفحه‌ی اصلی کوتاه که فقط معنی‌ها را با لینک فهرست می‌کند + یک صفحه برای هر معنی.
   - **حالت ۲ (آرتیکل متفاوت):** (الف) دو کارت با بالانویس See¹/See² (امروز) · (ب) بدون بالانویس، چون آرتیکل خودش فرق را نشان می‌دهد · (ج) id با آرتیکل یا با رقم (امروز `_die`).
   - **حالت ۳ (آرتیکل یکسان):** (الف) دو کارت با بالانویس (امروز) · (ب) کنار کلمه یک **کلمه‌ی راهنما** (die Bank «Sitz» / die Bank «Geld») · (ج) نماد/تصویر کوچک یا رنگ برای هر معنی · (د) روی جلوی کارت Leitner به جای کلمه‌ی تنها، جمله‌ی کوتاه با جای خالی.
   - **حالت ۴ (صفت‌گونه):** (الف) «der/die Abgeordnete» دو رنگ (امروز) · (ب) **بدون آرتیکل** «Abgeordnete» + جمله‌ی اول صفحه ارجاع به درس گرامر (خواسته‌ی Lukas «ب») · (ج) دو کارت جدا «der Abgeordnete» / «die Abgeordnete» · (د) کدام نماد Grammatikon (امروز طرح خالی).
3. **تأکید: نمایش در Leitner و در لیست کلمه‌ها مهم است** (خواسته‌ی «الف»): برای هر راه بگو جلوی/پشت کارت Leitner و ردیف «Alle Wörter» دقیقاً چه نشان می‌دهند؛ مشکل حالت ۳ (روی کارت فقط «die Bank») را صریح بگو؛ آیا یک نشانه‌ی کوچک (مثلاً «¹²» یا «⇄») در لیست و Leitner بیاید که «این کلمه هم‌شکل دارد».
4. **ایده‌های دیگر Claude که آن زمان باید گفته شوند** (و هر ایده‌ی تازه‌ای که آن موقع به ذهن رسید):
   - جست‌وجوی «Bank» همه‌ی هم‌شکل‌ها را **کنار هم** نشان دهد، نه پراکنده.
   - تمرین‌های خودکار: تمرین der/die/das برای حالت ۴ نباید ساخته شود؛ تمرین جای خالی باید مثال **همان معنی** را بگیرد.
   - جهت پرسش Leitner: فارسی ⇒ آلمانی برای هم‌شکل‌ها ابهام ندارد («بانک» ⇒ die Bank)، آلمانی ⇒ فارسی دارد — شاید برای این کلمه‌ها جهت ثابت.
   - لینک‌های `wortnetz`/`ersatz` کارت‌های دیگر به کدام معنی اشاره کنند.
   - همین تصمیم بعداً برای **همه‌ی صفت‌ها و فعل‌ها** (tippen، verletzen …) — خواسته‌ی «و».
5. فقط بعد از تصمیم Lukas: پرامپت (قاعده‌های ۱۹–۲۱) بازنویسی ⇒ کد ⇒ کارت‌های «ب» با همان id بازنویسی + کارت تازه برای هر معنای دیگر ⇒ کلمه‌های «الف» ساخته شوند.
