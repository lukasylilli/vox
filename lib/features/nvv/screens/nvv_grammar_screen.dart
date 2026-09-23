// FILE: lib/features/nvv/screens/nvv_grammar_screen.dart
// PURPOSE: Grammar explanation for Nomen-Verb-Verbindungen (NVV) — bilingual FA/EN
import 'package:flutter/material.dart';

import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/deutsch_text.dart';

class NvvGrammarScreen extends StatelessWidget {
  const NvvGrammarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.t(context, 'nvv_grammar_title'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          _Card(
            icon : Icons.menu_book_rounded,
            title: AppL10n.meaning(context,
                fa: 'Nomen-Verb-Verbindungen چیست؟',
                en: 'What are Nomen-Verb-Verbindungen?'),
            child: Text(
              AppL10n.meaning(context,
                fa: 'ترکیب‌های اسم-فعل (NVV) عبارت‌های ثابتی هستند که از یک اسم و یک فعل تشکیل شده‌اند '
                    'و با هم یک معنای واحد می‌دهند. این ترکیب‌ها در زبان نوشتاری و رسمی آلمانی بسیار '
                    'رایج هستند و باید به عنوان یک واحد یاد گرفته شوند.',
                en: 'Noun-verb combinations (NVV) are fixed expressions made up of a noun and a verb '
                    'that together carry a single meaning. They are very common in written and formal '
                    'German and should be learned as a unit.'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.8),
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            icon : Icons.compare_arrows_rounded,
            title: AppL10n.meaning(context,
                fa: 'NVV در مقابل فعل ساده', en: 'NVV vs. simple verb'),
            child: Column(
              children: const [
                _CompareRow(simple: 'helfen', nvv: 'Hilfe leisten',
                    fa: 'کمک کردن', en: 'to help'),
                _CompareRow(simple: 'entscheiden', nvv: 'eine Entscheidung treffen',
                    fa: 'تصمیم گرفتن', en: 'to decide'),
                _CompareRow(simple: 'fragen', nvv: 'eine Frage stellen',
                    fa: 'سوال پرسیدن', en: 'to ask a question'),
                _CompareRow(simple: 'kontrollieren', nvv: 'eine Kontrolle durchführen',
                    fa: 'کنترل انجام دادن', en: 'to carry out a check'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            icon : Icons.category_outlined,
            title: AppL10n.meaning(context,
                fa: 'افعال رایج در NVV', en: 'Common verbs in NVV'),
            child: Column(
              children: _commonVerbs.map((v) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        v.$1,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        v.$2,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            icon : Icons.lightbulb_outline_rounded,
            title: AppL10n.t(context, 'key_tips'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _Tip(fa: 'اسم در NVV معمولاً بدون حرف تعریف می‌آید: eine Frage stellen → Frage stellen',
                     en: 'The noun in an NVV usually appears without an article: eine Frage stellen → Frage stellen'),
                SizedBox(height: 6),
                _Tip(fa: 'موضع فعل مطابق قواعد عادی آلمانی است — اسم در موضع مفعول',
                     en: 'The verb position follows normal German rules — the noun sits in the object slot'),
                SizedBox(height: 6),
                _Tip(fa: 'در آزمون‌های B2/C1 استفاده از NVV به جای فعل ساده نشانه سطح بالاست',
                     en: 'In B2/C1 exams, using an NVV instead of a simple verb signals a higher level'),
                SizedBox(height: 6),
                _Tip(fa: 'هر NVV را با مثال یاد بگیر، نه فقط ترجمه',
                     en: 'Learn each NVV with an example, not just its translation'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            icon : Icons.edit_note_rounded,
            title: AppL10n.t(context, 'example'),
            child: Column(
              children: const [
                _ExampleRow(
                  de: 'Der Minister traf eine wichtige Entscheidung.',
                  fa: 'وزیر یک تصمیم مهم گرفت.',
                  en: 'The minister made an important decision.',
                ),
                _ExampleRow(
                  de: 'Sie stellte eine interessante Frage.',
                  fa: 'او یک سوال جالب پرسید.',
                  en: 'She asked an interesting question.',
                ),
                _ExampleRow(
                  de: 'Wir müssen Rücksicht auf andere nehmen.',
                  fa: 'باید به دیگران احترام بگذاریم.',
                  en: 'We must be considerate of others.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // German collocation lists — no translation (German content).
  static const _commonVerbs = [
    ('machen',    'Fortschritte, Pause, Fehler, Erfahrung...'),
    ('nehmen',    'Rücksicht, Bezug, Abschied, Einfluss...'),
    ('treffen',   'Entscheidung, Maßnahme, Vereinbarung...'),
    ('stellen',   'Frage, Antrag, Bedingung, Diagnose...'),
    ('leisten',   'Hilfe, Beitrag, Widerstand, Arbeit...'),
    ('geben',     'Antwort, Bescheid, Auskunft, Erlaubnis...'),
    ('ziehen',    'Schluss, Konsequenz, Bilanz...'),
    ('führen',    'Gespräch, Diskussion, Kontrolle...'),
  ];
}

// ─── widgets ──────────────────────────────────────────────────────────────────

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.simple,
    required this.nvv,
    required this.fa,
    required this.en,
  });
  final String simple, nvv, fa, en;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(simple, style: TextStyle(
                  color: cs.primary, fontWeight: FontWeight.w600)),
                Text(AppL10n.meaning(context, fa: fa, en: en),
                    style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_rounded, size: 14, color: cs.outline),
          const SizedBox(width: 8),
          Expanded(
            child: Text(nvv, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.fa, required this.en});
  final String fa, en;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontWeight: FontWeight.w700)),
        Expanded(
          child: Text(AppL10n.meaning(context, fa: fa, en: en),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.6)),
        ),
      ],
    );
  }
}

class _ExampleRow extends StatelessWidget {
  const _ExampleRow({required this.de, required this.fa, required this.en});
  final String de, fa, en;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeutschText(de, style: const TextStyle(fontStyle: FontStyle.italic)),
          Text(AppL10n.meaning(context, fa: fa, en: en),
              style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.icon, required this.title, required this.child});
  final IconData icon;
  final String   title;
  final Widget   child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child : Padding(
        padding: const EdgeInsets.all(14),
        child  : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
