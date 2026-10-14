// FILE: lib/core/widgets/filter_accordion.dart
// PURPOSE: Design System — aufklappbarer Filter-Drawer.
//          Inhalt kommt immer vom Screen (List<FilterOption>).
//          Dieser Widget kennt KEINE Inhalte — nur Darstellung + Verhalten.
//
// RASTER (فاز F.3, Lukas 2026-10-14): Die Knöpfe eines Drawers stehen in
//          einem GLEICHMÄSSIGEN Raster — jede Zeile gleich viele Knöpfe, alle
//          gleich breit, auf jedem Gerät bündig untereinander. Wie viele pro
//          Zeile, misst der Drawer selbst am breitesten Knopf ([filterSpalten]):
//          so viele wie hineinpassen (höchstens 6, sonst 4/3/2/1) — und davon
//          die größte Zahl, die die Knöpfe in VOLLE Zeilen teilt (6 ⇒ 6 oder
//          3+3, nie 4+2). Nur wenn das unter 2 fiele (z. B. 7 Knöpfe), bleibt
//          es bei «so viele wie passen»; die letzte Zeile ist dann kürzer,
//          aber im selben Raster. Verschiedene Drawer dürfen verschieden viele
//          Spalten haben. Gilt für JEDEN Filter-Drawer der App.
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

// ─── raster ───────────────────────────────────────────────────────────────────

/// Höchstzahl Knöpfe pro Zeile.
const filterMaxSpalten = 6;

/// Abstand zwischen den Knöpfen (waagerecht und senkrecht).
const filterAbstand = 8.0;

/// Spalten für Knöpfe der natürlichen Breiten [breiten] in [verfuegbar]
/// Pixeln (siehe RASTER oben). Rein — test/filter_raster_test.dart.
int filterSpalten({
  required List<double> breiten,
  required double verfuegbar,
  double abstand = filterAbstand,
  int maxSpalten = filterMaxSpalten,
}) {
  final n = breiten.length;
  if (n <= 1) return 1;
  final breitester = breiten.reduce((a, b) => a > b ? a : b);
  var passen = 1;
  for (var c = maxSpalten < n ? maxSpalten : n; c >= 2; c--) {
    final zelle = (verfuegbar - (c - 1) * abstand) / c;
    if (breitester <= zelle) {
      passen = c;
      break;
    }
  }
  for (var c = passen; c >= 2; c--) {
    if (n % c == 0) return c;
  }
  return passen;
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
            child: LayoutBuilder(
              builder: (context, constraints) => _raster(context, constraints),
            ),
          ),
        ),
      ],
    );
  }

  /// Natürliche Breite eines Knopfs: Text (fett, wie aktiv — der breiteste
  /// Zustand) + Innenabstand + Icon.
  double _knopfBreite(BuildContext context, FilterOption opt) {
    final tp = TextPainter(
      text: TextSpan(
        text : AppL10n.t(context, opt.label),
        style: _FilterChip.textStil.copyWith(fontWeight: FontWeight.w700),
      ),
      textDirection: Directionality.of(context),
      textScaler   : MediaQuery.textScalerOf(context),
      maxLines     : 1,
    )..layout();
    final breite = tp.width;
    tp.dispose();
    return breite +
        _FilterChip.innenAbstand * 2 +
        (opt.icon != null ? _FilterChip.iconPlatz : 0) +
        2; // Rundungsreserve
  }

  Widget _raster(BuildContext context, BoxConstraints constraints) {
    final optionen = widget.options;
    if (optionen.isEmpty) return const SizedBox.shrink();
    // Ohne feste Breite (z. B. waagerecht scrollend) gibt es kein Raster —
    // dann wie früher nebeneinander umbrechen.
    if (!constraints.hasBoundedWidth) {
      return Wrap(
        spacing   : filterAbstand,
        runSpacing: filterAbstand,
        children  : [
          for (final opt in optionen)
            _FilterChip(
              option: opt,
              active: widget.selected.contains(opt.value),
              onTap : () => widget.onChanged(
                  opt.value, !widget.selected.contains(opt.value)),
            ),
        ],
      );
    }
    final spalten = filterSpalten(
      breiten   : [for (final o in optionen) _knopfBreite(context, o)],
      verfuegbar: constraints.maxWidth,
    );
    final zeilen = <Widget>[];
    for (var i = 0; i < optionen.length; i += spalten) {
      final zellen = <Widget>[];
      for (var j = 0; j < spalten; j++) {
        if (j > 0) zellen.add(const SizedBox(width: filterAbstand));
        final k = i + j;
        if (k >= optionen.length) {
          zellen.add(const Expanded(child: SizedBox.shrink()));
          continue;
        }
        final opt    = optionen[k];
        final active = widget.selected.contains(opt.value);
        zellen.add(Expanded(
          child: _FilterChip(
            option  : opt,
            active  : active,
            zweiZeilen: spalten == 1,
            onTap   : () => widget.onChanged(opt.value, !active),
          ),
        ));
      }
      if (zeilen.isNotEmpty) {
        zeilen.add(const SizedBox(height: filterAbstand));
      }
      zeilen.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: zellen,
        ),
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: zeilen,
    );
  }
}

// ─── single filter chip ───────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.option,
    required this.active,
    required this.onTap,
    this.zweiZeilen = false,
  });

  final FilterOption option;
  final bool         active;
  final VoidCallback onTap;

  /// Nur eine Spalte (sehr lange Beschriftung) ⇒ darf umbrechen.
  final bool         zweiZeilen;

  /// Grundschrift — auch das Raster misst damit ([_FilterAccordionState]).
  static const textStil = TextStyle(fontSize: 13);
  static const innenAbstand = 12.0;
  static const iconPlatz = 18.0; // Icon 14 + Abstand 4

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      child: InkWell(
        onTap       : onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: innenAbstand, vertical: 8),
          alignment: Alignment.center,
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
              Flexible(
                child: Text(
                  AppL10n.t(context, option.label),
                  textAlign: TextAlign.center,
                  maxLines : zweiZeilen ? 2 : 1,
                  overflow : TextOverflow.ellipsis,
                  style: textStil.copyWith(
                    color     : active ? cs.onPrimary : cs.onSurface,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
