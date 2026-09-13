// FILE: lib/core/widgets/filter_chip_bar.dart
// PURPOSE: Design System — horizontale Zeile aktiver Filter + "Alle löschen"-Button.
//          Wird unterhalb der FilterAccordions angezeigt wenn Filter aktiv sind.
import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../../core/l10n/app_l10n.dart';

class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.activeFilters,
    required this.onRemove,
    required this.onClearAll,
  });

  /// Map: label → value (für Anzeige und Entfernen)
  final Map<String, String> activeFilters;
  final void Function(String value) onRemove;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    if (activeFilters.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 36,
      child: ListView(
        padding    : const EdgeInsets.symmetric(horizontal: AppSizes.md),
        scrollDirection: Axis.horizontal,
        children: [
          // Clear all button
          _ClearChip(onTap: onClearAll),
          const SizedBox(width: 6),
          // Active filter chips
          ...activeFilters.entries.map((e) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child  : _ActiveChip(
                  label  : e.key,
                  onRemove: () => onRemove(e.value),
                ),
              )),
        ],
      ),
    );
  }
}

// ─── clear all chip ───────────────────────────────────────────────────────────

class _ClearChip extends StatelessWidget {
  const _ClearChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap       : onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border      : Border.all(color: cs.error, width: 1.2),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.close_rounded, size: 13, color: cs.error),
            const SizedBox(width: 3),
            Text(
              AppL10n.t(context, 'clear_filters'),
              style: TextStyle(
                color     : cs.error,
                fontSize  : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── single active chip ───────────────────────────────────────────────────────

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({required this.label, required this.onRemove});
  final String       label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color       : cs.primaryContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppL10n.t(context, label),
            style: TextStyle(
              color     : cs.onPrimaryContainer,
              fontSize  : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap       : onRemove,
            borderRadius: BorderRadius.circular(100),
            child: Icon(
              Icons.close_rounded,
              size : 13,
              color: cs.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
