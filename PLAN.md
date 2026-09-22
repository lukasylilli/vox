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
> 🗓️ **آخرین جلسه:** 2026-09-22 (دور ۷) — فقط سند، کدی عوض نشد. Lukas داشبورد Supabase را باز کرد تا لینک «Reset Password» را طبق دور ۶ عوض کند ⇒ تب فقط **Preview** دارد، ویرایش/ذخیره‌ی HTML غیرفعال است.
> **علت:** از ژوئن ۲۰۲۶ Supabase برای پروژه‌های free-tier با ایمیل پیش‌فرض، ویرایش خام قالب‌های Auth را در **Studio** قفل کرده (ضد سوءاستفاده)؛ پروژه‌های قدیمی‌تر از کش‌آف معاف‌اند، این پروژه نه. باز شدنش فقط با Custom SMTP، send-email hook، یا پلن پولی ممکن است — هر سه برای این یک تغییر زیاده‌روی است.
> **تصمیم:** به‌جای این‌ها، از **Supabase Management API** استفاده شود؛ قفل مخصوص Studio است، نه API. `PATCH https://api.supabase.com/v1/projects/{ref}/config/auth` با فیلد `mailer_templates_recovery_content` مستقیم HTML قالب Reset Password را با لینک `{{ .RedirectTo }}?token_hash={{ .TokenHash }}&type=recovery` جایگزین می‌کند — بدون SMTP و بدون ارتقای پلن.
> ⏭️ **قدم بعدی (اولین کاری که چت بعدی انجام می‌دهد):** از Lukas این دو باید گرفته شود: (۱) یک **Personal Access Token** از Supabase (Account → Access Tokens → Generate new token) (۲) **Project ref** پروژه‌ی VOX (رشته‌ی بعد از `/project/` در URL داشبورد؛ در PLAN همین فایل هم `uayaomoxxzzbjquxbcpu` ثبت شده — همان‌جا بررسی و تأیید شود). با این دو، Claude خودش درخواست PATCH را می‌زند، سپس Lukas با یک ایمیل تازه («فراموشی رمز» → لینک تازه) در هر مرورگری تست می‌کند و نتیجه را می‌گوید.
> ⚠️ **نکته‌ی امنیتی برای Lukas:** آن PAT به کل حساب Supabase (نه فقط این پروژه) دسترسی مدیریتی می‌دهد؛ بعد از انجام کار می‌تواند از تنظیمات Supabase Revoke شود.
>
> 🗓️ **جلسه‌ی قبل (دور ۶):** 2026-09-22 (دور ۶) — **باگ لینک «فراموشی رمز»** (گزارش Lukas): لینک ایمیل VOX را باز کرد ولی کارت «رمز جدید» نیامد، فقط صفحه‌ی اصلی.
> **علت (از کد gotrue 2.27.2):** جریان PKCE (`?code=`) کد-تأیید (code verifier) را از **همان حافظه‌ی مرورگری** می‌خواهد که «فراموشی رمز» در آن زده شد؛ اگر ایمیل لینک را در مرورگر دیگر/مرورگر داخلی/کنار اپ صفحه‌ی اصلی باز کند، verifier نیست ⇒ تبادل بی‌صدا شکست ⇒ اپ عادی باز می‌شود. (رویداد `passwordRecovery` خودش درست است: `ReplaySubject` دیر-مشترک‌ها را هم می‌رساند.)
> **راه ماندگار:** لینک با `token_hash` + `verifyOTP(type: recovery)` — به هیچ چیز روی دستگاه وابسته نیست. **کجا:** `auth_service.dart` (`verifyRecoveryToken`، تابع خالص `wiederherstellungsToken(Uri)`) · `profil_controller.dart` (starter: توکن از `Uri.base` ⇒ پاک‌کردن آدرس ⇒ تأیید ⇒ `passwortNeuProvider` یا `passwortLinkUngueltigProvider`) ·
> `core/utils/anmelde_adresse{,_io,_web}.dart` (حذف `?token_hash…` از نوار آدرس با `history.replaceState`) · `app.dart` (لینک نامعتبر ⇒ پروفایل) · `profil_screen.dart` (کارت «لینک معتبر نیست») · کلید `account_reset_link_invalid` · تست‌ها: `auth_service_test.dart` (+۲)، پاریته (+۱).
> **CI:** ✅ Zweig `passwort-link` (Lauf 35700227299) ⇒ `main`. مسیر قدیمی `?code=` هم سر جایش است (همان مرورگر ⇒ همچنان کار می‌کند).
> ⏭️ **نیاز از Lukas (بدون این، راه تازه فعال نمی‌شود):** Supabase → Authentication → **Emails** (Email Templates) → **Reset Password** ⇒ لینک به `{{ .RedirectTo }}?token_hash={{ .TokenHash }}&type=recovery` (Root-in «فراموشی رمز» ندارد ⇒ اثری روی آن ندارد). بعد دوباره تست.
>
> 🗓️ **جلسه‌ی قبل (دور ۵):** 2026-09-22 (دور ۵) — فقط PLAN/MAP، **اجرا نشد**: Lukas به ۴ سؤال R-2.2 جواب داد ⇒ ثبت در «R-2.2 — برنامه» → «تصمیم‌ها»:
> **بعد از انتشار · یکی‌یکی · کارت‌های Auswendiglernen هرگز حذف/کوتاه نمی‌شوند، فقط گسترش · یک کارت در دو جا مجاز اگر چیزی کم نشود (`sich bedanken für` ⇒ `verb_bedanken` با rektion) · عبارت‌ها ⇒ «کارت عبارت» با پرامپت دوم هم‌ساختار پرامپت کلمه و همان صفحه‌ی کلمه.**
>
> 🗓️ **جلسه‌ی قبل (دور ۴):** 2026-09-22 (دور ۴) — فقط ثبت: Lukas `supabase/vox_tables.sql` را در SQL Editor اجرا کرد ⇒ «Success. No rows returned» ✅ و گفت «تست موفق بود» ⇒ **L.1d روی سرور فعال** (`delete_own_account()` موجود).
> ⏭️ کار بعدی Lukas: Redirect URL `https://lukasylilli.github.io/vox/` در Supabase → Authentication → URL Configuration (راهنما در چت داده شد).
>
> 🗓️ **جلسه‌ی قبل (دور ۳):** 2026-09-22 (دور ۳) — **فقط PLAN/MAP، کدی عوض نشد.** Lukas: (۱) اجرای `vox_tables.sql` را نتوانست ⇒ راهنمای قدم‌به‌قدم در چت داده شد (هنوز انجام نشده) ·
> (۲) یافته‌های دور ۲ ثبت شوند ⇒ بخش «🔎 یافته‌ها 2026-09-22» زیر L.5 · (۳) **R-2.2 شروع نشود، فقط برنامه‌اش نوشته شود** ⇒ بخش «R-2.2 — برنامه» زیر R-2 (تصمیم Lukas: همه‌ی بخش‌های Auswendiglernen طبق پرامپت کلمه ساخته شوند و صفحه‌ی کلمه‌ی خودش را داشته باشند).
> ⏭️ **قدم بعدی:** R-2.2 **شروع نمی‌شود** تا Lukas بگوید (به L.4 / A.6 وابسته است). بدون‌نیاز-به-Lukas فعلاً چیزی نمانده؛ منتظر Lukas: اجرای `vox_tables.sql` · تست حذف حساب · Redirect URL · L.2d · L.3 · L.5a · L.5g ⛔⛔ · L.6.
>
> 🗓️ **جلسه‌ی قبل (دور ۲ همان روز):** 2026-09-22 (دور ۲) — Lukas: «Weiter». اول: Deploy دور ۱ روی main در **هر دو** ریپو ✅ سبز (VOX 35693974368 · Root-in 35694006854 + Gegenprobe 35694006903).
> هر چهار فایل تازه خوانده شد. بازبینی همه‌ی `- [ ]`ها ⇒ **بیشترِ R/B/G/16 قدیمی بودند و در کد انجام شده‌اند** (doc-drift؛ هر کدام در کد تأیید و علامت خورد، پایین).
> اولین قدم بازِ واقعی بدون‌نیاز-به-Lukas = **R-2.1 ✅**: فهرست «Nomen · Verb · Adjektiv + Präpositionen» حالا کلمه را **با حرف اضافه** نشان می‌دهد («abhängen · abhängig · die Abhängigkeit von»)؛ قبلاً فقط معنی + چیپ حرف اضافه بود.
> **کجا:** `praepositionen/models/praep_cluster.dart` (`vollform` — حرف اضافه‌ی مشترک یک‌بار در آخر؛ اگر فرق دارند هر کلمه با حرف اضافه‌ی خودش؛ بدون حدس) · `praepositionen_home_screen.dart` (`DeutschText(vollform)` + معنی زیرش؛ جست‌وجو حالا کلمه‌ی آلمانی را هم پیدا می‌کند) · تست `test/praep_vollform_test.dart` (۴؛ روی هر ۱۸۵ خوشه‌ی واقعی).
> **CI:** ✅ Zweig `r21-praep-vollform` (Lauf 35694624236) ⇒ `main`.
> ⏭️ ~~R-2.2 (دکمه‌ی صدا/لایتنر…)~~ ⇒ **اصلاح دور ۳:** R-2.2 طبق تصمیم Lukas از راه پرامپت کلمه انجام می‌شود و فعلاً فقط برنامه است (بخش R-2.2) · بقیه منتظر Lukas: L.2d · L.3 · L.5a · L.5g ⛔⛔ · L.6.
>
> 🗓️ **جلسه‌ی قبل (دور ۱ همان روز):** 2026-09-22 — Lukas: «حذف حساب را فعال کن» ⇒ **تصمیم L.1d = بله، برای هر دو اپ** (یک حساب، یک حذف). ✅ **L.1d ساخته و منتشر شد.**
> **چه:** دکمه‌ی «حذف حساب» در کارت حساب (`/more/profil`، زیر خروج). دیالوگ تأیید صریحاً می‌گوید پشتیبان/نمایه‌ی **Root-in** هم پاک می‌شود و داده‌ی روی دستگاه می‌ماند.
> **چرا:** تصمیم Lukas + حق حذف (GDPR). **کجا:** `supabase/vox_tables.sql` بخش ۵ `delete_own_account()` (**زنونویسی‌شده‌ی دقیق** Root-in، مثل `touch_updated_at()`) ·
> `core/services/auth_service.dart` (`AccountDeletion` + `deleteAccount()` دقیقاً از Root-in) · `core/backup/cloud_abgleich.dart` + `cloud_ablage_supabase.dart` (`CloudAblage.loeschen()` — فقط ردیف خود در `vox_backups`) ·
> `features/more/widgets/profil_konto_karte.dart` (`_kontoLoeschen`) · `core/l10n/app_l10n.dart` (۸ کلید `account_delete*`) · `privacy_policy_screen.dart` (بخش «حذف حساب»، تاریخ 2026-09-22) · تست: `test/konto_loeschen_test.dart` (۶) + `l10n_paritaet_test.dart` (+۸).
> **سه حالت:** سرور تابع را دارد ⇒ حساب + پشتیبان هر دو اپ (cascade) پاک، خروج · تابع روی سرور نیست (PGRST202) ⇒ فقط پشتیبان VOX پاک + خروج + پیام صادقانه «به ما پیام بده» · خطا/بی‌اینترنت ⇒ هیچ چیز پاک نمی‌شود.
> **Root-in:** فقط متن دیالوگ حذف (de/en/fa) اضافه شد که پشتیبان VOX هم پاک می‌شود — کد Root-in دست نخورد (ثبت در Root-in PLAN/MAP).
> **CI:** ✅ Zweig `l1d-konto-loeschen` (Lauf 35693624574: Analyze + Test + Web-Bau) ⇒ `main`.
> ⏭️ **نیاز از Lukas:** (۱) اگر `schema.sql` روی Supabase قبلاً اجرا شده، تابع آنجاست و کار می‌کند؛ برای اطمینان `supabase/vox_tables.sql` را یک‌بار دیگر در SQL Editor اجرا کن (idempotent) · (۲) یک بار با حساب آزمایشی دکمه را امتحان کن · (۳) Redirect URL (بالا) · (۴) PATها. بقیه‌ی قدم‌ها: L.2d · L.3 · L.5a · L.5g ⛔⛔ · L.6.
>
> 🗓️ **جلسه‌ی قبل:** 2026-09-20 (دور ۴) — Lukas: «طبق مپ و پلن اپ VOX را پیش ببر». هر چهار فایل تازه از GitHub خوانده شد. **Root-in:** همه‌ی قدم‌های باز به Lukas وابسته‌اند ⇒ کاری نبود. **VOX: L.5f ✅ ساخته شد** (اولین قدم بازِ بدون‌نیاز-به-Lukas؛ ورودی «⏳ در حال انجام» دور ۲ فقط یادداشت بود و هیچ کدی در ریپو نبود).
> **چه:** کلیک روی هر کلمه در همه‌جا یک رفتار دارد: کلمه ⇒ **پاپ‌آپ** ⇒ کلیک روی ردیف پاپ‌آپ ⇒ **صفحه‌ی کامل کلمه**. **چرا:** درخواست Lukas (L.5f) + اصل Component Isolation. **کجا:** فایل‌های جدید `core/wort/wort_form.dart` (کلید کلمه: بدون حدس صرف؛ `stripPreposition` به اینجا منتقل شد و `word_list_item.dart` آن را re-export می‌کند) · `core/wort/klick_wort.dart` (شکستن متن؛ هیچ حرفی گم/دوبل نمی‌شود) · `core/wort/klick_wort_provider.dart` (اول آرشیو `vocab_index.json`، فقط اگر خالی بود DB قدیمی؛ کلمه‌های هم‌شکل **همه** نشان داده می‌شوند، انتخابی حدس زده نمی‌شود) · `core/widgets/wort_popup.dart` (`showWortPopup`؛ ظاهر = همان `WortCard`+`WortActions` / `WordListItem`، نه طراحی تازه؛ بدون نتیجه ⇒ «در دیکشنری نیست» + دکمه‌ی «جستجو در همه واژه‌ها» با کلمه‌ی پرشده) · `core/widgets/klick_wort_text.dart` (`KlickWortText`، هم‌خانواده‌ی `DeutschText`: LTR ثابت، `markiert`، `auswaehlbar`، recognizerها آزاد می‌شوند). **وصل‌شده به:** Lesen (Leser) · Grammatik-Lektion (`b.bodyDe`، جمله‌ی مثال) · Redemittel-Detail (مثال و متن آلمانی) · Konnektor-Detail · Unregelm-Detail · Wort-Seite (`BeispielBlock`) · Hören (کلمه‌های Karaoke). **عمداً وصل نشد:** ردیف‌های لیست که خودشان کلیک‌پذیرند (تداخل کلیک)، کوییزها (جواب را لو می‌دهند)، عنوان‌ها. **حذف شد:** `lesen/widgets/clickable_word_text.dart` · `lesen/widgets/word_popup_card.dart` · `wordLookupProvider`.
> **CI:** ✅ Zweig `l5f-klick-wort` (Lauf 35514107519: Analyze + Test + Web-Bau؛ `test/klick_wort_test.dart` ۱۸ تست) — یک دور قرمز پیش از آن: `databaseProvider` فقط از `word_controller.dart` می‌آمد و با حذف import از `lesen_controller.dart` گم شد ⇒ import با `show databaseProvider` برگشت. سپس `main` (fast-forward، commit `56152ef`): ✅ **Deploy سبز** (Lauf 35514377341: Analyze + Test + Bau + Veröffentlichung).
> ⚠️ **کد بدون کامپایلر نوشته شد و در مرورگر دیده نشد** (Claude مرورگر ندارد) — بازبینی چشمی از Lukas لازم است: (۱) پاپ‌آپ روی موبایل/RTL · (۲) کلمه‌های جمله‌های مثال **علامت ندارند** (فقط در Leser زیرخط دارند: `markiert`) — آیا کاربر می‌فهمد که قابل‌کلیک‌اند؟ (تصمیم ظاهری برای Lukas) · (۳) کلیک کلمه در Karaoke هنگام پخش صدا.
> ⏭️ **قدم بعدی (آن روز):** همه منتظر Lukas (L.1d ✅ 2026-09-22 · L.2d · L.3 · L.5a · L.5g ⛔⛔ · درس بعدی کتاب L.6). بدون‌نیاز-به-Lukas چیزی نمانده؛ L.5b/L.5e/L.5c به تصمیم‌های L.5g/G7d وابسته‌اند.
>
> 🗓️ **جلسه‌ی قبل (دور ۳):** Lukas: سؤال درباره‌ی **برنامه‌ی هفتگی در Root-in** (عادت فقط سه‌شنبه‌ها / سه‌شنبه و پنجشنبه / سه بار در هفته). **VOX دست‌نخورده** — این ورودی فقط یادداشت است، هیچ فایل کدی در این ریپو عوض نشد. **Root-in:** «Phase 32 — Wochenplan» ساخته و روی `main` منتشر شد (schema 4→5، فرمت پشتیبان Root-in نسخه ۱→۲؛ analyze تمیز، ۲۷۹ تست سبز، Deploy سبز). برای VOX هیچ تغییری لازم نیست: VOX فقط در `vox_backups` می‌نویسد (نه `backups`/`profiles` از Root-in) و لینک «Routine» در `app_links.dart` همان است. جزئیات: `Root-in/PLAN.md` → Phase 32.
>
> 🗓️ **جلسه‌ی قبل (دور ۲):** 2026-09-20 (دور ۲) — Lukas: «طبق مپ و پلن ادامه بده». هر چهار فایل تازه از GitHub خوانده شد. **Root-in:** همه‌ی قدم‌های باز به Lukas وابسته‌اند ⇒ کاری نبود.
> **VOX:** L.1d · L.2d · L.3 (آفلاین/آیفون) · L.5a · L.5g ⛔⛔ منتظر Lukas یا «بعد از انتشار»اند؛ L.5d با فاز P عملاً انجام شده (فقط «سطح کاربر» نیست). ⇒ اولین قدم باز بدون‌نیاز-به-Lukas = **L.5f** (کلیک یکسان روی کلمه).
> ✅ **(دور ۲ ⏳ → تمام شد در دور ۴)** کامپوننت مشترک «کلیک روی کلمه» ساخته و وصل شد — جزئیات: «آخرین جلسه» بالا و L.5f.
>
> 🗓️ **جلسه‌ی قبل (دور ۱ همان روز):** 2026-09-20 — Lukas: «کاربر اکانت و اطلاعاتش را کجا وارد کند؟ صفحه‌ی اطلاعات کاربر با آرشیوها، اسم/آدرس‌ها/ایمیل/تلفن،
> رمز و تغییر رمز، اکسپورت/ایمپورت لایتنر و بقیه‌ی چیزهای یک اپ حرفه‌ای». ⇒ **فاز P ساخته شد** (تفصیل: بخش «فاز P — Profil & Konto»).
> صفحه‌ی `/more/profil` («پروفایل و حساب»): کارت حساب (ورود · ثبت‌نام · فراموشی رمز · تغییر ایمیل · همگام‌سازی · خروج · خروج از همه‌ی دستگاه‌ها)،
> کارت تغییر رمز، اطلاعات شخصی (نام · تلفن · تا ۵ آدرس، همه اختیاری)، آرشیو من (اعداد لایتنر/فهرست/یادداشت/کلمه‌ی خودم)، پشتیبان فایل.
> قرارداد پشتیبان **نسخه ۴** (`profil`). ✅ **CI grün** (2026-09-20, Lauf 35487912698 auf Zweig `profil-seite`: analyze + test + Web-Bau) — danach nach `main`. ⚠️ Noch **nicht im Browser gesehen** (Claude hat keinen): Ansicht/RTL/Dialoge bitte von Lukas anschauen.
> ⚠️ **یک چیز عمداً ساخته نشد:** «حذف حساب» (L.1d — تصمیم Lukas برای هر دو اپ). ⏭️ **نیاز از Lukas:** (۱) L.1d · (۲) در Supabase →
> Authentication → URL Configuration → Redirect URLs این آدرس ثبت شود: `https://lukasylilli.github.io/vox/` (وگرنه لینک ایمیل «فراموشی رمز» به Site URL می‌رود = احتمالاً Root-in) ·
> (۳) دو PAT در چت نوشته شده‌اند ⇒ revoke و عوض شوند.
>
> 🗓️ **جلسه‌ی قبل:** 2026-09-19 (دور چهارم) — Lukas: «طبق پلن و اولویتِ انتشار ادامه بده». اولین قدم بازِ بدون‌نیاز-به-Lukas = **پاک‌سازی doc-drift فاز ۱۶ ✅** (همه‌ی موارد iOS/Android/RevenueCat/store در PLAN و MAP با `[⛔]` علامت خورد؛ اول در کد تأیید شد که پوشه‌های بومی و هر ارجاع RevenueCat وجود ندارند). حین کار در کد پیدا شد: **مکانیزم «قبل از انتشار پنهان کن» بی‌اثر بود** (`hidden` را هیچ صفحه‌ای نمی‌خواند؛ کاشی‌های Sprechen/Schreiben فلگ را نمی‌خواندند) ⇒ درست شد + نگهبان `test/feature_flags_test.dart` (رفتار امروز عوض نشد؛ جزئیات و Audit هر ۹ مورد: L.2d). CI روی commit `986ff7fa`: Analyze ✅ Test ✅ Build ✅ Deploy ✅. شمارش کد: هر ۱۰ Wortart دست‌کم یک کارت دارد (شرط L.2b برای نمونه‌ها برقرار است). ⏭️ **قدم بعدی — همه منتظر Lukas؛ کاری از مسیر انتشار که فقط Claude انجام دهد نمانده:** (۱) L.2d: تصمیم برای ۹ مورد — پنهان / منبع / وصل‌کردن tempusformen به صفحه‌ی گرامر؛ Sprechen/Schreiben (stub روی صفحه‌ی اصلی) · (۲) L.5a–g قبل یا بعد از انتشارند؟ · (۳) L.1d حذف حساب · (۴) L.3: خروجی DevTools برای باگ آفلاین + تست آیفون واقعی · (۵) درس بعدیِ کتاب (L.6).
>
> 🗓️ **جلسه‌ی قبل‌تر (همان روز):** 2026-09-19 (دور سوم) — فقط ثبت، کدی تغییر نکرد: Lukas پرسید انتشار اپ «چند ماه دیگر» ممکن است؛ پاسخ باید طبق PLAN/MAP باشد نه حدس. **نتیجه: در هیچ‌یک از چهار فایل تاریخ یا تخمین زمانی برای انتشار نوشته نشده.** آنچه هست فهرست «دروازه‌ها»ست: L.1d (تصمیم حذف حساب، Lukas) · L.2d (deckهای «به‌زودی»: منبع از Lukas یا پنهان‌کردن با FeatureFlags) · L.3 (باگ آفلاین ⏸️ منتظر خروجی DevTools از Lukas؛ تست آیفون واقعی، Lukas) · L.6 (درس‌های کتاب یکی‌یکی؛ شمار درس‌های باقی‌مانده در پلن نیست) · پاک‌سازی doc-drift فاز ۱۶ (Claude). ⛔ **سؤال باز برای Lukas:** L.5a–L.5g قبل از انتشارند یا بعد؟ PLAN زمانش را نگفته (L.5g هم تصمیم‌های ⛔⛔ باز دارد). تنها اعداد زمانی PLAN مال **بعد از انتشار** (کلمه‌ها، A.6 ⛔) است. ✏️ همین جلسه یک اصلاح: یادداشت «آفلاین» در L.3 گفته بود ادعای «۱۰۰MB» باطل شد — فقط برای ۷٫۵MB امروز درست است، با ~۲۶٬۲۰۰ کارت دوباره ~۱۰۰MB می‌شود (اصلاح در همان بند L.3).
>
> 🗓️ **جلسه‌ی قبل‌تر (همان روز):** 2026-09-19 — فقط مستندسازی: Lukas پرسید آیا ساختار «سطح‌بندی + ترجمه‌ی زیر متن + پاپ‌آپ کلمه + تمرین» برای Lesen/اخبار نوشته شده. **نیمه‌نوشته بود** (L.5b ترجمه، L.5e آزمون، L.5f پاپ‌آپ)؛ سطح A1–C2 برای اخبار، کلمات مهم، نکات گرامری و تقسیم «خودکار / دست‌ساز» نبود ⇒ **L.5g** ثبت شد + دو سؤال باز (منبع سطح اخبار، سرویس ترجمه). کدی تغییر نکرد. **دور دوم (همان روز):** Lukas تأکید کرد تقسیم «قابلیت‌های همه‌ی متن‌ها / متن‌های آماده» تصمیم مهمی است و باید بعداً با خودش گرفته شود — در L.5g با ⛔⛔ ثبت شد (تعداد، منبع، قابلیت‌های هر گروه).
>
> 🗓️ **جلسه‌ی قبل:** 2026-09-18 (ادامه ۴) — گزارش دو باگ از Lukas پس از تست دستی:
> **(الف) RTL/آلمانی ✅ رفع و توسط Lukas تأیید شد** — با locale=fa کل اپ RTL می‌شد و متن آلمانی هم آن را ارث
> می‌برد (خط به لبه‌ی راست، نقطه در سمت چپ). ویجت مشترک `DeutschText` ساخته شد (ltr + left ثابت) +
> `test/deutsch_text_test.dart`، و در همه‌ی صفحه‌های آلمانی‌نما اعمال شد. دور دوم لازم شد چون پاراگراف
> توضیح درس گرامر (`b.bodyDe`) جا افتاده بود — Lukas دقیق گزارش داد، رفع و تأیید شد.
> **(ب) آفلاین ⏸️ بلوکه** — SW یا ثبت نمی‌شود یا `assets/` را نگه نمی‌دارد؛ Claude مرورگر ندارد و Lukas فعلاً
> به کامپیوتر دسترسی ندارد ⇒ منتظر خروجی DevTools. نکته‌ی مهم: حجم کل assets فقط ۷٫۵MB است، پس ادعای قدیمیِ
> «۱۰۰MB، precache ممکن نیست» باطل شد.
> ⏭️ **قدم بعدی:** (۱) باگ آفلاین — منتظر خروجی DevTools از Lukas · (۲) درس بعدی کتاب / منبع deck بعدی
> از Lukas · (۳) L.1d تصمیم حذف حساب از Lukas · (۴) ~~پاک‌سازی doc-drift فاز ۱۶ (iOS/Android/RevenueCat)~~ ✅ 2026-09-19.
>
> 🆕 **اولویت‌بندی «قبل از انتشار» (درخواست Lukas، 2026-09-18):** معیار = کاری که **بعد از انتشار دیگر
> نمی‌شود انجام داد**. تحلیل Claude: این دسته تقریباً همیشه یعنی **شناسه‌هایی که داده‌ی کاربر به آن‌ها
> اشاره می‌کند** — چون بعد از انتشار، عوض‌کردنشان یعنی از دست رفتن پیشرفت کاربر.
> وضعیت این دسته: کارت‌های آرشیو ✅ L.1a · مهاجرت پایگاه‌داده ✅ L.1b · لیست‌های شخصی ✅ S.6 ·
> قرارداد پشتیبان ✅ S.5 · **کلمه‌های همراه اپ ⇒ شکاف بود، با L.1e بسته شد (2026-09-18).**
> **باگ RTL کاملاً بسته شد** (ویجت + دکمه + جاروی ۱۴ جای باقی‌مانده + نگهبان CI).
> 🆕 **اصل معماری تازه از Lukas (2026-09-18): «یک محتوا، چند ورودی»** — هر تمرین/کلمه/عبارت یک‌بار
> ساخته می‌شود و از چند در دیده می‌شود (مثلاً تمرین گرامر: یک‌بار بعد از درس، یک‌بار در Prüfungen با
> دسته‌بندی سطح/موضوع/هفت مهارت). ثبت شد به‌عنوان اصل پایه + کار باز **A-1** (Audit کل اپ، کار مشترک
> Lukas و Claude). ✅ فهرست هفت مهارت از Lukas گرفته شد: کلمه · گرامر · چیزهای حفظی · نوشتن · خواندن ·
> شنیدن · حرف زدن (جدول کامل با زیرشاخه‌ها در بخش اصل).
>
> 🗓️ **جلسه‌ی پیش‌تر:** 2026-09-18 (ادامه ۲) — منبع **ÖSD C1** از Lukas رسید (PDF) → `redemittel_oesd_c1.json`
> با ۱۱۲ عبارت (Schreiben Aufgabe 1/2 + Sprechen Aufgabe 1/2/3) ساخته و به‌عنوان deck زنده وصل شد (route،
> feature-flag، content_registry) ⇒ **L.2a بسته شد.** درس ۲ کتاب «Grammatik Aktiv» (صرف فعل در زمان حال —
> استثناهای پایانه‌ی فعل: arbeiten-نوع با -e- اضافه، heißen/tanzen-نوع فقط -t) به‌عنوان بلوک دوم به درس
> `konjugation-praesens` اضافه شد (۱ توضیح، ۱ جدول، ۲ مثال، ۳ تمرین تازه) — نه کپی از کتاب، نوشته‌ی نو.
> Secrets پروژه‌ی Supabase (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) — تلاش Claude برای ثبت خودکار شکست خورد (هر
> دو PAT بدون دسترسی «Secrets»، 403) ⇒ Lukas خودش این دو Secret را در Settings → Actions ثبت کرد و
> `supabase/vox_tables.sql` را در SQL Editor سایت Supabase اجرا کرد (2026-09-18). **L.1c ✅ بسته شد.**

> ⚠️ **2026-09-13 — Umbau zur reinen Web-App:** android/ios/macos/linux/windows, RevenueCat (Abos) und lokale Notifications wurden entfernt. VOX läuft nur noch als kostenlose Flutter-Web-App auf GitHub Pages (DB: drift + SQLite-WASM). Ältere Einträge unten beschreiben teils den früheren nativen Stand.
> ⚠️ **2026-09-13 — Habit/Routine entfernt, Root-in-Verlinkung.** VOX bleibt dauerhaft ein eigenes Repo (`github.com/lukasylilli/vox`), getrennt von Root-in (`github.com/lukasylilli/Root-in`, live unter `lukasylilli.github.io/Root-in/`) — bewusst KEIN Code-Merge, damit Nutzer, die nur die Routine-App brauchen, sie eigenständig nutzen können. In Selbstlernen ersetzt die Karte **„Routine"** die frühere „Habit Maker"-Karte und öffnet Root-in per Link in einem neuen Tab (`core/constants/app_links.dart` → `rootInUrl`, geöffnet über `core/utils/external_link_opener.dart`). Entfernt: `habit_maker_screen.dart`, `habit_stats_screen.dart`, `habit_day_selector_widget.dart`, `streak_chart_widget.dart`, `core/database/dao/habit_dao.dart`, alle Habit-Provider in `selbstlernen_controller.dart` und die „verknüpfte Gewohnheit"-Auswahl im Pomodoro-Timer (Pomodoro selbst bleibt unverändert als eigenständiger Fokus-Timer). Die Drift-Tabellen `Habits`/`HabitSessions` bleiben vorerst im Schema (kein Downgrade) — unbenutzt, entfernbar in einer künftigen Migration. ⚠️ **Lehre:** `package:web` darf nie ungeschützt importiert werden — bricht `flutter test` auf der VM, `flutter analyze` merkt es nicht. Bedingter Export nach Root-in-Vorbild (`external_link_opener_io.dart` / `_web.dart`).
> ⚠️ **2026-09-15 — Voll-Audit von Code + Daten (Claude, direkt über die GitHub-API).** Befunde, die die Planung ändern:
> **(1) Die `✓ `-Markierungen in `old files Lukasalmani/Wörter/*.txt` sind NICHT mehr die Wahrheit.** Gezählt: `assets/vocab/` enthält **87 Karten** (alle `schema: "3.0"`, kein kaputtes JSON) — davon **76 Verben**; markiert ist aber nur `✓ warten` (+ 3 Adjektive, 1 Nomen). 45 dieser Verbkarten stehen unmarkiert in den txt-Listen, 31 stehen dort gar nicht (sie stammen aus dem Dativ/Akkusativ-Deck, nicht aus dem alphabetischen Backlog). ⇒ **Neue Regel: einzige Wahrheit ist `assets/vocab/`; die `✓ `-Marken werden daraus abgeleitet (Sync-Skript), nicht mehr von Hand gesetzt.**
> **(2) Harte Obergrenze im Laufzeit-Pfad gefunden.** `lib/features/vokabular/controllers/vokabular_controller.dart` lädt beim Start **jede** Datei aus `assets/vocab/` über den `AssetManifest` und dekodiert sie vollständig in den Speicher. Bei 87 Karten unauffällig, bei einigen Tausend startet die Web-App nicht mehr sinnvoll. ⇒ **V.2 (`vocab.db`) ist keine „später"-Aufgabe mehr, sondern die Voraussetzung für die Automatisierung** (siehe فاز A). → ✅ **Gelöst durch V.2 (2026-09-16):** Die App lädt beim Start nur noch EINEN Wortindex, die volle Karte erst beim Öffnen.
> **(3) Doku-Drift korrigiert:** B-3 / R-1.1 sind im Code längst erledigt (`stripPreposition()` in `word_list_item.dart`) und werden hier auf ✅ gesetzt. Die README nannte unter „Selbstlernen" noch „Gewohnheiten, Streaks" — seit 2026-09-13 falsch (Habit entfernt, Root-in-Link). ✅ **Behoben (2026-09-18):** README-Zeile auf Pomodoro/Lernpfad/Vorlagen + Root-in-Link umgestellt.
> **(4) Entscheidung des Nutzers 2026-09-15:** Die Wörter werden **weiter alphabetisch** abgearbeitet (nicht nach Häufigkeit sortiert) — der Durchsatz kommt aus der Automatisierung, nicht aus der Reihenfolge.

# پلن کامل صفر تا انتشار اپ یادگیری آلمانی برای فارسی‌زبانان
# آپدیت: 2026-09-18

---

## 🎯 وضعیت فعلی (2026-09-15)
| فاز | وضعیت | خلاصه |
|-----|-------|-------|
| **G — Grammatik Vollausbau** | G1–G6 ✅ · G7a–G7c ✅ / G7d، G7e، G8 باز | کاتالوگ ۹۳ موضوع + LektionScreen live (**۸۴ درس**، 2026-09-16)؛ نقشه: `GRAMMATIK_MAP.md` |
| **B — Buttons (Puzzling)** | ✅ | همه دکمه‌ها reference به `vox_button.dart`؛ ۰ دکمه خام؛ همه quiz options → VoxOptionButton |
| **L — L10n: زبان فقط از Settings** | ✅ | ۶ سوییچ حذف، Dual-Display صفر، AppL10n تنها منبع |
| **L2 — Massen-Lokalisierung** | ✅ | ۶۴۱→۴۱ رشته FA در UI (کاتالوگ ۵۳۷=۵۳۷)؛ باقی در L3 |
| **L3 — Content-Zweisprachigkeit** | ✅ | **همه محتواها FA+EN** (JSON + صفحات + دیتابیس)؛ audit ۰؛ کاتالوگ ۵۶۵=۵۶۵؛ helper AppL10n.loc؛ MemorizeItems.meaningEn (schema v2) |
| **P — Profil & Konto** | ✅ P.1–P.3 (2026-09-20، CI سبز) — بازبینی چشمی از Lukas مانده | صفحه‌ی `/more/profil`: حساب + امنیت + اطلاعات شخصی + آرشیو + پشتیبان؛ قرارداد v4؛ **حذف حساب ✅ L.1d (2026-09-22)** |
| **V — Vokabular-DB (۲۵٬۰۰۰ کلمه)** | Stufen ۱–۵ ✅ · **۸۷ کارت** (۰٫۳٪ از ~۲۶٬۲۰۰) · گلوگاه = سرعت، نه کد | Pipeline کامل و سالم: SUPER-PROMPT v3.0 → `import_inbox/` → `tool/vokabular_import.dart` → اپ. از ۱۴ جولای تا ۱۵ سپتامبر (۲ ماه) فقط چند کلمه اضافه شد ⇒ **فاز A (خودکارسازی) باز شد.** V.2 ✅ (فهرست کلمات به‌جای vocab.db، 2026-09-16) · باز: · اتصال Leitner به imLeitner · V.5 توزیع |
| ~~۱۶ — انتشار و QA نهایی~~ | ⛔ منسوخ — فهرست معتبر: **L.3** | نسخه‌ی بومی (iOS/Android/RevenueCat) از 2026-09-13 حذف شد؛ انتشار = فقط وب (GitHub Pages) |

**2026-09-18:** L.6 شروع شد — Lukas درس‌های گرامر کتاب‌هایش را **یکی‌یکی** می‌فرستد. درس ۱ «Grammatik aktiv» (Personalpronomen) رسید و در درس `personalpronomen` اپ جا گرفت: ۲ توضیح تازه، ۲ جدول، ۴ مثال و ۶ تمرین — همه **از نو نوشته‌شده** (کپی‌رایت). فهرست کامل «کدام درس Lukas ↔ کدام درس اپ»: پایین‌تر در L.6 و در `GRAMMATIK_MAP.md`.
**2026-09-18:** تصمیم‌های Lukas (پاسخ به سه سؤال Claude): ① تمرین‌های باقی‌مانده (**G7d/G7e**) **بعد از انتشار** — این تصمیم جای تصمیم ۲۰۲۶-۰۹-۱۶ («تمرین‌ها قبل از انتشار») را می‌گیرد؛ G7a–G7c که آماده شده‌اند می‌مانند. ② کلمه‌های A1/A2 جزوه‌ها: مثل قبل جزو **L.4** (بدون تغییر). ③ deckهای «به‌زودی»: Lukas منبعشان را می‌فرستد؛ Claude هر بار فقط **یک** منبع می‌خواهد — درخواست اول (۲۰۲۶-۰۹-۱۸): **ÖSD C1**.
**2026-09-16:** G7c ✅ هر نوبت تمرین درس حالا ۱۰ تمرین مخلوط است: ۴ تمرین منبع + ۶ تمرین تازه از جمله‌های مثال (معنی، انتخاب جمله، درست/غلط، وصل کردن، چیدن کلمه‌ها) — هر بار نوعشان تصادفی.
**2026-09-16:** G7b ✅ آزمون سطح: بالای صفحه‌ی هر سطح (A1…C2) کارت «آزمون سطح» — ۱۰ سؤال تصادفی از درس‌های همان سطح، قبولی از ۷۰٪.
**2026-09-16:** G7a ✅ تمرین‌ها: هر درس گرامر حالا دکمه‌ی «تمرین این درس» دارد — ۳۳۶ تمرین منبع (۵ نوع)، یکی‌یکی با جواب و توضیح، در آخر نتیجه.
**2026-09-16:** L.3a ✅ زبان شروع = انگلیسی، مگر دستگاه فارسی باشد.
**2026-09-16:** L.2c ✅ گرامر: هر ۸۴ درس اصلی زنده‌اند (G3–G6) — منبع برخلاف یادداشت قبلی کامل بود؛ بدون تغییر محتوا وارد شد. یک خطای نمایش جدول در درس‌های sein/haben هم رفع شد.
**2026-09-16:** L.1b ✅ آزمون به‌روزرسانی: هر نسخه‌ی منتشرشده‌ی پایگاه‌داده (۲ تا ۶) با داده‌ی واقعی لایتنر به نسخه‌ی ۷ رسانده و بررسی می‌شود — ساختار دقیقاً مثل نصب تازه، لایتنر/لیست‌ها سالم. آزمون عمدی خراب ⇒ قرمز شد.
**2026-09-16:** L.1a ✅ نگهبان شناسه‌ها: اگر شناسه‌ی کارتی که روی سایت منتشر شده حذف یا عوض شود، ساخت قرمز می‌شود و چیزی منتشر نمی‌شود (با حذف آزمایشی یک کارت روی شاخه‌ی جدا ثابت شد).
**2026-09-16:** V.2 ✅ اپ هنگام شروع دیگر همه‌ی کارت‌ها را نمی‌خواند — فقط یک فهرست کوچک (`assets/vocab_index.json`)؛ کارت کامل فقط وقتی صفحه‌ی آن کلمه باز شود. سقف ~۵۰۰ کارت برداشته شد.
**2026-09-16:** S.6 ✅ لیست‌های شخصی شناسه‌ی ثابت دارند — تغییر نام دیگر کلمه‌ای را در همگام‌سازی از بین نمی‌برد (پایگاه داده نسخه‌ی ۷، قرارداد پشتیبان نسخه‌ی ۳).

**قدم‌های بعدی (2026-09-16, ترتیب جدید — بخش «فاز LAUNCH»):** ① **L.1** امنیت لایتنر: S.6 ✅ → V.2 ✅ → L.1a ✅ → L.1b ✅ → L.1c ✅ (2026-09-18, Supabase-Secrets + SQL) → L.1d ✅ (2026-09-22, حذف حساب برای هر دو اپ) ⇒ **L.1 کامل** ② **L.2** کامل بودن محتوا: G3–G6 ✅ · G7a–G7c ✅ · **G7d/G7e رفت بعد از انتشار** · L.2a ÖSD C1 ✅ (2026-09-18) ⇒ تنها کار باز = deckهای «به‌زودی» دیگر که منتظر منبع Lukas‌اند ③ **L.6** درس‌های کتاب Lukas (یکی‌یکی؛ رسیده: درس ۱ و ۲) ④ **L.3 آماده‌سازی انتشار** ← **انتشار** ④ **L.4** کلمه‌ها روزانه (A.6 ⛔ اول از Lukas بپرس)

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
      «لیست قدیم حذف، لیست جدید ساخته» نیست؛ کلمه‌ای که دستگاه دیگر در همان فاصله در لیست گذاشته
      حفظ می‌شود. لیست‌های قبلی شناسه‌ی قبلی‌شان (`eigen:<نام>`) را نگه می‌دارند. جزئیات: فاز S → S.6.
- [x] **V.2 ✅ (2026-09-16, CI سبز روی شاخه + ساخت وب) — به شکل «فهرست کلمات»، نه `vocab.db`.**
      اپ در شروع فقط `assets/vocab_index.json` را می‌خواند؛ کارت کامل فقط هنگام باز کردن صفحه‌ی کلمه.
      داده‌ی کلمه‌ها کاملاً از داده‌ی کاربر **جدا** ماند: فهرست هیچ لایتنر/لیستی ندارد و به جدول‌های
      کاربر (`ArchivLeitner`, `Mitgliedschaften`, …) دست نمی‌زند. جزئیات و دلیل تغییر شکل: فاز V → V.2.
      ~~V.2 `vocab.db` — حالا پیش‌شرط انتشار. چون بعد از انتشار کلمه‌ها روزانه زیاد می‌شوند و
      `vokabular_controller` در startup همه‌ی کارت‌ها را می‌خواند (سقف ~۵۰۰).~~
- [x] **L.1a قاعده + نگهبان CI: شناسه‌ی کارت منتشرشده هرگز حذف یا عوض نمی‌شود.** ✅ (2026-09-16) لایتنر کارت‌های
      آرشیو را با شناسه‌ی متنی (`adjektiv_stolz`) نگه می‌دارد؛ حذف/تغییر نام = کارت یتیم در لایتنر کاربر.
      ~~یک بررسی در CI که اگر شناسه‌ای نسبت به `main` ناپدید شد، قرمز شود.~~
      **Umgesetzt — Vergleich mit der LIVE-Seite, nicht mit `main`:** Ein roter Lauf veröffentlicht nichts; ein
      Vergleich mit „dem vorigen Commit" ließe deshalb den NÄCHSTEN Push die Löschung schon als Ausgangslage sehen
      und durchlassen. Die Live-Seite ist genau das, was Nutzer haben.
      · `deploy-web.yml` + `pruefen.yml`: neuer Schritt direkt nach „Wortindex bauen" — lädt
        `https://lukasylilli.github.io/vox/assets/assets/vocab_index.json` und ruft
        `dart run tool/vokab_ids_pruefen.dart` auf. Fehlt eine veröffentlichte id ⇒ rot, alles danach
        (Analyze/Test/Bau/Veröffentlichung) wird übersprungen. Neue ids sind immer erlaubt.
      · Seite nicht abrufbar (HTTP ≠ 200) ⇒ ebenfalls rot. **Einziger Ausweg:** „Run workflow" von Hand mit
        `ohne_id_waechter` — nur bewusst, z. B. wenn die Seite ganz weg ist. Ein Push kann das nie.
      · Der veröffentlichte Index wird **ohne Fassungsprüfung** gelesen (er darf älter sein); ist er gar kein
        Index, ist das ein Fehler — nie „nichts veröffentlicht, alles erlaubt".
      · `set -o pipefail` im Schritt: ohne das verschluckt `| tee` den roten Ausgang (Standard-Shell ist
        `bash -e` ohne pipefail).
      · Dateien: `vokab_index.dart` (`vokabIndexIds`, `vokabVerloreneIds`) · `tool/vokab_ids_pruefen.dart` ·
        Test `test/vokab_ids_waechter_test.dart` (4 Fälle).
      · **Gegenprobe:** auf einem Wegwerf-Zweig `adjektiv_aalartig.json` gelöscht ⇒ Lauf rot genau im
        Wächter-Schritt, Analyze/Test/Bau übersprungen; Zweig danach gelöscht.
      ⚠️ **Keine Ausnahmeliste, mit Absicht.** Muss eine Karte je wirklich weg (z. B. doppelt/falsch), braucht es
      vorher eine Umzugsregel für Leitner, Listen und Notizen der Nutzer (alte id → neue id) — eine Entscheidung
      mit Lukas, kein Handgriff. Eine fehlerhafte Karte wird **korrigiert**, nicht gelöscht; ihre id bleibt.
- [x] **L.1b تست مهاجرت** ✅ (2026-09-16): از هر `schemaVersion` قدیمی به نسخه‌ی فعلی، بدون از دست رفتن لایتنر.
      **Umgesetzt mit drifts eigenem Werkzeug (SchemaVerifier), nicht mit einer Nachbildung:**
      · **Echte alte Schemata:** `build-runner.yml` holt je Fassung den LETZTEN Commit, in dem
        `app_database.dart` diese `schemaVersion` trägt, legt dafür einen eigenen Arbeitsbaum an und führt
        `drift_dev schema dump` aus ⇒ `drift_schemas/drift_schema_v2…v7.json`; daraus
        `drift_dev schema generate` ⇒ `test/generated_migrations/`. Bei **jedem** Lauf alle neu — kein
        Abzug kann veralten. Ab jetzt entsteht der Abzug einer neuen Fassung automatisch mit.
      · **Fassung 1 gibt es nicht:** Die Geschichte dieses Repos beginnt am 2026-09-13 mit Fassung 2 (erste
        Web-Veröffentlichung, `ERSTE_FASSUNG` im Workflow). Kein Web-Nutzer kann Fassung 1 haben.
      · `test/migration_test.dart`: je Fassung 2…6 eine Datenbank im alten Schema anlegen, Nutzerdaten
        hineinschreiben (eigenes Wort mit Leitner-Fach 4 + Termin, eigene Liste; ab 3 Archiv-Leitner Fach 5;
        ab 4 Archiv-Liste; ab 6 Ereignis) ⇒ mit der App öffnen ⇒ `migrateAndValidate` (Tabellen, Spalten,
        Einschränkungen, Indizes **genau** wie bei einer frischen Installation; auch nichts Überzähliges) ⇒
        über `UserStateRepository.lesen()` prüfen, dass Fächer, Termine, Listen (mit ihrer alten id) und
        Ereignisse noch da sind. Dazu: frische Installation = was der Code erwartet; für jede Fassung ab 2
        gibt es einen Abzug (neue `schemaVersion` ohne Abzug ⇒ rot).
      · **Dabei korrigiert:** Der eindeutige Index `user_categories_uid` (S.6) war rohes SQL und damit für drift
        unsichtbar — jetzt `@TableIndex` an `UserCategories`, angelegt über `createAll` bzw. `m.createIndex`.
        Name und Definition unverändert ⇒ Datenbanken der Fassung 7 haben ihn schon, **keine** neue Fassung.
      · **Gegenprobe:** auf einem Wegwerf-Zweig `m.addColumn(words, words.ausApp)` aus der Migration entfernt ⇒
        genau 4 Tests rot (Fassung 2–5; 6 hatte die Spalte schon), Meldung „words: aus_app — the actual schema
        does not contain anything with this name". Zweig gelöscht.
      · **Fehlertexte sind jetzt lesbar:** `tool/ci_fehler_melden.sh` schreibt den Fehlertext roter Schritte als
        GitHub-Annotation (in `build-runner.yml` und `pruefen.yml`); Claude liest sie über
        `api.github.com/…/check-runs/<job>/annotations`. Die Gegenprobe oben wurde genau so gelesen.
        (`deploy-web.yml` hat das noch nicht — dort wird nur veröffentlicht, was vorher auf einem Zweig grün war.)
      ⚠️ **Regel ab jetzt:** Jede Schema-Änderung ⇒ `schemaVersion` erhöhen + Migration schreiben + `build-runner.yml`
      auf dem Zweig laufen lassen. Der Migrationstest deckt die neue Fassung dann von selbst ab.
- [x] **L.1c (Lukas)** Secrets `SUPABASE_URL`/`SUPABASE_ANON_KEY` در ریپوی vox + اجرای یک‌باره‌ی
      `supabase/vox_tables.sql` — بدون این‌ها کپی خودکار در حساب وجود ندارد (فقط مرورگر + فایل پشتیبان).
      ⚠️ **تلاش Claude (2026-09-18) ناموفق بود:** هر دو توکن PAT موجود دسترسی «Secrets» ندارند
      (`GET .../actions/secrets/public-key` → 403 Resource not accessible). ✅ **Lukas خودش انجام داد
      (2026-09-18):** هر دو Secret در Settings → Actions ثبت شد + `vox_tables.sql` در SQL Editor سایت
      Supabase اجرا شد (project ref `uayaomoxxzzbjquxbcpu`).
- [x] **L.1d حذف حساب** ✅ 2026-09-22 — تصمیم Lukas: **بله، برای هر دو اپ** (یک حساب مشترک ⇒ یک حذف). `delete_own_account()` در `vox_tables.sql` (هم‌متن Root-in) + `AuthService.deleteAccount()` + دکمه در `ProfilKontoKarte` + fallback `CloudAblage.loeschen()`. S.3 بسته شد. جزئیات: «آخرین جلسه» بالا و بخش فاز P.
- [x] **L.1e نگهبان شناسه‌ی کلمه‌های همراه اپ** ✅ (2026-09-18، Claude، CI سبز روی شاخه سپس main)
      **شکافی که پیدا شد (اولویت‌بندی «قبل از انتشار»، 2026-09-18):** لایتنر کاربر با شناسه‌ی متنی ذخیره
      می‌شود، نه شماره‌ی ردیف پایگاه‌داده (`core/backup/nutzer_zustand.dart`). برای کارت‌های آرشیو
      (`assets/vocab/`) **L.1a** نگهبانی می‌کند. ولی ~۱٬۰۱۶ کلمه‌ی همراه اپ که از چهار فایل
      `assets/data/*.json` در جدول `Words` کاشته می‌شوند شناسه‌شان `<german>|<wordType>` است و **هیچ
      نگهبانی نداشت**. یعنی: یک اصلاح تایپی در `verb_infinitive`، یک فاصله‌ی اضافه در `phrase_de`، یا
      عوض‌شدن `word_class` ⇒ شناسه عوض می‌شود ⇒ پیشرفت لایتنر کاربر روی آن کلمه **یتیم** می‌شود.
      **چرا دقیقاً «قبل از انتشار»:** تا کاربری نداریم، هزینه‌اش صفر است. بعد از انتشار، برای هر تغییر
      باید قاعده‌ی کوچ (شناسه‌ی قدیم → جدید) نوشته و روی همه‌ی دستگاه‌ها اجرا شود — همان چیزی که Lukas
      به‌عنوان «شرط سخت» گذاشته: داده‌ی لایتنر نباید با آپدیت اپ در خطر باشد.
      **پیاده‌سازی:**
      · `lib/core/services/seed_wortschluessel.dart` — **تنها منبع** استخراج `<german>|<wordType>` از
        آن چهار فایل. `data_seed_service.dart` حالا `mapWordClass` را از همین‌جا می‌گیرد تا دو فرمول
        هرگز از هم جدا نشوند (قبلاً کپی محلی داشت).
      · `test/daten/seed_schluessel_veroeffentlicht.txt` — **۱٬۰۱۶ شناسه‌ی** محافظت‌شده.
      · `test/seed_wortschluessel_test.dart` — اگر شناسه‌ای از آن فهرست دیگر ساخته نشود **CI قرمز**
        می‌شود و می‌گوید کدام‌ها. ۹ تست: شکل شناسه = شکل `LeitnerStand.wortSchluessel`، پوشش
        `mapWordClass`، سلامت هر چهار فایل، و سه حالت گم‌شدن (تایپ، فاصله، عوض‌شدن wordType).
      · `tool/seed_schluessel_schreiben.dart` — ثبت کلمه‌های **تازه** در فهرست. عمداً **امتناع می‌کند**
        اگر شناسه‌ای قرار باشد حذف شود، تا کسی نتواند با آن نگهبانِ قرمز را «خاموش» کند.
      ⚠️ **محدودیتی که دیده شد:** هر دو توکن PAT اجازه‌ی تغییر `.github/workflows/` ندارند (403). طرح اول
      مثل L.1a بود (مقایسه با سایت زنده در workflow)؛ چون نشد، نگهبان داخل **خود تست‌ها** ساخته شد — که
      اتفاقاً وابستگی کمتری دارد (بدون شبکه) و CI از قبل `flutter test` را اجرا می‌کند. فهرست فقط با
      تصمیم صریح عوض می‌شود، نه خودکار با هر push.

### L.2 — کامل بودن محتوا (Audit 2026-09-16، Claude، شمارش مستقیم منبع ↔ اپ)
> **Lukas 2026-09-16:** «منابع همه‌چیز با من است، برنامه‌نویسی با تو.» ⇒ برای هر مورد باز پایین (گرامر، ÖSD C1، deckها و …)، وقتی نوبتش رسید **منبع را از Lukas بخواه** (هر قالبی: Excel، CSV، JSON، Word، PDF) — نه حدس. ⚠️ **استثنا: کارت‌های کلمه** — آن‌ها را Claude طبق پرامپت می‌سازد (فاز A / A.6).
- ✅ **کامل نسبت به منبع** (`old files Lukasalmani/1/` ↔ `assets/data/`):
      Redemittel 1010 **۹۰۸/۹۰۸** (منبع خودش ۹۰۸ عبارت دارد، نه ۱۰۱۰؛ ۹۳ بخش) · Goethe B2 ۶۱/۶۱ ·
      ÖSD B2 ۱۲۱/۱۲۱ · Konnektoren ۱۸۶/۱۸۶ · NVV ۳۴۶/۳۴۶ · Präpositionen ۱۸۵/۱۸۵ · Dativ/Akkusativ ۱۱۰/۱۱۰
- [x] **L.2a ÖSD C1:** ✅ (2026-09-18) منبع از Lukas رسید (PDF «Prüfungstraining C1»)؛ `redemittel_oesd_c1.json`
      با **۱۱۲ عبارت** ساخته شد (Schreiben Aufgabe 1 Antwortbrief، Aufgabe 2 Referat/Stellungnahme، Gute-Texte-
      Redemittel، Sprechen Aufgabe 1/2/3) — دسته‌بندی بر اساس بخش‌های منبع؛ ترجمه‌ی EN چون منبع نداشت توسط
      Claude اضافه شد. وصل شد: `AppRoutes.redemittelOesdC1` + route در `app_router.dart` (کپی دقیق از الگوی
      ÖSD B2) + `feature_flags.dart` → `deck.oesd_c1` از `comingSoon` به `live` + `content_registry.dart`
      (route + itemCount) + کلید l10n جدید `deck_oesd_c1_sub` (FA+EN). ~~در اپ فقط **۶** عبارت...~~
- [x] **L.2b — تصمیم Lukas (2026-09-16):** این کلمه‌ها جزو **فاز کلمه‌ها (L.4)** هستند، مثل بقیه — فرقی ندارد.
      قبل از انتشار حداکثر **چند کارت نمونه** از سطوح و نوع‌های مختلف (اسم، فعل، …) تا هر نوع نمایشی یک نمونه داشته باشد
      (طبق پرامپت کلمه؛ روشش A.6 است).
      ~~**L.2b A1/A2 Wortschatz از جزوه‌ها:** `a1_wortschatz.json` (۷۳۹) + `a2_wortschatz.json` (۳۲۴) =
      **۱٬۰۶۳ کلمه** در `old files Lukasalmani/1/` — **هیچ‌جای اپ استفاده نشده‌اند.** ⇒ **از Lukas بپرس:**
      قبل از انتشار وارد شوند یا جزو مرحله‌ی کلمه‌ها (L.4)؟~~
- [x] **L.2c گرامر** ✅ (2026-09-16): ~~فقط ۴ از ۸۴ درس live ⇒ G3–G6 قبل از انتشار~~ ⇒ **هر ۸۴ درس live** (فاز G → G3–G6؛
      جزئیات کامل: `GRAMMATIK_MAP.md` → Änderungsprotokoll 2026-09-16). تمرین‌ها (G7) هنوز باز است — تصمیم با Lukas
      که قبل از انتشار لازم است یا بعد.
      🔁 **بازبینی مستقل (2026-09-16، جلسه‌ی بعد، بدون تغییر کد):** منبع دوباره از صفر تجزیه شد ⇒ ۱۷ سند درس
      (۸۴ درس، ۸۴ slug یکتا، ۳۳۶ تمرین؛ فهرست `_index` هر سند دقیقاً = درس‌هایش؛ هر `exerciseSlugs` تمرینش را دارد)
      + ۲ سند «پیکربندی آزمون ترکیبی هر سطح» (۱۰ سؤال، حد قبولی ۷۰٪، A1–C2) که برای **G7** کنار گذاشته می‌شود.
      هر ۱۷ سند با فایل‌های `assets/data/grammatik/` برابرند؛ ۷۹ مدخل کاتالوگ route درس دارند + ۵ صفحه‌ی ویژه = ۸۴.
      ⇒ **از منبع چیزی کم نیست**؛ سؤالی برای Lukas فقط درباره‌ی زمان G7 باقی است.
- [~] **L.2e تمرین‌ها — ⚠️ تصمیم تازه‌ی Lukas (2026-09-18): G7d/G7e بعد از انتشار.**
      ترتیب جدید: **گرامر ✅ → تمرین‌های گرامر (G7a–G7c) ✅ → انتشار → تمرین‌های ردمیتل و بقیه (G7d) + ذخیره‌ی نتیجه (G7e)
      → کلمه‌ها → تمرین‌های کلمه‌ها.** یعنی تمرین دیگر پیش‌شرط انتشار نیست؛ آنچه ساخته شده سر جایش می‌ماند.
      متن تصمیم قبلی (۲۰۲۶-۰۹-۱۶) برای تاریخچه:
      ~~**L.2e تمرین‌ها قبل از انتشار — تصمیم Lukas (2026-09-16).**~~ ترتیب کامل:
      **گرامر ✅ → تمرین‌های گرامر و ردمیتل و … → انتشار → کلمه‌ها → تمرین‌های کلمه‌ها.**
      تمرین‌ها از دو جا می‌آیند: (۱) ۳۳۶ تمرین آماده‌ی منبع گرامر، (۲) **جمله‌های مثال** (در صفحه‌ی درس گرامر؛ بعداً در کارت
      کلمه‌ها) که به جای‌خالی یا انواع دیگر تمرین تبدیل می‌شوند. تمرین‌های ساخته‌شده از کارت کلمه‌ها **بعد از** تمام شدن کلمه‌ها.
      اجرا: فاز G → **G7a** (تمرین‌های منبع در هر درس) · **G7b** (آزمون هر سطح) · **G7c** (تمرین از جمله‌های مثال) ·
      **G7d** (تمرین برای ردمیتل و deckهای دیگر).
      وضعیت: G7a ✅ · G7b ✅ · G7c ✅ (2026-09-16) · G7d/G7e باز — **و طبق تصمیم 2026-09-18 بعد از انتشار انجام می‌شوند**.
- [ ] **L.2d deckهای «به‌زودی» بدون محتوا:** relativsatz · da_praepositionen · adjektive ·
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
- [x] **L.3a زبان شروع اپ** ✅ (2026-09-16, تصمیم Lukas) — **مشکل:** پیش‌فرض قبلی فارسی بود؛ کاربر
      انگلیسی‌زبان با دیدن رابط فارسی اپ را می‌بندد و می‌رود. **قاعده‌ی ثابت:** تا وقتی کاربر خودش در
      Settings زبان انتخاب نکرده، **پیش‌فرض انگلیسی** است؛ **فقط اگر زبان دستگاه فارسی باشد** (`fa`،
      `fa-AF`، `prs`) رابط فارسی می‌شود. زبان‌های دستگاه به ترتیب بررسی می‌شوند و اولین زبانی که VOX دارد
      (fa/en) تصمیم می‌گیرد (مثل Root-in)؛ دستگاه فقط‌آلمانی ⇒ انگلیسی. انتخاب صریح کاربر (`ui_language`)
      همیشه مقدم است؛ تشخیص خودکار **ذخیره نمی‌شود** تا اپ تا لحظه‌ی انتخاب کاربر دنبال دستگاه بماند.
      فایل‌ها: `core/l10n/geraete_sprache.dart` (قاعده، تنها منبع) · `settings_controller.dart` (`_load`) ·
      `app.dart` (زبان در حین بارگذاری هم از دستگاه، نه `fa`) · `core/utils/dokument_sprache.dart`
      (+`_io`/`_web`: `<html lang>` همراه زبان) · `web/index.html` (`lang="en"`) · پیش‌فرض‌های
      `AppL10n.activeLang`/`Formatters.useFa` ⇒ en · تست: `test/geraete_sprache_test.dart`.
      ⚠️ هر تغییر بعدی در زبان پیش‌فرض فقط در `geraete_sprache.dart` — هیچ جای دیگری `'fa'` را پیش‌فرض نکند.
- [x] **اصلاح README** ✅ (2026-09-18) — خط قدیمی «Selbstlernen — Gewohnheiten, Streaks» (از 2026-09-13 غلط
      بود چون Habit حذف و با لینک Root-in جایگزین شده بود) به «Pomodoro-Timer, Lernpfad, Vorlagen sowie ein
      Link zur eigenständigen Routine-App (Root-in)» تغییر کرد. فقط متن README؛ کد دست نخورد.
- [x] **آیکون و manifest وب** ✅ (بررسی 2026-09-18) — `web/manifest.json` و `web/index.html` از قبل کامل
      بودند: نام/توضیح/رنگ‌ها، ۴ آیکون (192/512 عادی + maskable)، apple-touch-icon، favicon. کاری لازم نبود.
- [x] **صفحه‌ی حریم خصوصی** ✅ (2026-09-18) — `privacy_policy_screen.dart` از قبل وجود داشت ولی متنش قدیمی
      بود («VOX نیازی به حساب ندارد و هیچ داده‌ای روی سرور نمی‌رود») — از زمان S.3 (حساب + Supabase-Abgleich)
      این نادرست شده بود. بخش «جمع‌آوری داده‌ها» به‌روز شد + بخش تازه‌ی «حساب کاربری (اختیاری)» اضافه شد
      (ایمیل + نسخه‌ی پشتیبان روی Supabase فقط اگر کاربر خودش حساب بسازد).
- [x] **تست RTL همه‌ی صفحات — باگ پیدا و رفع شد** ✅ (گزارش Lukas + رفع Claude، 2026-09-18)
      **باگ:** وقتی زبان رابط فارسی است، `MaterialApp.locale = fa` جهت کل اپ را RTL می‌کند. یک `Text` ساده
      این را ارث می‌برد، پس متن **آلمانی** هم RTL می‌شد: کل خط به لبه‌ی راست می‌چسبید (چپ خالی) و نقطه‌ی
      پایان جمله طبق قواعد Bidi در سمت چپ — یعنی ظاهراً اولِ جمله — می‌افتاد. ترتیب کلمات سالم می‌ماند.
      **رفع (ماندگار، نه موضعی):** ویجت مشترک `lib/core/widgets/deutsch_text.dart` → `DeutschText`، که
      `textDirection: ltr` و `textAlign: left` را **ثابت** می‌گذارد به‌جای ارث‌بری. قاعده‌ی جدید: هر محتوای
      آلمانی با `DeutschText` نشان داده شود، نه `Text` خالی؛ ترجمه‌ها (fa/en) همان `Text` عادی بمانند.
      اعمال شد در `redemittel_exam_list_screen.dart` و `redemittel_1010_detail_screen.dart` (عنوان AppBar،
      کارت Deutsch، کارت Struktur danach، جمله‌ی نمونه؛ `_Card` پرچم `istDeutsch` گرفت).
      قفل شد با `test/deutsch_text_test.dart`. الگوی قبلی مشابه: `wort_text.dart` از قبل ltr داشت.
      ✅ **جاروی کامل شد (2026-09-18):** `DeutschText` در این‌ها هم اعمال شد —
      `grammatik_lektion_screen.dart` (عنوان AppBar، جمله‌ی نمونه `e.german`، عنوان جدول `t.titleDe`،
      عنوان درس در فهرست)، `redemittel_1010_list_screen.dart` (عنوان بخش + عبارت)،
      `redemittel_1010_grammar_screen.dart`، `redemittel_1010_quiz_screen.dart` (عنوان بخش، متن پرسش —
      با تفکیک نوع: multiChoice/wordOrder آلمانی است ولی matchMeaning/fillBlank ترجمه، پس فقط دوتای اول
      `DeutschText` گرفتند —، جمله‌ی درست، و چیپ‌های واژه در تمرین ترتیب‌کلمات)،
      `word_list_item.dart` (کلمه‌ی آلمانی در فهرست واژگان).
      ⚠️ **یک نکته‌ی مهم از همین باگ (2026-09-18):** در جاروی اول، همین `grammatik_lektion_screen.dart`
      «انجام‌شده» علامت خورد ولی **پاراگراف توضیح آلمانی** (`b.bodyDe` در ویجت `_Block`) جا افتاده بود —
      Lukas دوباره گزارش داد: «گرامر A1، پاراگراف اول، نقطه‌ی جمله‌ی آخر سمت چپ است». رفع شد و **Lukas
      تأیید کرد** (2026-09-18). در همان دور، تیتر بلوک (`b.headingDe`) و سه جای جدول‌ها (سرستون‌ها،
      `r.rowLabel` مثل ich/du/er، و خانه‌های `cell` مثل komme/kommst) هم درست شدند.
      **درسِ روش کار:** «این فایل را درست کردم» کافی نیست — باید در هر فایل **همه‌ی** `Text(`ها یکی‌یکی
      شمرده شوند و برای هرکدام تصمیم گرفته شود آلمانی است یا ترجمه. وگرنه دقیقاً همین اتفاق می‌افتد.
      ✅ **دکمه‌های کوییز هم رفع شد (2026-09-18):** `VoxOptionButton` پارامتر `istDeutsch` گرفت (پیش‌فرض
      `false`، پس ترجمه‌ها دست‌نخورده‌اند). در ۱۰ صفحه‌ی کوییز اعمال شد — در آن‌هایی که دو نوع پرسش دارند
      قاعده `istDeutsch: q.type != _QuizType.matchMeaning` است (چون `matchMeaning` ترجمه نشان می‌دهد و
      بقیه شکل‌های آلمانی)؛ در Präpositionen/Konnektoren/Grammatik همیشه `true`. **nvv عمداً دست نخورد**
      چون گزینه‌هایش `_m()` یعنی ترجمه‌اند. جمله‌ی آلمانی در `hoeren_quiz_screen` هم درست شد.
      ✅ **جاروی پایانی (2026-09-18):** با دانلود کل ریپو (tarball) و grep روی `lib/features/` دقیقاً
      **۱۴ جای باقی‌مانده** پیدا و رفع شد — detail-screenهای konnektor/nvv/unregelm، جمله‌های نمونه در
      کوییزها، `grammar_topic_screen`، `vorlagen_screen`، `word_detail_screen`، `add_word_screen`.
      ✅ **نگهبان ساخته شد: `test/deutscher_text_waechter_test.dart`** — `lib/features/` را می‌گردد و اگر
      یک فیلد آلمانی (`.german`, `.exampleDe`, `.phraseDe`, `.titleDe`, `.bodyDe`, `.headingDe`,
      `.promptDe`, `.sectionTitleDe`, `.connector`, `.labelDe`) داخل یک `Text(` خالی باشد **CI را قرمز
      می‌کند** و فایل/خط/فیلد را نام می‌برد. دو استثنای مستند دارد (جایی که کلمه‌ی آلمانی داخل یک جمله‌ی
      ترجمه‌شده نشسته). این همان الگوی B.5 است: «نگهبان به‌جای grep» — دقیقاً به این دلیل ساخته شد که
      همین باگ دو بار لازم شد.
- [ ] **تست آفلاین — باگ تأیید شد، علت هنوز قطعی نیست** (گزارش Lukas، 2026-09-18)
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
- [ ] **(Lukas)** تست روی آیفون واقعی (Safari + افزودن به صفحه‌ی اصلی)

### L.4 — بعد از انتشار: کلمه‌ها، روزانه
- ⏭️ **R-2.2 هم اینجاست** (2026-09-22): deckهای Auswendiglernen یکی‌یکی ⇒ کارت کلمه / کارت عبارت — برنامه: فاز R → «R-2.2 — برنامه». کارت‌های Auswendiglernen هرگز کم نمی‌شوند.
- [ ] روش ساخت ⇒ **فاز A / A.6 ⛔ — قبلش حتماً از Lukas بپرس.** (گزینه‌ی مطرح‌شده 2026-09-16: API با
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
- [x] **L.5f رفتار یکسان کلیک روی کلمه، در همه‌جای اپ.** ✅ (2026-09-20، CI سبز روی Zweig `l5f-klick-wort`؛ فایل‌ها و نقاط اتصال: «آخرین جلسه»؛ بازبینی چشمی از Lukas مانده) هر جای اپ که کلمه‌ای نمایش داده می‌شود، کلیک روی
      آن باید یک رفتار دو مرحله‌ای یکسان داشته باشد: (۱) اول یک **پاپ‌آپ** کوچک باز شود، (۲) با کلیک روی
      همان پاپ‌آپ، **صفحه‌ی کامل کلمه** (`wort_seite_screen.dart`) باز شود — از همان‌جا کاربر معنی را چک
      می‌کند یا کلمه را به لایتنر اضافه می‌کند. این یک قاعده‌ی سراسری UI است (نه فقط Wortschatz/Vokabular)؛
      باید به‌صورت یک ویجت/کامپوننت مشترک ساخته شود تا هر صفحه‌ای که کلمه نشان می‌دهد (Lesen، Hören،
      Redemittel، گرامر، جمله‌های مثال، …) همان را reference کند — طبق اصل Component Isolation
      (`ways-of-working` / اصل ۱ در PROJECT_MAP.md)، نه پیاده‌سازی جدا در هر صفحه.
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

> **درخواست Lukas (2026-09-20):** «کاربر اکانت و اطلاعات خودش را کجا وارد کند؟» تا آن روز جواب: فقط پایین «تنظیمات»، و آن هم فقط اگر Secretهای
> Supabase ست بودند. اسم/آدرس/تلفن/تغییر رمز/آرشیو اصلاً وجود نداشت. ✅ **CI grün** (2026-09-20, Lauf 35487912698 auf Zweig `profil-seite`: analyze + test + Web-Bau) — danach nach `main`. ⚠️ Noch **nicht im Browser gesehen** (Claude hat keinen): Ansicht/RTL/Dialoge bitte von Lukas anschauen.

**یک صفحه برای هرچه به کاربر تعلق دارد:** `/more/profil` (`AppRoutes.profil`) — از «More» (اولین ردیف) و «تنظیمات ← حساب» باز می‌شود.
صفحه **بدون سرور هم کار می‌کند** (اطلاعات، آرشیو، پشتیبان فایل)؛ فقط کارت‌های حساب وقتی `kontoAktivProvider` درست است دیده می‌شوند.

- [x] **P.1 اطلاعات شخصی** — نام (≤۸۰)، تلفن (۶–۱۵ رقم؛ ارقام فارسی/عربی به ASCII نرمال می‌شوند)، تا ۵ آدرس (عنوان/خیابان/کد پستی/شهر/کشور، هر فیلد ≤۱۲۰).
  همه اختیاری؛ آدرسِ فقط-با-عنوان دور ریخته می‌شود. **ایمیل اینجا ذخیره نمی‌شود** (مال `auth.users` است، دو بار نگه داشته نمی‌شود).
  · `core/backup/nutzer_profil.dart` (Dart خالص) — `NutzerProfil`، `ProfilAdresse`، `ProfilFehler` (خطاهای بی‌زبان مثل `AuthIssue`)، `telefonGueltig`، `normalisiereZiffern`.
  · **قرارداد پشتیبان 3 → 4:** فیلد `profil`. نسخه‌های ۱–۳ همچنان خوانده می‌شوند؛ بدون پروفایل کلید اصلاً در JSON نمی‌آید (مقایسه‌ی متن در Abgleich تغییر نمی‌کند).
    **قاعده‌ی ادغام: «آخرین ویرایش، کامل، برنده است»** (`NutzerProfil.spaeteres`) — برخلاف لایتنر («بالاترین جعبه») چیزی که فقط رو به جلو برود اینجا نیست؛ فرمِ پر‌شده روی دستگاه B با فرمِ دستگاه A قاطی نمی‌شود.
    پروفایلِ **عمداً خالی‌شده** با زمان جدیدتر برنده می‌شود، وگرنه پاک‌شده‌ها از دستگاه دیگر برمی‌گشتند. برابری/بدون زمان ⇒ نسخه‌ی خودی.
  · ذخیره: SharedPreferences، کلید `vox_profil_v1` (`kProfilKey` در `user_state_repository.dart`)؛ `lesen()` آن را می‌خواند، `anwenden()` مرحله‌ی (6) آن را می‌نویسد.
    ⚠️ عمداً **نه** در `einstellungen` (آنجا «نسخه‌ی خودی برنده است» و فقط وقتی map خالی است از سرور می‌گیرد ⇒ دستگاه تازه با یک تنظیم، پروفایل را هیچ‌وقت نمی‌گرفت).
  · `features/more/controllers/profil_controller.dart` — `profilProvider` (AsyncNotifier؛ `speichern()` پاک‌سازی + اعتبارسنجی + زمان؛ نامعتبر ⇒ چیزی نوشته نمی‌شود)، `archivUebersichtProvider`، `passwortNeuProvider`.
  · UI: `widgets/profil_angaben_karte.dart` (یک «ذخیره» کل فرم را ذخیره می‌کند؛ افزودن آدرس فیلدهای ذخیره‌نشده را از دست نمی‌دهد).
- [x] **P.2 حساب و امنیت** — `AuthService` +: `changePassword`، `changeEmail`، `sendPasswordReset`، `signOutEverywhere`، `watchPasswordRecovery`؛
  `AuthIssue` +: `samePassword`، `reauthNeeded` (کدهای `same_password`، `reauthentication_needed`/`_not_valid`).
  · `widgets/profil_konto_karte.dart` — `ProfilKontoKarte` (از `_KontoKarte` آمده؛ + فراموشی رمز، تغییر ایمیل، خروج همه‌جا) و `PasswortAendernKarte` (حداقل ۸ نویسه در UI — سخت‌گیرتر از سرور؛ تکرار باید یکی باشد؛ تابع خالص `passwortFehlerSchluessel`).
  · **بازنشانی رمز:** لینک ایمیل → رویداد `passwordRecovery` → `passwortNeuProvider=true` → `app.dart` به `/more/profil` می‌رود و کارت «رمز جدید» بالای صفحه می‌آید.
    جریان PKCE است (پیش‌فرض supabase_flutter 2.x): `?code=` در query می‌آید، پس با URL hash-strategy تصادم ندارد؛ لینک باید **در همان مرورگر** باز شود.
  ⚠️ **حساب با Root-in مشترک است** (`auth.users`): تغییر رمز/ایمیل در VOX در Root-in هم اثر می‌کند — UI صریحاً می‌گوید (`account_shared_hint`).
  ⚠️ `AppLinks.voxUrl` باید در Redirect URLs Supabase باشد (بالا).
- [x] **P.3 آرشیو و داده** — `widgets/profil_archiv_karte.dart`: تعداد کارت لایتنر (به تفکیک جعبه)، فهرست‌ها، یادداشت‌ها، کلمه‌های خودم + پرش به لایتنر/فهرست‌ها.
  فقط‌خواندنی؛ از **همان** `UserStateRepository.lesen()` می‌خواند (شمارش دوم وجود ندارد). `widgets/sicherung_karte.dart` = کارت پشتیبان (از `settings_screen.dart` منتقل شد، یک کپی — نه دو کپی)؛
  بعد از ایمپورت فایل: settings/profil/archiv هم invalidate می‌شوند (قبلاً settings تازه نمی‌شد). `datenOrtSchluessel` همراه رفت و از `settings_screen.dart` re-export می‌شود.
  تنظیمات: `_KontoKarte`/`_SicherungKarte` حذف؛ به‌جایش کاشی «پروفایل و حساب». `widgets/konto_texte.dart`: `kontoFehlerText`، `profilFehlerText` (ترجمه در UI، نه در سرویس).
- [x] **حریم خصوصی:** `privacy_policy_screen.dart` بخش «اطلاعات شخصی (اختیاری)» گرفت (تاریخ 2026-09-20) — نام/تلفن/آدرس فقط در مرورگر، و با حساب: در ردیف خودِ کاربر در `vox_backups`؛ جای دیگر نه.
- [x] **حذف حساب (L.1d) ✅ 2026-09-22** — Lukas: «فعالش کن» (برای هر دو اپ). `auth.users` پاک می‌شود ⇒ `vox_backups` و `profiles`/`backups` Root-in با cascade.
  · SQL: `supabase/vox_tables.sql` §5 `delete_own_account()` — **هم‌متن** `schema.sql` Root-in §6 (security definer، بدون پارامتر، `search_path=''`، فقط `authenticated`). تغییر = هر دو فایل. VOX دیگر برای حذف به schema.sql وابسته نیست.
  · کد: `AuthService.deleteAccount()` → `AccountDeletion {deleted, unavailable, failed}` (کپی دقیق Root-in؛ PGRST202 ⇒ unavailable).
  · UI: `ProfilKontoKarte._kontoLoeschen()` با `VoxDialog.confirm`؛ unavailable ⇒ `CloudAblage.loeschen()` (policy `vox_backups_delete_own` از قبل بود) + `signOut` (وگرنه همگام‌سازی خودکار دوباره آپلود می‌کرد) + پیام «به ما پیام بده».
  · داده‌ی روی دستگاه عمداً دست نمی‌خورد (مثل Root-in؛ اپ بدون حساب هم کار می‌کند). حریم خصوصی: بخش «حذف حساب».
  · ⚠️ مسابقه با همگام‌سازی: آپلود بعد از حذف با FK (`references auth.users`) رد می‌شود ⇒ حساب «برنمی‌گردد».
- **تست‌ها:** `test/profil_test.dart` (تلفن، پاک‌سازی، JSON، ادغام، قرارداد v4 + خواندن v3، قاعده‌ی رمز، کدهای Auth)، `test/profil_controller_test.dart`،
  `user_state_repository_test.dart` +۵ (Profil: خواندن، خراب، جابه‌جایی دستگاه، قدیمی‌تر رونویس نمی‌کند)، `l10n_paritaet_test.dart` +۵۴ کلید.
- ⚠️ **کد بدون کامپایلر نوشته شد** (Claude Flutter ندارد) — فقط ساختارهای موجود در ریپو؛ اعتبار واقعی = اجرای «Zweig prüfen».

---

## INHALTSVERZEICHNIS (فهرست مطالب)

| # | بخش | لینک |
|---|-----|------|
| 1 | اطلاعات کلی | [→](#اطلاعات-کلی) |
| 2 | Status Legend | [→](#status-legend) |
| 3 | خلاصه فازهای کامل | [→](#فاز-۰-تا-۱۵--زیرساخت-و-ویژگی‌های-اصلی-) |
| 4 | باگ‌های فعلی | [→](#️-باگ‌های-فعلی) |
| 5 | فاز R — Refactor & UX | [→](#فاز-r--refactor--ux-فاز-جاری--بعد-از-رفع-باگ‌ها) |
| 5b | ⭐ **اصل: یک محتوا، چند ورودی** (2026-09-18) | [→](#-اصل-معماری-پایه-یک-محتوا-چند-ورودی-content-once-many-entrances) |
| 5c | 🔍 **A-1 — Audit «یک محتوا، چند ورودی»** (باز) | [→](#-a-1-باز--audit-یک-محتوا-چند-ورودی-در-کل-اپ) |
| 6 | Design System (DS) | [→](#فاز-ds--design-system--یک-بار-برای-همیشه) |
| 6b | فاز ARCH — Architecture Hub | [→](#فاز-arch--architecture-hub--زیرساخت-مرکزی-2026-07-04) |
| 6c | **فاز G — Grammatik Vollausbau** (G1–G6 ✅) | [→](#فاز-g--grammatik-vollausbau-تمام-گرامر-زبان-آلمانی-g1g6-) |
| 6d | **فاز B — Buttons: Puzzling** ✅ | [→](#فاز-b--buttons-puzzling-prinzip--2026-07-07) |
| 6e | **فاز L — L10n: زبان فقط از Settings** ✅ | [→](#فاز-l--l10n-زبان-فقط-از-settings-step-1--audit--2026-07-07) |
| 6f | **فاز L2 — Massen-Lokalisierung** ✅ | [→](#فاز-l2--massen-lokalisierung-هیچ-fa-در-حالت-en-l2-ae--l2-f-باز-2026-07-07) |
| 6g | **فاز L3 — Content-Zweisprachigkeit** ✅ | [→](#فاز-l3--content-zweisprachigkeit-همه-محتواها-faen-l3-ad--e-باز-2026-07-07) |
| 0 | **🚀 فاز LAUNCH — ترتیب جدید تا انتشار** (2026-09-16) | [→](#-فاز-launch--ترتیب-جدید-تا-انتشار-تصمیم-lukas-2026-09-16) |
| 0b | **L.5 — درخواست‌های جدید Lukas** (باز، 2026-09-17) | [→](#l5--درخواست‌های-جدید-lukas-باز-شد-2026-09-17) |
| 6h3 | **فاز S — ذخیره‌سازی داده‌ی کاربر** (باز) | [→](#فاز-s--speicherung-der-nutzerdaten-باز-شد-2026-09-15) |
| 6h4 | **فاز P — Profil & Konto** (2026-09-20) | [→](#فاز-p--profil--konto-2026-09-20) |
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

## ⚠️ باگ‌های فعلی

### B-1: خطای Flutter — color + decoration در Container ✅
- وضعیت: رفع شد (2026-06-29)

### B-2: خطای SQLite — UNIQUE constraint در words ✅
- وضعیت: رفع شد (2026-06-29)

### B-12 ✅ (2026-09-15): پشتیبان فیلدهای گرامری B-10 را نداشت
- B-10 hat `Words` um `regelmaessig`/`trennbar`/`grammatikDetail` erweitert, die Fassade
  (`user_state_repository.dart` → `_wortZuJson` + `anwenden()`) aber nicht. Eine Sicherung
  (Datei oder Konto) hätte diese Felder still verloren ⇒ auf dem neuen Gerät keine Symbole.
- Beide Richtungen ergänzt; Test „B-12" in `test/user_state_repository_test.dart` (Gerätewechsel,
  und: ein unbekanntes Feld bleibt `null` — nie geraten).
- ⚠️ **Regel:** Jede neue Spalte in einer Nutzer-Tabelle braucht denselben Commit in der Fassade.

### B-11 ✅ (2026-09-15): اپ و پشتیبان دو جای متفاوت را می‌خواندند — از دست رفتن ظاهری پیشرفت
- **Befund (beim Vorbereiten von S.3 Schritt 3 am Code gefunden):** S.0b/S.0c hatten nur die
  Fassade (`user_state_repository.dart`) auf drift umgestellt. Der Store der App,
  `features/vokabular/controllers/vokabular_user_state.dart`, las und schrieb weiter
  `vokab_user_leitner_v1` / `vokab_user_kategorien_v1` in SharedPreferences.
- **Folge:** Wer eine Sicherung einspielte, dem leerte die Fassade genau diese Schlüssel
  (Übergangspfad) — beim nächsten Start zeigte die Wortseite **leeren Leitner-Stapel und
  leere Listen**, obwohl alles in drift lag. Jeder automatische Konto-Abgleich (S.3 Schritt 3)
  hätte denselben Effekt bei jedem Lauf gehabt. ⇒ Schritt 3 war ohne diese Korrektur nicht baubar.
- **Lösung — EIN Zuhause, keine zweite Logik:**
  · Der Store kennt keine Ablage mehr; er ruft nur die Fassade: `archivLesen()`,
    `archivLeitnerAufnehmen/-Entfernen()`, `archivKategorieAnlegen()`,
    `archivKategorieWortSetzen()`. Die Fassade bleibt die **einzige** Stelle, die die Tabellen kennt.
  · Beim Laden ruft der Store `uebergangAbschliessen()` — ein Altbestand in SharedPreferences wird
    über **dieselbe** `anwenden()`-Logik nach drift übernommen. Wessen Stand durch ein Einspielen
    „verschwunden" war, sieht ihn nach dem Update wieder (er lag die ganze Zeit in drift).
  · `neuLaden()` im Store; `_SicherungKarte` ruft es nach dem Einspielen — vorher blieb die
    Wortseite bis zum Neustart auf dem alten Stand.
  · Die drei `kVokab…Key`-Konstanten liegen jetzt in der Fassade: `core/` importiert kein Feature mehr.
- Drei neue Tests in `test/vokabular_test.dart` (gemeinsame Ablage · nach dem Einspielen fehlt
  nichts · Altbestand wird beim Laden übernommen); die bestehenden Store-Tests laufen jetzt gegen
  eine In-Memory-Datenbank.
- ⚠️ **Lehre:** Wer eine Ablage umzieht, muss **alle Leser** umziehen, nicht nur den, an dem er
  gerade arbeitet. Vor dem Umzug: `grep` nach dem Schlüssel/der Tabelle über `lib/`.

### B-10 ✅ (2026-09-16, CI grün): جدول قدیمی Words — Grammatikfelder nachgetragen
- Neue Spalten in `Words` (alle nullable, Migration `schemaVersion` 4 → 5):
  `regelmaessig` / `trennbar` (Verb) und `grammatikDetail` (Kasus bei Präposition,
  Untertyp bei Konnektor — ein Textfeld für beide, je nach Wortart unterschiedlich gedeutet).
- Durch alle Schichten gezogen: `Words` (drift) → `WordModel` → `WordToModel`/`ModelToCompanion`
  → drei Parser (`word_parser.dart`, `connector_parser.dart`, `irregular_verb_parser.dart`) →
  `wortschatz_grammatikon.dart`.
- **Herkunft je Parser, bewusst unterschiedlich vorsichtig:**
  · `IrregularVerbParser` (Format `UV`) nennt eigene Stammformen ⇒ per Definition
    `regelmaessig: false`. `trennbar` bleibt null (aus dem Infinitiv nicht sicher ableitbar).
  · `WordParser` — ein hier eingegebenes Verb hat kein Stammform-Feld (unregelmäßige laufen
    über `UV`) ⇒ per Konvention `regelmaessig: true`. Für Präposition: optionaler vierter
    Kasus-Wert direkt nach dem Typ, erkannt nur bei einem von vier bekannten Werten — jeder
    andere Text bleibt wie zuvor die Bedeutung (kein bestehendes Format bricht).
  · `ConnectorParser` — optionaler Untertyp direkt nach der `K`-Marke, gleiche Vorsicht.
- **`wortschatz_grammatikon.dart` unterscheidet jetzt zwei Fälle:** Verb/Präposition
  bekommen ohne das Feld weiterhin KEIN Symbol (raten wäre falsche Grammatik); Konnektor
  bekommt IMMER ein Symbol, weil der Resolver dafür einen echten, nicht falschen
  Standardfall hat (`kurve_u`) — mit Untertyp nur genauer, nie falsch ohne ihn.
- 8 neue Testfälle in `test/wortschatz_grammatikon_test.dart`, u. a.: fehlendes `trennbar`
  wird wie „nicht trennbar" behandelt statt geraten; Konnektor mit/ohne Untertyp.

### B-9 ✅ (2026-09-15): دو سیستم رنگ آرتیکل — یکی شد
- `core/constants/article_colors.dart` (لیست Wortschatz): der=آبی · die=قرمز · das=سبز
- `core/grammatikon/grammatikon_spec.dart` (آرشیو Vokabular): maskulin=سبز · feminin=نارنجی ·
  neutral=بنفش · plural=قرمز
- ⇒ سبز یک‌جا «das» و جای دیگر «der»؛ قرمز یک‌جا «die» و جای دیگر «جمع»
- برای زبان‌آموزی که رنگ‌ها را حفظ می‌کند، دو نظام متناقض است
- **حل شد:** نظام Grammatikon برنده شد (شکل=Kasus را هم حمل می‌کند و رنگ جمع دارد).
  `article_colors.dart` دیگر مقدار خودش را ندارد و از `GrammatikonSpec` می‌خواند — هشت فایلی
  که از آن استفاده می‌کنند بدون تغییر رنگ جدید را گرفتند (Puzzling: یک منبع).
- محافظ: `test/artikelfarben_test.dart` اگر دوباره از هم جدا شوند CI را قرمز می‌کند.
- ⚠️ اثر جانبی آگاهانه: رنگ‌های لیست Wortschatz برای کاربران فعلی عوض شد
  (der آبی→سبز، die قرمز→نارنجی، das سبز→بنفش). عمداً **حالا** انجام شد، چون بعد از اینکه
  کاربران رنگ‌ها را حفظ کنند، تغییرش یعنی خراب کردن آموخته‌شان.

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
- [x] R-1.2 ✅ (تأیید در کد 2026-09-22) `word_detail_screen.dart`: کلیک روی کلمه → همه اطلاعات: (معنا، مثال، `AudioPlayButton`، `LeitnerAddButton`، دسته‌بندی، یادداشت گرامر — **«favorit» در اپ مفهوم جدا ندارد؛ فهرست‌ها/دسته‌بندی جایش را گرفته‌اند**)
  - معنا (FA + EN)، مثال‌ها، صدا (TTS)
  - دکمه Leitner، دکمه دسته‌بندی، دکمه favorit، گرامر

### R-2: Auswendiglernen — Präpositionen list باید full form نشان دهد
- [x] R-2.1 ✅ 2026-09-22 لیست "Nomen · Verb · Adjektiv + Präpositionen": فرمت: `lemma · حرف_اضافه` — `PraepCluster.vollform` + `praepositionen_home_screen.dart`؛ تست `test/praep_vollform_test.dart`
  - مثال: "abhängen · abhängig · die Abhängigkeit von"
  - این فرمت را تغییر نده — کاربر می‌خواهد حرف اضافه را در لیست ببیند
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
  2. **ساخت کارت‌های نداشته** با پرامپت کلمه ⇒ `assets/vocab/` — این همان مسیر **L.4 / A.6 ⛔** است (روش و هزینه را Lukas تعیین می‌کند؛ «کلمه‌ها آخرین مرحله‌اند»).
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
  - معنا (FA + EN)، مثال‌ها، صدا (TTS)
  - دکمه Leitner، دسته‌بندی، favorit

### R-3: Auswendiglernen — ساختار جدید صفحه اصلی
- [x] R-3.1 ✅ (همان Phase 5، 2026-06-29) حذف section headers (Verben، Satzbau und Konnektoren، Wortschatz، Redemittel)
- [x] R-3.2 ✅ (Phase 5) فقط یک لیست ساده از deck‌ها:
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
- [x] R-3.3 ✅ (Phase 5) deck‌های "coming soon" را نشان بده ولی غیرفعال (قفل) — ⚠️ برای انتشار: L.2d

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

- [x] R-4.1 ✅ (تأیید در کد 2026-09-22) `core/widgets/filter_accordion.dart` — کامپوننت جدید
  - params: `label:String`، `options:List<FilterOption>`، `selected:Set<String>`، `onChanged`
- [x] R-4.2 ✅ `core/widgets/filter_chip_bar.dart` — نمایش فیلترهای فعال + پاک کردن
- [x] R-4.3 ✅ اعمال در: Konnektoren، NVV، Dativ Verben، Präpositionen، Wortschatz (+ trennbar، unregelm، reflexiv، verb_praep، redemittel_1010)
  - هر Screen فقط `FilterOption`‌های خودش را تعریف می‌کند و به widget می‌دهد

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
- [x] **B.5 ✅ (2026-09-15) Wächter statt grep:** `test/puzzling_buttons_test.dart` durchsucht
      `lib/features/` nach rohen `IconButton`/`TextButton`/`OutlinedButton`/`FilledButton`/
      `ElevatedButton`/`FloatingActionButton` und macht CI rot, wenn einer auftaucht.
      **Anlass:** Die Regel stand nur als grep-Befehl hier — und S.2 + S.3 Schritt 2 haben sie
      unbemerkt gebrochen (fünf rohe Buttons in `settings_screen.dart`, jetzt ersetzt).
      `lib/core/widgets/` bleibt ausgenommen: dort wird das Design System gebaut.
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

- [x] R-7.1 `assets/data/konnektoren_data.json` — ✅ موجود — مستقل از UI
- [x] R-7.2 `assets/data/dativ_akkusativ_data.json` — ✅ موجود
- [x] R-7.3 `assets/data/nvv_data.json` — ✅ موجود
- [x] R-7.4 `assets/data/praepositionen_data.json` — ✅ موجود
- [x] R-7.5 `assets/data/redemittel_goethe_b2.json` — ✅ ۶۱ عبارت (2026-07-04)
- [x] R-7.6 `assets/data/redemittel_oesd_b2.json` — ✅ ۱۲۱ عبارت (2026-07-04)
- [x] R-7.7 `assets/data/redemittel_oesd_c1.json` — ✅ ساخته شد (L.2a، 2026-09-18)
- [x] R-7.8 `assets/data/redemittel_1010.json` — ✅ ۹۰۸ عبارت (2026-07-04)
- [x] R-7.9 `lib/core/content/content_registry.dart` — ✅ موجود (oesd_c1 هم ثبت است) — ⚠️ 2026-09-22: هیچ فایل دیگری آن را import نمی‌کند (فقط فهرست)

---

## فاز ۱۶ — انتشار و QA نهایی [ ]
> ⚠️ **2026-09-16:** این فهرست مال نسخه‌ی بومی قدیمی است (iOS/Android/RevenueCat) و از 2026-09-13 منسوخ است. فهرست معتبر: **فاز LAUNCH → L.3**.
- [⛔] ~~16.1 تست دستی iOS Simulator~~ — ⛔ منسوخ (وب‌اپ، 2026-09-13)؛ جایگزین: تست آیفون واقعی در L.3
- [⛔] ~~16.2 تست دستی Android Emulator~~ — ⛔ منسوخ (وب‌اپ، 2026-09-13)
- [x] 16.3 تست RTL فارسی همه صفحات ✅ (2026-09-18) — باگ پیدا و رفع شد؛ Lukas تأیید کرد (جزئیات: L.3 «تست RTL»)
- [ ] 16.4 تست آفلاین (airplane mode) — ⏸️ ادامه در L.3 «تست آفلاین» (منتظر خروجی DevTools از Lukas)
- [x] 16.5 آیکون ✅ (`assets/images/app_icon.png` 2026-07-03؛ وب: `web/icons/` + manifest، L.3)
- [⛔] ~~16.6 dart run flutter_launcher_icons~~ — ⛔ بومی/منسوخ (وب‌اپ؛ در pubspec نیست)
- [⛔] ~~16.7 dart run flutter_native_splash:create~~ — ⛔ بومی/منسوخ (وب‌اپ؛ در pubspec نیست)
- [⛔] ~~16.8 RevenueCat API keys واقعی در main.dart~~ — ⛔ منسوخ (وب‌اپ، 2026-09-13)؛ RevenueCat از پروژه حذف شد، اپ رایگان است
- [⛔] ~~16.9 App Store Connect + Google Play metadata~~ — ⛔ منسوخ (وب‌اپ، 2026-09-13)
- [⛔] ~~16.10 flutter build ios/appbundle~~ — ⛔ منسوخ (وب‌اپ، 2026-09-13)
- [⛔] ~~16.11 TestFlight + Android test track~~ — ⛔ منسوخ (وب‌اپ، 2026-09-13)
- [⛔] ~~16.12 submit review~~ — ⛔ منسوخ (وب‌اپ، 2026-09-13)

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
- [x] R-2 (R-2.1) ✅ 2026-09-22: Präpositionen — full form (lemma · حرف‌اضافه) در لیست. R-2.2 باز.

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
- [x] B3  `app_env.dart` — LIVE — RevenueCat keys via --dart-define (main.dart پاک شد) — ⛔ RevenueCat بعداً حذف شد (2026-09-13)
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
- [x] B12 ✅ (تأیید 2026-09-22) `test/helpers/mock_data_factory.dart` + تست‌ها + CI (`pruefen.yml`، `deploy-web.yml`)

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

### فاز G — Grammatik Vollausbau (تمام گرامر زبان آلمانی) [G1–G6 ✅]
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
- [x] **G2-alt** ✅ اصلاح شد (2026-09-16): منبع **ناقص نیست** — ۱۷ سند JSON کامل (۸۴ درس، ۳۳۶ تمرین) پشت‌سرهم
      با متن توضیحی میانشان؛ هر سند از `{` قبل از `"_index"` جدا می‌شود. `verben-grundlagen.json` موجود بایت‌به‌بایت
      با سند منبع برابر بود. ~~منبع ناقص/آشفته است — فقط ۴ لکسیون کامل parse شد.~~
- [x] **G2-old** ✅ (تأیید 2026-09-22: explanationBlocks + relatedSlugs رندر می‌شوند) `GrammatikLektionScreen` — رندر Content-JSON (explanationBlocks سه‌زبانه +
      examples + tables + relatedSlugs) در `/grammatik/lektion/:slug`
- [x] **G3** ✅ (2026-09-16) ایمپورت محتوا I: verben-grundlagen(9) + tempus(5) + passiv(4) + konjunktiv(7)
      → `assets/data/grammatik/<thema>.json` + آپدیت route در کاتالوگ
- [x] **G4** ✅ (2026-09-16) ایمپورت محتوا II: verbergaenzungen(5) + ergaenzungssaetze(3) + nomen(6) + artikel(6)
- [x] **G5** ✅ (2026-09-16) ایمپورت محتوا III: adjektive(4) + adverbien(4) + pronomen(5) + praepositionen(5)
- [x] **G6** ✅ (2026-09-16) ایمپورت محتوا IV: satzlehre(9) + nebensaetze(7) + temporalsaetze(5) → همه ۸۴ درس live
      **G3–G6 انجام شد (2026-09-16):** ۱۷ فایل در `assets/data/grammatik/` (نام‌ها طبق منبع)، محتوا **بدون هیچ تغییر**؛
      ۷۵ مدخل کاتالوگ route `/grammatik/lektion/<slug>` گرفتند؛ ۵ مدخلی که صفحه‌ی ویژه‌ی خودشان را دارند
      (trennbare-verben، modalverben، unregelmaessige-verben، reflexive-verben، die-vier-faelle) **عمداً** دست نخوردند.
      · `grammatik_lektion_controller.dart`: فهرست `grammatikContentFiles` (۱۷ فایل).
      · `grammatik_lektion.dart`: منبع `columns` را دو جور نوشته (با/بدون عنوانِ ستونِ برچسب) ⇒ `GrammatikTable.fromJson`
        یکی‌شان می‌کند + `istStimmig`؛ صفحه جدول ناسازگار را هرگز نمی‌کشد. قبلاً جدول‌های `verb-sein`/`verb-haben`
        (live از G2) با DataTable ناسازگار بودند.
      · ۳ جدول `interactiveGrid` (Adjektivdeklination) به‌صورت جدول عادی نمایش داده می‌شوند؛ تمرین روی آن‌ها = G7.
      · ۸ ارجاع منبع به slugهای بدون درس (مثل `temporalsaetze`) مثل قبل بی‌صدا نادیده گرفته می‌شوند — حدس زده نشد.
      · تست: `test/grammatik_lektionen_test.dart` — فایل‌ها ↔ فهرست، درس ↔ کاتالوگ، جدول‌ها قابل‌نمایش، سه‌زبانه،
        و **رسم واقعی هر ۸۴ درس در EN و FA** بدون خطا (همه‌ی جدول‌ها کشیده می‌شوند).
- [ ] **G7** تمرین‌ها — G7a–G7c **قبل از انتشار ✅**؛ **G7d/G7e بعد از انتشار** (تصمیم Lukas 2026-09-18، L.2e). مراحل:
  - [x] **G7a** ✅ (2026-09-16، CI سبز روی شاخه + ساخت وب) ۳۳۶ تمرین منبع (۵ نوع: multipleChoice ۸۵ · fillBlank ۸۲ · wordOrder ۶۷ · transform ۵۱ · matching ۵۱) در هر درس.
        یافته‌های داده (بدون تغییر منبع، در منطق بررسی جذب می‌شوند): `alternatives` در fillBlank همیشه **گزینه‌ی غلط** است
        (۸۲/۸۲، هیچ‌کدام برابر جواب نیست) ⇒ fillBlank = انتخاب بین جواب + alternatives · ۴ wordOrder تکه‌ی اضافی دارند
        (`ex-interr-4` «am»، `ex-indefpron-4` «dem»، `ex-waehrend-4` یک «er»، `ex-genitiv-4` «Wir» با حرف بزرگ) ⇒ تکه‌ی
        بی‌استفاده مجاز، مقایسه بدون حروف بزرگ/کوچک و بدون علامت‌ها · ۷ matching جواب تکراری دارند ⇒ برای هر مورد چپ از
        فهرست جواب‌های **یکتا** انتخاب می‌شود.
        · **یافته‌ی دیگر (در CI پیدا شد):** شناسه‌های `ex-komp-1…4` دو بار در منبع آمده‌اند (درس komparativ-superlativ و
        درس komposita) ⇒ کلید یکتا = درس + شناسه (`GrammatikUebung.schluessel`)؛ داده دست نخورد.
        · فایل‌ها: `models/grammatik_uebung.dart` (مدل + **تنها** جای بررسی جواب) · `widgets/uebung_karte.dart` (نمایش ۵ نوع؛
          متن آلمانی همیشه چپ‌به‌راست) · `widgets/uebungs_sitzung.dart` (پشت‌سرهم + نتیجه؛ برای G7b هم) ·
          `screens/grammatik_uebung_screen.dart` · route `/grammatik/lektion/:slug/uebung` (`AppRoutes.grammatikLektionUebung`) ·
          دکمه‌ی بالا/پایین در `grammatik_lektion_screen.dart` · `grammatik_lektion_controller.dart` (`grammatikUebungenProvider`) ·
          ۱۰ کلید `uebung_*` در `app_l10n.dart` · `VoxButton` حالا `key` می‌پذیرد (برای تست).
        · transform سخت بررسی می‌شود (فقط فاصله/گیومه/علامت آخر مهم نیست)؛ «نمایش جواب» = غلط. نتیجه‌ها **ذخیره نمی‌شوند**
          (تمرین است، نه پیشرفت) — اگر «سطح گذرانده شد» باید بماند، در G7b از راه داده‌ی کاربر (فاز S).
        · تست: `test/grammatik_uebungen_test.dart` + دکمه در `grammatik_lektionen_test.dart` + کلیدها در `l10n_paritaet_test.dart`.
  - [x] **G7b** ✅ (2026-09-16، CI سبز روی شاخه + ساخت وب) آزمون ترکیبی هر سطح — منبع: سند «پیکربندی» در `Grammatik`
        (۱۰ سؤال، حد قبولی ۷۰٪، A1–C2) **بدون تغییر** در `assets/data/grammatik_niveautest.json`.
        · `models/grammatik_niveautest.dart` (بررسی تنظیمات؛ ناقص ⇒ آزمونی نیست) · `screens/grammatik_niveautest_screen.dart`
          (معرفی → سؤال‌ها → قبول/رد → «آزمون تازه» سؤال‌های جدید می‌کشد) · `NiveauTestKarte` بالای نمای سطح در
          `grammatik_katalog_screen.dart` · route `/grammatik/quiz-niveau/:level` (قبل از `:level`) ·
          `UebungsSitzung` حالا `onNochmal` و متن قبول/رد دارد · ۶ کلید `niveautest_*`.
        · **تصمیم Claude:** نوع `transform` در آزمون نمی‌آید — جواب آزاد با مقایسه‌ی سخت؛ یک جمله‌بندی درستِ دیگر در آزمون
          غلط حساب می‌شد. در تمرین درس می‌ماند (آنجا جواب نشان داده می‌شود).
        · اندازه‌ی مخزن سؤال: A1 ۸۶ · A2 ۱۴۶ · B1 ۱۷۰ · B2 ۱۰۷ · C1 ۲۴ · **C2 فقط ۳** (منبع فقط یک درس C2 دارد) ⇒
          آزمون C2 سه سؤال دارد؛ چیزی ساخته یا اضافه نمی‌شود.
        · ✅ **جواب Lukas (2026-09-16):** نتیجه **ذخیره شود** و در پیشرفت کاربر بماند — بعداً بخش **«دست‌یافته‌ها»**
          (Erfolge) آن را نشان می‌دهد ⇒ مرحله‌ی **G7e**.
        · تست: `test/grammatik_niveautest_test.dart`.
  - [x] **G7c** ✅ (2026-09-16، CI سبز روی شاخه + ساخت وب) تمرین از جمله‌های مثال درس‌ها (فقط شکل‌هایی که بی‌حدس درست‌اند).
        **Lukas (2026-09-16):** نوع تمرین‌ها **کاملاً متنوع و تصادفی** — معنی جمله، چیدن کلمه‌ها، چهارگزینه‌ای و …
        · `models/beispiel_uebungen.dart`: از هر جمله‌ی مثال **دقیقاً یک** تمرین؛ نوعش تصادفی از بین نوع‌هایی که برای آن جمله
          بی‌حدس درست‌اند: معنی جمله (۴ گزینه) · انتخاب جمله برای یک معنی (۴ گزینه) · درست/غلط بودن معنی ·
          وصل کردن ۳ جمله به ۳ معنی · چیدن کلمه‌ها (**کلمه‌ی اول داده شده**، معنی به‌عنوان راهنما؛ فقط جمله‌های ساده‌ی ۴ تا ۱۰ کلمه‌ای
          بدون →، +، پرانتز، دونقطه، خط تیره و نقل‌قول).
        · گزینه‌های غلط فقط از همان درس و در آلمانی، فارسی **و** انگلیسی با جواب فرق دارند. هیچ متنی ساخته نمی‌شود.
        · هر نوبت درس = ۴ تمرین منبع + ۶ تمرین تازه = **۱۰، به ترتیب تصادفی**؛ «دوباره از اول» همه را از نو می‌سازد
          (`grammatik_uebung_screen.dart`: `stelleDurchgangZusammen`, `uebungenProDurchgang`).
        · آزمون سطح این تمرین‌ها را هم می‌گیرد، **به‌جز چیدن کلمه‌ها** (حتی با شروع داده‌شده، ترتیب درستِ دوم کاملاً منتفی نیست)
          ⇒ قاعده در `GrammatikUebung.testTauglich`.
        · مدل: سه نوع تازه (bedeutung, satzWahl, richtigFalsch) فقط برای تمرین‌های ساخته‌شده؛ `ausJson` آن‌ها را از منبع نمی‌پذیرد.
          کارت تمرین بعد از جواب، جمله‌ی درس و معنی‌اش (+ note) را نشان می‌دهد. ۸ کلید `bsp_*`.
        · **ساخته نشد: جای‌خالی از جمله‌های مثال** — از داده نمی‌شود مطمئن بود کدام کلمه خالی شود و کدام گزینه‌ی غلط واقعاً غلط است
          (مثلاً `weil` و `da` هر دو درست‌اند). جای‌خالی همان ۸۲ تمرین منبع است.
        · تست: گروه G7c در `test/grammatik_uebungen_test.dart` (+ حل همه‌ی تمرین‌های ساخته‌شده در EN/FA) و `grammatik_niveautest_test.dart`.
  - [ ] **G7e** ذخیره‌ی نتیجه‌ی آزمون سطح در داده‌ی کاربر (پشتیبان + همگام‌سازی، فاز S) — پایه‌ی بخش آینده‌ی «دست‌یافته‌ها».
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
    → ✅ **V.2 (2026-09-16):** دو مرحله شد — `vokabIndexProvider` (فهرست) + `vokabKarteProvider(id)` (کارت کامل، lazy).
    + `vokabId(wortart, wort)` (قانون ۵ ID: آرتیکل حذف، ä→ae/ß→ss) + جستجوی DE/FA/EN.
  · `controllers/vokabular_user_state.dart` — **user state جدا از content read-only**
    (بهبود مهم نسبت به کد RN که flag را داخل خود کارت می‌نوشت): Leitner-Map (box/nextReview)
    + Kategorien؛ `_ready`-Gate ضد race. **Seit B-11 (2026-09-15): drift über die Fassade**
    (`ArchivLeitner`/`ArchivKategorien`), nicht mehr SharedPreferences.
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
- [x] **V.2 Wortindex** ✅ (2026-09-16, Zweig `v2-wortindex`: Index-Bau + `analyze` + `test` + `flutter build web`
      grün, danach nach `main`). Ursprünglich: build-script → `vocab.db`; der Backlog-Teil („welche Wörter sind
      schon da") ist seit A.1 `tool/backlog.py`.
      **Problem:** `vokabular_controller` las beim Start JEDE Karten-Datei — im Browser eine Netzanfrage je Wort.
      Bei ~26.200 Wörtern startet die App so nicht (sichere Grenze ~500).
      **Warum kein `vocab.db`:** (a) VOX ist nur noch Web; eine zweite SQLite-Datei müsste bei jedem neuen Wort
      (nach dem Start täglich!) komplett neu heruntergeladen werden — genau wie ein Index, nur größer und mit einer
      zweiten Datenbank im Browser. (b) Die Sätze-Tabelle ist seit V.0 hinfällig (2 Beispiele je Karte).
      (c) Filter und Suche über ~26.000 kurze Einträge sind im Speicher schnell — dafür braucht es keine
      SQL-Indizes. ⇒ Einfachste Lösung, die bis zum Ende trägt.
      **Aufbau (zwei Stufen):**
      · `assets/vocab_index.json` — je Wort nur id · wort · wortart · niveau · uebersetzung {fa,en} · die
        Symbol-Felder aus `details` (genus, typ, regelmaessig, trennbar, modalverb, kasus, untertyp).
        Gemessen an den 87 echten Karten: **~220 Byte je Wort** ⇒ bei 26.200 Wörtern ~5,8 MB, komprimiert
        übertragen etwa ein Viertel. Eine Anfrage beim Start.
      · Volle Karte `assets/vocab/<wortart>/<id>.json` — erst beim Öffnen der Wort-Seite
        (`vokabKarteProvider(id)`).
      **Der Index wird nie von Hand geschrieben und nie committet** (`.gitignore`). `tool/vokab_index.dart` baut
      ihn in **jedem** Workflow direkt vor `flutter analyze` (deploy-web, pruefen, build-runner, pubspec-lock,
      vokabular-autofill) — er kann also nicht veralten. Der Bau bricht ab (Bau rot, nichts veröffentlicht), wenn
      eine Karte nicht lesbar ist, id/wortart/wort fehlt, die Wortart unbekannt ist, die Datei nicht unter
      `assets/vocab/<wortart>/<id>.json` liegt oder eine id doppelt ist.
      **Dateien:** `lib/features/vokabular/data/vokab_index.dart` (Format, reines Dart — EINE Quelle für Werkzeug
      und App) · `tool/vokab_index.dart` · `vokabular_controller.dart` (`vokabIndexProvider`,
      `vokabIndexByIdProvider`, `vokabKarteProvider`) · Verwender: `wortschatz_list_screen`,
      `wortschatz_home_screen`, `dativ_verben_list_screen`, `wort_seite_screen` · `pubspec.yaml` · 5 Workflows.
      **Tests:** `test/vokab_index_test.dart` — Format; drei Wächter an den echten Karten: (1) Symbol und Farbe aus
      dem Index = aus der vollen Karte (liest der Resolver ein neues details-Feld, schlägt das an), (2) der
      ausgelieferte Index ist frisch gebaut, (3) jede Wortart hat ihren Ordner in `pubspec.yaml`.
      `test/vokabular_test.dart`: Index enthält das Demo-Wort ohne Seiteninhalt; Einzelkarte lädt, unbekannte id = null.
      ⚠️ **Bewusst geändert:** Die Liste zeigt bei Archiv-Karten kein „Fach 1" mehr — das kam aus dem festen
      `box: 1` jeder Karten-Datei und stimmte nie mit dem echten Leitner-Stand überein.
      ⚠️ **Offline:** Nur geöffnete Wörter liegen im Browser-Zwischenspeicher; ein nie geöffnetes Wort braucht
      Netz. Bei ~100 MB Karten ist Vorab-Laden aller Wörter keine Option — gehört zur Offline-Prüfung in L.3.
- [x] **V.3** ✅ entfällt — in V.2 aufgegangen (kein `vocab.db` zu kopieren; Filter/Suche laufen im Speicher über den Index).
      Ursprünglich: اپ: کپی prebuilt `vocab.db` در first-launch (نه seed) + DAO + provider های سورت
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

- [x] **S.0 EINE Ablage** ✅ — erledigt über S.0a–S.0c (Doku nachgezogen 2026-09-16; anderer Weg als
      ursprünglich geplant: eigene Tabelle `ArchivLeitner` statt `LeitnerCards` zu erweitern; die
      Blockade unten ist seit dem PAT mit „Workflows"-Recht weg). Ursprünglicher Text:
      `vokab_user_*` von localStorage nach drift; `LeitnerCards` so
      erweitern, dass es beide Wortquellen trägt (Archiv-Karten haben Text-IDs wie
      `adjektiv_stolz`, die alten Wörter eine Int-ID); Migration ohne Datenverlust.
      ⚠️ **BLOCKIERT** — jede Drift-Änderung braucht `build_runner` (`app_database.g.dart`,
      ~8.000 Zeilen). Claude hat kein Dart, und der nötige CI-Workflow lässt sich nicht pushen
      (PAT ohne „Workflows"-Recht, siehe فاز A / A.4). **Ein Recht löst beide Blockaden.**
- [x] **S.1 `persist()`** ✅ (2026-09-15, CI grün bestätigt) — `core/utils/persistent_storage.dart`
      (+ `_io`/`_web`, bedingter Export wie `external_link_opener`), aus `main.dart` gerufen. Aus
      Root-in übernommen, Herkunft (Repo/Pfad/Commit) im Dateikopf, `tool/check_vendored.py`
      meldet Abweichungen. Test: `test/persistent_storage_test.dart`.
- [x] **S.1b Einladung zur Installation** ✅ (2026-09-15, CI grün) — `core/utils/install_state.dart`
      (+ `install_hinweis.dart` mit dem Aufzählungstyp, damit kein Import-Kreis entsteht,
      + `_io`/`_web`). Erkennt über `matchMedia('(display-mode: standalone)')` und `userAgent`,
      ob VOX schon installiert ist, und zeigt sonst in den Einstellungen unter «داده‌ی من» die
      passende Anleitung (iOS/Android/Desktop). Bewusst **ohne** `beforeinstallprompt` und ohne
      Promises — je weniger Web-API, desto weniger kann brechen. Texte zweisprachig
      (8 neue Schlüssel in `app_l10n.dart`), abgesichert durch `test/l10n_paritaet_test.dart`.
      **Warum das mehr bringt als `persist()`:** installierte Web-Apps sind von Safaris
      Sieben-Tage-Aufräumen ausgenommen; `persist()` ist nur eine Bitte.

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
- [x] **S.2 Export/Import** ✅ (2026-09-15, CI grün) — `backup_service.dart` war ein leerer Stub,
      jetzt echte Sicherung. Vier getrennte Schichten, damit alles außer der Dateiauswahl ohne
      Browser prüfbar bleibt:
      `nutzer_zustand.dart` (was) → `user_state_repository.dart` (wo) →
      `core/backup/datei_io.dart` (Datei öffnen/ablegen) → `backup_service.dart` (Zusammenspiel).
      · Oberfläche: Einstellungen → «داده‌ی من» → Karte «پشتیبان», zwei Schaltflächen, FA/EN.
      · Dateiname `vox-sicherung-JJJJ-MM-TT.json` — Sicherungen verschiedener Tage
        überschreiben sich nicht.
      · **Einspielen ist immer ein Zusammenführen, nie ein Ersetzen.** Auch eine versehentlich
        gewählte alte Datei kann keinen Fortschritt kosten.
      · Fehlerhafte Dateien: `SicherungFehler` mit einem Grund, der direkt angezeigt wird
        (kein JSON · fremde App · zu neue Fassung · fehlende Version).
      · **Kein neues Paket.** Root-in nutzt für den Export share_plus; VOX hat das nicht und ist
        reine Web-App, deshalb Blob-Download über `package:web` (schon vorhanden). Damit bleibt
        `pubspec.lock` unberührt — wichtig, weil Claude kein `flutter pub get` ausführen kann.
      · `textDateiWaehlen` ist die zeichengleiche Übernahme aus Root-in (Herkunft im Dateikopf).
      ⚠️ Zwei eigene Fehler dabei vor dem Push abgefangen: ein unbenutzter Import und
        `context` nach einem `await` (`use_build_context_synchronously`). Alle anzuzeigenden
        Texte werden jetzt VOR der Unterbrechung aufgelöst.
- [~] **S.3 Supabase-Konto** — `auth.users` geteilt, aber **jedes Repo besitzt seine eigenen
      Tabellen**: `schema.sql` bleibt in Root-in, VOX hat ein eigenes `supabase/vox_tables.sql`.
  - [x] **S.3 Schritt 1 ✅ (2026-09-15)** — das Fundament, ohne dass die laufende App sich ändert:
        · `lib/core/constants/app_config.dart` — `SUPABASE_URL`/`SUPABASE_ANON_KEY` per
          `--dart-define`. **Leer heißt: kein Server, kein Konto, kein Netzaufruf** — der
          Normalfall in Tests und in jedem Bau ohne Secrets. Aus Root-in übernommen; VOX braucht
          kein `platform_support.dart`, weil es nur eine Plattform gibt (Web).
        · `lib/core/services/auth_service.dart` — einzige Stelle, die `supabase_flutter` kennt.
          `AuthIssue`/`authIssueFromCode`/`AuthResult` zeichengleich aus Root-in.
          ⚠️ **Zwei bewusste Auslassungen gegenüber der Vorlage:** (a) **kein Benutzername** —
          `profiles` samt Eindeutigkeits-Index gehört Root-in, und keine App schreibt in die
          Tabellen der anderen; (b) **kein `deleteAccount()`** — es löscht `auth.users` und damit
          auch den Root-in-Bestand desselben Menschen. Das ist eine Entscheidung für beide Apps
          zusammen und gehört nicht nebenbei in diese Phase.
        · `supabase/vox_tables.sql` — Tabelle `vox_backups` (eine Zeile je Konto), Rechte nur für
          `authenticated`, RLS mit einer Regel je Vorgang, `updated_at` per Trigger vom Server.
          ⚠️ Der Name ist **nicht** `backups`: diese Tabelle gehört Root-in, und `user_id` ist dort
          ebenfalls Primärschlüssel — eine geteilte Tabelle hieße, dass eine App die Sicherung der
          anderen überschreibt. `touch_updated_at()` ist zeichengleich zu `schema.sql`; wer sie
          ändert, muss BEIDE Dateien ändern.
        · `test/auth_service_test.dart` — die Fehlercodes (sie können still brechen) und der
          Nachweis, dass ohne Konfiguration nichts geworfen und nichts ins Netz geschickt wird.
        · `pubspec.yaml` + `supabase_flutter: ^2.8.0`; `deploy-web.yml` reicht die beiden Secrets
          als `--dart-define` weiter (fehlend ⇒ leer ⇒ aus, der Bau bleibt grün);
          `.env.example` erklärt beide Werte, `.gitignore` nimmt sie von `.env.*` aus.
        · **Noch nichts davon ist verdrahtet:** `main.dart` ruft `initialize()` nicht, es gibt
          keine Anmelde-Oberfläche. Für den Nutzer ist die App unverändert. Das ist Absicht —
          Schritt 1 kann nichts kaputtmachen.
  - [x] **S.3 Schritt 2 ✅ (2026-09-15, CI grün; Commits `63d14b4`…`16b7ad5`)** —
        · `main.dart` ruft `AuthService().initialize()` in try/catch (wie beim Seeding) —
          ohne Secrets liefert es nur `false`, der Start bleibt unberührt.
        · `settings_screen.dart` → `_KontoKarte` unter der Rubrik `section_account`: anmelden,
          registrieren, abmelden. **Nur sichtbar, wenn `kontoAktivProvider` wahr ist** — ohne
          Konfiguration gibt es die Rubrik gar nicht, statt einer, die nie funktioniert.
        · `AuthIssue` → Text in `_kontoFehlerText` (Oberfläche), nicht im Dienst.
          Registrierung mit E-Mail-Bestätigung ⇒ Konto ohne Sitzung ⇒ Hinweis
          `account_confirm_email_sent` statt stiller Erfolgsmeldung.
        · `app_l10n.dart` +21 Schlüssel FA/EN, `test/l10n_paritaet_test.dart` erweitert.
        ⚠️ **Zwei eigene Regelbrüche, am selben Tag nachträglich behoben:**
        (a) Der Schritt ging als **vier** Einzel-Commits hinaus statt als einer — zwei
        Deploy-Läufe wurden abgebrochen, der letzte war grün. Regel bleibt: ein Schritt = ein
        Commit (Git-Data-API oder ein einziger `git push`).
        (b) `_KontoKarte` — und schon vorher `_SicherungKarte` aus S.2 — nutzten **rohe**
        Material-Buttons (`FilledButton`/`OutlinedButton`/`TextButton`/`IconButton`, fünf
        Stellen). Das bricht فاز B (Puzzling). Umgestellt auf `VoxButton`/`VoxIconButton`,
        und die Regel ist jetzt ein Test (siehe فاز B → B.5).
  - [x] **S.3 Schritt 3 ✅ (2026-09-15)** — Kopie in der Cloud: `vox_backups` schreiben/lesen über **dieselbe**
        Nutzlast wie S.2 (`nutzer_zustand.dart`), Zusammenführen weiter „höchstes Fach gewinnt".
        ⚠️ **Planänderung 2026-09-15 (Claude, beim Vorbereiten am Code gefunden):** Schritt 3 braucht
        vorher **S.5** (unten). Ohne S.5 wäre der automatische Abgleich fehlerhaft: (a) jede Entfernung
        (Wort aus dem Leitner, Wort aus einer Liste, Liste gelöscht) käme beim nächsten Abgleich vom
        Server zurück, weil Zusammenführen nur vereinigt; (b) jede Sicherung trüge ~830 **App-Wörter**
        (die Seed-Daten aus `assets/data/`) als „eigene Wörter" mit — mehrere hundert Kilobyte je
        Konto-Zeile statt weniger Kilobyte.
        **Form (VOX, anders als Root-in):** Weil VOX zusammenführt statt zu überschreiben, ist der
        Abgleich ein echter Abgleich — holen → zusammenführen → nur bei Änderung hochladen. Kein
        Bestätigungsdialog nötig, denn nichts geht verloren, was nicht ausdrücklich entfernt wurde.
        **Umgesetzt:**
        · `core/backup/cloud_abgleich.dart` — Ablauf ohne Supabase (`CloudAblage` austauschbar).
          Neuere Fassung auf dem Server ⇒ `zuNeu`: weder einspielen noch überschreiben.
          Gleichheit über geordnetes JSON (der Server ordnet `jsonb` um); `NutzerZustand.toJson()`
          gibt Listen dafür geordnet aus.
        · `core/services/cloud_ablage_supabase.dart` — `vox_backups` (Abfrageform aus Root-in).
        · `features/more/controllers/konto_abgleich.dart` — wann: bei Anmeldung/Start mit Sitzung,
          alle 5 Minuten, und von Hand. Stumm bei Fehlern; danach `neuLaden()` + Einstellungen neu.
          `app.dart` hält ihn über `kontoAbgleichStarterProvider` am Leben (ohne Neubau der App).
        · Einstellungen → Konto: Hinweis, „آخرین کپی" (Serverzeit), Knopf «همگام‌سازی».
        · 7 Schlüssel FA/EN + Paritätstest; `test/cloud_abgleich_test.dart` (7 Tests, Server im Speicher).
        ⚠️ **Wirkt erst, wenn Lukas** die Secrets `SUPABASE_URL`/`SUPABASE_ANON_KEY` im vox-Repo
        setzt und `supabase/vox_tables.sql` einmal ausführt. Bis dahin: keine Rubrik, kein Timer.
  - [x] **S.3 Konto löschen ✅ L.1d (2026-09-22):** Entscheidung Lukas — ein Konto, ein Löschen, für BEIDE Apps.
        VOX ruft `delete_own_account()` (jetzt auch in `vox_tables.sql` §5).
  ⚠️ **Voraussetzung für Schritt 2:** die Secrets `SUPABASE_URL` und `SUPABASE_ANON_KEY` im
  vox-Repo (Settings → Secrets and variables → Actions) und `supabase/vox_tables.sql` einmal im
  SQL-Editor des Supabase-Projekts ausgeführt. Bis dahin bleibt alles wirkungslos — aber heil.
- [x] **S.4 Ehrlicher Hinweis** ✅ (2026-09-16) — Einstellungen → «داده‌ی من» → Karte «پشتیبان»
      sagt jetzt, wo die Daten wirklich liegen. Da S.2 und S.3 gebaut sind, war die ursprüngliche
      Formulierung („solange S.2/S.3 fehlen") überholt; die Lücke, die bleibt: **ohne Server**
      (keine Secrets) gibt es keine Konto-Rubrik und damit auch keinen Satz, der sagt, dass nichts
      kopiert wird.
      · `settings_screen.dart` → `datenOrtSchluessel()` (reine Funktion): kein Server ⇒
        `backup_only_here` · Server, nicht angemeldet ⇒ `backup_only_here_signin` · angemeldet ⇒
        kein Hinweis (die Konto-Karte sagt dann selbst, dass kopiert wird).
      · `authAccountProvider` wird nur beobachtet, wenn es überhaupt einen Server gibt.
      · 2 Schlüssel FA/EN; `test/l10n_paritaet_test.dart` schützt jetzt auch die 10
        `backup_*`-Schlüssel aus S.2, die dort bisher fehlten.
      · Test: `test/datenort_hinweis_test.dart` (alle vier Zustände).
- [x] **S.5 Entfernungen und App-Wörter im Vertrag** ✅ (2026-09-15, CI grün) (Voraussetzung für S.3 Schritt 3) —
      Entscheidung von Claude (2026-09-15, im Rahmen von Lukas' Vollmacht; Lukas kann sie kippen):
      · **Mitgliedschaft = „letzte Handlung gewinnt"**, **Fortschritt = „höchstes Fach gewinnt"**
        (Lukas' Regel bleibt unverändert). Aufnehmen/Entfernen ist eine bewusste Handlung des
        Nutzers und hat einen Zeitpunkt; das Fach ist Lernfortschritt und geht nur vorwärts.
        Gleichstand ⇒ „drin" gewinnt (im Zweifel bleibt Fortschritt erhalten).
      · Neue Tabelle `Mitgliedschaften` (art · schluessel · wort · drin · am). Arten: `leitner`,
        `liste`, `listenwort`, `wort`. Jede Stelle, die aufnimmt oder entfernt, schreibt dort ein
        Ereignis — Archiv-Store (über die Fassade), `LeitnerDao`, `CategoryDao`, `WordDao`,
        `ImportService`.
      · Vertrag `nutzerZustandVersion` 1 → **2** (`mitgliedschaften`); Fassung 1 bleibt lesbar
        (ohne Ereignisse = „älter als jede Handlung").
      · `Words.ausApp` — der Seed setzt es (Seed-Marke `vocab_seeded_v2` → `v3`, alle Inserts
        sind Upserts, also exakt nach Daten, nicht geraten). Sicherungen tragen nur Wörter ohne
        diese Marke; Leitner- und Listenverweise auf App-Wörter bleiben erhalten (Text-ID).
      · Migration `schemaVersion` 5 → 6, generierter Code über `build-runner.yml` **auf einem
        Zweig**, erst danach nach `main`.
      **Umgesetzt:**
      · `nutzer_zustand.dart`: `Mitgliedschaft` + `spaetere()`; `zusammenfuehren()` entfernt,
        was die letzte Handlung entfernt hat — ein entferntes eigenes Wort nimmt seine
        Leitner-Karte und Listenplätze mit.
      · `app_database.dart`: Tabelle `Mitgliedschaften`, `Words.ausApp`, Migration v6 und die
        Protokoll-Helfer (`mitgliedschaftMerken`, `leitnerMerken`, `eigeneListeMerken`,
        `eigenesListenwortMerken`, `nutzerwortMerken[NachSchluessel]`).
        ⚠️ Zeitpunkt als **Millisekunden-Integer** (`amMs`), nicht `DateTimeColumn` — drift legt
        DateTime ohne `build.yaml` in Sekunden ab, zwei Handlungen in derselben Sekunde wären
        sonst gleichzeitig.
      · Protokolliert wird in: `LeitnerDao.addWord/removeCard`, `CategoryDao.insert/update/
        deleteCategory` + `add/removeWordFromCategory` (Umbenennen = alte Liste weg, neue da),
        `WordDao.insert/delete` (liefert jetzt die echte Nummer über den eindeutigen Schlüssel),
        `ImportService`, Archiv-Store über die Fassade.
      · Fassade: `lesen()` liefert Ereignisse und nur Nutzerwörter; `anwenden()` legt Ereignisse
        ab und setzt Entfernungen um (`_entfernen`, mehrfach ausführbar).
      · Seed-Marke `vocab_seeded_v3`, alle Seed-Wörter mit `ausApp: true`.
      · Tests: 8 neue in `nutzer_zustand_test.dart`, 2 in `user_state_repository_test.dart`
        (Entfernung wandert von Gerät A nach B und kommt nicht zurück · App-Wörter nicht in der
        Sicherung), Seed-Test prüft `ausApp`.
      ⚠️ **Grenze:** Umbenennen einer eigenen Liste auf Gerät A, während Gerät B offline Wörter in
      die alte Liste legt ⇒ diese Wörter gehen beim Abgleich mit der alten Liste. Selten; eine
      stabile Listen-id (statt des Namens) wäre die Lösung und ist als **S.6** vorgemerkt.
      → **gelöst durch S.6 (2026-09-16).**
- [x] **S.6 Feste Listen-id** ✅ (2026-09-16, `build_runner` + `analyze` + `test` auf dem Zweig
      `s6-listen-id` grün, danach nach `main`) — eigene Listen tragen eine geräteübergreifende id
      statt ihres Namens. **Warum:** Umbenennen war für den Abgleich „alte Liste weg, neue da"; Wörter,
      die ein anderes Gerät offline in die alte Liste legte, gingen verloren (Grenze aus S.5).
      · **Tabelle** `UserCategories` + `uid` (Text) + `nameAmMs` (Millisekunden, wann der Name
        vergeben wurde); eindeutiger Index `user_categories_uid` (als eigener Index, weil SQLite eine
        UNIQUE-Spalte nicht nachträglich anlegen kann). `schemaVersion` 6 → **7**.
      · **Migration ohne Bruch:** bestehende Listen bekommen `eigen:<Name>` — genau ihre bisherige id,
        damit Sicherungen, Server-Kopie und gespeicherte Ereignisse weiter passen und derselbe Name auf
        zwei alten Geräten weiter EINE Liste ist. Doppelter Name auf einem Gerät (war möglich): die
        älteste Zeile behält die alte id, jede weitere bekommt eine neue.
      · **Neue Listen:** `eigen:#` + 32 Hex (`neueEigeneListenId()` in `nutzer_zustand.dart`), einmal
        bei der Anlage vergeben, nie geändert. Das Präfix `eigen:` bleibt — daran trennt die Fassade
        eigene Listen von Archiv-Listen (`kat_<ms>`, die schon immer eine feste id hatten).
      · **Name beim Zusammenführen:** der später vergebene gewinnt (`KategorieStand.nameAm`); ohne
        Zeitpunkt oder bei Gleichstand bleibt der eigene. Vertrag `nutzerZustandVersion` 2 → **3**;
        Fassung 2 bleibt lesbar. `nameAm` steht nur im Text, wenn bekannt — alte Listen ändern ihren
        Text nicht, der Konto-Abgleich lädt nicht grundlos hoch.
      · **Umbenennen** (`CategoryDao.updateCategory`) ändert nur Name + `nameAmMs`, kein Ereignis mehr;
        Anlegen/Löschen protokollieren die feste id (`eigeneListeMerken(listenId)`).
      · **Fassade** sucht eigene Listen über `uid`, nicht über den Namen (`_eigeneListe`).
      · **Tests:** `test/migration_v7_test.dart` (echte Datei im Stand 6 → neu geöffnet: alte ids
        bleiben, doppelter Name bekommt neue id, Index wirkt) · 4 neue in `nutzer_zustand_test.dart`
        · 2 neue in `user_state_repository_test.dart` (A benennt um, B legt offline ein Wort hinein ⇒
        nach Abgleich auf beiden Geräten: gleiche id, neuer Name, Wort drin).
      ⚠️ **Folge:** zwei Geräte, die nach S.6 unabhängig je eine Liste „Reise" anlegen, haben danach
      zwei Listen „Reise" — ehrlich, denn es sind zwei Handlungen. Nichts geht verloren.
      ⚠️ Ein noch offener alter Tab (Fassung 2) sieht die Server-Kopie als „zu neu" und überschreibt
      sie nicht — genau dafür gibt es die Versionsprüfung.

**Planänderung 2026-09-15 — S.0a, damit die Blockade nicht alles aufhält.**
S.0 braucht `build_runner` und ist gesperrt. Statt zu warten, kommt eine **Fassade** davor —
reines Dart, kein Codegen:

- [x] **S.0a-1 `core/backup/nutzer_zustand.dart`** ✅ (2026-09-15, CI grün) — **der Vertrag**.
      Reines Dart, kennt weder drift noch SharedPreferences noch Flutter, deshalb vollständig
      prüfbar (`test/nutzer_zustand_test.dart`, 12 Fälle). Enthält:
      · `NutzerZustand` — leitner · kategorien · notizen · einstellungen · eigeneWoerter
      · Hülle `{version, exportedAt, app, payload}` mit `sicherungSchreiben`/`sicherungLesen`;
        fehlerhafte Dateien werfen `SicherungFehler` mit einem Grund, den man zeigen kann
      · `zusammenfuehren()` mit der Regel **höchstes Fach gewinnt** — getestet auch im Fall,
        dass der ÄLTERE Stand das höhere Fach hat (Offline-Arbeit darf nie verloren gehen),
        und auf Reihenfolge-Unabhängigkeit (a+b == b+a)
      ⚠️ **Wichtige Festlegung: Leitner-IDs sind Text, nie die drift-Nummer.** Archivkarten
      `adjektiv_stolz`, eigene Wörter `eigen:<wort>|<wortart>` (genau der eindeutige Schlüssel
      der Tabelle `Words`). Die fortlaufende `id` bezeichnet auf einem anderen Gerät ein anderes
      Wort — sie darf niemals in eine Sicherung geraten.
- [x] **S.0a-2 `core/backup/user_state_repository.dart`** ✅ (2026-09-15, CI grün) — die Fassade.
      `lesen()` holt beide Ablagen in EINEN `NutzerZustand`; `anwenden()` führt einen
      eingehenden Stand ein (immer über `zusammenfuehren`, also „höchstes Fach gewinnt") und
      verteilt ihn wieder korrekt: Archivkarten → SharedPreferences, eigene Wörter/Listen/
      Leitner-Karten → drift.
      · **Nichts wird je gelöscht** — eine Wiederherstellung darf nie Fortschritt kosten.
      · Einstellungen werden über eine **ausdrückliche Liste** gesichert
        (`einstellungsSchluessel`), damit kein technischer Marker wie `vocab_seed_version`
        in eine Sicherung gerät.
      · Die Prefs-Schlüssel sind jetzt öffentlich (`kVokabLeitnerKey` …) und werden von
        Store und Fassade geteilt — keine zweite Kopie.
      · Tests gegen eine ECHTE Datenbank im Speicher (`AppDatabase.forTesting`), darunter
        ein simulierter **Gerätewechsel** (Sicherung schreiben → leeres Gerät → einspielen)
        und ein Nachweis, dass zweimaliges Einspielen nichts verdoppelt.
⇒ **Seit S.0a kennt alles oberhalb nur noch `NutzerZustand`.** S.2 fasst die Ablagen nicht
  direkt an; es geht ausschließlich über die Fassade.

- [x] **S.0b** ✅ (2026-09-16, CI grün) — die Ablage unter der Fassade auf drift umgestellt.
      Neue Tabelle `ArchivLeitner` (Text-Primärschlüssel `wortId`, dieselben IDs wie in
      `nutzer_zustand.dart`), Migration `schemaVersion` 2 → 3. `user_state_repository.dart`
      liest/schreibt Archivkarten jetzt aus drift statt SharedPreferences; ein **Übergangspfad**
      übernimmt einmalig den alten `vokab_user_leitner_v1`-Stand (falls vorhanden, ohne
      etwas Neueres in drift zu überschreiben — dieselbe „höchstes Fach gewinnt"-Regel) und
      leert danach den alten Schlüssel.
- [x] **S.0c** ✅ (2026-09-16, CI grün beim ersten Versuch) — Archiv-Listen ebenfalls nach
      drift. Zwei neue Tabellen (n:m wie bei den eigenen Listen): `ArchivKategorien` (id, name)
      + `ArchivKategorieWoerter` (kategorieId, wortId), Migration `schemaVersion` 3 → 4.
      Derselbe Übergangspfad wie S.0b: alter `vokab_user_kategorien_v1`-Stand wird einmalig
      übernommen (nur wo drift die id noch nicht kennt) und der Schlüssel danach geleert.
      Notizen bleiben bewusst in SharedPreferences — Freitext ist kein Kandidat für eine
      eigene Tabelle.
      ⚠️ **Diesmal keine eigenen Fehler** — Lehre aus S.0b direkt angewendet: Schema-Commit und
      `build-runner`-Dispatch unmittelbar hintereinander (keine rote Zwischen-Zeile im
      Actions-Log), und die neuen Tests per `str_replace` gegen eine bekannte, eindeutige
      Endzeile eingefügt statt per Datei-Anhängen — damit landen sie garantiert innerhalb von
      `main() { … }`.
      ⚠️ **Werkzeug dafür neu gebaut:** `.github/workflows/build-runner.yml` — führt
      `dart run build_runner build` aus der Ferne aus und committet nur bei grünem
      `analyze`+`test`. Nützlich für jede künftige Drift-Änderung, nicht nur S.0b.
      ⚠️ **Zwei eigene Fehler dabei, beide vor dem grünen Lauf behoben:**
      erstens ein Zwischen-Commit (Schema ohne den dazu passenden generierten Code), der
      genau EINEN `deploy-web`-Lauf rot machte, bevor der Codegen-Lauf folgte — Lehre:
      Schema-Änderung und `build_runner`-Commit so dicht wie möglich hintereinander schicken;
      zweitens ein Python-Skript, das zwei neue Tests HINTER die schließende Klammer von
      `main()` statt davor eingefügt hat (Syntaxfehler, `flutter analyze` rot). Lehre: beim
      Anhängen an eine bestehende Dart-Datei immer die genaue Einfügestelle prüfen, nicht
      blind ans Dateiende hängen.

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
      `assets/vocab/` حساب می‌کند **کلمه‌ی بعدی کدام است** (بر اساس فایل‌های موجود، نه مارک‌ها).
      خروجی: لیست N کلمه‌ی بعدی به ترتیب الفبا + گزارش پوشش per Wortart.
- [x] **A.2 `tool/sync_backlog.py`** ✅ (2026-09-15) — **اجرا شد: ۴۵ مارک نو، ۰ حذف؛ اجرای دوم بدون تغییر (idempotent)** — مارک‌های `✓ ` را از روی `assets/vocab/` بازسازی می‌کند
      (رفع ناهماهنگی Audit). idempotent؛ `--dry-run` دارد.
- [x] **A.3 `tool/generate_words.py`** ✅ (2026-09-15) — با `--dry-run` تست شد؛ سقف امن ۵۰۰ کارت سخت‌کد شده (`--grenze`) — Generator: N کلمه از A.1 می‌گیرد، SUPER-PROMPT v3.0 را
      از `old files Lukasalmani/Wort prompt` می‌خواند (**یک منبع** — کپی نمی‌شود)، batch را به
      Anthropic API می‌فرستد، خروجی را pre-flight می‌کند و در `import_inbox/` می‌نویسد.
      ⚠️ نیاز به `ANTHROPIC_API_KEY` (Secret) — هزینه دارد و باید شفاف گزارش شود.
- [x] **A.4 `.github/workflows/vokabular-autofill.yml`** ✅ (2026-09-16, CI grün) —
      Lukas hat ein neues Fine-grained-PAT mit **Contents + Workflows + Actions: Read and write**
      erzeugt (Repos: nur `vox` + `Root-in`, bewusst nicht „All repositories"). Damit war der
      Push sofort möglich — dieselbe Datei, die vorher mit „Resource not accessible" abgelehnt
      wurde. Braucht noch das Secret `ANTHROPIC_API_KEY`, bevor ein echter (Nicht-Probe-)Lauf
      Kosten verursacht. — `workflow_dispatch` (+ اختیاری `schedule`):
      A.3 → `dart run tool/vokabular_import.dart` (اعتبارسنجی واقعی) → A.2 → `flutter analyze` +
      `flutter test` → commit. **اگر Fehler > 0 یا تست قرمز: هیچ چیز commit نمی‌شود.**
      ورودی‌ها: `anzahl` (چند کلمه)، `gruppe` (adjektive/verben/nomen)، `dry_run`.
- [x] **A.5** ✅ گزارش: هر اجرا یک خلاصه در Job-Summary (چند کلمه، چند Warnung، هزینه‌ی تقریبی).
- [!] **A.6 ⛔ روش ساخت کلمه‌ها — تصمیم با Lukas (ثبت 2026-09-16)**
      **⚠️ قاعده برای Claude:** این قدم را **هرگز خودسرانه شروع نکن** — حتی اگر اولین قدم باز PLAN باشد
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
تصمیم A.6 با Lukas است.
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
> ⚠️ **2026-09-19: این بخش منسوخ است — فقط تاریخچه.** نسخه‌ی بومی (iOS/Android/RevenueCat) از 2026-09-13 حذف شد؛ فهرست معتبر = **فاز LAUNCH → L.3**. (در کد بررسی شد: پوشه‌های android/ios/… و هر ارجاع RevenueCat/purchases_* در `lib/`، `test/`، `pubspec.yaml` وجود ندارد.)
- [⛔] ~~16.1 تست دستی iOS Simulator~~ — ⛔ منسوخ (وب‌اپ، 2026-09-13)؛ جایگزین: تست آیفون واقعی در L.3
- [⛔] ~~16.2 تست دستی Android Emulator~~ — ⛔ منسوخ (وب‌اپ، 2026-09-13)
- [x] 16.3 تست RTL فارسی همه صفحات ✅ (2026-09-18) — باگ پیدا و رفع شد؛ Lukas تأیید کرد (جزئیات: L.3 «تست RTL»)
- [ ] 16.4 تست آفلاین (airplane mode) — ⏸️ ادامه در L.3 «تست آفلاین» (منتظر خروجی DevTools از Lukas)
- [x] 16.5 آیکون در assets/images/app_icon.png + app_icon_fg.png ✅ (2026-07-03) — 1254×1254px
- [x] 16.6 dart run flutter_launcher_icons ✅ (2026-07-03) — Android adaptive + iOS generated
- [x] 16.7 dart run flutter_native_splash:create ✅ (2026-06-30) — light #F5F5FA / dark #0A0A0F
- [⛔] 16.8 RevenueCat API keys ✅ (2026-06-30) — ⛔ بعداً حذف شد (2026-09-13؛ تاریخچه)
- [⛔] 16.8b RevenueCat SDK ✅ (2026-06-30) — ⛔ بعداً حذف شد (2026-09-13؛ در کد نیست)
      purchases_ui_flutter اضافه، subscription_service.dart (Riverpod)، paywall + customer center
- [⛔] ~~16.9 App Store Connect + Google Play metadata~~ — ⛔ منسوخ (وب‌اپ، 2026-09-13)
- [⛔] ~~16.10 flutter build ios/appbundle~~ — ⛔ منسوخ (وب‌اپ، 2026-09-13)
- [⛔] ~~16.11 TestFlight + Android test track~~ — ⛔ منسوخ (وب‌اپ، 2026-09-13)
- [⛔] ~~16.12 submit review~~ — ⛔ منسوخ (وب‌اپ، 2026-09-13)

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
| ~~Subscriptions~~ | ~~RevenueCat~~ | ⛔ حذف شد (2026-09-13) — وب‌اپ رایگان، بدون اشتراک |
| Font | Vazirmatn (google_fonts) | FA+DE+EN یک فونت |
| Color API | withValues(alpha:) | withOpacity deprecated |
| L10n | strings در app_l10n.dart | بدون .arb files |
| DAO | Plain Dart class | بدون @DriftAccessor |
| Upsert | DoUpdate(target:[german,wordType]) | UNIQUE constraint صحیح |
