// FILE: lib/core/widgets/filter_accordion.dart
// PURPOSE: Design System — aufklappbarer Filter-Drawer.
//          Inhalt kommt immer vom Screen (List<FilterOption>).
//          Dieser Widget kennt KEINE Inhalte — nur Darstellung + Verhalten.
import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../l10n/app_l10n.dart';

// ─── data model ───────────────────────────────────────────────────────────────

class FilterOption {
  const FilterOption({required this.value, required this.label, this.icon});
  final String    value;
  final String    label;
  final IconData? icon;
}

// ─── accordion widget ─────────────────────────────────────────────────────────

class FilterAccordion extends StatefulWidget {
  const FilterAccordion({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.initiallyExpanded = false,
  });

  final String              label;
  final List<FilterOption>  options;
  final Set<String>         selected;
  final void Function(String value, bool selected) onChanged;
  final bool                initiallyExpanded;

  @override
  State<FilterAccordion> createState() => _FilterAccordionState();
}

class _FilterAccordionState extends State<FilterAccordion>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _expand;
  late bool                _open;

  @override
  void initState() {
    super.initState();
    _open = widget.initiallyExpanded;
    _ctrl = AnimationController(
      vsync   : this,
      duration: const Duration(milliseconds: 220),
      value   : _open ? 1.0 : 0.0,
    );
    _expand = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final cs          = Theme.of(context).colorScheme;
    final activeCount = widget.selected.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── header row ──────────────────────────────────────────────────────
        InkWell(
          onTap       : _toggle,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm, vertical: AppSizes.xs),
            child: Row(
              children: [
                Text(
                  AppL10n.t(context, widget.label),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color     : _open ? cs.primary : cs.onSurface,
                  ),
                ),
                if (activeCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color       : cs.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '$activeCount',
                      style: TextStyle(
                        color     : cs.onPrimary,
                        fontSize  : 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_expand),
                  child: Icon(Icons.expand_more_rounded,
                      size: 20, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        // ── chip grid ───────────────────────────────────────────────────────
        SizeTransition(
          sizeFactor: _expand,
          child: Padding(
            padding: const EdgeInsets.only(
                left: AppSizes.sm,
                right: AppSizes.sm,
                bottom: AppSizes.sm),
            child: Wrap(
              spacing : 8,
              runSpacing: 6,
              children: widget.options.map((opt) {
                final active = widget.selected.contains(opt.value);
                return _FilterChip(
                  option  : opt,
                  active  : active,
                  onTap   : () => widget.onChanged(opt.value, !active),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── single filter chip ───────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.option,
    required this.active,
    required this.onTap,
  });

  final FilterOption option;
  final bool         active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      child: InkWell(
        onTap       : onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color : active ? cs.primary : cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (option.icon != null) ...[
                Icon(
                  option.icon,
                  size : 14,
                  color: active ? cs.onPrimary : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                AppL10n.t(context, option.label),
                style: TextStyle(
                  color     : active ? cs.onPrimary : cs.onSurface,
                  fontSize  : 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
