// FILE: lib/features/selbstlernen/screens/leitfaden_screen.dart
// DEPS: mountain_progress_widget.dart
// PURPOSE: مسیر یادگیری A1 تا C2 — نقشه کوهستانی + راهنمای هر سطح
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../widgets/mountain_progress_widget.dart';

class LeitfadenScreen extends StatefulWidget {
  const LeitfadenScreen({super.key});

  @override
  State<LeitfadenScreen> createState() => _LeitfadenScreenState();
}

class _LeitfadenScreenState extends State<LeitfadenScreen> {
  String _currentLevel = 'a1';

  static const _levels = [
    (
      key    : 'a1',
      label  : 'A1 — Anfänger',
      labelFa: 'مبتدی',
      labelEn: 'Beginner',
      desc   : 'حروف الفبا، اعداد، معرفی خود، رنگ‌ها، خانواده',
      descEn : 'Alphabet, numbers, introducing yourself, colours, family',
      skills : ['بیان اسم و سن', 'شمارش تا ۱۰۰', 'رنگ‌ها و اشیاء'],
      skillsEn: ['Stating name and age', 'Counting to 100', 'Colours and objects'],
      color  : Color(0xFF4CAF50),
    ),
    (
      key    : 'a2',
      label  : 'A2 — Grundstufe',
      labelFa: 'پایه',
      labelEn: 'Elementary',
      desc   : 'خرید، مسیرها، زمان گذشته، روزمره',
      descEn : 'Shopping, directions, past tense, daily life',
      skills : ['Perfekt و Präteritum', 'جهت‌یابی', 'خرید و پول'],
      skillsEn: ['Perfekt and Präteritum', 'Finding your way', 'Shopping and money'],
      color  : Color(0xFF8BC34A),
    ),
    (
      key    : 'b1',
      label  : 'B1 — Mittelstufe',
      labelFa: 'متوسط',
      labelEn: 'Intermediate',
      desc   : 'بیان نظر، رسانه، کار و شغل، سفر',
      descEn : 'Expressing opinions, media, work, travel',
      skills : ['Konjunktiv II', 'بحث کردن', 'نوشتن ایمیل رسمی'],
      skillsEn: ['Konjunktiv II', 'Discussing', 'Writing formal emails'],
      color  : Color(0xFFFFEB3B),
    ),
    (
      key    : 'b2',
      label  : 'B2 — Oberstufe',
      labelFa: 'بالاتر از متوسط',
      labelEn: 'Upper intermediate',
      desc   : 'متون پیچیده، بحث‌های انتزاعی، ادبیات ساده',
      descEn : 'Complex texts, abstract discussions, simple literature',
      skills : ['Passiv پیشرفته', 'درک متون تخصصی', 'نوشتن مقاله'],
      skillsEn: ['Advanced Passiv', 'Understanding specialist texts', 'Writing essays'],
      color  : Color(0xFFFF9800),
    ),
    (
      key    : 'c1',
      label  : 'C1 — Fortgeschritten',
      labelFa: 'پیشرفته',
      labelEn: 'Advanced',
      desc   : 'ادبیات، اخبار، بحث‌های علمی، نوشته‌های رسمی',
      descEn : 'Literature, news, academic debate, formal writing',
      skills : ['اصطلاحات پیچیده', 'نوشتن مقاله آکادمیک', 'درک لهجه‌ها'],
      skillsEn: ['Complex idioms', 'Academic essay writing', 'Understanding accents'],
      color  : Color(0xFFFF5722),
    ),
    (
      key    : 'c2',
      label  : 'C2 — Beherrschung',
      labelFa: 'تسلط کامل',
      labelEn: 'Mastery',
      desc   : 'تقریباً مثل گویشور بومی، درک هر متن پیچیده‌ای',
      descEn : 'Near-native, understanding any complex text',
      skills : ['نوشتن رسمی و ادبی', 'فهم لهجه‌های منطقه‌ای', 'استدلال فلسفی'],
      skillsEn: ['Formal and literary writing', 'Regional dialects', 'Philosophical argument'],
      color  : Color(0xFF9C27B0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lernpfad')),
      body  : ListView(
        padding : const EdgeInsets.all(AppSizes.md),
        children: [
          // Mountain map
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppL10n.t(context, 'path_a1_c2'),
                      style: const TextStyle(
                        fontSize  : 16,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: AppSizes.sm),
                  MountainProgressWidget(currentLevel: _currentLevel),
                  const SizedBox(height: AppSizes.sm),
                  // Level selector
                  Wrap(
                    spacing   : 8,
                    runSpacing: 4,
                    children  : _levels.map((l) {
                      final selected = l.key == _currentLevel;
                      return ChoiceChip(
                        label    : Text(l.key.toUpperCase()),
                        selected : selected,
                        onSelected: (_) =>
                            setState(() => _currentLevel = l.key),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSizes.md),

          // Level detail cards
          ..._levels.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child  : _LevelCard(
                  level     : l,
                  isCurrent : l.key == _currentLevel,
                  onSelect  : () =>
                      setState(() => _currentLevel = l.key),
                ),
              )),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.isCurrent,
    required this.onSelect,
  });

  final ({
    String key,
    String label,
    String labelFa, String labelEn,
    String desc, String descEn,
    List<String> skills, List<String> skillsEn,
    Color color,
  }) level;
  final bool       isCurrent;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrent
            ? BorderSide(color: level.color, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child  : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding   : const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color       : level.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(level.key.toUpperCase(),
                        style: TextStyle(
                          color     : level.color,
                          fontWeight: FontWeight.w900,
                          fontSize  : 14,
                        )),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(level.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize  : 14,
                            )),
                        Text(AppL10n.meaning(context, fa: level.labelFa, en: level.labelEn),
                            style: TextStyle(
                              color   : scheme.onSurfaceVariant,
                              fontSize: 12,
                            )),
                      ],
                    ),
                  ),
                  if (isCurrent)
                    Icon(Icons.location_on_rounded,
                        color: level.color, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(AppL10n.meaning(context, fa: level.desc, en: level.descEn),
                  style: TextStyle(
                    color  : scheme.onSurfaceVariant,
                    fontSize: 13,
                  )),
              const SizedBox(height: 8),
              Wrap(
                spacing   : 6,
                runSpacing: 4,
                children  : (AppL10n.isFa(context) ? level.skills : level.skillsEn)
                    .map((s) => Chip(
                          label       : Text(s,
                              style: const TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                          padding     : EdgeInsets.zero,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
