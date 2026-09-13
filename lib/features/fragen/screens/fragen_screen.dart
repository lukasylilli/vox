// FILE: lib/features/fragen/screens/fragen_screen.dart
// DEPS: app_l10n.dart
// PURPOSE: سوالات متداول درباره اپ VOX — دوزبانه (فارسی/انگلیسی از Settings)
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';

class FragenScreen extends StatelessWidget {
  const FragenScreen({super.key});

  static const _faqs = [
    (
      qFa: 'VOX چیست؟',
      qEn: 'What is VOX?',
      aFa: 'VOX یک اپلیکیشن جامع یادگیری زبان آلمانی است که برای فارسی‌زبانان طراحی شده. '
          'شامل واژگان، گرامر، مهارت‌های خواندن، شنیدن و آزمون‌های رسمی می‌شود.',
      aEn: 'VOX is a comprehensive German-learning app designed for Persian speakers. '
          'It covers vocabulary, grammar, reading and listening skills, and official exams.',
    ),
    (
      qFa: 'چطور می‌توانم واژه اضافه کنم؟',
      qEn: 'How can I add a word?',
      aFa: 'در بخش Wortschatz، دکمه + را بزن. می‌توانی واژه آلمانی، معنی فارسی، '
          'مثال و نوع کلمه را وارد کنی.',
      aEn: 'In the Wortschatz section, tap the + button. You can enter the German word, '
          'its meaning, an example and the word type.',
    ),
    (
      qFa: 'سیستم Leitner چیست؟',
      qEn: 'What is the Leitner system?',
      aFa: 'Leitner یک روش تکرار فاصله‌ای است. واژه‌هایی که درست جواب دادی به جعبه '
          'بعدی می‌روند و دیرتر مرور می‌شوند. واژه‌های اشتباه به جعبه اول برمی‌گردند.',
      aEn: 'Leitner is a spaced-repetition method. Words you answer correctly move to the '
          'next box and are reviewed less often. Wrong answers go back to the first box.',
    ),
    (
      qFa: 'آیا اپ آفلاین کار می‌کند؟',
      qEn: 'Does the app work offline?',
      aFa: 'بله! همه داده‌ها روی دستگاه ذخیره می‌شوند. فقط بخش اخبار (RSS) نیاز به '
          'اینترنت دارد.',
      aEn: 'Yes! All data is stored on your device. Only the news section (RSS) needs '
          'an internet connection.',
    ),
    (
      qFa: 'Pomodoro چطور کار می‌کند؟',
      qEn: 'How does Pomodoro work?',
      aFa: '۲۵ دقیقه تمرکز کامل، سپس ۵ دقیقه استراحت. بعد از ۴ جلسه، استراحت ۱۵ دقیقه‌ای '
          'داری. می‌توانی Pomodoro را به یک عادت خاص لینک کنی.',
      aEn: '25 minutes of full focus, then a 5-minute break. After 4 sessions you get a '
          '15-minute break. You can link Pomodoro to a specific habit.',
    ),
    (
      qFa: 'آزمون‌های Goethe، TELC و ÖSD چیستند؟',
      qEn: 'What are the Goethe, TELC and ÖSD exams?',
      aFa: 'این‌ها آزمون‌های رسمی زبان آلمانی هستند که توسط سازمان‌های رسمی اروپایی '
          'برگزار می‌شوند. بخش Prüfungen سوالات شبیه‌سازی‌شده این آزمون‌ها را ارائه می‌دهد.',
      aEn: 'These are official German-language exams run by recognised European bodies. '
          'The Prüfungen section offers simulated questions for these exams.',
    ),
    (
      qFa: 'چطور سطح یادگیری‌ام را تغییر دهم؟',
      qEn: 'How do I change my learning level?',
      aFa: 'در تنظیمات (Einstellungen) بخش "سطح یادگیری" را پیدا کن و از A1 تا C2 انتخاب کن.',
      aEn: 'In Settings (Einstellungen), find the "learning level" section and choose from A1 to C2.',
    ),
    (
      qFa: 'آیا VOX رایگان است؟',
      qEn: 'Is VOX free?',
      aFa: 'بله. VOX کاملاً رایگان و متن‌باز است — بدون اشتراک و بدون ثبت‌نام. '
          'اپ مستقیماً در مرورگر اجرا می‌شود و پیشرفت شما فقط روی همین دستگاه ذخیره می‌شود.',
      aEn: 'Yes. VOX is completely free and open source — no subscription, no sign-up. '
          'It runs right in your browser and your progress is stored only on this device.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fragen & Antworten')),
      body  : ListView.separated(
        padding         : const EdgeInsets.all(AppSizes.md),
        itemCount       : _faqs.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSizes.sm),
        itemBuilder     : (_, i) => _FaqCard(faq: _faqs[i]),
      ),
    );
  }
}

class _FaqCard extends StatefulWidget {
  const _FaqCard({required this.faq});
  final ({String qFa, String qEn, String aFa, String aEn}) faq;

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final q = AppL10n.meaning(context, fa: widget.faq.qFa, en: widget.faq.qEn);
    final a = AppL10n.meaning(context, fa: widget.faq.aFa, en: widget.faq.aEn);
    return Card(
      child: InkWell(
        onTap        : () => setState(() => _open = !_open),
        borderRadius : BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child  : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(q,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize  : 14,
                        )),
                  ),
                  Icon(
                    _open
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
              if (_open) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Text(a,
                    style: TextStyle(
                      color : scheme.onSurfaceVariant,
                      height: 1.6,
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
