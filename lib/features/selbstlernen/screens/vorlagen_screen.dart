// FILE: lib/features/selbstlernen/screens/vorlagen_screen.dart
// DEPS: -
// PURPOSE: قالب‌های آماده تمرین — ساختارهای متنی برای مرور و تمرین نوشتاری
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_snack_bar.dart';
import '../../../core/widgets/vox_button.dart';

class VorlagenScreen extends StatelessWidget {
  const VorlagenScreen({super.key});

  static const _templates = [
    (
      title : 'template_intro',
      titleDe: 'Sich vorstellen',
      level : 'A1',
      text  : '''Hallo! Ich heiße ___. Ich bin ___ Jahre alt.
Ich komme aus ___. Ich wohne in ___.
Ich bin ___ (Beruf). Ich lerne Deutsch, weil ___.
Meine Hobbys sind ___ und ___.''',
    ),
    (
      title : 'template_family',
      titleDe: 'Über die Familie',
      level : 'A1',
      text  : '''Meine Familie ist ___ (groß/klein).
Ich habe ___ Geschwister. Mein Vater heißt ___ und ist ___ (Beruf).
Meine Mutter heißt ___ und ist ___ (Beruf).
Wir wohnen zusammen in ___.''',
    ),
    (
      title : 'template_daily',
      titleDe: 'Tagesablauf',
      level : 'A2',
      text  : '''Ich stehe um ___ Uhr auf. Zuerst frühstücke ich ___.
Um ___ Uhr gehe ich zur Arbeit / Schule.
Mittags esse ich meistens ___.
Abends ___ ich gerne.
Ich schlafe um ___ Uhr ein.''',
    ),
    (
      title : 'template_letter',
      titleDe: 'Formeller Brief',
      level : 'B1',
      text  : '''Sehr geehrte Damen und Herren,

ich schreibe Ihnen wegen ___.
Ich bin ___ und möchte Sie darüber informieren, dass ___.
Ich wäre Ihnen sehr dankbar, wenn Sie ___ könnten.

Mit freundlichen Grüßen,
___''',
    ),
    (
      title : 'template_opinion',
      titleDe: 'Meinung äußern',
      level : 'B1',
      text  : '''Meiner Meinung nach ist ___.
Einerseits ___, andererseits ___.
Ich bin der Meinung, dass ___, weil ___.
Allerdings muss man auch bedenken, dass ___.
Alles in allem denke ich, dass ___.''',
    ),
    (
      title : 'template_essay',
      titleDe: 'Akademischer Aufsatz',
      level : 'C1',
      text  : '''In der heutigen Zeit spielt ___ eine wichtige Rolle.
Zunächst möchte ich ___ erläutern.
Darüber hinaus lässt sich feststellen, dass ___.
Es wäre jedoch falsch zu behaupten, dass ___.
Zusammenfassend lässt sich sagen, dass ___.''',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vorlagen')),
      body  : ListView.separated(
        padding         : const EdgeInsets.all(AppSizes.md),
        itemCount       : _templates.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSizes.sm),
        itemBuilder     : (_, i) => _TemplateCard(t: _templates[i]),
      ),
    );
  }
}

class _TemplateCard extends StatefulWidget {
  const _TemplateCard({required this.t});

  final ({
    String title,
    String titleDe,
    String level,
    String text,
  }) t;

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _expanded = false;

  Color get _levelColor => switch (widget.t.level) {
        'A1' || 'A2' => Colors.green,
        'B1' || 'B2' => Colors.orange,
        _            => Colors.purple,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: () => setState(() => _expanded = !_expanded),
            leading: Container(
              padding   : const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color       : _levelColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(widget.t.level,
                  style: TextStyle(
                    color     : _levelColor,
                    fontWeight: FontWeight.w900,
                    fontSize  : 12,
                  )),
            ),
            title   : Text(AppL10n.t(context, widget.t.title),
                style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(widget.t.titleDe,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
            trailing: Icon(
              _expanded
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.md, 0, AppSizes.md, AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding   : const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color       : scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.t.text,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize  : 13,
                        height    : 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      VoxButton.text(
                        label    : AppL10n.t(context, 'copy'),
                        icon     : Icons.copy_rounded,
                        size     : VoxButtonSize.small,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: widget.t.text));
                          VoxSnackBar.copied(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
