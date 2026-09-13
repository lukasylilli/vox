// FILE: lib/features/wortschatz/widgets/conjugation_table.dart
// PURPOSE: Displays verb conjugation (Infinitiv / Präsens / Präteritum / Partizip II)
import 'package:flutter/material.dart';
import '../../../core/models/word_model.dart';

class ConjugationTable extends StatelessWidget {
  const ConjugationTable({super.key, required this.conjugation});

  final VerbConjugation conjugation;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final surface = theme.colorScheme.surfaceContainerHighest;
    final rows = [
      ('Infinitiv',  conjugation.infinitiv),
      ('Präsens',    conjugation.praesens),
      ('Präteritum', conjugation.praeteritum),
      ('Partizip II', conjugation.partizip),
    ];

    return Container(
      decoration: BoxDecoration(
        color       : surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final isLast = entry.key == rows.length - 1;
          final (label, value) = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                    ),
                    Expanded(
                      child: Text(value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        )),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(height: 1,
                  indent: 16, endIndent: 16,
                  color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
