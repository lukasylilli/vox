# PLAN — VOX

> 🧭 **قاعده‌ی ثابت برای هر چت جدید (Lukas، 2026-09-18) — این بخش را حذف نکن.**
> Claude بین چت‌ها حافظه ندارد؛ **این چهار فایل تنها حافظه‌ی پروژه‌اند:**
> `vox/PLAN.md` · `vox/PROJECT_MAP.md` · `Root-in/PLAN.md` · `Root-in/MAP.md`.
> **۱ — اول هر چت:** هر چهار فایل را **تازه از GitHub** بخوان (api.github.com، شاخه main)، نه از حافظه.
> **۲ — بعد:** اولین قدم باز را پیدا کن و بدون پرسیدن انجامش بده.
> **۳ — آخر هر کار (و آخر هر چت):** در PLAN و MAP همان ریپو یک ورودی کوتاه بنویس — چه کردی، چرا، در کدام فایل/فاز —
> و خط «آخرین جلسه / قدم بعدی» پایین را تازه کن. **کاری که در پلن و مپ ثبت نشده، برای چت بعدی وجود ندارد.**
> فهرست مطالب و بخش Hinweise همیشه حفظ می‌شوند.
>
> 🗂️ **خلاصه‌سازی دوم (2026-09-23 دور ۲۵، درخواست Lukas):** هر بخشی که کاملاً انجام و تست‌شده بود به یک خط کوتاه شد؛
> قاعده‌ها، اصل‌ها، تصمیم‌ها و کارهای باز کامل ماندند. کارهای باز فقط در دو بخش پایین جمع‌اند: «🚀 قبل از انتشار» و «⏭️ بعد از انتشار».
> متن مفصل قبل از این خلاصه: `git show a078dc2:PLAN.md` (نسخه‌ی قدیمی‌تر: `afad3ab`).
> 🗂️ **خلاصه‌سازی سوم (2026-09-24 دور ۶۳، درخواست Lukas — «سریع‌تر، بدون اشتباه»):** گزارش دور به دور کلمه‌ها، جدول پیشرفت و L.4b/L.4b-2 به چند خط کوتاه شد؛ متن کامل قبلی: `git show be0c77d:PLAN.md`.
>
> 🗓️ **آخرین جلسه:** 2026-10-15 (ادامه ۵) — **دور ۶۹۰–۶۹۹ — ۱۰۰ فعل باقاعده** (Lukas: «۱۰۰ تا کلمه بعدی رو وارد اپ کن»؛ اول: CI `acbbbd3` سبز): faseln … fusionieren (هر دور: dry-run ۰/۰، import، index، ✓، `vokab_qualitaet` بدون هشدار، تست‌های کلمه سبز؛ هر دور commit خودش؛ کل تست‌ها در CI) ⇒ آرشیو **۷۹۶۱**. پایه‌ها: feiern، freuen (sich … auf/über)، frühstücken، fühlen (A1)؛ fegen، filmen، flüstern، föhnen، folgen (sein؛ «gehorchen» با haben)، fotografieren، führen، füllen، funktionieren (A2)؛ fassen، fasten، faszinieren، fischen، fordern، fördern، formen، formulieren، forschen، flüchten (sein؛ sich … haben)، fürchten (sich … vor) (B1). فعل کمکی sein: faulen، flitzen، flüchten، folgen (+ `anmerkung` برای haben)؛ haben + `anmerkung` «sein با جهت»: fegen، flanieren، flattern، fluten. امر null (فاعل معمولاً شخص نیست): faulen، flackern، flattern، flimmern، florieren، fluktuieren، fluoreszieren، fluten، frösteln، fruchten، funkeln، funktionieren. Regel 17: pflege_medizin (fiebern، fixieren، frösteln، frottieren، fühlen)، it (formatieren)، technik (federn، feilen، fertigen، fixieren، fräsen)، gastro_hotel (fermentieren، fetten، filetieren، flambieren، frittieren، frühstücken)، logistik (frankieren)، kinder_bildung (festigen، flektieren، fördern، formulieren، fremdeln)، reinigung (fegen)، buero (finanzieren، formatieren، formulieren، frankieren، fusionieren). ⚙️ ابزار Claude (بیرون از ریپو، بازسازی شد): صرف باقاعده پیش از استفاده با همه‌ی ۶۴۰ کارت باقاعده‌ی جدانشدنیِ موجود مقایسه شد (فقط تفاوت شناخته‌شده‌ی امر کوتاه قدیمی و امر null عمدی)؛ ترتیب `berufe` حالا خودکار طبق پرامپت (یک هشدار dry-run در دور ۶۹۷ پیش از import گرفته شد). **۱۷ فعل کنار گذاشته** (#۱۵۸۳–۱۵۹۹): ferkeln، feudeln، fiedern، fingern، fixen، flammen، fläzen، fleddern، flennen، flirren، fraktionieren، freveln، frikassieren، frömmeln، frommen، fummeln، furzen؛ ⚠️ fummeln (معنای جنسی، مثل befummeln) و furzen (رکیک) ⇒ تصمیم Lukas. ⏭️ Claude: افعال باقاعده **از fusseln**. <!--W3334-->
> قبلی: 2026-10-15 (ادامه ۴) — **دور ۶۸۰–۶۸۹ — ۱۰۰ فعل باقاعده** (Lukas: «صد کلمه جدید وارد اپ کن»؛ اول: CI `f9a79f4` سبز): entlarven … färben (هر دور: dry-run ۰/۰، import، index، ✓، `vokab_qualitaet` بدون هشدار، تست‌های کلمه سبز؛ هر دور commit خودش؛ کل تست‌ها در CI) ⇒ آرشیو **۷۸۶۱**. پایه‌ها: entschuldigen، erinnern، erkälten، ergänzen، erledigen، falten (A2)؛ entsprechen، erben، erhöhen، erkundigen، ernten، erweitern، existieren، experimentieren، explodieren، exportieren، färben (B1). **entsprechen** در فهرست باقاعده است ولی بی‌قاعده صرف می‌شود (entsprach، entsprochen؛ از کارت sprechen) ⇒ `regelmaessig: false` + `anmerkung` (مثل ansehen). «er» جزء ریشه ⇒ Partizip II با ge-: erben (geerbt)، erden (geerdet)، ernten (geerntet). فعل کمکی sein + امر null: erblassen، erblinden، ergrauen، erkalten، erkranken، ermatten، ermüden، erröten، erschlaffen، erstarken، eskalieren، explodieren (دوگانه‌ها + `anmerkung`: ermatten، ermüden، eskalieren؛ erodieren: haben + `anmerkung`). Regel 17: pflege_medizin (entlasten، entwöhnen، erblinden، erkälten، erkranken، ermüden، erschlaffen، evakuieren، examinieren، extrahieren)، it (exportieren)، technik (erden، erhitzen)، bau (erden)، gastro_hotel (entsaften، erhitzen)، logistik (etikettieren، expedieren، exportieren)، kinder_bildung (entmutigen، entschuldigen، ergänzen، ermuntern، ermutigen، erörtern، evaluieren، experimentieren)، reinigung (entrümpeln، falten)، buero (entschuldigen، ergänzen، erhöhen، erkundigen، erledigen، ermächtigen، erörtern، erstatten، evaluieren، fakturieren، fälschen). اصلاح پس از import (commit جدا `51cc637`): wortnetz erben دو مدخل با یک id داشت (das/der Erbe ⇒ nomen_erbe) ⇒ «die Erbschaft». ⚙️ ابزار Claude (بیرون از ریپو، بازسازی شد): صرف باقاعده پیش از استفاده با همه‌ی ۵۴۱ کارت باقاعده‌ی جدانشدنیِ موجود مقایسه شد (فقط تفاوت‌های شناخته‌شده: امر کوتاه قدیمی، be-/durch-/en- جزء ریشه)؛ دور حالا با هر هشدار `vokab_qualitaet` هم متوقف می‌شود. **۱۸ فعل کنار گذاشته** (#۱۵۶۵–۱۵۸۲): entleiben، entpersönlichen، entrinden، entwanzen، erbittern، erfrechen، erigieren، erkühnen، erotisieren، ertauben، ertüchtigen، eskamotieren، evangelisieren، exmittieren، extemporieren، fächern، fälteln، falzen؛ ⚠️ entleiben (خودکشی)، erigieren و erotisieren (جنسی) ⇒ تصمیم Lukas. ⏭️ ~~از faseln~~ <!--W3234-->
> قبلی: 2026-10-15 (ادامه ۳) — **دور ۶۷۷–۶۷۹ — ۳۰ فعل باقاعده** (Lukas: «ادامه بده»؛ اول: CI `d567167` و `a6c4542` سبز): einwilligen … entkräften (هر دور: dry-run ۰/۰، import، index، ✓، `vokab_qualitaet` بدون هشدار، تست‌های کلمه سبز؛ هر دور commit خودش) ⇒ آرشیو **۷۷۶۱**. جدانشدنی با ent-/emp- (`untr` ⇒ Partizip بدون ge-): empören، entblößen، enteisen، entfachen، entfernen، entfremden، entgegnen، entgraten، entgräten، entkernen، entkoppeln، entkorken، entkräften؛ einwilligen جداشدنی. پایه‌ها: enden، entfernen (B1)؛ ekeln (sich … vor)، engagieren (sich … für)، emigrieren (sein). Regel 17: pflege_medizin (einwilligen، eitern، entfernen)، it (emulieren)، technik (elektrifizieren، entgraten، entkoppeln)، bau (entkernen)، gastro_hotel (emulgieren، entgräten، entkernen، entkorken)، reinigung (entfernen). **۱ فعل کنار گذاشته** (#۱۵۶۴): entblöden. ⏭️ Claude: افعال باقاعده **از entlarven**. <!--W3134-->
> قبلی: 2026-10-15 (ادامه ۲) — **دور ۶۷۴–۶۷۶ — ۳۰ فعل باقاعده** (Lukas: «ادامه»؛ اول: ثبت دور ۶۶۴–۶۷۳ در PLAN/MAP، CI `07d36d5` سبز): ebben … eintüten (هر دور: dry-run ۰/۰، import، index، ✓، `vokab_qualitaet` بدون هشدار، تست‌های کلمه سبز؛ هر دور commit خودش) ⇒ آرشیو **۷۷۳۱**. اولین افعال جداشدنیِ ein-: einäschern، einbürgern، einengen، einflößen، einheimsen، einigeln، einkapseln، einkellern، einkerkern، einloggen، einmotten، einrenken، einsargen، einschiffen، einschläfern، einschüchtern، einstufen، eintüten (`trennbar: true`، «Trennbar (…)» مثل abdunkeln). einen و einigen جدانشدنی‌اند (eins/einig + -en ⇒ geeint، geeinigt). پایه‌ها: eignen (sich … für/zu/als)، eilen (sein؛ «es eilt» با haben)، einigen (sich … auf/mit)، einloggen (B1). Regel 17: pflege_medizin (einflößen، einrenken، einschläfern)، it (editieren، einloggen)، logistik (einschiffen). ⚙️ ابزار Claude: صرف جداشدنی (Partikel آخر، Partizip ein+ge…). **۳ فعل کنار گذاشته** (#۱۵۶۱–۱۵۶۳): eifern، einverleiben (Regel 3)، ⚠️ ejakulieren (جنسی ⇒ تصمیم Lukas). ⏭️ Claude: افعال باقاعده **از einwilligen**. <!--W3104-->
> قبلی: 2026-10-15 (ادامه) — **دور ۶۶۴–۶۷۳ — ۱۰۰ فعل باقاعده** (Lukas: «صد کلمه جدید وارد اپ کن» + «ادامه»؛ اول: CI `ca715ea` سبز بود): dekretieren … dynamisieren (هر دور: dry-run ۰/۰، import، index، ✓، `vokab_qualitaet` بدون هشدار، تست‌های کلمه سبز؛ هر دور commit خودش؛ کل تست‌ها در CI — دورهای ۶۶۴، ۶۶۶، ۶۶۹، ۶۷۲ سبز، بقیه با push بعدی cancelled شدند که عادی است) ⇒ آرشیو **۷۷۰۱**. پایه‌ها: duschen (A1)، diskutieren، drehen، drucken، drücken، duzen (A2)؛ dienen، deuten، drohen، diktieren، dividieren، dolmetschen، duften (B1). Regel 17: pflege_medizin (diagnostizieren، dokumentieren، dosieren، drainieren، drehen، duschen)، it (digitalisieren، duplizieren)، technik (demontieren، dübeln)، bau (drainieren، dübeln)، logistik (disponieren)، kinder_bildung (dividieren)، buero (delegieren، digitalisieren، diktieren، dokumentieren، drucken). فعل کمکی sein: desertieren، detonieren، diffundieren، driften، düsen (دوگانه‌ها + `anmerkung`). جدانشدنی با durch- (فقط جدانشدنی، دوگانه نیستند): durchforsten، durchfurchen، durchqueren. ابزار Claude (بیرون از ریپو): همان صرف باقاعده‌ی دور ۶۵۴–۶۶۳ (‎-eln: bügle/büglest، ‎-ern: blättere، e-Einschub، s/z ⇒ du duzt). **۶ فعل کنار گذاشته** (#۱۵۵۵–۱۵۶۰): deputieren، distinguieren، doktern، downloaden، dräuen، dröseln. ⏭️ Claude: افعال باقاعده **از ebben**. <!--W3074-->
> قبلی: 2026-10-15 — **دور ۶۵۴–۶۶۳ — ۱۰۰ فعل باقاعده** (Lukas: «صد کلمه جدید وارد اپ کن» + «ادامه بده»؛ اول: CI `97ee2af` سبز بود): beziffern … dekorieren (هر دور: dry-run ۰/۰، import، index، ✓، analyze بدون خطا، `vokab_qualitaet` بدون هشدار تازه (۱۹۶ ثابت)، تست‌های کلمه سبز؛ هر دور commit خودش؛ کل تست‌ها در CI) ⇒ آرشیو **۷۶۰۱**. پایه‌ها: brauchen، dauern (A1)، bilden، blättern، blinken، bremsen، bügeln، blühen، bluten، bücken (sich, obligatorisch)، chatten، chillen، cremen، decken، dekorieren (A2)؛ bezweifeln، blamieren (sich)، blicken، büffeln، bummeln (sein)، definieren، deklinieren (B1). Regel 17: pflege_medizin (blähen، bluten، bohren، bücken، bürsten، cremen، defäkieren، dehnen، dehydrieren، blinzeln)، it (blockieren، chatten، chiffrieren، computerisieren، definieren، defragmentieren)، technik/bau (bohren، blockieren، dämmen)، gastro_hotel (blanchieren، bröseln، brühen، brutzeln، bügeln، buttern، dämpfen، decken، dekantieren، dekorieren)، logistik (blinken، bremsen، bündeln، chauffieren، deklarieren)، kinder_bildung، reinigung، buero. امر null برای فعل‌هایی که فاعلشان معمولاً شخص نیست (bimmeln، blähen، blitzen، blöken، blubbern، blühen، bluten، boomen، brausen، bröckeln، brodeln، changieren، dämmern، dauern، defäkieren، dehydrieren). فعل کمکی دوگانه ⇒ فعل کمکی اصلی + `anmerkung` (brausen، bröckeln، bummeln، dampfen، defilieren). ⚙️ ابزار Claude (بیرون از ریپو، بازسازی شد): صرف باقاعده پیش از استفاده با همه‌ی ۳۰۰ کارت باقاعده‌ی جدانشدنیِ موجود مقایسه شد (فقط امر کوتاه قدیمی و دو فعل ge-). اصلاح‌ها پیش از commit: مثال cremen («creme … ein» = eincremen ⇒ برداشته شد)، IPA bugsieren، etymologie fa یکدست با کارت‌های قبلی (lat./frz./engl. به‌جای نام زبان فارسی). **۹ فعل کنار گذاشته** (#۱۵۴۶–۱۵۵۴): bimsen، bläuen، blessieren، blinkern، bollern، bosseln، bummern، chargieren؛ ⚠️ **bumsen** (رکیک/جنسی) ⇒ تصمیم Lukas. ⏭️ Claude: افعال باقاعده **از dekretieren**. <!--W2974-->
> قبلی: 2026-10-14 — **🗂️ فاز F باز شد** (درخواست Lukas: صفحه‌ی جدای فیلتر با کشوهای کتاب/Wortart/Niveau/مشاغل/بی‌احترامی/منسوخ، چیدمان هم‌ردیف دکمه‌ها، و gehen اول در جست‌وجوی «ging»). Claude طرح داد، Lukas همه را تأیید کرد (+ کتاب از شیت «افزودن به دسته‌بندی»؛ کلمه‌های کنار گذاشته‌ی ناسزا/منسوخ همچنان کنار). همان جلسه: **F.1 + F.1b ✅** — جست‌وجو حالا به ترتیب نزدیکی است (خود کلمه ⇒ مصدرِ شکل صرف‌شده ⇒ شروع ⇒ وسط ⇒ ترجمه)؛ «ging» ⇒ gehen اول، با خط «شکل صرف‌شده: ging». همان جلسه: **F.1c ✅** «gehn/Strasse» ⇒ «منظورت این بود؟» با دکمه‌ی gehen/Straße (فقط وقتی هیچ نتیجه‌ای نیست). همان جلسه: **F.3 ✅** شبکه‌ی هم‌ردیف دکمه‌ها در همه‌ی کشوهای فیلتر اپ (Wortschatz، deckها، Redemittel …). همان جلسه: **F.2 + F.2b + F.2c ✅** صفحه‌ی جدای فیلتر (دکمه‌ی ⚙︎ کنار جست‌وجو؛ پایین ثابت «پاک کردن همه» / «نمایش N کلمه»؛ عدد کنار هر دکمه؛ فیلترها روی دستگاه می‌مانند). همان جلسه: **F.4 ✅** کشوی «کتاب‌ها» (فقط کتاب‌های آماده‌ی VOX، `assets/buecher/buecher.json`) + کشوی «دسته‌بندی‌های من»؛ عدد زیر اسم دکمه، دکمه‌ها بلندتر؛ منوی Bücher حذف. 🔔 فهرست کتاب‌ها (اول «A1 Starten wir») را Lukas بعد از تمام شدن همه‌ی کلمه‌ها (حتی کنار گذاشته‌ها) می‌دهد — یادآوری فقط آن موقع. همان جلسه: **F.5 ✅** پرامپت Regel 17 + schema: `berufe` / `anstoessig` / `zeitlich` / `ersatz` (نام‌ها عوض شد تا با details.register/gebrauch قاطی نشود)؛ index نسخه‌ی ۲. همان جلسه: **F.6 ✅** سه کشوی مشاغل/بی‌احترامی/منسوخ + برچسب و «معادل» روی صفحه‌ی کلمه (لمس ⇒ فهرست با همان فیلتر). **F.7 به تعویق (Lukas):** بعد از تمام شدن کل اپ و قبل از تست‌ها، همراه دسته‌های احتمالی تازه (دیالکت، umgangssprachlich …). ⏭️ فاز F جز F.7 تمام است ⇒ قدم باز بعدی طبق «⏭️ بعد از انتشار». همان جلسه: **دور ۶۴۳ — ۱۰ فعل باقاعده** (Lukas: «ادامه وارد کردن کلمات»): beklatschen · beklauen · bekleben · bekleckern · beklecksen · beköstigen · bekräftigen · bekreuzigen (sich, obligatorisch) · bekunden · belasten (B1، mit + Dat؛ Konto belasten) — **اولین کارت‌ها با Regel 17** (berufe/anstoessig/zeitlich/ersatz؛ همه خالی/null چون هیچ‌کدام برچسب مطمئن نداشت)؛ dry-run ۰/۰، import، index (آرشیو **۷۴۰۱**)، ✓، analyze بدون خطا، `vokab_qualitaet` بدون هشدار تازه، تست‌های کلمه سبز. **کنار گذاشته (#۱۵۳۳):** belämmern (محاوره‌ای، نادر، معنا نامطمئن). ⏭️ ~~از belästigen~~ <!--F7p--> همان جلسه: **دور ۶۴۴–۶۵۳ — ۱۰۰ فعل باقاعده** (Lukas: «صد کلمه جدید وارد اپ کن» + «Mach weiter»): belästigen … bezichtigen (هر دور: dry-run ۰/۰، import، ✓، analyze بدون خطا، `vokab_qualitaet` بدون هشدار، تست‌های کلمه سبز؛ هر دور commit خودش؛ کل تست‌ها در CI) ⇒ آرشیو **۷۵۰۱**. پایه‌ها: bezahlen (A1)، benötigen، benutzen، besichtigen، besorgen (A2)، beschäftigen (sich … mit)، beschweren (sich bei … über)، beruhigen، betreuen، beurteilen، berücksichtigen (B1). **benennen** در فهرست باقاعده است ولی مختلط (benannte، benannt؛ K II benennte مثل nennen) ⇒ `regelmaessig: false` + `anmerkung`. beten، betteln، betten، beugen، bessern: «be-» جزء ریشه ⇒ Partizip II با ge-؛ besserstellen جداشدنی (bessergestellt)؛ beruhen، bestürzen، bewölken ⇒ امر null. Regel 17: pflege_medizin (beruhigen، betasten، betäuben، betreuen، betten)، kinder_bildung (benoten، betreuen)، bau (bepflastern، betonieren)، technik (beschichten، bestücken)، buero (bescheinigen، beurkunden، bevollmächtigen، bewilligen)، gastro_hotel (bewirten). ⚙️ ابزار Claude (بیرون از ریپو): صرف باقاعده پیش از استفاده با همه‌ی ۲۹۹ کارت باقاعده‌ی موجود مقایسه شد (فقط تفاوت‌های شناخته‌شده‌ی امر کوتاه قدیمی). **۱۳ فعل کنار گذاشته** (#۱۵۳۴–۱۵۴۶): benedeien، beschälen، beschranken، bessemern، bestallen، bestuhlen، betonnen، beulen، beuteln، bewandern؛ ⚠️ **betatschen** (بار جنسی، مثل befummeln) و **bewegen** (bewegte/bewog، مثل wenden) ⇒ تصمیم Lukas. ⏭️ Claude: افعال باقاعده **از beziffern**. <!--W2874-->
> قبلی: 2026-10-13 (ادامه ۱۴) — **۱۰۰ فعل تازه** (Lukas: «ادامه بده — این دفعه صد تا فعل»؛ اول: CI `5dc54da` سبز بود): دور ۶۳۳–۶۴۲، aufheitern … beklagen (هر دور: dry-run ۰/۰ و import جدا؛ vokab_index، ✓ در فهرست، analyze بدون خطا، `vokab_qualitaet` بدون هشدار، تست‌های کلمه سبز؛ هر دور commit خودش؛ کل تست‌ها در CI) ⇒ آرشیو **۷۳۹۱**. پایه‌ها: baden، bauen (A1)، basteln، begleiten (A2)، äußern، ausweichen، begegnen (sein + Dat)، sich begeistern für، bearbeiten، ausloggen (B1). فعل‌های پرستاری: beatmen، bandagieren، ausrenken. **در فهرست باقاعده ولی بی‌قاعده** ⇒ صرف از کارت پایه + `regelmaessig: false` + `anmerkung`: ausweichen (wich aus؛ جدول weichen در ابزار Claude، چون کارت weichen هنوز نیست)، beistehen (stehen)، beitreten (treten، sein). be-‌ها جدانشدنی (Partizip II بدون ge-)؛ beben، beichten، beizen جزء ریشه‌اند (gebebt …)؛ beipflichten/beistehen/beitreten جداشدنی (bei-). اصلاح‌ها پیش از commit: «(sich)» در fa (ابزار Claude حالا پیش از dry-run متوقف می‌کند)؛ غلط تایپی «mukt» ⇒ «muckt» (هشدار dry-run). ⚙️ ابزار Claude: commit فقط وقتی دور کامل و تمیز تمام شده باشد (یک commit دور ۶۳۳ پیش از این نگهبان فقط فایل‌های «کنار گذاشته» را داشت؛ کارت‌ها در commit بعدی `ad7ed5a`). یک wortnetz چندکلمه‌ای («recht haben») ⇒ unterstützen. **۳۷ فعل کنار گذاشته** (#۱۴۹۶–۱۵۳۲): بیشترشان تخصصی/قدیمی/محاوره‌ای؛ ⚠️ **befummeln** (بار جنسی) ⇒ تصمیم Lukas. ⏭️ Claude: افعال باقاعده **از beklatschen**. <!--W2774-->
> قبلی: 2026-10-13 (ادامه ۱۳) — **۳۰ فعل باقاعده‌ی تازه** (Lukas: «ادامه»؛ اول: CI `fb2d074` سبز بود): دور ۶۳۰ anseilen … apportieren · دور ۶۳۱ arbeiten … assimilieren · دور ۶۳۲ assistieren … aufhalsen (هر دور: dry-run ۰/۰ و import جدا؛ vokab_index، ✓ در فهرست، analyze بدون خطا، `vokab_qualitaet` بدون هشدار، تست‌های کلمه سبز؛ هر دور commit خودش؛ کل تست‌ها در CI) ⇒ آرشیو **۷۲۹۱**. پایه‌ها: **arbeiten** (A1، با als/an/bei)، ärgern (sich … über)، atmen (A2)، sich anstrengen، argumentieren، assistieren (+ Dat)، auffrischen (واکسن). فعل‌های پرستاری: applizieren، attestieren، assistieren. اصلاح پیش از commit: «(sich)» در fa (ärgern، arrangieren، assimilieren) ⇒ با `--update` برداشته شد؛ ⚙️ ابزار Claude (بیرون از ریپو) حالا پیش از dry-run «(sich)» را می‌گیرد. **۳۸ فعل کنار گذاشته** (#۱۴۵۸–۱۴۹۵): بیشترشان تخصصی/قدیمی/ادبی (arbitrieren، assekurieren …)، املا (armmachen)، فعل کمکی نامطمئن (arten)؛ ⚠️ **arisieren** (اصطلاح تاریخی دوران نازی) ⇒ تصمیم Lukas در «🏁 مرحله‌ی آخر». ⏭️ Claude: افعال باقاعده **از aufheitern**. <!--W2674-->
> قبلی: 2026-10-13 (ادامه ۱۲) — **۳۰ فعل باقاعده‌ی تازه** (Lukas: «ادامه»؛ اول: CI `45b1491` سبز بود): دور ۶۲۷ anbändeln … anheimeln · دور ۶۲۸ anhimmeln … anmuten · دور ۶۲۹ annektieren … ansehen (هر دور: dry-run ۰/۰ و import جدا؛ vokab_index، ✓ در فهرست، analyze بدون خطا، تست‌های کلمه سبز؛ هر دور commit خودش؛ کل تست‌ها در CI) ⇒ آرشیو **۷۲۶۱**. پایه‌ها: ändern (A2)، ansehen (A2)، angeln، anfreunden (sich … mit)، angehören (+ Dat). **ansehen** در فهرست باقاعده است ولی بی‌قاعده صرف می‌شود (sah an، angesehen) ⇒ صرف از کارت sehen، `regelmaessig: false` + `anmerkung`. angeln، ankern، ängstigen، animieren، annektieren … جداشدنی نیستند («an» جزء ریشه است) ⇒ `trennbar: false`. angehören: Partizip II بدون ge- اضافه (angehört). اصلاح‌ها (commit جدا `fee0707`): «(sich)» از fa در ändern/ängstigen برداشته شد (`vokab_qualitaet` ⇒ با `--update`)؛ دو مدخل wortnetz با عبارت چندکلمه‌ای به‌جای فعل («Angst haben»، «Gassi gehen») ⇒ fürchten، spazieren. هیچ فعلی کنار گذاشته نشد. ⏭️ Claude: افعال باقاعده **از anseilen**. <!--W2644-->
> قبلی: 2026-10-13 (ادامه ۱۱) — **۳۰ فعل باقاعده‌ی تازه** (Lukas: «ادامه بده»؛ اول: CI `5c57e45` سبز بود): دور ۶۲۴ adaptieren … ähneln · دور ۶۲۵ ahnen … alphabetisieren · دور ۶۲۶ altern … anästhetisieren (هر دور: dry-run ۰/۰ و import جدا؛ vokab_index، ✓ در فهرست، analyze بدون خطا، `vokab_qualitaet` بدون هشدار، تست‌های کلمه سبز؛ هر دور commit خودش؛ کل تست‌ها در CI) ⇒ آرشیو **۷۲۳۱**. پایه‌ها: akzeptieren، aktivieren، aktualisieren، analysieren، adoptieren، addieren، ahnen، ähneln (+ Dat)، alarmieren، amüsieren (sich … über + Akk). altern: sein. فعل‌های پزشکی: amputieren، anästhetisieren. یک اصلاح پیش از commit: «(sich)» از ترجمه‌ی fa در amüsieren برداشته شد (`vokab_qualitaet`). **۱۱ فعل کنار گذاشته** (#۱۴۴۷–۱۴۵۷): تخصصی/نادر (addizieren، affizieren، algorithmisieren، allozieren، amalgamieren)، ادبی/قدیمی (affirmieren، alimentieren، älteln، alterieren، altertümeln)، املا (altmachen). ⏭️ Claude: افعال باقاعده **از anbändeln**. <!--W2614-->
> قبلی: 2026-10-13 (ادامه ۱۰) — **شروع فهرست ۳: افعال باقاعده** (Lukas: «ادامه بده»؛ اول: CI `c0d167f` سبز بود): **۳۰ فعل تازه** — دور ۶۲۱ aalen … abkupfern · دور ۶۲۲ abmagern … absorbieren · دور ۶۲۳ abstatten … ackern (هر دور: dry-run ۰/۰ و import جدا؛ vokab_index، ✓ در فهرست، analyze بدون خطا، `vokab_qualitaet` بدون هشدار، تست‌های کلمه سبز؛ هر دور commit خودش؛ کل تست‌ها در CI) ⇒ آرشیو **۷۲۰۱**. ⚙️ ابزار Claude (بیرون از ریپو): صرف افعال باقاعده با قاعده‌ی ثابت ساخته شد (e-Einschub برای d/t و chn/ffn/gn/tm، ‎-eln/-ern، ‎-ieren بدون ge-، پیشوند جداشدنی/جدانشدنی) و پیش از استفاده با **همه‌ی ۳۹ کارت باقاعده‌ی موجود** مقایسه شد؛ قرارداد کارت‌های موجود حفظ شد: امر du با ‎-e (Zeige!)، K I برای ‎-ern «lieferest/lieferet». نکته‌ها: abduzieren، absolvieren، absorbieren، abstrahieren جدانشدنی‌اند (ab- لاتینی) ⇒ `trennbar: false`؛ abstumpfen: haben + `anmerkung` (sein برای «بی‌تفاوت شدن»)؛ abzweigen: sein + `anmerkung` (گذرا با haben)؛ ächten ≠ achten در `anmerkung`. **۳ فعل کنار گذاشته** (#۱۴۴۴–۱۴۴۶): aasen، abhausen (منطقه‌ای)، abwägen (wog/wägte، مثل wägen). ⏭️ Claude: افعال باقاعده **از adaptieren**. <!--W2584-->
> قبلی: 2026-10-13 (ادامه ۹) — **🏁 فهرست افعال بی‌قاعده تمام شد** (Lukas: «بقیه افعال رو وارد کن» + «ادامه»؛ اول: CI `b425c5f` سبز بود): **۷۳ فعل تازه** در دور ۶۱۳–۶۲۰ (zerbrechen … zuwiderlaufen؛ هر دور: dry-run ۰/۰ و import جدا؛ vokab_index، ✓ در فهرست، analyze بدون خطا، `vokab_qualitaet` بدون هشدار، تست‌های کلمه سبز؛ هر دور commit خودش؛ کل تست‌ها در CI) ⇒ آرشیو **۷۱۷۱**؛ `naechste_woerter.dart`: فهرست بی‌قاعده ⇒ **۰ باز**. پایه‌ها: ziehen (A2؛ haben + `anmerkung` «sein برای نقل مکان»)، zurückkommen (A1)، zurückgeben، zurückgehen، zurückbekommen، zurückfahren، zurückfliegen، zusammenbleiben (A2)، zugeben، zugehen، zukommen، zulassen، zurechtfinden، zurechtkommen، zusammenbrechen، zusammenkommen. zurückfragen در فهرست بی‌قاعده است ولی باقاعده صرف می‌شود ⇒ `regelmaessig: true` + `anmerkung` (مثل ausfragen). zerbrechen: sein + `anmerkung` (گذرا با haben)؛ zurückliegen: haben + `anmerkung` (جنوب/اتریش sein، مثل liegen). ⚙️ ابزار Claude (بیرون از ریپو، بازسازی شد): صرف هر فعل از جدول کارت فعلِ پایه‌ی موجود در `assets/vocab/verb/` ساخته شد (پیشوند جداشدنی/جدانشدنی روی همان شکل‌ها) تا خطای دستی نباشد. **۴۳ فعل کنار گذاشته** (#۱۴۰۱–۱۴۴۳): ترکیب‌های وجهی، hauen/biegen/kneifen/kriechen/mahlen (مثل سابقه)، املای نوسان‌دار (zueinander-…)، zuerkennen (جداشدنی/جدانشدنی نوسان‌دار)، نادرها؛ ⚠️ **zusammenhängen** (پرکاربرد B1، ولی ترکیب hängen: hing/hängte ⇒ مثل بقیه‌ی hängen-ها کنار رفت؛ تصمیم Lukas در «🏁 مرحله‌ی آخر»). ⏭️ Claude: **فهرست ۳ — افعال باقاعده از aalen** (`Verben_regelmaesig.txt`، ۲۹۹۳ باز). <!--W2554-->
> قبلی: 2026-10-13 (ادامه ۸) — **۳۰ فعل تازه** (Lukas: «ادامه بده»؛ اول: CI `afa15f6` سبز بود): دور ۶۱۰ weggießen … weiterfliegen · دور ۶۱۱ weitergeben … wiederbekommen · دور ۶۱۲ wiederbringen … zerbeißen (هر دور: dry-run ۰/۰ و import جدا؛ vokab_index، ✓ در فهرست، analyze بدون خطا، `vokab_qualitaet` بدون هشدار، تست‌های کلمه سبز؛ هر دور commit خودش؛ کل تست‌ها در CI) ⇒ آرشیو **۷۰۹۸**. پایه‌های A1/A2: werden (فعل کمکی؛ Partizip «worden» در مجهول در `anmerkung`)، wissen، wollen (`modalverb: true`، امر null، Ersatzinfinitiv مثل mögen)، werfen، weglaufen، weiterfahren، weitergehen، weiterhelfen، wiederkommen. ⚠️ **یافته‌ی ابزار:** فعل **wollen** با صفت «wollen» (پشمی، 2026-10-11 کنار گذاشته) هم‌نویسه است و `zurueckgestellt` بر اساس خود کلمه کار می‌کند ⇒ `naechste_woerter.dart` فعل را هم رد می‌کرد. کارت فعل دستی ساخته شد (`abhaken` بر اساس Wortart است، پس ✓ درست خورد). بررسی همه‌ی فهرست افعال: فقط همین یک مورد بود (belesen، erlesen، überlaufen عمداً به‌عنوان فعل کنار رفته‌اند). **۲۴ فعل کنار گذاشته** (#۱۳۷۷–۱۴۰۰): ⚠️ **wenden** و **wiegen** (پرکاربرد، دو صرف بسته به معنا ⇒ مثل schaffen، تصمیم Lukas)، ترکیب‌های وجهی، املای نوسان‌دار (wissenlassen، wundliegen)، قدیمی/نادر. ⏭️ Claude: افعال **از zerbersten**. <!--W2481-->
> قبلی: 2026-10-13 (ادامه ۷) — **۳۰ فعل تازه** (Lukas: «ادامه بده»؛ اول: CI `85c36c9` سبز بود): دور ۶۰۷ vorfallen … vorladen · دور ۶۰۸ vorlassen … wegbekommen · دور ۶۰۹ wegblasen … weggehen (هر دور: dry-run ۰/۰ و import جدا؛ vokab_index، ✓ در فهرست، analyze بدون خطا، `vokab_qualitaet` بدون هشدار، تست‌های کلمه سبز؛ هر دور commit خودش؛ کل تست‌ها در CI) ⇒ آرشیو **۷۰۶۸**. پایه‌ها: wachsen، vorhaben، wegbringen، wegfahren، weggehen (A2)؛ vorkommen، vorgehen، vorwärtskommen، wegbleiben، weggeben، wegfliegen (B1). wähnen در فهرست بی‌قاعده است ولی باقاعده صرف می‌شود ⇒ `regelmaessig: true` + `anmerkung` (مثل löschen). vorliegen: haben + `anmerkung` «جنوب/اتریش sein» (مثل liegen). vorwärtsbringen/-gehen/-kommen: سرهم فقط در معنای مجازی (پیشرفت) ⇒ `anmerkung`؛ vorwärtslaufen (معنای مکانی، جدا نوشته می‌شود) کنار رفت. wegfahren: sein + `anmerkung` (گذرا با haben). wegbekommen: Partizip II بدون ge-. **۲۶ فعل کنار گذاشته** (#۱۳۵۱–۱۳۷۶): vorüber-‌های ادبی، املای نوسان‌دار (wachhalten، warmhalten، warmlaufen)، wägen (wog/wägte)، wahrhaben (ناقص)، wegbrechen (فعل کمکی)، ترکیب‌های وجهی و نادرها. ⏭️ Claude: افعال **از weggießen**. <!--W2451-->
> قبلی: 2026-10-13 (ادامه ۶) — **۳۰ فعل تازه** (Lukas: «ادامه بده»؛ اول: CI `5595458` سبز بود): دور ۶۰۴ verleihen … voranbringen · دور ۶۰۵ vorangehen … vorbeifahren · دور ۶۰۶ vorbeifliegen … vorfahren (هر دور: dry-run ۰/۰ و import جدا؛ vokab_index، ✓ در فهرست، analyze بدون خطا، `vokab_qualitaet` بدون هشدار، تست‌های کلمه سبز؛ هر دور commit خودش؛ کل تست‌ها در CI) ⇒ آرشیو **۷۰۳۸**. پایه‌ها: verlieren (A2)، vorbeigehen و vorbeikommen (A2)، vermeiden، verleihen، vorankommen، vorbeibringen، vorbeifahren، vorbeilaufen، vorbeilassen (B1). vermögen: گذشته‌ی نامنظم (vermag/vermochte)، `modalverb: false` (طبق پرامپت فقط شش فعل وجهی)، امر null. vorbehalten و vollbringen: Partizip II بدون ge-. vonstattengehen، vorankommen، voraushaben، vordenken، verlöschen: امر null. دو اصلاح پیش از commit: «(sich)» از ترجمه‌ی fa در verlesen/vermessen برداشته شد (`vokab_qualitaet`)؛ اشاره‌ی نادرست «rumbringen» از anmerkung‌ی vorbeibringen حذف شد. **۲۳ فعل کنار گذاشته** (#۱۳۲۸–۱۳۵۰): املای نوسان‌دار (verlorengeben، verlorengehen، verschüttgehen، vollessen، vollfressen، vollgießen، vollladen، volllaufen)، ترکیب‌های وجهی (vorbeidürfen، vorbeikönnen، vorbeimüssen)، vorenthalten (جداشدنی/جدانشدنی نوسان‌دار ⇒ «🔀»)، vermahlen (مثل ausmahlen) و نادر/منطقه‌ای. ⏭️ Claude: افعال **از vorfallen**. <!--W2421-->
> قبلی: 2026-10-13 (ادامه ۵) — **۳۰ فعل تازه** (Lukas: «Mach weiter»؛ اول: ورودی ادامه ۴ ثبت شد و CI دور ۵۹۸–۶۰۰ سبز بود): دور ۶۰۱ verdenken … vergehen · دور ۶۰۲ vergelten … verhelfen · دور ۶۰۳ verkennen … verleiden (هر دور: dry-run ۰/۰ و import جدا؛ vokab_index، ✓ در فهرست، analyze بدون خطا، `vokab_qualitaet` بدون هشدار، تست‌های کلمه سبز؛ هر دور commit خودش؛ کل تست‌ها در CI) ⇒ آرشیو **۷۰۰۸**. پایه‌ها: vergessen (A1)، vergleichen (A2)، verlassen (A2، «sich verlassen auf»)، verhalten، vergeben، vergehen، verlaufen، verbinden. فعل کمکی دوگانه ⇒ فعل کمکی اصلی + `anmerkung` (verfliegen، vergehen، verlaufen: sein؛ sich … haben). باقاعده در فهرست بی‌قاعده: verkneten، verleiden ⇒ `regelmaessig: true` + `anmerkung`. یک خطای ابزار پیش از import گرفته شد: صرف vergessen از جدول اشتباه ساخته شده بود (veraß) ⇒ با جدول درست (vergaß) جایگزین شد. **۸ فعل کنار گذاشته** (#۱۳۲۰–۱۳۲۷): verdingen، verdreschen، verdrießen، vergären، verglimmen، verhauen، verkiesen، verkleiben. ⏭️ Claude: افعال **از verleihen**. <!--W2391-->
> قبلی: 2026-10-13 (ادامه ۴) — **۳۰ فعل تازه** (Lukas: «ادامه کلمات رو وارد کن» + «Mach weiter»): دور ۵۹۸ umdenken … umherliegen · دور ۵۹۹ umhinkommen … unterkommen · دور ۶۰۰ unterlassen … verbrennen (هر دور: dry-run ۰/۰ و import جدا؛ بعد vokab_index، ✓ در فهرست، analyze بدون خطا، `vokab_qualitaet` بدون هشدار، تست‌های کلمه (verb_formen_suche، vokab_schema، vokab_index، vokab_suche، vokab_ids_waechter، vokab_formen) سبز؛ هر دور commit خودش؛ **GitHub Actions هر سه دور سبز** — کل ۳۸۵ تست در CI) ⇒ آرشیو **۶۹۷۸**. ⚙️ ابزار Claude (بیرون از ریپو): اجرای کامل `flutter test` روی ماشین Claude آن را ریست کرد ⇒ محلی فقط تست‌های کلمه، کل تست‌ها در CI. **۲۸ فعل کنار گذاشته** (#۱۲۹۲–۱۳۱۹): ۱۲ دوگانه‌ی جداشدنی/جدانشدنی طبق «🔀» (umfahren، umfliegen، umgeben، umgehen، umgreifen، umlaufen، unterbinden، untergraben، unterhalten، unterliegen، unterlaufen، unterfahren)، بقیه نادر/عامیانه یا شکل نوسان‌دار. umhinkommen فقط منفی (`anmerkung` + rektion zu-Infinitiv)؛ verbrennen: haben + `anmerkung` (ناگذر sein)؛ verbitten reflexiv obligatorisch (Dativ)؛ verbrechen با اشاره به اسم «das Verbrechen». ⏭️ Claude: افعال **از verdenken**. <!--W2361-->
> قبلی: 2026-10-13 (ادامه ۳) — **تصمیم Lukas ثبت شد:** فعل‌های دوگانه‌ی جداشدنی/جدانشدنی (über-/um-/durch- …) کنار می‌روند تا **بعد از تمام شدن همه‌ی افعال**؛ آن موقع اول تصمیم‌ها (کارت + شکل هندسی و …) ⇒ پرامپت کامل ویژه (مثل Wort prompt) ⇒ ثبت در PLAN/MAP ⇒ بعد ساخت. جزئیات: «🏁 مرحله‌ی آخر» ⇒ «🔀». فقط سند؛ کارت و کد دست نخورد. ⏭️ Claude: افعال **از umdenken**. <!--W2331-->
> قبلی: 2026-10-13 (ادامه ۲) — **۳۰ فعل تازه** (Lukas: «ادامه بده»؛ اول: CI دور قبل `1fac298` سبز بود): دور ۵۹۵ standhalten … stoßen · دور ۵۹۶ streichen … trügen · دور ۵۹۷ tun … umbringen (هر دور: dry-run ۰/۰ و import جدا؛ بعد vokab_index، ✓ در فهرست، analyze و تست روی حالت نهایی هر سه دور؛ هر دور commit خودش) ⇒ آرشیو **۶۹۴۸**؛ `vokab_qualitaet`: فقط ۴ «لاتین در fa» عمدی. پایه‌های A1/A2: stehen، tragen، treffen، trinken، tun، steigen، sterben، stattfinden، streiten. stecken باقاعده + `anmerkung` (مثل löschen). **اولین فعل‌های جدانشدنی با über-:** überbieten، überbringen، überdenken، übergeben (Partizip II بدون ge-، امر «Übergib!»؛ ابزار Claude بیرون از ریپو). **قاعده‌ی تازه برای über-/um- (پیروی از سابقه‌ی durchdenken/durchfahren):** اگر فعل هم جداشدنی هم جدانشدنی باشد، یا مطمئن نیستم، کنار می‌رود (قاعده‌ی ۳ Lukas: نماد غلط بدتر از نبودن) — überfahren، übergehen، überlaufen، umbrechen و … . دو مثال پیش از import اصلاح شد: stoßen («stößt die Tür auf» = aufstoßen، فعل دیگر)، umbringen (جمله‌ی خودکشی برداشته شد؛ rektion خالی). **۴۷ فعل کنار گذاشته** (#۱۲۴۵–۱۲۹۱). ⏭️ Claude: افعال **از umdenken** (umfahren، umgehen و … هم دوگانه‌اند ⇒ دقت). <!--W2330-->
> قبلی: 2026-10-13 (ادامه ۱) — **۳۰ فعل تازه** (Lukas: «Mach weiter»؛ اول: CI دور قبل `21a5156` سبز بود): دور ۵۹۲ schlagen … schreien · دور ۵۹۳ schreiten … sein · دور ۵۹۴ sichergehen … springen (هر دور: dry-run ۰/۰ و import جدا؛ بعد vokab_index، ✓ در فهرست، analyze و ۳۸۵ تست سبز روی حالت نهایی هر سه دور؛ هر دور commit خودش) ⇒ آرشیو **۶۹۱۸**؛ `vokab_qualitaet`: فقط ۴ «لاتین در fa» عمدی (sich schleichen، sich an، zu + Dat، auf + Akk). پایه‌های A1: sehen، sein (کارت فعل؛ جدا از ضمیر ملکی «sein»)، sprechen، schließen، schneiden، schwimmen، singen، sitzen، sollen (فعل وجهی مثل mögen: `modalverb: true`، امر null). schmiegen و schnauben باقاعده + `anmerkung` (مثل löschen)؛ schwimmen/spinnen/schwören: Konjunktiv II اصلی Duden در جدول، شکل فرعی در `anmerkung`. دو مثال پیش از import اصلاح شد: schlingen (hinuntergeschlungen = فعل دیگر)، sein (wortnetz «da sein» ⇒ bleiben). **۲۶ فعل کنار گذاشته** (#۱۲۱۹–۱۲۴۴): دو صرف برای دو معنا (schleifen، schrecken، schwellen)، نوسان املا/صرف، فعل‌های ناقص، خطای فهرست (schliefen) و نادرها. ⏭️ Claude: افعال **از standhalten**. <!--W2300-->
> قبلی: 2026-10-13 — **۳۰ فعل تازه** (Lukas: «سی کلمه جدید وارد اپ کن»): دور ۵۸۹ reinfahren … rüberbringen · دور ۵۹۰ rüberkommen … runterladen · دور ۵۹۱ runterlassen … schlafen (هر دور: dry-run ۰/۰ و import جدا؛ بعد vokab_index، ✓ در فهرست، analyze و تست روی حالت نهایی هر سه دور — به‌خاطر محدودیت زمان ماشین Claude یک‌بار؛ هر دور commit خودش) ⇒ آرشیو **۶۸۸۸**؛ analyze بدون خطا، ۳۸۵ تست سبز؛ `vokab_qualitaet` روی ۳۰ کارت: فقط ۳ «لاتین در fa» عمدی (es geht rund، sich scheiden lassen، auf + Akk). پایه‌های A1/A2: rufen، schlafen، scheinen، rennen، riechen، schieben، runterladen. فعل‌های دوکمکی (reißen، reiten، schießen، scheiden) با یک hilfsverb + توضیح در `anmerkung` (مثل fahren). rümpfen در فهرست بی‌قاعده است ولی باقاعده صرف می‌شود ⇒ `regelmaessig: true` + `anmerkung` (مثل löschen). بی‌شخص‌ها (rundgehen، schiefgehen، schieflaufen) و rumkommen/runterfallen ⇒ امر null (مثل herunterfallen). scheißen با `anmerkung` «Vulgär». **۲۵ فعل کنار گذاشته** (#۱۱۹۴–۱۲۱۸): نوسان املا/صرف/فعل کمکی، ترکیب‌های وجهی و نادرها؛ ⚠️ **schaffen** (دو صرف برای دو معنا، پرکاربرد) هم کنار رفت — تصمیم Lukas در «🏁 مرحله‌ی آخر». ⏭️ Claude: افعال **از schlagen**. <!--W2270-->
> قبلی: 2026-10-11 (دیروقت، ادامه ۱۳) — **۲۰ فعل تازه** (Lukas: «ادامه»): دور ۵۸۷ pleitegehen … raten · دور ۵۸۸ raufkommen … reinbeißen (هر دور: dry-run ۰/۰، analyze و ۳۸۵ تست سبز، commit خودش؛ اسکن لاتین در fa: تمیز) ⇒ آرشیو **۶۸۵۸**. شکل‌های محاوره‌ای ran-/raus-/rauf-/rein- با `anmerkung` «Umgangssprachlich; Standard: heran…/heraus…». reihen باقاعده + `anmerkung`. ⚙️ ابزار Claude (بیرون از ریپو): تست‌ها روی ماشین Claude کندتر شده‌اند (~۴:۲۰ دقیقه)؛ اجرای دور به دو مرحله تقسیم شد (import+analyze / test+commit) — هیچ مرحله‌ای حذف نشده. **۶ فعل کنار گذاشته** (#۱۱۸۸–۱۱۹۳): platzenlassen (املا)، quellen (ناگذر quoll / گذرا quellte)، querkommen، ranbinden، rankönnen، ranmüssen. ⏭️ Claude: افعال **از reinfahren**. <!--W2240-->
> قبلی: 2026-10-11 (دیروقت، ادامه ۱۲) — **۳۰ فعل تازه** (Lukas: «ادامه»): دور ۵۸۴ nachhängen … nahebringen · دور ۵۸۵ nahegehen … niederfallen · دور ۵۸۶ niedergehen … pflegen (هر دور: dry-run ۰/۰، analyze و ۳۸۵ تست سبز، commit خودش؛ اسکن لاتین در fa: تمیز) ⇒ آرشیو **۶۸۳۸**. nehmen (A1) و pflegen (B1، باقاعده + `anmerkung`؛ مهم برای پرستاری) ساخته شدند؛ nieten هم باقاعده + `anmerkung`. دو مثال پیش از import اصلاح شد: nahekommen (جمله‌ی «zu nahe» و شکل näherkommen ⇒ شکل‌های درست nahegekommen)، pfeifen (abgepfiffen = فعل دیگر ⇒ «einen Elfmeter gepfiffen»). **۱۶ فعل کنار گذاشته** (#۱۱۷۲–۱۱۸۷): ترکیب‌های وجهی، املای جدا (näherliegen، nebeneinanderhalten، nebeneinanderliegen)، فعل کمکی نامعلوم (niederbrechen، niederbrennen)، obliegen (جداشدنی و جدانشدنی)، haute/hieb (niederhauen) و فعل‌های نادر. ⏭️ Claude: افعال **از platzenlassen**. <!--W2210-->
> قبلی: 2026-10-11 (دیروقت، ادامه ۱۱) — **۳۰ فعل تازه** (Lukas: «ادامه»): دور ۵۸۱ loslassen … mitfahren · دور ۵۸۲ mitfliegen … mitlesen · دور ۵۸۳ mögen … nachgießen (هر دور: dry-run ۰/۰، analyze و ۳۸۵ تست سبز، commit خودش؛ اسکن لاتین در fa: تمیز) ⇒ آرشیو **۶۸۰۸**. mögen (فعل وجهی A1: `modalverb: true`، امر null، «möchte» در `anmerkung`)؛ جدانشدنی‌ها با miss-: missfallen، misslingen (sein). **۱۲ فعل کنار گذاشته** (#۱۱۶۰–۱۱۷۱): ترکیب‌های وجهی (loskönnen، losmüssen، mitdürfen، mitkönnen، mitmüssen، nachdürfen) و نادر/ادبی (mitbieten، mitempfinden، mitklingen، mitlassen، nachfallen، nachgären). ⏭️ Claude: افعال **از nachgreifen**. <!--W2180-->
> قبلی: 2026-10-11 (دیروقت، ادامه ۱۰) — **۳۰ فعل تازه** (Lukas: «ادامه»): دور ۵۷۸ hinzuziehen … krummgehen · دور ۵۷۹ kundgeben … liebgewinnen · دور ۵۸۰ liebhaben … loskommen (هر دور: dry-run ۰/۰، analyze و ۳۸۵ تست سبز، commit خودش؛ اسکن لاتین در fa: تمیز) ⇒ آرشیو **۶۷۷۸**. فعل‌های پایه‌ی پرکاربرد: laden، lassen (Ersatzinfinitiv در `anmerkung`)، laufen، leiden، lesen، liegen، löschen. **löschen** در فهرست بی‌قاعده است ولی گذرا و باقاعده صرف می‌شود (löschte, gelöscht) ⇒ `regelmaessig: true` + `anmerkung` (erlöschen ناگذر و بی‌قاعده است). دو مثال پیش از import اصلاح شد: losbinden («Bind» ⇒ «Binde den Hund los!»)، hochheben (اسم «Hochheben» ⇒ جمله‌ی فعلی). **۲۱ فعل کنار گذاشته** (#۱۱۳۹–۱۱۵۹): املای جدا/نوسان‌دار (hockenbleiben، laufenlassen، leeressen، liebbehalten، liegenbleiben، liegenlassen)، küren (kor/kürte)، losbrechen (فعل کمکی)، ترکیب‌های وجهی و فعل‌های نادر/عامیانه. ⏭️ Claude: افعال **از loskönnen**. <!--W2150-->
> قبلی: 2026-10-11 (دیروقت، ادامه ۹) — **۳۰ فعل تازه** (Lukas: «ادامه»): دور ۵۷۵ hingehen … hinterherlaufen · دور ۵۷۶ hinterlassen … hinunterfallen · دور ۵۷۷ hinunterfließen … hinzukommen (هر دور: dry-run ۰/۰، analyze و ۳۸۵ تست سبز، commit خودش؛ اسکن لاتین در fa: تمیز) ⇒ آرشیو **۶۷۴۸**. جدانشدنی‌ها با hinter-: hinterfragen (باقاعده + `anmerkung`)، hintergehen، hinterlassen. **۳۴ فعل کنار گذاشته** (#۱۱۰۵–۱۱۳۸): ترکیب‌های وجهی، hängen-ترکیب‌ها، hinhauen (haute/hieb)، hintereinander… (املای جدا)، hinteressen (واژه نیست — احتمالاً خطای فهرست)، و فعل‌های ادبی/نادر — فهرست کامل در «🏁 مرحله‌ی آخر». ⏭️ Claude: افعال **از hinzulaufen**. <!--W2120-->
> قبلی: 2026-10-11 (دیروقت، ادامه ۸) — **۳۰ فعل تازه** (Lukas: «ادامه»): دور ۵۷۲ hinausfliegen … hineinbeißen · دور ۵۷۳ hineinbekommen … hineingehen · دور ۵۷۴ hineingießen … hingeben (هر دور: dry-run ۰/۰، analyze و ۳۸۵ تست سبز، commit خودش؛ اسکن لاتین در fa: تمیز) ⇒ آرشیو **۶۷۱۸**. hineindenken: مثال امری با `noimp` شکل قابل‌جست‌وجو نداشت ⇒ پیش از import با جمله‌ی خبری عوض شد. **۳۰ فعل کنار گذاشته** (#۱۰۷۵–۱۱۰۴): ترکیب‌های وجهی (hinauskönnen، hinausmüssen، hindurchdürfen، hindurchkönnen، hindurchmüssen، hindürfen، hineindürfen، hineinkönnen، hineinmüssen)، hängen-ترکیب‌ها (hinaushängen، hineinhängen)، ادبی/نادر/عامیانه (hinausgreifen، hinaushalten، hinausheben، hinbegeben، hinbieten، hindurchdringen، hindurchfließen، hindurchkriechen، hineinbegeben، hineinblasen، hineinbrennen، hineindringen، hineinfliegen، hineinfressen، hineingleiten، hineingreifen، hineinhalten، hineinkriechen، hinfließen). ⏭️ Claude: افعال **از hingehen**. <!--W2090-->
> قبلی: 2026-10-11 (دیروقت، ادامه ۷) — **۳۰ فعل تازه** (Lukas: «ادامه»): دور ۵۶۹ herunterkommen … hervorkommen · دور ۵۷۰ hervorkriechen … hinauffahren · دور ۵۷۱ hinauffinden … hinausfinden (هر دور: dry-run ۰/۰، analyze و ۳۸۵ تست سبز، commit خودش؛ اسکن لاتین در fa: تمیز) ⇒ آرشیو **۶۶۸۸**. herunterladen (A2، «دانلود کردن») ساخته شد. **۱۷ فعل کنار گذاشته** (#۱۰۵۸–۱۰۷۴): ترکیب‌های وجهی (herunterkönnen، heruntermüssen، hinaufdürfen، hinaufkönnen، hinaufmüssen، hinausdürfen)، hinauffallen (فقط اصطلاح)، hinausdenken، ادبی/نادر (herunterkriechen، hervordringen، herzukommen، hinabfahren، hinaufkriechen، hinauflassen، hinausbegeben، hinausblasen، hinausdringen). ⏭️ Claude: افعال **از hinausfliegen**. <!--W2060-->
> قبلی: 2026-10-11 (دیروقت، ادامه ۶) — **۳۰ فعل تازه** (Lukas: «ادامه»): دور ۵۶۶ herleihen … herüberlaufen · دور ۵۶۷ herumbekommen … herumliegen · دور ۵۶۸ herunterbekommen … herunterhelfen (هر دور: dry-run ۰/۰، analyze و ۳۸۵ تست سبز، commit خودش؛ اسکن لاتین در fa: تمیز) ⇒ آرشیو **۶۶۵۸**. herleihen با `anmerkung` اتریشی؛ herunterfahren: ناگذر sein، گذرا (رایانه، تولید) haben در `anmerkung`. **۲۴ فعل کنار گذاشته** (#۱۰۳۴–۱۰۵۷): ترکیب‌های وجهی (hermüssen، herüberdürfen، herüberkönnen، herübermüssen، herunterdürfen)، hängen-ترکیب‌ها (herüberhängen، herumhängen، herunterhängen)، فعل کمکی نامعلوم (herunterbrechen، herunterbrennen)، ادبی/نادر/عامیانه (herniederfallen، herniedergehen، herüberdringen، herüberfliegen، herumbiegen، herumbinden، herumgreifen، herumhaben، herumkriechen، herunterbiegen، herunterfliegen، heruntergießen، heruntergleiten، herunterhauen). ⏭️ Claude: افعال **از herunterkommen**. <!--W2030-->
> قبلی: 2026-10-11 (دیروقت، ادامه ۵) — **۲۰ فعل تازه** (Lukas: «ادامه»): دور ۵۶۴ hereinbekommen … hereinlaufen · دور ۵۶۵ herfahren … herlaufen (هر دور: dry-run ۰/۰، analyze و ۳۸۵ تست سبز، commit خودش) ⇒ آرشیو **۶۶۲۸**. اصلاح: در `verb_herfallen` یک کلمه‌ی انگلیسی («over food») در ترجمه‌ی فارسی بود ⇒ حذف شد (commit جدا)؛ بعد همه‌ی ۲۳۰ کارت این جلسه‌ها برای کلمه‌ی لاتین بیرون از پرانتز در fa اسکن شد ⇒ مورد دیگری نبود. **۸ فعل کنار گذاشته** (#۱۰۲۶–۱۰۳۳): herdürfen، hereindringen، hereindürfen، hereingeben، hereinkönnen، hereinkriechen، hereinmüssen، herkönnen. ⏭️ Claude: افعال **از herleihen** (⚠️ در اتریش = «قرض دادن»). <!--W2000-->
> قبلی: 2026-10-11 (دیروقت، ادامه ۴) — **۳۰ فعل تازه** (Lukas: «ادامه»): دور ۵۶۱ heraufkommen … herausfließen · دور ۵۶۲ herausgeben … herauskriechen · دور ۵۶۳ herauslassen … herbringen (هر دور: dry-run ۰/۰، analyze و ۳۸۵ تست سبز، commit خودش) ⇒ آرشیو **۶۶۰۸**. heraus-‌فعل‌ها: `anmerkung` «در محاوره raus…». **۱۳ فعل کنار گذاشته** (#۱۰۱۳–۱۰۲۵): heraufkönnen، heraufmüssen، herausbrechen (فعل کمکی یکتا نیست)، herausdringen، herausdürfen، heraushängen (گذرا/ناگذر)، heraushauen، herausklingen، herauskönnen، herausmüssen، herbeifahren، herbeifliegen، herbeilassen. ⏭️ Claude: افعال **از herdürfen**. <!--W1970-->
> قبلی: 2026-10-11 (دیروقت، ادامه ۳) — **۳۰ فعل تازه** (Lukas: «ادامه»): دور ۵۵۸ gegenlesen … heimbringen · دور ۵۵۹ heimfahren … herabhängen · دور ۵۶۰ herablassen … herauffahren (هر دور: dry-run ۰/۰، analyze و ۳۸۵ تست سبز، commit خودش) ⇒ آرشیو **۶۵۷۸**. gehen و geschehen (پایه‌ای) ساخته شدند. heim-‌فعل‌ها: `anmerkung` «بیشتر جنوب آلمان/اتریش». **۱۶ فعل کنار گذاشته** (#۹۹۷–۱۰۱۲): geheißen (مصدر نیست، Partizip II heißen)، gutgehen (املای نوسان‌دار)، heimbegeben، heimdürfen، heimfallen، heimkönnen، heimmüssen، heischen، herabfahren، herabkommen، heranbinden، herandürfen، herankönnen، heranmüssen، heraufdringen، heraufdürfen. ⏭️ Claude: افعال **از heraufkommen**. <!--W1940-->
> قبلی: 2026-10-11 (دیروقت، ادامه ۲) — **۳۰ فعل تازه** (Lukas: «ادامه»): دور ۵۵۵ festlaufen … fortbringen · دور ۵۵۶ fortfahren … freibekommen · دور ۵۵۷ freigeben … gegenhalten (هر دور: dry-run ۰/۰، analyze و ۳۸۵ تست سبز، commit خودش) ⇒ آرشیو **۶۵۴۸**. finden، fragen، fressen، flechten (پایه‌ای) ساخته شدند؛ gedenken/gefrieren با پیشوند جدانشدنی ge-. **۱۳ فعل کنار گذاشته** (#۹۸۴–۹۹۶): fortbegeben، fortblasen، fortdenken، fortdürfen، fortgießen، forthaben، fortkönnen، fortkriechen، fortmüssen، freibleiben، freilaufen، gegeneinanderhalten، gegenfragen. ⏭️ Claude: افعال **از gegenlesen**. <!--W1910-->
> قبلی: 2026-10-11 (دیروقت، ادامه) — **۲۰ فعل تازه** (Lukas: «Mach weiter»): دور ۵۵۳ erwägen … fernhalten · دور ۵۵۴ fernliegen … festhängen (هر دور: dry-run ۰/۰، analyze و ۳۸۵ تست سبز، commit خودش) ⇒ آرشیو **۶۵۱۸**. essen، fahren، fallen، fangen (پایه‌ای) ساخته شدند. fahren و festfahren: فعل کمکی اصلی + `anmerkung`. **۹ فعل کنار گذاشته** (#۹۷۵–۹۸۳): erschrecken (ناگذر erschrak / گذرا erschreckte — یک نماد درست نیست)، fahen، fahrenlassen و fallenlassen و feinmahlen و fertiglesen (املای جدا/نوسان‌دار)، feilbieten، feilhalten، festbleiben. ⏭️ Claude: افعال **از festlaufen**. <!--W1880-->
> قبلی: 2026-10-11 (شب؛ ساعت سیستم — ورودی قبلی تاریخ 2026-10-12 خورده بود) — **۱۰۰ فعل تازه** (Lukas: «صد تا فعل جدید وارد اپ کن» + «Mach weiter»): دور ۵۴۳–۵۵۲، durchfinden … ermessen (هر دور: dry-run ۰/۰، analyze و همه‌ی ۳۸۵ تست سبز (Flutter محلی)، `vokab_qualitaet` فقط هشدار شناخته‌شده‌ی «sich …/+ Genitiv» در fa، commit خودش؛ **GitHub Actions دور ۵۴۳–۵۵۲ همه سبز**) ⇒ آرشیو **۶۴۹۸**. صرف هر فعل از جدول ثابت فعل پایه ساخته شد (پیشوند جداشدنی/جدانشدنی روی همان شکل‌ها) تا خطای دستی نباشد. باقاعده‌ها در فهرست بی‌قاعده (durchfragen، durchkneten، entbehren، erfragen) ⇒ `regelmaessig: true` + `anmerkung`. dürfen: `modalverb: true`، امر = null. فعل‌هایی که فاعلشان معمولاً شخص نیست (entfallen، entstehen، erklingen، erlöschen …) ⇒ امر = null (قاعده‌ی ۳). **۴۷ فعل کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #۹۲۸–۹۷۴ + `zurueckgestellt`): هم جداشدنی هم جدانشدنی (durchfliegen، durchlaufen …)، نادر/ادبی/منسوخ، صرف یا املای نوسان‌دار (einhängen، erbleichen، eislaufen). ⏭️ Claude: افعال **از erschrecken** — ⚠️ erschrecken دو صرف دارد (ناگذر erschrak/erschrocken، گذرا erschreckte/erschreckt) ⇒ دقیق بررسی شود (کنار گذاشتن یا یک کارت + `anmerkung`). <!--W1860-->
> قبلی: 2026-10-12 (بعد) — **۱۰۰ فعل تازه** (Lukas: «صد فعل» + «Mach weiter»): دور ۵۳۳–۵۴۲، aushelfen … durchfechten (هر دور: dry-run ۰/۰، analyze و همه‌ی ۳۸۵ تست سبز (Flutter محلی)، commit خودش؛ GitHub Actions دور ۵۳۳–۵۴۰ سبز) ⇒ آرشیو **۶۳۹۸**. باقاعده‌ها در فهرست بی‌قاعده (bedingen، befragen، befürchten، bellen) ⇒ `regelmaessig: true` + `anmerkung`. فعل‌هایی که هم جداشدنی هم جدانشدنی‌اند با معنای متفاوت (durchbrechen، durchdenken، durchdringen، durchfahren) طبق قاعده‌ی ۳ (نماد غلط بدتر از نبودن) کنار گذاشته شدند. **۹۱ فعل کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #۸۳۷–۹۲۷ + `zurueckgestellt`)، بیشترشان ترکیب‌های نادر/ادبی da-/dar-/drauf-/beisammen- یا فعل کمکی متغیر (…liegen)؛ bedürfen: امر رایج ندارد. ⏭️ Claude: افعال **از durchfinden**؛ ⚠️ دقت: در ادامه‌ی فهرست durch- بسیاری هم جداشدنی هم جدانشدنی‌اند ⇒ هر کدام جدا بررسی شود. <!--W1760-->
> قبلی: 2026-10-12 — **۲۰ فعل تازه** (Lukas: «ادامه بده»): دور ۵۳۱ auseinanderfahren … ausfließen · دور ۵۳۲ ausfragen … ausheben (هر دور: dry-run ۰/۰، analyze و همه‌ی ۳۸۵ تست سبز (Flutter محلی)، commit خودش) ⇒ آرشیو **۶۲۹۸**. ausfragen (مثل aufkreischen) در فهرست بی‌قاعده است ولی باقاعده صرف می‌شود ⇒ `regelmaessig: true` + `anmerkung`. ausfahren و ausfliegen: sein + `anmerkung` (حالت گذرا با haben). **۹ فعل کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #۸۲۸–۸۳۶ + `zurueckgestellt`): auserkiesen، ausfinden، ausfrieren، ausgären، ausgebären، ausgreifen، aushaben، aushängen، aushauen. ⏭️ Claude: افعال **از aushelfen**. <!--W1660-->
> قبلی: 2026-10-11 (نیمه‌شب) — **۲۰ فعل تازه** (Lukas: «ادامه بده»): دور ۵۲۹ aufschreien … ausbleiben · دور ۵۳۰ ausbraten … auseinanderbringen (هر دور: dry-run ۰/۰، analyze و همه‌ی ۳۸۵ تست سبز (Flutter محلی)، commit خودش) ⇒ آرشیو **۶۲۷۸**. فعل‌هایی که هم با sein هم با haben می‌آیند (ausbrechen، ausbrennen، auseinanderbrechen) طبق سابقه‌ی auffahren/aufbrechen: فعل کمکی اصلی (sein) + `anmerkung`. **۷ فعل کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #۸۲۱–۸۲۷ + `zurueckgestellt`): ausbedingen، ausbiegen، ausbieten، ausbinden، ausbleichen، ausdreschen، auseinanderbersten. ⏭️ Claude: افعال **از auseinanderfahren**. <!--W1640-->
> قبلی: 2026-10-11 (دیروقت) — **۲۰ فعل تازه** (Lukas: «کلمات بعدی رو وارد کن»): دور ۵۲۷ auffinden … aufhaben · دور ۵۲۸ aufhalten … aufrechterhalten (هر دور: dry-run ۰/۰، analyze و همه‌ی ۳۸۵ تست سبز (Flutter محلی)، commit خودش؛ GitHub Actions دور ۵۲۷ سبز) ⇒ آرشیو **۶۲۵۸**. aufkreischen در فهرست بی‌قاعده است ولی طبق Duden امروز باقاعده صرف می‌شود ⇒ `regelmaessig: true` + `anmerkung`. aufrechterhalten: Partizip II بدون ge- (aufrechterhalten). **۸ فعل کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #۸۱۳–۸۲۰ + `zurueckgestellt`): aufgleiten، aufglimmen، aufhauen، aufkleiben، aufklieben، aufklingen، aufliegen، aufrechtbleiben. ⚠️ `wort_runde.sh` در پس‌زمینه (nohup) دوباره قطع شد ⇒ مراحل جدا و در پیش‌زمینه اجرا شدند (همان ترتیب). ⏭️ Claude: افعال **از aufschreien**. <!--W1620-->
> قبلی: 2026-10-11 (شب) — **🚦 افعال** (Lukas: گزینه‌ی ب + فعل پیشوندی کارت جدا + شکل با معنای مستقل کارت جدا + یکدست): زیرساخت (قاعده‌ی ۱۶، Konjunktiv I/II، modalverb، جست‌وجوی همه‌ی شکل‌ها، تست verb_formen_suche_test) · ۷۶ فعل قدیمی یکدست · دور ۵۲۲–۵۲۶: abbacken … auffangen (۱۰۹ فعل؛ هر دور dry-run ۰/۰، ۳۸۵ تست سبز) ⇒ آرشیو **۶۲۳۸** · کنار گذاشته #۷۹۱–۸۱۲ · ابزار listenLemma. ⏭️ Claude: افعال **از auffinden**. <!--W1600-->
> قبلی: 2026-10-11 (بعد) — **🔍 فاز Q بازبینی کیفیت — ✅ تمام شد** (Lukas: نگرانی از مرحله‌های Sonnet): Q.1 کد بازه خط به خط ⇒ بدون خطا · Q.2 ابزار ماندگار `tool/vokab_qualitaet.dart` · **یافته:** خطا فقط در کارت‌های ۸ و ۹ اکتبر (= جلسه‌های Sonnet) · سطح مثال‌ها ۶۸۵ کارت ✅ (۵۷۹ برچسب، ۱۰۶ + جمله‌ی ساده) · هر ۹۳۹ کارت ۸–۹ اکتبر خوانده شد + نمونه‌ی ۱۲۰ از ۲۹/۹ و ۱۰/۱۰ ⇒ ۲۴ اصلاح ریز محتوا · همه‌ی تست‌ها سبز. ⏭️ Lukas: ⛔ تصمیم افعال (یک صفحه با همه‌ی شکل‌ها یا صفحه‌ی جدا برای هر شکل). <!--W1600b-->
> قبلی: 2026-10-11 — **🏁 فهرست صفت‌ها تمام شد** (Lukas: «دویست کلمه بعدی رو وارد کن» + «Mach weiter»): **۲۰۴ کارت تازه** wirtschaftlich … überzeugend ⇒ آرشیو **۶۱۲۹ کارت** (دور ۵۱۷–۵۲۱: ۴ دور × ۴۰ + دور آخر ۴۴ تا صفت‌ها کامل شوند؛ هر دور: dry-run ۰/۰، analyze و همه‌ی ۳۷۹ تست سبز (Flutter محلی)؛ هر دور commit خودش؛ GitHub Actions دور ۱–۴ سبز). `naechste_woerter.dart`: Adjektive.txt ⇒ **۰ باز**. **Wortart درست:** zehnte، zehntausendste، zwanzigste، zweite، zweihundertste، zweiundzwanzigste، zwölfte ⇒ `numerale` (ordinal)؛ zehntel ⇒ `numerale` (bruchzahl) — همه + `wortartKorrektur`. «Y-förmig» = همان id کارت y-förmig. **۳۵ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #۷۵۶–۷۹۰ + `zurueckgestellt`)، از جمله منتظر تصمیم Lukas (بار جنسی/رکیک): wollüstig، wuschig، zotig؛ بقیه اصطلاح خیلی تخصصی، معنای نامطمئن یا صفت جنس (zedern، zinnern، zypressen …). ⏭️ **Lukas:** تصمیم درباره‌ی افعال (بخش «📚 روال» ⇒ «⛔ قبل از شروع افعال»): هر شکل صفحه‌ی جدا، یا همه روی صفحه‌ی مصدر + جست‌وجو؛ و اتصال جداشدنی‌ها/اسم‌های هم‌ریشه. ⏭️ Claude: تا تصمیم، `verbenFreigegeben = false` می‌ماند؛ هیچ کارت فعلی ساخته نمی‌شود. <!--W1600a-->
> قبلی: 2026-10-10 (شب) — **۲۰۰ کلمه‌ی تازه** (Lukas: «دویست کلمه بعدی را وارد کن» + «ادامه بده»): vielseitig … wirr ⇒ آرشیو **۵۹۲۵ کارت** (دور ۵۱۲–۵۱۶، ۵ دور × ۴۰ کارت؛ هر دور: dry-run ۰/۰، analyze و همه‌ی ۳۷۹ تست سبز (Flutter محلی)؛ هر دور commit خودش). **Wortart درست:** vierte، vierzehnte، vierzigste ⇒ `numerale` (ordinal)؛ viertel ⇒ `numerale` (bruchzahl)؛ vorbehaltlich، vorbehältlich ⇒ `praeposition` (+ Gen)؛ wahrlich ⇒ `adverb`؛ wenig ⇒ `numerale` (unbestimmt، مثل viel) — همه + `wortartKorrektur`. **۲۶ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #۷۳۰–۷۵۵ + `zurueckgestellt`): vigil، vincentisch، vinophil، vogtländisch، volitional، vorderer و vorletzte (شکل صرف‌شده مثل oberer/letzter)، vorgabenwirksam، vulkanistisch، wegsam، wehrig، weidlich، weinfarben، weinfröhlich، weinfroh، weingelb، weinhaltig، weinig، weinsauer، weißfeldrig، weißgolden، weitentlegen، wergen، westmitteldeutsch، westoberdeutsch، wipfelschäftig. ⚠️ فرایند پس‌زمینه‌ی `wort_runde.sh` در دور اول وسط analyze قطع شد ⇒ از مرحله‌ی ۷ در پیش‌زمینه ادامه یافت؛ دورهای بعد مراحل جدا و در پیش‌زمینه اجرا شدند. ⏭️ Claude: کلمه‌ها **از wirsch** (پیشنهاد: wirsch، wollen (صفت جنسی «پشمی»)، wollüstig (بار جنسی ⇒ تصمیم Lukas) کنار گذاشته شوند). قفل افعال سر جایش است؛ بعد از آخرین صفت (حدود ۲۶۰ کلمه‌ی دیگر) باید از Lukas درباره‌ی افعال پرسید. <!--W1400-->
> قبلی: 2026-10-10 (عصر) — **۲۰۰ کلمه‌ی تازه** (Lukas: «دویست کلمه جدید وارد کن» + «Mach weiter»): unverwandt … vielgestaltig ⇒ آرشیو **۵۷۲۵ کارت** (دور ۵۰۷–۵۱۱، ۵ دور × ۴۰ کارت؛ هر دور: dry-run ۰/۰، analyze و همه‌ی ۳۷۹ تست سبز (Flutter محلی)؛ هر دور commit خودش؛ GitHub Actions دور ۱–۳ سبز). **Wortart درست:** viel ⇒ `numerale` (unbestimmt) + `wortartKorrektur`. **۳۵ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #۶۹۵–۷۲۹ + `zurueckgestellt`)، از جمله منتظر تصمیم Lukas: vaginal، venerisch، versaut، verhaltensgestört (بار جنسی/حساس)، vielerlei (Wortart مثل mancherlei). vag (کنار vage) و valid (کنار valide) طبق ⭐ اصل اول کارت خودشان را گرفتند (با `anmerkung`). ⏭️ Claude: کلمه‌ها **از vielseitig**. قفل افعال سر جایش است. <!--W1200-->
> قبلی: 2026-10-10 — **۲۰۰ کلمه‌ی تازه** (Lukas: «دویست کلمه جدید وارد کن» + «Mach weiter»): unerlässlich … unversucht ⇒ آرشیو **۵۵۲۵ کارت** (۵ دور × ۴۰ کارت؛ هر دور: dry-run ۰/۰، analyze و همه‌ی ۳۷۹ تست سبز (Flutter محلی)؛ هر دور commit خودش؛ GitHub Actions سبز). **۸ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #۶۸۷–۶۹۴ + `zurueckgestellt`): ungerechnet، ungeständig، unikursal، unitaristisch، unleidig، unschierig (املا ناشناخته)، unsexy (جنسی ⇒ تصمیم Lukas)، unterer (شکل صرف‌شده مثل oberer). unplaciert (املای قدیمی unplatziert) طبق ⭐ اصل اول کارت خودش را گرفت (با `anmerkung`). ⏭️ Claude: کلمه‌ها **از unverwandt**. قفل افعال سر جایش است. <!--W1000-->
> قبلی: 2026-10-09 (عصر) — **۱۴۰ کلمه‌ی تازه**: überbordend … unerhört ⇒ آرشیو ۵۳۲۵ (۴ دور؛ این ورودی در همان جلسه جا مانده بود و 2026-10-10 اضافه شد)؛ ۶ کلمه کنار گذاشته (#۶۸۱–۶۸۶): überwechtet، unangesehen، unbedankt، unbeugbar، unbewehrt، undulös.
> قبلی: 2026-10-09 — **۲۰۰ کلمه‌ی تازه** (Lukas: «ادامه» ⇒ دویست کلمه‌ی بعدی): stylish … überaltert ⇒ آرشیو **۵۱۸۵ کارت** (هر دور: dry-run ۰/۰، analyze و همه‌ی تست‌ها سبز؛ هر دور commit خودش؛ Flutter این بار در محیط Claude نصب شد و تست‌ها محلی اجرا شدند). ⏭️ Claude: کلمه‌ها **از überbordend**. قفل افعال سر جایش است. <!--W800-->
> قبلی: 2026-10-08 — **۲۰۰ کلمه‌ی تازه** (Lukas: «ادامه» ⇒ دویست کلمه‌ی بعدی): sinngemäß … stutzig ⇒ آرشیو **۴۹۸۵ کارت** (هر دور: dry-run ۰/۰، analyze و همه‌ی تست‌ها سبز؛ هر دور commit خودش؛ Flutter این بار در محیط Claude نصب شد و تست‌ها محلی اجرا شدند). ⏭️ Claude: کلمه‌ها **از stylish**. قفل افعال سر جایش است. <!--W600-->
> قبلی: 2026-10-08 — **۲۰۰ کلمه‌ی تازه** (Lukas: «ادامه» ⇒ دویست کلمه‌ی بعدی): schlüssig … sinnfällig ⇒ آرشیو **۴۷۸۵ کارت** (هر دور: dry-run ۰/۰، analyze و همه‌ی تست‌ها سبز؛ هر دور commit خودش؛ Flutter این بار در محیط Claude نصب شد و تست‌ها محلی اجرا شدند). ⏭️ Claude: کلمه‌ها **از sinnfrei**. قفل افعال سر جایش است. <!--W400-->
> قبلی: 2026-10-08 — **۲۰۰ کلمه‌ی تازه** (Lukas: «دویست کلمه جدید وارد کن»): rigide … schlüsselfertig ⇒ آرشیو **۴۵۸۵ کارت** (هر دور: dry-run ۰/۰، analyze و همه‌ی تست‌ها سبز؛ هر دور commit خودش؛ Flutter این بار در محیط Claude نصب شد و تست‌ها محلی اجرا شدند). ⏭️ Claude: کلمه‌ها **از schlüssig**. قفل افعال سر جایش است. <!--W200-->
> قبلی: 2026-10-05 (بعدازظهر) — **B-14b: سه بهبود Pomodoro** (درخواست Lukas؛ فقط VOX — Root-in دست‌نخورده): ۱) **روشن ماندن صفحه** (Screen Wake Lock) تا وقتی تایمر کار می‌کند — سوییچ، پیش‌فرض روشن؛ ۲) **اعلام پایان فاز**: بنر «فاز تمام شد» تا اولین کار کاربر + صدای کوتاه (Web Audio) — سوییچ، پیش‌فرض روشن؛ ۳) **شروع خودکار فاز بعدی** — سوییچ، پیش‌فرض **خاموش** (رفتار قبلی). با قفل طولانی همه‌ی فازهای میانی از ساعت واقعی نقل می‌شوند. فایل‌ها: `selbstlernen_controller.dart`، `pomodoro_screen.dart`، تازه `services/pomodoro_geraet*.dart` (۴ فایل: basis/io/web)، `app_l10n.dart` (۹ کلید fa+en)؛ تست‌ها: `test/pomodoro_test.dart` (۲۷)، تازه `test/pomodoro_screen_test.dart` (۳)، `l10n_paritaet_test.dart` (+۹ کلید) — ۳۷۹ تست سبز؛ `flutter build web` محلی موفق. وابستگی تازه‌ای نیست.
> قبلی: 2026-10-05 — **باگ B-14: تایمر Pomodoro با قفل شدن صفحه می‌ایستاد** (گزارش Lukas؛ فقط VOX — در Root-in هیچ چیز تغییر نکرد). علت: تایمر فقط تیک می‌شمرد (`secondsLeft - 1` در هر `Timer.periodic`)؛ مرورگر هنگام قفل/پس‌زمینه تایمر صفحه را متوقف می‌کند و زمان از دست‌رفته هرگز جبران نمی‌شد. راه‌حل ماندگار: بر پایه‌ی ساعت واقعی (`_endsAt`)، محاسبه‌ی دوباره با هر تیک و هنگام `AppLifecycleState.resumed`، و ذخیره‌ی وضعیت در shared_preferences. فایل‌ها: `selbstlernen_controller.dart`؛ تست تازه `test/pomodoro_test.dart`. وابستگی تازه‌ای اضافه نشد (`pubspec.yaml` دست‌نخورده).
> قبلی: 2026-09-30 — **جست‌وجو و لمس با شکل صرف‌شده برای همه‌ی نوع کلمه‌ها** (درخواست Lukas): «aalartige/rauer/Häuser/empfahl» ⇒ کارت/کلمه‌ی درست، هم در «Alle Wörter»، هم جست‌وجوی سراسری، هم لمس. فایل‌ها: `vokabular_controller.dart` (`vokabSucheProvider`، `vokabTrefferZusammen`)، `wortschatz_list_screen.dart`، `home/controllers/search_controller.dart` (کارت‌های آرشیو هم)، تازه `core/wort/altwort_formen.dart`، `word_dao.dart` (`nachForm`)، `klick_wort_provider.dart`؛ تست تازه `test/vokab_suche_test.dart` (۳۴۸ تست سبز). قفل افعال سر جایش است.
> قبلی: 2026-09-30 — **قفل افعال** (درخواست Lukas): قبل از اولین کارت فعل باید از Lukas درباره‌ی جست‌وجوی همه‌ی شکل‌های فعل پرسیده شود (⇒ بخش «📚 روال» ⇒ «⛔ قبل از شروع افعال»)؛ `tool/naechste_woerter.dart`: `verbenFreigegeben = false` + پیام ⛔ (فقط ابزار؛ کد اپ و کارت‌ها دست نخورد). کلمه‌ها همچنان **از rigide**.
> قبلی: 2026-09-29 (دور ۴۶۰–۴۷۹) — **۲۰۰ کلمه‌ی تازه** (Lukas: «دویست کلمه اضافه کن» + «ادامه»): provokant … riesig ⇒ آرشیو **۴۳۸۵ کارت** (هر دور: dry-run ۰/۰، analyze و همه‌ی ۳۴۲ تست سبز؛ هر دور commit خودش؛ GitHub Actions سبز). **Wortart درست:** quadrillionste ⇒ `numerale` (ordinal) + `wortartKorrektur`. **۳۵ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #۴۳۵–۴۶۹ + `zurueckgestellt`): psychrophil، pueril، punitiv، pythonesk، quinär، quittegelb، quotal، räß، räumdig، rahn، rallig، rangig، raß، ratierlich، raubauzig، rebenumsponnen، renaissancistisch، reputabel، reputierlich، resonant، respektiv، restituiert، restitutiv، retikulär، retinotop، retransloziert، retroaktiv، retrobulbär، retrofuturistisch، rezent، rezeptorvermittelt، rheophil، rhodiniert، rhomboedrisch، ridikül. ابزار کمکی ساخت JSON فقط در محیط Claude است (خارج از ریپو)؛ قالب کارت همان پرامپت. اصلاح: `adjektiv_regierungsnah.json` ⇒ صفت تفضیلی/عالی حذف شد (null)، چون شکل «regierungsnäher» مطمئن نبود (قاعده‌ی ۱۴). ⏭️ Claude: کلمه‌ها **از rigide**.
> قبلی: 2026-09-27 (دور ۴۵۶–۴۵۹) — **۴۰ کلمه‌ی تازه** (Lukas: «Weiter»): prickelnd … provisorisch ⇒ آرشیو **۴۱۸۵ کارت** (هر دور: dry-run ۰/۰، analyze و همه‌ی ۳۴۲ تست سبز؛ هر دور commit خودش). Wortart غلطی پیدا نشد. **۵ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #۴۳۰–۴۳۴): primordial، promisk و promiskuitiv (جنسی ⇒ تصمیم با Lukas)، prosopografisch، proteisch. ⏭️ Claude: کلمه‌ها **از provokant**.
> قبلی: 2026-09-27 (دور ۴۵۰–۴۵۵) — **۶۰ کلمه‌ی تازه**: politisch … preußisch ⇒ آرشیو ۴۱۴۵؛ ۲۵ کلمه کنار گذاشته (#۴۰۵–۴۲۹)؛ GitHub Actions سبز.
> قبلی: 2026-09-27 (دور ۴۴۵–۴۴۹) — **۵۰ کلمه‌ی تازه**: phonologisch … polemisch ⇒ آرشیو ۴۰۸۵؛ ۱۰ کلمه کنار گذاشته (#۳۹۵–۴۰۴)؛ GitHub Actions سبز.
> قبلی: 2026-09-27 (دور ۴۴۰–۴۴۴) — **۵۰ کلمه‌ی تازه**: pendent … phonetisch ⇒ آرشیو ۴۰۳۵؛ ۱۶ کلمه کنار گذاشته (#۳۷۹–۳۹۴)؛ GitHub Actions سبز.
> قبلی: 2026-09-27 (دور ۴۳۵–۴۳۹) — **۵۰ کلمه‌ی تازه**: paranoid … pelzig ⇒ آرشیو ۳۹۸۵؛ ۸ کلمه کنار گذاشته (#۳۷۱–۳۷۸)؛ GitHub Actions سبز.
> قبلی: 2026-09-27 (دور ۴۲۹–۴۳۴) — **۶۰ کلمه‌ی تازه**: ordoliberal … paramilitärisch ⇒ آرشیو ۳۹۳۵؛ ۱۸ کلمه کنار گذاشته (#۳۵۳–۳۷۰)؛ GitHub Actions سبز.
> قبلی: 2026-09-27 (دور ۴۲۱–۴۲۸) — **۸۰ کلمه‌ی تازه**: obersächsisch … ordnungspolitisch ⇒ آرشیو ۳۸۷۵؛ ۷ کلمه کنار گذاشته (#۳۴۶–۳۵۲)؛ GitHub Actions سبز.
> قبلی: 2026-09-27 (دور ۴۱۵–۴۲۰) — **۶۰ کلمه‌ی تازه**: niederländisch … oberösterreichisch ⇒ آرشیو ۳۷۹۵؛ nullte ⇒ numerale؛ ۴ کلمه کنار گذاشته (#۳۴۲–۳۴۵)؛ GitHub Actions سبز.
> قبلی: 2026-09-27 (دور ۴۰۳–۴۱۴) — **۱۲۰ کلمه‌ی تازه**: mundtot … niedergeschlagen ⇒ آرشیو ۳۷۳۵؛ ۳ Wortart ⇒ numerale؛ ۱۱ کلمه کنار گذاشته (#۳۳۱–۳۴۱).
> قبلی: 2026-09-27 (دور ۳۹۴–۴۰۲) — **۹۰ کلمه‌ی تازه**: mittelhochdeutsch … mundgerecht ⇒ آرشیو ۳۶۱۵؛ ۸ کلمه کنار گذاشته (#۳۲۳–۳۳۰)؛ GitHub Actions همه سبز.
> قبلی: 2026-09-27 (دور ۳۸۴–۳۹۳) — **۱۰۰ کلمه‌ی تازه**: medium … mittelgriechisch ⇒ آرشیو ۳۵۲۵؛ ۴ Wortart ⇒ numerale؛ ۱۰ کلمه کنار گذاشته (#۳۱۳–۳۲۲)؛ GitHub Actions همه سبز.
> قبلی: 2026-09-27 (دور ۳۷۵–۳۸۳) — **۹۰ کلمه‌ی تازه**: mäzenatisch … mediterran ⇒ آرشیو ۳۴۲۵؛ ۹ کلمه کنار گذاشته (#۳۰۴–۳۱۲)؛ GitHub Actions همه سبز.
> قبلی: 2026-09-27 (دور ۳۶۵–۳۷۴) — **۱۰۰ کلمه‌ی تازه**: libanesisch … mäßig ⇒ آرشیو ۳۳۳۵؛ ۱۳ کلمه کنار گذاشته (#۲۹۱–۳۰۳)؛ GitHub Actions همه سبز.
> قبلی: 2026-09-27 (دور ۳۵۵–۳۶۴) — **۹۹ کلمه‌ی تازه**: labiodental … lexikographisch ⇒ آرشیو ۳۲۳۵؛ ۱۲ کلمه کنار گذاشته (#۲۷۹–۲۹۰)؛ GitHub Actions همه سبز.
> قبلی: 2026-09-27 (دور ۳۴۵–۳۵۴) — **۱۰۰ کلمه‌ی تازه**: korrosionsbeständig … labil ⇒ آرشیو ۳۱۳۶؛ ۹ کلمه کنار گذاشته (#۲۷۰–۲۷۸).
> قبلی: 2026-09-27 (دور ۳۳۵–۳۴۴) — **۱۰۰ کلمه‌ی تازه**: kombinatorisch … korrigierbar ⇒ آرشیو ۳۰۳۶؛ ۱۰ کلمه کنار گذاشته (#۲۶۰–۲۶۹).
> قبلی: 2026-09-27 (دور ۳۲۵–۳۳۴) — **۱۰۰ کلمه‌ی تازه**: katholisch … komatös ⇒ آرشیو ۲۹۳۶؛ ۹ کلمه کنار گذاشته (#۲۵۱–۲۵۹)؛ GitHub Actions همه سبز.
> قبلی: 2026-09-27 (دور ۳۱۵–۳۲۴) — **۱۰۰ کلمه‌ی تازه**: jadegrün … kategorisch ⇒ آرشیو ۲۸۳۶؛ ۱۱ کلمه کنار گذاشته (#۲۴۰–۲۵۰).
> قبلی: 2026-09-27 (دور ۳۰۵–۳۱۴) — **۱۰۰ کلمه‌ی تازه**: interimistisch … ivorisch ⇒ آرشیو ۲۷۳۶؛ ۱۱ کلمه کنار گذاشته (#۲۲۹–۲۳۹).
> قبلی: 2026-09-27 (دور ۲۹۵–۳۰۴) — **۱۰۰ کلمه‌ی تازه**: illusionär … interglazial ⇒ آرشیو ۲۶۳۶؛ ۸ کلمه کنار گذاشته (#۲۲۱–۲۲۸).
> قبلی: 2026-09-27 (دور ۲۸۵–۲۹۴) — **۱۰۰ کلمه‌ی تازه**: hochnäsig … illokutiv ⇒ آرشیو ۲۵۳۶؛ ۶ عدد ⇒ `numerale`؛ ۵ کلمه کنار گذاشته (#۲۱۶–۲۲۰).
> قبلی: 2026-09-27 (دور ۲۶۵–۲۸۴) — **۲۰۰ کلمه‌ی تازه**: großmütig … hochmögend ⇒ آرشیو ۲۴۳۶؛ ۱۳ کلمه کنار گذاشته (#۲۰۳–۲۱۵)؛ GitHub Actions همه سبز.
> قبلی: 2026-09-26 (دور ۲۲۴–۲۶۴) — **۴۱۰ کلمه‌ی تازه** (Lukas: «دویست کلمه به اپ اضافه کن» + «ادامه»): formlos … großkotzig ⇒ آرشیو **۲۲۳۶ کارت** (هر دور: dry-run ۰/۰، analyze و همه‌ی ۳۴۲ تست سبز؛ هر دور commit خودش). Wortart درست: forte، fürbass، gratis ⇒ `adverb`؛ fünfte، fünfzehnte، fünfzigste، fünfhundertste ⇒ `numerale` (ordinal)؛ fünftel ⇒ `numerale` (bruchzahl)؛ gell ⇒ `partikel`. **۱۶ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #۱۸۷–۲۰۲): gasig، gebalkt، gebuckelt، gefizt، gegengleich، gegiebelt، gehäusetragend، geheist، gehenkelt، gehl، geköpert، gekröpft، geperlt، gewalmt، glanzhell، griveliert. ورودی‌های تکراری فهرست (grafisch ×۲، graphitfarben ×۲) ⇒ یک کارت. ⏭️ Claude: کلمه‌ها **از großmütig**.
> قبلی: 2026-09-26 (دور ۲۰۴–۲۱۳) — **۱۰۰ کلمه‌ی تازه** (Lukas: «Weiter»): eventuell … feingliedrig ⇒ آرشیو **۱۷۲۶ کارت** (هر دور: dry-run ۰/۰، analyze و همه‌ی تست‌ها سبز؛ هر دور commit خودش؛ دور ۲۰۴ وسط تست قطع شد و از مرحله‌ی ۶ ادامه یافت). **۱۷ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #158–174): exergon، exogenetisch، exozentrischg (غلط تایپی فهرست)، expert، extinkt، extradiegetisch، extramundan، extra-temporal، extratemporal، fabisch، fadenbreit، fadenlos، faselnackend، fasennackend، fassettenartig، fassettenreich، fastidiös. ⏭️ Claude: کلمه‌ها **از feinkörnig**.
> قبلی: 2026-09-26 (دور ۱۹۴–۲۰۳) — **۱۰۰ کلمه‌ی تازه** (Lukas: «Weiter»): entwaffnend … evasiv ⇒ آرشیو **۱۶۲۶ کارت** (هر دور: dry-run ۰/۰، analyze و همه‌ی تست‌ها سبز؛ هر دور commit خودش). **Wortart درست:** erste ⇒ `numerale`. **۱۹ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #139–157): ephebisch، epifaszial، epithetisch، eponymisch، erdhaltig، erethisch، erfolgswirksam، erlen، erotomanisch، erzen، eschen، espen، etisch، euploid، europazentriert، euryhalin، euryhygr، euryök، eurytherm (صفت‌های جنس مثل birken + اصطلاح‌های خیلی تخصصی). ⏭️ Claude: کلمه‌ها **از eventuell**.
> قبلی: 2026-09-26 (دور ۱۸۴–۱۹۳) — **۱۰۰ کلمه‌ی تازه** (Lukas: «Weiter»): einundzwanzigste … enttäuscht ⇒ آرشیو **۱۵۲۶ کارت** (هر دور: dry-run ۰/۰، analyze و همه‌ی تست‌ها سبز؛ هر دور commit خودش). **Wortart درست:** einundzwanzigste، elfte ⇒ `numerale`. **۱۳ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #126–138): elektrogen، elenktisch، emeritus، emisch، empathogen، enaktiv، endogenetisch، endothym، endozentrisch، enkaptisch، enneaeterisch، enostal، entaktogen (بیشترشان اصطلاح‌های خیلی تخصصی با ثبت نامطمئن). ⏭️ Claude: کلمه‌ها **از entwaffnend**.
> قبلی: 2026-09-26 (دور ۱۷۴–۱۸۳) — **۱۰۰ کلمه‌ی تازه** (Lukas: «Weiter»): dunstig … einunddreißigste ⇒ آرشیو **۱۴۲۶ کارت** (هر دور: dry-run ۰/۰، analyze و همه‌ی تست‌ها سبز؛ هر دور commit خودش). **Wortart درست:** einhunderterste، einhundertste، einunddreißigste ⇒ `numerale` (einundzwanzigste هم در `wortartKorrektur` آماده است). **۸ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #118–125): dutzend، dyadisch، ebengleich، egressiv، ehrenkäsig، eiben، eichen، einschaltbereit. ⏭️ Claude: کلمه‌ها **از einundzwanzigste**.
> قبلی: 2026-09-26 (دور ۱۶۴–۱۷۳) — **۱۰۰ کلمه‌ی تازه** (Lukas: «Weiter»): diskriminierend … dunkelrot ⇒ آرشیو **۱۳۲۶ کارت** (هر دور: dry-run ۰/۰، analyze و همه‌ی تست‌ها سبز؛ هر دور commit خودش). **Wortart درست:** dreihundertste، dreißigste، dreiundzwanzigste، dreizehnte، dritte ⇒ `numerale` (عدد ترتیبی) + `wortartKorrektur`. **۹ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #109–117): dissidentisch، dissipativ، distich، dolent، doloros، dominicanisch، doppelherzig، drahten، drittelzahlig (معنا/املا/ثبت نامطمئن). ⏭️ Claude: کلمه‌ها **از dunstig**.
> قبلی: 2026-09-26 (دور ۱۴۴–۱۶۳) — **۲۰۰ کلمه‌ی تازه** (درخواست Lukas: «دویست کلمه بعدی» ⇒ «Weiter» ⇒ «Weiter»): buchhalterisch … diskretionär ⇒ آرشیو **۱۲۲۶ کارت** (هر دور: dry-run ۰ خطا/۰ هشدار، analyze سبز، ۳۴۲ تست سبز؛ هر دور commit خودش). **Wortart درست:** demgemäß ⇒ `adverb` (Duden) + `wortartKorrektur`. **۲۹ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #80–108 + `zurueckgestellt`): صفت‌های جنسی مثل buchen/damasten/diamanten/demanten (مثل birken)، اصطلاح‌های خیلی تخصصی (chemometrisch، chionophil، dextral، diptotisch …)، شکل‌های لاتین/اسمی (designatus، desiderat، chochem) و املای مشکوک (desmal، depretiativ). «demographisch» و «dichotomisch»/«diachronisch» طبق ⭐ اصل اول کارت خودشان را گرفتند (با `anmerkung`). ⚠️ فرایندهای پس‌زمینه در محیط Claude بین پاسخ‌ها قطع می‌شوند ⇒ اگر دوری نیمه‌کاره ماند، از مرحله‌ی ۶ (`vokab_index` ⇒ `--abhaken` ⇒ analyze ⇒ test) ادامه بده. ⏭️ Claude: کلمه‌ها **از diskriminierend**.
> قبلی: 2026-09-26 (دور ۱۳۹–۱۴۳) — **۵۰ کلمه‌ی تازه** (درخواست Lukas: «پنجاه کلمه بعدی»): böse … brutal ⇒ آرشیو **۱۰۲۶ کارت** (هر دور: dry-run ۰ خطا/۰ هشدار، analyze سبز، ۳۴۲ تست سبز؛ هر دور commit خودش). **۶ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #74–79 + `zurueckgestellt`): bonfortionös (املا مشکوک)، botrytisiert، boustrophedon، brennheiß، brillanten، brokaten. «bös» (هم‌معنی böse، id جدا) و «breitschulterig» (هم‌معنی breitschultrig) طبق ⭐ اصل اول کارت خودشان را گرفتند (با `anmerkung`)؛ «braungebrannt» در فهرست دو بار آمده ⇒ یک کارت، هر دو ✓. ⏭️ Claude: کلمه‌ها **از buchen**.
> قبلی: 2026-09-26 (دور ۱۳۰–۱۳۸) — **۹۰ کلمه‌ی تازه** («Weiter»): bewundernswert … bösartig ⇒ آرشیو **۹۷۶ کارت** (هر دور ۰ خطا/۰ هشدار، ۳۳۸ تست سبز؛ هر دور commit خودش). **Wortart درست:** billiardste و billionste ⇒ `numerale` (عدد ترتیبی) + `wortartKorrektur`. **۱۰ کلمه کنار گذاشته** (bezastert، bezopft، bibliophob، biereifrig، bimaxillär، birken، bitchig، blakig، bland، blaustrümpfig ⇒ «🏁 مرحله‌ی آخر»). «blaß» (املای قدیمی) همان id کارت blass را دارد ⇒ ساخته‌شده حساب می‌شود. ⚠️ یک چت دیگر هم‌زمان روی vox کار کرد (`theme_mode`)؛ `runde.sh` حالا قبل از push هر دور `pull --rebase` می‌کند. ⏭️ Claude: کلمه‌ها **از böse**.
> قبلی: 2026-09-26 (باگ مشترک با Root-in) — **خواندن `theme_mode` مقاوم شد** (`features/more/controllers/settings_controller.dart` → `_gespeichertesFarbschema()`؛ تست `test/farbschema_speicher_test.dart`). **چرا:** vox و Root-in هر دو روی `lukasylilli.github.io` هستند ⇒ مرورگر برایشان **یک** `localStorage` دارد. هر دو کلید `theme_mode` داشتند: vox عدد (`2` = تیره)، Root-in متن (`"dark"`). کاربری که vox را تیره کرده بود، Root-in برایش باز نمی‌شد (گزارش کاربر، Root-in PLAN 31.8) و برعکس `getInt` در vox روی متن Root-in خطا می‌داد. Root-in حالا پیشوند خودش `root_in.` را دارد و کلیدهای قدیمی‌اش را جابه‌جا می‌کند؛ vox فقط عدد معتبر ۰–۲ را قبول می‌کند، بقیه ⇒ System. ⚠️ قاعده: کلید تازه در vox نباید با کلیدهای قدیمی Root-in هم‌نام باشد؛ اسم دیتابیس‌ها جداست (`vox` / `root_in_db`). ⚠️ ورود به حساب Supabase هم به همین دلیل بین دو اپ مشترک است (یک کلید در همان `localStorage`) — تصمیمش با فاز ۳۰ Root-in.
> قبلی: 2026-09-26 (دور ۱۰۰–۱۲۹) — **۳۰۰ کلمه‌ی تازه** (درخواست Lukas: «صد کلمه» ⇒ «۲۰۰ کلمه» ⇒ «Weiter»): auffallend … bewohnbar ⇒ آرشیو **۸۸۶ کارت** (هر دور: dry-run ۰ خطا/۰ هشدار، analyze سبز، ۳۳۸ تست سبز؛ هر دور commit خودش؛ GitHub Actions تا دور ۱۲۹ سبز). **۴۰ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #24–63 + `zurueckgestellt`)، از جمله سه **خطای فهرست**: besoffenbesondere (دو کلمه سرهم)، besonderes و besonderer (شکل صرف‌شده) — تصمیم با Lukas. **Wortart درست:** baldmöglichst ⇒ `adverb` (Duden) + `wortartKorrektur`. **نگهبان تازه در ابزار ساخت کارت (خارج از ریپو):** id_ref با «/» (مثل «der/die Bekannte») رد می‌شود — کارت bedienstet و beidhändig اصلاح شد. ⚠️ عنوان commit دور ۱۰۱ (9cdc9a0) به‌خاطر تبدیل غلط رقم‌ها ناخوانا است؛ محتوا سالم است (بازنویسی تاریخچه‌ی main انجام نشد). ⏭️ Claude: کلمه‌ها **از bewundernswert**؛ T.3 منتظر نمونه‌های ÖSD A1 از Lukas.
> قبلی: 2026-09-25 (دور ۹۵–۹۹) — **۵۰ کلمه‌ی تازه** (درخواست Lukas: «پنجاه کلمه بعدی»): arrogant … auditiv ⇒ آرشیو **۵۹۶ کارت** (هر دور: dry-run ۰ خطا/۰ هشدار، analyze سبز، ۳۳۸ تست سبز؛ هر دور commit خودش). **۴ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #20–23 + `zurueckgestellt`): arschig، arschlos، assi، athermisch. ⏭️ Claude: T.3 با نمونه‌های ÖSD A1 از Lukas؛ تا آن موقع G7d و کلمه‌ها **از auffallend**.
> قبلی: 2026-09-25 (دور ۹۴) — **درخواست Lukas: مثال سوم برای arisch** (نژاد آریایی از نظر علمی وجود ندارد، ولی هنوز کسانی به آن باور دارند) در `assets/vocab/adjektiv/adjektiv_arisch.json`. ⇒ قاعده‌ی تازه: پرامپت همچنان **دقیقاً ۲** مثال می‌سازد، ولی مثالی که Lukas اضافه می‌کند مجاز است (فقط افزودن، هرگز کم کردن) — `vokab_schema.dart` فقط برای **کمتر از ۲** هشدار می‌دهد؛ نگهبان: تست تازه در `test/vokab_schema_test.dart` (۳۳۸ تست سبز). ⏭️ Claude: T.3 با نمونه‌های ÖSD A1 از Lukas؛ تا آن موقع G7d و کلمه‌ها **از arrogant**.
> قبلی: 2026-09-25 (دور ۸۹–۹۳) — **۵۰ کلمه‌ی تازه** (درخواست Lukas: «پنجاه کلمه بعدی»): apophatisch … arriviert ⇒ آرشیو **۵۳۶ کارت** (هر دور: dry-run ۰ خطا/۰ هشدار، analyze سبز، ۳۳۷ تست سبز؛ هر دور commit خودش). **۲ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #18–19 + `zurueckgestellt`): appendikuliert، aretologisch. ⏭️ Claude: T.3 با نمونه‌های ÖSD A1 از Lukas؛ تا آن موقع G7d و کلمه‌ها **از arrogant**.
> قبلی: 2026-09-25 (دور ۸۸) — تصمیم Lukas: **تمرین تک‌بخشی مجاز** (فقط آزمون باید کامل باشد) — در بلوک «✅ قواعد آزمون…» و توضیح `pruefungs_ergebnis.dart`. ⏭️ Claude: T.3 با نمونه‌های ÖSD A1 (Hören با Transkript)؛ تا آن موقع G7d و کلمه‌ها.
> قبلی: 2026-09-25 (دور ۸۷) — **قواعد آزمون مثل آزمون واقعی ثبت شد** (زمان ⇒ پایان خودکار، نمره‌ی جدای Lesen/Hören/Schreiben/Sprechen، فقط آزمون کامل) — در PLAN (بلوک «✅ قواعد آزمون…») و در قالب نتیجه (`pruefungs_ergebnis.dart`: `zeitLimitSekunden`، `zeitAbgelaufen`، `teileGeordnet`، `vollstaendig`؛ +۳ تست). ⏭️ Claude: T.3 با نمونه‌های ÖSD A1 از Lukas (Hören با Transkript)؛ تا آن موقع G7d و کلمه‌ها.
> قبلی: 2026-09-25 (دور ۸۶) — **T.1 انجام شد** (ذخیره‌ی عمومی نتیجه‌ی آزمون‌ها، قرارداد Fassung 5، آزمون سطح گرامر اولین مصرف‌کننده؛ ۳۳۴ تست سبز). ⏭️ Claude: **T.3 قالب واحد سؤال** — منتظر اولین نمونه‌سؤال‌های **ÖSD A1** از Lukas (یادآوری: Hören با Transkript). تا رسیدن نمونه: G7d و کلمه‌ها (از apophatisch).
> قبلی: 2026-09-25 (دور ۸۵) — **تصمیم‌های فاز T کامل شد** (بلوک «✅ تصمیم‌های تکمیلی» در «🧪 فاز T»): متن سؤال از نو + ساختار اصلی؛ ترتیب ÖSD ⇒ … ⇒ VOX، هر مؤسسه A1 تا آخر؛ نتیجه‌ی شبیه‌سازها ذخیره + تاریخچه + مدال؛ Lernpfad فعلاً دستی. کدی ساخته نشد. ⏭️ Claude: **T.1** (بدون نیاز به نمونه) ⇒ بعد ÖSD A1 با نمونه‌های Lukas (یادآوری Transkript برای Hören).
> قبلی: 2026-09-25 (دور ۸۴) — **تصمیم‌های Lukas برای فاز T ثبت شد** (بلوک «✅ تصمیم‌های Lukas» در «🧪 فاز T»): شبیه‌ساز هر چه بیشتر، اول ÖSD، آخر آزمون خود VOX (تنها منبع Lernpfad)؛ جواب درست هرگز نشان داده نمی‌شود؛ نیمه‌کاره ⇒ از اول؛ بدون AI؛ Hören با صدای دستگاه؛ Schreiben با جای خالی/املا. **هیچ کدی ساخته نشد.** ⏭️ Lukas: جواب سؤال‌های باز (ترتیب بعد از ÖSD، سطح شروع ÖSD، متن Hören، حق نشر) + نمونه‌سؤال ÖSD. ⏭️ Claude: T.1.
> قبلی: 2026-09-25 (دور ۸۳) — **فاز T پیش‌نویس شد** (بخش «🧪 فاز T» بالای «📚 روال»؛ درخواست Lukas): آزمون‌های گسترده‌تر + شبیه‌ساز مؤسسه‌ها + نتیجه در Selbstlernen ⇒ Lernpfad. G7e ⇒ T.1. **هیچ کدی ساخته نشد.** ⏭️ Lukas: تصمیم درباره‌ی مراحل و T.0. ⏭️ Claude: بعد از تصمیم ⇒ T.1؛ تا آن موقع G7d و کلمه‌ها (از apophatisch).
> قبلی: 2026-09-25 (دور ۷۸–۸۲) — **۵۰ کلمه‌ی تازه‌ی دیگر** (درخواست Lukas: «پنجاه کلمه بعدی»): antiamerikanisch … apologetisch ⇒ آرشیو **۴۸۶ کارت** (هر دور: dry-run ۰ خطا/۰ هشدار، analyze سبز، ۳۱۹ تست سبز؛ هر دور commit خودش). **هیچ کلمه‌ی تازه‌ای کنار گذاشته نشد** (antichretisch از قبل در «🏁 مرحله‌ی آخر» #17 بود و رد شد). ⏭️ Claude: G7e ⇒ G7d؛ کلمه‌ها موازی **از apophatisch**. L.2d و L.6 منتظر منبع Lukas.
> قبلی: 2026-09-25 (دور ۷۳–۷۷) — **۵۰ کلمه‌ی تازه‌ی دیگر** (درخواست Lukas: «پنجاه تای بعدی»): angelsächsisch … anthropozentrisch ⇒ آرشیو **۴۳۶ کارت** (هر دور: dry-run ۰ خطا/۰ هشدار، analyze سبز، ۳۱۹ تست سبز؛ هر دور commit خودش). **۲ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #16–17 + `zurueckgestellt`): anotherm، antichretisch. ⏭️ Claude: G7e ⇒ G7d؛ کلمه‌ها موازی **از antiamerikanisch**. L.2d و L.6 منتظر منبع Lukas.
> قبلی: 2026-09-25 (دور ۶۸–۷۲) — **۵۰ کلمه‌ی تازه** (درخواست Lukas: «پنجاه کلمه جدید»): altäthiopisch … angelegentlich ⇒ آرشیو **۳۸۶ کارت** (هر دور: dry-run ۰ خطا/۰ هشدار، analyze سبز، ۳۱۹ تست سبز؛ هر دور commit خودش). **۶ کلمه کنار گذاشته** (⇒ «🏁 مرحله‌ی آخر» #10–15 + `zurueckgestellt`): amaranten، ambient، amethysten، amphibolisch، anamorph، anelliert. **Wortart درست:** andante و anderweit ⇒ `adverb` (Duden) + `wortartKorrektur`. ⏭️ Claude: G7e ⇒ G7d؛ کلمه‌ها موازی **از angelsächsisch**. L.2d و L.6 منتظر منبع Lukas.
> قبلی: 2026-09-25 (دور ۶۷) — **🎉 انتشار: Lukas لینک وب‌اپ را عمومی منتشر کرد.** کدی عوض نشد. ⏭️ Claude (ترتیب «بعد از انتشار»): **G7e** (ذخیره‌ی نتیجه‌ی آزمون سطح در داده‌ی کاربر + پشتیبان + همگام‌سازی) ⇒ **G7d** (تمرین Redemittel و deckهای دیگر)؛ کلمه‌ها با «ده کلمه جدید» موازی ادامه دارند (از altäthiopisch). L.2d و L.6 منتظر منبع Lukas.
> قبلی: 2026-09-24 (دور ۶۶) — **🚀 همه‌ی شرط‌های «قبل از انتشار» ✅** (Lukas بندهای ۲–۴ را هم روی آیفون/تلگرام تأیید کرد). فقط L.6 (اختیاری) باز است. ⏭️ Lukas: انتشار (اعلام در کانال). ⏭️ Claude بعد از انتشار: G7e ⇒ G7d (ترتیب «بعد از انتشار»؛ L.2d منتظر منبع Lukas). **L.3 ✅ تأیید Lukas روی مک:** اپ آفلاین کامل کار می‌کند جز اخبار (طبق طراحی). ⚠️ نکته‌ی DevTools: صفحه‌ی کلی Cache storage همیشه خالی به نظر می‌رسد؛ باید فلش ▶ کنارش را باز کرد.
> قبلی: 2026-09-24 (دور ۶۵) — **فاز Z ثبت شد (تصمیم Lukas؛ فقط برنامه، هیچ کدی ساخته نشد):** آخرین مرحله‌ی کل پروژه، بعد از کامل شدن همه‌ی بخش‌ها و سبز بودن همه‌ی تست‌ها — Z.1 ربات تلگرام واقعی ⇒ Z.2 تبلیغات گوگل ⇒ Z.3 اندروید/آیفون. بخش «🌍 فاز Z» ته فایل + فهرست مطالب + «⏭️ بعد از انتشار». **ادامه‌ی کلمه‌ها از: altäthiopisch.**
> قبلی: 2026-09-24 (دور ۶۴) — **L.3c باز شدن در تلگرام (Mini App) رفع شد:** تلگرام `#tgWebAppData=…` به آدرس می‌چسباند و go_router آن را صفحه می‌خواند (GoException). ⇒ `web/telegram_guard.js` قبل از `flutter_bootstrap.js`: **فقط** وقتی آدرس tgWebAppData دارد، SDK تلگرام را می‌آورد و بعد آدرس را پاک می‌کند؛ مرورگر/PWA معمولی دست نخورده. نگهبان: مرحله‌ی ۵ در `tool/pwa/offline_test.cjs` (Chrome واقعی در deploy). ⏭️ Lukas: یک بار VOX را از داخل تلگرام باز کند. **ادامه‌ی کلمه‌ها از: altäthiopisch.**
> قبلی: 2026-09-24 (دور ۶۳) — **⭐ اصل اول کلمه‌ها (Lukas، جایگزین L.4b / L.4b-2 / L.4c قدیم):** هر کلمه‌ی فهرست **همیشه** کارت و **صفحه‌ی جدید خودش** را می‌گیرد — حتی اگر از قبل در اپ باشد (تنها، با حرف اضافه، با sich، داخل عبارت)؛ **هیچ** صفحه/کلمه/جزئیاتی حذف نمی‌شود؛ دوبرابر شدن اشکال ندارد؛ **در آخرین مرحله** Claude همه‌ی تکراری‌ها را پیدا می‌کند و **Lukas تصمیم می‌گیرد** (L.4d). ⇒ **کد:** `wort_seite_screen.dart` دیگر به صفحه‌ی قبلی هدایت نمی‌کند · `wortschatz_list_screen.dart` هیچ کارتی را پنهان نمی‌کند · شمارنده‌ی `wortschatz_home_screen.dart` همه را می‌شمارد · صفحه‌ی قبلی کارت را فقط **اضافه** نشان می‌دهد (چیزی حذف نشد) · نگهبان تازه در `test/altwort_karte_test.dart`. **سرعت:** `tool/wort_runde.sh` (مراحل ۵–۷ در یک دستور، همان دستورها) + `naechste_woerter.dart --abhaken` (✓ با همان vokabId و wortartKorrektur). PLAN/MAP کل بازبینی و خلاصه شدند. **ادامه‌ی کلمه‌ها از: altäthiopisch.**
> قبلی: 2026-09-24 (دور ۲۸–۶۲) — کلمه‌ها: aalglatt … alttestamentlich ⇒ آرشیو **۳۳۶ کارت** (هر دور ۰ خطا/۰ هشدار)؛ ۹ کلمه کنار گذاشته (⇒ «🏁 مرحله‌ی آخر»)؛ عددها ⇒ numerale با `wortartKorrektur` (دور ۳۴)؛ «🏁 مرحله‌ی آخر» (دور ۴۴) و قاعده‌اش (دور ۴۸)؛ L.4b / L.4b-2 (دور ۵۴/۵۶، حالا با اصل اول منسوخ)؛ L.4d ثبت (دور ۵۷).
> قبلی: 2026-09-24 (دور ۳۳) — **L.3 آفلاین رفع شد:** worker خودمان `vox_sw.js` (Workbox، `tool/pwa/`) + build با `--pwa-strategy=none --no-web-resources-cdn` + تست آفلاین Chrome در `deploy-web.yml`. ⏭️ Lukas: تست دوباره روی کامپیوتر.
> قبلی: 2026-09-24 (دور ۳۱) — اسم‌ها: نام شهرها فقط تلفظ + معنی + آرتیکل؛ قبل از فهرست اسم‌ها دوباره از Lukas بپرس.  2026-09-23 (دور ۲۹–۳۰) — روال «ده کلمه جدید» + `tool/naechste_woerter.dart` + ترتیب فهرست‌ها.
> قبلی: 2026-09-23 (دور ۲۶–۲۷) — **RTL در Auswendiglernen کامل** (نگهبان ~۴۰ فیلد، جدول‌ها LTR، `Wrap(textDirection: ltr)`، `DeutschMitEtikett`). ⏭️ Lukas: نگاه روی آیفون.
>
> 📜 **کارنامه (خیلی خلاصه):**
> - **2026-09-26** — ۱۰۰ کلمه‌ی دیگر (دور ۲۱۴–۲۲۳، feinkörnig … formidabel، آرشیو ۱۸۲۶) · ۱۰۰ کلمه‌ی دیگر (دور ۲۰۴–۲۱۳، eventuell … feingliedrig، آرشیو ۱۷۲۶) · ۱۰۰ کلمه‌ی دیگر (دور ۱۹۴–۲۰۳، entwaffnend … evasiv، آرشیو ۱۶۲۶) · erste ⇒ numerale · ۱۰۰ کلمه‌ی دیگر (دور ۱۸۴–۱۹۳، einundzwanzigste … enttäuscht، آرشیو ۱۵۲۶) · ۲ عدد ترتیبی ⇒ numerale · ۱۰۰ کلمه‌ی دیگر (دور ۱۷۴–۱۸۳، dunstig … einunddreißigste، آرشیو ۱۴۲۶) · ۳ عدد ترتیبی ⇒ numerale · ۱۰۰ کلمه‌ی دیگر (دور ۱۶۴–۱۷۳، diskriminierend … dunkelrot، آرشیو ۱۳۲۶) · ۵ عدد ترتیبی ⇒ numerale · ۲۰۰ کلمه‌ی دیگر (دور ۱۴۴–۱۶۳، buchhalterisch … diskretionär، آرشیو ۱۲۲۶) · demgemäß ⇒ adverb · ۵۰ کلمه‌ی دیگر (دور ۱۳۹–۱۴۳، böse … brutal، آرشیو ۱۰۲۶) · ۹۰ کلمه‌ی دیگر (دور ۱۳۰–۱۳۸، bewundernswert … bösartig، آرشیو ۹۷۶) · billiardste/billionste ⇒ numerale · `theme_mode` مقاوم در برابر مقدار Root-in (localStorage مشترک روی یک دامنه) · ۳۰۰ کلمه‌ی تازه (دور ۱۰۰–۱۲۹، auffallend … bewohnbar، آرشیو ۸۸۶) · baldmöglichst ⇒ adverb · ۴۰ کلمه کنار گذاشته.
> - **2026-09-25** — 🎉 انتشار (دور ۶۷) · ۱۵۰ کلمه‌ی تازه (دور ۶۸–۸۲، altäthiopisch … apologetisch، آرشیو ۴۸۶) · andante/anderweit ⇒ adverb.
> - **2026-09-24** — فاز Z ثبت (ربات تلگرام ⇒ تبلیغات گوگل ⇒ اندروید/آیفون؛ آخرین مرحله) · L.3c تلگرام (`web/telegram_guard.js`) · ⭐ اصل اول کلمه‌ها (هر کلمه صفحه‌ی جدید؛ تکراری‌ها فقط در آخر، تصمیم Lukas) + `tool/wort_runde.sh` + خلاصه‌سازی سوم · ۲۳۹ کلمه‌ی تازه (دور ۳۲–۶۲، abbruchreif … alttestamentlich، آرشیو ۳۳۶) · L.4d ثبت · L.4b/L.4b-2 (منسوخ) · L.3 آفلاین: `vox_sw.js` · تصمیم اسم‌ها.
> - **2026-09-23** — L.3b نگهبان زبان مرورگر (`web/locale_guard.js`، vox + Root-in) · L.2d تصمیم (deckهای خالی «به‌زودی» می‌مانند) · B-13 لایتنر هر دو منبع · تست آیفون ✅ · پاپ‌آپ کلمه: German News، تلفظ برای هر کلمه، پیام جدای «بارگذاری نشد»، **شکل‌های صرف‌شده** (`assets/vocab_formen/`) · RTL: `deutschLinksbuendig` + `DeutschRichText` + جدول‌های گرامر LTR + نگهبان چندخطی · R-2.3 ثبت شد · رمز فراموشی با جریان implicit.
> - **2026-09-22** — L.1d حذف حساب (هر دو اپ) · R-2.1 Präpositionen · قفل قالب ایمیل Supabase.
> - **2026-09-20** — فاز P (پروفایل و حساب) · L.5f پاپ‌آپ کلمه.  **2026-09-19** — `FeatureFlags` · L.5g ثبت.
> - **2026-09-18** — RTL متن آلمانی · L.1c · L.1e · L.2a · L.6 درس ۱–۲ · اصل «یک محتوا، چند ورودی».  **2026-09-16** — S.6 · V.2 · L.1a · L.1b · L.2c · L.3a · G7a–G7c.
>
> 🔒 **قاعده‌ی «قبل از انتشار» (Lukas، 2026-09-18):** هر چیزی که داده‌ی کاربر به آن اشاره می‌کند باید قبل از انتشار نگهبان داشته باشد — کارت آرشیو ✅ L.1a · مهاجرت DB ✅ L.1b · لیست‌های شخصی ✅ S.6 · قرارداد پشتیبان ✅ S.5 · کلمه‌های همراه اپ ✅ L.1e.

> ⚠️ **2026-09-13:** VOX فقط Flutter-Web روی GitHub Pages است (بومی، RevenueCat و Notifications حذف شدند). Habit/Routine ⇒ Root-in، ریپوی جدا؛ تنها اتصال: لینک Routine در `core/constants/app_links.dart`.
> ⚠️ **2026-09-15 (Audit):** علامت‌های `✓` در `old files Lukasalmani/Wörter/*.txt` مرجع نیستند — مرجع `assets/vocab/` است · سقف startup (خواندن همه‌ی کارت‌ها) با V.2 ✅ رفع شد · کلمه‌ها **الفبایی** ساخته می‌شوند (تصمیم Lukas).

## 🚀 قبل از انتشار — فهرست کامل (بازبینی کامل PLAN و MAP، 2026-09-23 دور ۲۵)

> همه‌ی `[ ]`/`[~]`های این فایل یک‌به‌یک بررسی شدند. هر چه در این فهرست نیست یا انجام شده یا عمداً برای **بعد از انتشار** است (بخش بعدی).
> L.1 (امنیت داده) ✅ کامل · L.2 (محتوا) ✅ برای انتشار · تست آیفون ✅ · بازبینی چشمی پروفایل/پاپ‌آپ ✅.

1. [x] **L.3 تست آفلاین روی کامپیوتر — ✅ رفع شد (دور ۳۳) و Lukas روی مک تأیید کرد (2026-09-24، بعد از دور ۶۵):** `vox_sw.js` سبز، Offline + `Cmd+R` ⇒ همه‌ی بخش‌ها کار می‌کنند جز «اخبار» (طبق طراحی: فقط فیدی که قبلاً آنلاین بارگیری شده از `cache_service` می‌آید؛ خود مقاله‌ها سایت بیرونی‌اند). یادداشت قدیم: (Service Workers باید `vox_sw.js` سبز نشان دهد، Cache Storage باید `vox-precache-…` داشته باشد، بعد Offline + Reload). جزئیات: بخش L.3.
2. [x] **پاپ‌آپ کلمه برای شکل‌های صرف‌شده — Claude ✅ ساخته شد (دور ۲۴)؛ ✅ Lukas روی آیفون تأیید کرد (2026-09-24 دور ۶۶).** یادداشت قدیم: Lukas روی آیفون امتحان کند (مثلاً «aalartigen» در مثال صفحه‌ی aalartig).
3. [x] **RTL در Auswendiglernen — Claude ✅ کامل (دور ۲۶–۲۷)؛ ✅ Lukas روی آیفون تأیید کرد (2026-09-24 دور ۶۶).** (متن‌های توضیحی گرامر که فارسی و آلمانی را در یک جمله قاطی دارند عمداً دست نخوردند — جدا کردنشان یعنی تغییر داده‌ها.) سابقه: سطرهای آلمانی که نام فیلدشان برای نگهبان ناشناس است: «sich auskennen mit + dativ» (Reflexiv)، مترادف NVV («sich verabschieden»)، چیپ «von +Dat»، عنوان کانکتورها در فهرست، و جمله‌های آلمانی در صفحه‌های گرامرِ deckها (`*_grammar_screen.dart`). بعدش Lukas یک نگاه روی آیفون.
4. [x] **L.3c باز شدن در تلگرام — Claude ✅ رفع شد (دور ۶۴)؛ ✅ Lukas از داخل تلگرام تأیید کرد (2026-09-24 دور ۶۶).** یادداشت قدیم: یک بار VOX را از داخل تلگرام (Mini App) باز کند — باید مستقیم صفحه‌ی اصلی بیاید، بدون GoException. جزئیات: بخش L.3.
5. [ ] **L.6 درس بعدی کتاب گرامر — Lukas منبع بفرستد (اختیاری؛ می‌تواند بعد از انتشار بیاید).** رسیده: درس ۱ و ۲.

## ⏭️ بعد از انتشار و تصمیم‌های باز

- **🗂️ فاز F (Lukas، 2026-10-14) — ✅ جز F.7:** صفحه‌ی فیلتر، کتاب‌ها، مشاغل/بی‌احترامی/منسوخ، ترتیب جست‌وجو ⇒ بخش «🗂️ فاز F». ⏸️ **F.7 (پر کردن کارت‌های موجود) بعد از تمام شدن کل اپ و قبل از تست‌ها** (همراه دسته‌های احتمالی تازه). کارت‌های تازه از F.5 به بعد با Regel 17 ساخته می‌شوند.
- **کلمه‌ها (L.4):** روال کامل، فایل‌ها و پیشرفت ⇒ بخش **«📚 روال ده کلمه جدید»** (پایین‌تر). Lukas فقط می‌گوید «ده کلمه جدید وارد کن».
- **🔍 فاز Q (Lukas، 2026-10-11) — قبل از افعال:** بازبینی کیفیت کارهای بازه‌ی Sonnet ⇒ بخش «🔍 فاز Q».
- **بعد از انتشار (به ترتیب Lukas):** L.2d منابع deckهای «به‌زودی» (یکی‌یکی) · G7d/G7e تمرین deckها + ذخیره‌ی نتیجه‌ی آزمون سطح · L.4 کلمه‌ها (روزانه؛ هر کلمه همیشه صفحه‌ی جدید — ⭐ اصل اول) · **L.4c کارت عبارت (NVV/Redemittel) — بعد از همه‌ی کلمه‌ها** · **L.4d تکراری‌ها — آخرین مرحله (Claude پیدا می‌کند، Lukas تصمیم می‌گیرد)** · R-2.2 صفحه‌ی جزئیات کامل deckها (صدا/لایتنر/دسته) · **R-2.3 گسترش همه‌ی محتوای Auswendiglernen** (مثال، ترجمه، تمرین؛ فقط افزودن) · L.5b ترجمه‌ی جمله‌به‌جمله در Lesen · L.5c تمرین از همه‌ی محتوا · L.5d صفحه‌ی کامل اکانت · L.5e آزمون بعد از هر بخش · G8 جست‌وجو/گلاسری · V.4 UI لیست بزرگ کلمه‌ها · B.4-alt و DS باقی‌مانده (vox_chip، vox_list_tile …).
- 🌍 **آخرین مرحله‌ی کل پروژه — فاز Z (Lukas، 2026-09-24):** فقط بعد از کامل شدن همه‌ی بخش‌ها و سبز بودن همه‌ی تست‌ها: Z.1 ربات تلگرام (ربات واقعی، نه Mini App) ⇒ Z.2 تبلیغات گوگل روی سایت ⇒ Z.3 اندروید و آیفون. جزئیات: بخش «🌍 فاز Z» ته همین فایل.
- **تصمیم‌های باز Lukas (قبل از شروع حتماً بپرس):** L.5g ⛔⛔ ساختار دولایه‌ی متن‌ها · L.5a صفحه‌ی پیشرفت · V.5 توزیع آرشیو بزرگ.
- ⚠️ **مقیاس:** جدول شکل‌ها (`assets/vocab_formen/`) تکه‌تکه است؛ با ~۲۶٬۰۰۰ کارت هر تکه چند صد KB می‌شود — اگر لازم شد، تکه‌ها بر اساس دو حرف اول.

## 🗂️ فاز F — فیلتر، دسته‌بندی و ترتیب جست‌وجوی Wortschatz (Lukas، 2026-10-14 — ✅ طرح تأیید شد)

> **درخواست Lukas (2026-10-14):** صفحه‌ی جدای فیلتر (مثل آمازون) با کشوها: کتاب · Wortart · Niveau · مشاغل · بی‌احترامی · منسوخ (فیلترهای بیشتر بعداً)؛ زیبا، کاربردی و هم‌شکل اپ. نتایج جست‌وجوی شکل صرف‌شده (ging) باید **gehen را اول** نشان دهند، نه الفبایی.
> **یافته‌ی Claude (کد، 2026-10-14):** `vokabSucheProvider` (vokabular_controller.dart) ترتیب درست را می‌سازد (اول کارت‌هایی که جست‌وجو شکلِ آن‌هاست)، ولی `wortschatz_list_screen.dart` همه‌ی ردیف‌ها را دوباره **الفبایی** مرتب می‌کند ⇒ gehen گم می‌شود. کارت‌ها هنوز هیچ فیلدی برای شغل/بی‌احترامی/منسوخ ندارند (`themen` آزاد است و قابل اعتماد نیست). کتاب‌ها در DB قدیمی‌اند (`Books`/`WordBooks`، ۴ کتاب آماده از `data_seed_service.dart` + کتاب‌های خود کاربر)؛ کارت‌های آرشیو به کتاب وصل نیستند.

**✅ تصمیم‌های Lukas (2026-10-14):**
- **قاعده‌ی چیدمان دکمه‌ها در هر کشو:** همه‌ی سطرهای یک کشو **یک تعداد** دکمه و یک عرض دارند (۴ اگر همه خیلی کوتاه‌اند، وگرنه ۳، وگرنه ۲، وگرنه ۱)، روی هر دستگاه هم‌ردیف. کشوهای مختلف می‌توانند تعداد متفاوت داشته باشند.
- **کتاب‌ها** کنار بقیه‌ی فیلترها می‌آیند (منوی جدای «Bücher» برداشته می‌شود)؛ ساختن کتاب خود کاربر می‌ماند: دکمه‌ی **«+ کتاب جدید»** ته کشوی کتاب‌ها. اضافه کردن کلمه به کتاب از **همان دکمه‌ی «افزودن به دسته‌بندی»** (شیت `wort_actions.dart`): کاربر آنجا کتاب را انتخاب می‌کند یا دسته‌بندی/کتاب تازه‌ی خودش را می‌سازد — برای همه‌ی کلمه‌ها (قدیمی و آرشیو).
- **کلمه‌های کنار گذاشته‌ی ناسزا/منسوخ** (assi، befummeln، … در «🏁 مرحله‌ی آخر») **همچنان کنار می‌مانند** و در همان زمان تعیین‌شده وارد اپ می‌شوند. دسته‌ها فعلاً فقط برای کارت‌های ساخته‌شده و کارت‌های تازه.
- **برچسب روی صفحه‌ی کلمه:** بله (مثلاً «پرستاری»، هشدار «توهین‌آمیز»/«منسوخ»).
- **همه‌ی پیشنهادهای Claude پذیرفته شد** (بندهای زیر F.1b، F.1c، F.2b، F.2c، F.4c، F.5b، F.5c، F.6b).
- **فهرست مشاغل (پیشنهاد Claude، پذیرفته):** پزشکی و پرستاری · IT · برق، مکانیک و تأسیسات · ساختمان · رستوران و هتل · حمل‌ونقل و انبار · مهدکودک و آموزش · نظافت · اداری. یک کلمه می‌تواند در چند شغل باشد.
- قواعد ثابت سر جایشان: پرامپت هیچ اطلاعات ظاهری (رنگ/آیکون/شکل) نمی‌سازد — آیکون مشاغل و رنگ برچسب‌ها در کد؛ رنگ آرتیکل فقط از `GrammatikonSpec`؛ مطمئن نیستم ⇒ کلمه در دسته نمی‌رود (مثل قاعده‌ی ۳: دسته‌ی غلط بدتر از نبودن).

**مراحل (به ترتیب):**
- [x] **F.1 ترتیب نتایج جست‌وجو — ✅ 2026-10-14** (تابع `features/wortschatz/data/such_rang.dart`؛ provider تازه‌ی `vokabFormTrefferProvider` در vokabular_controller.dart؛ تست `such_rang_test.dart` + تست صفحه `such_reihenfolge_screen_test.dart` که خطای قبلی را می‌گیرد؛ ۳۹۱ تست سبز): (`wortschatz_list_screen.dart` + تابع خالص رتبه‌بندی، تست): با جست‌وجو ⇒ ۱) خود کلمه ۲) کارتی که جست‌وجو شکلِ آن است (ging ⇒ gehen) ۳) شروع با عبارت ۴) عبارت در وسط ۵) فقط از ترجمه؛ داخل هر رده کوتاه‌تر اول، بعد الفبا. بدون جست‌وجو: الفبایی مثل قبل. هر دو منبع (DB قدیمی + آرشیو).
  - [x] **F.1b ✅ 2026-10-14** (جای خالی `hinweis` در `wort_card.dart` و `word_list_item.dart`؛ کلید `such_form_etikett` fa/en: «شکل صرف‌شده: ging») زیر نتیجه‌ای که از شکل صرف‌شده آمده یک خط کوچک: «ging ← شکل gehen».
  - [x] **F.1c ✅ 2026-10-14** (تازه `features/wortschatz/data/such_vorschlag.dart`: فاصله‌ی Damerau-Levenshtein، زیر ۳ حرف هیچ، تا ۵ حرف حداکثر ۱ تغییر، بیشتر حداکثر ۲؛ ß=ss، ä=ae …؛ دکمه‌های VoxButton.tonal؛ کلید `such_meintest_du`؛ تست `such_vorschlag_test.dart` + تست صفحه؛ ۴۰۰ تست سبز) غلط تایپی کوچک (gehn، Strasse) ⇒ «منظورت این بود؟» با نزدیک‌ترین کلمه‌ها، فقط وقتی نتیجه‌ای نیست.
- [x] **F.2 ✅ 2026-10-14** (`screens/wortschatz_filter_screen.dart`، مسیر `/wortschatz/filter?suche=`؛ منطق مشترک لیست و صفحه‌ی فیلتر در `data/wortschatz_filter.dart`: WortschatzFilter، WortschatzBasis، wortschatzZeilen، wortschatzAnzahl/AnzahlMit؛ وضعیت در `controllers/wortschatz_filter_controller.dart`؛ در لیست: دکمه‌ی فیلتر کنار جست‌وجو با عدد فیلترهای فعال + چیپ‌های قابل حذف؛ کشوهای قدیمی Niveau/Wortart از لیست به صفحه‌ی فیلتر رفتند؛ تست `wortschatz_filter_test.dart`؛ ۴۱۴ تست سبز؛ اسکرین‌شات fa/en روی build محلی بررسی شد) **صفحه‌ی جدای فیلتر** (مسیر تازه از «Alle Wörter»؛ دکمه‌ی فیلتر با عدد فیلترهای فعال): کشوها + نوار پایین ثابت «پاک کردن همه» / «نمایش N کلمه» (عدد زنده). داخل یک کشو «یا»، بین کشوها «و». فیلترهای فعال بالای فهرست به‌صورت چیپ قابل حذف.
  - [x] **F.2b ✅** (`FilterOption.anzahl` در filter_accordion.dart؛ صفر و انتخاب‌نشده ⇒ کم‌رنگ و غیرفعال؛ عدد = اگر در همان کشو فقط همین انتخاب بود، با بقیه‌ی کشوها) کنار هر دکمه تعداد کلمه‌هایش؛ دکمه‌ی صفر نتیجه کم‌رنگ.
  - [x] **F.2c ✅** (کلید `vox_wortschatz_filter_v1`؛ مقدار ناشناخته نادیده؛ تغییر کاربر قبل از بارگذاری برنده است) آخرین فیلترهای کاربر ذخیره می‌شود (shared_preferences، کلید تازه با پیشوند vox — نه هم‌نام کلیدهای Root-in).
- [x] **F.3 ✅ 2026-10-14** (تابع `filterSpalten` + رسم شبکه در `filter_accordion.dart`؛ اندازه‌گیری با TextPainter و اندازه‌ی متن دستگاه؛ حداکثر ۶ در سطر؛ اول بیشترین تعدادی که جا می‌شود، بعد بزرگ‌ترین عددی که سطرها را **پر** می‌کند (۶ دکمه ⇒ ۶ یا ۳+۳، نه ۴+۲)؛ فقط اگر این زیر ۲ برسد (مثلاً ۷ دکمه) همان «تا جایی که جا می‌شود» و سطر آخر کوتاه‌تر ولی هم‌ستون؛ یک‌ستونی ⇒ متن دوخطی مجاز؛ بدون عرض مشخص ⇒ Wrap قدیمی؛ تست `filter_raster_test.dart`؛ ۴۰۸ تست سبز) **شبکه‌ی هم‌ردیف** در قطعه‌ی مشترک `core/widgets/filter_accordion.dart` (اندازه‌گیری بلندترین دکمه ⇒ ۴/۳/۲/۱ ستون، همه‌ی سطرها برابر) ⇒ همه‌ی کشوهای فیلتر اپ همین نظم را می‌گیرند. تست ویجت برای چند عرض صفحه.
- [x] **F.4 کتاب‌ها + «دسته‌بندی‌های من» — ✅ 2026-10-14** (طبق تصمیم Lukas زیر): کشوی «کتاب‌ها» = فقط کتاب‌های آماده‌ی VOX از **`assets/buecher/buecher.json`** (تنها منبع؛ هر کتاب: id ثابت، name، `alt_buch` = نام deck قدیمی در جدول Books، `karten` = idهای کارت؛ خواندن و اعتبارسنجی در `features/wortschatz/data/vox_buecher.dart`؛ تست `vox_buecher_test.dart` وجود هر id کارت را چک می‌کند)؛ فعلاً همان ۴ deck آماده (Dativ/Akkusativ، Konnektoren، NVV، Verben mit Präpositionen). منوی «Bücher» از `wortschatz_home_screen.dart` برداشته شد (صفحه‌ها/مسیرهای قدیمی کتاب دست نخوردند). کتاب‌هایی که کاربر قبلاً خودش ساخته **در فیلتر نمی‌آیند و منتقل نمی‌شوند** (تصمیم Lukas؛ ردیف‌های DB پاک نمی‌شوند). کشوی تازه‌ی **«دسته‌بندی‌های من»** (تأیید Lukas): دسته‌بندی‌های کارت‌ها (شیت WortActions، id `archiv:…`) + «Meine Kategorien» کلمه‌های قدیمی (id = `eigeneListenId`)؛ خالی ⇒ متن راهنما. دسته‌بندی پاک‌شده: در فیلتر ذخیره‌شده می‌ماند ولی اثر و چیپ ندارد (`WortschatzFilter.bereinigt`). **درخواست Lukas همان جلسه:** عدد هر دکمه **زیر** اسمش و دکمه‌ی بلندتر (`filter_accordion.dart`: ستون، padding عمودی ۱۰، گوشه‌ی ۱۴ وقتی عدد دارد) ⇒ Wortart حالا ۳×۳ و Niveau همه در یک سطر. ۴۲۰ تست سبز؛ اسکرین‌شات fa بررسی شد.
  - 🔎 یافته‌ی Claude (برای بعد، تصمیم با Lukas): دو سیستم دسته‌بندی جدا هست — «Meine Kategorien» (صفحه‌ی خودش) فقط کلمه‌های قدیمی را نشان می‌دهد؛ دسته‌بندی‌های کارت‌ها (شیت روی هر کلمه) جایی جز همین فیلتر دیده نمی‌شوند.
  - ✅ **تصمیم Lukas (2026-10-14) — جای سؤال باز قبلی:** مفهوم «کتاب من» حذف می‌شود. **کتاب‌ها فقط کتاب‌های آماده‌ی خود ما هستند** (ما می‌سازیم، کاربر نمی‌تواند پاک یا ویرایش کند). کاربر برای خودش از «+ دسته‌بندی جدید» (فهرست‌های موجود با پشتیبان/همگام‌سازی) استفاده می‌کند و هر اسمی خواست می‌گذارد. Lukas بعداً فهرست کلمه‌های هر کتاب را می‌دهد (مثلاً «A1 Starten wir») و Claude آن‌ها را وارد کتاب مربوط می‌کند.
  - 🔔 **یادآوری (اصلاح Lukas، 2026-10-14):** فهرست کلمه‌های کتاب‌ها (اول «A1 Starten wir») را Lukas **بعد از تمام شدن همه‌ی کلمه‌ها می‌دهد — حتی کلمه‌های کنار گذاشته‌شده‌ی «🏁 مرحله‌ی آخر»**. Claude فقط آن موقع یادآوری کند (یادآوری هم در «🏁 مرحله‌ی آخر» ثبت است). روال ورود: کارت هر کلمه را در آرشیو پیدا کن (نبود ⇒ اول بساز طبق پرامپت)، idها را به ترتیب فهرست در `karten` کتاب تازه در `assets/buecher/buecher.json` بنویس (id کتاب ثابت، مثلاً `a1_starten_wir`)، تست `vox_buecher_test.dart`.
  - ~~**F.4c**~~ لغو با تصمیم Lukas (کتاب خود کاربر وجود ندارد؛ کتاب‌ها همه آماده و غیرقابل حذف‌اند).
- [x] **F.5 فیلدهای تازه در پرامپت و `vokab_schema.dart` — ✅ 2026-10-14** (Regel 17 در «old files Lukasalmani/Wort prompt» + چهار فیلد در TEIL 1 بعد از `anmerkung`):
  - `berufe`: فهرست ثابت `vokabBerufe` = pflege_medizin · it · technik · bau · gastro_hotel · logistik · kinder_bildung · reinigung · buero (ترتیب = ترتیب فیلتر؛ چندتایی؛ معمولاً []؛ «کلمه‌ای که در کار روزانه‌ی آن شغل لازم است، حتی کلمه‌ی روزمره» مثل Waschlappen).
  - `anstoessig`: null | {stufe: vulgaer | abwertend | diskriminierend, erklaerung: {fa, en}}.
  - `zeitlich`: null | veraltend | veraltet (معیار: علامت Duden).
  - `ersatz`: null | {wort, wortart, uebersetzung{fa,en}, id_ref} — کلمه‌ی امروزی (برای veraltet) **یا** محترمانه (برای anstoessig).
  - **تغییر نام نسبت به طرح (Claude):** به جای `register`/`gebrauch` ⇒ `anstoessig`/`zeitlich`، چون `details.register` (Partikel) و `details.gebrauch` (Adjektiv) از قبل معنای دیگری دارند و هم‌نامی گیج‌کننده بود.
  - **F.5b** به شکل `anstoessig.erklaerung` دوزبانه (نه `anmerkung`، چون anmerkung طبق پرامپت فقط آلمانی است و برای فارسی‌زبان بی‌فایده): چقدر توهین‌آمیز است + چه بگوییم. **F.5c** = `ersatz`.
  - اعتبارسنجی (`_pruefeEinordnung`): مقدار ناشناخته ⇒ خطای fatal (کارت نوشته نمی‌شود)؛ نبودن فیلد ⇒ مجاز (کارت‌های قدیمی تا F.7)؛ berufe مرتب/بی‌تکرار؛ ersatz.id_ref اصلاح؛ veraltet بی ersatz و anstoessig بی erklaerung ⇒ هشدار.
  - index (`vokab_index.dart`، نسخه‌ی ۲): `berufe`، `anstoessig` (فقط stufe)، `zeitlich` — فقط وقتی پر است.
  - تست `vokab_einordnung_test.dart` (از جمله: پرامپت و schema همان مقادیر را دارند).
  - از این به بعد هر کارت تازه (افعال از beklatschen) این چهار فیلد را دارد.
- [x] **F.6 + F.6b — ✅ 2026-10-14:** سه کشوی تازه در صفحه‌ی فیلتر: **مشاغل** (۹ دکمه با آیکون از کد — `berufIcon`)، **بی‌احترامی** (رکیک/تحقیرآمیز/تبعیض‌آمیز)، **منسوخ** (کهنه‌شده/منسوخ). ترتیب کشوها: کتاب‌ها · Wortart · Niveau · مشاغل · بی‌احترامی · منسوخ · دسته‌بندی‌های من. کلمه‌های قدیمی (بدون Einordnung) در این سه فیلتر نمی‌آیند. **برچسب روی صفحه‌ی کلمه** (`vokabular/widgets/wort_einordnung.dart`، اول `WortKarteAbschnitte`): شغل‌ها خنثی، هشدارها کهربایی (`AppColors.warning`)، کادر توضیح `anstoessig.erklaerung` به زبان فعال، و ردیف قابل‌کلیک «معادل امروزی» / «به‌جایش بگو» (کارت هست ⇒ صفحه‌ی آن، نیست ⇒ جست‌وجو). لمس برچسب ⇒ «Alle Wörter» فقط با همان فیلتر (`nurDieser`). متن‌ها: کلیدهای l10n `beruf_*`، `anstoessig_*`، `zeitlich_*`، `filter_berufe/anstoessig/zeitlich`، `wort_ersatz_*`. تست‌ها: `wort_einordnung_test.dart` + گروه تازه در `wortschatz_filter_test.dart`؛ ۴۳۵ تست سبز؛ اسکرین‌شات fa صفحه‌ی کلمه (با دو کارت آزمایشی فقط روی build محلی، کامیت نشد) و صفحه‌ی فیلتر بررسی شد. **تا F.7 دکمه‌های این سه کشو صفر و کم‌رنگ‌اند** چون هیچ کارتی هنوز این فیلدها را ندارد.
  - 🔎 برای F.7: بسیاری از کارت‌ها همین حالا در `anmerkung` نشانه دارند (مثلاً doof: «über Personen abwertend»، beatmen: «Fachsprache Medizin/Pflege») — نقطه‌ی شروع خوب، ولی هر کارت جدا و محتاط بررسی شود.
- [ ] ⏸️ **F.7 پر کردن فیلدها برای کارت‌های موجود — به تعویق افتاد (تصمیم Lukas، 2026-10-14):** این کار **بعد از تمام شدن کل اپ و قبل از شروع تست‌ها** انجام می‌شود، چون احتمالاً چند دسته‌ی دیگر هم اضافه می‌شود (Lukas مثال زد: **دیالکت**، **Umgangssprachlich** و …) — تا همه‌ی دسته‌ها **در یک دور** روی همه‌ی کارت‌ها پر شوند. روال آن موقع: دسته‌به‌دسته و محتاط؛ مطمئن نیستم ⇒ بدون برچسب؛ نشانه‌های `anmerkung` نقطه‌ی شروع‌اند (بند 🔎 F.6). تا آن موقع: کارت‌های **تازه** همین حالا طبق Regel 17 پرامپت با berufe/anstoessig/zeitlich/ersatz ساخته می‌شوند؛ کارت‌های قدیمی در سه کشوی F.6 نمی‌آیند (صفر و کم‌رنگ).
  - 💡 دسته‌های احتمالی آینده (هنوز تصمیم نشده، فقط ثبت): دیالکت (مثلاً اتریشی/سوئیسی/جنوب آلمان)، umgangssprachlich. اگر Lukas اضافه کرد: همان مسیر F.5/F.6 (Regel پرامپت + schema + index + کشو + برچسب).

## 🧪 فاز T — آزمون‌ها و نتیجه در Lernpfad (پیش‌نویس 2026-09-25 دور ۸۳ — ⛔ منتظر تصمیم Lukas، هنوز هیچ کدی ساخته نشده)

> **درخواست Lukas (2026-09-25):** ذخیره‌ی نتیجه‌ی آزمون (G7e) خوب است، ولی نوع آزمون بعداً عوض می‌شود: آزمون‌ها گسترده‌تر، پیچیده‌تر، با سؤال‌های بیشتر و متنوع‌تر، و شبیه‌ساز مؤسسه‌های مختلف (Goethe، telc، …). نتیجه در **Selbstlernen ⇒ Lernpfad** نمایش داده شود — هوشمند و زیبا. «پروسه‌ی بزرگ و طولانی؛ اول مراحل با جزئیات، بعد از تصمیم کامل شروع.»
> **وضع فعلی (بررسی Claude):** `leitfaden_screen.dart` (Lernpfad) هیچ داده‌ی واقعی ندارد — سطح فقط `_currentLevel = 'a1'` محلی است که کاربر خودش لمس می‌کند. آزمون سطح فعلی (G7b، `grammatik_niveautest.dart`) فقط گرامر، ۱۰ سؤال در هر سطح، C2 فقط ۳ سؤال؛ نتیجه‌اش جایی ذخیره نمی‌شود.
> **G7e در این فاز حل می‌شود (= T.1)** — دیگر جدا ساخته نمی‌شود.

> ✅ **تصمیم‌های Lukas (2026-09-25 دور ۸۴) — جایگزین هر چیزی در مراحل زیر که با این‌ها نمی‌خواند:**
> 1. **مؤسسه‌ها و سطح‌ها: هر چه بیشتر، بهتر.** فهرست: «📋 فهرست شبیه‌سازها» پایین. **اولی: ÖSD.** آخرین: **آزمون خود VOX** (بعد از تمام شدن همه‌ی شبیه‌سازها).
> 2. **منبع سؤال:** Lukas نمونه‌سؤال اصلی می‌فرستد. **ساختار دقیقاً مثل آزمون اصلی** (بخش‌ها، نوع و تعداد سؤال، زمان، امتیاز). ⚠️ حق نشر: محتوا (متن‌ها، جمله‌ها، گزینه‌ها) **از نو** با همان قالب و سختی نوشته می‌شود — «کمی تغییر» کافی نیست (پیشنهاد Claude، منتظر تأیید Lukas).
> 3. **قالب واحد سؤال (T.3):** تا حد ممکن شبیه آزمون واقعی.
> 4. **موتور (T.4):** حالت «تمرین» (جواب فوری) و «آزمون» (زمان‌دار، بخش‌به‌بخش). آزمون نیمه‌کاره **ادامه ندارد — از اول**. بعد از پایان فقط **نتیجه** نشان داده می‌شود، **جواب درست هرگز**. همه‌چیز آفلاین.
> 5. **آزمون تعیین سطح (T.5) = آزمون خود VOX:** فقط **یکی**، با سؤال‌های خیلی زیاد، ترکیبی از همه‌ی آزمون‌های دیگر ⇒ طولانی‌تر. **Lernpfad فقط نتیجه‌ی همین آزمون را نشان می‌دهد.** ساخت: آخر فاز T.
> 6. **انتخاب آزمون با کاربر است.**
> 7. **Schreiben:** مثل آزمون واقعی نمی‌شود ⇒ جای خالی، املا (دیکته با صدای دستگاه) و موارد مشابه. **⛔ هیچ هوش مصنوعی‌ای — کل پروژه رایگان.**
> 8. **Hören:** صدای خود دستگاه (TTS)، حتی اگر مصنوعی است.
> 9. **Sprechen / خودارزیابی:** وقتی رسیدیم **دوباره از Lukas بپرس**.
>
> ✅ **تصمیم‌های تکمیلی Lukas (2026-09-25 دور ۸۵) — همه‌ی تصمیم‌های پایه کامل است؛ فاز T شروع‌شدنی:**
> - **حق نشر:** ساختار دقیقاً مثل آزمون اصلی (بخش‌ها، نوع و تعداد سؤال، زمان، امتیاز، سختی)؛ **متن‌ها، جمله‌ها و گزینه‌ها را Claude از نو می‌نویسد** — تأیید شد.
> - **ترتیب شبیه‌سازها تأیید شد:** ÖSD ⇒ ÖIF ⇒ Goethe ⇒ telc ⇒ DTZ ⇒ telc Pflege/Medizin ⇒ TestDaF ⇒ آزمون خود VOX. **داخل هر مؤسسه: از A1 تا آخرین سطح**, به ترتیب.
> - **Hören:** Lukas نمونه‌ی صوتی را تا حد ممکن **با متن (Transkript)** می‌فرستد. ⚠️ **Claude: هر بار که نمونه‌ی Hören می‌خواهی، به Lukas یادآوری کن که متنش را هم بفرستد** (صدای دستگاه فقط متن را می‌خواند).
> - **نتیجه‌ی شبیه‌سازهای مؤسسه‌ها:** ذخیره می‌شود (T.1) + تاریخچه در بخش خود آزمون‌ها + مدال پروفایل (T.10؛ «کاربرها عاشق مدال‌اند»). در Lernpfad **نمی‌آید**.
> - **Lernpfad تا ساخت آزمون خود VOX مثل امروز می‌ماند** (سطح دستی کاربر).
> - هنوز باز: Sprechen/خودارزیابی ⇒ **وقتی به T.9 رسیدیم دوباره از Lukas بپرس.**
>
> ✅ **قواعد آزمون مثل آزمون واقعی (Lukas، 2026-09-25 دور ۸۷) — برای T.4 و همه‌ی شبیه‌سازها (T.7) و آزمون خود VOX:**
> - **زمان:** هر آزمون زمان رسمی خودش را دارد. **وقتی زمان تمام شود، آزمون فوراً تمام می‌شود**, حتی اگر همه‌ی سؤال‌ها جواب داده نشده باشد؛ سؤال بی‌جواب = ۰ امتیاز. (کد: `zeitLimitSekunden` و `zeitAbgelaufen` در `pruefungs_ergebnis.dart`.)
> - **جواب درست در آزمون هرگز نشان داده نمی‌شود** (تأیید دوباره).
> - **نمره‌ی هر بخش جدا نمایش داده می‌شود:** Lesen، Hören، Schreiben، Sprechen — به ترتیب کارنامه‌ی واقعی — به‌علاوه‌ی نمره‌ی کل. (کد: `teile` + `teileGeordnet`/`teilReihenfolge`.)
> - **آزمون فقط کامل:** نمی‌شود فقط یک بخش (مثلاً فقط Hören) را آزمون داد؛ همیشه همه‌ی بخش‌ها پشت‌سرهم. نتیجه‌ی شبیه‌ساز باید همه‌ی بخش‌هایش را داشته باشد. (کد: `vollstaendig()`.)
> - ✅ **حالت «تمرین»** (جواب فوری) **می‌تواند تک‌بخشی باشد** — مثلاً کاربر فقط Hören را تمرین کند (Lukas، دور ۸۸). قاعده‌ی «فقط کامل» فقط برای حالت «آزمون» است.
>
> **📋 فهرست شبیه‌سازها (پیشنهاد Claude؛ ترتیب بعد از ÖSD را Lukas تأیید می‌کند):**
> - **ÖSD** (اتریش): Zertifikat A1 · A2 · B1 · B2 · C1 · C2
> - **ÖIF Integrationsprüfung** (اتریش): A2 · B1
> - **Goethe-Institut:** Goethe-Zertifikat A1 (Start Deutsch 1) · A2 · B1 · B2 · C1 · C2 (GDS)
> - **telc:** Deutsch A1 · A2 · B1 · B2 · C1 · C1 Hochschule · C2
> - **DTZ** (آلمان، مهاجرت): A2–B1
> - **telc Deutsch B1·B2 Pflege** (پرستاری) · **telc Deutsch B2·C1 Medizin** (پزشکی)
> - **TestDaF** (دانشگاه، B2–C1)
> - **آخر:** آزمون خود VOX (ترکیبی) ⇒ Lernpfad

**مراحل پیشنهادی (به ترتیب):**
- [ ] **T.0 تصمیم‌ها و منبع‌ها (Lukas)** — کدام مؤسسه‌ها/سطح‌ها و به چه ترتیب؛ ساختار رسمی هر آزمون (بخش‌ها، زمان، امتیاز، حد قبولی) از منبع Lukas؛ روش Hören و Schreiben/Sprechen (T.8/T.9).
- [x] ✅ **2026-09-25 دور ۸۶ — انجام شد:** `core/backup/pruefungs_ergebnis.dart` (مدل خالص Dart: id `pr:#`+۳۲ hex، art، niveau، fassung، am، dauer، punkte/max با اعشار، bestanden، teile؛ خواندن بخشنده، ادغام = اجتماع)؛ قرارداد **Fassung 5** (`nutzer_zustand.dart`: فیلد `pruefungen` فقط اگر خالی نباشد ⇒ متن Fassung 4 بی‌تغییر)؛ ذخیره در SharedPreferences `vox_pruefungen_v1` (`user_state_repository.dart`: `pruefungenLesen`/`pruefungMerken` + lesen/anwenden) ⇒ فایل پشتیبان و همگام‌سازی حساب خودکار؛ `features/pruefungen/controllers/pruefungs_ergebnisse_controller.dart` (`pruefungsErgebnisseProvider`، جدیدترین اول)؛ آزمون سطح گرامر (G7b) در پایان نتیجه را ذخیره می‌کند (`UebungsSitzung.onFertig`)، **بدون پاسخ‌ها**. تست: `test/pruefungs_ergebnis_test.dart` (+۱۵ ⇒ ۳۳۴ سبز). ⚠️ دستگاهی با نسخه‌ی قدیمی اپ (Fassung 4) تا به‌روزرسانی، همگام‌سازی را متوقف می‌کند (`zuNeu`) — طراحی عمدی فاز S. متن طرح: **T.1 پایه‌ی ذخیره‌ی نتیجه (عمومی، ماندگار) = G7e** — هر آزمون = یک «رکورد نتیجه»: id یکتا، نوع آزمون (`grammatik_niveau`، `einstufung`، `sim_goethe_b1` …)، **نسخه‌ی آزمون**، تاریخ، سطح، امتیاز کل، امتیاز هر مهارت (Lesen/Hören/Schreiben/Sprechen/Grammatik/Wortschatz — هر کدام اختیاری)، زمان صرف‌شده، (اختیاری) پاسخ‌ها. **فقط اضافه می‌شود، هرگز حذف/بازنویسی** (مثل لایتنر) ⇒ ادغام همگام‌سازی = اجتماع بر اساس id. داخل داده‌ی کاربر ⇒ پشتیبان (S.5) + همگام‌سازی Supabase (فاز S). نگهبان تست: قالب قدیمی همیشه خواندنی. **چرا اول:** آزمون‌های آینده بدون تغییر قالب به همین وصل می‌شوند؛ نتیجه‌ی آزمون فعلی از همین امروز جمع می‌شود.
- [ ] **T.2 Lernpfad v1** — کوه (`MountainProgressWidget`) از نتیجه‌ی واقعی: «سطح تخمینی تو»؛ کارت آخرین نتیجه؛ تاریخچه؛ حالت خالی («هنوز آزمونی نداده‌ای ⇒ شروع آزمون»)؛ از صفحه‌ی نتیجه‌ی آزمون یک دکمه به Lernpfad. سطح دستی کاربر هم می‌ماند (انتخاب خودش ≠ نتیجه‌ی آزمون، هر دو دیده شوند).
- [ ] **T.3 قالب واحد سؤال** — مثل کارت کلمه: یک schema + یک اعتبارسنج (تنها منبع، مثل `vokab_schema.dart`) + یک پرامپت ساخت سؤال (مثل Wort prompt). نوع‌ها: چندگزینه‌ای، جای خالی، وصل‌کردنی، درست/غلط/ذکرنشده، متن + سؤال‌ها (Lesen)، صوت + سؤال‌ها (Hören)، نوشتن آزاد، گفتار. هر سؤال: سطح، مهارت، موضوع گرامر/واژه (برای T.6).
- [ ] **T.4 موتور آزمون** — ⚠️ قواعد دور ۸۷ (زمان رسمی و پایان خودکار، نمره‌ی جدای هر بخش، فقط آزمون کامل، بدون جواب درست) بالاتر در بلوک «✅ قواعد آزمون مثل آزمون واقعی» — بر هر چیز دیگر مقدم است. متن طرح: حالت تمرین (جواب فوری) و حالت آزمون (زمان‌دار، بخش‌به‌بخش، بدون جواب تا آخر)؛ ادامه‌ی آزمون نیمه‌کاره؛ کاملاً آفلاین.
- [ ] **T.5 آزمون تعیین سطح هوشمند (Einstufungstest)** — تطبیقی: درست ⇒ سؤال سخت‌تر، غلط ⇒ آسان‌تر؛ گرامر + واژه + Lesen؛ ۲۰–۳۰ دقیقه؛ جای آزمون فعلی G7b به‌عنوان ورودی اصلی (G7b به‌عنوان «آزمون گرامر هر سطح» می‌ماند).
- [ ] **T.6 تحلیل هوشمند + Lernpfad v2** — نقاط ضعف بر اساس مهارت و موضوع ⇒ پیشنهاد مستقیم (لینک به درس گرامر، deck، کلمه‌ها)؛ نمودار مهارت‌ها، روند پیشرفت در زمان، کارت «قدم بعدی تو».
- [ ] **T.7 شبیه‌سازها** — هر بار **یک** آزمون کامل (یک مؤسسه + یک سطح) از اول تا آخر، بعد بعدی. ساختار، زمان و امتیازدهی طبق قوانین رسمی (منبع Lukas). ⚠️ سؤال‌ها **از نو** نوشته می‌شوند (کپی Modelltest ممنوع — حق نشر)؛ عنوان «در قالب Goethe-Zertifikat B1»، با توضیح «آزمون رسمی نیست».
- [ ] **T.8 Hören** — منبع صوت (تصمیم Lukas): صدای مرورگر (TTS، رایگان، آفلاین ناقص) یا فایل ضبط‌شده (کیفیت آزمون واقعی، حجم زیاد).
- [ ] **T.9 Schreiben/Sprechen** — نسخه‌ی اول بدون سرور: نمونه‌پاسخ + چک‌لیست معیارهای رسمی + خودارزیابی؛ بعداً (فقط با تصمیم Lukas و سقف هزینه‌ی ~۵۰ یورو/ماه) ارزیابی با AI.
- [ ] **T.10 اتصال به جایزه‌های پروفایل** (آرزوی Lukas 2026-09-20) — مثلاً مدال قبولی در هر شبیه‌ساز.
- [ ] **T.11 QA** — تست‌های واحد (امتیازدهی، ادغام نتیجه‌ها)، تست آفلاین، بازبینی چشمی Lukas روی آیفون/مک.

## 🔍 فاز Q — بازبینی کیفیت (کارهایی که شاید با Sonnet انجام شد؛ Lukas، 2026-10-11)

> **چرا؟** Lukas چند مرحله‌ی آخر (حدود یک هفته قبل از 2026-10-11، تاریخ دقیق نامعلوم) را اشتباهی با Sonnet به‌جای Opus اجرا کرد. تصمیم Lukas: بازبینی هدفمند **قبل از افعال** — نه بررسی کل اپ کد به کد، نه صبر تا آخر.
> **بازه (کمی بزرگ‌تر از یک هفته تا چیزی جا نماند):** از اولین commit 2026-09-29 (`6a06812`، دور ۴۲۱) تا `3820108` (wert … wirr، 2026-10-10). کارهای 2026-10-11 (Opus) بیرون‌اند.
> **قاعده‌ی اصلاح:** فقط **درست‌کردن یا افزودن** — هیچ کارت، id، مثال یا جزئیاتی حذف نمی‌شود (⭐ اصل اول و قاعده‌ی مثال‌ها). استثنا: خطای آشکار ساختاری (مثلاً کلمه‌ای که مترادف خودش ثبت شده).

- [x] **Q.0 — ثبت فاز** (2026-10-11).
- [x] **Q.1 — بازبینی کد بازه (2026-10-11):** فقط سه تغییر کد در بازه بود: جست‌وجو/لمس با شکل صرف‌شده (`1a3141f` 2026-09-30: `altwort_formen.dart`، `word_dao.dart → nachForm`، `vokabular_controller.dart → vokabSucheProvider`، `search_controller.dart`، `klick_wort_provider.dart`، `wortschatz_list_screen.dart`) و Pomodoro (`c50404b` B-14، `9da0db8` B-14b). خط به خط خوانده شد ⇒ **هیچ خطایی پیدا نشد** (ساعت واقعی، ذخیره/بازیابی، Wake Lock با درخواست دوباره بعد از برگشت، صدا با Web Audio، همه با try/catch و تست). یادداشت (خطا نیست): جست‌وجوی سراسری تعداد نتیجه‌های آرشیو را محدود نمی‌کند — اگر با آرشیو بزرگ کند شد ⇒ V.4.
- [x] **Q.2 — ابزار ماندگار بازبینی محتوا:** `tool/vokab_qualitaet.dart` (فقط گزارش، چیزی نمی‌نویسد، build را نمی‌شکند): ترجمه‌ی fa/en در خط درست، IPA، سطح دو مثال (اول A1/A2، دوم B1/B2 — قاعده‌ی ۹)، مثال تکراری، مترادف/متضاد = خود کلمه، Steigerung ناقص/غلط، gegensatzpaar، wortnetz تکراری یا به خودش. اجرا: `dart run tool/vokab_qualitaet.dart [--liste f.txt] [--alle]`. **از این به بعد در هر دور کلمه هم اجرا شود.**
  · **نتیجه‌ی اولین اجرا (۶۱۲۹ کارت):** (۱) **سطح مثال‌ها — خطای اصلی بازه:** ۷۲۴ کارت مثال اولشان A1/A2 نیست (B1 ۲۹۶، B2 ۲۷۵، C1 ۱۱۰ در بازه) و ۴۴۵ کارت مثال دومشان B1/B2 نیست (بیشتر C1/C2) — **۶۸۱ و ۴۳۸ تایشان در همین بازه**، بیرون از بازه فقط ~۴۰. یعنی در بازه سطح مثال بر اساس سطح *کلمه* زده شده، نه سطح *ساختار جمله* (قاعده‌ی ۹ پرامپت و روش ۴۰۰۰ کارت قبلی). خود جمله‌ها و ترجمه‌ها در نمونه‌ها درست و طبیعی بودند. (۲) `adjektiv_rueckwirkend`: «rückwirkend» مترادف خودش ثبت شده بود ⇒ آن ردیف برداشته شد. (۳) `adjektiv_steuerbar`: wortnetz «die Steuer» و «das Steuer» یک id می‌گیرند — مشکل شناخته‌شده‌ی هم‌نویسه‌ها (⇒ «⛔ قبل از شروع اسم‌ها»)، خطای کارت نیست. (۴) ۱۷ «حرف لاتین در ترجمه‌ی fa» = توضیح دستوری عمدی (مثلاً «+ Genitiv»، «CDU») ⇒ درست.
- [x] **Q.3 — خواندن کارت‌های بازه (۲۱۲۹ کارت، فهرست: `tool/qualitaet/q_liste.txt`)** دسته‌دسته (~۲۰۰ در هر جلسه): ترجمه، IPA، Steigerung، Niveau کلمه، مثال‌ها. **روش اصلاح سطح مثال:** برچسب = سطح ساختار جمله (مثل ۴۰۰۰ کارت قبلی): جمله‌ی اول ساده و کوتاه ⇒ A1/A2؛ جمله‌ی دوم با Nebensatz یا ساختار معمول ⇒ B1/B2. اگر جمله‌ی اول واقعاً ساده نیست ⇒ یک جمله‌ی ساده‌ی A1/A2 تازه **اول** اضافه می‌شود و جمله‌های قبلی با برچسب درست می‌مانند (هیچ جمله‌ای حذف نمی‌شود). پیشرفت: هر دسته یک خط زیر همین بند.
  · **یافته‌ی مهم (2026-10-11):** خطای سطح مثال‌ها **فقط در کارت‌های 2026-10-08 و 2026-10-09** است (۹۳۹ کارت، rigide … unerhört؛ ۶۸۵ کارت خطا). کارت‌های 2026-09-29 (۵۹۰) و 2026-10-10 (۶۰۰) صفر خطا دارند ⇒ به احتمال زیاد **جلسه‌های Sonnet همین ۸ و ۹ اکتبر** بوده‌اند. ⇒ Q.3a: خواندن کامل ۹۳۹ کارت ۸–۹ اکتبر؛ Q.3b: کارت‌های ۲۹ سپتامبر و ۱۰ اکتبر فقط نمونه‌خوانی.
  · ✅ **دسته‌ی ۱ (2026-10-11):** (الف) **۵۷۹ کارت** که جمله‌ی اولشان ساده و کوتاه است (بدون ویرگول، ≤۱۰ کلمه) ⇒ فقط **برچسب** درست شد: اول ⇒ A2، دوم ⇒ B2 اگر جمله‌واره دارد (ویرگول)، وگرنه B1. متن هیچ جمله‌ای عوض نشد. (ب) ✅ **۱۰۶ کارت** که جمله‌ی اولشان جمله‌واره داشت (فهرست: `tool/qualitaet/q_offen_satz1.txt`) ⇒ برای هر کدام یک جمله‌ی ساده‌ی A2 تازه **اول** اضافه شد (fa+en، کلمه‌ی هدف در جمله)؛ دو جمله‌ی قبلی **بدون تغییر متن** ماندند و فقط برچسب گرفتند (جمله‌واره ⇒ B2، وگرنه B1) ⇒ این کارت‌ها حالا ۳ مثال دارند (مجاز، مثل arisch). اعتبارسنجی رسمی (`vokabular_import --dry-run`): ۰ خطا/۰ هشدار. **نتیجه: سطح مثال در هر ۹۳۹ کارت ۸–۹ اکتبر درست است** (`vokab_qualitaet`: فقط هشدار شناخته‌شده‌ی steuerbar باقی است). (ج) خطای محتوا پیدا و درست شد: `adjektiv_rostig` (ترجمه‌ی fa «نواخته‌ام» ⇒ «ننواخته‌ام»، منفی جا افتاده بود)، `adjektiv_rumaenisch` («fließend rumänisch» ⇒ «Rumänisch»، اسم زبان بزرگ نوشته می‌شود). (د) خوانده‌شده با چشم: کارت‌های ۱–۱۰۰ (rigide … sägerau) — بقیه‌ی محتوا درست و طبیعی بود. یادداشت: ۶۸٪ صفت‌ها Steigerung = null دارند، **قبل و داخل بازه یکسان** ⇒ روش قدیمی پروژه (قاعده‌ی ۱۴)، نه خطای Sonnet.
  · ✅ **دسته‌ی ۲ (2026-10-11):** کارت‌های ۱۰۱–۲۰۰ فهرست ۸–۹ اکتبر (säkular … schlüssig) با چشم خوانده شد ⇒ خطای تازه‌ای نبود. **نرخ خطای محتوا تا اینجا: ۲ از ۲۰۰ (~۱٪)** — یعنی مشکل اصلی Sonnet سطح مثال‌ها بود که درست شد؛ ترجمه‌ها و جمله‌ها در کل سالم‌اند.
  · ✅ **دسته‌ی ۳ (2026-10-11):** کارت‌های ۲۰۱–۵۰۰ (schmackhaft … stachelig) خوانده شد ⇒ ۱۲ کارت اصلاح شد (فقط درست‌کردن): ترجمه‌ی fa جمله‌ها — schmutzig (ترتیب جمله)، schmerzlich («ضرر» ⇒ «فقدان»)، selbständig («اخراج» ⇒ «ترک کار»؛ Kündigung دوپهلوست)، selig (Seligsprechung ⇒ «سعادتمند» نه «مبارک»)، sekundenlang، siebenstellig، spät («قطار رابط»)؛ ترجمه‌ی کلمه — schnodderig («سلیطه» برداشته شد: توهین جنسیتی و معنای غلط)، solvent («ملی» برداشته شد: معنای غلط)، servil (غلط تایپی برده‌وار)، sommergrün («همیشه‌سبز نیست…» ⇒ «برگ‌ریز»)؛ آلمانی — solubel («solubele» صرف غلط ⇒ جمله‌ی گزاره‌ای «ob ein Wirkstoff solubel … ist» تا Lückentext کار کند). اعتبارسنجی رسمی ۰/۰.
  · **نرخ خطا تا اینجا: ۱۵ از ۵۰۰ (~۳٪)، بیشترشان ریز (ترجمه‌ی فارسی جمله)؛ هیچ خطای ساختاری یا معنای کاملاً غلط کلمه‌ی اصلی پیدا نشد.**
  · ✅ **دسته‌ی ۴ (2026-10-11) — Q.3a تمام شد:** کارت‌های ۵۰۱–۹۳۹ (städtisch … unerhört + عددهای ترتیبی sechste … tausendste) خوانده شد ⇒ ۶ کارت اصلاح شد: stutzig («به شرکت تماس گرفت» ⇒ «با شرکت»)، symptomatisch (ترجمه‌ی ناقص «نشانه‌ی» ⇒ «نشانه‌دهنده»)، sechzigste و siebzigste («سالگرد» ⇒ «سالروز تولد»)، siebte (stolz ⇒ «به خودش افتخار می‌کرد»، نه «مغرور»)، unbemannt. **هر ۹۳۹ کارت ۸–۹ اکتبر با چشم خوانده شد.** جمع کل اصلاح‌های محتوایی: ۲۱ کارت از ۹۳۹ (~۲٪)، همه ریز؛ به‌علاوه‌ی سطح مثال‌ها در ۶۸۵ کارت. `vokab_qualitaet` روی این ۹۳۹ کارت: فقط هشدار شناخته‌شده‌ی steuerbar.
  · ✅ **Q.3b (2026-10-11):** نمونه‌ی تصادفی ۱۲۰ کارت (۶۰ از 2026-09-29، ۶۰ از 2026-10-10؛ فهرست با seed=11 از `q_liste.txt`) خوانده شد ⇒ سطح مثال‌ها همه درست؛ ۳ اصلاح ریز ترجمه‌ی fa: peripatetisch («رواقی» ⇒ «راهروی سرپوشیده (پریپاتوس)»، رواقی با Stoa اشتباه می‌شد)، unfehlbar (دستور جمله‌ی فارسی)، unsinkbar (ترتیب کلمه). نرخ مثل بقیه (~۲٪، ریز) ⇒ خواندن کامل این دو روز لازم نیست.
- [x] **Q.4 — جمع‌بندی (2026-10-11) — ✅ فاز Q تمام شد:** کد بازه بدون خطا (Q.1). خطای اصلی Sonnet = سطح مثال‌ها در ۶۸۵ کارت ۸–۹ اکتبر ⇒ ✅ درست شد (۵۷۹ برچسب + ۱۰۶ جمله‌ی ساده‌ی تازه، چیزی حذف نشد). اصلاح محتوایی: ۲۴ کارت (همه ریز: ترجمه‌ی fa جمله‌ها، چند ترجمه‌ی کلمه با معنای غلط مثل «سلیطه»/«ملی»، دو خطای آلمانی rumänisch/solubel، یک مترادف تکراری). `vokab_qualitaet` روی همه‌ی ۶۱۲۹ کارت: فقط هشدارهای توضیح‌داده‌شده — ۱۷ «لاتین در fa» (توضیح دستوری عمدی)، steuerbar (هم‌نویسه)، و **۴۴ + ۷ کارت قدیمی‌تر از بازه** (قبل از 2026-09-29، نه Sonnet) که سطح مثالشان با قاعده‌ی ۹ نمی‌خواند ⇒ برای بعد (⇒ V.4)، فوری نیست. ⏭️ بعد از فاز Q: ⛔ تصمیم Lukas درباره‌ی افعال.

## 📚 روال «ده کلمه جدید» — دیکشنری آنلاین VOX (L.4)

> **Lukas فقط می‌گوید: «ده کلمه جدید وارد کن».** Claude بدون سؤال همین روال را از اول تا آخر اجرا و ثبت می‌کند.
> هدف (Lukas، 2026-09-23): VOX یک **دیکشنری آنلاین** با تقریباً همه‌ی کلمه‌ها. **ترتیب فهرست هرگز عوض نمی‌شود** (الفبایی، همان فایل).
>
> ⭐ **اصل اول — هر کلمه همیشه صفحه‌ی جدید (Lukas، 2026-09-24 دور ۶۳؛ جایگزین L.4b / L.4b-2 / L.4c قدیم):**
> - هر کلمه‌ی فهرست **همیشه** کارت تازه با **صفحه‌ی جدید خودش** می‌گیرد — مهم نیست از قبل در اپ باشد: کلمه‌ی تنها، دو کلمه‌ای/با حرف اضافه (`warten auf`)، با `sich`، یا داخل یک عبارت (`eine Entscheidung treffen`). از قبل بودن ⇒ **نه سؤال، نه بررسی، نه صبر.**
> - **هیچ** صفحه، کلمه یا جزئیاتی از هیچ صفحه‌ای حذف نمی‌شود؛ هیچ ادغام، هدایت یا پنهان‌کردن. **دوبرابر شدن اشکال ندارد.**
> - **آخرین مرحله** (وقتی هر چهار فهرست صفر تا صد وارد شد): Claude **همه‌ی** کلمه‌های اضافی/دوبرابر را پیدا می‌کند ⇒ **Lukas تصمیم می‌گیرد** با هر کدام چه شود ⇒ «🔁 مرحله‌ی آخر (۲)» ته همین فایل (L.4d).
> - کد (همین اصل): هر کارت صفحه‌ی خودش (`/vokabular/wort/:id`) و ردیف خودش در «Alle Wörter» را دارد. اگر همان کلمه صفحه‌ی قدیمی اپ دارد، آن صفحه کارت را فقط **اضافه** زیر خودش نشان می‌دهد (`features/wortschatz/data/altwort_karte.dart` — فقط افزودن، هرگز هدایت/پنهان). نگهبان: `test/altwort_karte_test.dart` («Grundregel»).
>
> 🔒 **کلمه‌ی نامطمئن ⇒ نساز (Lukas، 2026-09-24) — خودکار، بدون پرسیدن:**
> - **چه کلمه‌ای؟** معنا، کاربرد (مثلاً شاید اصلاً صفت نیست) یا املای نامطمئن، یا هر شک دیگر (قاعده‌ی ۱۴ پرامپت: حدس ممنوع).
> - **ثبت در سه جا (همیشه یکسان):** (۱) جدول «🏁 مرحله‌ی آخر» ته همین فایل (تاریخ، فهرست، دلیل) · (۲) `zurueckgestellt` در `tool/naechste_woerter.dart` · (۳) ستون «کنار گذاشته» جدول پیشرفت. کلمه‌ی بعدی جایش می‌آید؛ نام + دلیل به Lukas گزارش می‌شود.
> - **فعل دوگانه‌ی جداشدنی/جدانشدنی** (über-/um-/durch-/unter-/wieder-/hinter-/voll- …): همیشه کنار می‌رود تا بعد از تمام شدن همه‌ی افعال؛ آن موقع با پرامپت ویژه (کارت + شکل هندسی) ساخته می‌شود — تصمیم Lukas 2026-10-13، جزئیات: «🏁 مرحله‌ی آخر» ⇒ «🔀».
> - **کی؟** فقط در آخر کار (هر چهار فهرست تمام) Lukas درباره‌ی تک‌تکشان تصمیم می‌گیرد؛ تا آن موقع ساخته نمی‌شوند (مگر Lukas زودتر بخواهد).
> - **استثنا:** فقط Wortart فهرست غلط است (aberhundert، achte ⇒ numerale) ⇒ با Wortart درست (Duden) ساخته می‌شود + `wortartKorrektur` در `tool/naechste_woerter.dart`.

**فایل‌ها (همیشه تازه از `main` بخوان، نه از حافظه):**
- پرامپت کلمه (تنها منبع قالب کارت، SUPER-PROMPT 3.0): [`old files Lukasalmani/Wort prompt`](https://github.com/lukasylilli/vox/blob/main/old%20files%20Lukasalmani/Wort%20prompt)
- فهرست‌ها: [`old files Lukasalmani/Wörter/`](https://github.com/lukasylilli/vox/tree/main/old%20files%20Lukasalmani/W%C3%B6rter) — فعلی: [`Adjektive.txt`](https://github.com/lukasylilli/vox/blob/main/old%20files%20Lukasalmani/W%C3%B6rter/Adjektive.txt) (۶٬۸۴۹ صفت)
- اعتبارسنجی و id: [`lib/features/vokabular/data/vokab_schema.dart`](https://github.com/lukasylilli/vox/blob/main/lib/features/vokabular/data/vokab_schema.dart)
- ابزارها: `tool/naechste_woerter.dart` (۱۰ کلمه‌ی بعدی؛ `--abhaken` = ✓) · `tool/vokabular_import.dart` (نوشتن کارت‌ها) · `tool/vokab_index.dart` (فهرست + شکل‌های صرف‌شده) · **`tool/wort_runde.sh`** (مراحل ۵–۷ در یک دستور)
- مقصد: `assets/vocab/<wortart>/<id>.json` (یک کارت = یک فایل، fa+en در همان فایل). ظاهر (رنگ/نماد) فقط در کد — برای کلمه‌ی تازه هیچ فایل ظاهری عوض نمی‌شود.

**مراحل (به همین ترتیب):**
1. هر چهار فایل PLAN/MAP (vox + Root-in) و **پرامپت کلمه** را تازه بخوان.
2. Flutter: `curl -sL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.44.6-stable.tar.xz | tar xJ` ⇒ `export PATH=$PWD/flutter/bin:$PATH` ⇒ در ریپو `flutter pub get`.
3. `dart run tool/naechste_woerter.dart` ⇒ ۱۰ کلمه‌ی بعدی (کارت موجود و «کنار گذاشته» را خودش رد می‌کند).
4. برای همان ۱۰ کلمه طبق پرامپت یک **JSON-Array** در `/tmp/batch.json` بساز (همه‌ی TEIL 0 — به‌ویژه ۱۴: «مطمئن نیستی ⇒ null، حدس نزن»؛ ۱۵: حرف اضافه‌ی ثابت اجباری). از قبل بودن کلمه در اپ **مهم نیست** (⭐ اصل اول). کلمه‌ی نامطمئن ⇒ 🔒 بالا.
5–7. `bash tool/wort_runde.sh /tmp/batch.json` — **همان دستورها به همان ترتیب**، در یک اجرا: dry-run (باید «Fehler: 0 · Warnungen: 0») ⇒ import ⇒ `vokab_index.dart` ⇒ `naechste_woerter.dart --abhaken` (✓ در فهرست) ⇒ `flutter analyze` ⇒ `flutter test` ⇒ ۱۰ کلمه‌ی بعدی. اولین مشکل ⇒ توقف (با dry-run ناپاک هیچ چیز نوشته نمی‌شود).
8. جدول «پیشرفت» + خط «آخرین جلسه» + خط «پیشرفت» در MAP ⇒ commit + push ⇒ نتیجه‌ی GitHub Actions (قرمز ⇒ فوراً درست کن). چند دور در یک چت ⇒ هر دور commit خودش؛ «آخرین جلسه» یک ورودی جمعی.

**قاعده‌ها:** ترتیب ثابت · id کارت منتشرشده هرگز عوض/حذف نمی‌شود · بدون کپی از کتاب/دیکشنری، جمله‌ها از نو. · **مثال اضافه (Lukas، 2026-09-25 دور ۹۴):** پرامپت دقیقاً ۲ مثال می‌سازد؛ مثال‌هایی که Lukas می‌خواهد به کارتی اضافه شوند، مستقیم به `beispiele` همان کارت افزوده می‌شوند (کلمه‌ی هدف باید در جمله باشد) — هیچ مثالی حذف یا جایگزین نمی‌شود. نمونه‌ی اول: arisch.
**پیشرفت:**

| فهرست | انجام‌شده (آخرین کلمه) | کلمه‌ی بعدی | کنار گذاشته (منتظر Lukas) |
|---|---|---|---|
| ۱. `Adjektive.txt` (صفت) | aalartig … **überzeugend** (دور ۲۸–۵۲۱؛ فهرست دقیق: ✓ در `Adjektive.txt` = کارت در `assets/vocab/`) | **— ✅ فهرست صفت‌ها تمام شد (۰ باز)؛ بعدی: افعال، ⛔ منتظر تصمیم Lukas** | abatisch (2026-09-23) · abdikativ (2026-09-24) — معنا نامطمئن · afrikaans (2026-09-24) — کاربرد صفتی نامطمئن · aldente (2026-09-24) — املا مشکوک · aleppinisch (2026-09-24) — کاربرد صفتی نامطمئن · allenfallsig (2026-09-24) — شکل ثابت‌شده ندارد · altaltbacken (2026-09-24) — املا مشکوک · Altdorfer (2026-09-24) — اسم خاص/صفت مکانی · altkrank (2026-09-24) — معنا/کاربرد نامطمئن · amaranten · ambient · amethysten · amphibolisch · anamorph · anelliert · anotherm · antichretisch · appendikuliert · aretologisch · arschig · arschlos · assi · athermisch · ausheimisch · austral · averbal · azentrisch · azephal · bananig · bannig · basalten · basiklin · basten · batisten · bebuscht · bebust · bedonnert · befotzt · begeißelt · begrannt · behemdet · behost · behuft · beinfarben · bekrallt · bemähnt · bemützt · bepelzt · beredet · berindet · bernsteinen · berstig · berüscht · beschilft · beschürzt · besoffenbesondere · besonderes · besonderer · bestiefelt · bestrumpft · bestusst · betresst · betrieben · bezastert · bezopft · bibliophob · biereifrig · bimaxillär · birken · bitchig · blakig · bland · blaustrümpfig · bonfortionös · botrytisiert · boustrophedon · brennheiß · brillanten · brokaten · buchen · bundrein · buntfarben · busig · bustrophedon · chemometrisch · chilotisch · chionophil · chochem · chondritisch · claviform · damasten · dasig · debitorisch · dekremental · delatorisch · demanten · deprekativ · depretiativ · desiderat · designatus · desmal · dextral · dezisionistisch · diamanten · diffusibel · dikasterial · dilemmatisch · diptotisch · dissidentisch · dissipativ · distich · dolent · doloros · dominicanisch · doppelherzig · drahten · drittelzahlig · dutzend · dyadisch · ebengleich · egressiv · ehrenkäsig · eiben · eichen · einschaltbereit · elektrogen · elenktisch · emeritus · emisch · empathogen · enaktiv · endogenetisch · endothym · endozentrisch · enkaptisch · enneaeterisch · enostal · entaktogen · ephebisch · epifaszial · epithetisch · eponymisch · erdhaltig · erethisch · erfolgswirksam · erlen · erotomanisch · erzen · eschen · espen · etisch · euploid · europazentriert · euryhalin · euryhygr · euryök · eurytherm · exergon · exogenetisch · exozentrischg · expert · extinkt · extradiegetisch · extramundan · extra-temporal · extratemporal · fabisch · fadenbreit · fadenlos · faselnackend · fasennackend · fassettenartig · fassettenreich · fastidiös · fekund · fennoskandisch · fichten · fickerig · filamentartig · fipsig · firn · flächengroß · flächsen · flächsern · flanellen · fluvioglazial · gasig · gebalkt · gebuckelt · gefizt · gegengleich · gegiebelt · gehäusetragend · geheist · gehenkelt · gehl · geköpert · gekröpft · geperlt · gewalmt · glanzhell · griveliert · hären · halbverklungen · halbwollen · hallisch · haloniert · haltig · handsam · hanfen · hapaxanth · hieb-undstichfest · hinterer · hirschledern · hitlerisch · hühnermüde · humil · hydrogen · hygrisch · hypophrenisch · immediat · impardonnabel · imperturbatisch · importun · inkommod · innerer · insistent · interdenominational · interkranial · interkrustal · interkurrierend · interorbital · interterritorial · interurban · intervallisch · interventiv · inzident · irden · irländisch · jaden · jährig · jiddischistisch · judiziös · juwelen · juxtarenal · kaduk · kärntisch · kanevassen · kantoniert · karolinisch · katenativ · katotherm · kattunen · kautelarjuristisch · kiefern · knitz · knülle · knüll · koblenzisch · komplektisch · komputativ · konfliktär · konjugal · konkomitant · konphas · konvenient · konvers · konvivial · korallen · kredibel · kreiden · krisselig · krisslig · kristallen · krütsch · kryptomer · kunstseiden · kurrent · laff · laikal · larifari · latinisch · latreutisch · leckerfritzig · legasthen · leidsam · leinen · leinwand · letzter · levurozid · lidschäftig · limnophil · linden · linker · listrisch · lohfarben · lucianisch · ludisch · lübsch · lüdisch · lukulent · luminös · lustgetrieben · mainzisch · majorenn · mamertinisch · mancherlei · marastisch · marktbar · maschinenmäßig · masturbatorisch · mediat · meißenisch · meißnisch · messingen · metadiegetisch · millenarisch · minderer · ministrabel · mirakulös · mittelalterig · mittelaltrig · mnestisch · moderativ · monadisch · monadologisch · mongolid · mongoloid · moros · moselromanisch · nachmalig · nachrichtlich · nächst · nämlich · naschsüchtig · neolamarckistisch · neovitalistisch · neurasthenisch · neusilbern · neusumerisch · nichtperturbativ · nillenkrank · nordelbisch · notgeil · oberer · oberschlächtig · obliviös · obstinat · öffenbar · ogygisch · oknophil · opalen · oreal · orthotrop · oskisch · ostensibel · ostfälisch · ostgrönländisch · ouvert · ovovivipar · pädophil · pagatorisch · palato-alveolar · panchronisch · panhellenisch · papabile · papieren · papiern · papstfähig · paradoxal · parasprachlich · paraxial · pariserisch · partial · passiert · pastellen · patrologisch · pekig · penil · pentelisch · perdu · pergamenisch · pergamenten · perimortal · perkussiv · perlmuttern · permutabel · perpendikular · perpetuell · pervasiv · pervers · pestilenzartig · phallisch · phaneromer · phyletisch · pikarisch · pithekoid · pitschepatschenass · platzmäßig · plerophor · plüschen · pluralisch · poemisch · polabisch · polemogen · polydispers · polytoxikoman · polytrop · polyzyklisch · pongid · pornografisch · pornographisch · porzellanen · porzin · postalveolar · postfrisch · postulationsfähig · potentiometrisch · potenzsteigernd · prädiktabel · präjudiziell · präliminär · prämonetär · präplanetar · prärogativ · präsentisch · präsidiabel · präsumtiv · präterital · primordial · promisk · promiskuitiv · prosopografisch · proteisch · psychrophil · pueril · punitiv · pythonesk · quinär · quittegelb · quotal · räß · räumdig · rahn · rallig · rangig · raß · ratierlich · raubauzig · rebenumsponnen · renaissancistisch · reputabel · reputierlich · resonant · respektiv · restituiert · restitutiv · retikulär · retinotop · retransloziert · retroaktiv · retrobulbär · retrofuturistisch · rezent · rezeptorvermittelt · rheophil · rhodiniert · rhomboedrisch · ridikül · rodelfrei · überwechtet · unangesehen · unbedankt · unbeugbar · unbewehrt · undulös · ungerechnet · ungeständig · unikursal · unitaristisch · unleidig · unschierig · unsexy · unterer · unzial · uptodate · uranhaltig · urcool · uroborisch · vagil · vaginal · valabel · vanille · vaskularisiert · veilchenfarben · venenös · venerisch · venetisch · vereinslos · verfristet · vergnügungssüchtig · verhaltensgestört · verhascht · veritabel · verkrebst · verlustbehaftet · vernakulär · veronesisch · verpflichtungslos · verrechenbar · verrunzelt · versaut · verschwendungssüchtig · vertiert · vertränt · verzopft · vestibulär · vestimentär · vigil · vincentisch · vinophil · vogtländisch · volitional · vorderer · vorgabenwirksam · vorletzte · vulkanistisch · wegsam · wehrig · weidlich · weinfarben · weinfröhlich · weinfroh · weingelb · weinhaltig · weinig · weinsauer · weißfeldrig · weißgolden · weitentlegen · wergen · westmitteldeutsch · westoberdeutsch · wipfelschäftig · vielerlei · wirsch · wollen · wollüstig · wurzelverwandt · wuschig · xenophontisch · xerographisch · xerophil · yttriumhaltig · zahlungswirksam · zapfentragend · zedern · zehntpflichtig · zeitgeistlich · zeitinvariant · zementen · zertalt · zervikogen · zinken · zinnen · zinnern · zirkumpolar · zisalpin · zombig · zotig · zusammengeritten · zweibasig · zweibasisch · zweihebig · zweitmeist · zwirnen · zygomorph · zypressen · zytogen · zytotrop (2026-09-29 / 2026-10-11؛ دلیل‌ها: «🏁 مرحله‌ی آخر») |
| ۲. `Verben_unregelmaeßig_Infinitiv.txt` (فعل بی‌قاعده) | abbacken … **zuwiderlaufen** (دور ۵۲۲–۶۲۰؛ کنار گذاشته: abbedingen · abbehalten · abbleichen · abdingen · abdreschen · abkneifen · abkönnen · abliegen · abmelken · achthaben · andringen · anessen · anfinden · angedeihen · anheimgeben · ankeifen · ankleiben · ankönnen · ankriechen · aufbersten · aufbrennen · aufdringen · aufgleiten · aufglimmen · aufhauen · aufkleiben · aufklieben · aufklingen · aufliegen · aufrechtbleiben · ausbedingen · ausbiegen · ausbieten · ausbinden · ausbleichen · ausdreschen · auseinanderbersten · auserkiesen · ausfinden · ausfrieren · ausgären · ausgebären · ausgreifen · aushaben · aushängen · aushauen · auskiesen · auskneifen · ausliegen · ausmahlen · ausmelken · auswärtsgehen · bedünken · bedürfen · beibiegen · beibleiben · beieinanderhaben · beieinanderhalten · beifallen · beigehen · beihalten · beiladen · beiliegen · beisammenhaben · beisammenhalten · bekleiben · belesen · bereitliegen · blickenlassen · blindfliegen · bloßliegen · brachliegen · dafürhalten · dafürkönnen · daherbringen · daherfliegen · dahinfahren · dahinfallen · dahinfliegen · dahinfließen · dahingeben · dahingehen · dahingleiten · daliegen · danebenfallen · danebengelingen · danebenhalten · danebenhauen · danebenliegen · daniederliegen · darangeben · darangehen · darbringen · dareinfinden · darleihen · darniederliegen · darüberfahren · darüberliegen · darumbinden · darumkommen · darunterbleiben · darunterfallen · daruntergehen · darunterheben · darunterliegen · davonbleiben · davorhalten · davorliegen · dazuhalten · dazukönnen · dazwischenfragen · dazwischenhauen · dazwischenliegen · dortbehalten · drangeben · dranhalten · dranhängen · draufgeben · draufhalten · draufhauen · drauflosfahren · drauflosgehen · drausbringen · drauskommen · dreinfahren · dreinfinden · dreingeben · durchblasen · durchbrechen · durchdenken · durchdreschen · durchdringen · durchdürfen · durcheinanderessen · durcheinanderlaufen · durchessen · durchfahren · durchflechten · durchfliegen · durchfließen · durchfressen · durchfrieren · durchgären · durchgraben · durchhauen · durchklingen · durchkönnen · durchkriechen · durchlaufen · durchmahlen · durchmüssen · ehebrechen · einbacken · einbegreifen · einbeißen · einblasen · eindreschen · einfressen · eingebären · einhängen · einhauen · einhelfen · einherfahren · einiggehen · einkneifen · einkommen · einwärtsgehen · eislaufen · emporfahren · emporfliegen · emporheben · entbieten · entgegenfließen · entzweibeißen · entzweibrechen · erbieten · erbleichen · erfechten · erheischen · erkiesen · erküren · erlaufen · erlesen · erlügen · erschrecken · fahen · fahrenlassen · fallenlassen · feilbieten · feilhalten · feinmahlen · fertiglesen · festbleiben · fortbegeben · fortblasen · fortdenken · fortdürfen · fortgießen · forthaben · fortkönnen · fortkriechen · fortmüssen · freibleiben · freilaufen · gegeneinanderhalten · gegenfragen · geheißen · gutgehen · heimbegeben · heimdürfen · heimfallen · heimkönnen · heimmüssen · heischen · herabfahren · herabkommen · heranbinden · herandürfen · herankönnen · heranmüssen · heraufdringen · heraufdürfen · heraufkönnen · heraufmüssen · herausbrechen · herausdringen · herausdürfen · heraushängen · heraushauen · herausklingen · herauskönnen · herausmüssen · herbeifahren · herbeifliegen · herbeilassen · herdürfen · hereindringen · hereindürfen · hereingeben · hereinkönnen · hereinkriechen · hereinmüssen · herkönnen · hermüssen · herniederfallen · herniedergehen · herüberdringen · herüberdürfen · herüberfliegen · herüberhängen · herüberkönnen · herübermüssen · herumbiegen · herumbinden · herumgreifen · herumhaben · herumhängen · herumkriechen · herunterbiegen · herunterbrechen · herunterbrennen · herunterdürfen · herunterfliegen · heruntergießen · heruntergleiten · herunterhängen · herunterhauen · herunterkönnen · herunterkriechen · heruntermüssen · hervordringen · herzukommen · hinabfahren · hinaufdürfen · hinauffallen · hinaufkönnen · hinaufkriechen · hinauflassen · hinaufmüssen · hinausbegeben · hinausblasen · hinausdenken · hinausdringen · hinausdürfen · hinausgreifen · hinaushalten · hinaushängen · hinausheben · hinauskönnen · hinausmüssen · hinbegeben · hinbieten · hindurchdringen · hindurchdürfen · hindurchfließen · hindurchkönnen · hindurchkriechen · hindurchmüssen · hindürfen · hineinbegeben · hineinblasen · hineinbrennen · hineindringen · hineindürfen · hineinfliegen · hineinfressen · hineingleiten · hineingreifen · hineinhalten · hineinhängen · hineinkönnen · hineinkriechen · hineinmüssen · hinfließen · hingießen · hingleiten · hinhaben · hinhängen · hinhauen · hinkönnen · hinmüssen · hintanbleiben · hintanhalten · hintenüberfallen · hinterbringen · hintereinanderfahren · hintereinandergehen · hintereinanderlaufen · hinteressen · hintergießen · hinterlaufen · hinüberbegeben · hinüberdürfen · hinüberfliegen · hinübergleiten · hinübergreifen · hinüberhängen · hinüberkönnen · hinüberlassen · hinunterdürfen · hinunterfliegen · hinuntergießen · hinwegbegeben · hinwegbringen · hinweglesen · hinzubekommen · hinzudenken · hinzuerfinden · hinzulaufen · hochbiegen · hochbinden · hochfliegen · hochkönnen · hochkriechen · hochmüssen · hockenbleiben · hofhalten · küren · langliegen · laufenlassen · leeressen · liebbehalten · liegenbleiben · liegenlassen · losbrechen · losdreschen · losdürfen · loshaben · loshalten · loskönnen · losmüssen · mitbieten · mitdürfen · mitempfinden · mitklingen · mitkönnen · mitlassen · mitmüssen · nachdürfen · nachfallen · nachgären · nachgreifen · nachhalten · nachkönnen · nachmüssen · näherliegen · nebeneinanderhalten · nebeneinanderliegen · niederbrechen · niederbrennen · niederbringen · niederdreschen · niederfahren · niederhauen · obliegen · offenliegen · paarlaufen · platzenlassen · quellen · querkommen · ranbinden · rankönnen · ranmüssen — 2026-10-11 · reinfliegen · reinhauen · reinkönnen · reinmüssen · richtigliegen · rinnen · rückfragen · rückwärtsfahren · rückwärtsgehen · ruhenlassen · rumhaben · rumhängen · rundfragen · runterfliegen · runterhauen · sattbekommen · satthaben · saugen · sausenlasen · schaffen · schallen · scheren · schiefliegen · schießenlassen · schinden · schlechtgehen · schleifen · schleifenlassen · schleißen · schliefen · schmalzen · schmorenlassen · schockgefrieren · schrecken · schroten · schwären · schwarzbrennen · schweifen · schwellen · schwerhalten · segelfliegen · seinlassen · setzenlassen · sieden · sinnen · sitzenbleiben · sitzenlassen · spalten · spitzbekommen · spitzhaben · spleißen · statthaben · steckenbleiben · steckenlassen · stehenbleiben · stehenlassen · steifhalten · stieben · stillbleiben · stillhalten · stillliegen · tiefgefrieren · totbeißen · totlaufen · triefen · trockenfallen · überbacken · überbekommen · überbinden · überblasen · überbleiben · überbraten · überbrennen · übereinanderliegen · überessen · überfahren · überfallen · überfangen · überfliegen · überfließen · überfragen · überfressen · überfrieren · übergehen · übergießen · überhaben · überhängen · überheben · überkommen · überladen · überlaufen · überlesen · übrigbleiben · übrighaben · übriglassen · umbehalten · umbinden · umbrechen · umfahren · umfangen · umflechten · umfliegen · umfragen · umgeben · umgehen · umgreifen · umhaben · umhängen · umhauen · umherkriechen · umhinkönnen · umlassen · umlaufen · unterbinden · untereinanderliegen · unterfahren · unterfallen · unterfliegen · untergraben · unterhalten · unterkriechen · unterlaufen · unterliegen · verbacken · verblasen · verbleichen · verdingen · verdreschen · verdrießen · vergären · verglimmen · verhauen · verkiesen · verkleiben · verleitgeben · verlorengeben · verlorengehen · vermahlen · verquergehen · verschüttgehen · vollessen · vollfressen · vollgießen · vollladen · volllaufen · voraufgehen · vorausfliegen · vorbeidürfen · vorbeifließen · vorbeigelingen · vorbeigleiten · vorbeikönnen · vorbeimüssen · vorblasen · voreinanderliegen · vorenthalten · voressen · vorfliegen · vorgebären · vorhängen · vorlaufen · vornüberfallen · vorüberfahren · vorüberfliegen · vorübergleiten · vorüberkommen · vorüberlassen · vorüberlaufen · vorwärtslaufen · wachhalten · wägen · wahrhaben · warmhalten · warmlaufen · wegbegeben · wegbeißen · wegbinden · wegbrechen · wegbrennen · wegdürfen · wegfangen · wegfließen · wegfressen · weghaben · weghalten · weghauen · weghelfen · wegkönnen · wegkriechen · wegmüssen · weiterdürfen · weiterfragen · weiterfressen · weiterkönnen · weiterkriechen · weitermüssen · wenden · werthalten · wettlaufen · widerklingen · wiedererhalten · wiederhaben · wiederkennen · wiegen · wissenlassen · wundliegen · zeihen · zerbersten · zerfahren · zerhauen · zerklieben · zerlesen · zermahlen · zudenken · zueinanderdürfen · zueinanderhalten · zueinanderkommen · zueinanderkönnen · zueinanderlassen · zuerkennen · zugewinnen · zuhaben · zuhauen · zukneifen · zukriechen · zuladen · zurechtbiegen · zurechtbringen · zurückbegeben · zurückbiegen · zurückdürfen · zurückgießen · zurückgleiten · zurückhaben · zurückhauen · zurückkönnen · zurückmüssen · zusammenbiegen · zusammenflechten · zusammengeben · zusammengießen · zusammenhaben · zusammenhängen · zusammenhauen · zusammenklingen · zusammenkneifen · zusammenlassen · zusammenlesen · zusammenliegen · zusammenlügen — 2026-10-13) | **— ✅ فهرست افعال بی‌قاعده تمام شد (۰ باز)؛ بعدی: فهرست ۳** | ✅ تصمیم Lukas 2026-10-11 — «افعال — تصمیم Lukas» پایین |
| ۳. `Verben_regelmaesig.txt` (فعل باقاعده) | aalen … **fusionieren** (دور ۶۲۱–۶۹۹؛ کنار گذاشته: aasen · abhausen · abwägen · addizieren · affirmieren · affizieren · algorithmisieren · alimentieren · allozieren · älteln · alterieren · altertümeln · altmachen · amalgamieren · antichambrieren · apanagieren · apern · äpfeln · apostrophieren · approximieren · aptieren · aquarellieren · äquilibrieren · arabisieren · arbitrieren · archaisieren · arisieren · arkadieren · armieren · armmachen · arretieren · arrivieren · arrodieren · arrondieren · arsenieren · arten · äsen · aspirieren · assekurieren · assemblieren · asservieren · asten · ästen · ästhetisieren · äthern · atomisieren · atrophieren · attachieren · attraktivieren · attribuieren · atzen · aufächzen · appretieren · äugeln · äugen · ausixen · ausmergeln · auszementieren · auszieren · auszirkeln · authentisieren · autographieren · autoklavieren · autonomisieren · auxiliieren · aversionieren · avertieren · avisieren · avivieren · avouieren · axiomatisieren · azotieren · balbieren · baldowern · balsamieren · bändern · barbieren · bäumen · bauschen · bechern · beckmessern · beeiden · beeidigen · befleißigen · befrachten · befummeln · beglotzen · begnaden · bekiffen — 2026-10-13 · belämmern · benedeien · beschälen · beschranken · bessemern · bestallen · bestuhlen · betatschen · betonnen · beulen · beuteln · bewandern · bewegen — 2026-10-14 · bimsen · bläuen · blessieren · blinkern · bollern · bosseln · bummern · bumsen · chargieren — 2026-10-15 · deputieren · distinguieren · doktern · downloaden · dräuen · dröseln · eifern · einverleiben · ejakulieren · entblöden · entleiben · entpersönlichen · entrinden · entwanzen · erbittern · erfrechen · erigieren · erkühnen · erotisieren · ertauben · ertüchtigen · eskamotieren · evangelisieren · exmittieren · extemporieren · fächern · fälteln · falzen · ferkeln · feudeln · fiedern · fingern · fixen · flammen · fläzen · fleddern · flennen · flirren · fraktionieren · freveln · frikassieren · frömmeln · frommen · fummeln · furzen — 2026-10-15) | **fusseln** | — |
| ۴. `substantiv_singular_alle.txt` (اسم) | — | Aachen | — |

- ✅ **ترتیب فهرست‌ها (تصمیم Lukas، 2026-09-23):** ۱ صفت‌ها ⇒ ۲ افعال بی‌قاعده ⇒ ۳ افعال باقاعده ⇒ ۴ اسم‌ها. در `tool/naechste_woerter.dart` (`listen`) ثبت است؛ فهرست تمام شد ⇒ ابزار خودش سراغ بعدی می‌رود.
- ✅ **اسم شهرها/کشورها/مکان‌ها (تصمیم Lukas، 2026-09-24):** کارت فقط با **تلفظ (IPA) + معنی (fa/en) + آرتیکل** — بدون مثال، توضیح، مترادف، wortnetz و بقیه. ⚠️ قالب پرامپت و `vokab_schema.dart` فعلاً برای این نوع کارت کوتاه جا ندارند (نبودِ مثال/wortnetz ⇒ هشدار) ⇒ **قبل از اولین اسم خاص**، این نوع کارت در schema و پرامپت تعریف شود (با تأیید Lukas).
- ⛔ **قبل از شروع اسم‌ها (فهرست ۴) حتماً از Lukas بپرس:** اسم‌هایی که آرتیکل ندارند (بیشتر نام شهرها و کشورها، مثل Aachen) چطور ساخته شوند — تصمیم Lukas: «وقتی به اسم‌ها رسیدیم، قبلش دوباره سؤال کن». ⚠️ همان‌جا بپرس: **هم‌نویسه‌ها با همان Wortart** (مثل der See / die See) طبق `vokabId` یک id می‌گیرند و فعلاً فقط یکی ساخته می‌شود — با ⭐ اصل اول (همه ساخته شوند) باید id دوم تعریف شود (تغییر `vokab_schema.dart` ⇒ فقط با تأیید Lukas).
- ✅ **افعال — تصمیم Lukas (2026-10-11، بعد از فاز Q):** (جایگزین «⛔ قبل از شروع افعال» قدیمی؛ پرسش 2026-09-30 جواب گرفت)
  · **گزینه‌ی (ب):** همه‌ی شکل‌های یک فعل روی **یک کارت/صفحه‌ی مصدر**؛ جست‌وجوی **هر** شکل به آن می‌رسد (ging، gegangen، ginge، anzurufen، rief … an، angerufene، hat angerufen، des Anrufens …). شرط Lukas: «مطمئن باش هر نوع شکل پیدا شود» ⇒ قبل از اولین کارت با تست دائمی ثابت شد (پایین).
  · **فعل‌های پیشوندی/جداشدنی = فعل جدا با کارت جدا:** rufen ≠ anrufen، scheiden ≠ entscheiden — هرگز ادغام نمی‌شوند.
  · **شکل با معنای مستقل = کارت جدا** (به نوع کلمه‌ی خودش): اسم مثل die Arbeit (≠ arbeiten)، das Essen (غذا)؛ صفت‌شده‌ها مثل bekannt، spannend، gelassen. کارت فعل فقط در `nominalisierung`/`wortnetz` به آن‌ها اشاره می‌کند. اسم‌ها در نوبت فهرست ۴ کارت می‌گیرند.
  · **پیاده‌سازی (2026-10-11):** پرامپت قاعده‌ی ۱۶ + `konjunktiv1`/`konjunktiv2` (شش شخص) + `modalverb` در details فعل؛ `vokab_schema.dart`: `modalverb` اجباری + هشدار اگر یکی از praesens/praeteritum/konjunktiv1/konjunktiv2/imperativ نباشد؛ `vokab_formen.dart → _verbFormen`: همه‌ی شکل‌های کارت + Partikel+فعل («anrief»)، Partizip I/II با پسوندهای صفت، zu-Infinitiv، Gerundiv، Genitiv مصدر (فقط داده‌ی کارت + قاعده‌ی ثابت، بدون حدس)؛ `vokabSuchSchluessel` (جست‌وجو: کل عبارت ⇒ آخرین+اولین کلمه برای فعل جدا ⇒ تک‌تک کلمه‌ها)؛ `details_renderer.dart`: جدول Konjunktiv I/II و «Modalverb»؛ نماد (Grammatikon) همان قبلی: `trennbar`/`regelmaessig`/`modalverb` ⇒ doppel_kreis/doppel_blob/kreis/blob_wellig/blob_zahnrad.
  · **تست دائمی:** `test/verb_formen_suche_test.dart` — sein، haben، gehen، rufen، anrufen، arbeiten، waschen (reflexiv)، mögen (Modal)، scheiden، entscheiden: هر شکل ⇒ کارت درست؛ پیشوندی‌ها جدا. قرمز شود ⇒ کارت فعل تازه ساخته نمی‌شود.
  · **محدودیت (قاعده‌ی ۳ Lukas: نماد غلط بدتر از نبودن):** شکل‌هایی که نه در کارت هستند نه قاعده‌ی ثابت دارند (قدیمی مثل frug) پیدا نمی‌شوند؛ شکل مشترک چند کلمه (rief ⇒ rufen و anrufen؛ hat ⇒ haben) همه‌ی کارت‌ها را نشان می‌دهد.
  · **ابزار (2026-10-11):** `naechste_woerter.dart → listenLemma`: دو مدخل فهرست افعال توضیح دارند («anbacken, kleben» = معنا، «sein, war, gewesen» = Stammformen) ⇒ کارت به نام بخش قبل از ویرگول (anbacken، sein).
  · ✅ **یکدست‌سازی (2026-10-11):** ۷۶ کارت فعل قدیمی (`assets/vocab/verb/`) `konjunktiv1`/`konjunktiv2`/`modalverb: false` گرفتند (فقط افزودن): K I از ریشه‌ی مصدر، K II فعل‌های باقاعده = Präteritum، بی‌قاعده = ریشه‌ی Präteritum با Umlaut + e (استثناها طبق Duden: nennte، sendete، hülfe، empföhle). اعتبارسنجی رسمی ۷۶/۷۶: ۰ خطا ۰ هشدار. `vokab_schema.dart`: بررسی «کلمه در مثال» برای فعل حالا شکل صرف‌شده را هم می‌شناسد (همان فهرست شکل‌های جست‌وجو) — «Er ging nach Hause» دیگر هشدار نمی‌دهد.
- ⚠️ برای اسم‌ها: `substantiv_singular_alle.txt` بدون آرتیکل است ⇒ genus از `substantiv_singular_der/die/das.txt`؛ نام‌های خاص (شهر/کشور، مثل Aachen) هم در فهرست‌اند — وقتی رسیدیم، همان قاعده‌ی پرامپت (مطمئن نیستی ⇒ نساز) و گزارش به Lukas.
- ✅ **Wortart غلط در فهرست (2026-09-24 دور ۳۴):** aberhundert و abertausend (و عددهای ترتیبی achte، achtzehnte، achtzigste) در Adjektive.txt هستند ولی طبق Duden «unbestimmtes Zahlwort»اند ⇒ کارت در `assets/vocab/numerale/` ساخته شد و در `wortartKorrektur` (`tool/naechste_woerter.dart`) ثبت شد تا ابزار آن‌ها را ساخته‌شده بشناسد. قاعده: Wortart درست (Duden) مهم‌تر از برچسب فهرست است؛ هر مورد تازه همان‌جا ثبت شود. **2026-09-25 دور ۷۱:** andante (نشانه‌ی تمپوی موسیقی) و anderweit (صفتش anderweitig است) ⇒ `assets/vocab/adverb/`. **2026-09-26 دور ۱۳۵:** «blaß» (املای قدیمی) همان id کارت blass را دارد (`vokabId`: ß→ss) ⇒ ابزار آن را ساخته‌شده می‌شمارد؛ کارت جدا لازم نیست. **2026-09-26 دور ۱۱۱:** baldmöglichst (Duden: قید، زبان اداری) ⇒ `assets/vocab/adverb/`. **2026-09-26 دور ۱۵۳:** demgemäß (Duden: قید) ⇒ `assets/vocab/adverb/`. **2026-09-26 دور ۱۶۹–۱۷۱:** dreihundertste، dreißigste، dreiundzwanzigste، dreizehnte، dritte (عدد ترتیبی) ⇒ `numerale`. **2026-09-26 دور ۱۸۲–۱۸۴:** einhunderterste، einhundertste، einunddreißigste، einundzwanzigste (عدد ترتیبی) ⇒ `numerale`. **2026-09-26 دور ۱۸۴–۱۸۸:** einundzwanzigste، elfte ⇒ `numerale`. **2026-09-26 دور ۱۹۹:** erste ⇒ `numerale`. **2026-09-26 دور ۲۲۴:** forte (Duden: adverb) ⇒ `assets/vocab/<wortart>/` + `wortartKorrektur`. **2026-09-26 دور ۲۳۱:** fünfhundertste (Duden: numerale)؛ fünfte (Duden: numerale)؛ fünftel (Duden: numerale)؛ fünfzehnte (Duden: numerale) ⇒ `assets/vocab/<wortart>/` + `wortartKorrektur`. **2026-09-26 دور ۲۳۲:** fünfzigste (Duden: numerale)؛ fürbass (Duden: adverb) ⇒ `assets/vocab/<wortart>/` + `wortartKorrektur`. **2026-09-26 دور ۲۴۳:** gell (Duden: partikel) ⇒ `assets/vocab/<wortart>/` + `wortartKorrektur`. **2026-09-26 دور ۲۶۱:** gratis (Duden: adverb) ⇒ `assets/vocab/<wortart>/` + `wortartKorrektur`. **2026-09-27 دور ۲۹۰:** hunderterste (Duden: numerale)؛ hundertste (Duden: numerale)؛ hundertstel (Duden: numerale)؛ hunderttausendste (Duden: numerale)؛ hundertundzweite (Duden: numerale)؛ hundertzweite (Duden: numerale) ⇒ `assets/vocab/<wortart>/` + `wortartKorrektur`. **2026-09-27 دور ۳۹۰:** milliardste (Duden: numerale)؛ milliardstel (Duden: numerale)؛ millionste (Duden: numerale)؛ millionstel (Duden: numerale) ⇒ `assets/vocab/<wortart>/` + `wortartKorrektur`. **2026-09-27 دور ۴۱۳:** neunte (Duden: numerale)؛ neunzehnte (Duden: numerale)؛ neunzigste (Duden: numerale) ⇒ `assets/vocab/<wortart>/` + `wortartKorrektur`. **2026-09-27 دور ۴۱۹:** nullte (Duden: numerale) ⇒ `assets/vocab/<wortart>/` + `wortartKorrektur`. **2026-10-10 دور ۵۰۷–۵۱۶:** viel، wenig (Duden: numerale unbestimmt)؛ vierte، vierzehnte، vierzigste، viertel (numerale)؛ vorbehaltlich، vorbehältlich (praeposition + Gen)؛ wahrlich (adverb) ⇒ `assets/vocab/<wortart>/` + `wortartKorrektur`. **2026-09-29 دور ۴۶۳:** quadrillionste (Duden: numerale) ⇒ `assets/vocab/<wortart>/` + `wortartKorrektur`. **2026-10-10 دور ۵۱۱:** viel (Duden: Indefinitpronomen/unbestimmtes Zahlwort) ⇒ `assets/vocab/numerale/` + `wortartKorrektur`. **2026-10-11 دور ۵۱۸:** zehntausendste، zehnte (Duden: numerale ordinal)؛ zehntel (numerale bruchzahl) ⇒ `assets/vocab/numerale/` + `wortartKorrektur`. «Y-förmig» همان id کارت y-förmig را دارد (`vokabId` حروف کوچک) ⇒ ساخته‌شده حساب می‌شود. **2026-10-11 دور ۵۲۰:** zwanzigste (Duden: numerale ordinal) ⇒ `assets/vocab/numerale/` + `wortartKorrektur`. **2026-10-11 دور ۵۲۱:** zweihundertste، zweite، zweiundzwanzigste، zwölfte (Duden: numerale ordinal) ⇒ `assets/vocab/numerale/` + `wortartKorrektur`.
- کارت‌های دیگر آرشیو (افعال Dativ و …) از deckها آمده‌اند، نه از این فهرست‌ها. کل آرشیو: **۷۹۶۱ کارت** (2026-10-15).

## INHALTSVERZEICHNIS (فهرست مطالب)

> خودکار از سرتیترهای همین فایل ساخته شد (2026-09-23 دور ۲۵). ✅ = کامل · ⛔ = منسوخ.

- [🚀 قبل از انتشار — فهرست کامل (بازبینی کامل PLAN و MAP، 2026-09-23 دور ۲۵)](#-قبل-از-انتشار--فهرست-کامل-بازبینی-کامل-plan-و-map-2026-09-23-دور-۲۵)
- [⏭️ بعد از انتشار و تصمیم‌های باز](#-بعد-از-انتشار-و-تصمیم‌های-باز)
- [🗂️ فاز F — فیلتر، دسته‌بندی و ترتیب جست‌وجوی Wortschatz (Lukas، 2026-10-14)](#-فاز-f--فیلتر-دسته‌بندی-و-ترتیب-جست‌وجوی-wortschatz-lukas-2026-10-14---طرح-تأیید-شد)
- [🧪 فاز T — آزمون‌ها و نتیجه در Lernpfad (پیش‌نویس، منتظر تصمیم Lukas)](#-فاز-t--آزمون‌ها-و-نتیجه-در-lernpfad-پیش‌نویس-2026-09-25-دور-۸۳---منتظر-تصمیم-lukas-هنوز-هیچ-کدی-ساخته-نشده)
- [🔍 فاز Q — بازبینی کیفیت (Sonnet، 2026-10-11)](#-فاز-q--بازبینی-کیفیت-کارهایی-که-شاید-با-sonnet-انجام-شد-lukas-2026-10-11)
- [📚 روال «ده کلمه جدید» — دیکشنری آنلاین VOX (L.4)](#-روال-ده-کلمه-جدید--دیکشنری-آنلاین-vox-l4)
- [🏁 مرحله‌ی آخر — کلمه‌هایی که وارد اپ نشده‌اند](#-مرحله‌ی-آخر--کلمه‌هایی-که-وارد-اپ-نشده‌اند-آخرین-کلمه‌ها-برای-بررسی-و-انتشار)
- [🔁 مرحله‌ی آخر (۲) — کلمه‌های تکراری/چندنسخه‌ای (L.4d)](#-مرحله‌ی-آخر-۲--کلمه‌های-تکراریچندنسخه‌ای-l4d)
- [🧩 مرحله‌ی آخر (۳) — کلمه‌های رایجِ غایب از فهرست‌ها](#-مرحله‌ی-آخر-۳--کلمه‌های-رایجی-که-در-فهرست‌های-lukas-نیستند-تصمیم-lukas-2026-10-11)
- [🌍 فاز Z — پایان: انتشار روی پلتفرم‌های دیگر (ربات تلگرام ⇒ تبلیغات گوگل ⇒ اندروید/آیفون)](#-فاز-z--پایان-انتشار-روی-پلتفرم‌های-دیگر-تصمیم-lukas-2026-09-24-دور-۶۵)
- [🎯 وضعیت فعلی (2026-09-23)](#-وضعیت-فعلی-2026-09-23)
- [🚀 فاز LAUNCH — ترتیب جدید تا انتشار (تصمیم Lukas، 2026-09-16)](#-فاز-launch--ترتیب-جدید-تا-انتشار-تصمیم-lukas-2026-09-16)
  - [L.1 — امنیت داده‌ی لایتنر (قبل از انتشار)](#l1--امنیت-داده‌ی-لایتنر-قبل-از-انتشار)
  - [L.2 — کامل بودن محتوا (Audit 2026-09-16، Claude، شمارش مستقیم منبع ↔ اپ)](#l2--کامل-بودن-محتوا-audit-2026-09-16-claude-شمارش-مستقیم-منبع--اپ)
  - [L.6 — درس‌های گرامر از کتاب‌های Lukas (باز شد 2026-09-18)](#l6--درس‌های-گرامر-از-کتاب‌های-lukas-باز-شد-2026-09-18)
  - [L.3 — آماده‌سازی انتشار (جایگزین فاز ۱۶ قدیمی که هنوز iOS/Android/RevenueCat دارد)](#l3--آماده‌سازی-انتشار-جایگزین-فاز-۱۶-قدیمی-که-هنوز-iosandroidrevenuecat-دارد)
  - [L.4 — بعد از انتشار: کلمه‌ها، روزانه](#l4--بعد-از-انتشار-کلمه‌ها-روزانه)
  - [L.5 — درخواست‌های جدید Lukas (باز شد 2026-09-17)](#l5--درخواست‌های-جدید-lukas-باز-شد-2026-09-17)
- [فاز P — Profil & Konto (2026-09-20)](#فاز-p--profil--konto-2026-09-20)
- [اطلاعات کلی](#اطلاعات-کلی)
- [STATUS LEGEND](#status-legend)
- [فاز ۰ تا ۱۵ — زیرساخت و ویژگی‌های اصلی ✅](#فاز-۰-تا-۱۵--زیرساخت-و-ویژگی‌های-اصلی-)
- [✅ باگ‌ها (همه بسته)](#-باگ‌ها-همه-بسته)
  - [B-13 ✅ (2026-09-23): کلمه‌ی واژگان در لایتنر دیده نمی‌شد](#b-13--2026-09-23-کلمه‌ی-واژگان-در-لایتنر-دیده-نمی‌شد)
  - [B-1: خطای Flutter — color + decoration در Container ✅](#b-1-خطای-flutter--color--decoration-در-container-)
  - [B-2: خطای SQLite — UNIQUE constraint در words ✅](#b-2-خطای-sqlite--unique-constraint-در-words-)
  - [B-12 ✅ (2026-09-15): پشتیبان فیلدهای گرامری B-10 را نداشت](#b-12--2026-09-15-پشتیبان-فیلدهای-گرامری-b-10-را-نداشت)
  - [B-11 ✅ (2026-09-15): اپ و پشتیبان دو جای متفاوت را می‌خواندند — از دست رفتن ظاهری پیشرفت](#b-11--2026-09-15-اپ-و-پشتیبان-دو-جای-متفاوت-را-می‌خواندند--از-دست-رفتن-ظاهری-پیشرفت)
  - [B-10 ✅ (2026-09-16, CI grün): جدول قدیمی Words — Grammatikfelder nachgetragen](#b-10--2026-09-16-ci-grün-جدول-قدیمی-words--grammatikfelder-nachgetragen)
  - [B-9 ✅ (2026-09-15): دو سیستم رنگ آرتیکل — یکی شد](#b-9--2026-09-15-دو-سیستم-رنگ-آرتیکل--یکی-شد)
  - [B-3: Wortschatz — نمایش کلمه با حرف اضافه در لیست ✅](#b-3-wortschatz--نمایش-کلمه-با-حرف-اضافه-در-لیست-)
  - [B-4: Grammatik home — لینک به صفحه لیست به جای گرامر ✅](#b-4-grammatik-home--لینک-به-صفحه-لیست-به-جای-گرامر-)
- [فاز R — Refactor & UX (فاز جاری — بعد از رفع باگ‌ها)](#فاز-r--refactor--ux-فاز-جاری--بعد-از-رفع-باگ‌ها)
  - [R-1: Wortschatz — نمایش پاک کلمه در لیست](#r-1-wortschatz--نمایش-پاک-کلمه-در-لیست)
  - [R-2: Auswendiglernen — Präpositionen list باید full form نشان دهد](#r-2-auswendiglernen--präpositionen-list-باید-full-form-نشان-دهد)
  - [R-3: Auswendiglernen — ساختار جدید صفحه اصلی](#r-3-auswendiglernen--ساختار-جدید-صفحه-اصلی)
  - [R-3b: Grammatik — لینک‌های موضوعی ✅ (2026-06-29)](#r-3b-grammatik--لینک‌های-موضوعی--2026-06-29)
  - [R-3c: Prüfungen — بخش تمرین‌های موضوعی ✅ (2026-06-29)](#r-3c-prüfungen--بخش-تمرین‌های-موضوعی--2026-06-29)
  - [R-4: Filter / Sort UI — یکپارچه در همه صفحات](#r-4-filter--sort-ui--یکپارچه-در-همه-صفحات)
  - [⭐ اصل معماری پایه: یک محتوا، چند ورودی (Content Once, Many Entrances)](#-اصل-معماری-پایه-یک-محتوا-چند-ورودی-content-once-many-entrances)
  - [🔍 A-1 (باز) — Audit «یک محتوا، چند ورودی» در کل اپ](#-a-1-باز--audit-یک-محتوا-چند-ورودی-در-کل-اپ)
  - [⭐ اصل معماری پایه: Component Isolation (ارجاع‌دهی)](#-اصل-معماری-پایه-component-isolation-ارجاع‌دهی)
  - [R-5: دکمه‌ها و UI یکپارچه (Design System)](#r-5-دکمه‌ها-و-ui-یکپارچه-design-system)
  - [فاز B — Buttons: Puzzling-Prinzip ✅ (2026-07-07)](#فاز-b--buttons-puzzling-prinzip--2026-07-07)
  - [R-6: دوزبانه — Audit کامل (FA + EN) ✅ (2026-06-30)](#r-6-دوزبانه--audit-کامل-fa--en--2026-06-30)
  - [R-7: جداسازی محتوا از UI (Content Files)](#r-7-جداسازی-محتوا-از-ui-content-files)
- [فاز ۱۶ — انتشار و QA نهایی ⛔ منسوخ](#فاز-۱۶--انتشار-و-qa-نهایی--منسوخ)
- [ترتیب اجرا — Phase‌های بهینه](#ترتیب-اجرا--phase‌های-بهینه)
  - [Phase 1 — باگ‌های فوری ✅ (2026-06-29)](#phase-1--باگ‌های-فوری--2026-06-29)
  - [Phase 2 — Design System ✅ (2026-06-29)](#phase-2--design-system--2026-06-29)
  - [Phase 3 — Filter Components ✅ (2026-06-29)](#phase-3--filter-components--2026-06-29)
  - [Phase 4 — Content Screens با Filter جدید ✅](#phase-4--content-screens-با-filter-جدید-)
  - [Phase 5 — Auswendiglernen Restructure ✅ (2026-06-29)](#phase-5--auswendiglernen-restructure--2026-06-29)
  - [Phase 6 — Data & Content Files ✅ (2026-06-29)](#phase-6--data--content-files--2026-06-29)
  - [Phase 7 — Bilingual Audit ✅ (2026-06-30)](#phase-7--bilingual-audit--2026-06-30)
  - [فاز DS — Design System — یک بار برای همیشه](#فاز-ds--design-system--یک-بار-برای-همیشه)
  - [فاز ARCH — Architecture Hub — زیرساخت مرکزی (2026-07-04)](#فاز-arch--architecture-hub--زیرساخت-مرکزی-2026-07-04)
  - [Phase 14 — Modalverben ✅ (2026-07-04)](#phase-14--modalverben--2026-07-04)
  - [Phase 15 — Grammatik-Themen (generisch) ✅ (2026-07-05)](#phase-15--grammatik-themen-generisch--2026-07-05)
  - [فاز G — Grammatik Vollausbau (تمام گرامر زبان آلمانی) [G1–G6 ✅]](#فاز-g--grammatik-vollausbau-تمام-گرامر-زبان-آلمانی-g1g6-)
  - [فاز V — Vokabular-Datenbank (آرشیو بزرگ ~۲۶٬۰۰۰ کلمه) [طراحی نهایی ✅ / پیاده‌سازی باز] (2026-07-08)](#فاز-v--vokabular-datenbank-آرشیو-بزرگ-۲۶۰۰۰-کلمه-طراحی-نهایی---پیاده‌سازی-باز-2026-07-08)
  - [فاز S — Speicherung der Nutzerdaten [باز شد 2026-09-15]](#فاز-s--speicherung-der-nutzerdaten-باز-شد-2026-09-15)
  - [فاز A — Automatisierung der Worterfassung [باز شد 2026-09-15]](#فاز-a--automatisierung-der-worterfassung-باز-شد-2026-09-15)
  - [فاز L — L10n: زبان فقط از Settings [Step 1 ✅ Audit — 2026-07-07]](#فاز-l--l10n-زبان-فقط-از-settings-step-1--audit--2026-07-07)
  - [فاز L2 — Massen-Lokalisierung: «هیچ FA در حالت EN» [L2-A..E ✅ / L2-F باز] (2026-07-07)](#فاز-l2--massen-lokalisierung-هیچ-fa-در-حالت-en-l2-ae---l2-f-باز-2026-07-07)
  - [فاز L3 — Content-Zweisprachigkeit: همه محتواها FA+EN [کامل ✅] (2026-07-07)](#فاز-l3--content-zweisprachigkeit-همه-محتواها-faen-کامل--2026-07-07)
  - [Phase 13 — Redemittel 1010 ✅ (2026-07-04)](#phase-13--redemittel-1010--2026-07-04)
  - [Phase 12 — Unregelmäßige Verben ✅ (2026-07-03)](#phase-12--unregelmäßige-verben--2026-07-03)
  - [Phase 11 — Verben mit Präpositionen ✅ (2026-07-03)](#phase-11--verben-mit-präpositionen--2026-07-03)
  - [Phase 10 — Trennbare / Untrennbare Verben ✅ (2026-07-03)](#phase-10--trennbare--untrennbare-verben--2026-07-03)
  - [Phase 9 — Reflexivverben ✅ (2026-07-03)](#phase-9--reflexivverben--2026-07-03)
  - [Phase 8 — انتشار (فاز ۱۶) ⛔ منسوخ](#phase-8--انتشار-فاز-۱۶--منسوخ)
- [فازهای تکمیل‌شده (آرشیو)](#فازهای-تکمیل‌شده-آرشیو)
- [تصمیمات تکنیکی](#تصمیمات-تکنیکی)

---

# پلن کامل صفر تا انتشار اپ یادگیری آلمانی برای فارسی‌زبانان

# آپدیت: 2026-09-23

---

## 🎯 وضعیت فعلی (2026-09-23)
| فاز | وضعیت | خلاصه |
|-----|-------|-------|
| **G — Grammatik Vollausbau** | G1–G6 ✅ · G7a–G7c ✅ / G7d، G7e، G8 باز | کاتالوگ ۹۳ موضوع + LektionScreen live (**۸۴ درس**، 2026-09-16)؛ نقشه: `GRAMMATIK_MAP.md` |
| **B — Buttons (Puzzling)** | ✅ | همه دکمه‌ها reference به `vox_button.dart`؛ ۰ دکمه خام؛ همه quiz options → VoxOptionButton |
| **L — L10n: زبان فقط از Settings** | ✅ | ۶ سوییچ حذف، Dual-Display صفر، AppL10n تنها منبع |
| **L2 — Massen-Lokalisierung** | ✅ | ۶۴۱→۴۱ رشته FA در UI (کاتالوگ ۵۳۷=۵۳۷)؛ باقی در L3 |
| **L3 — Content-Zweisprachigkeit** | ✅ | **همه محتواها FA+EN** (JSON + صفحات + دیتابیس)؛ audit ۰؛ کاتالوگ ۵۶۵=۵۶۵؛ helper AppL10n.loc؛ MemorizeItems.meaningEn (schema v2) |
| **P — Profil & Konto** | ✅ P.1–P.3 (2026-09-20، CI سبز) — بازبینی چشمی از Lukas مانده | صفحه‌ی `/more/profil`: حساب + امنیت + اطلاعات شخصی + آرشیو + پشتیبان؛ قرارداد v4؛ **حذف حساب ✅ L.1d (2026-09-22)** |
| **V — Vokabular-DB (۲۵٬۰۰۰ کلمه)** | Stufen ۱–۵ ✅ · **۸۷ کارت** (۰٫۳٪ از ~۲۶٬۲۰۰) · گلوگاه = سرعت، نه کد | Pipeline کامل و سالم: SUPER-PROMPT v3.0 → `import_inbox/` → `tool/vokabular_import.dart` → اپ. از ۱۴ جولای تا ۱۵ سپتامبر (۲ ماه) فقط چند کلمه اضافه شد ⇒ **فاز A (خودکارسازی) باز شد.** V.2 ✅ (فهرست کلمات به‌جای vocab.db، 2026-09-16) · اتصال Leitner به imLeitner ✅ B-13 (2026-09-23) · V.5 توزیع |
| ~~۱۶ — انتشار و QA نهایی~~ | ⛔ منسوخ — فهرست معتبر: **L.3** | نسخه‌ی بومی (iOS/Android/RevenueCat) از 2026-09-13 حذف شد؛ انتشار = فقط وب (GitHub Pages) |

**کارهای انجام‌شده و قدم‌های بعدی:** بالای همین فایل («⏭️ کارهای باز» و «📜 کارنامه»).

---

## 🚀 فاز LAUNCH — ترتیب جدید تا انتشار (تصمیم Lukas، 2026-09-16)
> **تصمیم:** اپ **زودتر** و به‌صورت **نسخه‌ی نهایی** در دسترس کاربران قرار می‌گیرد. **کلمه‌ها آخرین مرحله‌اند**
> (زمان‌برترین بخش) و **بعد از انتشار، هر روز مقداری کلمه اضافه می‌شود.** همه‌ی بخش‌های دیگر هنگام انتشار
> **کامل‌اند** — مخصوصاً ردمیتل‌ها و هر چیزی که از جزوه‌های خود Lukas وارد اپ شده.
> **شرط سخت:** حساب/داده‌ی کاربر نباید در معرض پاک شدن اطلاعات لایتنر باشد — نه با آپدیت اپ، نه با
> اضافه شدن کلمه‌ها، نه با همگام‌سازی.
> ترتیب اجرا: **L.1 → L.2 → L.3 → انتشار → L.4 (کلمه‌ها، روزانه)**

### L.1 — امنیت داده‌ی لایتنر (قبل از انتشار)
- [x] **S.6** شناسه‌ی ثابت برای لیست‌های شخصی ✅ (2026-09-16، CI سبز) — تغییر نام یک لیست دیگر
- [x] **V.2** ✅ (2026-09-16) — اپ در شروع فقط `assets/vocab_index.json` را می‌خواند؛ کارت کامل هنگام باز شدن صفحه‌ی کلمه. جزئیات: فاز V → V.2.
- [x] **L.1a نگهبان شناسه‌ی کارت** ✅ (2026-09-16) — CI شناسه‌ها را با **سایت زنده** مقایسه می‌کند؛ شناسه‌ی منتشرشده گم شود ⇒ قرمز و چیزی منتشر نمی‌شود (`tool/vokab_ids_pruefen.dart`، `test/vokab_ids_waechter_test.dart`).
      ⚠️ **بدون فهرست استثنا:** کارت غلط **اصلاح** می‌شود، حذف نه. حذف واقعی فقط با قاعده‌ی کوچ (شناسه‌ی قدیم → جدید) و تصمیم Lukas.
- [x] **L.1b تست مهاجرت** ✅ (2026-09-16) — هر نسخه‌ی قدیمی DB (۲ به بعد) با داده‌ی واقعی لایتنر به نسخه‌ی فعلی می‌رسد و با `SchemaVerifier` بررسی می‌شود (`test/migration_test.dart`؛ اسکیماهای قدیمی را `build-runner.yml` خودکار می‌سازد).
      ⚠️ **قاعده:** هر تغییر اسکیمای drift ⇒ `schemaVersion` بالا + migration + اجرای `build-runner.yml` روی شاخه.
- [x] **L.1c** ✅ (2026-09-18، Lukas) — Secrets `SUPABASE_URL`/`SUPABASE_ANON_KEY` در ریپو + اجرای `supabase/vox_tables.sql` روی سرور (ref `uayaomoxxzzbjquxbcpu`).
- [x] **L.1d حذف حساب** ✅ 2026-09-22 — تصمیم Lukas: **بله، برای هر دو اپ** (یک حساب مشترک ⇒ یک حذف). `delete_own_account()` در `vox_tables.sql` (هم‌متن Root-in) + `AuthService.deleteAccount()` + دکمه در `ProfilKontoKarte` + fallback `CloudAblage.loeschen()`. …
- [x] **L.1e نگهبان کلمه‌های همراه اپ** ✅ (2026-09-18) — ۱٬۰۱۶ شناسه‌ی `<german>|<wordType>` در `test/daten/seed_schluessel_veroeffentlicht.txt`؛ گم شدن یکی ⇒ تست قرمز. فرمول فقط در `seed_wortschluessel.dart`؛ ثبت کلمه‌ی تازه با …

### L.2 — کامل بودن محتوا (Audit 2026-09-16، Claude، شمارش مستقیم منبع ↔ اپ)
> **Lukas 2026-09-16:** «منابع همه‌چیز با من است، برنامه‌نویسی با تو.» ⇒ برای هر مورد باز پایین (گرامر، ÖSD C1، deckها و …)، وقتی نوبتش رسید **منبع را از Lukas بخواه** (هر قالبی: Excel، CSV، JSON، Word، PDF) — نه حدس. ⚠️ **استثنا: کارت‌های کلمه** — آن‌ها را Claude طبق پرامپت می‌سازد (فاز A / A.6).
- ✅ **کامل نسبت به منبع** (`old files Lukasalmani/1/` ↔ `assets/data/`):
      Redemittel 1010 **۹۰۸/۹۰۸** (منبع خودش ۹۰۸ عبارت دارد، نه ۱۰۱۰؛ ۹۳ بخش) · Goethe B2 ۶۱/۶۱ ·
      ÖSD B2 ۱۲۱/۱۲۱ · Konnektoren ۱۸۶/۱۸۶ · NVV ۳۴۶/۳۴۶ · Präpositionen ۱۸۵/۱۸۵ · Dativ/Akkusativ ۱۱۰/۱۱۰
- [x] **L.2a ÖSD C1** ✅ (2026-09-18) — `redemittel_oesd_c1.json` با ۱۱۲ عبارت از PDF Lukas؛ deck زنده.
- [x] **L.2b** ✅ تصمیم Lukas (2026-09-16): کلمه‌های A1/A2 جزوه‌ها جزو فاز کلمه‌ها (L.4)؛ قبل از انتشار فقط چند کارت نمونه (روش: A.6).
- [x] **L.2c گرامر** ✅ (2026-09-16) — هر ۸۴ درس زنده (G3–G6)؛ بازبینی مستقل: از منبع چیزی کم نیست (`GRAMMATIK_MAP.md`).
- [~] **L.2e تمرین‌ها** — G7a–G7c ✅؛ **G7d/G7e بعد از انتشار** (تصمیم Lukas 2026-09-18). ترتیب: گرامر ✅ → تمرین گرامر ✅ → انتشار → G7d/G7e → کلمه‌ها → تمرین کلمه‌ها.
- [x] **L.2d — تصمیم Lukas (2026-09-23 دور ۱۵):** deckهای بی‌محتوا **پنهان نمی‌شوند** — با دکمه‌ی قفل «به‌زودی» (R-3.3) می‌مانند
      ⚠️ شرط Lukas برای هر پرکردنِ بعدی: به‌روزرسانی هرگز داده‌ی کاربر را پاک نکند ⇒ همان نگهبان‌های L.1 (شناسه‌ها، مهاجرت، پشتیبان).
- [~] **L.2d deckهای «به‌زودی» بدون محتوا (بعد از انتشار):** relativsatz · da_praepositionen · adjektive ·
      adjektivdeklination · tempusformen (⚠️ `tempusformen_grammar.json` موجود است ولی deck خاموش) ·
      oesd_c1 · zusammenfassung · a2_zusammenfassung · feature.sprechen · feature.schreiben
      ⇒ برای هر کدام: منبع از Lukas ← ساخت، یا قبل از انتشار **پنهان** (`FeatureFlags`) — نسخه‌ی نهایی
      دکمه‌ی «به‌زودی» ندارد. **فهرست را با Lukas مرور کن.**
      ⏳ **جریان کار (از 2026-09-18):** **ÖSD C1 ✅ انجام شد.** درخواست باز بعدی = یکی از deckهای باقی‌مانده
      (relativsatz، da_praepositionen، adjektive، adjektivdeklination، tempusformen، zusammenfassung،
      a2_zusammenfassung، feature.sprechen، feature.schreiben) — منتظر منبع بعدی از Lukas. وقتی فایلش رسید:
      ساخت + تست + انتشار، بعد منبع **بعدی** خواسته می‌شود. deckی که تا انتشار منبع نگیرد، قبل از انتشار **پنهان** می‌شود (`FeatureFlags`) —
      نسخه‌ی نهایی دکمه‌ی «به‌زودی» ندارد. ⚠️ این تنها کار باز L.2 است؛ کار بعدی Claude **L.3** است.
      🔎 **Audit کد (Claude، 2026-09-19) — وضعیت واقعی هر ۹ مورد، برای تصمیم Lukas (فقط واقعیت، نه تصمیم):**
      · **tempusformen:** محتوا هست و **در Grammatik زنده است** (`tempusformen-ueberblick` ← `/grammatik/thema/tempusformen`،
        ۴ بخش، سطح B2، `assets/data/tempusformen_grammar.json`). ولی deck «Tempusformen» در Auswendiglernen (برچسب سطح **C2**)
        محتوای خودش را ندارد و به همان صفحه هم وصل نیست. گزینه‌ها: پنهان‌کردن، یا وصل‌کردن به همان صفحه (اصل «یک محتوا، چند
        ورودی»). ⛔ تصمیم با Lukas — و برچسب C2 deck با سطح B2 محتوا نمی‌خواند.
      · **relativsatz · da_praepositionen · adjektive · adjektivdeklination · zusammenfassung · a2_zusammenfassung:** برای deck
        فایل داده و route اختصاصی در Auswendiglernen/Prüfungen **وجود ندارد**. ولی در کاتالوگ **گرامر** دو موضوعِ مرتبط درس دارند:
        `relativpronomen-relativsaetze` و `adjektivdeklination` — یعنی این deckها «در حفظی» همان موضوع‌اند، نه موضوعِ بدون محتوا.
        (برای «adjektive» اسلاگ جدا در کاتالوگ نیست؛ فایل `grammatik/adjektive.json` هست ولی درس‌هایش را بررسی نکردم.)
      · **feature.sprechen / feature.schreiben:** `sprechen_home_screen.dart` و `schreiben_home_screen.dart` **stub**اند (۴۳ خط، فقط
        چیپ «به‌زودی») و از **کاشی صفحه‌ی اصلی** باز می‌شوند — یعنی الان کاربر آخر مسیر یک صفحه‌ی خالی می‌بیند.
      🔧 **مکانیزم «پنهان‌کردن» کار نمی‌کرد — درست شد (2026-09-19):** `FeatureState.hidden` تعریف شده بود ولی **هیچ صفحه‌ای آن را
      نمی‌خواند**، و کاشی‌های Sprechen/Schreiben اصلاً فلگ را نمی‌خواندند ⇒ «قبل از انتشار پنهان کن» یک تغییر یک‌خطیِ **بی‌اثر** بود.
      حالا: `FeatureFlags.isHidden/isVisible/resolve/keys` · `auswendiglernen_home_screen.dart` هر دو فهرست را با `isVisible` فیلتر
      می‌کند · `home_screen.dart` کاشی‌های Sprechen/Schreiben را با `feature.sprechen`/`feature.schreiben` شرطی کرد · نگهبان
      `test/feature_flags_test.dart`. ⚠️ **رفتار امروز عوض نشد** (هیچ فلگی `hidden` نشد؛ تصمیمش با Lukas است). با پنهان‌شدن
      Sprechen+Schreiben شبکه‌ی خانه ۱۰ کاشی می‌شود (۳ ستون ⇒ ردیف آخر ناقص) — تصمیم ظاهری هم با Lukas.

### L.6 — درس‌های گرامر از کتاب‌های Lukas (باز شد 2026-09-18)
> **جریان کار:** Lukas درس‌ها را **به ترتیب کتاب** می‌فرستد. شماره‌گذاری او با شماره‌ی درس‌های اپ **یکی نیست** —
> Claude خودش درس کتاب را به `slug` درست اپ وصل می‌کند و در جدول زیر ثبت می‌کند (این جدول = حافظه‌ی این مرحله؛
> نسخه‌ی کامل‌تر با توضیح در `GRAMMATIK_MAP.md`).
> ⚠️ **کپی‌رایت — قاعده‌ی ثابت:** هیچ جمله، تمرین یا جدولی از کتاب **کپی نمی‌شود**. از کتاب فقط **موضوع و دامنه**
> گرفته می‌شود؛ توضیح‌ها، مثال‌ها و تمرین‌ها را Claude از نو و با واژه‌های خودش می‌نویسد (اسم‌ها و جمله‌ها هم
> عوض می‌شوند). «کمی تغییر دادن» کافی نیست و انجام نمی‌شود.
> ⚠️ محتوا همیشه سه‌زبانه (DE/FA/EN) و در همان فایل `assets/data/grammatik/<thema>.json` درسِ مقصد.
> تمرین‌های خود کتاب هم به همین شکل: موضوعشان الگو می‌شود، جمله‌هایشان از نو نوشته می‌شود.

| # کتاب | کتاب | موضوع درس | درس اپ (slug) | چه اضافه شد | تاریخ |
|---|---|---|---|---|---|
| ۱ | Grammatik aktiv | Personalpronomen (ich…Sie، ضمیر برای اشیاء، du/ihr/Sie) | `personalpronomen` (درس ۱۸ اپ، A1) | ۲ بلوک توضیح (شخص/شمار/خطاب · ضمیر اشیاء) · ۲ جدول (Nominativ؛ آرتیکل ⇒ ضمیر) · ۴ مثال · ۶ تمرین (`ex-pers-5…10`) | 2026-09-18 ✅ |
| ۲ | Grammatik aktiv | Konjugation Präsens (پایانه‌های فعل، استثنا: ریشه با -t/-d نیاز به -e- اضافه، ریشه با -s/-ß/-z/-x فقط -t برای du) | `konjugation-praesens` (درس در `verben-grundlagen.json`، A1) | ۱ بلوک توضیح تازه (block-2) · ۱ جدول (arbeiten) · ۲ مثال (`ex-7`,`ex-8`) · ۳ تمرین تازه (`ex-konjugation-5…7`) — همه از نو نوشته‌شده | 2026-09-18 ✅ |

⚠️ درس اپ از قبل بخش Akkusativ/Dativ را داشت؛ درس کتاب پایه‌ی A1 را اضافه کرد — چیزی حذف یا بازنویسی نشد.
شمار تمرین‌ها: ۳۳۶ (منبع قدیمی) + ۶ (personalpronomen) + ۳ (konjugation-praesens) = **۳۴۵**؛ آزمون سطح A1 هم ۵ تمرین بیشتر دارد (transform در آزمون نمی‌آید).

### L.3 — آماده‌سازی انتشار (جایگزین فاز ۱۶ قدیمی که هنوز iOS/Android/RevenueCat دارد)
- [x] **L.3a زبان شروع** ✅ (2026-09-16) — پیش‌فرض انگلیسی؛ فقط اگر زبان دستگاه فارسی باشد (`fa`/`fa-AF`/`prs`) فارسی. انتخاب کاربر در Settings برنده است.
      ⚠️ تنها منبع: `core/l10n/geraete_sprache.dart` — هیچ جای دیگری `'fa'` را پیش‌فرض نکند.
- [x] **اصلاح README** ✅ (2026-09-18) — خط قدیمی «Selbstlernen — Gewohnheiten, Streaks» (از 2026-09-13 غلط
- [x] **آیکون و manifest وب** ✅ (بررسی 2026-09-18) — `web/manifest.json` و `web/index.html` از قبل کامل
- [x] **صفحه‌ی حریم خصوصی** ✅ (2026-09-18) — متن با وضعیت واقعی به‌روز شد (حساب اختیاری + پشتیبان Supabase)؛ بخش «حذف حساب» 2026-09-22.
- [x] **تست RTL همه‌ی صفحات** ✅ (2026-09-18، Lukas تأیید کرد) — ویجت مشترک `DeutschText` (ltr + left ثابت) برای هر متن آلمانی + جاروی کامل + نگهبان تست.
      ⚠️ **تکمیل (2026-09-23 دور ۲۲):** `DeutschText`/`KlickWortText` در RTL کل خط را می‌گیرند و چپ می‌ایستند (`deutschLinksbuendig`)؛ جایی که متن نباید به لبه‌ی چپ برود (عنوان AppBar، چیپ، کارت وسط‌چین) ⇒ `ganzeZeile: false`. جدول کاملاً آلمانی ⇒ `Directionality(ltr)`.
      ⚠️ **قاعده:** هر متن آلمانی ⇒ `DeutschText`. در بازبینی **همه‌ی** `Text(`های هر فایل یکی‌یکی چک شوند، نه فقط جای گزارش‌شده.
- [x] **L.3b کرش شروع با زبان نامعتبر مرورگر** ✅ (2026-09-23 دور ۱۴)
      ⚠️ اگر روزی Flutter خودش این را درست کرد، نگهبان بی‌ضرر می‌ماند (برای زبان معتبر کاری نمی‌کند).
- [x] **تست آفلاین — علت پیدا و رفع شد ✅ (2026-09-24 دور ۳۳)؛ Lukas روی مک تأیید کرد ✅ — اخبار آفلاین طبق طراحی فقط از cache قبلی**
      **شواهد (DevTools، Lukas 2026-09-24):** Service workers خالی · «No cache storage detected».
      **علت (در سورس Flutter 3.44.6 تأیید شد):** (۱) `flutter_bootstrap.js` هنوز `flutter_service_worker.js` را ثبت می‌کرد،
      ولی این فایل در 3.44 فقط یک worker پاک‌کننده است: هنگام activate خودش را unregister می‌کند و هیچ cache نمی‌سازد
      (Flutter آن را deprecated کرده). (۲) CanvasKit به‌طور پیش‌فرض از `www.gstatic.com` می‌آمد ⇒ بدون اینترنت Engine هرگز بالا نمی‌آمد.
      **رفع ماندگار:** `deploy-web.yml` ⇒ `--pwa-strategy=none --no-web-resources-cdn` · worker خودمان `vox_sw.js` با **Workbox 7.4.1**
      (پین در `tool/pwa/package-lock.json`)، ثبت در `web/index.html`. تقسیم (تنها منبع: `tool/pwa/workbox_config.cjs`):
      **پیش‌بارگذاری** همه‌ی چیزهایی که با آرشیو کلمه رشد نمی‌کنند (کد، CanvasKit هر دو نسخه‌ی Chrome/Safari، محتوا، تصویرها،
      فونت‌ها، فهرست کلمات؛ ~۲۸MB، هر فایل با revision ⇒ در deploy بعدی فقط فایل‌های عوض‌شده دوباره دانلود می‌شوند) ·
      **هنگام استفاده** کارت‌های کلمه و `vocab_formen` (StaleWhileRevalidate، cache `vox-woerter`) — همان تحلیل 2026-09-19 ·
      Supabase و سرورهای بیرونی هرگز cache نمی‌شوند. نسخه‌ی جدید فقط وقتی همه‌ی پنجره‌های VOX بسته شدند فعال می‌شود (هرگز کد قدیم + فایل جدید).
      **نگهبان‌ها در deploy (قرمز ⇒ بدون انتشار):** `tool/pwa/sw_bauen.cjs` (پرچم‌های build، هیچ هشدار Workbox، فایل‌های اجباری در بسته) ·
      `tool/pwa/offline_test.cjs` در Chrome واقعی: آنلاین باز ⇒ Offline + بارگذاری دوباره ⇒ همه‌ی فایل‌های بسته آفلاین ⇒ پنجره‌ی تازه آفلاین.
      روی خروجی واقعی Pages (artifact 2026-09-24) در Chromium محلی: هر چهار مرحله سبز (۷۷ فایل).
      ⚠️ **بعد از رفع:** بار اول بعد از این deploy اپ باید یک بار **آنلاین** باز شود تا worker نصب شود؛ کارتی که هیچ‌وقت باز نشده آفلاین نمی‌آید (عمداً).
      سابقه‌ی پیش از رفع:
      **نشانه‌ها:** (۱) اپ باز و همه‌ی صفحه‌ها بارگیری‌شده ⇒ قطع اینترنت مشکلی ندارد. (۲) اپ باز ولی صفحه‌ی
      تازه ⇒ محتوا نمی‌آید («تعداد کلمات صفر»). (۳) اپ بسته + اینترنت قطع + باز کردن ⇒ خطا و درخواست اینترنت.
      یعنی عملاً Service-Worker یا نصب نشده یا فایل‌های `assets/` را نگه نمی‌دارد.
      **آنچه بررسی شد:** حجم کل `assets/` فقط **۷٫۵ مگابایت** است (data 4.3 · images 2.6 · vocab 0.36 ·
      fonts 0.24) ⇒ ادعای قدیمیِ «~۱۰۰ مگابایت، پیش‌بارگذاری ممکن نیست» (خط ۱۲۳۵ همین فایل) **دیگر درست
      نیست**؛ precache کاملاً شدنی است — **ولی فقط برای همین ~۷٫۵MB فعلی (۸۷ کارت).**
      ⚠️ **اصلاح (2026-09-19، از اعداد خود PLAN):** میانگین کارت ≈ ۴KB (A.6) ⇒ ~۲۶٬۲۰۰ کارت ≈ **~۱۰۰MB**. پس «باطل شد» فقط برای امروز درست بود؛
      پیش‌بارگذاری **همه‌ی** کارت‌های کلمه بعد از رشد آرشیو همچنان گزینه نیست (همان چیزی که V.2 هم نوشته). آنچه شدنی است:
      precache دارایی‌های ثابت (+ فهرست کلمات) و ذخیره‌ی هر کارت هنگام باز شدن. این فقط تحلیل است، نه تصمیم — رفع بعد از دیدن خروجی DevTools. کلمه‌ها هم از `rootBundle` می‌آیند (`vokabular_controller.dart`)،
      نه از شبکه‌ی بیرونی — پس با SW درست باید آفلاین کار کنند. `deploy-web.yml` هم `flutter build web`
      استاندارد است (بدون `--pwa-strategy=none`).
      ⛔ **چرا هنوز رفع نشده:** Claude در این محیط مرورگر ندارد و `*.github.io` هم خارج از allowlist شبکه
      است، پس نمی‌تواند ببیند SW اصلاً ثبت شده یا نه. حدس‌زدن و «وصله‌ی آزمایشی» خلاف قاعده‌ی ۵ است.
      **نیاز از Lukas:** خروجی DevTools (Application → Service Workers + Cache Storage).
      ⏸️ **معلق (2026-09-18):** Lukas فعلاً به کامپیوتر دسترسی ندارد ⇒ این کار تا رسیدن آن شواهد **بلوکه**
      است و Claude سراغ کار بعدیِ بدون‌وابستگی رفت (جاروی RTL).
- [~] **L.3c باز شدن به‌عنوان Telegram Mini App** — Claude ✅ (2026-09-24 دور ۶۴)؛ ⏭️ تأیید Lukas در تلگرام
      **علت:** تلگرام `#tgWebAppData=…&tgWebAppVersion=…` (یا `#/pfad?tgWebAppData=…`) به آدرس اضافه می‌کند؛ VOX با hash-URL کار می‌کند ⇒ go_router آن را مسیر می‌خواند ⇒ «GoException: no routes for location».
      **رفع ماندگار:** `web/telegram_guard.js` در `web/index.html` بعد از `locale_guard.js` و قبل از `flutter_bootstrap.js`. فقط اگر آدرس `tgWebAppData` دارد: (۱) SDK رسمی
      `telegram-web-app.js` همزمان (document.write) — **قبل** از پاک‌کردن، چون SDK داده‌ها را خودش از hash می‌خواند (`Telegram.WebApp.initData`)؛ (۲) `history.replaceState` ⇒ بدون hash (یا `#/pfad` اگر مسیری جلوی آن بود).
      **چرا SDK فقط در تلگرام:** یک script همزمان از telegram.org در هر شروع، VOX را تا جواب telegram.org نگه می‌داشت — آفلاین و جایی که telegram.org فیلتر است، خیلی طولانی.
      **Dart:** `Uri.base` فقط در `main.dart` برای لینک ایمیل Supabase (`anmelde_ruecklauf.dart`)؛ هیچ داده‌ی کاربر تلگرام از آدرس خوانده نمی‌شود ⇒ تغییری لازم نبود. ⚠️ اگر روزی داده‌ی تلگرام لازم شد: فقط `Telegram.WebApp.initData` (و بررسی در سرور)، هرگز آدرس.
      **نگهبان در deploy:** `offline_test.cjs` مرحله‌ی ۵ — `#tgWebAppData=…`، `#/wortschatz?tgWebAppData=…`، `#/`، `#/wortschatz` هر کدام در پنجره‌ی تازه؛ GoException یا آدرس غلط ⇒ قرمز ⇒ بدون انتشار.
- [x] **(Lukas)** تست روی آیفون واقعی (Safari + افزودن به صفحه‌ی اصلی) ✅ 2026-09-23 — هر ۱۴ مرحله سبز؛ تنها یافته B-13 (رفع شد، Lukas روی آیفون تأیید کرد). باز شدن در حالت هواپیما روی آیفون ✅ — تست آفلاین کامل (DevTools) هنوز باز است.

### L.4 — بعد از انتشار: کلمه‌ها، روزانه
- ⏭️ **R-2.2 هم اینجاست** (2026-09-22): deckهای Auswendiglernen یکی‌یکی ⇒ هر کلمه کارت و صفحه‌ی خودش (⭐ اصل اول)؛ NVV/Redemittel ⇒ کارت عبارت (L.4c). برنامه: فاز R → «R-2.2 — برنامه». کارت‌های Auswendiglernen هرگز کم نمی‌شوند.
- [x] **L.4b / L.4b-2 (دور ۵۴ و ۵۶) — ⚠️ از 2026-09-24 دور ۶۳ با ⭐ اصل اول منسوخ.** آن‌موقع کارت کلمه‌ای که از قبل در اپ بود (۷۵+ کلمه: افعال Dativ/Akkusativ، weil، «warten auf»، «vertrauen auf/in» …) **به‌جای** صفحه‌ی خودش زیر صفحه‌ی قبلی می‌آمد و ردیفش پنهان بود.
      **حالا (دور ۶۳):** کارت همیشه صفحه (`wort_seite_screen.dart`، بدون هدایت) و ردیف خودش (`wortschatz_list_screen.dart`، بدون پنهان‌کردن) را دارد؛ شمارنده‌ی `wortschatz_home_screen.dart` همه را می‌شمارد. نمایش **اضافه**ی کارت زیر صفحه‌ی قبلی (`word_detail_screen.dart` → `_KartenErweiterung`) ماند — هیچ چیز حذف نشد.
      کد جفت‌کردن (فقط برای همین نمایش اضافه + فهرست L.4d): `features/wortschatz/data/altwort_karte.dart` (+ `controllers/altwort_karte_provider.dart`، `vokabular/widgets/wort_karte_inhalt.dart`). نگهبان: `test/altwort_karte_test.dart` (+ تست «Grundregel»). جزئیات قدیم: `git show be0c77d:PLAN.md`.
- [ ] **L.4c کارت عبارت (NVV، Redemittel) — بعد از وارد شدن همه‌ی کلمه‌ها (Lukas، 2026-09-24).** روش: R-2.2 تصمیم ۳ (پرامپت عبارت، `bestandteile` ⇒ لینک به کارت کلمه‌ها). مثل همه: کارت عبارت صفحه‌ی **جدید** خودش را می‌گیرد؛ صفحه‌ی قدیمی عبارت دست نمی‌خورد؛ فقط افزودن. ⛔ پیش‌نویس پرامپت عبارت + تغییر schema اول به Lukas نشان داده شود.
- [ ] **L.4d تکراری‌ها — آخرین مرحله (Lukas، 2026-09-24 دور ۵۷/۶۳)** — Claude: فقط **پیدا کردن و فهرست کردن**؛ Lukas: **تصمیم**. جزئیات: «🔁 مرحله‌ی آخر (۲)» ته همین فایل.
- [x] روش ساخت ⇒ **تصمیم Lukas (2026-09-23): Claude خودش طبق Wort prompt می‌سازد، هر بار ۱۰ کلمه با دستور «ده کلمه جدید وارد کن»** — روال: بخش «📚 روال ده کلمه جدید». (سابقه‌ی A.6: (گزینه‌ی مطرح‌شده 2026-09-16: API با
      حدود ۵۰ یورو در ماه، اعتبار پیش‌پرداخت بدون شارژ خودکار، ترجیحاً Batch — هنوز تأیید نشده)

### L.5 — درخواست‌های جدید Lukas (باز شد 2026-09-17)
- 🔎 **یافته‌ها — بازبینی کد 2026-09-22 (دور ۲)؛ فقط ثبت، تصمیم با Lukas:**
  · **«favorit» در اپ وجود ندارد.** R-1.2 آن را خواسته بود؛ در `word_detail_screen.dart` و کل `lib/` مفهوم علاقه‌مندی نیست — فهرست‌ها/دسته‌بندی‌ها (`add_to_category_sheet.dart`) همین کار را می‌کنند. ⇒ اگر Lukas دکمه‌ی جدا می‌خواهد، قدم تازه.
  · **`lib/core/content/content_registry.dart` بی‌استفاده است** — همه‌ی منابع (حتی oesd_c1) در آن ثبت‌اند، ولی هیچ فایل دیگری import‌اش نمی‌کند؛ deckها در `auswendiglernen_home_screen.dart` **دوباره** فهرست شده‌اند (دو فهرست = خلاف «یک منبع»). ⇒ یا وصل شود یا حذف؛ **بررسی نشد**.
  · **صفحه‌ی جزئیات Präpositionen** (`praep_cluster_detail_screen.dart`) صدا/لایتنر/دسته‌بندی ندارد و جمله‌ها `KlickWortText` نیستند ⇒ R-2.2.
  · **حدود ۲۰ مورد `- [ ]` قدیمی** (R-1/3/4/7، B12، G2-old، 16.5–16.7، S.3) در کد انجام شده بودند ⇒ در دور ۲ علامت خوردند. باقی `[ ]`ها واقعاً بازند.
  · **Suche Präpositionen** کلمه‌ی آلمانی را نمی‌گشت ⇒ در R-2.1 رفع شد.
- [ ] **L.5a صفحه‌ی پیشرفت (درصد/جدول).** ⛔ ایده، هنوز قطعی نیست — به گفته‌ی Lukas «شاید بعداً اضافه کنم».
      مشابه جدول‌ها و درصدهای اپ Root-in، ولی یک **صفحه‌ی مستقل و مخصوص VOX** — کپی کد از Root-in ممنوع؛
      دو ریپو همیشه جدا می‌مانند (`ways-of-working`). قبل از هر پیاده‌سازی از Lukas بپرس: چه چیزی درصد گرفته
      شود؟ (کلمه‌ها، گرامر، تمرین‌ها، یا یک درصد کلی؟) و آیا این صفحه داخل «حساب کاربری» (L.5d) باشد یا جدا.
- [ ] **L.5b ترجمه‌ی جمله‌به‌جمله در بخش خواندن (Lesen)، از جمله بخش اخبار.** زیر هر جمله‌ی متن، معنی‌اش
      نوشته شود — فارسی یا انگلیسی، بسته به زبان فعال اپ (طبق `AppL10n.activeLang`، همان قاعده‌ی L3، نه
      هر دو زبان هم‌زمان مگر تصمیم دیگری گرفته شود). شامل بخش اخبار هم می‌شود، نه فقط متن‌های Lesen عادی.
- [ ] **L.5c فاز تبدیل همه‌ی محتوای آموزشی داخل اپ به تمرین — به‌شدت متنوع.** گسترش زیرساخت **G7**
      (که فعلاً فقط گرامر را پوشش می‌دهد: G7a–G7c ✅، G7d/G7e باز) به **همه‌ی محتواهای اپ**
      (Redemittel، Lesen، Hören، Auswendiglernen، و هر بخش آموزشی دیگر) — نه فقط گرامر. هر چه نوع تمرین
      متنوع‌تر باشد بهتر است (چندگزینه‌ای، جفت‌کردن، درست/غلط، چیدن کلمه، جای‌خالی، شنیداری، و بیشتر).
      هم‌راستا با L.2e/G7d/G7e که هنوز باز است؛ اجرا بعد از تکمیل G7d/G7e برای گرامر.
- [ ] **L.5d صفحه‌ی کامل اکانت کاربری.** یک صفحه‌ی مستقل برای: اطلاعات حساب، آرشیوها، و سطح کاربر —
      فعلاً این اطلاعات پخش در More/Settings است؛ باید یک‌جا و کامل جمع شوند.
- [ ] **L.5e همه‌ی بخش‌ها بعد از مطالعه آزمون داشته باشند.** هر متن Lesen (و اخبار) بعد از خواندن یک آزمون
      دارد؛ هر درس گرامر بعد از مطالعه یک آزمون دارد؛ همین‌طور برای بقیه‌ی بخش‌های محتوایی. **تفاوت با L.5c:**
      L.5c درباره‌ی تنوع نوع تمرین‌هاست، L.5e درباره‌ی این است که **هیچ بخش محتوایی بدون آزمون پایانی نماند**
      (پوشش کامل، نه فقط گرامر). الگوی موجود برای گرامر: G7a (تمرین هر درس) + G7b (آزمون هر سطح) — همین
      الگو باید برای Lesen/اخبار و بقیه‌ی بخش‌ها هم تکرار شود.
- [x] **L.5f کلیک روی کلمه** ✅ (2026-09-20) — در همه‌جا یک رفتار: کلمه ⇒ پاپ‌آپ ⇒ صفحه‌ی کامل کلمه (+ لایتنر)؛ یک کامپوننت مشترک (`test/klick_wort_test.dart`). ✅ بازبینی چشمی Lukas روی آیفون (2026-09-23 دور ۲۱)، بعد از نسخه‌ی دوم (German News + تلفظ + پیام …
- [ ] **L.5g ساختار یکسان همه‌ی متن‌های Lesen و اخبار — دو لایه (درخواست Lukas، 2026-09-19).**
      **قاعده‌ی کلی:** این ساختار برای **کل بخش Lesen** است، نه فقط اخبار.
      **۱) سطح‌بندی:** هر متن و هر خبر برچسب سطح A1–C2 دارد (Lesen عادی الان دارد؛ اخبار RSS فعلاً ندارد —
      `news_screen.dart` فقط کارت‌های ExpansionTile + انتخاب فید Tagesschau/DW است).
      **۲) لایه‌ی خودکار (پیش‌نویس، نه تصمیم) — برای همه‌ی متن‌ها و اخبار، حتی آنهایی که خودکار به‌روز می‌شوند:**
      · ترجمه‌ی زیر متن (جمله‌به‌جمله) طبق زبان فعال اپ FA/EN — همان L.5b؛
      · کلیک روی هر کلمه ⇒ پاپ‌آپ ⇒ صفحه‌ی کلمه با ترجمه و افزودن به لایتنر — همان L.5f.
      **۳) لایه‌ی دست‌ساز (پیش‌نویس، نه تصمیم) — فقط برای متن‌هایی که از قبل آماده شده‌اند (تعدادشان کمتر است):**
      · تمرین‌ها · فهرست کلمات مهم متن · آزمون بعد از خواندن (L.5e) · توضیح نکات گرامری همان متن.
      **پیاده‌سازی:** لایه‌ی خودکار یک‌بار در کد ساخته شود و همه‌ی متن‌ها از همان استفاده کنند (Component
      Isolation)؛ لایه‌ی دست‌ساز **اختیاری** باشد — وقتی برای متنی موجود نیست، بخش مربوط نمایش داده نشود.
      ⛔⛔ **تصمیم مهم و باز — فقط با Lukas (تأکید او، 2026-09-19).** اینکه **کدام قابلیت‌ها برای همه‌ی متن‌ها**
      و **کدام فقط برای متن‌های از قبل آماده‌شده** است، یک تصمیم مهم است. تقسیم بالا (۲ و ۳) فقط **پیش‌نویس**
      است، نه تصمیم. **وقتی به این کار رسیدیم Claude باید بپرسد و هیچ‌کدام را حدس نزند:**
      (۱) **چند متن** آماده‌شده (دست‌ساز) داشته باشیم؟
      (۲) این متن‌ها **از کجا** می‌آیند؟ (Lukas خودش می‌نویسد، Claude می‌سازد، منبع بیرونی، …)
      (۳) **کدام قابلیت‌ها** را فقط همین متن‌های محدود دارند؟ (تمرین، کلمات مهم، آزمون، نکات گرامری، …)
      (۴) **کدام قابلیت‌ها** را همه‌ی متن‌ها دارند؟ (ترجمه‌ی زیر متن، پاپ‌آپ کلمه، سطح، …)
      تا Lukas جواب نداده، پیاده‌سازی این تقسیم شروع نشود.
      ⛔ **دو سؤال باز دیگر — قبل از پیاده‌سازی از Lukas بپرس، حدس نزن:**
      (الف) سطح A1–C2 برای اخبار خودکار از کجا بیاید؟ (تخمین با کد از روی سطح کلمه‌ها در فهرست کلمات، یا
      منبع خبری که خودش ساده‌شده است، یا فقط اخبار دست‌چین‌شده)
      (ب) ترجمه‌ی جمله‌به‌جمله‌ی اخبار خودکار **با کدِ تنها ممکن نیست** — نیاز به سرویس ترجمه‌ی ماشینی دارد
      (هزینه، کیفیت، آفلاین). پاپ‌آپ کلمه با کد ممکن است ولی فقط برای کلمه‌هایی که در آرشیو کلمات هستند.

## فاز P — Profil & Konto (2026-09-20)
✅ درخواست Lukas (2026-09-20):** «کاربر اکانت و اطلاعات خودش را کجا وارد کند؟» تا آن روز جواب: فقط پایین «تنظیمات»، و آن هم فقط اگر Secretهای
> Supabase ست بودند. اسم/آدرس/تلفن/تغییر رمز/آرشیو اصلاً وجود نداشت. ✅ **CI grün** (2026-09-20, Lauf 35487912698 auf Zweig `profil-seite`: analyze + test + Web-Bau) — danach nach `main`. ⚠️ Noch **nicht im Browser gesehen** (Claude hat keinen): Ansicht/RTL/Dialoge bitte von Lukas anschauen.
      ⚠️ ادغام: «آخرین ویرایش کامل برنده است» (`NutzerProfil.spaeteres`)؛ عمداً جدا از `einstellungen`.
      ⚠️ حساب با Root-in مشترک است (`auth.users`): تغییر رمز/ایمیل در هر دو اپ اثر دارد (UI صریحاً می‌گوید).
      ⚠️ `AppLinks.voxUrl` و `AppLinks.voxPasswortUrl` باید زیر Redirect URLs در Supabase باشند.
      ⚠️ مسابقه با همگام‌سازی: آپلود بعد از حذف با FK رد می‌شود ⇒ حساب «برنمی‌گردد».
- **تست‌ها:** `test/profil_test.dart` (تلفن، پاک‌سازی، JSON، ادغام، قرارداد v4 + خواندن v3، قاعده‌ی رمز، کدهای Auth)، `test/profil_controller_test.dart`،
- ⚠️ **کد بدون کامپایلر نوشته شد** (Claude Flutter ندارد) — فقط ساختارهای موجود در ریپو؛ اعتبار واقعی = اجرای «Zweig prüfen».
_(جزئیات: `git show a078dc2:PLAN.md`)_

## اطلاعات کلی
- نام اپ: VOX
- پروژه Flutter: vox
- پلتفرم هدف: iOS + Android
- زبان رابط: فارسی / انگلیسی (قابل تغییر در settings) — **پیش‌فرض انگلیسی؛ فقط روی دستگاه فارسی‌زبان فارسی** (L.3a، 2026-09-16)
- زبان هدف: آلمانی
- رویکرد: آفلاین‌محور، بدون AI، parser متنی

---

## STATUS LEGEND
[x] = done  [ ] = planned  [~] = in progress  [!] = blocked  [⛔] = منسوخ/حذف‌شده (فقط تاریخچه)

---

## فاز ۰ تا ۱۵ — زیرساخت و ویژگی‌های اصلی ✅
(همه فازهای اولیه کامل شده‌اند — جزئیات در آرشیو پایین)

---

## ✅ باگ‌ها (همه بسته)

### B-14 ✅ (2026-10-05): تایمر Pomodoro با قفل شدن صفحه می‌ایستاد
✅ **گزارش Lukas:** وقتی در بخش Pomodoro صفحه قفل می‌شود، تایمر دیگر کار نمی‌کند و می‌ایستد.
- **علت:** `PomodoroNotifier` با `Timer.periodic(1s)` فقط تیک می‌شمرد. با قفل صفحه یا رفتن اپ به پس‌زمینه، مرورگر/PWA تایمرها را کند یا متوقف می‌کند؛ ثانیه‌های از دست‌رفته هرگز نمی‌آمدند و ساعت عقب می‌ماند.
- **راه‌حل (بدون موقت‌کاری):** `selbstlernen_controller.dart` ⇒ هنگام شروع `_endsAt` (زمان پایان واقعی) ثبت می‌شود و `secondsLeft` از آن حساب می‌شود (هر ۲۵۰ms و هنگام `didChangeAppLifecycleState(resumed)`). پایان فاز در حین قفل ⇒ فاز بعدی، جلسه شمرده می‌شود، منتظر دکمه‌ی شروع (رفتار قبلی). ساعت سیستم به عقب برگردد ⇒ هرگز بیشتر از کل فاز نشان داده نمی‌شود. `pause` ابتدا زمان گذشته را کم می‌کند.
- **ذخیره و بازیابی:** کلید `pomodoro_zustand_v1` در shared_preferences (فاز، شمارنده، باقی‌مانده، running، `endsAtMs`) ⇒ اگر PWA در پس‌زمینه بسته شود، تایمر از زمان پایان واقعی ادامه می‌دهد؛ ورودی خراب نادیده گرفته می‌شود.
- **تست:** `test/pomodoro_test.dart` با ساعت جعلی (قفل ۹۰ ثانیه، پایان فاز حین قفل، pause، ساعت به عقب، reset، جلسه‌ی چهارم ⇒ استراحت بلند، ذخیره و بازیابی، ورودی خراب).
- ⚠️ **حد روشن:** وب هنگام قفل دقیقاً ثانیه‌ای اجرا نمی‌شود و بدون سرور نمی‌تواند هشدار پایان فاز بدهد؛ زمان نمایش‌داده‌شده بعد از برگشت درست است. wake-lock و اعلام پایان فاز ⇒ B-14b پایین.
_(Root-in: هیچ تغییری.)_

### B-14b ✅ (2026-10-05): روشن ماندن صفحه + اعلام پایان فاز + شروع خودکار (درخواست Lukas)
✅ **چرا:** B-14 زمان را درست کرد، ولی (الف) صفحه حین تایمر خودش قفل می‌شد، (ب) کاربر بعد از برگشت نمی‌فهمید فاز کی تمام شده، (ج) هر فاز دکمه می‌خواست.
- **روشن ماندن صفحه:** `navigator.wakeLock.request('screen')` (`pomodoro_geraet_web.dart`). مرورگر هنگام پنهان‌شدن صفحه قفل را خودش آزاد می‌کند ⇒ هنگام `resumed` دوباره درخواست می‌شود. مرورگر بدون API / رد شدن ⇒ بی‌صدا صرف‌نظر؛ تایمر به آن وابسته نیست. در ⚠️ قفل دستی صفحه کمکی نمی‌کند (فقط قفل خودکار). پیش‌فرض روشن، سوییچ در صفحه.
- **پایان فاز:** `PomodoroState.beendetePhase/beendetUm` ⇒ بنر در `pomodoro_screen.dart` تا اولین Start/Pause/Reset/Skip (در حالت خودکار بعد از ۳۰ ثانیه). صدا: سه نت سینوسی با Web Audio، بدون فایل صوتی و بدون پکیج؛ `AudioContext` هنگام لمس Start ساخته می‌شود (قانون مرورگر)، پس بعد از قفل هم پخش می‌شود. یک صدا برای کل قفل (نه برای هر فاز). سوییچ، پیش‌فرض روشن.
- **شروع خودکار:** `autoWeiter` (پیش‌فرض **خاموش** = رفتار قبلی). `_phasenAbschliessen` همه‌ی فازهای میانی را از `_endsAt` نقل می‌کند (جلسه‌ها شمرده می‌شوند؛ سقف ۵۰۰ دور برای ساعت خراب). `skipPhase` اگر در حال اجرا و خودکار باشد ادامه می‌دهد.
- **ذخیره:** سه سوییچ در همان JSON `pomodoro_zustand_v1` (`autoWeiter`، `wachHalten`، `klang`)؛ نبودن/خرابی ⇒ پیش‌فرض؛ `reset` آن‌ها را نگه می‌دارد.
- **ساختار:** قابلیت‌های مرورگر جدا از منطق زمان: `services/pomodoro_geraet.dart` (+ `_basis`، `_io`، `_web` با export شرطی مثل `install_state.dart`) ⇒ در تست با دستگاه جعلی جایگزین می‌شوند.
- **تست:** `pomodoro_test.dart` (wake-lock روشن/خاموش/دوباره‌درخواست، بنر+صدا، خودکار، قفل ۱۱۷ دقیقه ⇒ استراحت بلند، ۲۱ روز، skip، reset، ذخیره/بازیابی)، `pomodoro_screen_test.dart` (سوییچ‌ها، بنر fa/en)، `l10n_paritaet_test.dart`.
- ⏭️ **باز (فقط با تصمیم Lukas):** اعلان واقعی هنگام قفل = Web Push با سرور (Supabase Edge Function + VAPID؛ در iOS فقط PWA نصب‌شده) یا اپ بومی (فاز Z، اعلان محلی).
_(Root-in: هیچ تغییری.)_

### B-13 ✅ (2026-09-23): کلمه‌ی واژگان در لایتنر دیده نمی‌شد
✅ گزارش Lukas (آیفون):** «افزودن به لایتنر» در واژگان ⇒ دکمه رنگ عوض می‌کرد و پیام می‌آمد، ولی بخش لایتنر «هیچ کارتی» نشان می‌داد.
  نمره‌دادن کارت آرشیو: `UserStateRepository.archivLeitnerBewerten` با همان قاعده و فاصله‌های `LeitnerDao.boxIntervals`؛ جریان زنده: `archivLeitnerBeobachten`.
- ⚠️ **قاعده:** هر جای تازه‌ای که لایتنر را می‌شمارد یا می‌خواند ⇒ از `leitnerEintraegeProvider`، هرگز مستقیم از یک جدول.
_(جزئیات: `git show a078dc2:PLAN.md`)_

### B-1: خطای Flutter — color + decoration در Container ✅
- وضعیت: رفع شد (2026-06-29)

### B-2: خطای SQLite — UNIQUE constraint در words ✅
- وضعیت: رفع شد (2026-06-29)

### B-12 ✅ (2026-09-15): پشتیبان فیلدهای گرامری B-10 را نداشت
✅ ✅ فیلدهای B-10 به Fassade و پشتیبان اضافه شدند.
- ⚠️ **قاعده:** هر ستون تازه در جدول کاربر ⇒ در **همان commit** در Fassade (`user_state_repository.dart`).
_(جزئیات: `git show a078dc2:PLAN.md`)_

### B-11 ✅ (2026-09-15): اپ و پشتیبان دو جای متفاوت را می‌خواندند — از دست رفتن ظاهری پیشرفت
✅ ✅ Store و پشتیبان حالا یک محل ذخیره دارند (فقط از راه Fassade).
- ⚠️ **درس:** جابه‌جایی محل ذخیره ⇒ **همه‌ی** خواننده‌ها منتقل شوند (قبلش grep روی `lib/`).
_(جزئیات: `git show a078dc2:PLAN.md`)_

### B-10 ✅ (2026-09-16, CI grün): جدول قدیمی Words — Grammatikfelder nachgetragen
✅ ✅ ستون‌های `regelmaessig`/`trennbar`/`grammatikDetail` در `Words` (schema 4→5).
- ⚠️ داده‌ی ناکافی ⇒ بدون نماد، هرگز حدس (Konnektor همیشه نماد دارد: `kurve_u`).
_(جزئیات: `git show a078dc2:PLAN.md`)_

### B-9 ✅ (2026-09-15): دو سیستم رنگ آرتیکل — یکی شد
- ✅ یک نظام رنگ آرتیکل: `GrammatikonSpec` (`article_colors.dart` از آن می‌خواند؛ نگهبان `test/artikelfarben_test.dart`).

### B-3: Wortschatz — نمایش کلمه با حرف اضافه در لیست ✅
✅ مشکل: کلمات Präpositionen مثل "das Engagement für" در لیست Wortschatz نمایش داده می‌شدند
_(جزئیات: `git show a078dc2:PLAN.md`)_

### B-4: Grammatik home — لینک به صفحه لیست به جای گرامر ✅
✅ مشکل: `_GrammarSection` tiles به list screens می‌رفتند (konnektoren، dativ، praep)
_(جزئیات: `git show a078dc2:PLAN.md`)_

## فاز R — Refactor & UX (فاز جاری — بعد از رفع باگ‌ها)

### R-1: Wortschatz — نمایش پاک کلمه در لیست
✅ [x] R-1.1 ✅ `word_list_item.dart` کلمه را بدون حرف اضافه نشان می‌دهد (`stripPreposition`).
_(جزئیات: `git show a078dc2:PLAN.md`)_

### R-2: Auswendiglernen — Präpositionen list باید full form نشان دهد
- [x] R-2.1 ✅ 2026-09-22 لیست "Nomen · Verb · Adjektiv + Präpositionen": فرمت: `lemma · حرف_اضافه` — `PraepCluster.vollform` + `praepositionen_home_screen.dart`؛ تست `test/praep_vollform_test.dart`
- [ ] R-2.2 کلیک روی هر آیتم → detail view کامل: (وضع 2026-09-22: `praep_cluster_detail_screen.dart` معنا + اعضا + مثال‌ها دارد؛ **صدا/لایتنر/دسته‌بندی ندارد**)
  ⛔ **بعد از انتشار** (تصمیم Lukas 2026-09-22 دور ۵) — برنامه و تصمیم‌ها: بخش «R-2.2 — برنامه» درست زیر همین.

#### R-2.2 — برنامه (فقط برنامه؛ ثبت 2026-09-22 دور ۳ — هیچ کدی ساخته نشده)
**تصمیم Lukas:** همه‌ی بخش‌های **Auswendiglernen** باید کلمه‌هایشان را **طبق پرامپت کلمه** بسازند؛ صفحه‌ی کلمه **کد جداگانه‌ی خودش** را دارد
(`features/vokabular/screens/wort_seite_screen.dart` + `widgets/wortseite_bausteine.dart` + `widgets/details_renderer.dart`). یعنی:
**برای هر deck صفحه‌ی جزئیاتِ دوم با صدا/لایتنر خودش ساخته نمی‌شود** — اصل «یک محتوا، چند ورودی» و Component Isolation: کلمه یک‌بار (یک کارت، یک id)، از چند در دیده می‌شود.
- **منابع ثابت (قبل از هر تغییر مستقیم از ریپو بخوان، نه از حافظه):** پرامپت = `old files Lukasalmani/Wort prompt` (Version 3.0) · اعتبارسنجی + id = `lib/features/vokabular/data/vokab_schema.dart` (`vokabId(wortart, wort)`، `vokabWortarten`) ·
  ظاهر فقط در کد (`core/grammatikon/*`) — پرامپت هیچ اطلاعات ظاهری تولید نمی‌کند · یک کلمه = یک کارت (fa+en در همان فایل) · داده برای نماد کافی نیست ⇒ «بی‌نماد بهتر از نماد غلط».
- **deckهای درگیر** (`auswendiglernen_home_screen.dart`): Satzkonnektoren · Dativ/Akkusativ-Verben · NVV · Nomen·Verb·Adjektiv + Präposition · Unregelmäßige Verben · Trennbare/untrennbare Verben ·
  Reflexivverben · Verben mit Präpositionen · Modalverben · (بعداً deckهای «به‌زودی» L.2d). Redewendungen = کارت‌های شخصی کاربر (جداست).
- **مراحل پیشنهادی (هر کدام قدم جدا، بعد از «بله»ی Lukas):**
  1. **فهرست‌برداری:** از هر فایل داده‌ی deck (`assets/data/*_data.json`) همه‌ی lemmaها + Wortart بیرون کشیده شود و با `vocab_index.json` مقایسه شود ⇒ فهرست «کارت دارد / کارت ندارد». (ابزار در `tool/`، مثل `sync_backlog.py`؛ بدون تغییر در اپ.)
  2. **ساخت کارت‌های نداشته** با پرامپت کلمه ⇒ `assets/vocab/` — همان مسیر **L.4** (روش: «📚 روال ده کلمه جدید»، تصمیم 2026-09-23؛ هر کلمه صفحه‌ی خودش — ⭐ اصل اول).
  3. **اتصال:** در لیست/جزئیات هر deck، هر lemma ⇒ همان رفتار L.5f (`showWortPopup` / `router.push('/vokabular/wort/:id')`) — id فقط از `vokabId`/`vocab_index`، **هیچ id حدسی**. کارت نیست ⇒ لینک نیست (نه لینک شکسته).
  4. **صدا/لایتنر/دسته‌بندی** از خود صفحه‌ی کلمه می‌آیند (`WortActions`) — در صفحه‌های deck تکرار نمی‌شوند.
  5. تست: نگهبان «هر lemma که لینک دارد، id‌اش در `vocab_index.json` هست» (مثل L.1a).
- ✅ **تصمیم‌ها (Lukas، 2026-09-22 دور ۵) — هنوز اجرا نشده، فقط برنامه:**
  **۰. زمان: همه‌ی R-2.2 بعد از انتشار** (قانون: اپ هر چه زودتر منتشر شود، کلمه‌ها به‌مرور) ⇒ همراه L.4 / A.6. **ترتیب: یکی‌یکی** (کیفیت بهتر، اشتباه کمتر).
  **۱. کارت‌های Auswendiglernen مقدس‌اند (قانون ثابت Lukas):** هیچ کارتی از صفحه‌ی Auswendiglernen **حذف نمی‌شود**؛ مثال، جزئیات، توضیح و ترجمه‌ی هیچ‌کدام **پاک یا کوتاه نمی‌شود**.
     فقط **گسترش** مجاز است = ترجمه/مثال/توضیح بیشتر، شکل‌های بصری (Grammatikon)، دکمه‌ی تلفظ، ذخیره در لایتنر و … .
     ⇒ فایل‌های `assets/data/*_data.json` و صفحه‌های deck **منبع دست‌نخورده** می‌مانند؛ نگهبان: تستی که هر رشته‌ی متنی فعلی deckها (مثال/ترجمه/توضیح) را نگه می‌دارد و اگر یکی کم شد CI را قرمز می‌کند (baseline از commit قبل از شروع).
  **۲. یک کارت، دو جا (Auswendiglernen + Wörter):** مجاز است **فقط** اگر از محتوای کارت Auswendiglernen چیزی کم نشود. مثال `sich bedanken für`:
     · کارت Wörter = **یک کارت** `verb_bedanken` (id فقط از `vokabId`)؛ پرامپت کلمه خودش جا دارد: `details.reflexiv` + `details.rektion` (فهرست — هم `sich bedanken bei + Dat` هم `für + Akk`).
     · وقتی کارت `bedanken` ساخته می‌شود، مثال‌ها/ترجمه‌های کارت Auswendiglernen **عیناً** به‌عنوان ورودی به پرامپت داده می‌شوند و در کارت می‌آیند (کارت کلمه از deck استفاده می‌کند، نه برعکس).
     · در deck: همان کارت «sich bedanken für» با همه‌ی محتوای قبلی + دکمه‌های تازه (تلفظ، لایتنر، «صفحه‌ی کامل کلمه» ⇒ `/vokabular/wort/verb_bedanken`).
     · هر عضو خوشه/deck که کلمه‌ی تکی است (Präp-Cluster، Verben mit Präp، Dativ/Akk، Reflexiv، Trennbar، Unregelmäßig، Modal، Konnektoren) همین راه را می‌رود.
  **۳. عبارت‌ها (NVV، Redemittel) — تصمیم Claude به خواست Lukas: «کارت عبارت» (Ausdruck-Karte) هم‌خانواده‌ی کارت کلمه.**
     · ⏱️ **زمان (Lukas، 2026-09-24): بعد از وارد شدن همه‌ی کلمه‌ها** ⇒ L.4c. تا آن زمان صفحه‌ی عبارت همان‌طور که هست می‌ماند؛ کلمه‌های سازنده‌اش در روال ده کلمه مثل همه صفحه‌ی **جدید** خودشان را می‌گیرند (⭐ اصل اول).
     · **تأیید Lukas (2026-09-22 دور ۷) — در لیست عبارت کامل می‌ماند:** لیست deck (NVV/Redemittel) هیچ تغییری نمی‌کند —
       هر ردیف همان عبارتِ کامل است («eine Entscheidung treffen» یک ردیف، نه سه ردیف جدا برای هر کلمه)، دقیقاً مثل الان.
       کلمه‌ها فقط **داخل صفحه‌ی جزئیات** (بعد از کلیک روی ردیف) تک‌تک و قابل‌کلیک می‌شوند (مثل L.5f) — نه در خود لیست.
     · **تأیید Lukas (2026-09-22 دور ۸) — عبارت و کلمه دو کارت جدا، دو صفحه‌ی جدا:** «eine Entscheidung treffen» = کارت عبارت (`ausdruck_…`) با صفحه‌ی خودش
       (معنی عبارت، معادل تک‌کلمه‌ای `entscheiden`، مثال‌های خودش)؛ «die Entscheidung» = کارت کلمه (`nomen_entscheidung`) با صفحه‌ی خودش (معنی، جمع، مثال…).
       هرگز در هم ادغام نمی‌شوند؛ **فقط به هم لینک‌اند**: در صفحه‌ی عبارت، کلیک روی «Entscheidung» (از `bestandteile`) ⇒ صفحه‌ی کارت کلمه.
     · **یک کارت، چند جا (اصل «یک محتوا، چند ورودی»):** هر کارت یک‌بار ساخته می‌شود و هرجا مربوط است دیده می‌شود — Auswendiglernen (همان جای قبلی)، Wörter (صفحه‌ی کامل)،
       Prüfungen (تمرین‌های فعلی Redemittel دست‌نخورده می‌مانند). هیچ‌وقت نسخه‌ی دوم برای نمایش دوم.
     · **دکمه‌ها:** تلفظ + لایتنر به کارت‌های عبارت هم اضافه می‌شوند؛ **شکل هندسی (Grammatikon) نه** تا Lukas برای عبارت شکل تعریف کند.
     · **یک پرامپت دوم، کپی ساختاری پرامپت کلمه:** `old files Lukasalmani/Ausdruck prompt` (ساخته نشده). همان TEIL 0 (فقط JSON، `{fa,en}`، null نه ""، `schema: "3.0"`، ۲ مثال A2 + B1/B2، مترادف/«Gegenteil»، `register`، `anmerkung` فقط آلمانی، هیچ اطلاعات ظاهری) ⇒ اپ یکپارچه می‌ماند.
     · تفاوت فقط در `wortart: "ausdruck"` و بلوک `details`: `typ` (nvv | redemittel)، `bestandteile` (کلمه‌های سازنده ⇒ لینک به کارت کلمه‌ی هر کدام، مثل wortnetz)، برای NVV: `funktionsverb`، `nomen`، `kasus/praeposition`، `verbalform` (eine Entscheidung treffen ↔ entscheiden)؛ برای Redemittel: `situation/funktion` (Meinung äußern، Vortrag einleiten…)، `pruefung` (Goethe B2 / ÖSD B2 / ÖSD C1 / 1010)، `register`.
     · **نمایش: همان صفحه‌ی کلمه** `wort_seite_screen.dart` + `wortseite_bausteine.dart`؛ فقط یک بلوک `details` تازه در `details_renderer.dart`. Grammatikon برای عبارت **شکل ندارد** تا Lukas شکل تعریف کند (قاعده‌ی ۳: بی‌نماد بهتر از نماد غلط).
     · **محتوای قدیمی حفظ:** توضیح، مثال، ترجمه و برچسب‌های فعلی Redemittel/NVV **عیناً** در کارت عبارت می‌آیند (ورودی پرامپت) و در deck هم همان‌طور می‌مانند؛ فقط اضافه می‌شود.
     · ⚠️ نیاز به تغییر `vokab_schema.dart` (`vokabWortarten` + `vokabId` برای `ausdruck_…`) = تغییر در «تنها منبع validation و id» ⇒ در قدم اجرا **اول پیش‌نویس پرامپت عبارت و تغییر schema به Lukas نشان داده شود**، بعد کد.
  **۴. ترتیب پیشنهادی deckها (یکی‌یکی، هر کدام: فهرست‌برداری ⇒ کارت‌ها ⇒ اتصال ⇒ نگهبان ⇒ تأیید Lukas ⇒ بعدی):**
     ① Nomen·Verb·Adjektiv + Präposition (منشأ R-2.2) ② Verben mit Präpositionen ③ Reflexivverben ④ Dativ/Akkusativ-Verben ⑤ Trennbare Verben ⑥ Unregelmäßige Verben ⑦ Modalverben ⑧ Satzkonnektoren
     ⑨ NVV (اولین کارت عبارت) ⑩ Redemittel: Goethe B2 ⇒ ÖSD B2 ⇒ ÖSD C1 ⇒ 1010 (بزرگ‌ترین، آخر). Redewendungen = کارت‌های شخصی کاربر ⇒ بیرون از این کار.
     ⚠️ (2026-09-24) ⑨ و ⑩ = L.4c ⇒ **فقط بعد از وارد شدن همه‌ی کلمه‌ها**. ①–⑧: هر کلمه کارت و صفحه‌ی خودش (⭐ اصل اول)؛ deck فقط دکمه/لینک به آن اضافه می‌کند؛ هیچ ادغام — تکراری‌ها فقط در L.4d.
  - معنا (FA + EN)، مثال‌ها، صدا (TTS)
  - دکمه Leitner، دسته‌بندی، favorit

#### R-2.3 — گسترش همه‌ی محتوای Auswendiglernen (درخواست Lukas، 2026-09-23 دور ۱۹) ⛔ **بعد از انتشار**
- [ ] **هدف:** همه‌ی deckهای Auswendiglernen بعد از انتشار **گسترش** پیدا کنند — نمونه‌هایی که Lukas گفت: **مثال بیشتر، ترجمه‌ی بیشتر/کامل‌تر (fa + en)، تمرین**، و … .
- **قانون ثابت (همان R-2.2 تصمیم ۱):** فقط افزودن. هیچ کارت، مثال، ترجمه یا توضیحی حذف یا کوتاه نمی‌شود؛ نگهبان متن (baseline) قبل از اولین تغییر ساخته می‌شود.
- **تمرین‌ها:** طبق اصل «یک محتوا، چند ورودی» (A-1) — هر تمرین یک‌بار ساخته می‌شود و هم کنار همان deck هم در Prüfungen دیده می‌شود؛ تمرین از مثال‌های خود deck هم ساخته می‌شود (مثل G7: جای خالی و …).
- **ترتیب و هماهنگی:** deck به deck، هم‌زمان با R-2.2 (همان ترتیب ①…⑩) — وقتی deckی برای R-2.2 باز است، گسترش R-2.3 همان deck هم همان‌جا انجام می‌شود تا هر deck یک‌بار کامل شود.
- **منبع محتوا:** Lukas منابع را می‌فرستد؛ متن/مثال/تمرین از کتاب کپی نمی‌شود — فقط موضوع، متن از نو (کپی‌رایت).
- ⚠️ قبل از شروع هر deck: فهرست دقیق «چه اضافه می‌شود» به Lukas نشان داده شود و بعد از «بله» ساخته شود.

### R-3: Auswendiglernen — ساختار جدید صفحه اصلی
✅ [x] R-3.1 ✅ (همان Phase 5، 2026-06-29) حذف section headers (Verben، Satzbau und Konnektoren، Wortschatz، Redemittel)
- [x] R-3.3 ✅ (Phase 5) deck‌های "coming soon" را نشان بده ولی غیرفعال (قفل) — ⚠️ برای انتشار: L.2d
_(جزئیات: `git show a078dc2:PLAN.md`)_

### R-3b: Grammatik — لینک‌های موضوعی ✅ (2026-06-29)
- ✅ لینک‌های موضوعی (Konnektoren، Dativ/Akk، NVV، Präpositionen). اصل: Grammatik home فقط ارجاع می‌دهد.

### R-3c: Prüfungen — بخش تمرین‌های موضوعی ✅ (2026-06-29)
- ✅ تمرین‌های موضوعی (همان چهار موضوع). اصل: Prüfungen فقط ارجاع می‌دهد.

### R-4: Filter / Sort UI — یکپارچه در همه صفحات
✅ هدف:** همه صفحات محتوا یک ظاهر یکسان دارند، ولی گزینه‌های فیلتر به محتوای همان صفحه تعلق دارند.
**⚠️ اصل مهم — گزینه‌های فیلتر باید با محتوای صفحه تطابق داشته باشند:**
**⚠️ اصل component isolation:**
_(جزئیات: `git show a078dc2:PLAN.md`)_

### ⭐ اصل معماری پایه: یک محتوا، چند ورودی (Content Once, Many Entrances)
> **تصمیم Lukas، 2026-09-18.** هم‌ردیف Component Isolation است و هر Session باید رعایتش کند.

**هدف Lukas (به بیان خودش):** «اپ پر از منابع و محتوا باشد، ولی با دسته‌بندی‌های مختلف.»

**قانون:** هر واحد محتوا (یک تمرین، یک کلمه، یک عبارت، یک متن) **یک‌بار** ساخته و ذخیره می‌شود،
ولی از **چند در ورودی** دیده می‌شود. هرگز برای نمایش دوم، نسخه‌ی دوم ساخته نمی‌شود.

**نمونه‌ی مرجع — تمرین‌های گرامر:**
| کجا | چه‌وقت دیده می‌شود | با چه چیدمانی |
|---|---|---|
| بخش **Grammatik** | بلافاصله بعد از آموزشِ همان موضوع | به ترتیب درس |
| صفحه‌ی **Prüfungen** | جدا از درس، برای تمرین هدفمند | با دسته‌بندی‌های زیر |

**سه محور دسته‌بندی در Prüfungen** (هر تمرین می‌تواند هم‌زمان در هر سه بیاید):
1. **سطح** — A1، A2، B1، B2، C1، C2
2. **موضوع** — مثلاً «افعال مدال»، «حروف اضافه»، «افعال جداشدنی»
3. **هفت مهارت** — فهرست نهایی از Lukas (2026-09-18):

| # | مهارت | شامل چه چیزهایی | بخش‌های موجود اپ که اینجا می‌نشینند |
|---|-------|------------------|--------------------------------------|
| ۱ | **کلمه** | آرتیکل، معنی، متضاد، املا، تلفظ و … | `wortschatz` · `vokabular` · `kategorien` · `leitner` |
| ۲ | **گرامر** | قواعد و تمرین‌های گرامری | `grammatik` (۸۴ درس / ۳۴۵ تمرین) · `modalverben` · `konnektoren` · `praepositionen` · `dativ_verben` · `reflexiv_verben` · `trennbar_verben` |
| ۳ | **چیزهای حفظی** | Redemittel · افعال بی‌قاعده · حروف اضافه‌ی ثابت با فعل/اسم/صفت · ترکیب‌های ثابت فعل با اسم خاص (Nomen-Verb-Verbindungen) و … | `redemittel` · `auswendiglernen` · `unregelm_verben` · `verb_praep` · `nvv` |
| ۴ | **نوشتن** | Schreiben | `schreiben` |
| ۵ | **خواندن** | Lesen | `lesen` |
| ۶ | **شنیدن** | Hören | `hoeren` |
| ۷ | **حرف زدن** | Sprechen | `sprechen` · `fragen` |

   ⚠️ **ستون سوم حدسِ Claude از روی نام پوشه‌هاست، نه تصمیم Lukas** — در A-1 باید یکی‌یکی
   با Lukas تأیید یا اصلاح شود. مخصوصاً: `nvv` و `verb_praep` مرز بین «گرامر» و «حفظی» را
   لمس می‌کنند، و `fragen` معلوم نیست زیر «حرف زدن» درست بنشیند یا جای دیگر.

**چرا این مهم است:** اگر یک تمرین دو بار ساخته شود، اصلاح‌کردنش هم باید دو بار انجام شود و
دیر یا زود دو نسخه با هم فرق می‌کنند. همان منطق R-3c که از قبل داشتیم: «Prüfungen فقط ارجاع
می‌دهد — هر quiz در feature folder خودش است.» این اصل همان را به **کل اپ** تعمیم می‌دهد.

**وضعیت فعلی (بررسی Claude، 2026-09-18):**
- ✅ **بخش کلمات** — Lukas می‌گوید تا حد زیادی رعایت شده.
- ✅ **R-3c** — Prüfungen به quizهای موضوعی ارجاع می‌دهد (Konnektoren، Dativ، NVV، Präpositionen).
- ⚠️ **شکاف روشن:** `pruefungen_home_screen.dart` الان فقط بر اساس **سازمان آزمون**
  (Goethe / telc / ÖSD) چیده شده — سه محور بالا (سطح/موضوع/مهارت) هنوز آنجا نیستند،
  و **۳۴۵ تمرین گرامر** فعلاً فقط از راه درس‌ها دیده می‌شوند، نه از Prüfungen.

### 🔍 A-1 (باز) — Audit «یک محتوا، چند ورودی» در کل اپ
> **درخواست صریح Lukas (2026-09-18):** «یک زمانی باید چک کنیم آیا این فرایند در همه جای اپ
> رعایت شده یا خیر؟ کل اپ را بخش به بخش چک کنیم.»
> **و:** «می‌توانیم با هم همکاری کنیم توی این موضوع چون تنهایی نمی‌توانی.» — درست است:
> Claude می‌تواند کد و داده را بشمارد و شکاف‌ها را فهرست کند، ولی **کدام دسته‌بندی برای
> یادگیرنده مفید است** تصمیم Lukas است، و **دیدن اینکه در اپ واقعاً چه پیداست** هم فقط با
> مرورگرِ Lukas ممکن است.

**تقسیم کار پیشنهادی:**
- **Claude:** برای هر بخش اپ فهرست می‌کند چه محتوایی دارد، از کجا خوانده می‌شود، و از کدام
  درها دیده می‌شود ⇒ یک جدول «محتوا ↔ ورودی‌ها» + فهرست شکاف‌ها.
- **Lukas:** تصمیم می‌گیرد کدام شکاف ارزش پرکردن دارد.
  ✅ **فهرست هفت مهارت داده شد (2026-09-18)** — جدولش بالاست. باقی‌مانده: تأیید اینکه هر بخش
  اپ زیر کدام مهارت می‌نشیند (ستون سوم آن جدول فعلاً حدس Claude است).

**بخش‌هایی که باید یکی‌یکی چک شوند:** Wortschatz · Grammatik (۸۴ درس / ۳۴۵ تمرین) ·
Auswendiglernen (deckها) · Redemittel · Lesen · Hören · Schreiben · Sprechen · Fragen ·
Modalverben · Konnektoren · Dativ/NVV/Präpositionen/Reflexiv/Trennbar/Unregelmäßig/Verb+Präp ·
Vokabular · Leitner · Kategorien · Selbstlernen.

⏳ **زمان‌بندی:** بعد از انتشار (چون فاز LAUNCH جاری است)، مگر Lukas زودتر بخواهد.

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
✅ [x] R-5.1 `core/widgets/vox_button.dart` ✅ (2026-07-07 — فاز B کامل، پایین را ببین)
_(جزئیات: `git show a078dc2:PLAN.md`)_

### فاز B — Buttons: Puzzling-Prinzip ✅ (2026-07-07)
> خواسته کاربر: **همه‌چیز در اپ فقط از «صفحه دکمه» استفاده می‌کند** — هیچ screen ای
> کد دکمه ندارد (reference نه کپی). و دکمه‌ها روی **System-Widgets** متریال ساخته
> شوند تا با هر آپدیت فریمورک/پلتفرم خودکار به‌روز شوند (نه شکل دستی‌کشیده).
> منبع طراحی: `old files Lukasalmani/1/Button` — نسخه «اجزای رسمی» (buttonStyle های سیستمی).

- [x] B.1 ✅ `vox_button.dart` تنها منبع همه‌ی دکمه‌ها (`VoxButton.*` · `VoxIconButton` · `VoxFab` · `VoxOptionButton`).
- [x] B.2 ✅ جاروی کامل: ۰ دکمه‌ی خام در `features/`.
- [x] B.3 flutter analyze: No issues ✅
- [x] B.4 ✅ (2026-07-07) گزینه‌های آزمون ListTile-based (nvv، praep، redemittel، unregelm، verb-praep)
- [~] B.4-alt باقی‌مانده (بعداً): Word-Chips (wortstellung، dativ) → vox_chip؛ قدیمی:
      RadioListTile) → VoxOptionButton برای یکدستی کامل؛ Word-Chips (wortstellung، dativ) → vox_chip
- [x] **B.5** ✅ (2026-09-15) نگهبان `test/puzzling_buttons_test.dart`: دکمه‌ی خام در `lib/features/` ⇒ CI قرمز.
- **قانون از این به بعد**: دکمه جدید = فقط reference به vox_button.dart؛
  `grep -rE 'IconButton\(|TextButton|OutlinedButton|FilledButton|FloatingActionButton' lib/features`
  باید همیشه ۰ نتیجه غیر-Vox بدهد.

### R-6: دوزبانه — Audit کامل (FA + EN) ✅ (2026-06-30)
✅ ✅ R-6.1 تا R-6.12 همه انجام شد (ادامه: فازهای L، L2، L3).
- ⚠️ Dynamic strings با $variable intentionally left — نیاز به ICU system جداگانه
_(جزئیات: `git show a078dc2:PLAN.md`)_

### R-7: جداسازی محتوا از UI (Content Files)
✅ ✅ R-7.1 تا R-7.9 همه انجام شد: هر محتوا فایل مستقل در `assets/data/`.
- ⚠️ `content_registry.dart` فعلاً فقط فهرست است؛ هیچ فایل دیگری آن را import نمی‌کند (2026-09-22).
_(جزئیات: `git show a078dc2:PLAN.md`)_

## فاز ۱۶ — انتشار و QA نهایی ⛔ منسوخ
> نسخه‌ی بومی از 2026-09-13 حذف شد. فهرست معتبر: **فاز LAUNCH → L.3** (تست آفلاین همان‌جا باز است).

## ترتیب اجرا — Phase‌های بهینه

> **چرا این ترتیب؟** هر phase پایه phase بعدی است. Design System باید اول باشد چون همه widgets به آن وابسته‌اند. Filter UI بعد از Design System می‌آید. محتوا و audit آخر می‌آیند چون به کد ثابت نیاز دارند.

### Phase 1 — باگ‌های فوری ✅ (2026-06-29)
- ✅ همه انجام شد (۵ مورد).

### Phase 2 — Design System ✅ (2026-06-29)
- ✅ همه انجام شد (۴ مورد).

### Phase 3 — Filter Components ✅ (2026-06-29)
- ✅ همه انجام شد (۲ مورد).

### Phase 4 — Content Screens با Filter جدید ✅
- ✅ همه انجام شد (۶ مورد).

### Phase 5 — Auswendiglernen Restructure ✅ (2026-06-29)
- ✅ همه انجام شد (۴ مورد).

### Phase 6 — Data & Content Files ✅ (2026-06-29)
- ✅ همه انجام شد: Goethe B2 (۶۱)، ÖSD B2 (۱۲۱)، Redemittel 1010 (۹۰۸) و فایل‌های داده‌ی دیگر.

### Phase 7 — Bilingual Audit ✅ (2026-06-30)
- ✅ انجام شد.

### فاز DS — Design System — یک بار برای همیشه
✅ هدف: هر کامپوننت UI یک فایل اختصاصی دارد.
_(جزئیات: `git show a078dc2:PLAN.md`)_

### فاز ARCH — Architecture Hub — زیرساخت مرکزی (2026-07-04)
> هدف: هر سرویس/ابزار مرکزی یک فایل دارد — Screens فقط import می‌کنند.
> مکمل فاز DS: آنجا UI مرکزی شد، اینجا Logic/Infra مرکزی می‌شود.

#### ARCH-A: Skeleton — وضعیت واقعی (بررسی کد 2026-09-23)
- ✅ در استفاده: `core/network/api_client.dart` · `core/utils/formatters.dart` · `core/services/feature_flags.dart` · `core/services/cache_service.dart` · `core/services/app_logger.dart`
- ◻️ stub: `test/helpers/mock_data_factory.dart`
- 🗑️ دیگر وجود ندارند: `core/config/app_env.dart` · `core/services/permission_service.dart` (با حذف بومی/RevenueCat) · `ci.yml` ⇒ جایش `pruefen.yml` + `deploy-web.yml`.

#### ARCH-B: Implementation — ترتیب وابستگی ✅ B1–B11 (2026-07-04)
- [x] B1  `vox_colors.dart` — LIVE — CEFR/register/article/wordType/quiz tokens
- [x] B2  `formatters.dart` — LIVE — faDigits، countLabel، outOf، percent، relativeDate، timer
- [x] B3  `app_env.dart` — LIVE — RevenueCat keys via --dart-define (main.dart پاک شد) — ⛔ RevenueCat بعداً حذف شد (2026-09-13)
- [x] B4  `app_logger.dart` — LIVE — AppLogger(tag) + loggerProvider
- [x] B5  `feature_flags.dart` — LIVE — همه ۲۳ فلگ deck/feature
- [x] B6  `cache_service.dart` — LIVE — file-based TTL + getStale (offline fallback)
- [x] B7  `api_client.dart` — LIVE — ApiException typed + logging
- [x] B8  `permission_service.dart` — LIVE — notifications (mic/speech برای Sprechen آماده)
- [x] B9  `vox_search_field` — LIVE — متصل شد: **۱۱ list screen** (۹ template + ۲ redemittel)
- [x] B10 `vox_progress` (VoxQuizProgressBar + VoxStepDots) + `vox_empty_state` — LIVE
- [x] B11 `vox_snack_bar` + `vox_dialog` (quizResult/confirm/info) + `vox_chip`
- [x] B12 ✅ (تأیید 2026-09-22) `test/helpers/mock_data_factory.dart` + تست‌ها + CI (`pruefen.yml`، `deploy-web.yml`)

#### ARCH-C: Integration — اتصال Feature‌ها به مرکز ✅ عمده (2026-07-04)
> از طریق B9–B11 انجام شد — هر الگوی تکراری با نسخه مرکزی جایگزین شد:
- [x] Suchfelder: konnektoren، dativ، nvv، praepositionen، reflexiv، trennbar،
- [x] Quiz-Progress: همان ۹ + grammatik + cloze + exam_simulation
- [x] Result-Dialoge: ۹ quiz (redemittel، unregelm، reflexiv، trennbar، verb_praep،
- [x] رنگ‌ها: CEFR/register switches حذف شدند (۱۲ مکان → VoxColors)
- [x] Flags: comingSoon مرکزی شد
- [ ] باقی‌مانده (بعدی): vox_list_tile، vox_card، vox_app_bar، vox_section_header،
      vox_bottom_bar، vox_text_field در صفحات قدیمی‌تر (leitner، hoeren، lesen، more)

#### استپ‌های stub (2026-07-04) — وضعیت واقعی (2026-09-23)
- ✅ `core/services/backup_service.dart` — ساخته شد (S.2).
- ◻️ stub بی‌استفاده: `core/utils/debouncer.dart` · `validators.dart` · `extensions.dart`

#### استراتژی Integration (قانون برای همه صفحات آینده)
- صفحات جدید (Profile، Category، Product...) از روز اول **فقط import** می‌کنند:
  `VoxButton.primary(...)` · `VoxColors.cefrB2` · `Formatters.faDigits(n)` · `FeatureFlags.isLive(key)`
- **هرگز** local duplicate: رنگ، TextStyle، فرمت ارقام، دکمه، dialog درون screen تعریف نمی‌شود
- تغییر یک فایل مرکزی → کل اپ یکجا آپدیت می‌شود (همان اصل ۱ — Component Isolation)
- مرجع‌ها: PLAN.md (این فاز) + PROJECT_MAP.md (بخش Architecture Hub + Design System)

### Phase 14 — Modalverben ✅ (2026-07-04)
- ✅ همه انجام شد: `modalverben_data.json` (۷ فعل، صرف کامل) + صفحه‌ها و تمرین.

### Phase 15 — Grammatik-Themen (generisch) ✅ (2026-07-05)
- ✅ همه انجام شد: زیرساخت عمومی موضوع گرامر (`grammar_topic.dart` + `grammar_topic_screen.dart`).

### فاز G — Grammatik Vollausbau (تمام گرامر زبان آلمانی) [G1–G6 ✅]
> هدف: صفحه Grammatik کل گرامر آلمانی را پوشش دهد و مرحله‌به‌مرحله کامل شود.
> **نقشه مرجع: `GRAMMATIK_MAP.md`** — کاتالوگ ۹۳ موضوع + ۴ نمای مرتب‌سازی.
> منبع فعلی: `old files Lukasalmani/1/Grammatik` (۸۴ درس کامل سه‌زبانه با جدول/مثال/تمرین).
> منابع بیشتر بعداً از کاربر می‌رسد → فقط Katalog-Eintrag + Content-JSON اضافه می‌شود.
> اصل: کاتالوگ = تنها منبع حقیقت؛ نماها فقط سورت متفاوت همان کاتالوگ‌اند (reference نه کپی).
> ⚠️ در پایان هر Stufe: هم `GRAMMATIK_MAP.md` هم همین فاز آپدیت شود.

- [x] **G1** ✅ (2026-07-06) کاتالوگ گرامر: `grammatik_katalog.json` (۱۵ موضوع، ۹۳ مدخل) + مدل‌ها.
- [x] **G2** ✅ (2026-07-07) `GrammatikLektionScreen` — رندر درس از JSON سه‌زبانه.
- [x] **G2-alt** ✅ اصلاح شد (2026-09-16): منبع **ناقص نیست** — ۱۷ سند JSON کامل (۸۴ درس، ۳۳۶ تمرین) پشت‌سرهم
- [x] **G2-old** ✅ (تأیید 2026-09-22: explanationBlocks + relatedSlugs رندر می‌شوند) `GrammatikLektionScreen` — رندر Content-JSON (explanationBlocks سه‌زبانه +
- [x] **G3** ✅ (2026-09-16) ایمپورت محتوا I: verben-grundlagen(9) + tempus(5) + passiv(4) + konjunktiv(7)
- [x] **G4** ✅ (2026-09-16) ایمپورت محتوا II: verbergaenzungen(5) + ergaenzungssaetze(3) + nomen(6) + artikel(6)
- [x] **G5** ✅ (2026-09-16) ایمپورت محتوا III: adjektive(4) + adverbien(4) + pronomen(5) + praepositionen(5)
- [x] **G6** ✅ (2026-09-16) satzlehre + nebensaetze + temporalsaetze ⇒ همه‌ی ۸۴ درس زنده (۱۷ فایل در `assets/data/grammatik/`، محتوا بدون تغییر).
- [ ] **G7** تمرین‌ها — G7a–G7c **قبل از انتشار ✅**؛ **G7d/G7e بعد از انتشار** (تصمیم Lukas 2026-09-18، L.2e). مراحل:
  - [x] **G7a** ✅ (2026-09-16) ۳۳۶ تمرین منبع (۵ نوع) در هر درس، با جواب و توضیح.
  - [x] **G7b** ✅ (2026-09-16) آزمون هر سطح A1–C2: ۱۰ سؤال تصادفی، قبولی ۷۰٪ (`grammatik_niveautest.json`).
  - [x] **G7c** ✅ (2026-09-16) تمرین از جمله‌های مثال (فقط شکل‌های بی‌حدس، نوع تصادفی)؛ هر نوبت ۱۰ تمرین مخلوط.
        ⚠️ قاعده‌ی «بی‌حدس» در `GrammatikUebung.testTauglich`.
  - [x] **G7e ⇒ در فاز T.1 انجام شد (2026-09-25 دور ۸۶).** قبلاً: منتقل شد به فاز T.1 (2026-09-25 دور ۸۳، درخواست Lukas: قالب عمومی برای همه‌ی آزمون‌های آینده).** متن قدیم: ذخیره‌ی نتیجه‌ی آزمون سطح در داده‌ی کاربر (پشتیبان + همگام‌سازی، فاز S) — پایه‌ی بخش آینده‌ی «دست‌یافته‌ها».
  - [ ] **G7d** تمرین برای ردمیتل و deckهای دیگر.
- [ ] **G8** یکپارچه‌سازی: Global Search + لینک Leitner + گلاسری A–Z + منابع جدید کاربر

### فاز V — Vokabular-Datenbank (آرشیو بزرگ ~۲۶٬۰۰۰ کلمه) [طراحی نهایی ✅ / پیاده‌سازی باز] (2026-07-08)
> خواسته کاربر: آرشیو بزرگ کلمات. **هر کلمه ~۱۰۰ جمله** (DE/FA/EN). کاربر **هر بار یک کلمه**
> می‌فرستد و Claude آن را با همه اطلاعات ذخیره می‌کند. اپ باید **آفلاین** بماند، **سریع load**
> شود، و **چند سورت هم‌زمان** داشته باشد (A1–C2، Akkusativ، Adjektive، …).

> ⚠️ **Update 2026-09-16 (V.2, Entscheidung von Claude im Rahmen von Lukas' Vollmacht — Lukas kann sie kippen):**
> Die Architektur unten („prebuilt `vocab.db`, beim ersten Start kopieren, Tabelle `sentences`") stammt aus
> der Zeit der nativen App und der ~100-Sätze-Idee. Beides gilt nicht mehr: VOX ist seit 2026-09-13 eine
> **reine Web-App**, und V.0 hat die Karten auf **2 Beispiele** festgelegt. Umgesetzt ist deshalb ein
> **Wortindex** statt einer zweiten SQLite-Datenbank — Begründung und Aufbau unter **V.2** unten.
> Die ältere Beschreibung bleibt als Geschichte stehen.

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
- [x] **V.icon** ✅ (2026-07-14) `grammatikon_painter.dart` + `grammatikon_resolver.dart` + `WortSymbol` — فقط از `GrammatikonSpec`.
      ⚠️ نماد هرگز در داده ذخیره نمی‌شود؛ همیشه از wortart + details محاسبه می‌شود.

**🗺️ نقشه‌ی Wortschatz کاربر (۵ مرحله، 2026-07-14) — همه به Flutter نه React Native:**
- [x] **مرحله ۱** سیستم طراحی: WortSymbol + Resolver خودکار (کارت→نماد) ✅ = V.icon بالا
- [x] **مرحله ۲** ✅ (2026-07-14) متن رنگی (`WortText` + `endung_resolver.dart`) + کارت لیست (`wort_card.dart`).
- [x] **مرحله ۳** ✅ (2026-07-14) صفحات Vokabular — آرشیو جدا حذف شد؛ کارت‌ها در «Alle Wörter» (`wortschatz_list_screen.dart`) ادغام شدند (تصمیم کاربر).
- [x] **مرحله ۴** ✅ (2026-07-14) صفحه‌ی کلمه (`wort_seite_screen.dart`) — با بخش «Gegenteil» بعد از Synonyme.
      ⚠️ ظاهر (رنگ/شکل) همیشه در کد ساخته می‌شود، هرگز ذخیره نه؛ اصطلاحات گرامری آلمانی = محتوا (تغییرناپذیر).
- [x] **مرحله ۵** ✅ (2026-07-14) Import-Pipeline — SUPER-PROMPT v3.0 (آرایه‌ی ۱–۱۰ کلمه؛ `etymologie` دوزبانه) + validator.
      ⚠️ قواعد پرامپت (از جمله Regel 15: `rektion`/`mit_praeposition` هرگز null اگر حرف اضافه‌ی ثابت هست) فقط در `old files Lukasalmani/Wort prompt` و `vokab_schema.dart`.

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
- [x] **Audit** ✅ (2026-07-15) ۸ فایل `assets/data`: ۷ دِک پاس؛ نقص `praepositionen_data.json` (۱۳۴ عضو بدون جمله‌ی نمونه) ⇒ رفع شد (مورد بعد).
- [x] **اجرا ✅ (2026-07-15):** ۱۳۴ جمله‌ی {de, fa, en} با الگوی روشن Lemma + Präposition + Kasus
- [x] **تأیید ✅ (2026-07-15):** Re-Audit = ۰ عضو بدون جمله؛ flutter analyze پاک؛ ۳۳ تست سبز.

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
- [x] **V.1** ✅ (2026-07-14) ساختار پوشه `assets/vocab/<wortart>/<id>.json` (۱۰ پوشه در pubspec)
- [x] **V.2 Wortindex** ✅ (2026-09-16) — `tool/vokab_index.dart` هنگام build فهرست را می‌سازد؛ کارت کامل lazy.
      ⚠️ فهرست هرگز دستی نوشته یا commit نمی‌شود (`.gitignore`). آفلاین: فقط کلمه‌های بازشده در cache مرورگرند.
- [x] **V.3** ✅ entfällt — in V.2 aufgegangen (kein `vocab.db` zu kopieren; Filter/Suche laufen im Speicher über den Index).
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

**❗ Zwei Klarstellungen zum Wort-Prompt (2026-09-15, am Code geprüft):**
1. **Ein Wort = EINE Karte, nicht zwei.** `old files Lukasalmani/Wort prompt` (SUPER-PROMPT v3.0),
   Regel 2: alle Übersetzungsfelder sind zweisprachige Objekte `{ fa: …, en: … }` in
   **derselben** Datei. Regel 10 hält ausdrücklich fest, dass die App laut Einstellungen
   **genau eine** Sprache zeigt, nie fa und en zugleich; `vokabUeb()` in
   `features/vokabular/widgets/wortseite_bausteine.dart` setzt das über `AppL10n.isFa` um.
   ⚠️ Karten je Sprache getrennt zu erzeugen würde die Kosten verdoppeln und kollidierende
   IDs erzeugen (`adjektiv_stolz` zweimal) — `vokabular_import.dart` verwürfe die zweite.
2. **Das Aussehen der Wortseite steht NICHT im Prompt.** Der Prompt sagt in seinem Kopf
   ausdrücklich, er enthalte nur linguistische Daten und keine Icon-, Farb- oder
   Render-Informationen, weil die App sie berechnet. Was er sehr wohl vorgibt, sind
   Reihenfolge und Verhalten: Gegenteil direkt nach Synonyme und ohne Beispielsatz
   (Regel 10), `wortnetz` als klickbare Verweise (Regel 13), Beispielsätze als Vorlage für
   Lückentext (Regel 9), Perfekt und Genitiv baut die App selbst (Regel 7).
   Das tatsächliche Aussehen liegt in `core/grammatikon/grammatikon_spec.dart` (Farben,
   Formen), `features/vokabular/screens/wort_seite_screen.dart` (Abschnittsfolge) und
   `wortseite_bausteine.dart`. Code und Prompt stimmen überein — geprüft 2026-09-15.

**Konfliktregel (Nutzerentscheidung 2026-09-15): „höchstes Fach gewinnt".**
Beim Zusammenführen zweier Stände wird **nicht** der jüngste Zeitstempel genommen, sondern je
Karte das höhere Leitner-Fach. Begründung: Lernfortschritt geht nur vorwärts; so geht Offline-
Arbeit nie verloren. Für Notizen und Kategorien gilt Vereinigung statt Überschreiben.

**Gemeinsame Sicherungs-Hülle (Vertrag mit Root-in, kein geteilter Code):**
`{ "version": <int>, "exportedAt": <ISO>, "app": "vox" | "root-in", "payload": { … } }`
Gleiche Hülle, unterschiedliche Nutzlast. In beiden PLAN-Dateien festgehalten.

- [x] **S.0 یک محل ذخیره** ✅ — از راه S.0a–S.0c (جدول `ArchivLeitner`).
- [x] **S.1 `persist()`** ✅ (2026-09-15) — `core/utils/persistent_storage.dart` (از Root-in).
- [x] **S.1b دعوت به نصب** ✅ (2026-09-15) — `core/utils/install_state.dart`.

  **⚠️ Zwei Lehren aus dem roten Lauf dabei (2026-09-15) — beide wiederholbar:**
  · **Mehrere Dateien gehören in EINEN Commit.** Claude hat sie einzeln über die
    Contents-API geschoben. Der erste Commit enthielt eine Datei, die auf noch nicht
    existierende Dateien exportierte ⇒ `flutter analyze` rot, und jeder Push stieß einen
    Deploy an, der den vorigen abbrach (7 abgebrochene Läufe). **Ab jetzt über die Git-Data-API
    committen** (blobs → tree → commit → ref), ein Commit je Arbeitsschritt.
  · **Claude kann die CI-Logs nicht lesen.** GitHub liefert sie von
    `*.blob.core.windows.net` aus; diese Domain steht nicht in Claudes Netz-Freigabe. Die
    Fehlermeldung war also unsichtbar, und die Ursache musste erschlossen werden (sie lag in
    `main.dart`: `dart:async` + `unawaited` + `catchError` statt des im Repo bewährten
    try/catch). **Konsequenz: in Dart-Dateien nur Konstrukte verwenden, die im Repo schon
    vorkommen, und übernommenen Code zeichengleich kopieren — nicht umbenennen.**
- [x] **S.2 Export/Import** ✅ (2026-09-15) — `backup_service.dart`: پشتیبان فایل واقعی.
      ⚠️ وارد کردن همیشه **ادغام** است، هرگز جایگزینی.
- [~] **S.3 Supabase-Konto** — `auth.users` geteilt, aber **jedes Repo besitzt seine eigenen
      Tabellen**: `schema.sql` bleibt in Root-in, VOX hat ein eigenes `supabase/vox_tables.sql`.
  - [x] **S.3 گام ۱** ✅ (2026-09-15) — `app_config.dart` (`--dart-define`) + `auth_service.dart`؛ بدون Secrets = بدون سرور و بدون هیچ درخواست شبکه.
        ⚠️ VOX نام کاربری ندارد (`profiles` مال Root-in)؛ جدول خودش `vox_backups` است، نه `backups`.
  - [x] **S.3 گام ۲** ✅ (2026-09-15) — ورود/ثبت‌نام؛ بدون پیکربندی، بخش حساب اصلاً دیده نمی‌شود.
  - [x] **S.3 گام ۳** ✅ (2026-09-15) — کپی در `vox_backups` با همان محتوای S.2؛ ادغام «بالاترین جعبه برنده است».
  - [x] **S.3 Konto löschen ✅ L.1d (2026-09-22):** Entscheidung Lukas — ein Konto, ein Löschen, für BEIDE Apps.
  ⚠️ **Voraussetzung für Schritt 2:** die Secrets `SUPABASE_URL` und `SUPABASE_ANON_KEY` im
  vox-Repo (Settings → Secrets and variables → Actions) und `supabase/vox_tables.sql` einmal im
  SQL-Editor des Supabase-Projekts ausgeführt. Bis dahin bleibt alles wirkungslos — aber heil.
- [x] **S.4 توضیح صادقانه** ✅ (2026-09-16) — کارت «پشتیبان» در Settings می‌گوید داده واقعاً کجاست.
- [x] **S.5 حذف‌ها و کلمه‌های اپ در قرارداد** ✅ (2026-09-15).
      ⚠️ عضویت = «آخرین کار برنده است»؛ پیشرفت = «بالاترین جعبه برنده است». زمان به میلی‌ثانیه (`amMs`).
- [x] **S.6 شناسه‌ی ثابت لیست** ✅ (2026-09-16) — لیست‌های خودی شناسه‌ی بین‌دستگاهی دارند؛ پیشوند `eigen:` می‌ماند.
      ⚠️ دو دستگاه که مستقل لیستی هم‌نام بسازند ⇒ دو لیست جدا.

**Planänderung 2026-09-15 — S.0a, damit die Blockade nicht alles aufhält.**
S.0 braucht `build_runner` und ist gesperrt. Statt zu warten, kommt eine **Fassade** davor —
reines Dart, kein Codegen:

- [x] **S.0a-1** ✅ `core/backup/nutzer_zustand.dart` — قرارداد (Dart خالص، تست‌پذیر).
      ⚠️ شناسه‌ی لایتنر متن است، هرگز شماره‌ی drift. ادغام: بالاترین جعبه برنده است (کار آفلاین هرگز گم نمی‌شود).
- [x] **S.0a-2** ✅ `core/backup/user_state_repository.dart` — Fassade؛ تنها جایی که جدول‌های کاربر را می‌شناسد.
      ⚠️ هیچ‌چیز حذف نمی‌شود؛ بازیابی هرگز پیشرفت را کم نمی‌کند.
⇒ **Seit S.0a kennt alles oberhalb nur noch `NutzerZustand`.** S.2 fasst die Ablagen nicht
  direkt an; es geht ausschließlich über die Fassade.

- [x] **S.0b** ✅ (2026-09-16) ذخیره‌ی زیر Fassade ⇒ drift (`ArchivLeitner`، schema 2→3).
- [x] **S.0c** ✅ (2026-09-16) لیست‌های آرشیو ⇒ drift (schema 3→4)؛ ابزار `build-runner.yml` ساخته شد.

**Zwingend bleibt: S.0a vor S.2 und S.3** — sonst wird jeder Serializer zweimal geschrieben.

---

### فاز A — Automatisierung der Worterfassung [باز شد 2026-09-15]
> **مسئله (اندازه‌گیری‌شده، نه حدس):** Pipeline سالم است؛ گلوگاه **انسانی** است. از ۲۰۲۶-۰۷-۱۴ تا
> ۲۰۲۶-۰۹-۱۵ — دو ماه — تعداد کارت‌ها به ۸۷ رسید (۰٫۳٪ از ~۲۶٬۲۰۰). با همین آهنگ پروژه هرگز تمام نمی‌شود.
> **تصمیم کاربر:** ترتیب **الفبایی** می‌ماند؛ سرعت از خودکارسازی می‌آید.

**اصل راهنما: فقط «تولید» خودکار می‌شود، نه «اعتبارسنجی».** اعتبارسنجی همچنان تنها و تنها
`vokabPruefeKarte` در `lib/features/vokabular/data/vokab_schema.dart` است (یک منبع برای اپ + تول + CI).
هیچ منطق validation دومی نوشته نمی‌شود — هر ابزار کمکی فقط «pre-flight» است و حرف آخر را Dart می‌زند.

- [x] **A.1 `tool/backlog.py`** ✅ (2026-09-15) — backlog reader: از `old files Lukasalmani/Wörter/*.txt` و
- [x] **A.2 `tool/sync_backlog.py`** ✅ (2026-09-15) — **اجرا شد: ۴۵ مارک نو، ۰ حذف؛ اجرای دوم بدون تغییر (idempotent)** — مارک‌های `✓ ` را از روی `assets/vocab/` بازسازی می‌کند
      ⚠️ (2026-09-24 دور ۶۳) `wortartKorrektur` را نمی‌شناسد (✓ عددهای numerale را برمی‌دارد) ⇒ در روال **فقط** `dart run tool/naechste_woerter.dart --abhaken` (همان vokabId + wortartKorrektur). این ابزار را برای ✓ اجرا نکن.
- [x] **A.3** ✅ `tool/generate_words.py` — سازنده‌ی کلمه با SUPER-PROMPT (مستقیم از `Wort prompt`)، سقف ۵۰۰.
- [x] **A.4** ✅ (2026-09-16) `vokabular-autofill.yml`.
      ⚠️ نیاز به `ANTHROPIC_API_KEY` — هزینه دارد و باید شفاف گزارش شود.
- [x] **A.5** ✅ گزارش: هر اجرا یک خلاصه در Job-Summary (چند کلمه، چند Warnung، هزینه‌ی تقریبی).
- [x] **A.6 روش ساخت کلمه‌ها — ✅ تصمیم Lukas (2026-09-23): Claude در چت طبق Wort prompt، هر بار «ده کلمه جدید» ⇒ «📚 روال».** متن زیر فقط سابقه است (گزینه‌های 2026-09-16)؛ دیگر مانع کار نیست.
      _(سابقه)_ **⚠️ قاعده‌ی قدیم برای Claude:** این قدم را **هرگز خودسرانه شروع نکن** — حتی اگر اولین قدم باز PLAN باشد
      و حتی با وکالت کلی 2026-09-15. وقتی زمانش رسید (پیش از اولین اجرای واقعی ساخت کلمه، یا وقتی
      V.2 تمام شد)، **حتماً از Lukas بپرس از کدام روش پیش برویم** و فقط بعد از جواب او کاری بکن.
      گزینه‌ها (تخمین 2026-09-16، اندازه‌ی میانگین کارت فعلی ≈ ۴ KB، ~۲۶٬۱۰۰ کلمه باقی):
      | روش | هزینه | سرعت تقریبی | لازم دارد |
      |---|---|---|---|
      | **API** (`vokabular-autofill.yml`، مدل `claude-sonnet-5`) | ~۴۰۰–۶۰۰ $ (با Batch API حدود نصف) | ۱–۲ هفته زمان ماشین | Secret `ANTHROPIC_API_KEY` + V.2 قبلش |
      | **دستی در چت با Claude** | بدون هزینه‌ی جدا (سقف اشتراک) | ~۲۰–۴۰ کارت در هر جلسه ⇒ ~۸۷۰ جلسه | یک مسیر «فقط import»: کارت‌ها در `import_inbox/` ← GitHub همان بررسی Dart + تست ← commit |
      | **Claude Code** (با اشتراک) | بدون هزینه‌ی جدا (سقف اشتراک) | احتمالاً چند صد کارت در هر نوبت | همان مسیر «فقط import» |
      ⛔ **Lukas 2026-09-16 (قطعی):** کارت‌های کلمه **همیشه توسط Claude و بر اساس پرامپت** (`old files Lukasalmani/Wort prompt`) ساخته می‌شوند — **نه** با تبدیل منابع/جزوه‌های Lukas. (پیشنهاد «تبدیل منابع» رد شد.) سؤال A.6 فقط این است که Claude از کدام مسیر بسازد: API · چت · Claude Code · ترکیب.
      ترکیب روش‌ها هم ممکن است. در همه‌ی روش‌ها اعتبارسنجی فقط `vokab_schema.dart` است و پرامپت فقط
      از `old files Lukasalmani/Wort prompt` خوانده می‌شود.
      ⚠️ مسیر «فقط import» هنوز **ساخته نشده** — آن هم جزو همین تصمیم است، نه قبل از آن.

**⚠️ ترتیب اجباری:** A.1/A.2 بی‌خطرند و می‌توانند همین حالا بروند. **A.3/A.4 نباید قبل از V.2
فعال شوند** — چون `vokabular_controller` همه‌ی کارت‌ها را در startup می‌خواند و یک اجرای موفق
با چند هزار کلمه اپ زنده را می‌شکند. سقف امن فعلی: **~۵۰۰ کارت**.
✅ **V.2 انجام شد (2026-09-16)** — دلیل فنی این سقف از بین رفت. سقف `--grenze 500` در
`tool/generate_words.py` **عمداً** باقی است: حالا فقط جلوی هزینه‌ی ناخواسته را می‌گیرد و برداشتنش جزو
تصمیم A.6 گرفته شد (2026-09-23، «📚 روال»).
⚠️ **یافته‌ی دوم 2026-09-16 (برای A.6, هنگام L.1a):** در `vokabular-autofill.yml` قدم «Import + Validierung»
`dart run tool/vokabular_import.dart 2>&1 | tee …` است؛ shell پیش‌فرض GitHub (`bash -e`) بدون `pipefail` است ⇒
خروجی قرمز import **پنهان می‌شود** و workflow ادامه می‌دهد — برخلاف قاعده‌ی «Fehler > 0 ⇒ هیچ commit». همراه با
یافته‌ی زیر، قبل از اولین اجرای واقعی درست شود (`set -o pipefail`).
⚠️ **یافته‌ی 2026-09-16 (برای A.6):** `vokabular-autofill.yml` با `GITHUB_TOKEN` push می‌کند؛ چنین commitی
**هیچ workflow دیگری را راه نمی‌اندازد** ⇒ `deploy-web.yml` بعد از آن اجرا **نمی‌شود** و کلمه‌های جدید
منتشر نمی‌شوند (متن «deploy-web.yml baut jetzt neu» در خلاصه‌ی آن workflow درست نیست). قبل از اولین اجرای
واقعی باید حل شود — همراه ساخت مسیر «فقط import».

---

### فاز L — L10n: زبان فقط از Settings [Step 1 ✅ Audit — 2026-07-07]
✅ قوانین کاربر (blueprint 2026-07-07):
_(جزئیات: `git show a078dc2:PLAN.md`)_

### فاز L2 — Massen-Lokalisierung: «هیچ FA در حالت EN» [L2-A..E ✅ / L2-F باز] (2026-07-07)
✅ شکایت کاربر: با انتخاب English هنوز خیلی جاها فارسی است. Audit: **۶۴۱ رشته FA hardcoded در ۹۸ فایل**
_(جزئیات: `git show a078dc2:PLAN.md`)_

### فاز L3 — Content-Zweisprachigkeit: همه محتواها FA+EN [کامل ✅] (2026-07-07)
✅ شکایت کاربر: بعضی صفحات هنوز **محتوایشان** فارسی است (مثال ۱: Auswendiglernen →
_(جزئیات: `git show a078dc2:PLAN.md`)_

### Phase 13 — Redemittel 1010 ✅ (2026-07-04)
- ✅ همه انجام شد: ۹۰۸ عبارت (منبع ۹۰۸ دارد، نه ۱۰۱۰).

### Phase 12 — Unregelmäßige Verben ✅ (2026-07-03)
- ✅ همه انجام شد.

### Phase 11 — Verben mit Präpositionen ✅ (2026-07-03)
- ✅ همه انجام شد.

### Phase 10 — Trennbare / Untrennbare Verben ✅ (2026-07-03)
- ✅ همه انجام شد.

### Phase 9 — Reflexivverben ✅ (2026-07-03)
- ✅ همه انجام شد.

### Phase 8 — انتشار (فاز ۱۶) ⛔ منسوخ
> فقط تاریخچه — فهرست معتبر: **فاز LAUNCH → L.3**.

---

## فازهای تکمیل‌شده (آرشیو)
✅ | فاز | عنوان | وضعیت |
_(جزئیات: `git show a078dc2:PLAN.md`)_

## تصمیمات تکنیکی
| موضوع | تصمیم | دلیل |
|-------|--------|------|
| State | flutter_riverpod (manual) | بدون codegen boilerplate |
| DB | drift (SQLite) | type-safe، offline |
| Router | go_router | declarative، deep link |
| Audio | just_audio + flutter_tts | بهترین Flutter audio |
| Charts | fl_chart | محبوب‌ترین Flutter chart |
| ~~Subscriptions~~ | ~~RevenueCat~~ | ⛔ حذف شد (2026-09-13) — وب‌اپ رایگان، بدون اشتراک |
| Font | Vazirmatn (google_fonts) | FA+DE+EN یک فونت |
| Color API | withValues(alpha:) | withOpacity deprecated |
| L10n | strings در app_l10n.dart | بدون .arb files |
| DAO | Plain Dart class | بدون @DriftAccessor |
| Upsert | DoUpdate(target:[german,wordType]) | UNIQUE constraint صحیح |

## 🏁 مرحله‌ی آخر — کلمه‌هایی که وارد اپ نشده‌اند (آخرین کلمه‌ها برای بررسی و انتشار)

> 🔔 **یادآوری برای Claude (Lukas، 2026-10-14):** وقتی همه‌ی کلمه‌ها — از جمله همه‌ی کلمه‌های کنار گذاشته‌شده‌ی همین بخش — وارد اپ شدند، به Lukas یادآوری کن فهرست کلمه‌های کتاب‌ها (اول «A1 Starten wir») را بفرستد ⇒ PLAN «🗂️ فاز F» بند F.4.

> **تصمیم Lukas (2026-09-24):** هر کلمه‌ای از فهرست‌های `old files Lukasalmani/Wörter/` که به **هر دلیلی** کارت نمی‌گیرد، همین‌جا ثبت می‌شود — با تاریخ، فهرست و دلیل.
> این‌ها **آخرین کلمه‌هایی** هستند که بررسی و منتشر می‌شوند: بعد از تمام شدن هر چهار فهرست، Lukas درباره‌ی تک‌تکشان تصمیم می‌گیرد.
> 📌 **کی بررسی؟** وقتی هر چهار فهرست تمام شد (قاعده‌ی کامل: «📚 روال ده کلمه جدید» ⇒ «🔒 قاعده‌ی ثابت»). تا آن موقع فقط ردیف اضافه می‌شود، چیزی ساخته نمی‌شود.
> ⚙️ هم‌زمان باید در `zurueckgestellt` در `tool/naechste_woerter.dart` باشند (ابزار از آن‌ها رد می‌شود). **این جدول و آن فهرست همیشه یکی‌اند.**
> کلمه‌هایی که با Wortart دیگری ساخته شدند (مثل aberhundert ⇒ numerale) این‌جا نیستند — کارت دارند (`wortartKorrektur`).
> 
> 🔀 **فعل‌های دوگانه‌ی جداشدنی/جدانشدنی — تصمیم Lukas (2026-10-13):** فعل‌هایی مثل **über**fahren («عبور دادن») ↔ über**fahren** («زیر گرفتن»)، übergehen، überlaufen، umbrechen، durchfahren، durchdenken، obliegen و هر فعل دیگری که هم جداشدنی و هم جدانشدنی است (یا جداشدنی بودنش مطمئن نیست) **فعلاً کنار می‌روند** و همین‌جا ثبت می‌شوند (دلیل: «هم جداشدنی هم جدانشدنی …»).
> 1. **کی؟** فقط **بعد از تمام شدن همه‌ی افعال** (هر دو فهرست فعل) — نه زودتر.
> 2. **چطور؟** اول همه‌ی تصمیم‌ها گرفته می‌شود — **هم کارت** (یک کارت یا دو کارت، id، ساختار داده) **هم شکل هندسی/نماد Grammatikon** و هر چیز دیگر. این تصمیم‌ها مثل «Wort prompt» یک **پرامپت کامل و جدا** می‌گیرند.
> 3. **ترتیب:** تصمیم‌های Lukas ⇒ نوشتن پرامپت ویژه ⇒ ثبت در PLAN و PROJECT_MAP ⇒ **بعد** شروع ساخت این افعال. تا آن موقع Claude برای این گروه **هیچ کارتی نمی‌سازد** و پیشنهاد ساخت زودتر هم نمی‌دهد.
> 4. در روال عادی کلمه‌ها: هر فعل دوگانه‌ی تازه (مثلاً umfahren، umgehen، unterhalten، wiederholen …) بی‌پرسش کنار می‌رود — مثل همین ردیف‌ها.

| # | کلمه | فهرست | تاریخ | دلیل | تصمیم Lukas |
|---|---|---|---|---|---|
| 1 | abatisch | `Adjektive.txt` | 2026-09-23 | معنای مطمئنی ندارم (قاعده‌ی ۱۴ پرامپت: حدس ممنوع) | — |
| 2 | abdikativ | `Adjektive.txt` | 2026-09-24 | معنای مطمئنی ندارم (قاعده‌ی ۱۴ پرامپت: حدس ممنوع) | — |
| 3 | afrikaans | `Adjektive.txt` | 2026-09-24 | معنا روشن است (مربوط به زبان آفریکانس)، ولی مطمئن نیستم که در آلمانی به‌عنوان **صفت** رایج باشد — معمولاً اسم است: das Afrikaans (قاعده‌ی ۱۴: حدس ممنوع) | — |
| 4 | aldente | `Adjektive.txt` | 2026-09-24 | املا مشکوک: در فهرست سرهم نوشته شده، ولی Duden آن را دوکلمه‌ای می‌نویسد («al dente»، معنی: نیم‌پز/قابل جویدن برای پاستا). ساختن کارت با املای فهرست یعنی املای غلط؛ با املای درست یعنی id دیگری غیر از فهرست ⇒ Lukas تصمیم بگیرد | — |
| 5 | aleppinisch | `Adjektive.txt` | 2026-09-24 | معنا روشن است (مربوط به شهر حلب/Aleppo)، ولی مطمئن نیستم که این شکل صفت در آلمانی رایج و در Duden ثبت باشد (قاعده‌ی ۱۴: حدس ممنوع) | — |
| 6 | allenfallsig | `Adjektive.txt` | 2026-09-24 | شکل ثابت‌شده‌ای برایش نمی‌شناسم: فقط قید «allenfalls» رایج است؛ صفتِ «allenfallsig» در Duden نیست (قاعده‌ی ۱۴: حدس ممنوع) | — |
| 7 | altaltbacken | `Adjektive.txt` | 2026-09-24 | املا مشکوک: احتمالاً «altbacken» (کهنه، بیات) است که در فهرست با «alt» اضافه تکرار شده؛ ساختن با املای فهرست یعنی املای غلط ⇒ Lukas تصمیم بگیرد | — |
| 8 | Altdorfer | `Adjektive.txt` | 2026-09-24 | با حرف بزرگ؛ اسم خاص/صفت مکانی (مربوط به شهر Altdorf، صرف‌ناپذیر) — صفت معمولی نیست و کدام Altdorf مقصود است روشن نیست | — |
| 9 | altkrank | `Adjektive.txt` | 2026-09-24 | معنا و کاربرد رایجش را مطمئن نمی‌دانم (قاعده‌ی ۱۴: حدس ممنوع) | — |
| 10 | amaranten | `Adjektive.txt` | 2026-09-25 | معنا/کاربرد مطمئن نیست (کهنه؟ «به رنگ تاج‌خروس» یا «از گیاه آمارانت»؟) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 11 | ambient | `Adjektive.txt` | 2026-09-25 | در آلمانی بیشتر اسم است (das Ambient / سبک موسیقی Ambient)؛ کاربرد رایجش به‌عنوان **صفت** مطمئن نیست | — |
| 12 | amethysten | `Adjektive.txt` | 2026-09-25 | معنا مطمئن نیست: «ساخته‌شده از آمتیست» یا «به رنگ آمتیست»؟ (amethystfarben جدا ساخته شد) | — |
| 13 | amphibolisch | `Adjektive.txt` | 2026-09-25 | دو معنای ممکن از دو رشته (منطق: «دوپهلو» / کانی‌شناسی: «مربوط به آمفیبول») — کدام مقصود است مطمئن نیستم | — |
| 14 | anamorph | `Adjektive.txt` | 2026-09-25 | معنا بسته به رشته فرق می‌کند (اپتیک/زیست‌شناسی/قارچ‌شناسی) و رایج‌ترینش را مطمئن نمی‌دانم | — |
| 15 | anelliert | `Adjektive.txt` | 2026-09-25 | نه معنا و نه شکل ثبت‌شده‌ای برایش می‌شناسم (احتمالاً اصطلاح خیلی تخصصی یا املای غلط) | — |
| 16 | anotherm | `Adjektive.txt` | 2026-09-25 | معنا و رشته‌ی کاربردش را مطمئن نمی‌دانم (شاید اصطلاح لیمنولوژی/دمای آب؟) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 17 | antichretisch | `Adjektive.txt` | 2026-09-25 | اصطلاح حقوقی خیلی تخصصی (احتمالاً از Antichrese: نوعی رهن که طلبکار از درآمد مال استفاده می‌کند) — معنای دقیق مطمئن نیست | — |
| 18 | appendikuliert | `Adjektive.txt` | 2026-09-25 | معنا و رشته‌ی کاربردش را مطمئن نمی‌دانم (شاید زیست‌شناسی: «دارای زائده»؟) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 19 | aretologisch | `Adjektive.txt` | 2026-09-25 | دو معنای ممکن (مربوط به «علم فضیلت‌ها» یا به «روایت معجزه‌ها» در دین‌پژوهی) — کدام مقصود است مطمئن نیستم | — |
| 20 | arschig | `Adjektive.txt` | 2026-09-25 | بی‌ادبانه/عامیانه‌ی زشت؛ معنا و کاربرد صفتی رایجش را مطمئن نمی‌دانم (قاعده‌ی ۱۴: حدس ممنوع) | — |
| 21 | arschlos | `Adjektive.txt` | 2026-09-25 | نه معنا و نه شکل ثبت‌شده‌ای برایش می‌شناسم (احتمالاً املای غلط) | — |
| 22 | assi | `Adjektive.txt` | 2026-09-25 | عامیانه (کوتاه‌شده‌ی asozial)؛ Duden آن را به‌صورت «der Assi» (اسم) و «assig» (صفت) ثبت کرده — کاربرد صفتیِ «assi» مطمئن نیست | — |
| 23 | athermisch | `Adjektive.txt` | 2026-09-25 | معنا و رشته‌ی کاربردش را مطمئن نمی‌دانم («نفوذناپذیر برای گرما» یا «بدون تولید گرما»؟) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 24 | ausheimisch | `Adjektive.txt` | 2026-09-25 | معنا روشن به نظر می‌رسد («غیربومی»)، ولی مطمئن نیستم که در آلمانی امروز رایج و در Duden ثبت باشد (شاید گویشی/کهنه) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 25 | austral | `Adjektive.txt` | 2026-09-25 | معنای احتمالی «جنوبی» (در نجوم/جغرافیا)، ولی مطمئن نیستم که به‌عنوان صفت مستقل در آلمانی رایج و ثبت‌شده باشد — قاعده‌ی ۱۴: حدس ممنوع | — |
| 26 | averbal | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش را مطمئن نمی‌دانم («غیرکلامی»؟ «بدون فعل»؟) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 27 | azentrisch | `Adjektive.txt` | 2026-09-25 | معنا و رشته‌ی کاربردش را مطمئن نمی‌دانم («بی‌مرکز»؟) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 28 | azephal | `Adjektive.txt` | 2026-09-25 | دو معنای ممکن از دو رشته (پزشکی: «بدون سر» / عروض: «مصراع بی‌آغاز») — کدام مقصود است مطمئن نیستم | — |
| 29 | bananig | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش را مطمئن نمی‌دانم (عامیانه؟) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 30 | bannig | `Adjektive.txt` | 2026-09-25 | گویشی (شمال آلمان، به معنی «خیلی»)، احتمالاً قید نه صفت — مطمئن نیستم | — |
| 31 | basalten | `Adjektive.txt` | 2026-09-25 | معنا مطمئن نیست («ساخته‌شده از بازالت»؟) و ثبتش در Duden را نمی‌دانم | — |
| 32 | basiklin | `Adjektive.txt` | 2026-09-25 | اصطلاح تخصصی (گیاه‌شناسی؟)، معنای دقیق مطمئن نیست | — |
| 33 | basten | `Adjektive.txt` | 2026-09-25 | معنا مطمئن نیست («ساخته‌شده از لیف»؟) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 34 | batisten | `Adjektive.txt` | 2026-09-25 | معنا مطمئن نیست («از پارچه‌ی باتیست»؟) و رایج بودنش را نمی‌دانم | — |
| 35 | bebuscht | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش را مطمئن نمی‌دانم («بوته‌دار»؟) | — |
| 36 | bebust | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست (عامیانه/زشت؟) | — |
| 37 | bedonnert | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش را مطمئن نمی‌دانم (عامیانه؟ «خل»؟) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 38 | befotzt | `Adjektive.txt` | 2026-09-25 | نه شکل و نه معنای ثبت‌شده‌ای برایش می‌شناسم (احتمالاً واژه‌ی زشت/املای غلط) | — |
| 39 | begeißelt | `Adjektive.txt` | 2026-09-25 | معنا و رشته‌ی کاربردش مطمئن نیست (زیست‌شناسی: «تاژک‌دار»؟) | — |
| 40 | begrannt | `Adjektive.txt` | 2026-09-25 | اصطلاح تخصصی (گیاه‌شناسی: «سیخک‌دار»؟)، معنای دقیق مطمئن نیست | — |
| 41 | behemdet | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست («پیراهن‌پوش»؟) | — |
| 42 | behost | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست («شلوارپوش»؟) | — |
| 43 | behuft | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست («سم‌دار»؟) | — |
| 44 | beinfarben | `Adjektive.txt` | 2026-09-25 | معنا مطمئن نیست («به رنگ استخوان»؟) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 45 | bekrallt | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست («چنگال‌دار»؟) | — |
| 46 | bemähnt | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست («یال‌دار»؟) | — |
| 47 | bemützt | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست («کلاه‌به‌سر»؟) | — |
| 48 | bepelzt | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست («خزپوش»؟) | — |
| 49 | beredet | `Adjektive.txt` | 2026-09-25 | شکل مشکوک: احتمالاً با «beredt» (سخنور) اشتباه شده یا صفت مفعولی bereden است — مطمئن نیستم | — |
| 50 | berindet | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست («پوست‌دار (درخت)»؟) | — |
| 51 | bernsteinen | `Adjektive.txt` | 2026-09-25 | معنا مطمئن نیست («ساخته‌شده از کهربا»؟)؛ bernsteinfarben جدا ساخته شد | — |
| 52 | berstig | `Adjektive.txt` | 2026-09-25 | نه معنا و نه شکل ثبت‌شده‌ای برایش می‌شناسم | — |
| 53 | berüscht | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست («چین‌دار (لباس)»؟) | — |
| 54 | beschilft | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست («نیزارپوش»؟) | — |
| 55 | beschürzt | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست («پیش‌بند‌پوش»؟) | — |
| 56 | besoffenbesondere | `Adjektive.txt` | 2026-09-25 | خطای فهرست: دو کلمه (besoffen + besondere) سرهم نوشته شده‌اند؛ Lukas تصمیم بگیرد | — |
| 57 | besonderes | `Adjektive.txt` | 2026-09-25 | شکل صرف‌شده است نه شکل پایه (صفت «besondere» فقط صرف‌شده به کار می‌رود) — شکل درست کارت را Lukas تصمیم بگیرد | — |
| 58 | besonderer | `Adjektive.txt` | 2026-09-25 | مثل besonderes: شکل صرف‌شده، نه شکل پایه — شکل درست کارت را Lukas تصمیم بگیرد | — |
| 59 | bestiefelt | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست («چکمه‌پوش»؟) | — |
| 60 | bestrumpft | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست («جوراب‌پوش»؟) | — |
| 61 | bestusst | `Adjektive.txt` | 2026-09-25 | عامیانه؛ معنا و کاربرد رایجش را مطمئن نمی‌دانم («خل»؟) | — |
| 62 | betresst | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست («یراق‌دار»؟) | — |
| 63 | betrieben | `Adjektive.txt` | 2026-09-25 | فقط صفت مفعولی است؛ به‌عنوان صفت مستقل مطمئن نیستم (بیشتر در ترکیب‌ها مثل batteriebetrieben) | — |
| 64 | bezastert | `Adjektive.txt` | 2026-09-25 | نه معنا و نه شکل ثبت‌شده‌ای برایش می‌شناسم | — |
| 65 | bezopft | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست («گیس‌بافته»؟) | — |
| 66 | bibliophob | `Adjektive.txt` | 2026-09-25 | معنا روشن به نظر می‌رسد («کتاب‌گریز»)، ولی رایج بودن و ثبتش در Duden را مطمئن نیستم | — |
| 67 | biereifrig | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست (شوخی‌آمیز؟) | — |
| 68 | bimaxillär | `Adjektive.txt` | 2026-09-25 | اصطلاح تخصصی (پزشکی/دندان‌پزشکی: «مربوط به هر دو فک»؟)، معنای دقیق مطمئن نیست | — |
| 69 | birken | `Adjektive.txt` | 2026-09-25 | معنا و رایج بودنش مطمئن نیست («از چوب توس»؟) | — |
| 70 | bitchig | `Adjektive.txt` | 2026-09-25 | وام‌واژه‌ی عامیانه از انگلیسی؛ کاربرد و ثبتش مطمئن نیست | — |
| 71 | blakig | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست («دوده‌زا»؟) | — |
| 72 | bland | `Adjektive.txt` | 2026-09-25 | اصطلاح تخصصی (پزشکی: «ملایم، بی‌تحریک»؟)، معنای دقیق مطمئن نیست | — |
| 73 | blaustrümpfig | `Adjektive.txt` | 2026-09-25 | معنا و کاربرد رایجش مطمئن نیست (تعبیر تحقیرآمیز قدیمی برای زنان تحصیل‌کرده؟) | — |
| 74 | bonfortionös | `Adjektive.txt` | 2026-09-26 | املا مشکوک: شکل ثبت‌شده‌ی این واژه‌ی شوخی‌آمیز (به معنی «باشکوه») را مطمئن نیستم — شاید «bomforzionös»؛ ساختن با املای فهرست یعنی احتمالاً املای غلط | — |
| 75 | botrytisiert | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی شراب‌سازی (انگورِ دچار «پوسیدگی نجیب»)؛ ثبتش در Duden و کاربرد رایجش را مطمئن نیستم | — |
| 76 | boustrophedon | `Adjektive.txt` | 2026-09-26 | این واژه (نوعی خط که سطرها یکی در میان از چپ و راست نوشته می‌شوند) بیشتر اسم/قید است (das Bustrophedon)؛ کاربرد صفتی و املای درستش مطمئن نیست | — |
| 77 | brennheiß | `Adjektive.txt` | 2026-09-26 | معنا روشن است («داغِ داغ»)، ولی مطمئن نیستم که به‌صورت یک کلمه در Duden ثبت شده باشد — معمولاً «brennend heiß» گفته می‌شود | — |
| 78 | brillanten | `Adjektive.txt` | 2026-09-26 | معنا و کاربرد رایجش مطمئن نیست («ساخته‌شده از الماس تراش‌خورده»؟)؛ brillant جدا ساخته شد | — |
| 79 | brokaten | `Adjektive.txt` | 2026-09-26 | معنا و رایج بودنش مطمئن نیست («از پارچه‌ی زربفت»؟) — مثل batisten و birken | — |
| 80 | buchen | `Adjektive.txt` | 2026-09-26 | معنا و رایج بودنش مطمئن نیست («از چوب راش»؟) — مثل birken و brokaten | — |
| 81 | bundrein | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی (ساخت گیتار؟: «پرده‌ها کوک درست»؟)؛ معنا و ثبتش در Duden مطمئن نیست | — |
| 82 | buntfarben | `Adjektive.txt` | 2026-09-26 | مطمئن نیستم در Duden ثبت شده باشد (شکل مطمئن: buntfarbig، که ساخته شد) | — |
| 83 | busig | `Adjektive.txt` | 2026-09-26 | معنا و کاربرد رایجش مطمئن نیست (عامیانه، «سینه‌بزرگ»؟) — مثل bebust | — |
| 84 | bustrophedon | `Adjektive.txt` | 2026-09-26 | مثل boustrophedon: بیشتر اسم/قید است (das Bustrophedon)؛ کاربرد صفتی مطمئن نیست | — |
| 85 | chemometrisch | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی (شیمی‌سنجی/Chemometrie)؛ ثبتش در Duden و کاربرد رایجش مطمئن نیست | — |
| 86 | chilotisch | `Adjektive.txt` | 2026-09-26 | معنا مطمئن نیست (مربوط به جزیره‌ی Chiloé در شیلی؟) و ثبتش را نمی‌دانم | — |
| 87 | chionophil | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی (زیست‌شناسی: «برف‌دوست»؟)؛ معنا و ثبتش مطمئن نیست | — |
| 88 | chochem | `Adjektive.txt` | 2026-09-26 | در Duden فقط به‌صورت اسم («der Chochem» = آدم دانا، از ییدیش) آمده؛ کاربرد صفتی مطمئن نیست | — |
| 89 | chondritisch | `Adjektive.txt` | 2026-09-26 | دو معنای ممکن (مربوط به شهاب‌سنگ Chondrit / التهاب غضروف Chondritis) — کدام مقصود است مطمئن نیستم | — |
| 90 | claviform | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی (گیاه‌شناسی: «گرزی‌شکل»؟)؛ ثبتش در Duden مطمئن نیست | — |
| 91 | damasten | `Adjektive.txt` | 2026-09-26 | معنا و رایج بودنش مطمئن نیست («از پارچه‌ی دمسکی»؟) — مثل batisten و brokaten | — |
| 92 | dasig | `Adjektive.txt` | 2026-09-26 | گویشی؛ معنا مطمئن نیست («گیج»؟ «این‌جایی»؟) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 93 | debitorisch | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی حسابداری («مربوط به بدهکاران»؟)؛ ثبتش در Duden و کاربرد رایجش مطمئن نیست | — |
| 94 | dekremental | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی؛ معنا و ثبتش در Duden مطمئن نیست («کاهشی»؟) | — |
| 95 | delatorisch | `Adjektive.txt` | 2026-09-26 | معنا و ثبتش مطمئن نیست («سخن‌چینانه»؟ کهنه) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 96 | demanten | `Adjektive.txt` | 2026-09-26 | معنا و کاربرد رایجش مطمئن نیست (ادبی: «الماسی»؟) — مثل brillanten | — |
| 97 | deprekativ | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی (زبان‌شناسی/دین: «دعایی، درخواستی»؟)؛ ثبتش در Duden مطمئن نیست | — |
| 98 | depretiativ | `Adjektive.txt` | 2026-09-26 | معنا و املا مطمئن نیست (شاید «depreziativ» = تحقیرآمیز؟)؛ ساختن با املای فهرست یعنی احتمالاً املای غلط | — |
| 99 | desiderat | `Adjektive.txt` | 2026-09-26 | در Duden به‌صورت اسم آمده («das Desiderat» = چیز مورد نیاز/کمبود)؛ کاربرد صفتی مطمئن نیست | — |
| 100 | designatus | `Adjektive.txt` | 2026-09-26 | لاتین است و فقط بعد از اسم می‌آید (مثل «Rektor designatus» = رئیس منتخب)؛ صفت معمولی نیست (شکل آلمانی‌اش designiert ساخته شد) | — |
| 101 | desmal | `Adjektive.txt` | 2026-09-26 | نه معنا و نه شکل ثبت‌شده‌ای برایش می‌شناسم (شاید غلط تایپی) | — |
| 102 | dextral | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی (زیست‌شناسی/پزشکی: «راست‌گرد، سمت راست»؟)؛ معنای دقیق و ثبتش مطمئن نیست | — |
| 103 | dezisionistisch | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی فلسفه/حقوق اساسی («تصمیم‌گرایانه»؟)؛ معنای دقیق و ثبتش مطمئن نیست | — |
| 104 | diamanten | `Adjektive.txt` | 2026-09-26 | معنا و کاربرد رایجش مطمئن نیست («از الماس»؟ ادبی) — مثل brillanten و demanten | — |
| 105 | diffusibel | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی (فیزیک/شیمی: «قابل انتشار»؟)؛ ثبتش در Duden مطمئن نیست | — |
| 106 | dikasterial | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی (احتمالاً مربوط به «Dikasterium» = اداره‌ی واتیکان)؛ معنا و ثبتش مطمئن نیست | — |
| 107 | dilemmatisch | `Adjektive.txt` | 2026-09-26 | معنا روشن به نظر می‌رسد («دشوار، دوراهی‌گونه»)، ولی ثبتش در Duden و رایج بودنش مطمئن نیست | — |
| 108 | diptotisch | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی دستور زبان (اسم «دوحالته»؟ مثلاً در عربی)؛ معنا و ثبتش مطمئن نیست | — |
| 109 | dissidentisch | `Adjektive.txt` | 2026-09-26 | ثبتش در Duden مطمئن نیست (شکل مطمئن: dissident، که ساخته شد) | — |
| 110 | dissipativ | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی فیزیک («اتلاف‌کننده‌ی انرژی»)؛ ثبتش در Duden مطمئن نیست | — |
| 111 | distich | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی (گیاه‌شناسی: «دوردیفه»؟) یا اشتباه با «Distichon» (دوبیتی)؛ مطمئن نیستم | — |
| 112 | dolent | `Adjektive.txt` | 2026-09-26 | اصطلاح پزشکی («دردناک»؟)؛ ثبتش در Duden مطمئن نیست (شکل مطمئن: dolorös، که ساخته شد) | — |
| 113 | doloros | `Adjektive.txt` | 2026-09-26 | املای این شکل مطمئن نیست (شکل مطمئن: dolorös، که ساخته شد) | — |
| 114 | dominicanisch | `Adjektive.txt` | 2026-09-26 | املای این شکل مطمئن نیست (شکل مطمئن: dominikanisch، که ساخته شد) | — |
| 115 | doppelherzig | `Adjektive.txt` | 2026-09-26 | کهنه؛ معنا و ثبتش در Duden مطمئن نیست («دورو»؟) | — |
| 116 | drahten | `Adjektive.txt` | 2026-09-26 | معنا و رایج بودنش مطمئن نیست («سیمی، از سیم»؟) — مثل birken و damasten | — |
| 117 | drittelzahlig | `Adjektive.txt` | 2026-09-26 | معنا و ثبتش در Duden مطمئن نیست | — |
| 118 | dutzend | `Adjektive.txt` | 2026-09-26 | نوع کلمه مطمئن نیست (بیشتر اسم است: «das Dutzend»؛ با حرف کوچک فقط در «dutzende») | — |
| 119 | dyadisch | `Adjektive.txt` | 2026-09-26 | چند معنای تخصصی دارد (ریاضی: دودویی / جامعه‌شناسی: رابطه‌ی دونفره) — کدام مقصود است مطمئن نیستم | — |
| 120 | ebengleich | `Adjektive.txt` | 2026-09-26 | معنا و ثبتش در Duden مطمئن نیست | — |
| 121 | egressiv | `Adjektive.txt` | 2026-09-26 | چند معنای تخصصی دارد (آواشناسی: بازدمی / دستور: پایان‌نما) — کدام مقصود است مطمئن نیستم | — |
| 122 | ehrenkäsig | `Adjektive.txt` | 2026-09-26 | معنا و ثبتش در Duden مطمئن نیست (عامیانه؟) | — |
| 123 | eiben | `Adjektive.txt` | 2026-09-26 | صفت جنس («از چوب سرخدار»؟)؛ کاربرد رایجش مطمئن نیست — مثل birken | — |
| 124 | eichen | `Adjektive.txt` | 2026-09-26 | صفت جنس («از چوب بلوط»)؛ با فعل «eichen» (کالیبره کردن) قاطی می‌شود — مثل birken کنار ماند | — |
| 125 | einschaltbereit | `Adjektive.txt` | 2026-09-26 | معنا و ثبتش در Duden مطمئن نیست | — |
| 126 | elektrogen | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی؛ معنا و ثبتش در Duden مطمئن نیست | — |
| 127 | elenktisch | `Adjektive.txt` | 2026-09-26 | اصطلاح فلسفی («ابطال‌کننده»؟)؛ ثبتش در Duden مطمئن نیست | — |
| 128 | emeritus | `Adjektive.txt` | 2026-09-26 | لاتین است و فقط بعد از اسم می‌آید (Professor emeritus)؛ صفت معمولی نیست (شکل آلمانی‌اش emeritiert ساخته شد) | — |
| 129 | emisch | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی (مردم‌شناسی/زبان‌شناسی: «درون‌نگر»)؛ ثبتش در Duden مطمئن نیست | — |
| 130 | empathogen | `Adjektive.txt` | 2026-09-26 | اصطلاح داروشناسی؛ ثبتش در Duden مطمئن نیست | — |
| 131 | enaktiv | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی (علوم شناختی/آموزش: «عملی، کنشی»)؛ ثبتش در Duden مطمئن نیست | — |
| 132 | endogenetisch | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی؛ فرقش با endogen (که ساخته شد) و ثبتش مطمئن نیست | — |
| 133 | endothym | `Adjektive.txt` | 2026-09-26 | اصطلاح روان‌شناسی؛ معنا و ثبتش مطمئن نیست | — |
| 134 | endozentrisch | `Adjektive.txt` | 2026-09-26 | اصطلاح زبان‌شناسی («درون‌مرکز»)؛ ثبتش در Duden مطمئن نیست | — |
| 135 | enkaptisch | `Adjektive.txt` | 2026-09-26 | معنا و ثبتش در Duden مطمئن نیست | — |
| 136 | enneaeterisch | `Adjektive.txt` | 2026-09-26 | اصطلاح بسیار کمیاب («نه‌ساله»؟)؛ معنا و ثبتش مطمئن نیست | — |
| 137 | enostal | `Adjektive.txt` | 2026-09-26 | معنا و ثبتش مطمئن نیست (شاید اشتباه با enossal، که ساخته شد) | — |
| 138 | entaktogen | `Adjektive.txt` | 2026-09-26 | اصطلاح داروشناسی؛ ثبتش در Duden مطمئن نیست | — |
| 139 | ephebisch | `Adjektive.txt` | 2026-09-26 | معنا و ثبتش در Duden مطمئن نیست («نوجوانانه»؟) | — |
| 140 | epifaszial | `Adjektive.txt` | 2026-09-26 | اصطلاح پزشکی («روی نیام عضله»؟)؛ ثبتش در Duden مطمئن نیست | — |
| 141 | epithetisch | `Adjektive.txt` | 2026-09-26 | اصطلاح بلاغت (مربوط به «صفت/لقب»)؛ ثبتش در Duden مطمئن نیست | — |
| 142 | eponymisch | `Adjektive.txt` | 2026-09-26 | ثبتش در Duden مطمئن نیست (شکل رایج‌تر: eponym) | — |
| 143 | erdhaltig | `Adjektive.txt` | 2026-09-26 | معنا و ثبتش در Duden مطمئن نیست («خاک‌دار»؟) | — |
| 144 | erethisch | `Adjektive.txt` | 2026-09-26 | اصطلاح پزشکی (تحریک‌پذیری شدید)؛ ثبتش در Duden مطمئن نیست | — |
| 145 | erfolgswirksam | `Adjektive.txt` | 2026-09-26 | اصطلاح حسابداری («مؤثر بر سود و زیان»)؛ معنای دقیقش مطمئن نیست | — |
| 146 | erlen | `Adjektive.txt` | 2026-09-26 | صفت جنس («از چوب توسکا»؟) — مثل birken | — |
| 147 | erotomanisch | `Adjektive.txt` | 2026-09-26 | اصطلاح روان‌پزشکی؛ ثبتش در Duden مطمئن نیست | — |
| 148 | erzen | `Adjektive.txt` | 2026-09-26 | صفت جنس («از مفرغ»؟، کهنه) — مثل birken | — |
| 149 | eschen | `Adjektive.txt` | 2026-09-26 | صفت جنس («از چوب زبان‌گنجشک»؟) — مثل birken | — |
| 150 | espen | `Adjektive.txt` | 2026-09-26 | صفت جنس («از چوب سپیدار»؟) — مثل birken | — |
| 151 | etisch | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی (مردم‌شناسی/زبان‌شناسی: «برون‌نگر») — مثل emisch | — |
| 152 | euploid | `Adjektive.txt` | 2026-09-26 | اصطلاح ژنتیک؛ ثبتش در Duden مطمئن نیست | — |
| 153 | europazentriert | `Adjektive.txt` | 2026-09-26 | ثبتش در Duden مطمئن نیست (شکل رایج: eurozentrisch) | — |
| 154 | euryhalin | `Adjektive.txt` | 2026-09-26 | اصطلاح بوم‌شناسی (تحمل شوری گسترده)؛ ثبتش مطمئن نیست | — |
| 155 | euryhygr | `Adjektive.txt` | 2026-09-26 | اصطلاح بوم‌شناسی (تحمل رطوبت گسترده)؛ ثبتش مطمئن نیست | — |
| 156 | euryök | `Adjektive.txt` | 2026-09-26 | اصطلاح بوم‌شناسی (سازگار با محیط‌های گوناگون)؛ ثبتش مطمئن نیست | — |
| 157 | eurytherm | `Adjektive.txt` | 2026-09-26 | اصطلاح بوم‌شناسی (تحمل دمای گسترده)؛ ثبتش مطمئن نیست | — |
| 158 | exergon | `Adjektive.txt` | 2026-09-26 | اصطلاح زیست‌شیمی؛ شکل رایج «exergonisch» است و این شکل مطمئن نیست | — |
| 159 | exogenetisch | `Adjektive.txt` | 2026-09-26 | اصطلاح تخصصی؛ فرقش با exogen (که ساخته شد) مطمئن نیست — مثل endogenetisch | — |
| 160 | exozentrischg | `Adjektive.txt` | 2026-09-26 | غلط تایپی در فهرست (احتمالاً exozentrisch)؛ اصطلاح زبان‌شناسی با ثبت نامطمئن | — |
| 161 | expert | `Adjektive.txt` | 2026-09-26 | صفت ثبت‌شده‌ی آلمانی نیست (از انگلیسی expert)؛ مطمئن نیستم | — |
| 162 | extinkt | `Adjektive.txt` | 2026-09-26 | معنا و ثبتش در Duden مطمئن نیست («منقرض»؟) | — |
| 163 | extradiegetisch | `Adjektive.txt` | 2026-09-26 | اصطلاح روایت‌شناسی (برون‌داستانی)؛ ثبتش در Duden مطمئن نیست | — |
| 164 | extramundan | `Adjektive.txt` | 2026-09-26 | اصطلاح فلسفی («فراجهانی»؟)؛ ثبتش مطمئن نیست | — |
| 165 | extra-temporal | `Adjektive.txt` | 2026-09-26 | املا و معنایش مطمئن نیست | — |
| 166 | extratemporal | `Adjektive.txt` | 2026-09-26 | معنا و ثبتش مطمئن نیست (پزشکی: «بیرون از ناحیه‌ی گیجگاه»؟) | — |
| 167 | fabisch | `Adjektive.txt` | 2026-09-26 | معنا و ثبتش در Duden مطمئن نیست | — |
| 168 | fadenbreit | `Adjektive.txt` | 2026-09-26 | بیشتر اسم است («um keinen Fadenbreit»)؛ کاربرد صفتی مطمئن نیست | — |
| 169 | fadenlos | `Adjektive.txt` | 2026-09-26 | معنا و ثبتش در Duden مطمئن نیست | — |
| 170 | faselnackend | `Adjektive.txt` | 2026-09-26 | گویشی؛ معنا و املایش مطمئن نیست («لخت مادرزاد»؟) | — |
| 171 | fasennackend | `Adjektive.txt` | 2026-09-26 | گویشی؛ معنا و املایش مطمئن نیست — مثل faselnackend | — |
| 172 | fassettenartig | `Adjektive.txt` | 2026-09-26 | املای این شکل مطمئن نیست (شکل مطمئن: facettenartig، که ساخته شد) | — |
| 173 | fassettenreich | `Adjektive.txt` | 2026-09-26 | املای این شکل مطمئن نیست (شکل مطمئن: facettenreich، که ساخته شد) | — |
| 174 | fastidiös | `Adjektive.txt` | 2026-09-26 | کهنه؛ معنا مطمئن نیست («چندش‌آور»؟ «مشکل‌پسند»؟) | — |
| 175 | fekund | `Adjektive.txt` | 2026-09-26 | کمیاب؛ ثبتش در Duden مطمئن نیست («بارور»؟) | — |
| 176 | fennoskandisch | `Adjektive.txt` | 2026-09-26 | اصطلاح زمین‌شناسی/جغرافیا (فنوسکاندیا)؛ ثبتش در Duden مطمئن نیست | — |
| 177 | fichten | `Adjektive.txt` | 2026-09-26 | صفت جنس («از چوب صنوبر»؟) — مثل birken | — |
| 178 | fickerig | `Adjektive.txt` | 2026-09-26 | گویشی؛ معنا مطمئن نیست («بی‌قرار»؟) و ممکن است سوءبرداشت شود | — |
| 179 | filamentartig | `Adjektive.txt` | 2026-09-26 | ثبتش در Duden مطمئن نیست («رشته‌مانند») | — |
| 180 | fipsig | `Adjektive.txt` | 2026-09-26 | گویشی/عامیانه؛ معنا مطمئن نیست | — |
| 181 | firn | `Adjektive.txt` | 2026-09-26 | کهنه؛ معنا مطمئن نیست (درباره‌ی شراب: «کهنه، جاافتاده»؟) | — |
| 182 | flächengroß | `Adjektive.txt` | 2026-09-26 | ثبتش در Duden مطمئن نیست | — |
| 183 | flächsen | `Adjektive.txt` | 2026-09-26 | صفت جنس («از کتان»؟) — مثل birken | — |
| 184 | flächsern | `Adjektive.txt` | 2026-09-26 | صفت جنس («از کتان»؟) — مثل birken | — |
| 185 | flanellen | `Adjektive.txt` | 2026-09-26 | صفت جنس («از فلانل»؟) — مثل batisten | — |
| 186 | fluvioglazial | `Adjektive.txt` | 2026-09-26 | اصطلاح زمین‌شناسی (رودخانه‌ای-یخچالی)؛ ثبتش مطمئن نیست | — |
| 187 | gasig | `Adjektive.txt` | 2026-09-26 | معنا و کاربرد رایجش را مطمئن نمی‌دانم («گازی»؟ «پرگاز»؟ عامیانه؟) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 188 | gebalkt | `Adjektive.txt` | 2026-09-26 | معنا و کاربرد رایجش مطمئن نیست («تیرک‌دار»؟ اصطلاح نجاری/شکار؟) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 189 | gebuckelt | `Adjektive.txt` | 2026-09-26 | معنا مطمئن نیست («قوزدار»؟ «برآمده/دارای برجستگی»؟) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 190 | gefizt | `Adjektive.txt` | 2026-09-26 | نه معنا و نه شکل ثبت‌شده‌ای برایش می‌شناسم (شاید گویشی یا املای غلط) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 191 | gegengleich | `Adjektive.txt` | 2026-09-26 | معنا/کاربرد مطمئن نیست («قرینه‌ی مخالف»؟ اصطلاح فنی/اتریشی؟) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 192 | gegiebelt | `Adjektive.txt` | 2026-09-26 | معنا و کاربرد رایجش مطمئن نیست («شیروانی‌دار»؟) — مثل behemdet، قاعده‌ی ۱۴ | — |
| 193 | gehäusetragend | `Adjektive.txt` | 2026-09-26 | کاربرد ثابت‌شده‌اش را مطمئن نیستم (اصطلاح زیست‌شناسی «صدف‌دار»؟) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 194 | geheist | `Adjektive.txt` | 2026-09-26 | نه معنا و نه شکل ثبت‌شده‌ای برایش می‌شناسم (شاید املای غلط) — قاعده‌ی ۱۴ | — |
| 195 | gehenkelt | `Adjektive.txt` | 2026-09-26 | معنا و کاربرد رایجش مطمئن نیست («دسته‌دار»؟) — قاعده‌ی ۱۴ | — |
| 196 | gehl | `Adjektive.txt` | 2026-09-26 | گویشی/کهنه (احتمالاً «زرد»)؛ معنا و رواج مطمئن نیست — قاعده‌ی ۱۴ | — |
| 197 | geköpert | `Adjektive.txt` | 2026-09-26 | اصطلاح نساجی (احتمالاً «با بافت جناغی/Köper»)؛ معنای دقیق و رواجش مطمئن نیست — قاعده‌ی ۱۴ | — |
| 198 | gekröpft | `Adjektive.txt` | 2026-09-26 | اصطلاح فنی (لوله/میله‌ی خم‌شده؟) یا شکار؛ معنای دقیق مطمئن نیست — قاعده‌ی ۱۴ | — |
| 199 | geperlt | `Adjektive.txt` | 2026-09-26 | معنا و کاربرد رایجش مطمئن نیست («مرواریدنشان»؟ «دانه‌دانه»؟) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 200 | gewalmt | `Adjektive.txt` | 2026-09-26 | اصطلاح معماری (احتمالاً «با شیروانی چهارشیبه/Walmdach»)؛ مثل gegiebelt معنا و رواجش را مطمئن نمی‌دانم — قاعده‌ی ۱۴ | — |
| 201 | glanzhell | `Adjektive.txt` | 2026-09-26 | کلمه‌ی ثبت‌شده و رایجی برایش نمی‌شناسم (شاید ترکیب آزاد «براق و روشن») — قاعده‌ی ۱۴: حدس ممنوع | — |
| 202 | griveliert | `Adjektive.txt` | 2026-09-26 | شکل و معنای ثبت‌شده‌ای برایش مطمئن نیستم (شاید «grivelliert» = نقطه‌نقطه‌ی خاکستری؟) — قاعده‌ی ۱۴: حدس ممنوع | — |
| 203 | hären | `Adjektive.txt` | 2026-09-27 | صفت جنس («از مو بافته»)، ادبی/قدیمی — مثل birken و flächsen (صفت‌های جنس) کنار گذاشته شد؛ کاربرد امروزی‌اش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 204 | halbverklungen | `Adjektive.txt` | 2026-09-27 | ترکیب آزاد ادبی («نیمه‌خاموش‌شده»، مثلاً صدا)؛ شکل ثبت‌شده و مطمئنی برایش نمی‌شناسم — قاعده‌ی ۱۴ | — |
| 205 | halbwollen | `Adjektive.txt` | 2026-09-27 | صفت جنس («از نیم‌پشم») — مثل flanellen و flächsen کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 206 | hallisch | `Adjektive.txt` | 2026-09-27 | صفت شهر Halle؟ شکل رایجش (hallesch یا hallisch) را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 207 | haloniert | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید «چشم‌های گود افتاده با حلقه‌ی تیره»)؛ معنا را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 208 | haltig | `Adjektive.txt` | 2026-09-27 | به‌عنوان کلمه‌ی مستقل مطمئن نیستم (معمولاً فقط پسوند -haltig، مثل eisenhaltig) — قاعده‌ی ۱۴ | — |
| 209 | handsam | `Adjektive.txt` | 2026-09-27 | محلی/قدیمی؛ معنای دقیقش («خوش‌دست» یا «خوش‌برخورد»؟) را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 210 | hanfen | `Adjektive.txt` | 2026-09-27 | صفت جنس («از کنف») — مثل flächsen و flanellen کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 211 | hapaxanth | `Adjektive.txt` | 2026-09-27 | اصطلاح گیاه‌شناسی (شاید «فقط یک بار گل‌دهنده»)؛ شکل و معنا را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 212 | hieb-undstichfest | `Adjektive.txt` | 2026-09-27 | خطای فهرست: درستش «hieb- und stichfest» است (چندبخشی، با فاصله). ساختن با املای فهرست یعنی املای غلط؛ با املای درست یعنی id دیگر ⇒ تصمیم با Lukas | — |
| 213 | hinterer | `Adjektive.txt` | 2026-09-27 | خطای فهرست: شکل صرف‌شده است؛ شکل پایه «hintere» است (مثل besonderer) ⇒ تصمیم با Lukas | — |
| 214 | hirschledern | `Adjektive.txt` | 2026-09-27 | صفت جنس («از چرم گوزن») — مثل flächsern کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 215 | hitlerisch | `Adjektive.txt` | 2026-09-27 | کاربرد و شکل ثبت‌شده‌اش را به‌عنوان صفت مطمئن نیستم؛ موضوع حساس — قاعده‌ی ۱۴ | — |
| 216 | hühnermüde | `Adjektive.txt` | 2026-09-27 | عامیانه/محلی؛ شکل ثبت‌شده و معنای دقیقش (شاید «خیلی خسته»؟) را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 217 | humil | `Adjektive.txt` | 2026-09-27 | قدیمی/نادر (شاید «فروتن»)؛ معنا و کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 218 | hydrogen | `Adjektive.txt` | 2026-09-27 | به‌عنوان صفت مطمئن نیستم (شاید «هیدروژن‌دار»؟)؛ معمولاً اسم/پیشوند است — قاعده‌ی ۱۴ | — |
| 219 | hygrisch | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید «مربوط به رطوبت»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 220 | hypophrenisch | `Adjektive.txt` | 2026-09-27 | اصطلاح تخصصی (شاید «زیر دیافراگم»)؛ معنا و کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 221 | immediat | `Adjektive.txt` | 2026-09-27 | قدیمی (شاید «مستقیماً زیر نظر حاکم»)؛ معنا و کاربرد امروزی‌اش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 222 | impardonnabel | `Adjektive.txt` | 2026-09-27 | قدیمی (شاید «نابخشودنی»)؛ کاربرد امروزی‌اش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 223 | imperturbatisch | `Adjektive.txt` | 2026-09-27 | شکل مشکوک است (شکل رایج شاید «imperturbabel» = خونسرد)؛ املا/شکل مطمئن نیست ⇒ تصمیم با Lukas | — |
| 224 | importun | `Adjektive.txt` | 2026-09-27 | قدیمی (شاید «بی‌موقع، مزاحم»)؛ کاربرد امروزی‌اش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 225 | inkommod | `Adjektive.txt` | 2026-09-27 | قدیمی (شاید «مزاحم، ناراحت‌کننده»)؛ کاربرد امروزی‌اش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 226 | innerer | `Adjektive.txt` | 2026-09-27 | خطای فهرست: شکل صرف‌شده است؛ شکل پایه «innere» است (مثل hinterer) ⇒ تصمیم با Lukas | — |
| 227 | insistent | `Adjektive.txt` | 2026-09-27 | به‌عنوان صفت آلمانی مطمئن نیستم (شاید «مُصر»)؛ کاربردش روشن نیست — قاعده‌ی ۱۴ | — |
| 228 | interdenominational | `Adjektive.txt` | 2026-09-27 | در آلمانی رایج نیست (معمولاً «interkonfessionell» = بین‌مذهبی)؛ شاید وام‌واژه‌ی انگلیسی — قاعده‌ی ۱۴ | — |
| 229 | interkranial | `Adjektive.txt` | 2026-09-27 | شکل مشکوک است (رایج: «intrakranial» = درون جمجمه)؛ مطمئن نیستم ⇒ تصمیم با Lukas | — |
| 230 | interkrustal | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید زمین‌شناسی)؛ معنا را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 231 | interkurrierend | `Adjektive.txt` | 2026-09-27 | شکل مشکوک است (رایج: «interkurrent» که ساخته شد) — قاعده‌ی ۱۴ | — |
| 232 | interorbital | `Adjektive.txt` | 2026-09-27 | چندمعنایی (کالبدشناسی: بین دو حفره‌ی چشم؟ یا فضانوردی؟)؛ معنای مطمئن نیست — قاعده‌ی ۱۴ | — |
| 233 | interterritorial | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید «بین سرزمین‌ها»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 234 | interurban | `Adjektive.txt` | 2026-09-27 | قدیمی (شاید «بین‌شهری»، مثل تلفن راه دور)؛ معنا و کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 235 | intervallisch | `Adjektive.txt` | 2026-09-27 | معنا نامطمئن (شاید «فاصله‌دار» یا اصطلاح موسیقی)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 236 | interventiv | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید «مداخله‌ای»، پزشکی)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 237 | inzident | `Adjektive.txt` | 2026-09-27 | چندمعنایی (ریاضی: «واقع بر»؟ یا «اتفاقی»؟)؛ معنای مطمئن نیست — قاعده‌ی ۱۴ | — |
| 238 | irden | `Adjektive.txt` | 2026-09-27 | صفت جنس («سفالی، از گل پخته») — مثل birken و flächsen کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 239 | irländisch | `Adjektive.txt` | 2026-09-27 | در کنار «irisch» (که ساخته شد) کمیاب است؛ کاربرد امروزی‌اش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 240 | jaden | `Adjektive.txt` | 2026-09-27 | صفت جنس («از یشم») — مثل birken و flächsen کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 241 | jährig | `Adjektive.txt` | 2026-09-27 | به‌عنوان کلمه‌ی مستقل قدیمی/نامطمئن (معمولاً فقط پسوند -jährig، مثل zweijährig) — قاعده‌ی ۱۴ | — |
| 242 | jiddischistisch | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (مربوط به جنبش «ییدیشیسم»؟)؛ معنا را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 243 | judiziös | `Adjektive.txt` | 2026-09-27 | قدیمی/ادبی (شاید «باقضاوت و تیزبین»)؛ معنا و کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 244 | juwelen | `Adjektive.txt` | 2026-09-27 | صفت جنس («از جواهر»)؛ مثل birken و flächsen کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 245 | juxtarenal | `Adjektive.txt` | 2026-09-27 | اصطلاح پزشکی نادر (شاید «کنار کلیه»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 246 | kaduk | `Adjektive.txt` | 2026-09-27 | قدیمی (شاید «فرسوده، باطل»)؛ کاربرد امروزی‌اش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 247 | kärntisch | `Adjektive.txt` | 2026-09-27 | شکل مشکوک است (رایج: «kärntnerisch» که ساخته شد) ⇒ تصمیم با Lukas | — |
| 248 | kanevassen | `Adjektive.txt` | 2026-09-27 | صفت جنس («از پارچه‌ی کنواس») — مثل flanellen کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 249 | kantoniert | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید معماری: «ستون با ستونک‌های گوشه»)؛ معنا را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 250 | karolinisch | `Adjektive.txt` | 2026-09-27 | چندمعنایی (جزایر کارولین؟ یا مربوط به شارل پنجم/قانون Carolina؟)؛ معنای مطمئن نیست — قاعده‌ی ۱۴ | — |
| 251 | katenativ | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید زبان‌شناسی: «زنجیره‌ای»)؛ معنا را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 252 | katotherm | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر؛ معنا را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 253 | kattunen | `Adjektive.txt` | 2026-09-27 | صفت جنس («از پارچه‌ی کتان/چیت») — مثل flanellen کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 254 | kautelarjuristisch | `Adjektive.txt` | 2026-09-27 | اصطلاح حقوقی بسیار نادر (مربوط به تنظیم قرارداد پیشگیرانه)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 255 | kiefern | `Adjektive.txt` | 2026-09-27 | صفت جنس («از چوب کاج») — مثل birken کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 256 | knitz | `Adjektive.txt` | 2026-09-27 | محلی (جنوب‌غرب آلمان، شاید «زرنگ»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 257 | knülle | `Adjektive.txt` | 2026-09-27 | محلی/عامیانه (شاید «مست» یا «خسته»)؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| 258 | knüll | `Adjektive.txt` | 2026-09-27 | شکل دیگر «knülle»؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| 259 | koblenzisch | `Adjektive.txt` | 2026-09-27 | شکل مشکوک است (صفت رایج شهر: «Koblenzer») ⇒ تصمیم با Lukas | — |
| 260 | komplektisch | `Adjektive.txt` | 2026-09-27 | این کلمه را نمی‌شناسم؛ معنا نامطمئن است — قاعده‌ی ۱۴ | — |
| 261 | komputativ | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید «محاسباتی»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 262 | konfliktär | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید «پرتعارض»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 263 | konjugal | `Adjektive.txt` | 2026-09-27 | قدیمی (شاید «زناشویی»)؛ کاربرد امروزی‌اش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 264 | konkomitant | `Adjektive.txt` | 2026-09-27 | اصطلاح پزشکی نادر (شاید «همراه، هم‌زمان»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 265 | konphas | `Adjektive.txt` | 2026-09-27 | این کلمه را نمی‌شناسم (شاید فیزیک: «هم‌فاز»)؛ معنا نامطمئن — قاعده‌ی ۱۴ | — |
| 266 | konvenient | `Adjektive.txt` | 2026-09-27 | قدیمی (شاید «مناسب»)؛ کاربرد امروزی‌اش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 267 | konvers | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید منطق: «معکوس»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 268 | konvivial | `Adjektive.txt` | 2026-09-27 | نادر/ادبی (شاید «معاشرتی و صمیمی»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 269 | korallen | `Adjektive.txt` | 2026-09-27 | صفت جنس («از مرجان») — مثل birken کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 270 | kredibel | `Adjektive.txt` | 2026-09-27 | قدیمی/ادبی (شاید «باورپذیر»)؛ کاربرد امروزی‌اش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 271 | kreiden | `Adjektive.txt` | 2026-09-27 | صفت جنس («از گچ») — مثل birken کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 272 | krisselig | `Adjektive.txt` | 2026-09-27 | محلی/عامیانه (شاید «موج‌دار ریز» یا «دانه‌دانه»)؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| 273 | krisslig | `Adjektive.txt` | 2026-09-27 | شکل دیگر «krisselig»؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| 274 | kristallen | `Adjektive.txt` | 2026-09-27 | صفت جنس («از کریستال») — مثل birken کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 275 | krütsch | `Adjektive.txt` | 2026-09-27 | محلی (شاید «مشکل‌پسند»)؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| 276 | kryptomer | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید کانی‌شناسی: «ریزبلور پنهان»)؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| 277 | kunstseiden | `Adjektive.txt` | 2026-09-27 | صفت جنس («از ابریشم مصنوعی») — مثل flanellen کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 278 | kurrent | `Adjektive.txt` | 2026-09-27 | چندمعنایی (خط کورنت اتریشی؟ یا «جاری» در تجارت؟)؛ معنای مطمئن نیست — قاعده‌ی ۱۴ | — |
| 279 | laff | `Adjektive.txt` | 2026-09-27 | محلی/عامیانه (شاید «شل» یا «بی‌مزه»)؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| 280 | laikal | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید «مربوط به غیرروحانیان»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 281 | larifari | `Adjektive.txt` | 2026-09-27 | بیشتر اسم یا صوت است («Larifari» = مزخرف)؛ کاربرد صفتی‌اش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 282 | latinisch | `Adjektive.txt` | 2026-09-27 | نادر/تاریخی (شاید «مربوط به لاتیوم»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 283 | latreutisch | `Adjektive.txt` | 2026-09-27 | اصطلاح الهیاتی بسیار نادر؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| 284 | leckerfritzig | `Adjektive.txt` | 2026-09-27 | عامیانه/محلی؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| 285 | legasthen | `Adjektive.txt` | 2026-09-27 | شکل نادر (رایج: «legasthenisch» که ساخته شد)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 286 | leidsam | `Adjektive.txt` | 2026-09-27 | قدیمی/نادر؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| 287 | leinen | `Adjektive.txt` | 2026-09-27 | صفت جنس («از کتان») — مثل flanellen کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 288 | leinwand | `Adjektive.txt` | 2026-09-27 | املای مشکوک (شکل رایج اتریشی «leiwand» است که ساخته شد) ⇒ تصمیم با Lukas | — |
| 289 | letzter | `Adjektive.txt` | 2026-09-27 | خطای فهرست: شکل صرف‌شده است؛ شکل پایه «letzte» است (مثل hinterer و innerer) ⇒ تصمیم با Lukas | — |
| 290 | levurozid | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر (شاید «مخمرکش»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 291 | lidschäftig | `Adjektive.txt` | 2026-09-27 | این کلمه را نمی‌شناسم؛ معنا نامطمئن است — قاعده‌ی ۱۴ | — |
| 292 | limnophil | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید «آب‌شیرین‌دوست»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 293 | linden | `Adjektive.txt` | 2026-09-27 | صفت جنس («از چوب نمدار») — مثل birken کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 294 | linker | `Adjektive.txt` | 2026-09-27 | خطای فهرست: شکل صرف‌شده است؛ شکل پایه «linke» است (مثل hinterer و letzter) ⇒ تصمیم با Lukas | — |
| 295 | listrisch | `Adjektive.txt` | 2026-09-27 | اصطلاح زمین‌شناسی نادر (شاید «گسل قاشقی»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 296 | lohfarben | `Adjektive.txt` | 2026-09-27 | رنگ نامطمئن (شاید «قهوه‌ای مایل به قرمز»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 297 | lucianisch | `Adjektive.txt` | 2026-09-27 | معنا نامطمئن (شاید «مربوط به لوکیان»)؛ نادر — قاعده‌ی ۱۴ | — |
| 298 | ludisch | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید «بازی‌گونه»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 299 | lübsch | `Adjektive.txt` | 2026-09-27 | قدیمی/تاریخی (شاید «مربوط به لوبک»، مثل lübsches Recht)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 300 | lüdisch | `Adjektive.txt` | 2026-09-27 | این کلمه را نمی‌شناسم؛ معنا نامطمئن است — قاعده‌ی ۱۴ | — |
| 301 | lukulent | `Adjektive.txt` | 2026-09-27 | این کلمه را نمی‌شناسم (شاید شکل دیگری از «lukullisch»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 302 | luminös | `Adjektive.txt` | 2026-09-27 | نادر/ادبی (شاید «درخشان»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 303 | lustgetrieben | `Adjektive.txt` | 2026-09-27 | ترکیب آزاد («لذت‌محور»)؛ شکل ثبت‌شده‌ای برایش نمی‌شناسم — قاعده‌ی ۱۴ | — |
| 304 | mainzisch | `Adjektive.txt` | 2026-09-27 | شکل مشکوک است (صفت رایج شهر: «Mainzer») ⇒ تصمیم با Lukas | — |
| 305 | majorenn | `Adjektive.txt` | 2026-09-27 | قدیمی (شاید «بالغ قانونی»)؛ کاربرد امروزی‌اش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 306 | mamertinisch | `Adjektive.txt` | 2026-09-27 | واژه‌ی تاریخی نادر (شاید مربوط به «ممرتینی‌ها»)؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| 307 | mancherlei | `Adjektive.txt` | 2026-09-27 | Wortart مشکوک است (دودن: عدد نامعین/ضمیر، صرف‌نشدنی)؛ مطمئن نیستم با کدام Wortart بسازم ⇒ تصمیم با Lukas | — |
| 308 | marastisch | `Adjektive.txt` | 2026-09-27 | شکل مشکوک است (پزشکی: شاید «marantisch» = لاغر و فرسوده) ⇒ تصمیم با Lukas | — |
| 309 | marktbar | `Adjektive.txt` | 2026-09-27 | این کلمه را نمی‌شناسم (شاید «قابل عرضه در بازار»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 310 | maschinenmäßig | `Adjektive.txt` | 2026-09-27 | ترکیب آزاد (شاید «ماشین‌وار»)؛ شکل ثبت‌شده‌ای برایش نمی‌شناسم — قاعده‌ی ۱۴ | — |
| 311 | masturbatorisch | `Adjektive.txt` | 2026-09-27 | اصطلاح جنسی — برای اپ آموزشی بدون محدودیت سنی کنار گذاشته شد ⇒ تصمیم با Lukas | — |
| 312 | mediat | `Adjektive.txt` | 2026-09-27 | قدیمی/تاریخی (شاید «غیرمستقیم»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 313 | meißenisch | `Adjektive.txt` | 2026-09-27 | شکل مشکوک است (صفت رایج شهر: «Meißner»، مثل Meißner Porzellan) ⇒ تصمیم با Lukas | — |
| 314 | meißnisch | `Adjektive.txt` | 2026-09-27 | شکل مشکوک است (صفت رایج شهر: «Meißner») ⇒ تصمیم با Lukas | — |
| 315 | messingen | `Adjektive.txt` | 2026-09-27 | صفت جنس («از برنج (فلز)») — مثل flanellen کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 316 | metadiegetisch | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر روایت‌شناسی؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 317 | millenarisch | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید «هزاره‌گرا»)؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| 318 | minderer | `Adjektive.txt` | 2026-09-27 | خطای فهرست: شکل صرف‌شده است؛ شکل پایه «mindere» است (مثل hinterer و letzter) ⇒ تصمیم با Lukas | — |
| 319 | ministrabel | `Adjektive.txt` | 2026-09-27 | ادبی/نادر (شاید «شایسته‌ی وزارت»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 320 | mirakulös | `Adjektive.txt` | 2026-09-27 | ادبی/نادر (شاید «معجزه‌آسا»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 321 | mittelalterig | `Adjektive.txt` | 2026-09-27 | شکل مشکوک است (شاید «میان‌سال»)؛ کاربردش را مطمئن نیستم ⇒ تصمیم با Lukas | — |
| 322 | mittelaltrig | `Adjektive.txt` | 2026-09-27 | شکل مشکوک است (شاید شکل دیگر «mittelalterig»)؛ مطمئن نیستم ⇒ تصمیم با Lukas | — |
| 323 | mnestisch | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید «حافظه‌ای»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 324 | moderativ | `Adjektive.txt` | 2026-09-27 | این کلمه را نمی‌شناسم (شاید «تعدیل‌کننده»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 325 | monadisch | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (فلسفه/ریاضی)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 326 | monadologisch | `Adjektive.txt` | 2026-09-27 | اصطلاح فلسفی بسیار نادر (لایب‌نیتس)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 327 | mongolid | `Adjektive.txt` | 2026-09-27 | اصطلاح قدیمی نژادشناختی که امروز تبعیض‌آمیز شمرده می‌شود ⇒ تصمیم با Lukas | — |
| 328 | mongoloid | `Adjektive.txt` | 2026-09-27 | اصطلاح قدیمی نژادشناختی/تحقیرآمیز ⇒ تصمیم با Lukas | — |
| 329 | moros | `Adjektive.txt` | 2026-09-27 | قدیمی (شاید «بدعنق»)؛ کاربرد امروزی‌اش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 330 | moselromanisch | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر تاریخ زبان (شاید «رومیِ موزلی»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 331 | nachmalig | `Adjektive.txt` | 2026-09-27 | قدیمی (شاید «بعدی، آینده»)؛ کاربرد امروزی‌اش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 332 | nachrichtlich | `Adjektive.txt` | 2026-09-27 | زبان اداری (شاید «جهت اطلاع»)؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| 333 | nächst | `Adjektive.txt` | 2026-09-27 | شکل عالیِ «nah» است، نه یک صفت پایه‌ی جدا ⇒ تصمیم با Lukas | — |
| 334 | nämlich | `Adjektive.txt` | 2026-09-27 | Wortart مشکوک است (بیشتر قید است؛ کاربرد صفتی «der nämliche» قدیمی است) ⇒ تصمیم با Lukas | — |
| 335 | naschsüchtig | `Adjektive.txt` | 2026-09-27 | نادر (شاید شکل دیگری از «naschhaft» که ساخته شد)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 336 | neolamarckistisch | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر (تاریخ زیست‌شناسی)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 337 | neovitalistisch | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر (فلسفه/زیست‌شناسی)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 338 | neurasthenisch | `Adjektive.txt` | 2026-09-27 | اصطلاح پزشکی قدیمی (نوراستنی)؛ کاربرد امروزی‌اش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 339 | neusilbern | `Adjektive.txt` | 2026-09-27 | صفت جنس («از ورشو/نقره‌ی آلمانی») — مثل flanellen کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 340 | neusumerisch | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر (شرق‌شناسی باستان)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 341 | nichtperturbativ | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر فیزیک؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 342 | nillenkrank | `Adjektive.txt` | 2026-09-27 | این کلمه را نمی‌شناسم (احتمالاً عامیانه‌ی رکیک/محلی)؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| 343 | nordelbisch | `Adjektive.txt` | 2026-09-27 | نادر/محلی (شاید «شمال رود البه»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 344 | notgeil | `Adjektive.txt` | 2026-09-27 | اصطلاح جنسیِ رکیک — برای اپ آموزشی بدون محدودیت سنی کنار گذاشته شد ⇒ تصمیم با Lukas | — |
| 345 | oberer | `Adjektive.txt` | 2026-09-27 | خطای فهرست: شکل صرف‌شده است؛ شکل پایه «obere» است (مثل hinterer و innerer) ⇒ تصمیم با Lukas | — |
| 346 | oberschlächtig | `Adjektive.txt` | 2026-09-27 | اصطلاح فنی (چرخ آسیاب آبی که آب از بالا می‌خورد)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 347 | obliviös | `Adjektive.txt` | 2026-09-27 | این کلمه را نمی‌شناسم (شاید «فراموشکار»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 348 | obstinat | `Adjektive.txt` | 2026-09-27 | قدیمی/ادبی (شاید «لجوج»)؛ کاربرد امروزی‌اش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 349 | öffenbar | `Adjektive.txt` | 2026-09-27 | این کلمه را نمی‌شناسم (شاید خطای «offenbar»)؛ شکل مشکوک ⇒ تصمیم با Lukas | — |
| 350 | ogygisch | `Adjektive.txt` | 2026-09-27 | بسیار نادر/ادبی (شاید «بسیار کهن»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 351 | oknophil | `Adjektive.txt` | 2026-09-27 | اصطلاح روانکاوی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 352 | opalen | `Adjektive.txt` | 2026-09-27 | صفت جنس («از عقیق سلیمانی/اوپال») — مثل flanellen کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 353 | oreal | `Adjektive.txt` | 2026-09-27 | این کلمه را نمی‌شناسم (شاید جغرافیا: «کوهستانی»)؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| 354 | orthotrop | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (گیاه‌شناسی/فنی)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 355 | oskisch | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر (زبان باستانی ایتالیا)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 356 | ostensibel | `Adjektive.txt` | 2026-09-27 | قدیمی/ادبی؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 357 | ostfälisch | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر گویش‌شناسی؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 358 | ostgrönländisch | `Adjektive.txt` | 2026-09-27 | بسیار نادر؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 359 | ouvert | `Adjektive.txt` | 2026-09-27 | اصطلاح خاص (بازی ورق/فرانسوی)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 360 | ovovivipar | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر زیست‌شناسی؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 361 | pädophil | `Adjektive.txt` | 2026-09-27 | اصطلاح حساس پزشکی-حقوقی — برای اپ آموزشی بدون محدودیت سنی کنار گذاشته شد ⇒ تصمیم با Lukas | — |
| 362 | pagatorisch | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر حسابداری؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 363 | palato-alveolar | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر آواشناسی (با خط تیره)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 364 | panchronisch | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر زبان‌شناسی؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 365 | panhellenisch | `Adjektive.txt` | 2026-09-27 | نادر (شاید «مربوط به همه‌ی یونانیان»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 366 | papabile | `Adjektive.txt` | 2026-09-27 | شکل ایتالیایی «papabel» (که ساخته شد)؛ مطمئن نیستم ⇒ تصمیم با Lukas | — |
| 367 | papieren | `Adjektive.txt` | 2026-09-27 | صفت جنس («کاغذی») — مثل flanellen کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 368 | papiern | `Adjektive.txt` | 2026-09-27 | شکل دیگر «papieren» (صفت جنس)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 369 | papstfähig | `Adjektive.txt` | 2026-09-27 | ترکیب آزاد (شاید معادل «papabel» که ساخته شد)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 370 | paradoxal | `Adjektive.txt` | 2026-09-27 | شکل نادر «paradox» (که ساخته شد)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 371 | parasprachlich | `Adjektive.txt` | 2026-09-27 | شکل نادر «paralinguistisch» (که ساخته شد)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 372 | paraxial | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر نورشناسی؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 373 | pariserisch | `Adjektive.txt` | 2026-09-27 | شکل مشکوک است (صفت رایج شهر: «Pariser») ⇒ تصمیم با Lukas | — |
| 374 | partial | `Adjektive.txt` | 2026-09-27 | شکل نادر «partiell» (که ساخته شد)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 375 | passiert | `Adjektive.txt` | 2026-09-27 | اسم مفعول «passieren» (در آشپزی: «از صافی ردشده»)؛ به‌عنوان صفت مطمئن نیستم ⇒ تصمیم با Lukas | — |
| 376 | pastellen | `Adjektive.txt` | 2026-09-27 | نادر (شاید «به رنگ پاستلی»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 377 | patrologisch | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر الهیات (پدران کلیسا)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 378 | pekig | `Adjektive.txt` | 2026-09-27 | این کلمه را نمی‌شناسم (شاید محلی)؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| 379 | penil | `Adjektive.txt` | 2026-09-27 | اصطلاح کالبدشناسی مربوط به اندام جنسی — برای اپ آموزشی بدون محدودیت سنی کنار گذاشته شد ⇒ تصمیم با Lukas | — |
| 380 | pentelisch | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر (مرمر پنتلی)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 381 | perdu | `Adjektive.txt` | 2026-09-27 | عامیانه/قدیمی (شاید «از دست رفته»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 382 | pergamenisch | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید «مربوط به پرگامون»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 383 | pergamenten | `Adjektive.txt` | 2026-09-27 | صفت جنس («از پوست نوشتنی») — مثل flanellen کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 384 | perimortal | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر پزشکی قانونی؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 385 | perkussiv | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (موسیقی/پزشکی)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 386 | perlmuttern | `Adjektive.txt` | 2026-09-27 | صفت جنس («از صدف») — مثل flanellen کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 387 | permutabel | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر ریاضی؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 388 | perpendikular | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید «عمود»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 389 | perpetuell | `Adjektive.txt` | 2026-09-27 | ادبی/نادر (شاید «همیشگی»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 390 | pervasiv | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (شاید «فراگیر»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 391 | pervers | `Adjektive.txt` | 2026-09-27 | معنای اصلی‌اش جنسی است — برای اپ آموزشی بدون محدودیت سنی کنار گذاشته شد ⇒ تصمیم با Lukas | — |
| 392 | pestilenzartig | `Adjektive.txt` | 2026-09-27 | قدیمی/نادر (شاید «طاعون‌وار»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 393 | phallisch | `Adjektive.txt` | 2026-09-27 | اصطلاح با بار جنسی — برای اپ آموزشی بدون محدودیت سنی کنار گذاشته شد ⇒ تصمیم با Lukas | — |
| 394 | phaneromer | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر زمین‌شناسی؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 395 | phyletisch | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر (تبارشناسی)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 396 | pikarisch | `Adjektive.txt` | 2026-09-27 | شکل نادر «pikaresk» (که ساخته شد)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 397 | pithekoid | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر انسان‌شناسی؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 398 | pitschepatschenass | `Adjektive.txt` | 2026-09-27 | شکل عامیانه‌ی تقویت‌شده‌ی «pitschnass» (که ساخته شد)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 399 | platzmäßig | `Adjektive.txt` | 2026-09-27 | نادر (شاید ورزشی: «از نظر زمین بازی»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 400 | plerophor | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| 401 | plüschen | `Adjektive.txt` | 2026-09-27 | صفت جنس («از مخمل پرزدار») — مثل flanellen کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 402 | pluralisch | `Adjektive.txt` | 2026-09-27 | نادر (شاید «جمعی»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 403 | poemisch | `Adjektive.txt` | 2026-09-27 | این کلمه را نمی‌شناسم؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| 404 | polabisch | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر (زبانی منقرض)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 405 | polemogen | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر (شاید «جنگ‌زا»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 406 | polydispers | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر شیمی؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 407 | polytoxikoman | `Adjektive.txt` | 2026-09-27 | اصطلاح پزشکی (اعتیاد چندگانه) — حساس ⇒ تصمیم با Lukas | — |
| 408 | polytrop | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 409 | polyzyklisch | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر شیمی؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 410 | pongid | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر جانورشناسی؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 411 | pornografisch | `Adjektive.txt` | 2026-09-27 | محتوای جنسی — برای اپ آموزشی بدون محدودیت سنی کنار گذاشته شد ⇒ تصمیم با Lukas | — |
| 412 | pornographisch | `Adjektive.txt` | 2026-09-27 | محتوای جنسی (املای دیگر) — کنار گذاشته شد ⇒ تصمیم با Lukas | — |
| 413 | porzellanen | `Adjektive.txt` | 2026-09-27 | صفت جنس («چینی») — مثل flanellen کنار گذاشته شد — قاعده‌ی ۱۴ | — |
| 414 | porzin | `Adjektive.txt` | 2026-09-27 | اصطلاح فنی (شاید «خوکی» در پزشکی)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 415 | postalveolar | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر آواشناسی؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 416 | postfrisch | `Adjektive.txt` | 2026-09-27 | اصطلاح خاص (تمبرشناسی: تمبر استفاده‌نشده)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 417 | postulationsfähig | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر حقوقی؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 418 | potentiometrisch | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر (شیمی/اندازه‌گیری)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 419 | potenzsteigernd | `Adjektive.txt` | 2026-09-27 | با بار جنسی — برای اپ آموزشی بدون محدودیت سنی کنار گذاشته شد ⇒ تصمیم با Lukas | — |
| 420 | prädiktabel | `Adjektive.txt` | 2026-09-27 | نادر (شاید «پیش‌بینی‌پذیر»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 421 | präjudiziell | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر حقوقی؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 422 | präliminär | `Adjektive.txt` | 2026-09-27 | ادبی/نادر (شاید «مقدماتی»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 423 | prämonetär | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 424 | präplanetar | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر نجوم؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 425 | prärogativ | `Adjektive.txt` | 2026-09-27 | نادر (شاید «امتیازی»)؛ کاربردش را مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 426 | präsentisch | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر دستوری؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 427 | präsidiabel | `Adjektive.txt` | 2026-09-27 | ادبی/نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 428 | präsumtiv | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر حقوقی؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 429 | präterital | `Adjektive.txt` | 2026-09-27 | اصطلاح نادر دستوری؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 430 | primordial | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر (شاید «آغازین»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 431 | promisk | `Adjektive.txt` | 2026-09-27 | اصطلاح جنسی — برای اپ آموزشی بدون محدودیت سنی کنار گذاشته شد ⇒ تصمیم با Lukas | — |
| 432 | promiskuitiv | `Adjektive.txt` | 2026-09-27 | اصطلاح جنسی (شکل دیگر) — کنار گذاشته شد ⇒ تصمیم با Lukas | — |
| 433 | prosopografisch | `Adjektive.txt` | 2026-09-27 | اصطلاح بسیار نادر تاریخ‌نگاری؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 434 | proteisch | `Adjektive.txt` | 2026-09-27 | ادبی/نادر (شاید «دگرگون‌شونده»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 435 | psychrophil | `Adjektive.txt` | 2026-09-29 | اصطلاح زیست‌شناسی بسیار نادر (شاید «سرمادوست»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 436 | pueril | `Adjektive.txt` | 2026-09-29 | ادبی/نادر (شاید «کودکانه»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 437 | punitiv | `Adjektive.txt` | 2026-09-29 | ادبی/حقوقی نادر (شاید «تنبیهی»)؛ کاربرد نامطمئن — قاعده‌ی ۱۴ | — |
| 438 | pythonesk | `Adjektive.txt` | 2026-09-29 | بسیار نادر (شاید «به سبک Monty Python»)؛ معنا نامطمئن — قاعده‌ی ۱۴ | — |
| 439 | quinär | `Adjektive.txt` | 2026-09-29 | اصطلاح تخصصی نادر (شاید «پنج‌گانه»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 440 | quittegelb | `Adjektive.txt` | 2026-09-29 | شکل فرعی quittengelb؛ املا نامطمئن — قاعده‌ی ۱۴ | — |
| 441 | quotal | `Adjektive.txt` | 2026-09-29 | اصطلاح تخصصی نادر (شاید «سهمی»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 442 | räß | `Adjektive.txt` | 2026-09-29 | محلی (سوئیس/جنوب آلمان)؛ معنا نامطمئن — قاعده‌ی ۱۴ | — |
| 443 | räumdig | `Adjektive.txt` | 2026-09-29 | معنا و املا نامطمئن — قاعده‌ی ۱۴ | — |
| 444 | rahn | `Adjektive.txt` | 2026-09-29 | محلی/کهنه؛ معنا نامطمئن — قاعده‌ی ۱۴ | — |
| 445 | rallig | `Adjektive.txt` | 2026-09-29 | زبان شکارچی‌ها/عامیانه؛ معنا نامطمئن — قاعده‌ی ۱۴ | — |
| 446 | rangig | `Adjektive.txt` | 2026-09-29 | تقریباً فقط جزء دوم ترکیب (hochrangig …)؛ کاربرد مستقل نامطمئن — قاعده‌ی ۱۴ | — |
| 447 | raß | `Adjektive.txt` | 2026-09-29 | محلی (شکل فرعی räß)؛ معنا نامطمئن — قاعده‌ی ۱۴ | — |
| 448 | ratierlich | `Adjektive.txt` | 2026-09-29 | زبان حقوقی، بسیار نادر؛ کاربرد نامطمئن — قاعده‌ی ۱۴ | — |
| 449 | raubauzig | `Adjektive.txt` | 2026-09-29 | محلی/عامیانه؛ معنا نامطمئن — قاعده‌ی ۱۴ | — |
| 450 | rebenumsponnen | `Adjektive.txt` | 2026-09-29 | شاعرانه و بسیار نادر؛ کاربرد نامطمئن — قاعده‌ی ۱۴ | — |
| 451 | renaissancistisch | `Adjektive.txt` | 2026-09-29 | بسیار نادر؛ معنا و کاربرد نامطمئن — قاعده‌ی ۱۴ | — |
| 452 | reputabel | `Adjektive.txt` | 2026-09-29 | ادبی و بسیار نادر (شاید «آبرومند»)؛ کاربرد نامطمئن — قاعده‌ی ۱۴ | — |
| 453 | reputierlich | `Adjektive.txt` | 2026-09-29 | کهنه و بسیار نادر؛ کاربرد نامطمئن — قاعده‌ی ۱۴ | — |
| 454 | resonant | `Adjektive.txt` | 2026-09-29 | در آلمانی نادر؛ کاربرد نامطمئن — قاعده‌ی ۱۴ | — |
| 455 | respektiv | `Adjektive.txt` | 2026-09-29 | کهنه؛ کاربرد نامطمئن — قاعده‌ی ۱۴ | — |
| 456 | restituiert | `Adjektive.txt` | 2026-09-29 | اسم مفعول/اصطلاح تخصصی؛ کاربرد صفتی نامطمئن — قاعده‌ی ۱۴ | — |
| 457 | restitutiv | `Adjektive.txt` | 2026-09-29 | اصطلاح تخصصی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 458 | retikulär | `Adjektive.txt` | 2026-09-29 | اصطلاح پزشکی بسیار نادر (شاید «مشبک»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 459 | retinotop | `Adjektive.txt` | 2026-09-29 | اصطلاح عصب‌شناسی؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 460 | retransloziert | `Adjektive.txt` | 2026-09-29 | اصطلاح تخصصی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 461 | retroaktiv | `Adjektive.txt` | 2026-09-29 | در آلمانی نادر (شاید «عطف به ماسبق»)؛ کاربرد نامطمئن — قاعده‌ی ۱۴ | — |
| 462 | retrobulbär | `Adjektive.txt` | 2026-09-29 | اصطلاح پزشکی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 463 | retrofuturistisch | `Adjektive.txt` | 2026-09-29 | اصطلاح سبکی؛ ثبت در فرهنگ‌ها نامطمئن — قاعده‌ی ۱۴ | — |
| 464 | rezent | `Adjektive.txt` | 2026-09-29 | چندمعنایی (زیست‌شناسی: امروزی / محلی: ترش‌مزه)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 465 | rezeptorvermittelt | `Adjektive.txt` | 2026-09-29 | اصطلاح تخصصی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 466 | rheophil | `Adjektive.txt` | 2026-09-29 | اصطلاح زیست‌شناسی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 467 | rhodiniert | `Adjektive.txt` | 2026-09-29 | اصطلاح تخصصی (جواهرسازی)، بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 468 | rhomboedrisch | `Adjektive.txt` | 2026-09-29 | اصطلاح تخصصی (بلورشناسی)، بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 469 | ridikül | `Adjektive.txt` | 2026-09-29 | کهنه/ادبی (شاید «مسخره»)؛ کاربرد نامطمئن — قاعده‌ی ۱۴ | — |
| 470 | rodelfrei | `Adjektive.txt` | 2026-10-08 | اصطلاح محلی/نادر (شاید «مجاز برای سورتمه»)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 471 | röntgenabsorbierend | `Adjektive.txt` | 2026-10-08 | اصطلاح تخصصی بسیار نادر (فیزیک/پزشکی)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 472 | rösch | `Adjektive.txt` | 2026-10-08 | محلی (جنوب آلمان/اتریش، «ترد»)؛ کاربرد نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 473 | romfreundlich | `Adjektive.txt` | 2026-10-08 | ترکیب نادر؛ ثبت در دیکشنری نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 474 | rossig | `Adjektive.txt` | 2026-10-08 | اصطلاح تخصصی/کهنه (مادیان)؛ کاربرد نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 475 | rostral | `Adjektive.txt` | 2026-10-08 | اصطلاح تخصصی کالبدشناسی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 476 | rücklaufend | `Adjektive.txt` | 2026-10-08 | صفت‌فعلی نادر؛ ثبت در دیکشنری نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 477 | rückwärtsgekrümmt | `Adjektive.txt` | 2026-10-08 | ترکیب بسیار نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 478 | rügensch | `Adjektive.txt` | 2026-10-08 | صفت مکانی (جزیره‌ی رودن)؛ کاربرد نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 479 | rüstern | `Adjektive.txt` | 2026-10-08 | صفت جنس (از چوب نارون)؛ مثل birken، تصمیم با Lukas؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 480 | runtergerockt | `Adjektive.txt` | 2026-10-08 | عامیانه؛ ثبت در دیکشنری نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 481 | sackleinen | `Adjektive.txt` | 2026-10-08 | صفت جنس (از کتان گونی)؛ مثل birken، تصمیم با Lukas؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 482 | salpeterhaltig | `Adjektive.txt` | 2026-10-08 | ترکیب تخصصی؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 483 | salzburgerisch | `Adjektive.txt` | 2026-10-08 | شکل نامعمول (salzburgisch کارت دارد)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 484 | samten | `Adjektive.txt` | 2026-10-08 | صفت جنس (از مخمل)؛ مثل birken، تصمیم با Lukas؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 485 | saphiren | `Adjektive.txt` | 2026-10-08 | صفت جنس (از یاقوت کبود)؛ مثل birken، تصمیم با Lukas؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 486 | satzwertig | `Adjektive.txt` | 2026-10-08 | اصطلاح تخصصی زبان‌شناسی؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 487 | saubillig | `Adjektive.txt` | 2026-10-08 | عامیانه/منطقه‌ای؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 488 | scharlachen | `Adjektive.txt` | 2026-10-08 | صفت جنس (از قرمز تند)؛ مثل birken، تصمیم با Lukas؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 489 | schau | `Adjektive.txt` | 2026-10-08 | منطقه‌ای (جنوب)؛ کاربرد نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 490 | scheiße | `Adjektive.txt` | 2026-10-08 | عامیانه و رکیک؛ تصمیم با Lukas؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 491 | scheißegal | `Adjektive.txt` | 2026-10-08 | عامیانه و رکیک؛ تصمیم با Lukas؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 492 | scheißfreundlich | `Adjektive.txt` | 2026-10-08 | عامیانه و رکیک؛ تصمیم با Lukas؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 493 | schicker | `Adjektive.txt` | 2026-10-08 | شکل تفضیلی schick (نه لم)؛ خطای فهرست؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 494 | schiefern | `Adjektive.txt` | 2026-10-08 | صفت جنس (از تخته‌سنگ)؛ مثل birken؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 495 | schilfen | `Adjektive.txt` | 2026-10-08 | صفت جنس (از نی)؛ مثل birken؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 496 | schilfleinen | `Adjektive.txt` | 2026-10-08 | صفت جنس (از کتان نی)؛ مثل birken؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 497 | schismogen | `Adjektive.txt` | 2026-10-08 | اصطلاح تخصصی بسیار نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 498 | schlagzeilenträchtig | `Adjektive.txt` | 2026-10-08 | ترکیب نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 499 | schleckig | `Adjektive.txt` | 2026-10-08 | منطقه‌ای؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 500 | schmerzenvoll | `Adjektive.txt` | 2026-10-08 | شکل نامعمول (schmerzvoll/schmerzensreich)؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 501 | schnäukig | `Adjektive.txt` | 2026-10-08 | منطقه‌ای (شمال)؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 502 | schoflig | `Adjektive.txt` | 2026-10-08 | شکل نامعمول (schofel/schofelig کارت دارند)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 503 | schokoladen | `Adjektive.txt` | 2026-10-08 | صفت جنس (از شکلات)؛ مثل birken؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 504 | schulautonom | `Adjektive.txt` | 2026-10-08 | اصطلاح تخصصی آموزش؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 505 | schurwollen | `Adjektive.txt` | 2026-10-08 | صفت جنس (از پشم خالص)؛ مثل birken؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 506 | schwachsinnig | `Adjektive.txt` | 2026-10-08 | برچسب توهین‌آمیز/قدیمی؛ تصمیم با Lukas؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 507 | schwätzicht | `Adjektive.txt` | 2026-10-08 | شکل نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 508 | schwanzgesteuert | `Adjektive.txt` | 2026-10-08 | عامیانه و رکیک؛ تصمیم با Lukas؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 509 | schwarzfeldrig | `Adjektive.txt` | 2026-10-08 | اصطلاح تخصصی بسیار نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 510 | schweinern | `Adjektive.txt` | 2026-10-08 | صفت جنس (از گوشت خوک)؛ مثل birken؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 511 | schwerkriegsbeschädigt | `Adjektive.txt` | 2026-10-08 | اصطلاح اداری تاریخی؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 512 | schwerlötig | `Adjektive.txt` | 2026-10-08 | اصطلاح تخصصی بسیار نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 513 | sechsarmig | `Adjektive.txt` | 2026-10-08 | ترکیب بسیار نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 514 | seiden | `Adjektive.txt` | 2026-10-08 | صفت جنس (از ابریشم)؛ مثل birken؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 515 | seiger | `Adjektive.txt` | 2026-10-08 | اصطلاح معدن‌کاری؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 516 | seimig | `Adjektive.txt` | 2026-10-08 | منطقه‌ای؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 517 | sekkant | `Adjektive.txt` | 2026-10-08 | اتریشی/عامیانه؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 518 | selektionistisch | `Adjektive.txt` | 2026-10-08 | اصطلاح تخصصی بسیار نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 519 | semesterbegleitend | `Adjektive.txt` | 2026-10-08 | ترکیب شفاف ولی ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 520 | serbisch-montenegrinisch | `Adjektive.txt` | 2026-10-08 | اصطلاح تاریخی/سیاسی؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 521 | sexbesessen | `Adjektive.txt` | 2026-10-08 | عامیانه و رکیک؛ تصمیم با Lukas؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 522 | sichergestellt | `Adjektive.txt` | 2026-10-08 | صفت‌فعلی؛ ثبت در دیکشنری نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 523 | sichtlaut | `Adjektive.txt` | 2026-10-08 | اصطلاح تخصصی بسیار نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 524 | silbentragend | `Adjektive.txt` | 2026-10-08 | اصطلاح تخصصی نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 525 | silbern | `Adjektive.txt` | 2026-10-08 | صفت جنس (از نقره)؛ مثل birken، تصمیم با Lukas؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 526 | siliziumhaltig | `Adjektive.txt` | 2026-10-08 | اصطلاح تخصصی؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 527 | sinnfrei | `Adjektive.txt` | 2026-10-08 | عامیانه/نوظهور؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 528 | siriusfern | `Adjektive.txt` | 2026-10-08 | ترکیب بسیار نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 529 | skatologisch | `Adjektive.txt` | 2026-10-08 | اصطلاح تخصصی و رکیک؛ تصمیم با Lukas؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 530 | skoptisch | `Adjektive.txt` | 2026-10-08 | اصطلاح تخصصی بسیار نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 531 | small | `Adjektive.txt` | 2026-10-08 | اصطلاح انگلیسی/عامیانه؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 532 | smaragden | `Adjektive.txt` | 2026-10-08 | صفت جنس (از زمرد)؛ مثل birken؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 533 | sodomitisch | `Adjektive.txt` | 2026-10-08 | اصطلاح قدیمی و حساس؛ تصمیم با Lukas؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 534 | solarthermisch | `Adjektive.txt` | 2026-10-08 | اصطلاح تخصصی؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 535 | solenn | `Adjektive.txt` | 2026-10-08 | اصطلاح بسیار نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 536 | sozioökologisch | `Adjektive.txt` | 2026-10-08 | ترکیب تخصصی؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 537 | spack | `Adjektive.txt` | 2026-10-08 | منطقه‌ای (شمال)؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 538 | spackig | `Adjektive.txt` | 2026-10-08 | منطقه‌ای/عامیانه؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 539 | spätmittelhochdeutsch | `Adjektive.txt` | 2026-10-08 | اصطلاح بسیار تخصصی؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 540 | SPD-geführt | `Adjektive.txt` | 2026-10-08 | ترکیب سیاسی گذرا؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 541 | speditiv | `Adjektive.txt` | 2026-10-08 | سوئیسی/اداری؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 542 | speicherresident | `Adjektive.txt` | 2026-10-08 | اصطلاح فنی بسیار تخصصی؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 543 | spillerig | `Adjektive.txt` | 2026-10-08 | منطقه‌ای؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 544 | spillrig | `Adjektive.txt` | 2026-10-08 | منطقه‌ای؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 545 | splitterfasernackt | `Adjektive.txt` | 2026-10-08 | تقویت‌شده‌ی عامیانه؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 546 | spottschlecht | `Adjektive.txt` | 2026-10-08 | ترکیب عامیانه؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 547 | spottsüchtig | `Adjektive.txt` | 2026-10-08 | ترکیب نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 548 | spritig | `Adjektive.txt` | 2026-10-08 | منطقه‌ای/نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 549 | stählern | `Adjektive.txt` | 2026-10-08 | صفت جنس (از فولاد)؛ مثل birken؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 550 | stärkehaltig | `Adjektive.txt` | 2026-10-08 | ترکیب تخصصی؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 551 | statutarisch | `Adjektive.txt` | 2026-10-08 | اصطلاح حقوقی نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 552 | steinern | `Adjektive.txt` | 2026-10-08 | صفت جنس (از سنگ)؛ مثل birken؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 553 | stenök | `Adjektive.txt` | 2026-10-08 | اصطلاح تخصصی زیست‌بوم‌شناسی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 554 | stenohalin | `Adjektive.txt` | 2026-10-08 | اصطلاح تخصصی زیست‌شناسی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 555 | stichometrisch | `Adjektive.txt` | 2026-10-08 | اصطلاح تخصصی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 556 | stichprobenhaft | `Adjektive.txt` | 2026-10-08 | شکل نامعمول (stichprobenartig کارت دارد)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 557 | stickstoffhaltig | `Adjektive.txt` | 2026-10-08 | ترکیب تخصصی؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 558 | stier | `Adjektive.txt` | 2026-10-08 | چندمعنایی و منطقه‌ای (اتریش: بی‌پول)؛ نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 559 | stilmäßig | `Adjektive.txt` | 2026-10-08 | عامیانه؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 560 | stomachal | `Adjektive.txt` | 2026-10-08 | اصطلاح پزشکی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 561 | stotterig | `Adjektive.txt` | 2026-10-08 | شکل محاوره‌ای نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 562 | stottrig | `Adjektive.txt` | 2026-10-08 | شکل محاوره‌ای نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 563 | strack | `Adjektive.txt` | 2026-10-08 | منطقه‌ای/کهنه؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 564 | strafbewehrt | `Adjektive.txt` | 2026-10-08 | اصطلاح حقوقی نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 565 | strafmindernd | `Adjektive.txt` | 2026-10-08 | شکل نامعمول (strafmildernd کارت دارد)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 566 | strafverdächtig | `Adjektive.txt` | 2026-10-08 | ترکیب حقوقی؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 567 | straßenköterblond | `Adjektive.txt` | 2026-10-08 | عامیانه و تحقیرآمیز؛ تصمیم با Lukas؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 568 | streitbefangen | `Adjektive.txt` | 2026-10-08 | اصطلاح حقوقی نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 569 | stressresistent | `Adjektive.txt` | 2026-10-08 | ترکیب نوظهور؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 570 | streufähig | `Adjektive.txt` | 2026-10-08 | ترکیب فنی؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 571 | strohen | `Adjektive.txt` | 2026-10-08 | صفت جنس (از کاه)؛ مثل birken؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 572 | strunzdumm | `Adjektive.txt` | 2026-10-08 | عامیانه و توهین‌آمیز؛ تصمیم با Lukas؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 573 | subaquatisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 574 | subfossil | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی زمین‌شناسی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 575 | subgingival | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی دندان‌پزشکی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 576 | subglazial | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی یخچال‌شناسی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 577 | subkonszient | `Adjektive.txt` | 2026-10-09 | اصطلاح روان‌شناسی کهنه؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 578 | subkrustal | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی زمین‌شناسی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 579 | sublunarisch | `Adjektive.txt` | 2026-10-09 | اصطلاح فلسفی کهنه؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 580 | submers | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی زیست‌شناسی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 581 | submikroskopisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 582 | submukös | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی پزشکی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 583 | subnival | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی جغرافیا؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 584 | suborbital | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی فضایی/پزشکی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 585 | subperiostal | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی پزشکی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 586 | subphrenisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی پزشکی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 587 | subsumtiv | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی منطق/حقوق؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 588 | subterran | `Adjektive.txt` | 2026-10-09 | اصطلاح ادبی/تخصصی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 589 | subungual | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی پزشکی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 590 | suburbikarisch | `Adjektive.txt` | 2026-10-09 | اصطلاح کلیسایی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 591 | südostdeutsch | `Adjektive.txt` | 2026-10-09 | ترکیب جغرافیایی نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 592 | sulzig | `Adjektive.txt` | 2026-10-09 | منطقه‌ای؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 593 | summativ | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی آموزش؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 594 | supergen | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 595 | superlativ | `Adjektive.txt` | 2026-10-09 | کاربرد صفتی نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 596 | superprovisorisch | `Adjektive.txt` | 2026-10-09 | اصطلاح حقوقی سوئیسی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 597 | suppressiv | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی پزشکی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 598 | supragingival | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی دندان‌پزشکی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 599 | suprapubisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی پزشکی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 600 | surjektiv | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی ریاضی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 601 | suszeptibel | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 602 | swasiländisch | `Adjektive.txt` | 2026-10-09 | نام قدیمی کشور (اسواتینی)؛ نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 603 | sympathetisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی/کهنه؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 604 | syndetisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی زبان‌شناسی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 605 | synekdochisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی بلاغت؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 606 | synergistisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 607 | synkretistisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی دین‌پژوهی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 608 | synsemantisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی زبان‌شناسی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 609 | synsystematisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 610 | syntagmatisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی زبان‌شناسی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 611 | syntaxonomisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 612 | syntonisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی روان‌شناسی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 613 | systemlos | `Adjektive.txt` | 2026-10-09 | ترکیب نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 614 | systemoid | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 615 | szientifisch | `Adjektive.txt` | 2026-10-09 | اصطلاح کهنه؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 616 | tablettensüchtig | `Adjektive.txt` | 2026-10-09 | ترکیب حساس؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 617 | taften | `Adjektive.txt` | 2026-10-09 | صفت جنس (از تافته)؛ مثل birken؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 618 | talentfrei | `Adjektive.txt` | 2026-10-09 | عامیانه و طعنه‌آمیز؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 619 | talmudisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی دینی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 620 | tangibel | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی/نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 621 | tannen | `Adjektive.txt` | 2026-10-09 | صفت جنس (از چوب صنوبر)؛ مثل birken؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 622 | tarentinisch | `Adjektive.txt` | 2026-10-09 | صفت مکانی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 623 | taubstumm | `Adjektive.txt` | 2026-10-09 | واژه‌ی کهنه و آزاردهنده (به‌جایش gehörlos)؛ تصمیم با Lukas؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 624 | tausendstel | `Adjektive.txt` | 2026-10-09 | کسر عددی (نه صفت معمول)؛ نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 625 | taxativ | `Adjektive.txt` | 2026-10-09 | اصطلاح حقوقی اتریشی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 626 | teaken | `Adjektive.txt` | 2026-10-09 | صفت جنس (از چوب ساج)؛ مثل birken؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 627 | teilerfremd | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی ریاضی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 628 | teleoklin | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 629 | teleologisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی فلسفه؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 630 | tellurisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 631 | tentativ | `Adjektive.txt` | 2026-10-09 | اصطلاح ادبی نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 632 | teratogen | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی پزشکی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 633 | ternär | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی ریاضی/شیمی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 634 | terrisch | `Adjektive.txt` | 2026-10-09 | اصطلاح بسیار نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 635 | tetragonal | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی کریستال‌شناسی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 636 | thalassogen | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 637 | theodosianisch | `Adjektive.txt` | 2026-10-09 | صفت تاریخی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 638 | thermophil | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی زیست‌شناسی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 639 | thetisch | `Adjektive.txt` | 2026-10-09 | اصطلاح فلسفی نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 640 | thorakal | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی پزشکی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 641 | timokratisch | `Adjektive.txt` | 2026-10-09 | اصطلاح سیاسی/تاریخی نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 642 | timoresisch | `Adjektive.txt` | 2026-10-09 | صفت مکانی نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 643 | tobsüchtig | `Adjektive.txt` | 2026-10-09 | واژه‌ی پزشکی کهنه؛ نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 644 | todgeweiht | `Adjektive.txt` | 2026-10-09 | واژه‌ی سنگین و ادبی؛ تصمیم با Lukas؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 645 | töfte | `Adjektive.txt` | 2026-10-09 | عامیانه‌ی برلینی؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 646 | tönern | `Adjektive.txt` | 2026-10-09 | صفت جنس (از سفال)؛ مثل birken؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 647 | togoisch | `Adjektive.txt` | 2026-10-09 | شکل نامعمول (togolesisch کارت دارد)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 648 | tomatiert | `Adjektive.txt` | 2026-10-09 | اصطلاح آشپزی نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 649 | tongaisch | `Adjektive.txt` | 2026-10-09 | صفت مکانی نادر؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 650 | tonhaltig | `Adjektive.txt` | 2026-10-09 | ترکیب تخصصی؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 651 | tonisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی پزشکی/موسیقی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 652 | tonotop | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 653 | topasen | `Adjektive.txt` | 2026-10-09 | صفت جنس (از توپاز)؛ مثل birken؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 654 | topisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی پزشکی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 655 | toreutisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی هنر؛ بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 656 | totipotent | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی زیست‌شناسی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 657 | träf | `Adjektive.txt` | 2026-10-09 | سوئیسی؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 658 | transdisziplinär | `Adjektive.txt` | 2026-10-09 | اصطلاح علمی تخصصی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 659 | transfinit | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی ریاضی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 660 | transient | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 661 | transitorisch | `Adjektive.txt` | 2026-10-09 | اصطلاح ادبی/تخصصی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 662 | transmembranös | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی زیست‌شناسی؛ بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 663 | transregional | `Adjektive.txt` | 2026-10-09 | ترکیب تخصصی؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 664 | transspezifisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 665 | transzendental | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی فلسفه (کانت)؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 666 | treife | `Adjektive.txt` | 2026-10-09 | اصطلاح دینی یهودی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 667 | tribal | `Adjektive.txt` | 2026-10-09 | انگلیسی‌واژه‌ی نوظهور؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 668 | trichinenhaltig | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی بهداشت؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 669 | trilliardste | `Adjektive.txt` | 2026-10-09 | عدد ترتیبی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 670 | trillionste | `Adjektive.txt` | 2026-10-09 | عدد ترتیبی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 671 | trinär | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 672 | tropologisch | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی بلاغت/الهیات؛ نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 673 | trunksüchtig | `Adjektive.txt` | 2026-10-09 | واژه‌ی کهنه‌ی پزشکی؛ حساس؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 674 | trutzig | `Adjektive.txt` | 2026-10-09 | ادبی و کهنه؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 675 | tuchen | `Adjektive.txt` | 2026-10-09 | صفت جنس (از ماهوت)؛ مثل birken؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 676 | tumb | `Adjektive.txt` | 2026-10-09 | ادبی و کهنه؛ ثبت نامطمئن؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 677 | tumultuarisch | `Adjektive.txt` | 2026-10-09 | شکل ادبی نادر (tumultartig کارت دارد)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 678 | tuvaluisch | `Adjektive.txt` | 2026-10-09 | صفت مکانی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 679 | tuwinisch | `Adjektive.txt` | 2026-10-09 | صفت مکانی بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| 680 | tyrrhenisch | `Adjektive.txt` | 2026-10-09 | صفت جغرافیایی نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۶۸۱ | überwechtet | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی کوه‌نوردی/برف (لبه‌ی برفی)، نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۶۸۲ | unangesehen | `Adjektive.txt` | 2026-10-09 | کهنه (به معنای ungeachtet، بیشتر حرف اضافه)؛ کاربرد صفتی نامطمئن — قاعده‌ی ۱۴ | — |
| ۶۸۳ | unbedankt | `Adjektive.txt` | 2026-10-09 | نادر و کهنه؛ کاربرد رایجش را مطمئن نمی‌دانم — قاعده‌ی ۱۴ | — |
| ۶۸۴ | unbeugbar | `Adjektive.txt` | 2026-10-09 | دو معنای ممکن (خم‌نشدنی / صرف‌ناپذیر)؛ کاربرد رایجش را مطمئن نمی‌دانم — قاعده‌ی ۱۴ | — |
| ۶۸۵ | unbewehrt | `Adjektive.txt` | 2026-10-09 | نادر (بی‌سلاح / بتن بدون میلگرد)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۶۸۶ | undulös | `Adjektive.txt` | 2026-10-09 | اصطلاح تخصصی کانی‌شناسی، نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۶۸۷ | ungerechnet | `Adjektive.txt` | 2026-10-10 | کاربرد صفتی نامطمئن (بیشتر به‌شکل «ungerechnet + Gen» شبیه حرف اضافه)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۶۸۸ | ungeständig | `Adjektive.txt` | 2026-10-10 | اصطلاح حقوقی نادر (اقرارنکرده)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۶۸۹ | unikursal | `Adjektive.txt` | 2026-10-10 | اصطلاح تخصصی ریاضی (گراف/منحنی)، نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۶۹۰ | unitaristisch | `Adjektive.txt` | 2026-10-10 | اصطلاح تخصصی الهیات (Unitarier)، نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۶۹۱ | unleidig | `Adjektive.txt` | 2026-10-10 | واژه‌ی منطقه‌ای/کهنه؛ معنا و کاربرد نامطمئن — قاعده‌ی ۱۴ | — |
| ۶۹۲ | unschierig | `Adjektive.txt` | 2026-10-10 | املا/معنا ناشناخته (شاید غلط تایپی فهرست)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۶۹۳ | unsexy | `Adjektive.txt` | 2026-10-10 | محاوره‌ای و مربوط به جذابیت جنسی ⇒ تصمیم با Lukas (مثل promisk)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۶۹۴ | unterer | `Adjektive.txt` | 2026-10-10 | شکل صرف‌شده (مثل oberer/innerer)؛ قاعده‌ی ۱۴ | — |
| ۶۹۵ | unzial | `Adjektive.txt` | 2026-10-10 | اصطلاح تخصصی خط‌شناسی (Unziale)، نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۶۹۶ | uptodate | `Adjektive.txt` | 2026-10-10 | املا مشکوک: Duden «up to date» (سه کلمه، انگلیسی) — Lukas تصمیم بگیرد | — |
| ۶۹۷ | uranhaltig | `Adjektive.txt` | 2026-10-10 | ترکیب تخصصی با -haltig (مثل siliziumhaltig)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۶۹۸ | urcool | `Adjektive.txt` | 2026-10-10 | محاوره‌ای جوانانه؛ ثبت نامطمئن — قاعده‌ی ۱۴ | — |
| ۶۹۹ | uroborisch | `Adjektive.txt` | 2026-10-10 | اصطلاح نمادشناسی، بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۰۰ | vagil | `Adjektive.txt` | 2026-10-10 | اصطلاح تخصصی زیست‌شناسی، نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۰۱ | vaginal | `Adjektive.txt` | 2026-10-10 | اصطلاح پزشکی با بار جنسی (مثل penil) ⇒ تصمیم با Lukas | — |
| ۷۰۲ | valabel | `Adjektive.txt` | 2026-10-10 | کهنه/نادر (معتبر)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۰۳ | vanille | `Adjektive.txt` | 2026-10-10 | صفت رنگ صرف‌نشدنی، ثبت و کاربرد نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۰۴ | vaskularisiert | `Adjektive.txt` | 2026-10-10 | اصطلاح تخصصی پزشکی، نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۰۵ | veilchenfarben | `Adjektive.txt` | 2026-10-10 | صفت رنگ با -farben (مثل lohfarben)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۰۶ | venenös | `Adjektive.txt` | 2026-10-10 | املا/وجود نامطمئن (شاید venös)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۰۷ | venerisch | `Adjektive.txt` | 2026-10-10 | اصطلاح کهنه‌ی پزشکی (بیماری مقاربتی) ⇒ تصمیم با Lukas | — |
| ۷۰۸ | venetisch | `Adjektive.txt` | 2026-10-10 | مربوط به قوم/زبان باستانی Veneter، نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۰۹ | vereinslos | `Adjektive.txt` | 2026-10-10 | نادر؛ ثبت نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۱۰ | verfristet | `Adjektive.txt` | 2026-10-10 | اصطلاح حقوقی نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۱۱ | vergnügungssüchtig | `Adjektive.txt` | 2026-10-10 | ترکیب با -süchtig (مثل naschsüchtig)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۱۲ | verhaltensgestört | `Adjektive.txt` | 2026-10-10 | برچسب روان‌شناختی حساس و کهنه ⇒ تصمیم با Lukas | — |
| ۷۱۳ | verhascht | `Adjektive.txt` | 2026-10-10 | محاوره‌ای (مواد مخدر)، نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۱۴ | veritabel | `Adjektive.txt` | 2026-10-10 | واژه‌ی ادبی، تقریباً فقط وصفی (veritabler) — مثال با شکل پایه طبیعی نیست؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۱۵ | verkrebst | `Adjektive.txt` | 2026-10-10 | محاوره‌ای/پزشکی، نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۱۶ | verlustbehaftet | `Adjektive.txt` | 2026-10-10 | اصطلاح فنی، نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۱۷ | vernakulär | `Adjektive.txt` | 2026-10-10 | اصطلاح زبان‌شناسی، نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۱۸ | veronesisch | `Adjektive.txt` | 2026-10-10 | صفت مکانی نادر (Verona)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۱۹ | verpflichtungslos | `Adjektive.txt` | 2026-10-10 | نادر؛ ثبت نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۲۰ | verrechenbar | `Adjektive.txt` | 2026-10-10 | اصطلاح اداری نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۲۱ | verrunzelt | `Adjektive.txt` | 2026-10-10 | نادر (رایج‌تر: runzlig)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۲۲ | versaut | `Adjektive.txt` | 2026-10-10 | محاوره‌ای با بار جنسی ⇒ تصمیم با Lukas | — |
| ۷۲۳ | verschwendungssüchtig | `Adjektive.txt` | 2026-10-10 | ترکیب با -süchtig (مثل naschsüchtig)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۲۴ | vertiert | `Adjektive.txt` | 2026-10-10 | ادبی/نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۲۵ | vertränt | `Adjektive.txt` | 2026-10-10 | نادر (رایج‌تر: verweint)؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۲۶ | verzopft | `Adjektive.txt` | 2026-10-10 | محاوره‌ای، نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۲۷ | vestibulär | `Adjektive.txt` | 2026-10-10 | اصطلاح تخصصی پزشکی، نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۲۸ | vestimentär | `Adjektive.txt` | 2026-10-10 | بسیار نادر؛ مطمئن نیستم — قاعده‌ی ۱۴ | — |
| ۷۲۹ | vielerlei | `Adjektive.txt` | 2026-10-10 | Wortart نامطمئن (Duden: عدد نامعین/ضمیر، صرف‌نشدنی) — مثل mancherlei، تصمیم با Lukas | — |
| ۷۳۰ | vigil | `Adjektive.txt` | 2026-10-10 | اصطلاح پزشکی نادر؛ معنا/کاربرد صفتی نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۳۱ | vincentisch | `Adjektive.txt` | 2026-10-10 | اسم خاص/صفت مکانی نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۳۲ | vinophil | `Adjektive.txt` | 2026-10-10 | بسیار نادر؛ ثبت نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۳۳ | vogtländisch | `Adjektive.txt` | 2026-10-10 | صفت منطقه‌ای (مثل ostfälisch) — قاعده‌ی ۱۴ | — |
| ۷۳۴ | volitional | `Adjektive.txt` | 2026-10-10 | اصطلاح تخصصی روان‌شناسی، نادر — قاعده‌ی ۱۴ | — |
| ۷۳۵ | vorderer | `Adjektive.txt` | 2026-10-10 | شکل صرف‌شده (مثل oberer/unterer) — قاعده‌ی ۱۴ | — |
| ۷۳۶ | vorgabenwirksam | `Adjektive.txt` | 2026-10-10 | اصطلاح اداری بسیار نادر — قاعده‌ی ۱۴ | — |
| ۷۳۷ | vorletzte | `Adjektive.txt` | 2026-10-10 | شکل صرف‌شده (مثل letzter؛ Duden: vorletzt) — قاعده‌ی ۱۴ | — |
| ۷۳۸ | vulkanistisch | `Adjektive.txt` | 2026-10-10 | اصطلاح تخصصی زمین‌شناسی؛ معنا نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۳۹ | wegsam | `Adjektive.txt` | 2026-10-10 | کهنه و نادر؛ کاربرد نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۴۰ | wehrig | `Adjektive.txt` | 2026-10-10 | معنا نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۴۱ | weidlich | `Adjektive.txt` | 2026-10-10 | Wortart نامطمئن (قید/صفت) — قاعده‌ی ۱۴ | — |
| ۷۴۲ | weinfarben | `Adjektive.txt` | 2026-10-10 | مثل beinfarben/lohfarben (-farben) — قاعده‌ی ۱۴ | — |
| ۷۴۳ | weinfröhlich | `Adjektive.txt` | 2026-10-10 | بسیار نادر — قاعده‌ی ۱۴ | — |
| ۷۴۴ | weinfroh | `Adjektive.txt` | 2026-10-10 | بسیار نادر — قاعده‌ی ۱۴ | — |
| ۷۴۵ | weingelb | `Adjektive.txt` | 2026-10-10 | نادر؛ رنگ دقیق نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۴۶ | weinhaltig | `Adjektive.txt` | 2026-10-10 | مثل uranhaltig (-haltig) — قاعده‌ی ۱۴ | — |
| ۷۴۷ | weinig | `Adjektive.txt` | 2026-10-10 | نادر؛ معنا نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۴۸ | weinsauer | `Adjektive.txt` | 2026-10-10 | نادر؛ معنا نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۴۹ | weißfeldrig | `Adjektive.txt` | 2026-10-10 | معنا نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۵۰ | weißgolden | `Adjektive.txt` | 2026-10-10 | نادر؛ معنا نامطمئن (رنگ یا جنس) — قاعده‌ی ۱۴ | — |
| ۷۵۱ | weitentlegen | `Adjektive.txt` | 2026-10-10 | املا مشکوک (weit entlegen) — قاعده‌ی ۱۴ | — |
| ۷۵۲ | wergen | `Adjektive.txt` | 2026-10-10 | صفت جنسی «از کنف» مثل flächsen — قاعده‌ی ۱۴ | — |
| ۷۵۳ | westmitteldeutsch | `Adjektive.txt` | 2026-10-10 | اصطلاح تخصصی گویش‌شناسی — قاعده‌ی ۱۴ | — |
| ۷۵۴ | westoberdeutsch | `Adjektive.txt` | 2026-10-10 | اصطلاح تخصصی گویش‌شناسی — قاعده‌ی ۱۴ | — |
| ۷۵۵ | wipfelschäftig | `Adjektive.txt` | 2026-10-10 | معنا نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۵۶ | wirsch | `Adjektive.txt` | 2026-10-11 | منطقه‌ای؛ معنا دوگانه و نامطمئن (عصبانی/گیج) — قاعده‌ی ۱۴ | — |
| ۷۵۷ | wollen | `Adjektive.txt` | 2026-10-11 | صفت جنسی «پشمی» مثل leinen؛ با فعل wollen هم‌نویسه — قاعده‌ی ۱۴ | — |
| ۷۵۸ | wollüstig | `Adjektive.txt` | 2026-10-11 | بار جنسی ⇒ تصمیم Lukas | — |
| ۷۵۹ | wurzelverwandt | `Adjektive.txt` | 2026-10-11 | نادر؛ اصطلاح تخصصی زبان‌شناسی (هم‌ریشه) — قاعده‌ی ۱۴ | — |
| ۷۶۰ | wuschig | `Adjektive.txt` | 2026-10-11 | عامیانه؛ معنا دوگانه (عصبی / تحریک جنسی) ⇒ تصمیم Lukas | — |
| ۷۶۱ | xenophontisch | `Adjektive.txt` | 2026-10-11 | صفت از اسم خاص (Xenophon) — قاعده‌ی ۱۴ | — |
| ۷۶۲ | xerographisch | `Adjektive.txt` | 2026-10-11 | اصطلاح تخصصی نادر — قاعده‌ی ۱۴ | — |
| ۷۶۳ | xerophil | `Adjektive.txt` | 2026-10-11 | اصطلاح تخصصی زیست‌شناسی مثل psychrophil — قاعده‌ی ۱۴ | — |
| ۷۶۴ | yttriumhaltig | `Adjektive.txt` | 2026-10-11 | اصطلاح تخصصی مثل uranhaltig — قاعده‌ی ۱۴ | — |
| ۷۶۵ | zahlungswirksam | `Adjektive.txt` | 2026-10-11 | اصطلاح تخصصی حسابداری؛ ثبت نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۶۶ | zapfentragend | `Adjektive.txt` | 2026-10-11 | اصطلاح گیاه‌شناسی مثل gehäusetragend — قاعده‌ی ۱۴ | — |
| ۷۶۷ | zedern | `Adjektive.txt` | 2026-10-11 | صفت جنسی «از چوب سدر» مثل fichten — قاعده‌ی ۱۴ | — |
| ۷۶۸ | zehntpflichtig | `Adjektive.txt` | 2026-10-11 | اصطلاح تاریخی نادر — قاعده‌ی ۱۴ | — |
| ۷۶۹ | zeitgeistlich | `Adjektive.txt` | 2026-10-11 | معنا نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۷۰ | zeitinvariant | `Adjektive.txt` | 2026-10-11 | اصطلاح تخصصی نظریه‌ی سیستم‌ها — قاعده‌ی ۱۴ | — |
| ۷۷۱ | zementen | `Adjektive.txt` | 2026-10-11 | صفت جنسی «سیمانی» با کاربرد نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۷۲ | zertalt | `Adjektive.txt` | 2026-10-11 | اصطلاح نادر جغرافیا — قاعده‌ی ۱۴ | — |
| ۷۷۳ | zervikogen | `Adjektive.txt` | 2026-10-11 | اصطلاح تخصصی پزشکی مثل retrobulbär — قاعده‌ی ۱۴ | — |
| ۷۷۴ | zinken | `Adjektive.txt` | 2026-10-11 | صفت جنسی «از روی» — قاعده‌ی ۱۴ | — |
| ۷۷۵ | zinnen | `Adjektive.txt` | 2026-10-11 | صفت جنسی «از قلع» — قاعده‌ی ۱۴ | — |
| ۷۷۶ | zinnern | `Adjektive.txt` | 2026-10-11 | صفت جنسی «از قلع» مثل messingen — قاعده‌ی ۱۴ | — |
| ۷۷۷ | zirkumpolar | `Adjektive.txt` | 2026-10-11 | اصطلاح تخصصی نجوم/جغرافیا — قاعده‌ی ۱۴ | — |
| ۷۷۸ | zisalpin | `Adjektive.txt` | 2026-10-11 | نادر؛ اصطلاح تاریخی — قاعده‌ی ۱۴ | — |
| ۷۷۹ | zombig | `Adjektive.txt` | 2026-10-11 | عامیانه؛ معنا نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۸۰ | zotig | `Adjektive.txt` | 2026-10-11 | بار جنسی/رکیک ⇒ تصمیم Lukas | — |
| ۷۸۱ | zusammengeritten | `Adjektive.txt` | 2026-10-11 | معنا نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۸۲ | zweibasig | `Adjektive.txt` | 2026-10-11 | اصطلاح تخصصی شیمی — قاعده‌ی ۱۴ | — |
| ۷۸۳ | zweibasisch | `Adjektive.txt` | 2026-10-11 | اصطلاح تخصصی شیمی — قاعده‌ی ۱۴ | — |
| ۷۸۴ | zweihebig | `Adjektive.txt` | 2026-10-11 | اصطلاح تخصصی عروض (وزن شعر) — قاعده‌ی ۱۴ | — |
| ۷۸۵ | zweitmeist | `Adjektive.txt` | 2026-10-11 | نادر؛ ثبت نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۸۶ | zwirnen | `Adjektive.txt` | 2026-10-11 | صفت جنسی «از نخ تابیده» — قاعده‌ی ۱۴ | — |
| ۷۸۷ | zygomorph | `Adjektive.txt` | 2026-10-11 | اصطلاح تخصصی گیاه‌شناسی — قاعده‌ی ۱۴ | — |
| ۷۸۸ | zypressen | `Adjektive.txt` | 2026-10-11 | صفت جنسی «از چوب سرو» مثل zedern — قاعده‌ی ۱۴ | — |
| ۷۸۹ | zytogen | `Adjektive.txt` | 2026-10-11 | اصطلاح تخصصی؛ معنا نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۹۰ | zytotrop | `Adjektive.txt` | 2026-10-11 | اصطلاح تخصصی نادر — قاعده‌ی ۱۴ | — |
| ۷۹۱ | abbedingen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | اصطلاح حقوقی بسیار نادر (توافقی کنار گذاشتن) — قاعده‌ی ۱۴ | — |
| ۷۹۲ | abbehalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر (برنداشتن کلاه و…) — قاعده‌ی ۱۴ | — |
| ۷۹۳ | abbleichen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر؛ معنا نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۹۴ | abdingen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ — قاعده‌ی ۱۴ | — |
| ۷۹۵ | abdreschen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر (تقریباً فقط صفت abgedroschen رایج است) — قاعده‌ی ۱۴ | — |
| ۷۹۶ | abkneifen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴ | — |
| ۷۹۷ | abkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه‌ی منطقه‌ای؛ معنا نامطمئن — قاعده‌ی ۱۴ | — |
| ۷۹۸ | abliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر؛ تقریباً فقط صفت abgelegen رایج است — قاعده‌ی ۱۴ | — |
| ۷۹۹ | abmelken | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | اصطلاح کشاورزی نادر — قاعده‌ی ۱۴ | — |
| ۸۰۰ | achthaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | کهنه (هم‌معنی achtgeben) — قاعده‌ی ۱۴ | — |
| ۸۰۱ | andringen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ — قاعده‌ی ۱۴ | — |
| ۸۰۲ | anessen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴ | — |
| ۸۰۳ | anfinden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منطقه‌ای و نادر — قاعده‌ی ۱۴ | — |
| ۸۰۴ | angedeihen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | فقط در عبارت «angedeihen lassen» — صرف مستقل ندارد — قاعده‌ی ۱۴ | — |
| ۸۰۵ | anheimgeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و بسیار نادر — قاعده‌ی ۱۴ | — |
| ۸۰۶ | ankeifen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر و عامیانه — قاعده‌ی ۱۴ | — |
| ۸۰۷ | ankleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ثبت در Duden پیدا نشد — قاعده‌ی ۱۴ | — |
| ۸۰۸ | ankönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ صرف نامطمئن — قاعده‌ی ۱۴ | — |
| ۸۰۹ | ankriechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر (تقریباً فقط angekrochen kommen) — قاعده‌ی ۱۴ | — |
| ۸۱۰ | aufbersten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر و ادبی — قاعده‌ی ۱۴ | — |
| ۸۱۱ | aufbrennen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر؛ معنا نامطمئن — قاعده‌ی ۱۴ | — |
| ۸۱۲ | aufdringen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ (امروز فقط aufdrängen و صفت aufdringlich) — قاعده‌ی ۱۴ | — |
| ۸۱۳ | aufgleiten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر؛ معنا/کاربرد مطمئن ثبت نشده — قاعده‌ی ۱۴ | — |
| ۸۱۴ | aufglimmen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | صرف دوگانه (glomm/glimmte) ⇒ «regelmaessig» مطمئن نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۸۱۵ | aufhauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ Präteritum (haute/hieb) و فعل کمکی (haben/sein) بسته به معنا متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۱۶ | aufkleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ/محلی (امروز aufkleben)؛ صرف نامطمئن — قاعده‌ی ۱۴ | — |
| ۸۱۷ | aufklieben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | محلی؛ معنا و صرف مطمئن ثبت نشده — قاعده‌ی ۱۴ | — |
| ۸۱۸ | aufklingen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر و ادبی — قاعده‌ی ۱۴ | — |
| ۸۱۹ | aufliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | فعل کمکی متغیر (haben؛ جنوب آلمان/اتریش/سوئیس sein) مثل abliegen — قاعده‌ی ۱۶ | — |
| ۸۲۰ | aufrechtbleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املا: طبق رسم‌الخط امروز معمولاً جدا «aufrecht bleiben» — قاعده‌ی ۱۴ | — |
| ۸۲۱ | ausbedingen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | Präteritum متغیر (bedang/bedingte aus) — قاعده‌ی ۱۴/۱۶ | — |
| ۸۲۲ | ausbiegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | معنای اصلی محلی (کنار کشیدن، sein) در برابر صاف کردن (haben)؛ کاربرد نامطمئن — قاعده‌ی ۱۴ | — |
| ۸۲۳ | ausbieten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر (برای فروش عرضه کردن) — قاعده‌ی ۱۴ | — |
| ۸۲۴ | ausbinden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر/تخصصی؛ معنا متغیر — قاعده‌ی ۱۴ | — |
| ۸۲۵ | ausbleichen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | صرف متغیر (blich/bleichte؛ ausgeblichen/ausgebleicht) و فعل کمکی بسته به معنا — مثل abbleichen — قاعده‌ی ۱۴/۱۶ | — |
| ۸۲۶ | ausdreschen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر و تخصصی — مثل abdreschen — قاعده‌ی ۱۴ | — |
| ۸۲۷ | auseinanderbersten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر و ادبی — قاعده‌ی ۱۴ | — |
| ۸۲۸ | auserkiesen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ/ادبی؛ امروز تقریباً فقط Partizip «auserkoren» — قاعده‌ی ۱۴ | — |
| ۸۲۹ | ausfinden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر/محلی («sich ausfinden»)؛ کاربرد نامطمئن — قاعده‌ی ۱۴ | — |
| ۸۳۰ | ausfrieren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | معنا و فعل کمکی متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۳۱ | ausgären | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | صرف متغیر (gor/gärte aus) — قاعده‌ی ۱۴/۱۶ | — |
| ۸۳۲ | ausgebären | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر و ادبی — قاعده‌ی ۱۴ | — |
| ۸۳۳ | ausgreifen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر و ادبی (بیشتر فقط «weit ausgreifend») — قاعده‌ی ۱۴ | — |
| ۸۳۴ | aushaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ معناها متغیر — قاعده‌ی ۱۴ | — |
| ۸۳۵ | aushängen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | گذرا باقاعده (hängte aus) و ناگذر بی‌قاعده (hing aus) ⇒ «regelmaessig» یکتا نیست — قاعده‌ی ۱۶ | — |
| ۸۳۶ | aushauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | Präteritum متغیر (haute/hieb aus)، نادر — مثل aufhauen — قاعده‌ی ۱۴/۱۶ | — |
| ۸۳۷ | auskiesen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ (مثل auserkiesen) — قاعده‌ی ۱۴/۱۶ | — |
| ۸۳۸ | auskneifen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ کاربرد نامطمئن — قاعده‌ی ۱۴/۱۶ | — |
| ۸۳۹ | ausliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | فعل کمکی متغیر (haben / در جنوب sein) مثل aufliegen — قاعده‌ی ۱۴/۱۶ | — |
| ۸۴۰ | ausmahlen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر/تخصصی؛ صرف آمیخته — قاعده‌ی ۱۴/۱۶ | — |
| ۸۴۱ | ausmelken | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — مثل abmelken — قاعده‌ی ۱۴/۱۶ | — |
| ۸۴۲ | auswärtsgehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۴۳ | bedünken | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ — قاعده‌ی ۱۴/۱۶ | — |
| ۸۴۴ | bedürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | امر رایج ندارد؛ فیلد اجباری imperativ را نمی‌شود مطمئن پر کرد — قاعده‌ی ۱۴/۱۶ | — |
| ۸۴۵ | beibiegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ کاربرد نامطمئن — قاعده‌ی ۱۴/۱۶ | — |
| ۸۴۶ | beibleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۴۷ | beieinanderhaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه، تقریباً فقط در اصطلاح — قاعده‌ی ۱۴/۱۶ | — |
| ۸۴۸ | beieinanderhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۴۹ | beifallen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ — قاعده‌ی ۱۴/۱۶ | — |
| ۸۵۰ | beigehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ/محلی — قاعده‌ی ۱۴/۱۶ | — |
| ۸۵۱ | beihalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر؛ معنا نامطمئن — قاعده‌ی ۱۴/۱۶ | — |
| ۸۵۲ | beiladen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | تخصصی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۵۳ | beiliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | فعل کمکی متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۵۴ | beisammenhaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه، تقریباً فقط در اصطلاح — قاعده‌ی ۱۴/۱۶ | — |
| ۸۵۵ | beisammenhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۵۶ | bekleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ — قاعده‌ی ۱۴/۱۶ | — |
| ۸۵۷ | belesen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | به‌عنوان فعل منسوخ (امروز فقط صفت) — قاعده‌ی ۱۴/۱۶ | — |
| ۸۵۸ | bereitliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | فعل کمکی متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۵۹ | blickenlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املا: امروز جدا نوشته می‌شود — قاعده‌ی ۱۴/۱۶ | — |
| ۸۶۰ | blindfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر؛ فعل کمکی متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۶۱ | bloßliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | فعل کمکی متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۶۲ | brachliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | فعل کمکی متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۶۳ | dafürhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی؛ تقریباً فقط به شکل اسم — قاعده‌ی ۱۴/۱۶ | — |
| ۸۶۴ | dafürkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۸۶۵ | daherbringen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | محلی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۶۶ | daherfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۶۷ | dahinfahren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی/منسوخ — قاعده‌ی ۱۴/۱۶ | — |
| ۸۶۸ | dahinfallen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | سوئیسی/نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۶۹ | dahinfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۷۰ | dahinfließen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۷۱ | dahingeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۷۲ | dahingehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی؛ معناها متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۷۳ | dahingleiten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۷۴ | daliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | فعل کمکی متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۷۵ | danebenfallen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۷۶ | danebengelingen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | کاربرد ثبت‌شده پیدا نشد — قاعده‌ی ۱۴/۱۶ | — |
| ۸۷۷ | danebenhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۷۸ | danebenhauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ Präteritum متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۷۹ | danebenliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ فعل کمکی متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۸۰ | daniederliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی؛ فعل کمکی متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۸۱ | darangeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۸۲ | darangehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۸۳ | darbringen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۸۴ | dareinfinden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۸۵ | darleihen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ — قاعده‌ی ۱۴/۱۶ | — |
| ۸۸۶ | darniederliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی؛ فعل کمکی متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۸۷ | darüberfahren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر؛ معمولاً جدا نوشته می‌شود — قاعده‌ی ۱۴/۱۶ | — |
| ۸۸۸ | darüberliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املا و فعل کمکی متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۸۹ | darumbinden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر؛ معمولاً جدا — قاعده‌ی ۱۴/۱۶ | — |
| ۸۹۰ | darumkommen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر؛ معمولاً جدا — قاعده‌ی ۱۴/۱۶ | — |
| ۸۹۱ | darunterbleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر؛ معمولاً جدا — قاعده‌ی ۱۴/۱۶ | — |
| ۸۹۲ | darunterfallen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر؛ معمولاً جدا — قاعده‌ی ۱۴/۱۶ | — |
| ۸۹۳ | daruntergehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۹۴ | darunterheben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر؛ معنا نامطمئن — قاعده‌ی ۱۴/۱۶ | — |
| ۸۹۵ | darunterliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املا و فعل کمکی متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۹۶ | davonbleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۹۷ | davorhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر؛ معمولاً جدا — قاعده‌ی ۱۴/۱۶ | — |
| ۸۹۸ | davorliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | فعل کمکی متغیر؛ نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۸۹۹ | dazuhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | محلی — قاعده‌ی ۱۴/۱۶ | — |
| ۹۰۰ | dazukönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۹۰۱ | dazwischenfragen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۰۲ | dazwischenhauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ Präteritum متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۰۳ | dazwischenliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | فعل کمکی متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۰۴ | dortbehalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۰۵ | drangeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۰۶ | dranhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ کاربرد متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۰۷ | dranhängen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ صرف بسته به معنا متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۰۸ | draufgeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۰۹ | draufhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۱۰ | draufhauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ Präteritum متغیر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۱۱ | drauflosfahren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۱۲ | drauflosgehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۱۳ | drausbringen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | محلی — قاعده‌ی ۱۴/۱۶ | — |
| ۹۱۴ | drauskommen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | محلی — قاعده‌ی ۱۴/۱۶ | — |
| ۹۱۵ | dreinfahren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۱۶ | dreinfinden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۱۷ | dreingeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | محلی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۱۸ | durchblasen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۱۹ | durchbrechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | هم جداشدنی هم جدانشدنی با معنای متفاوت؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۹۲۰ | durchdenken | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۹۲۱ | durchdreschen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۲۲ | durchdringen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۹۲۳ | durchdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۹۲۴ | durcheinanderessen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۲۵ | durcheinanderlaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۲۶ | durchessen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۲۷ | durchfahren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۹۲۸ | durchflechten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۹۲۹ | durchfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۹۳۰ | durchfließen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۹۳۱ | durchfressen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۹۳۲ | durchfrieren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۹۳۳ | durchgären | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر (اصطلاح تخصصی) — قاعده‌ی ۱۴/۱۶ | — |
| ۹۳۴ | durchgraben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۹۳۵ | durchhauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | هم جداشدنی هم جدانشدنی؛ گذشته بین haute/hieb نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۹۳۶ | durchklingen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۹۳۷ | durchkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ ترکیب فعل وجهی، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۹۳۸ | durchkriechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۹۳۹ | durchlaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۹۴۰ | durchmahlen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۴۱ | durchmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ ترکیب فعل وجهی، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۹۴۲ | ehebrechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | تقریباً فقط مصدر به کار می‌رود؛ صرف ثابت ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۹۴۳ | einbacken | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر؛ گذشته بین buk/backte نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۹۴۴ | einbegreifen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | تقریباً فقط به شکل Partizip «einbegriffen» — قاعده‌ی ۱۴/۱۶ | — |
| ۹۴۵ | einbeißen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۴۶ | einblasen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر؛ معنای عامیانه نامطمئن — قاعده‌ی ۱۴/۱۶ | — |
| ۹۴۷ | eindreschen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۴۸ | einfressen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۴۹ | eingebären | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۵۰ | einhängen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | گذرا باقاعده، ناگذر بی‌قاعده — شکل‌ها نوسان دارند — قاعده‌ی ۱۴/۱۶ | — |
| ۹۵۱ | einhauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ گذشته بین haute/hieb نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۹۵۲ | einhelfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۵۳ | einherfahren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۵۴ | einiggehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املای رسمی نامطمئن (einig gehen) — قاعده‌ی ۱۴/۱۶ | — |
| ۹۵۵ | einkneifen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۵۶ | einkommen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | اداری و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۵۷ | einwärtsgehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر؛ شکل ثابت ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۹۵۸ | eislaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املای شکل‌های جدا نامطمئن (läuft Eis) — قاعده‌ی ۱۴/۱۶ | — |
| ۹۵۹ | emporfahren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۶۰ | emporfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۶۱ | emporheben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۶۲ | entbieten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و منسوخ — قاعده‌ی ۱۴/۱۶ | — |
| ۹۶۳ | entgegenfließen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۶۴ | entzweibeißen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۶۵ | entzweibrechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | فعل کمکی نوسان دارد (haben/sein) — قاعده‌ی ۱۴/۱۶ | — |
| ۹۶۶ | erbieten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | sich erbieten — ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۶۷ | erbleichen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | صرف نوسان دارد (erbleichte/erblich) — قاعده‌ی ۱۴/۱۶ | — |
| ۹۶۸ | erfechten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۶۹ | erheischen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و منسوخ — قاعده‌ی ۱۴/۱۶ | — |
| ۹۷۰ | erkiesen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۷۱ | erküren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۷۲ | erlaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۷۳ | erlesen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | فعل ادبی؛ بیشتر به‌عنوان صفت «erlesen» — قاعده‌ی ۱۴/۱۶ | — |
| ۹۷۴ | erlügen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۷۵ | erschrecken | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ناگذر بی‌قاعده (erschrak) و گذرا باقاعده (erschreckte) — یک کارت با یک نماد درست نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۹۷۶ | fahen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۷۷ | fahrenlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املای رسمی «fahren lassen» (جدا)؛ مدخل فهرست نامطمئن — قاعده‌ی ۱۴/۱۶ | — |
| ۹۷۸ | fallenlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املا بین «fallen lassen» و «fallenlassen» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۹۷۹ | feilbieten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ‌شونده و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۸۰ | feilhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ‌شونده و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۸۱ | feinmahlen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املای رسمی «fein mahlen» (جدا) — قاعده‌ی ۱۴/۱۶ | — |
| ۹۸۲ | fertiglesen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املای رسمی «fertig lesen» (جدا) — قاعده‌ی ۱۴/۱۶ | — |
| ۹۸۳ | festbleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۸۴ | fortbegeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | sich fortbegeben — ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۸۵ | fortblasen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۸۶ | fortdenken | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | sich etwas fortdenken — نادر (رایج: wegdenken) — قاعده‌ی ۱۴/۱۶ | — |
| ۹۸۷ | fortdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۹۸۸ | fortgießen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر (رایج: weggießen) — قاعده‌ی ۱۴/۱۶ | — |
| ۹۸۹ | forthaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۹۰ | fortkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۹۹۱ | fortkriechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۹۲ | fortmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۹۹۳ | freibleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | در معنای اصلی رسماً جدا نوشته می‌شود («frei bleiben») — قاعده‌ی ۱۴/۱۶ | — |
| ۹۹۴ | freilaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | sich freilaufen (ورزشی) — نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۹۵ | gegeneinanderhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۹۶ | gegenfragen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۹۹۷ | geheißen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | مصدر نیست؛ Partizip II فعل heißen است — قاعده‌ی ۱۴/۱۶ | — |
| ۹۹۸ | gutgehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املا بین «gut gehen» و «gutgehen» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۹۹۹ | heimbegeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | sich heimbegeben — ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۰۰ | heimdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۰۱ | heimfallen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | اصطلاح حقوقی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۰۲ | heimkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۰۳ | heimmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۰۴ | heischen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و منسوخ؛ صرف نامطمئن — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۰۵ | herabfahren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۰۶ | herabkommen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۰۷ | heranbinden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۰۸ | herandürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۰۹ | herankönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۱۰ | heranmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۱۱ | heraufdringen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۱۲ | heraufdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۱۳ | heraufkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۱۴ | heraufmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۱۵ | herausbrechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | گذرا با haben، ناگذر با sein — فعل کمکی یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۱۶ | herausdringen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۱۷ | herausdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۱۸ | heraushängen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | گذرا باقاعده، ناگذر بی‌قاعده — شکل‌ها نوسان دارند — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۱۹ | heraushauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ گذشته بین haute/hieb نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۲۰ | herausklingen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۲۱ | herauskönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۲۲ | herausmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۲۳ | herbeifahren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۲۴ | herbeifliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۲۵ | herbeilassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | sich herbeilassen — ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۲۶ | herdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۲۷ | hereindringen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۲۸ | hereindürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۲۹ | hereingeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۳۰ | hereinkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۳۱ | hereinkriechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۳۲ | hereinmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۳۳ | herkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۳۴ | hermüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۳۵ | herniederfallen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۳۶ | herniedergehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۳۷ | herüberdringen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۳۸ | herüberdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۳۹ | herüberfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۴۰ | herüberhängen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | گذرا باقاعده، ناگذر بی‌قاعده — شکل‌ها نوسان دارند — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۴۱ | herüberkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۴۲ | herübermüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۴۳ | herumbiegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۴۴ | herumbinden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۴۵ | herumgreifen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۴۶ | herumhaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۴۷ | herumhängen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | گذرا باقاعده، ناگذر بی‌قاعده — شکل‌ها نوسان دارند — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۴۸ | herumkriechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۴۹ | herunterbiegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۵۰ | herunterbrechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | گذرا با haben، ناگذر با sein — فعل کمکی یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۵۱ | herunterbrennen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | گذرا با haben، ناگذر با sein — فعل کمکی یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۵۲ | herunterdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۵۳ | herunterfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۵۴ | heruntergießen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۵۵ | heruntergleiten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۵۶ | herunterhängen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | گذرا باقاعده، ناگذر بی‌قاعده — شکل‌ها نوسان دارند — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۵۷ | herunterhauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ گذشته بین haute/hieb نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۵۸ | herunterkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۵۹ | herunterkriechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۶۰ | heruntermüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۶۱ | hervordringen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۶۲ | herzukommen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۶۳ | hinabfahren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۶۴ | hinaufdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۶۵ | hinauffallen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | تقریباً فقط در اصطلاح «die Treppe hinauffallen» — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۶۶ | hinaufkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۶۷ | hinaufkriechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۶۸ | hinauflassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۶۹ | hinaufmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۷۰ | hinausbegeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | sich hinausbegeben — ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۷۱ | hinausblasen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۷۲ | hinausdenken | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | تقریباً فقط «über etwas hinausdenken»؛ نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۷۳ | hinausdringen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۷۴ | hinausdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۷۵ | hinausgreifen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۷۶ | hinaushalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۷۷ | hinaushängen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | گذرا باقاعده، ناگذر بی‌قاعده — شکل‌ها نوسان دارند — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۷۸ | hinausheben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | تقریباً فقط «über etwas hinausheben»؛ نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۷۹ | hinauskönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۸۰ | hinausmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۸۱ | hinbegeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | sich hinbegeben — ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۸۲ | hinbieten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۸۳ | hindurchdringen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۸۴ | hindurchdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۸۵ | hindurchfließen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۸۶ | hindurchkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۸۷ | hindurchkriechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۸۸ | hindurchmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۸۹ | hindürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۹۰ | hineinbegeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | sich hineinbegeben — ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۹۱ | hineinblasen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۹۲ | hineinbrennen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۹۳ | hineindringen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۹۴ | hineindürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۹۵ | hineinfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۹۶ | hineinfressen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر (in sich hineinfressen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۹۷ | hineingleiten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۹۸ | hineingreifen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۰۹۹ | hineinhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۰۰ | hineinhängen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | گذرا باقاعده، ناگذر بی‌قاعده — شکل‌ها نوسان دارند — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۰۱ | hineinkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۰۲ | hineinkriechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۰۳ | hineinmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۰۴ | hinfließen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۰۵ | hingießen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۰۶ | hingleiten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۰۷ | hinhaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۰۸ | hinhängen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | گذرا باقاعده، ناگذر بی‌قاعده — شکل‌ها نوسان دارند — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۰۹ | hinhauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ گذشته بین haute/hieb نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۱۰ | hinkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۱۱ | hinmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۱۲ | hintanbleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۱۳ | hintanhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | منسوخ و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۱۴ | hintenüberfallen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۱۵ | hinterbringen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۱۶ | hintereinanderfahren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املای رسمی جدا («hintereinander …») — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۱۷ | hintereinandergehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املای رسمی جدا («hintereinander …») — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۱۸ | hintereinanderlaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املای رسمی جدا («hintereinander …») — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۱۹ | hinteressen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | واژه‌ی شناخته‌شده‌ای نیست (احتمالاً خطای فهرست) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۲۰ | hintergießen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۲۱ | hinterlaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۲۲ | hinüberbegeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | sich hinüberbegeben — ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۲۳ | hinüberdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۲۴ | hinüberfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۲۵ | hinübergleiten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۲۶ | hinübergreifen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۲۷ | hinüberhängen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | گذرا باقاعده، ناگذر بی‌قاعده — شکل‌ها نوسان دارند — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۲۸ | hinüberkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۲۹ | hinüberlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۳۰ | hinunterdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۳۱ | hinunterfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۳۲ | hinuntergießen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۳۳ | hinwegbegeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | sich hinwegbegeben — ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۳۴ | hinwegbringen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۳۵ | hinweglesen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۳۶ | hinzubekommen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۳۷ | hinzudenken | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۳۸ | hinzuerfinden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۳۹ | hinzulaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۴۰ | hochbiegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۴۱ | hochbinden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۴۲ | hochfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ معنا نوسان دارد (بالا پریدن/منفجر شدن) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۴۳ | hochkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۴۴ | hochkriechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۴۵ | hochmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۴۶ | hockenbleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املای رسمی جدا («hocken bleiben») — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۴۷ | hofhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و تاریخی؛ املای «Hof halten» هم رایج است — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۴۸ | küren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | گذشته بین kor/kürte نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۴۹ | langliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۵۰ | laufenlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املا بین «laufen lassen» و «laufenlassen» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۵۱ | leeressen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املای رسمی جدا («leer essen») — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۵۲ | liebbehalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املای رسمی جدا («lieb behalten») — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۵۳ | liegenbleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املا بین جدا و سرهم نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۵۴ | liegenlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املا بین جدا و سرهم نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۵۵ | losbrechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | گذرا با haben، ناگذر با sein — فعل کمکی یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۵۶ | losdreschen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۵۷ | losdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۵۸ | loshaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ معنا نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۵۹ | loshalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۶۰ | loskönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۶۱ | losmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۶۲ | mitbieten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۶۳ | mitdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۶۴ | mitempfinden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۶۵ | mitklingen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۶۶ | mitkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۶۷ | mitlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۶۸ | mitmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۶۹ | nachdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۷۰ | nachfallen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۷۱ | nachgären | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۷۲ | nachgreifen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۷۳ | nachhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | به‌عنوان فعل نادر (رایج: صفت «nachhaltig») — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۷۴ | nachkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۷۵ | nachmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۷۶ | näherliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املای رسمی جدا یا نوسان‌دار — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۷۷ | nebeneinanderhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املای رسمی جدا یا نوسان‌دار — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۷۸ | nebeneinanderliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املای رسمی جدا یا نوسان‌دار — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۷۹ | niederbrechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | گذرا با haben، ناگذر با sein — فعل کمکی یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۸۰ | niederbrennen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | گذرا با haben، ناگذر با sein — فعل کمکی یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۸۱ | niederbringen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۸۲ | niederdreschen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۸۳ | niederfahren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۸۴ | niederhauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه؛ گذشته بین haute/hieb نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۸۵ | obliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | هم جداشدنی (liegt ob) هم جدانشدنی (obliegt) — نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۸۶ | offenliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۸۷ | paarlaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | اصطلاح ورزشی نادر؛ صرف جدا نامطمئن — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۸۸ | platzenlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | املا بین «platzen lassen» و «platzenlassen» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۸۹ | quellen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ناگذر بی‌قاعده (quoll)، گذرا باقاعده (quellte) — شکل‌ها نوسان دارند — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۹۰ | querkommen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۹۱ | ranbinden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۹۲ | rankönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۹۳ | ranmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-11 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۹۴ | reinfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۹۵ | reinhauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه؛ گذشته بین haute/hieb نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۹۶ | reinkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۹۷ | reinmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب فعل وجهی (محاوره)، امر ندارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۹۸ | richtigliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه؛ فعل کمکی منطقه‌ای (haben/sein) نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۱۹۹ | rinnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ادبی/نادر؛ Konjunktiv II بین ränne/rönne نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۰۰ | rückfragen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | فقط به‌صورت مصدر/Partizip II رایج است (ناقص) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۰۱ | rückwärtsfahren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «rückwärts fahren» و «rückwärtsfahren» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۰۲ | rückwärtsgehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا/معنا نوسان دارد (rückwärts gehen / rückwärtsgehen = بدتر شدن) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۰۳ | ruhenlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «ruhen lassen» و «ruhenlassen» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۰۴ | rumhaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۰۵ | rumhängen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب hängen (مثل herumhängen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۰۶ | rundfragen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر؛ صرف‌شده کم‌کاربرد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۰۷ | runterfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۰۸ | runterhauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه؛ گذشته بین haute/hieb نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۰۹ | sattbekommen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «satt bekommen» و «sattbekommen» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۱۰ | satthaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «satt haben» و «satthaben» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۱۱ | saugen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | گذشته بین sog/saugte نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۱۲ | sausenlasen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | غلط املایی فهرست (sausenlassen)؛ املا نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۱۳ | schaffen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | دو صرف برای دو معنا (schuf/geschaffen «آفریدن» ↔ schaffte/geschafft «از عهده برآمدن») — ⚠️ کلمه‌ی پرکاربرد A2، تصمیم Lukas لازم — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۱۴ | schallen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | گذشته بین scholl/schallte نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۱۵ | scheren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | دو صرف برای دو معنا (schor ↔ scherte) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۱۶ | schiefliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه؛ فعل کمکی منطقه‌ای (haben/sein) نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۱۷ | schießenlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «schießen lassen» و «schießenlassen» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۱۸ | schinden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | گذشته بین schindete/schund نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۱۹ | schlechtgehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | بی‌شخص (مثل gutgehen)؛ املا نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۲۰ | schleifen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | دو صرف برای دو معنا (schliff «تیز کردن» ↔ schleifte «کشیدن») — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۲۱ | schleifenlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «schleifen lassen» و «schleifenlassen» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۲۲ | schleißen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر؛ گذشته بین schliss/schleißte نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۲۳ | schliefen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | خطای فهرست: گذشته‌ی schlafen است، نه مصدر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۲۴ | schmalzen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر؛ Partizip بین geschmalzt/geschmalzen نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۲۵ | schmorenlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «schmoren lassen» و «schmorenlassen» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۲۶ | schockgefrieren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | فقط به‌صورت مصدر/Partizip II رایج است (ناقص) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۲۷ | schrecken | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | دو صرف برای دو معنا (schrak ↔ schreckte) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۲۸ | schroten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر (اصطلاح فنی) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۲۹ | schwären | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | کهنه؛ گذشته بین schwor/schwärte نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۳۰ | schwarzbrennen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر (اصطلاح خاص) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۳۱ | schweifen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ادبی/نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۳۲ | schwellen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | دو صرف برای دو معنا (schwoll ↔ schwellte) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۳۳ | schwerhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر؛ معنا/املا نامطمئن — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۳۴ | segelfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | فقط به‌صورت مصدر رایج است (ناقص) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۳۵ | seinlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «sein lassen» و «seinlassen» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۳۶ | setzenlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا/معنا نامطمئن (setzen lassen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۳۷ | sieden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | گذشته بین sott/siedete نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۳۸ | sinnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ادبی/نادر؛ Konjunktiv II بین sänne/sönne نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۳۹ | sitzenbleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «sitzen bleiben» و «sitzenbleiben» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۴۰ | sitzenlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «sitzen lassen» و «sitzenlassen» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۴۱ | spalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | Partizip II بین gespalten/gespaltet نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۴۲ | spitzbekommen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۴۳ | spitzhaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۴۴ | spleißen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | اصطلاح فنی؛ گذشته بین spliss/spleißte نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۴۵ | statthaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | کهنه/نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۴۶ | steckenbleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «stecken bleiben» و «steckenbleiben» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۴۷ | steckenlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «stecken lassen» و «steckenlassen» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۴۸ | stehenbleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «stehen bleiben» و «stehenbleiben» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۴۹ | stehenlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «stehen lassen» و «stehenlassen» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۵۰ | steifhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «steif halten» و «steifhalten» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۵۱ | stieben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر؛ گذشته بین stob/stiebte نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۵۲ | stillbleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «still bleiben» و «stillbleiben» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۵۳ | stillhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «still halten» و «stillhalten» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۵۴ | stillliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا و فعل کمکی منطقه‌ای نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۵۵ | tiefgefrieren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | فقط به‌صورت مصدر/Partizip II رایج است (ناقص) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۵۶ | totbeißen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۵۷ | totlaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه و نادر (sich totlaufen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۵۸ | triefen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | گذشته بین troff/triefte نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۵۹ | trockenfallen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر (اصطلاح فنی)؛ املا نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۶۰ | überbacken | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | Präsens/Präteritum نوسان دارد (überbäckt/überbackt، überbuk/überbackte) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۶۱ | überbekommen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۶۲ | überbinden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | منطقه‌ای (سوئیس)، نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۶۳ | überblasen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۶۴ | überbleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه (= übrig bleiben)، نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۶۵ | überbraten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۶۶ | überbrennen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۶۷ | übereinanderliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا نوسان دارد (übereinander liegen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۶۸ | überessen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۶۹ | überfahren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست (معنای متفاوت: عبور دادن ↔ زیر گرفتن) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۷۰ | überfallen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | جداشدنی/جدانشدنی بودن مطمئن نیست؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۷۱ | überfangen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر (اصطلاح فنی) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۷۲ | überfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | جداشدنی/جدانشدنی بودن مطمئن نیست؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۷۳ | überfließen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | جداشدنی/جدانشدنی بودن مطمئن نیست؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۷۴ | überfragen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | تقریباً فقط «überfragt sein» (ناقص) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۷۵ | überfressen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۷۶ | überfrieren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۷۷ | übergehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست (معنای متفاوت: رفتن به ↔ نادیده گرفتن) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۷۸ | übergießen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۷۹ | überhaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۸۰ | überhängen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب hängen؛ جداشدنی/جدانشدنی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۸۱ | überheben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۸۲ | überkommen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۸۳ | überladen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۸۴ | überlaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست (معنای متفاوت) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۸۵ | überlesen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۸۶ | übrigbleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «übrig bleiben» و «übrigbleiben» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۸۷ | übrighaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «übrig haben» و «übrighaben» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۸۸ | übriglassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بین «übrig lassen» و «übriglassen» نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۸۹ | umbehalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۹۰ | umbinden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | جداشدنی/جدانشدنی بودن مطمئن نیست؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۹۱ | umbrechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست (معنای متفاوت) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۹۲ | umfahren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست (معنای متفاوت) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۹۳ | umfangen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۹۴ | umflechten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر (اصطلاح تخصصی) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۹۵ | umfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست (معنای متفاوت) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۹۶ | umfragen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر، تقریباً صرف نمی‌شود — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۹۷ | umgeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی (محاوره: umlegen) هم جدانشدنی (احاطه کردن)؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۹۸ | umgehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست (معنای متفاوت) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۲۹۹ | umgreifen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست (معنای متفاوت) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۰۰ | umhaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۰۱ | umhängen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب hängen؛ گذرا باقاعده، ناگذر بی‌قاعده — شکل‌ها نوسان دارند — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۰۲ | umhauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه؛ گذشته نوسان دارد (haute/hieb) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۰۳ | umherkriechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۰۴ | umhinkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب با فعل وجهی (مثل loskönnen)؛ umhinkommen کارت دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۰۵ | umlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۰۶ | umlaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست (معنای متفاوت) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۰۷ | unterbinden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست (معنای متفاوت) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۰۸ | untereinanderliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا نوسان دارد (untereinander liegen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۰۹ | unterfahren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر؛ جداشدنی/جدانشدنی بودن مطمئن نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۱۰ | unterfallen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر (زبان اداری) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۱۱ | unterfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۱۲ | untergraben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست (معنای متفاوت) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۱۳ | unterhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی هم جدانشدنی؛ نماد یکتا نیست (معنای متفاوت) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۱۴ | unterkriechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۱۵ | unterlaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | جداشدنی/جدانشدنی بودن مطمئن نیست؛ فعل کمکی بسته به معنا (sein/haben) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۱۶ | unterliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | هم جداشدنی (محلی: زیرش بودن) هم جدانشدنی (شکست خوردن)؛ نماد یکتا نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۱۷ | verbacken | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | شکل‌ها نوسان دارند (verbäckt/verbackt، verbackte/verbuk) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۱۸ | verblasen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۱۹ | verbleichen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | گذشته نوسان دارد (verblich/verbleichte) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۲۰ | verdingen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | قدیمی؛ شکل‌ها نوسان دارند (verdingte/verdang، verdungen/verdingt) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۲۱ | verdreschen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه و نادر (خانواده‌ی dreschen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۲۲ | verdrießen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ادبی و نادر؛ تقریباً فقط غیرشخصی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۲۳ | vergären | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | شکل‌ها نوسان دارند (vergor/vergärte) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۲۴ | verglimmen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر؛ شکل‌ها نوسان دارند (verglomm/verglimmte) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۲۵ | verhauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه؛ گذشته نوسان دارد (verhaute/verhieb) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۲۶ | verkiesen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | قدیمی (مثل erkiesen، auskiesen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۲۷ | verkleiben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | قدیمی و نادر (مثل ankleiben) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۲۸ | verleitgeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | منطقه‌ای (باواریا/اتریش) و نادر؛ معنا نامطمئن — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۲۹ | verlorengeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا نوسان دارد (verloren geben / verlorengeben) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۳۰ | verlorengehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا نوسان دارد (verloren gehen / verlorengehen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۳۱ | vermahlen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | تخصصی؛ صرف آمیخته (مثل ausmahlen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۳۲ | verquergehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه و نادر؛ املا نامطمئن — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۳۳ | verschüttgehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه؛ املا نوسان دارد (verschütt gehen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۳۴ | vollessen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا نوسان دارد (sich voll essen / vollessen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۳۵ | vollfressen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا نوسان دارد (sich voll fressen / vollfressen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۳۶ | vollgießen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا نوسان دارد (voll gießen / vollgießen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۳۷ | vollladen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا نوسان دارد (voll laden / vollladen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۳۸ | volllaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا نوسان دارد (voll laufen / volllaufen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۳۹ | voraufgehen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | قدیمی/ادبی (= vorangehen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۴۰ | vorausfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر (مثل herüberfliegen، hineinfliegen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۴۱ | vorbeidürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب با فعل وجهی (مثل hindurchdürfen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۴۲ | vorbeifließen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر (مثل hinfließen، dahinfließen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۴۳ | vorbeigelingen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | واژه‌ی رایجی نیست (مثل danebengelingen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۴۴ | vorbeigleiten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر (مثل hingleiten) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۴۵ | vorbeikönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب با فعل وجهی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۴۶ | vorbeimüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب با فعل وجهی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۴۷ | vorblasen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۴۸ | voreinanderliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا/کاربرد نامطمئن (مثل nebeneinanderliegen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۴۹ | vorenthalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | جداشدنی/جدانشدنی نوسان دارد (enthielt vor / vorenthielt) — «🔀» — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۵۰ | voressen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۵۱ | vorfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۵۲ | vorgebären | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | واژه‌ی رایجی نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۵۳ | vorhängen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب با hängen: گذرا/ناگذر نوسان دارد (مثل hinhängen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۵۴ | vorlaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر؛ معمولاً vorauslaufen — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۵۵ | vornüberfallen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۵۶ | vorüberfahren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ادبی و نادر (= vorbeifahren) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۵۷ | vorüberfliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۵۸ | vorübergleiten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۵۹ | vorüberkommen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۶۰ | vorüberlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۶۱ | vorüberlaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ادبی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۶۲ | vorwärtslaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا بسته به معنا (vorwärts laufen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۶۳ | wachhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا نوسان دارد (wach halten / wachhalten) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۶۴ | wägen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | صرف نوسان دارد (wog/wägte)؛ ادبی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۶۵ | wahrhaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | فقط «nicht wahrhaben wollen» (ناقص) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۶۶ | warmhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا نوسان دارد (warm halten / warmhalten) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۶۷ | warmlaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا نوسان دارد (warm laufen / warmlaufen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۶۸ | wegbegeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۶۹ | wegbeißen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۷۰ | wegbinden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۷۱ | wegbrechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | فعل کمکی یکتا نیست (sein/haben، مثل herausbrechen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۷۲ | wegbrennen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر؛ فعل کمکی نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۷۳ | wegdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب با فعل وجهی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۷۴ | wegfangen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۷۵ | wegfließen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۷۶ | wegfressen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه/زمخت (مثل wegessen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۷۷ | weghaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه (مثل herumhaben) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۷۸ | weghalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۷۹ | weghauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | گذشته نوسان دارد (haute/hieb) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۸۰ | weghelfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۸۱ | wegkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب با فعل وجهی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۸۲ | wegkriechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۸۳ | wegmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب با فعل وجهی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۸۴ | weiterdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب با فعل وجهی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۸۵ | weiterfragen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۸۶ | weiterfressen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه/زمخت — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۸۷ | weiterkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب با فعل وجهی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۸۸ | weiterkriechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۸۹ | weitermüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب با فعل وجهی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۹۰ | wenden | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | دو صرف بسته به معنا (wandte/wendete، مثل schaffen) ⇒ تصمیم Lukas — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۹۱ | werthalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | قدیمی و نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۹۲ | wettlaufen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | تقریباً فقط مصدر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۹۳ | widerklingen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۹۴ | wiedererhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر (معمولاً zurückerhalten) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۹۵ | wiederhaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | عامیانه — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۹۶ | wiederkennen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر/منطقه‌ای — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۹۷ | wiegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | دو فعل با دو صرف (wog = وزن / wiegte = تکان دادن)، مثل schaffen ⇒ تصمیم Lukas — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۹۸ | wissenlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا (wissen lassen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۳۹۹ | wundliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا نوسان دارد (wund liegen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۰۰ | zeihen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۰۱ | zerbersten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر/ادبی (مثل aufbersten) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۰۲ | zerfahren | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | به‌عنوان فعل نادر (بیشتر صفت «zerfahren») — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۰۳ | zerhauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | صرف نوسان‌دار haute/hieb (مثل aufhauen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۰۴ | zerklieben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۰۵ | zerlesen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | به‌عنوان فعل نادر (بیشتر صفت) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۰۶ | zermahlen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | صرف مختلط mahlte/gemahlen (مثل ausmahlen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۰۷ | zudenken | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | تقریباً فقط به شکل صفت مفعولی (zugedacht) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۰۸ | zueinanderdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب با فعل وجهی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۰۹ | zueinanderhalten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۱۰ | zueinanderkommen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا نوسان دارد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۱۱ | zueinanderkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب با فعل وجهی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۱۲ | zueinanderlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | املا نوسان دارد، نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۱۳ | zuerkennen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | جداشدنی/جدانشدنی نوسان‌دار (erkannte zu / zuerkannte) ⇒ مثل vorenthalten — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۱۴ | zugewinnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر (بیشتر hinzugewinnen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۱۵ | zuhaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | محاوره‌ای (مثل aushaben) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۱۶ | zuhauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | صرف نوسان‌دار haute/hieb — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۱۷ | zukneifen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر (مثل einkneifen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۱۸ | zukriechen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۱۹ | zuladen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر/تخصصی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۲۰ | zurechtbiegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر (مثل herumbiegen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۲۱ | zurechtbringen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر/قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۲۲ | zurückbegeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ادبی/نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۲۳ | zurückdürfen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب با فعل وجهی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۲۴ | zurückgießen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۲۵ | zurückgleiten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۲۶ | zurückhaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | محاوره‌ای (مثل wiederhaben) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۲۷ | zurückhauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | صرف نوسان‌دار haute/hieb — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۲۸ | zurückkönnen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب با فعل وجهی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۲۹ | zurückmüssen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ترکیب با فعل وجهی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۳۰ | zusammenbiegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۳۱ | zusammenflechten | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۳۲ | zusammengeben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر/منطقه‌ای — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۳۳ | zusammengießen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۳۴ | zusammenhaben | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | محاوره‌ای — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۳۵ | zusammenhängen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | ⚠️ ترکیب hängen: hing (ناگذر) / hängte (گذرا) مثل بقیه‌ی ترکیب‌های hängen؛ پرکاربرد ⇒ تصمیم Lukas — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۳۶ | zusammenhauen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | صرف نوسان‌دار haute/hieb — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۳۷ | zusammenklingen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۳۸ | zusammenkneifen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۳۹ | zusammenlassen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۴۰ | zusammenlesen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۴۱ | zusammenliegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۴۲ | zusammenlügen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | محاوره‌ای، نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۴۳ | zurückbiegen | `Verben_unregelmaeßig_Infinitiv.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۴۴ | aasen | `Verben_regelmaesig.txt` | 2026-10-13 | منطقه‌ای/محاوره‌ای — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۴۵ | abhausen | `Verben_regelmaesig.txt` | 2026-10-13 | منطقه‌ای، نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۴۶ | abwägen | `Verben_regelmaesig.txt` | 2026-10-13 | صرف نوسان‌دار wog/wägte (مثل wägen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۴۷ | addizieren | `Verben_regelmaesig.txt` | 2026-10-13 | نادر/تخصصی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۴۸ | affirmieren | `Verben_regelmaesig.txt` | 2026-10-13 | ادبی/نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۴۹ | affizieren | `Verben_regelmaesig.txt` | 2026-10-13 | نادر/تخصصی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۵۰ | algorithmisieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی، نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۵۱ | alimentieren | `Verben_regelmaesig.txt` | 2026-10-13 | ادبی/نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۵۲ | allozieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی، نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۵۳ | älteln | `Verben_regelmaesig.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۵۴ | alterieren | `Verben_regelmaesig.txt` | 2026-10-13 | قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۵۵ | altertümeln | `Verben_regelmaesig.txt` | 2026-10-13 | نادر/ادبی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۵۶ | altmachen | `Verben_regelmaesig.txt` | 2026-10-13 | املا (alt machen جدا نوشته می‌شود) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۵۷ | amalgamieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی، نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۵۸ | antichambrieren | `Verben_regelmaesig.txt` | 2026-10-13 | قدیمی/ادبی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۵۹ | apanagieren | `Verben_regelmaesig.txt` | 2026-10-13 | قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۶۰ | apern | `Verben_regelmaesig.txt` | 2026-10-13 | منطقه‌ای — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۶۱ | äpfeln | `Verben_regelmaesig.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۶۲ | apostrophieren | `Verben_regelmaesig.txt` | 2026-10-13 | ادبی/نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۶۳ | approximieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۶۴ | aptieren | `Verben_regelmaesig.txt` | 2026-10-13 | قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۶۵ | aquarellieren | `Verben_regelmaesig.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۶۶ | äquilibrieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی/نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۶۷ | arabisieren | `Verben_regelmaesig.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۶۸ | arbitrieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۶۹ | archaisieren | `Verben_regelmaesig.txt` | 2026-10-13 | ادبی/نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۷۰ | arisieren | `Verben_regelmaesig.txt` | 2026-10-13 | اصطلاح تاریخی دوران نازی — تصمیم Lukas — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۷۱ | arkadieren | `Verben_regelmaesig.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۷۲ | armieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی (ساختمان) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۷۳ | armmachen | `Verben_regelmaesig.txt` | 2026-10-13 | املا (arm machen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۷۴ | arretieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی/قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۷۵ | arrivieren | `Verben_regelmaesig.txt` | 2026-10-13 | ادبی/نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۷۶ | arrodieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۷۷ | arrondieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۷۸ | arsenieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۷۹ | arten | `Verben_regelmaesig.txt` | 2026-10-13 | نادر، فعل کمکی نامطمئن — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۸۰ | äsen | `Verben_regelmaesig.txt` | 2026-10-13 | اصطلاح شکارچیان — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۸۱ | aspirieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۸۲ | assekurieren | `Verben_regelmaesig.txt` | 2026-10-13 | قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۸۳ | assemblieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۸۴ | asservieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی (حقوقی) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۸۵ | asten | `Verben_regelmaesig.txt` | 2026-10-13 | منطقه‌ای/محاوره‌ای — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۸۶ | ästen | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی/نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۸۷ | ästhetisieren | `Verben_regelmaesig.txt` | 2026-10-13 | ادبی/نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۸۸ | äthern | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی/قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۸۹ | atomisieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی/ادبی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۹۰ | atrophieren | `Verben_regelmaesig.txt` | 2026-10-13 | اصطلاح پزشکی، به‌ندرت فعل — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۹۱ | attachieren | `Verben_regelmaesig.txt` | 2026-10-13 | قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۹۲ | attraktivieren | `Verben_regelmaesig.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۹۳ | attribuieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۹۴ | atzen | `Verben_regelmaesig.txt` | 2026-10-13 | اصطلاح شکارچیان/قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۹۵ | aufächzen | `Verben_regelmaesig.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۹۶ | appretieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی (نساجی) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۹۷ | äugeln | `Verben_regelmaesig.txt` | 2026-10-13 | قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۹۸ | äugen | `Verben_regelmaesig.txt` | 2026-10-13 | اصطلاح شکارچیان — قاعده‌ی ۱۴/۱۶ | — |
| ۱۴۹۹ | ausixen | `Verben_regelmaesig.txt` | 2026-10-13 | محاوره‌ای، املا نوسان‌دار — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۰۰ | ausmergeln | `Verben_regelmaesig.txt` | 2026-10-13 | تقریباً فقط به شکل صفت (ausgemergelt) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۰۱ | auszementieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۰۲ | auszieren | `Verben_regelmaesig.txt` | 2026-10-13 | قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۰۳ | auszirkeln | `Verben_regelmaesig.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۰۴ | authentisieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی (بیشتر authentifizieren) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۰۵ | autographieren | `Verben_regelmaesig.txt` | 2026-10-13 | قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۰۶ | autoklavieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۰۷ | autonomisieren | `Verben_regelmaesig.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۰۸ | auxiliieren | `Verben_regelmaesig.txt` | 2026-10-13 | قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۰۹ | aversionieren | `Verben_regelmaesig.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۱۰ | avertieren | `Verben_regelmaesig.txt` | 2026-10-13 | قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۱۱ | avisieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی/نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۱۲ | avivieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۱۳ | avouieren | `Verben_regelmaesig.txt` | 2026-10-13 | قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۱۴ | axiomatisieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۱۵ | azotieren | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۱۶ | balbieren | `Verben_regelmaesig.txt` | 2026-10-13 | قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۱۷ | baldowern | `Verben_regelmaesig.txt` | 2026-10-13 | محاوره‌ای/نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۱۸ | balsamieren | `Verben_regelmaesig.txt` | 2026-10-13 | تقریباً فقط einbalsamieren — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۱۹ | bändern | `Verben_regelmaesig.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۲۰ | barbieren | `Verben_regelmaesig.txt` | 2026-10-13 | قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۲۱ | bäumen | `Verben_regelmaesig.txt` | 2026-10-13 | نادر (بیشتر sich aufbäumen) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۲۲ | bauschen | `Verben_regelmaesig.txt` | 2026-10-13 | نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۲۳ | bechern | `Verben_regelmaesig.txt` | 2026-10-13 | محاوره‌ای — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۲۴ | beckmessern | `Verben_regelmaesig.txt` | 2026-10-13 | ادبی/نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۲۵ | beeiden | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی (حقوقی) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۲۶ | beeidigen | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی (حقوقی) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۲۷ | befleißigen | `Verben_regelmaesig.txt` | 2026-10-13 | ادبی/قدیمی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۲۸ | befrachten | `Verben_regelmaesig.txt` | 2026-10-13 | تخصصی/نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۲۹ | befummeln | `Verben_regelmaesig.txt` | 2026-10-13 | محاوره‌ای، اغلب با بار جنسی — تصمیم Lukas — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۳۰ | beglotzen | `Verben_regelmaesig.txt` | 2026-10-13 | محاوره‌ای/زمخت — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۳۱ | begnaden | `Verben_regelmaesig.txt` | 2026-10-13 | ادبی/قدیمی (بیشتر begnadet) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۳۲ | bekiffen | `Verben_regelmaesig.txt` | 2026-10-13 | محاوره‌ای (مواد مخدر)، نادر — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۳۳ | belämmern | `Verben_regelmaesig.txt` | 2026-10-14 | محاوره‌ای، نادر؛ معنا (آزار دادن/فریب دادن) مطمئن نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۳۴ | benedeien | `Verben_regelmaesig.txt` | 2026-10-14 | کهنه/کلیسایی؛ صفت مفعولی دوگانه (benedeit/gebenedeit) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۳۵ | beschälen | `Verben_regelmaesig.txt` | 2026-10-14 | اصطلاح تخصصی پرورش اسب، کم‌کاربرد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۳۶ | beschranken | `Verben_regelmaesig.txt` | 2026-10-14 | کم‌کاربرد، بیشتر فقط صفت مفعولی (beschrankt) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۳۷ | bessemern | `Verben_regelmaesig.txt` | 2026-10-14 | اصطلاح تخصصی ذوب فلز — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۳۸ | bestallen | `Verben_regelmaesig.txt` | 2026-10-14 | زبان اداری، رو به کهنگی، کم‌کاربرد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۳۹ | bestuhlen | `Verben_regelmaesig.txt` | 2026-10-14 | کم‌کاربرد، تخصصی (صندلی چیدن در سالن) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۴۰ | betatschen | `Verben_regelmaesig.txt` | 2026-10-14 | محاوره‌ای، اغلب با بار جنسی (مثل befummeln) — تصمیم Lukas — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۴۱ | betonnen | `Verben_regelmaesig.txt` | 2026-10-14 | اصطلاح تخصصی دریانوردی — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۴۲ | beulen | `Verben_regelmaesig.txt` | 2026-10-14 | کم‌کاربرد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۴۳ | beuteln | `Verben_regelmaesig.txt` | 2026-10-14 | محاوره‌ای/محلی؛ معنا مطمئن نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۴۴ | bewandern | `Verben_regelmaesig.txt` | 2026-10-14 | به‌عنوان فعل تقریباً به کار نمی‌رود (بیشتر صفت bewandert) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۴۵ | bewegen | `Verben_regelmaesig.txt` | 2026-10-14 | دو صرف بسته به معنا (bewegte «تکان دادن» ↔ bewog «وادار کردن»)، مثل wenden — ⚠️ کلمه‌ی پرکاربرد، تصمیم Lukas — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۴۶ | bimsen | `Verben_regelmaesig.txt` | 2026-10-15 | دو معنا (با سنگ پا صیقل دادن ↔ محاوره‌ای «خرخوانی کردن»)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۴۷ | bläuen | `Verben_regelmaesig.txt` | 2026-10-15 | کم‌کاربرد؛ با «bleuen» (کتک زدن) قاطی می‌شود — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۴۸ | blessieren | `Verben_regelmaesig.txt` | 2026-10-15 | منسوخ و خیلی کم‌کاربرد (زخمی کردن) — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۴۹ | blinkern | `Verben_regelmaesig.txt` | 2026-10-15 | محلی/کم‌کاربرد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۵۰ | bollern | `Verben_regelmaesig.txt` | 2026-10-15 | محلی (سروصدا کردن)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۵۱ | bosseln | `Verben_regelmaesig.txt` | 2026-10-15 | محاوره‌ای/محلی (کار دستی کردن) و نام یک بازی؛ معنا روشن نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۵۲ | bummern | `Verben_regelmaesig.txt` | 2026-10-15 | محلی (محکم در زدن)؛ کم‌کاربرد — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۵۳ | bumsen | `Verben_regelmaesig.txt` | 2026-10-15 | محاوره‌ای/رکیک، معنای جنسی (مثل befummeln) ⇒ ⚠️ تصمیم Lukas — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۵۴ | chargieren | `Verben_regelmaesig.txt` | 2026-10-15 | چند معنای تخصصی (تئاتر: اغراق در بازی؛ نظامی؛ ذوب فلز)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴/۱۶ | — |
| ۱۵۵۵ | deputieren | `Verben_regelmaesig.txt` | 2026-10-15 | کم‌کاربرد (abordnen)؛ برچسب سبکی (منسوخ؟) مطمئن نیست — قاعده‌ی ۱۴/۱۷ | — |
| ۱۵۵۶ | distinguieren | `Verben_regelmaesig.txt` | 2026-10-15 | امروز تقریباً فقط Partizip «distinguiert» (کارت صفت خودش)؛ فعل منسوخ، کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۵۷ | doktern | `Verben_regelmaesig.txt` | 2026-10-15 | محاوره‌ای، بیشتر «herumdoktern»؛ معنا/کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۵۸ | downloaden | `Verben_regelmaesig.txt` | 2026-10-15 | Partizip II دوگانه (downgeloadet/gedownloadet)، جداشدنی بودن مطمئن نیست ⇒ قاعده‌ی ۳ (نماد غلط بدتر از نبودن) | — |
| ۱۵۵۹ | dräuen | `Verben_regelmaesig.txt` | 2026-10-15 | شاعرانه/منسوخ (drohen)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۶۰ | dröseln | `Verben_regelmaesig.txt` | 2026-10-15 | محلی، بیشتر «aufdröseln»؛ معنا مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۶۱ | eifern | `Verben_regelmaesig.txt` | 2026-10-15 | فاخر، امروز بیشتر «nacheifern»/«sich ereifern»؛ کاربرد/برچسب سبکی مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۶۲ | einverleiben | `Verben_regelmaesig.txt` | 2026-10-15 | Präteritum/Partizip دوگانه (verleibte ein / einverleibte) ⇒ جداشدنی بودن مطمئن نیست ⇒ قاعده‌ی ۳ | — |
| ۱۵۶۳ | ejakulieren | `Verben_regelmaesig.txt` | 2026-10-15 | ⚠️ موضوع جنسی (مثل masturbatorisch، promisk) ⇒ تصمیم Lukas | — |
| ۱۵۶۴ | entblöden | `Verben_regelmaesig.txt` | 2026-10-15 | فقط در عبارت ثابت «sich nicht entblöden, … zu …» (فاخر/رو به منسوخ)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۶۵ | entleiben | `Verben_regelmaesig.txt` | 2026-10-15 | ⚠️ «sich entleiben» = خودکشی کردن (فاخر/منسوخ)؛ موضوع حساس ⇒ تصمیم Lukas — قاعده‌ی ۱۴ | — |
| ۱۵۶۶ | entpersönlichen | `Verben_regelmaesig.txt` | 2026-10-15 | کم‌کاربرد، معنا/کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۶۷ | entrinden | `Verben_regelmaesig.txt` | 2026-10-15 | اصطلاح تخصصی جنگل‌داری، کم‌کاربرد — قاعده‌ی ۱۴ | — |
| ۱۵۶۸ | entwanzen | `Verben_regelmaesig.txt` | 2026-10-15 | دو معنای کم‌کاربرد (حشره‌زدایی / برداشتن شنود)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۶۹ | erbittern | `Verben_regelmaesig.txt` | 2026-10-15 | کم‌کاربرد؛ امروز بیشتر Partizip «erbittert» (کارت صفت) یا «verbittern»؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۷۰ | erfrechen | `Verben_regelmaesig.txt` | 2026-10-15 | «sich erfrechen» رو به منسوخ و کم‌کاربرد؛ برچسب سبکی مطمئن نیست — قاعده‌ی ۱۴/۱۷ | — |
| ۱۵۷۱ | erigieren | `Verben_regelmaesig.txt` | 2026-10-15 | ⚠️ معنای جنسی/پزشکی (نعوظ؛ مثل ejakulieren) ⇒ تصمیم Lukas | — |
| ۱۵۷۲ | erkühnen | `Verben_regelmaesig.txt` | 2026-10-15 | «sich erkühnen» فاخر و کم‌کاربرد؛ برچسب سبکی مطمئن نیست — قاعده‌ی ۱۴/۱۷ | — |
| ۱۵۷۳ | erotisieren | `Verben_regelmaesig.txt` | 2026-10-15 | ⚠️ موضوع جنسی (مثل ejakulieren) ⇒ تصمیم Lukas | — |
| ۱۵۷۴ | ertauben | `Verben_regelmaesig.txt` | 2026-10-15 | کم‌کاربرد/تخصصی (ناشنوا شدن)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۷۵ | ertüchtigen | `Verben_regelmaesig.txt` | 2026-10-15 | کم‌کاربرد و فاخر؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۷۶ | eskamotieren | `Verben_regelmaesig.txt` | 2026-10-15 | بسیار کم‌کاربرد (شعبده/پنهان کردن)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۷۷ | evangelisieren | `Verben_regelmaesig.txt` | 2026-10-15 | کم‌کاربرد (تبلیغ مسیحیت)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۷۸ | exmittieren | `Verben_regelmaesig.txt` | 2026-10-15 | اصطلاح اداری/حقوقی کم‌کاربرد (تخلیه‌ی اجباری مستأجر)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۷۹ | extemporieren | `Verben_regelmaesig.txt` | 2026-10-15 | بسیار کم‌کاربرد (بداهه‌گویی)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۸۰ | fächern | `Verben_regelmaesig.txt` | 2026-10-15 | کم‌کاربرد (بیشتر «auffächern»)؛ معنا/کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۸۱ | fälteln | `Verben_regelmaesig.txt` | 2026-10-15 | اصطلاح تخصصی خیاطی، کم‌کاربرد — قاعده‌ی ۱۴ | — |
| ۱۵۸۲ | falzen | `Verben_regelmaesig.txt` | 2026-10-15 | اصطلاح تخصصی (صحافی/ورق‌کاری) با چند معنا؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۸۳ | ferkeln | `Verben_regelmaesig.txt` | 2026-10-15 | کم‌کاربرد با دو معنای متفاوت (زاییدن خوک / کثیف‌کاری)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۸۴ | feudeln | `Verben_regelmaesig.txt` | 2026-10-15 | منطقه‌ای (شمال آلمان)، کم‌کاربرد — قاعده‌ی ۱۴ | — |
| ۱۵۸۵ | fiedern | `Verben_regelmaesig.txt` | 2026-10-15 | کم‌کاربرد (پر دادن؛ گیاه‌شناسی)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۸۶ | fingern | `Verben_regelmaesig.txt` | 2026-10-15 | محاوره‌ای با چند معنا (ور رفتن / زیرکانه جور کردن)؛ مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۸۷ | fixen | `Verben_regelmaesig.txt` | 2026-10-15 | زبان خاص (تزریق مواد مخدر / اصطلاح بورس)؛ کاربرد و سطح زبان مطمئن نیست — قاعده‌ی ۱۴/۱۷ | — |
| ۱۵۸۸ | flammen | `Verben_regelmaesig.txt` | 2026-10-15 | ادبی و کم‌کاربرد (بیشتر aufflammen/entflammen)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۸۹ | fläzen | `Verben_regelmaesig.txt` | 2026-10-15 | محاوره‌ای و تحقیرآمیز («sich fläzen»)؛ برچسب سطح زبان مطمئن نیست — قاعده‌ی ۱۴/۱۷ | — |
| ۱۵۹۰ | fleddern | `Verben_regelmaesig.txt` | 2026-10-15 | کم‌کاربرد (غارت جسد)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۹۱ | flennen | `Verben_regelmaesig.txt` | 2026-10-15 | محاوره‌ای و تحقیرآمیز (گریه کردن)؛ درجه‌ی توهین‌آمیز بودن مطمئن نیست — قاعده‌ی ۱۷ | — |
| ۱۵۹۲ | flirren | `Verben_regelmaesig.txt` | 2026-10-15 | ادبی و کم‌کاربرد (لرزیدن نور/هوا)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۹۳ | fraktionieren | `Verben_regelmaesig.txt` | 2026-10-15 | اصطلاح تخصصی (شیمی: تقطیر جزء‌به‌جزء؛ پزشکی: تقسیم پرتودرمانی) با چند معنا؛ مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۹۴ | freveln | `Verben_regelmaesig.txt` | 2026-10-15 | ادبی/در حال منسوخ شدن (گناه/بی‌حرمتی کردن)؛ برچسب زمانی مطمئن نیست — قاعده‌ی ۱۴/۱۷ | — |
| ۱۵۹۵ | frikassieren | `Verben_regelmaesig.txt` | 2026-10-15 | کم‌کاربرد با دو معنا (خوراک فریکاسه / محاوره‌ای: کتک زدن)؛ مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۵۹۶ | frömmeln | `Verben_regelmaesig.txt` | 2026-10-15 | تحقیرآمیز و کم‌کاربرد (تظاهر به دینداری)؛ برچسب مطمئن نیست — قاعده‌ی ۱۴/۱۷ | — |
| ۱۵۹۷ | frommen | `Verben_regelmaesig.txt` | 2026-10-15 | منسوخ (فایده داشتن)؛ برچسب زمانی و جایگزین مطمئن نیست — قاعده‌ی ۱۷ | — |
| ۱۵۹۸ | fummeln | `Verben_regelmaesig.txt` | 2026-10-15 | محاوره‌ای؛ یکی از معناها بار جنسی دارد (مثل befummeln) ⇒ تصمیم Lukas | — |
| ۱۵۹۹ | furzen | `Verben_regelmaesig.txt` | 2026-10-15 | رکیک — تصمیم Lukas (قاعده‌ی ۱۷) | — |
| ۱۶۰۰ | füßeln | `Verben_regelmaesig.txt` | 2026-10-15 | محاوره‌ای (لمس پا زیر میز، معمولاً برای دلبری)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۶۰۱ | gasen | `Verben_regelmaesig.txt` | 2026-10-15 | چند معنا (گاز دادن، گاز پس دادن؛ نزدیک به «vergasen»)؛ مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۶۰۲ | gaukeln | `Verben_regelmaesig.txt` | 2026-10-15 | ادبی و کم‌کاربرد (بال‌بال زدن؛ بیشتر vorgaukeln)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۶۰۳ | gebaren | `Verben_regelmaesig.txt` | 2026-10-15 | در حال منسوخ شدن و کم‌کاربرد («sich gebaren»)؛ برچسب زمانی مطمئن نیست — قاعده‌ی ۱۷ | — |
| ۱۶۰۴ | gedeihen | `Verben_regelmaesig.txt` | 2026-10-15 | در فهرست باقاعده است ولی بی‌قاعده صرف می‌شود (gedieh، gediehen) و کارت پایه برای صرف ندارد؛ مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۶۰۵ | geifern | `Verben_regelmaesig.txt` | 2026-10-15 | ادبی/تحقیرآمیز (کف به دهان آوردن، ناسزا گفتن)؛ برچسب مطمئن نیست — قاعده‌ی ۱۷ | — |
| ۱۶۰۶ | gelüsten | `Verben_regelmaesig.txt` | 2026-10-15 | ادبی و غیرشخصی («es gelüstet mich nach»)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۶۰۷ | gerieren | `Verben_regelmaesig.txt` | 2026-10-15 | زبان فرهیخته و کم‌کاربرد («sich gerieren als»)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۶۰۸ | gieren | `Verben_regelmaesig.txt` | 2026-10-15 | ادبی/تحقیرآمیز (حریصانه چیزی خواستن)؛ برچسب مطمئن نیست — قاعده‌ی ۱۷ | — |
| ۱۶۰۹ | girren | `Verben_regelmaesig.txt` | 2026-10-15 | کم‌کاربرد و ادبی (بغبغو کردن کبوتر)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۶۱۰ | gleißen | `Verben_regelmaesig.txt` | 2026-10-15 | ادبی و کم‌کاربرد (درخشش خیره‌کننده؛ صرف گذشته نوسان‌دار)؛ مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۶۱۱ | grabbeln | `Verben_regelmaesig.txt` | 2026-10-15 | منطقه‌ای (شمال آلمان: دست‌دست کردن)، کم‌کاربرد — قاعده‌ی ۱۴ | — |
| ۱۶۱۲ | grämen | `Verben_regelmaesig.txt` | 2026-10-15 | ادبی («sich grämen» غصه خوردن)؛ برچسب مطمئن نیست — قاعده‌ی ۱۷ | — |
| ۱۶۱۳ | granteln | `Verben_regelmaesig.txt` | 2026-10-15 | منطقه‌ای (بایرن/اتریش، محاوره‌ای: بدخلقی کردن)؛ مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۶۱۴ | grapschen | `Verben_regelmaesig.txt` | 2026-10-15 | محاوره‌ای؛ یکی از معناها بار جنسی دارد (begrapschen) ⇒ تصمیم Lukas | — |
| ۱۶۱۵ | grausen | `Verben_regelmaesig.txt` | 2026-10-15 | غیرشخصی/بازتابی با حالت (Dat/Akk) نوسان‌دار؛ مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۶۱۶ | greinen | `Verben_regelmaesig.txt` | 2026-10-15 | محاوره‌ای و تحقیرآمیز (نق زدن گریه‌آلود)؛ برچسب مطمئن نیست — قاعده‌ی ۱۷ | — |
| ۱۶۱۷ | grienen | `Verben_regelmaesig.txt` | 2026-10-15 | منطقه‌ای (شمال آلمان: نیشخند)، کم‌کاربرد — قاعده‌ی ۱۴ | — |
| ۱۶۱۸ | grummeln | `Verben_regelmaesig.txt` | 2026-10-15 | محاوره‌ای با چند معنا (غرغر، قاروقور شکم، غرش رعد)؛ مطمئن نیست — قاعده‌ی ۱۴ | — |
| ۱۶۱۹ | gründeln | `Verben_regelmaesig.txt` | 2026-10-15 | اصطلاح جانورشناسی (غذا جستن در کف آب)، کم‌کاربرد — قاعده‌ی ۱۴ | — |
| ۱۶۲۰ | guillotinieren | `Verben_regelmaesig.txt` | 2026-10-15 | تاریخی و کم‌کاربرد (اعدام با گیوتین)؛ کاربرد مطمئن نیست — قاعده‌ی ۱۴ | — |

## 🔁 مرحله‌ی آخر (۲) — کلمه‌های تکراری/چندنسخه‌ای (L.4d)

> **تصمیم Lukas (2026-09-24 دور ۵۷، به‌روز دور ۶۳):** کلمه‌ها **در هر صورت** ساخته می‌شوند، حتی اگر دوبرابر شوند (⭐ اصل اول در «📚 روال»). **در آخرین مرحله** — وقتی هر چهار فهرست (`Adjektive` ⇒ `Verben_unregelmaeßig_Infinitiv` ⇒ `Verben_regelmaesig` ⇒ `substantiv_singular_alle`) صفر تا صد وارد اپ شد — Claude **همه‌ی** کلمه‌های اضافی/دوبرابر را پیدا می‌کند و این‌جا ثبت می‌کند؛ **Lukas تصمیم می‌گیرد** با هر کدام چه شود (ادغام، نگه داشتن هر دو، لینک، …).
> ⛔ تا آن موقع و بدون تصمیم Lukas: **هیچ** صفحه، کلمه یا جزئیاتی حذف، ادغام، پنهان یا هدایت نمی‌شود. وسط روال ده کلمه هم لازم نیست تکراری‌ها بررسی یا ثبت شوند — همه یک‌جا در آخر.
> 📌 ترتیب این بخش با «🏁 مرحله‌ی آخر» و L.4c را Lukas تعیین می‌کند.

**Claude کجا را می‌گردد (همه‌ی منابع کلمه در اپ):**
- آرشیو `assets/vocab/**` (همه‌ی Wortartها) + `assets/vocab_index.json`.
- کلمه‌ها و عبارت‌های deckهای Auswendiglernen و صفحه‌های قدیمی (`word_detail_screen.dart`، `assets/data/*_data.json`؛ جفت‌های شناخته‌شده: `features/wortschatz/data/altwort_karte.dart`).
- فهرست‌های `old files Lukasalmani/Wörter/*.txt` (فقط برای مقایسه؛ مرجع وجود کارت `assets/vocab/` است).

**چه چیزی «تکراری/چندنسخه‌ای» است (Claude پیدا و دسته‌بندی می‌کند، حدس نمی‌زند):**
1. همان lemma + همان Wortart در **دو کارت** (دو id).
2. **گونه‌های املایی/شکلی** یک کلمه با کارت جدا (مثل allein / alleine — هر دو الان کارت دارند).
3. همان کلمه با **Wortartهای مختلف** (صفت + قید، یا برچسب فهرست ≠ `wortartKorrektur`).
4. کارت تازه + **صفحه‌ی قدیمی** همان کلمه: کلمه‌ی تنها (`helfen`)، با حرف اضافه (`warten auf`، `vertrauen auf/in`)، با `sich` (`sich bedanken bei`) — چه زیر صفحه‌ی قدیمی نمایش اضافه داشته باشد، چه نه.
5. کارت کلمه + **عبارتی** که آن کلمه را دارد (`Entscheidung` ↔ «eine Entscheidung treffen») — فقط برای دیدن Lukas.
6. هم‌نویسه‌ها (Homographe) با معنای جدا — احتمالاً درست‌اند، ولی برای تأیید Lukas ثبت می‌شوند.

**خروجی Claude:** جدول پایین (یک ردیف برای هر گروه) + خلاصه در MAP. هنگام اجرای تصمیم Lukas: id کارت منتشرشده بدون تصمیم صریح او هرگز عوض/حذف نمی‌شود؛ پیشرفت لایتنر و لیست‌های کاربر که به آن id اشاره دارند قبلش نگهبان دارند (قاعده‌ی «قبل از انتشار»، L.1).

| # | کلمه | نسخه‌ها (id / جا) | نوع (۱–۵) | توضیح Claude | تصمیم Lukas |
|---|---|---|---|---|---|
| — | (هنوز خالی — بعد از وارد شدن همه‌ی کلمه‌ها پر می‌شود) | | | | |

## 🧩 مرحله‌ی آخر (۳) — کلمه‌های رایجی که در فهرست‌های Lukas نیستند (تصمیم Lukas، 2026-10-11)

> **زمان: فقط بعد از تمام شدن هر چهار فهرست** (صفت‌ها ⇒ افعال بی‌قاعده ⇒ افعال باقاعده ⇒ اسم‌ها) و بعد از «🏁 مرحله‌ی آخر» و «🔁 مرحله‌ی آخر (۲)». تا آن موقع ترتیب فهرست‌ها دست نمی‌خورد.
> **چرا؟** هنگام ساختن افعال (دور ۵۲۵–۵۲۶) دیده شد که فهرست `Verben_unregelmaeßig_Infinitiv.txt` بعضی فعل‌های خیلی رایج را ندارد — مثلاً anrufen، annehmen (بعد از anliegen مستقیم anlügen، anmessen، anziehen می‌آیند).

- [ ] **۳.۱ — ساختن فهرست:** کلمه‌های رایجِ غایب را از یک منبع معتبر پیدا کن (پیشنهاد: فهرست‌های واژگان Goethe A1–B2، فهرست بسامد DWDS/Leipzig، Duden) و با آرشیو (`assets/vocab/`) و چهار فهرست مقایسه کن؛ فقط آن‌هایی که نه کارت دارند نه در فهرستی هستند. فهرست را به‌صورت فایل تازه در `old files Lukasalmani/Wörter/` بگذار و منبع را بنویس.
- [ ] **۳.۲ — تأیید Lukas:** فهرست را قبل از ساختن به Lukas نشان بده.
- [ ] **۳.۳ — ساختن کارت‌ها:** با همان روال (`tool/wort_runde.sh`)، همان پرامپت و همان قاعده‌ها (فعل‌ها: قاعده‌ی ۱۶)؛ فهرست تازه آخر `listen` در `tool/naechste_woerter.dart` اضافه می‌شود.

## 🌍 فاز Z — پایان: انتشار روی پلتفرم‌های دیگر (تصمیم Lukas، 2026-09-24 دور ۶۵)

> **شرط شروع (سخت):** فقط وقتی **همه‌ی بخش‌های اپ کامل** شد — همه‌ی `[ ]`/`[~]`های این فایل ✅، هر چهار فهرست کلمه، «🏁 مرحله‌ی آخر» و «🔁 مرحله‌ی آخر (۲)» با تصمیم Lukas بسته — و **همه‌ی تست‌ها سبز** است (`flutter analyze` + `flutter test` + deploy و تست آفلاین Chrome در GitHub Actions). ⛔ قبل از آن هیچ قدمی از فاز Z شروع نمی‌شود.
> **ترتیب ثابت (Lukas):** Z.1 ربات تلگرام ⇒ Z.2 تبلیغات گوگل روی سایت ⇒ Z.3 نسخه‌ی اندروید و آیفون.
> **اصل‌ها در هر سه:** «یک محتوا، چند ورودی» — ربات و اپ‌ها **همان** داده‌ها را می‌خوانند (`assets/vocab/`، `vocab_index.json`، `assets/data/`…)، هیچ کپی دوم ساخته نمی‌شود · رنگ/نماد فقط از `GrammatikonSpec` · هیچ راه‌حل موقت · داده و پیشرفت لایتنر کاربر هرگز در خطر نیست (قاعده‌ی «قبل از انتشار»، L.1).
> ⛔ **قبل از شروع هر مرحله** تصمیم‌های باز همان مرحله (پایین) را از Lukas بپرس — Claude حدس نمی‌زند.

### Z.1 — ربات تلگرام (ربات واقعی، نه Mini App) ⬜
- **هدف (Lukas):** کل سایت به‌صورت **ربات تلگرامی واقعی** که همه کار می‌کند: جست‌وجوی کلمه (کارت کامل: آرتیکل، معنی fa/en، تلفظ، مثال)، ارسال فایل و لینک، و بقیه‌ی بخش‌های اپ. Mini App (L.3c، `web/telegram_guard.js`) جدا و دست‌نخورده می‌ماند.
- **چرا جدا از سایت:** GitHub Pages فقط فایل ثابت است؛ ربات به سروری نیاز دارد که همیشه روشن باشد و پیام‌ها را جواب دهد.
- ⛔ **تصمیم‌های باز Lukas:** (۱) میزبان سرور ربات (مثلاً Supabase Edge Functions که هم‌اکنون مشترک با Root-in است، یا سرویس دیگر) و سقف هزینه · (۲) نام و @username ربات — توکن را Lukas در BotFather می‌سازد؛ توکن فقط به‌صورت secret، **هرگز در ریپو** · (۳) فهرست دقیق کارها (کدام بخش‌ها، کدام فایل‌ها) · (۴) لایتنر و پیشرفت در ربات: بله/نه، و اگر بله اتصال به همان حساب Supabase (با نگهبان L.1) · (۵) زبان ربات (مثل اپ: پیش‌فرض انگلیسی، فارسی برای کاربر فارسی‌زبان؟).
- ظاهر: تلگرام متن رنگی ندارد ⇒ اگر تصویر کارت لازم شد، فقط از روی `GrammatikonSpec` ساخته شود، نه تعریف رنگ مستقل.

### Z.2 — تبلیغات گوگل (AdSense) روی سایت ⬜
- **هدف (Lukas):** نمایش تبلیغات گوگل در سایت VOX.
- ⚠️ **چیزهایی که باید پیش از ساخت روشن شوند:** (۱) تا امروز VOX «بدون ردیابی (tracking)» معرفی شده ⇒ متن معرفی و `PRIVACY` باید عوض شوند · (۲) کاربران اروپا (اتریش): بنر رضایت کوکی (CMP تأییدشده‌ی گوگل) قانوناً لازم است · (۳) تأیید AdSense برای زیردامنه‌ی `lukasylilli.github.io` باید بررسی شود (فایل `ads.txt` در ریشه‌ی دامنه)؛ شاید دامنه‌ی اختصاصی لازم باشد · (۴) Flutter-Web روی canvas رسم می‌کند ⇒ تبلیغ یک جای HTML جدا لازم دارد · (۵) آفلاین و service worker (`vox_sw.js`) نباید با تبلیغ خراب شوند؛ اگر تبلیغ بار نشد، اپ بی‌نقص کار کند.
- ⛔ **تصمیم‌های باز Lukas:** تبلیغ در کدام صفحه‌ها (پیشنهاد برای پرسیدن: نه وسط تمرین و لایتنر) · حساب AdSense (به نام Lukas) · Root-in هم تبلیغ بگیرد یا نه (ریپوی جدا).

### Z.3 — نسخه‌ی اندروید و آیفون ⬜
- **هدف (Lukas):** انتشار VOX در Google Play و App Store.
- **پیش‌زمینه:** 2026-09-13 پوشه‌های android/ios عمداً حذف شدند (VOX فقط وب شد) ⇒ این‌جا از نو و درست ساخته می‌شوند، نه بازگرداندن نسخه‌ی قدیمی (RevenueCat و Notifications قدیمی برنمی‌گردند مگر با تصمیم Lukas).
- ⚠️ **روشن شود:** (۱) هزینه‌ها: Google Play یک‌بار ۲۵ دلار، Apple Developer سالانه ۹۹ دلار — حساب‌ها به نام Lukas · (۲) ساخت iOS به macOS نیاز دارد و Lukas دیگر Mac محلی ندارد ⇒ ساخت در GitHub Actions (runner مک) · (۳) ذخیره‌ی داده روی گوشی (drift با SQLite بومی به‌جای WASM) — پیشرفت لایتنر از طریق همان حساب/پشتیبان Supabase منتقل شود، بدون از دست رفتن (L.1) · (۴) شرایط فروشگاه‌ها: سیاست حریم خصوصی، برچسب داده‌ها، حذف حساب (L.1d ✅ هست) · (۵) تبلیغ داخل اپ‌ها با AdMob است نه AdSense — همراه Z.2 تصمیم گرفته شود.
- ⛔ **تصمیم‌های باز Lukas:** نام اپ در فروشگاه‌ها · تبلیغ در اپ بله/نه · Root-in هم اپ موبایل بگیرد یا نه (Root-in در فاز ۲۸ خودش هم android/ios را حذف کرده).
