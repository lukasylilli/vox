// FILE: lib/features/praepositionen/screens/praepositionen_grammar_screen.dart
// PURPOSE: Grammar explanation for Verben/Adjektive/Nomen + Präpositionen — bilingual FA/EN
import 'package:flutter/material.dart';

import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/deutsch_text.dart';

class PraepositonenGrammarScreen extends StatelessWidget {
  const PraepositonenGrammarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.t(context, 'praep_grammar_title'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          _Card(
            icon : Icons.menu_book_rounded,
            title: AppL10n.meaning(context,
                fa: 'ترکیب‌های Verb/Adjektiv/Nomen + Präposition',
                en: 'Verb/Adjective/Noun + Präposition combinations'),
            child: Text(
              AppL10n.meaning(context,
                fa: 'در آلمانی بسیاری از افعال، صفت‌ها و اسم‌ها به یک حرف اضافه مشخص نیاز دارند. '
                    'این ترکیب‌ها ثابت هستند و باید حفظ شوند — قانون عمومی وجود ندارد. '
                    'حرف اضافه معنای فعل را عوض می‌کند و حالت دستوری (Kasus) را تعیین می‌کند.',
                en: 'In German, many verbs, adjectives and nouns require a specific preposition. '
                    'These combinations are fixed and must be memorised — there is no general rule. '
                    'The preposition changes the meaning of the verb and determines the case (Kasus).'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.8),
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            icon : Icons.category_outlined,
            title: AppL10n.meaning(context,
                fa: 'حرف اضافه‌های رایج و کازوس آنها',
                en: 'Common prepositions and their case'),
            child: Column(
              children: _praepKasus.map((r) => _PraepRow(r.$1, r.$2, r.$3)).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            icon : Icons.compare_arrows_rounded,
            title: AppL10n.meaning(context,
                fa: 'تفاوت معنا با حرف اضافه مختلف',
                en: 'Different preposition, different meaning'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _DiffRow(
                  verb: 'denken',
                  prep1: 'an + Akk', mean1: 'فکر کردن به', mean1En: 'to think of',
                  prep2: 'über + Akk', mean2: 'در مورد چیزی فکر کردن', mean2En: 'to reflect on something',
                ),
                SizedBox(height: 8),
                _DiffRow(
                  verb: 'warten',
                  prep1: 'auf + Akk', mean1: 'منتظر بودن برای', mean1En: 'to wait for',
                  prep2: 'mit + Dat', mean2: 'تاخیر در شروع', mean2En: 'to hold off starting',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            icon : Icons.edit_note_rounded,
            title: AppL10n.meaning(context,
                fa: 'ضمیر پرسشی: worüber / worauf / woran ...',
                en: 'Interrogatives: worüber / worauf / woran ...'),
            child: Text(
              AppL10n.meaning(context,
                fa: 'برای پرسش از ترکیب فعل + حرف اضافه از ضمیر مرکب استفاده می‌شود:\n\n'
                    '• woran denkst du? (به چه فکر می‌کنی؟)\n'
                    '• worauf wartest du? (منتظر چه هستی؟)\n'
                    '• womit bist du zufrieden? (از چه راضی هستی؟)\n\n'
                    'اگر به انسان اشاره شود: an wen / auf wen / mit wem ...',
                en: 'To ask about a verb+preposition combination, use a compound interrogative:\n\n'
                    '• woran denkst du? (what are you thinking of?)\n'
                    '• worauf wartest du? (what are you waiting for?)\n'
                    '• womit bist du zufrieden? (what are you satisfied with?)\n\n'
                    'When referring to a person: an wen / auf wen / mit wem ...'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.8),
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            icon : Icons.lightbulb_outline_rounded,
            title: AppL10n.t(context, 'key_tips'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _Tip(fa: 'حرف اضافه و کازوسش را همیشه با هم حفظ کن: "abhängen von + Dat"',
                     en: 'Always memorise the preposition together with its case: "abhängen von + Dat"'),
                SizedBox(height: 6),
                _Tip(fa: 'ترکیب را با مثال کامل یاد بگیر، نه فقط فعل + حرف اضافه',
                     en: 'Learn the combination with a full example, not just verb + preposition'),
                SizedBox(height: 6),
                _Tip(fa: 'در B2/C1 استفاده صحیح از این ترکیب‌ها بسیار مهم است',
                     en: 'At B2/C1, using these combinations correctly is very important'),
                _Tip(fa: 'Reflexivverben (افعال بازتابی) اغلب با حرف اضافه مشخص می‌آیند',
                     en: 'Reflexive verbs (Reflexivverben) often come with a specific preposition'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // German collocation lists — no translation (German content).
  static const _praepKasus = [
    ('an',   'Akkusativ', 'denken an, glauben an, sich erinnern an'),
    ('auf',  'Akkusativ', 'warten auf, hoffen auf, achten auf, sich freuen auf'),
    ('für',  'Akkusativ', 'danken für, sich interessieren für, sorgen für'),
    ('über', 'Akkusativ', 'sprechen über, nachdenken über, sich ärgern über'),
    ('um',   'Akkusativ', 'bitten um, kämpfen um, sich handeln um'),
    ('von',  'Dativ',     'abhängen von, träumen von, sich verabschieden von'),
    ('mit',  'Dativ',     'beginnen mit, aufhören mit, zufrieden sein mit'),
    ('bei',  'Dativ',     'helfen bei, bleiben bei'),
    ('in',   'Dativ',     'bestehen in, sich unterscheiden in'),
    ('nach', 'Dativ',     'suchen nach, fragen nach, riechen nach'),
    ('zu',   'Dativ',     'gehören zu, beitragen zu, führen zu'),
  ];
}

// ─── widgets ──────────────────────────────────────────────────────────────────

class _PraepRow extends StatelessWidget {
  const _PraepRow(this.prep, this.kasus, this.examples);
  final String prep, kasus, examples;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width  : 52,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color       : cs.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: DeutschText(ganzeZeile: false, prep,
                style: TextStyle(
                  color     : cs.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                  fontSize  : 12,
                ),
                textAlign: TextAlign.center),
          ),
          const SizedBox(width: 8),
          Container(
            width  : 68,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color       : cs.secondaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: DeutschText(ganzeZeile: false, kasus,
                style: TextStyle(
                  color   : cs.onSecondaryContainer,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DeutschText(
              examples,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiffRow extends StatelessWidget {
  const _DiffRow({
    required this.verb,
    required this.prep1,
    required this.mean1,
    required this.mean1En,
    required this.prep2,
    required this.mean2,
    required this.mean2En,
  });
  final String verb, prep1, mean1, mean1En, prep2, mean2, mean2En;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeutschText(ganzeZeile: false, verb, style: const TextStyle(
          fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 4),
        _row(prep1, AppL10n.meaning(context, fa: mean1, en: mean1En), cs),
        _row(prep2, AppL10n.meaning(context, fa: mean2, en: mean2En), cs),
      ],
    );
  }

  Widget _row(String prep, String mean, ColorScheme cs) => Padding(
    padding: const EdgeInsets.only(top: 2, right: 8),
    child: Row(
      children: [
        Text('$verb $prep',
            style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
        Text(' — $mean',
            style: TextStyle(color: cs.onSurfaceVariant)),
      ],
    ),
  );
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
