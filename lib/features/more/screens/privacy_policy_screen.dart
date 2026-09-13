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
            AppL10n.meaning(context, fa: '۲۲ شهریور ۱۴۰۵', en: '13 September 2026'),
          ),
          _Section(
            AppL10n.meaning(context, fa: 'جمع‌آوری داده‌ها', en: 'Data collection'),
            AppL10n.meaning(context,
              fa: 'VOX هیچ داده شخصی را روی سرور ذخیره نمی‌کند و به ثبت‌نام نیازی ندارد. '
                  'تمام اطلاعات (واژگان، پیشرفت، عادت‌ها) '
                  'فقط در مرورگر روی دستگاه شما ذخیره می‌شوند.',
              en: 'VOX stores no personal data on any server and needs no account. '
                  'All information (vocabulary, progress, habits) is kept only in '
                  'your browser on this device.'),
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
              fa: 'VOX در مرورگر اجرا می‌شود؛ برای بارگذاری اپ و بخش اخبار (RSS) '
                  'به اینترنت نیاز است.',
              en: 'VOX runs in your browser; the internet is needed to load the app '
                  'and for the news section (RSS).'),
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
