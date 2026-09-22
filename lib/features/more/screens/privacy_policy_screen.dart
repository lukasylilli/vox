// FILE: lib/features/more/screens/privacy_policy_screen.dart
// DEPS: -
// PURPOSE: متن سیاست حریم خصوصی VOX (نسخه وب)
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.t(context, 'privacy_title'))),
      body  : ListView(
        padding : const EdgeInsets.all(AppSizes.md),
        children: [
          _Section(
            AppL10n.meaning(context, fa: 'آخرین بروزرسانی', en: 'Last updated'),
            AppL10n.meaning(context, fa: '۳۱ شهریور ۱۴۰۵', en: '22 September 2026'),
          ),
          _Section(
            AppL10n.meaning(context, fa: 'جمع‌آوری داده‌ها', en: 'Data collection'),
            AppL10n.meaning(context,
              fa: 'VOX بدون نیاز به حساب کاربری کار می‌کند. به‌طور پیش‌فرض هیچ داده‌ی '
                  'شخصی روی سرور ذخیره نمی‌شود؛ تمام اطلاعات (واژگان، پیشرفت، عادت‌ها) '
                  'فقط در مرورگر روی همین دستگاه شما ذخیره می‌شوند.',
              en: 'VOX works without any account. By default, no personal data is '
                  'stored on any server; all information (vocabulary, progress, '
                  'habits) is kept only in your browser on this device.'),
          ),
          _Section(
            AppL10n.meaning(context, fa: 'حساب کاربری (اختیاری)', en: 'Account (optional)'),
            AppL10n.meaning(context,
              fa: 'اگر خودتان از صفحه‌ی «پروفایل و حساب» یک حساب بسازید، ایمیل شما و یک نسخه‌ی '
                  'پشتیبان از پیشرفت‌تان (واژگان، Leitner، عادت‌ها) روی سرور Supabase '
                  'ذخیره می‌شود تا بین چند دستگاه هماهنگ بماند. بدون ساختن حساب، هیچ‌چیز '
                  'به سرور فرستاده نمی‌شود.',
              en: 'If you choose to create an account on the Profile & account page, your email and a '
                  'backup copy of your progress (vocabulary, Leitner state, habits) '
                  'are stored on our Supabase server so it can sync across devices. '
                  'Without creating an account, nothing is sent to any server.'),
          ),
          _Section(
            AppL10n.meaning(context, fa: 'حذف حساب', en: 'Deleting your account'),
            AppL10n.meaning(context,
              fa: 'در صفحه‌ی «پروفایل و حساب» با دکمه‌ی «حذف حساب» می‌توانی حسابت را '
                  'هر وقت خواستی خودت برای همیشه حذف کنی: ایمیل، رمز و نسخه‌ی پشتیبان '
                  'روی سرور پاک می‌شوند. حساب VOX با اپ Root-in مشترک است؛ بنابراین '
                  'پشتیبان و نمایه‌ی Root-in همان حساب هم با آن پاک می‌شود. داده‌های '
                  'روی دستگاه خودت دست‌نخورده می‌مانند.',
              en: 'On the “Profile & account” page, the “Delete account” button lets '
                  'you delete your account yourself, for good, at any time: your '
                  'email, password and the backup on the server are removed. The '
                  'VOX account is shared with the Root-in app, so the Root-in backup '
                  'and profile of the same account are removed with it. The data on '
                  'your own device stays untouched.'),
          ),
          _Section(
            AppL10n.meaning(context,
                fa: 'اطلاعات شخصی (اختیاری)', en: 'Personal details (optional)'),
            AppL10n.meaning(context,
              fa: 'در صفحه‌ی «پروفایل و حساب» می‌توانی نام، شماره‌ی تلفن و آدرس‌هایت را '
                  'بنویسی. این بخش کاملاً اختیاری است و برای یادگیری لازم نیست. اطلاعات '
                  'در مرورگر خودت می‌ماند. فقط اگر حساب کاربری داشته باشی، همراه '
                  'نسخه‌ی پشتیبان خودت روی سرور Supabase هم ذخیره می‌شود؛ همین‌طور '
                  'در فایل پشتیبانی که خودت می‌گیری. جای دیگری فرستاده نمی‌شود و '
                  'هر وقت خواستی می‌توانی آن را پاک کنی.',
              en: 'On the “Profile & account” page you can enter your name, phone '
                  'number and addresses. This is entirely optional and not needed '
                  'for learning. The details stay in your browser. Only if you have '
                  'an account are they also stored on our Supabase server, together '
                  'with your own backup copy, and in the backup file you export '
                  'yourself. They are not sent anywhere else, and you can erase '
                  'them at any time.'),
          ),
          _Section(
            AppL10n.meaning(context, fa: 'میکروفون', en: 'Microphone'),
            AppL10n.meaning(context,
              fa: 'برای تمرین Shadowing (تلفظ) به میکروفون دسترسی داریم. '
                  'صدای شما ضبط یا ارسال نمی‌شود.',
              en: 'We access the microphone for Shadowing (pronunciation) practice. '
                  'Your voice is never recorded or transmitted.'),
          ),
          _Section(
            AppL10n.meaning(context, fa: 'اینترنت', en: 'Internet'),
            AppL10n.meaning(context,
              fa: 'VOX در مرورگر اجرا می‌شود و برای بارگذاری اولیه و بخش اخبار (RSS) '
                  'به اینترنت نیاز دارد؛ اگر حساب بسازید، برای هماهنگ‌سازی هم به '
                  'اینترنت نیاز است.',
              en: 'VOX runs in your browser and needs the internet for the initial '
                  'load and the news section (RSS); if you create an account, it '
                  'also needs the internet to sync.'),
          ),
          _Section(
            AppL10n.meaning(context, fa: 'تماس با ما', en: 'Contact us'),
            AppL10n.meaning(context,
              fa: 'سوال یا مشکل دارید؟ از قسمت Fragen & Antworten با ما در تماس باشید.',
              en: 'Have a question or problem? Reach us via the Fragen & Antworten section.'),
          ),
          const SizedBox(height: AppSizes.lg),
          Center(
            child: Text(
              AppL10n.meaning(context,
                  fa: '© ۱۴۰۵ VOX — یادگیری آلمانی',
                  en: '© 2026 VOX — Learning German'),
              style: TextStyle(
                color   : scheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.body);
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.lg),
      child  : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(body,
              style: TextStyle(
                color : scheme.onSurfaceVariant,
                height: 1.7,
              )),
        ],
      ),
    );
  }
}
