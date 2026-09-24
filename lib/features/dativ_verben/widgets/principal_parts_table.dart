// FILE: lib/features/dativ_verben/widgets/principal_parts_table.dart
import 'package:flutter/material.dart';
import '../models/dativ_verb.dart';

class PrincipalPartsTable extends StatelessWidget {
  const PrincipalPartsTable(this.parts, {super.key});

  final PrincipalParts parts;

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final tt    = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Directionality(
          // Deutsche Formen-Tabelle ⇒ fest LTR (2026-09-23)
          textDirection: TextDirection.ltr,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _header('Präsens (3.Sg)', cs),
                _header('Präteritum',     cs),
                _header('Perfekt',        cs),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cell(parts.praesens3sg, tt),
                _cell(parts.praeteritum, tt),
                _cell(
                  parts.perfekt,
                  tt,
                  seinBadge: parts.isSeinVerb,
                ),
              ],
            ),
          ],
        )),
      ),
    );
  }

  Widget _header(String t, ColorScheme cs) => Expanded(
        child: Text(
          t,
          style: TextStyle(
            fontSize  : 10,
            fontWeight: FontWeight.w600,
            color     : cs.onSurfaceVariant,
            letterSpacing: 0.2,
          ),
        ),
      );

  Widget _cell(String t, TextTheme tt, {bool seinBadge = false}) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t,
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            if (seinBadge)
              const _SeinChip(),
          ],
        ),
      );
}

class _SeinChip extends StatelessWidget {
  const _SeinChip();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF80CBC4)
        : const Color(0xFF00695C);
    return Container(
      margin     : const EdgeInsets.only(top: 3),
      padding    : const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration : BoxDecoration(
        color       : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border      : Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text('sein',
          style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
