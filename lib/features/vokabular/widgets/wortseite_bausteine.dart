// FILE: lib/features/vokabular/widgets/wortseite_bausteine.dart
// PURPOSE: Wiederverwendbare UI-Teile der Wort-Seite (فاز V, Stufe ۴):
//          Sektion / Zeile / BeispielBlock / Tabelle + Übersetzungs-Helper.
//          ⚠️ فاز L: BeispielBlock zeigt EINE Übersetzung (aktive Sprache aus
//          Settings via AppL10n.isFa) — nie FA und EN gleichzeitig.
//          Alles null-sicher: fehlende Felder → Baustein rendert nichts.
import 'package:flutter/material.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/klick_wort_text.dart';

/// {fa:…, en:…} (String oder List) → Text der AKTIVEN Sprache (EN-Fallback→FA).
String? vokabUeb(BuildContext context, dynamic u) {
  if (u is! Map) return null;
  String? join(dynamic v, String sep) => v is List
      ? v.cast<String>().join(sep)
      : v as String?;
  return AppL10n.isFa(context)
      ? join(u['fa'], '، ')
      : (join(u['en'], ', ') ?? join(u['fa'], '، '));
}

class Sektion extends StatelessWidget {
  final String titel;
  final List<Widget> children;
  const Sektion({super.key, required this.titel, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titel,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children),
            ),
          ),
        ],
      ),
    );
  }
}

/// Label-Wert-Zeile; wert null/leer → nichts (Regel 3 des Prompts: null erlaubt).
class Zeile extends StatelessWidget {
  final String label;
  final String? wert;
  const Zeile({super.key, required this.label, this.wert});

  @override
  Widget build(BuildContext context) {
    final w = wert;
    if (w == null || w.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        textDirection: TextDirection.ltr, // Grammatik-Metadaten deutsch/LTR
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Text(label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
          Expanded(
            flex: 2,
            child: Text(w,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// Beispielsatz + optionale Übersetzung (nur aktive Sprache) + optionales Badge.
class BeispielBlock extends StatelessWidget {
  final String satz;
  final String? uebersetzung;
  final String? badge;
  const BeispielBlock(
      {super.key, required this.satz, this.uebersetzung, this.badge});

  @override
  Widget build(BuildContext context) {
    if (satz.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badge != null && badge!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(badge!,
                  textDirection: TextDirection.ltr,
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800)),
            ),
          // L.5f: jedes Wort antippbar (Popup → Wort-Seite)
          KlickWortText(satz,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
          if (uebersetzung != null && uebersetzung!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(uebersetzung!,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ),
        ],
      ),
    );
  }
}

/// Generische Tabelle: kopf optional, Zellen null → '–'.
class Tabelle extends StatelessWidget {
  final List<String>? kopf;
  final List<List<String?>> zeilen;
  const Tabelle({super.key, this.kopf, required this.zeilen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rand = theme.colorScheme.outlineVariant.withValues(alpha: 0.4);

    TableRow reihe(List<String?> zellen, {bool istKopf = false}) => TableRow(
          decoration: istKopf
              ? BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08))
              : null,
          children: [
            for (var i = 0; i < zellen.length; i++)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                child: Text(
                  zellen[i] ?? '–',
                  textAlign: i == 0 ? TextAlign.left : TextAlign.center,
                  style: (i == 0 || istKopf)
                      ? theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: istKopf
                              ? null
                              : theme.colorScheme.onSurfaceVariant)
                      : theme.textTheme.bodySmall,
                ),
              ),
          ],
        );

    return Directionality(
      textDirection: TextDirection.ltr, // deutsche Grammatiktabellen immer LTR
      child: Table(
        border: TableBorder.all(color: rand, borderRadius: BorderRadius.circular(8)),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          if (kopf != null) reihe(kopf!, istKopf: true),
          for (final z in zeilen) reihe(z),
        ],
      ),
    );
  }
}
