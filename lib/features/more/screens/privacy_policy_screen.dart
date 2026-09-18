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
            AppL10n.meaning(context, fa: '۲۷ شهریور ۱۴۰۵', en: '18 September 2026'),
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
              fa: 'اگر خودتان از بخش تنظیمات یک حساب بسازید، ایمیل شما و یک نسخه‌ی '
                  'پشتیبان از پیشرفت‌تان (واژگان، Leitner، عادت‌ها) روی سرور Supabase '
                  'ذخیره می‌شود تا بین چند دستگاه هماهنگ بماند. بدون ساختن حساب، هیچ‌چیز '
                  'به سرور فرستاده نمی‌شود.',
              en: 'If you choose to create an account in Settings, your email and a '
                  'backup copy of your progress (vocabulary, Leitner state, habits) '
                  'are stored on our Supabase server so it can sync across devices. '
                  'Without creating an account, nothing is sent to any server.'),
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
