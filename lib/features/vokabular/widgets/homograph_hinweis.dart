// FILE: lib/features/vokabular/widgets/homograph_hinweis.dart
// PHASE: L.4 (2026-10-19) — Entscheidung Lukas: Homographen (der See /
//        die See, die Bank / die Bank²) haben eigene Karten; jede Karte
//        zeigt deutlich, dass es die anderen gibt — mit Bedeutung und Weg
//        dorthin. Steht im Kopf jeder Karte (Wort-Seite) und auf der
//        Rückseite der Lernkarte (Leitner), damit niemand die Bedeutungen
//        verwechselt.
// DEPS:   vokabHomographeProvider (Familien nur aus den ids im Code erkannt —
//         die Karten tragen dafür nichts, Prompt-Regel 1).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/grammatikon/wort_card.dart';
import '../../../core/l10n/app_l10n.dart';
import '../controllers/vokabular_controller.dart';

class HomographHinweis extends ConsumerWidget {
  const HomographHinweis({super.key, required this.id, this.kompakt = false});

  /// id der Karte, die gerade gezeigt wird.
  final String id;

  /// Kleinere Fassung für die Lernkarte.
  final bool kompakt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final andere =
        ref.watch(vokabHomographeProvider).valueOrNull?[id] ?? const [];
    if (andere.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fa = AppL10n.isFa(context);

    return Container(
      margin: EdgeInsets.only(top: kompakt ? 8 : 12),
      padding: EdgeInsets.all(kompakt ? 8 : 12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.tertiary.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: kompakt ? 16 : 18, color: scheme.tertiary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  AppL10n.t(context, 'homograph_titel'),
                  style: (kompakt
                          ? theme.textTheme.bodySmall
                          : theme.textTheme.bodyMedium)
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final k in andere)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () =>
                  context.push(AppRoutes.vokabularWort(k['id'] as String)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    WortZeile(
                      card: k,
                      zentriert: true,
                      style: kompakt
                          ? theme.textTheme.bodyMedium
                          : theme.textTheme.titleSmall,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '= ${_ersteBedeutung(k, fa)}',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Icon(
                      fa
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Erste Übersetzung in der eingestellten Sprache (nie beide, فاز L).
  static String _ersteBedeutung(Map<String, dynamic> k, bool fa) {
    final u = (k['uebersetzung'] as Map?)?.cast<String, dynamic>() ?? const {};
    final liste = ((u[fa ? 'fa' : 'en'] as List?) ?? const []).cast<String>();
    return liste.isEmpty ? '' : liste.first;
  }
}

/// Hochgestellte Homograph-Nummer einer VOLLEN Karte (die volle Karte trägt
/// sie nicht — sie steht nur im Index). Keine Familie ⇒ nichts.
class HomographNummer extends ConsumerWidget {
  const HomographNummer({super.key, required this.id, this.style});
  final String id;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eintrag = ref.watch(vokabIndexByIdProvider).valueOrNull?[id];
    final hoch = homographHoch(eintrag?['homograph_nr']);
    if (hoch == null) return const SizedBox.shrink();
    return Text(hoch, style: style, textDirection: TextDirection.ltr);
  }
}
