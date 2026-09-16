// FILE: lib/core/widgets/vox_button.dart
// PURPOSE: Design System — ALLE Button-Varianten der App an einem Ort.
//          Screens dürfen KEINE eigenen Button-Styles definieren — nur
//          VoxButton / VoxIconButton / VoxFab / VoxOptionButton referenzieren.
//
// PRINZIP (siehe old files Lukasalmani/1/Button — "Puzzling"):
//   1. Jede Variante baut auf offiziellen Material-System-Widgets auf
//      (FilledButton, FilledButton.tonal, OutlinedButton, TextButton,
//      IconButton.filled/…, FloatingActionButton) — KEINE handgezeichneten
//      Formen. Framework-/Plattform-Updates stylen so ALLE Buttons
//      automatisch neu.
//   2. Style-Änderung = nur diese Datei ändern → ganze App folgt.
import 'package:flutter/material.dart';

import '../constants/vox_colors.dart';

// ─── Größen-Token (controlSize-Äquivalent) ────────────────────────────────────

enum VoxButtonSize { small, medium, large }

extension on VoxButtonSize {
  EdgeInsets get padding => switch (this) {
        VoxButtonSize.small  => const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        VoxButtonSize.medium => const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        VoxButtonSize.large  => const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      };

  Size get minSize => switch (this) {
        VoxButtonSize.small  => const Size(0, 36),
        VoxButtonSize.medium => const Size(0, 44),
        VoxButtonSize.large  => const Size(0, 52),
      };

  TextStyle get textStyle => switch (this) {
        VoxButtonSize.small  => const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        VoxButtonSize.medium => const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        VoxButtonSize.large  => const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      };

  double get iconSize => switch (this) {
        VoxButtonSize.small  => 16,
        VoxButtonSize.medium => 18,
        VoxButtonSize.large  => 20,
      };
}

// ─── VoxButton ────────────────────────────────────────────────────────────────

enum _Variant {
  primary,             // FilledButton                 — wichtigste Aktion
  tonal,               // FilledButton.tonal           — sekundäre Fläche (Soft)
  secondary,           // OutlinedButton               — gleichwertige Alternative
  text,                // TextButton                   — Ghost/Plain (Dialoge, "später")
  success,             // FilledButton, grün           — "wusste ich", richtig
  destructive,         // FilledButton, error          — löschen/bestätigen
  destructiveOutlined, // OutlinedButton, error-Rand   — "wusste nicht", abbrechen-rot
  header,              // FilledButton, primaryContainer — Section-Header-CTA
}

class VoxButton extends StatelessWidget {
  const VoxButton._(
    this._variant, {
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.size    = VoxButtonSize.medium,
    this.expand  = false,
    this.loading = false,
    this.tooltip,
  });

  factory VoxButton.primary({
    Key?                   key,
    required String        label,
    required VoidCallback? onPressed,
    IconData?              icon,
    VoxButtonSize          size    = VoxButtonSize.medium,
    bool                   expand  = false,
    bool                   loading = false,
    String?                tooltip,
  }) => VoxButton._(
        _Variant.primary,
        key: key,
        label: label, onPressed: onPressed,
        icon: icon, size: size, expand: expand, loading: loading,
        tooltip: tooltip,
      );

  factory VoxButton.tonal({
    Key?                   key,
    required String        label,
    required VoidCallback? onPressed,
    IconData?              icon,
    VoxButtonSize          size    = VoxButtonSize.medium,
    bool                   expand  = false,
    bool                   loading = false,
    String?                tooltip,
  }) => VoxButton._(
        _Variant.tonal,
        key: key,
        label: label, onPressed: onPressed,
        icon: icon, size: size, expand: expand, loading: loading,
        tooltip: tooltip,
      );

  factory VoxButton.secondary({
    Key?                   key,
    required String        label,
    required VoidCallback? onPressed,
    IconData?              icon,
    VoxButtonSize          size    = VoxButtonSize.medium,
    bool                   expand  = false,
    bool                   loading = false,
    String?                tooltip,
  }) => VoxButton._(
        _Variant.secondary,
        key: key,
        label: label, onPressed: onPressed,
        icon: icon, size: size, expand: expand, loading: loading,
        tooltip: tooltip,
      );

  factory VoxButton.text({
    Key?                   key,
    required String        label,
    required VoidCallback? onPressed,
    IconData?              icon,
    VoxButtonSize          size = VoxButtonSize.medium,
    String?                tooltip,
  }) => VoxButton._(
        _Variant.text,
        key: key,
        label: label, onPressed: onPressed,
        icon: icon, size: size, tooltip: tooltip,
      );

  factory VoxButton.success({
    Key?                   key,
    required String        label,
    required VoidCallback? onPressed,
    IconData?              icon,
    VoxButtonSize          size    = VoxButtonSize.medium,
    bool                   expand  = false,
    bool                   loading = false,
    String?                tooltip,
  }) => VoxButton._(
        _Variant.success,
        key: key,
        label: label, onPressed: onPressed,
        icon: icon, size: size, expand: expand, loading: loading,
        tooltip: tooltip,
      );

  factory VoxButton.destructive({
    Key?                   key,
    required String        label,
    required VoidCallback? onPressed,
    IconData?              icon,
    VoxButtonSize          size    = VoxButtonSize.medium,
    bool                   expand  = false,
    bool                   loading = false,
    String?                tooltip,
  }) => VoxButton._(
        _Variant.destructive,
        key: key,
        label: label, onPressed: onPressed,
        icon: icon, size: size, expand: expand, loading: loading,
        tooltip: tooltip,
      );

  factory VoxButton.destructiveOutlined({
    Key?                   key,
    required String        label,
    required VoidCallback? onPressed,
    IconData?              icon,
    VoxButtonSize          size    = VoxButtonSize.medium,
    bool                   expand  = false,
    String?                tooltip,
  }) => VoxButton._(
        _Variant.destructiveOutlined,
        key: key,
        label: label, onPressed: onPressed,
        icon: icon, size: size, expand: expand, tooltip: tooltip,
      );

  factory VoxButton.header({
    Key?                   key,
    required String        label,
    required VoidCallback? onPressed,
    IconData?              icon,
    bool                   expand = false,
    String?                tooltip,
  }) => VoxButton._(
        _Variant.header,
        key: key,
        label: label, onPressed: onPressed,
        icon: icon, size: VoxButtonSize.medium, expand: expand,
        tooltip: tooltip,
      );

  /// Kompakter Pill-Button (ehem. VoxButton.small) — jetzt System-tonal.
  factory VoxButton.small({
    Key?                   key,
    required String        label,
    required VoidCallback? onPressed,
    IconData?              icon,
    String?                tooltip,
  }) => VoxButton._(
        _Variant.tonal,
        key: key,
        label: label, onPressed: onPressed,
        icon: icon, size: VoxButtonSize.small, tooltip: tooltip,
      );

  // ─── fields ────────────────────────────────────────────────────────────────

  final String        label;
  final VoidCallback? onPressed;
  final _Variant      _variant;
  final IconData?     icon;
  final VoxButtonSize size;
  final bool          expand;
  final bool          loading;
  final String?       tooltip;

  // ─── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final onTap   = loading ? null : onPressed;

    final style = switch (_variant) {
      _Variant.primary || _Variant.tonal => _base(),
      _Variant.secondary                 => _base(),
      _Variant.text                      => TextButton.styleFrom(
          padding: size.padding, textStyle: size.textStyle),
      _Variant.success => FilledButton.styleFrom(
          padding: size.padding, minimumSize: size.minSize,
          textStyle: size.textStyle,
          backgroundColor: VoxColors.success, foregroundColor: Colors.white),
      _Variant.destructive => FilledButton.styleFrom(
          padding: size.padding, minimumSize: size.minSize,
          textStyle: size.textStyle,
          backgroundColor: cs.error, foregroundColor: cs.onError),
      _Variant.destructiveOutlined => OutlinedButton.styleFrom(
          padding: size.padding, minimumSize: size.minSize,
          textStyle: size.textStyle,
          foregroundColor: cs.error, side: BorderSide(color: cs.error)),
      _Variant.header => FilledButton.styleFrom(
          backgroundColor: cs.primaryContainer,
          foregroundColor: cs.onPrimaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
    };

    final child = _child(context);

    Widget btn = switch (_variant) {
      _Variant.primary ||
      _Variant.success ||
      _Variant.destructive ||
      _Variant.header => icon != null && !loading
          ? FilledButton.icon(
              onPressed: onTap, style: style,
              icon: Icon(icon, size: size.iconSize), label: child)
          : FilledButton(onPressed: onTap, style: style, child: child),
      _Variant.tonal => icon != null && !loading
          ? FilledButton.tonalIcon(
              onPressed: onTap, style: style,
              icon: Icon(icon, size: size.iconSize), label: child)
          : FilledButton.tonal(onPressed: onTap, style: style, child: child),
      _Variant.secondary || _Variant.destructiveOutlined =>
          icon != null && !loading
              ? OutlinedButton.icon(
                  onPressed: onTap, style: style,
                  icon: Icon(icon, size: size.iconSize), label: child)
              : OutlinedButton(onPressed: onTap, style: style, child: child),
      _Variant.text => icon != null
          ? TextButton.icon(
              onPressed: onTap, style: style,
              icon: Icon(icon, size: size.iconSize), label: child)
          : TextButton(onPressed: onTap, style: style, child: child),
    };

    if (expand) btn = SizedBox(width: double.infinity, child: btn);
    if (tooltip != null) btn = Tooltip(message: tooltip!, child: btn);
    return btn;
  }

  ButtonStyle _base() => FilledButton.styleFrom(
        padding    : size.padding,
        minimumSize: size.minSize,
        textStyle  : size.textStyle,
      );

  Widget _child(BuildContext context) {
    if (!loading) {
      return Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width : size.iconSize,
          height: size.iconSize,
          child : const CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

// ─── VoxIconButton ────────────────────────────────────────────────────────────

enum VoxIconVariant { plain, filled, tonal, outlined }

/// Icon-Button in 4 System-Varianten (IconButton / .filled / .filledTonal /
/// .outlined). `isSelected`/`selectedIcon` = System-Toggle (M3).
class VoxIconButton extends StatelessWidget {
  const VoxIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant  = VoxIconVariant.plain,
    this.tooltip,
    this.color,
    this.iconSize,
    this.padding,
    this.isSelected,
    this.selectedIcon,
  });

  const VoxIconButton.filled({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.iconSize,
    this.padding,
    this.isSelected,
    this.selectedIcon,
  }) : variant = VoxIconVariant.filled;

  const VoxIconButton.tonal({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.iconSize,
    this.padding,
    this.isSelected,
    this.selectedIcon,
  }) : variant = VoxIconVariant.tonal;

  const VoxIconButton.outlined({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.iconSize,
    this.padding,
    this.isSelected,
    this.selectedIcon,
  }) : variant = VoxIconVariant.outlined;

  final IconData       icon;
  final VoidCallback?  onPressed;
  final VoxIconVariant variant;
  final String?        tooltip;

  /// plain: Icon-Farbe · filled/tonal: Hintergrund-Tint
  final Color?    color;
  final double?   iconSize;
  final EdgeInsets? padding;
  final bool?     isSelected;
  final IconData? selectedIcon;

  @override
  Widget build(BuildContext context) {
    final sel  = selectedIcon != null ? Icon(selectedIcon) : null;

    return switch (variant) {
      VoxIconVariant.plain => IconButton(
          icon: Icon(icon, color: color),
          onPressed: onPressed, tooltip: tooltip, iconSize: iconSize,
          padding: padding,
          isSelected: isSelected, selectedIcon: sel,
        ),
      VoxIconVariant.filled => IconButton.filled(
          icon: Icon(icon),
          onPressed: onPressed, tooltip: tooltip, iconSize: iconSize,
          padding: padding,
          isSelected: isSelected, selectedIcon: sel,
          style: color == null
              ? null
              : IconButton.styleFrom(
                  backgroundColor: color, foregroundColor: Colors.white),
        ),
      VoxIconVariant.tonal => IconButton.filledTonal(
          icon: Icon(icon),
          onPressed: onPressed, tooltip: tooltip, iconSize: iconSize,
          padding: padding,
          isSelected: isSelected, selectedIcon: sel,
          style: color == null
              ? null
              : IconButton.styleFrom(
                  backgroundColor: color!.withValues(alpha: 0.15),
                  foregroundColor: color),
        ),
      VoxIconVariant.outlined => IconButton.outlined(
          icon: Icon(icon, color: color),
          onPressed: onPressed, tooltip: tooltip, iconSize: iconSize,
          padding: padding,
          isSelected: isSelected, selectedIcon: sel,
        ),
    };
  }
}

// ─── VoxFab ───────────────────────────────────────────────────────────────────

/// Floating Action Button — System-FAB, zentral referenziert.
class VoxFab extends StatelessWidget {
  const VoxFab({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  })  : label = null;

  const VoxFab.extended({
    super.key,
    required this.icon,
    required String this.label,
    required this.onPressed,
    this.tooltip,
  });

  final IconData      icon;
  final String?       label;
  final VoidCallback? onPressed;
  final String?       tooltip;

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        tooltip  : tooltip,
        icon     : Icon(icon),
        label    : Text(label!),
      );
    }
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip  : tooltip,
      child    : Icon(icon),
    );
  }
}

// ─── VoxOptionButton ──────────────────────────────────────────────────────────

enum VoxOptionState { idle, selected, correct, wrong }

/// Quiz-Antwort-Option — EIN Look für alle Quiz-Screens.
/// System-OutlinedButton; Zustand färbt Rand/Fläche (grün/rot).
class VoxOptionButton extends StatelessWidget {
  const VoxOptionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.state = VoxOptionState.idle,
    this.subtitle,
  });

  final String          label;
  final VoidCallback?   onPressed;
  final VoxOptionState  state;
  final String?         subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (Color? bg, Color border, Color fg) = switch (state) {
      VoxOptionState.idle => (
          null, cs.outline.withValues(alpha: 0.4), cs.onSurface),
      VoxOptionState.selected => (
          cs.primaryContainer, cs.primary, cs.onPrimaryContainer),
      VoxOptionState.correct => (
          VoxColors.success.withValues(alpha: 0.15),
          VoxColors.success, cs.onSurface),
      VoxOptionState.wrong => (
          cs.error.withValues(alpha: 0.15), cs.error, cs.onSurface),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding        : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          minimumSize    : const Size(double.infinity, 48),
          backgroundColor: bg,
          foregroundColor: fg,
          disabledForegroundColor: fg,
          disabledBackgroundColor: bg,
          side           : BorderSide(color: border),
          shape          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle      : const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500),
        ),
        child: subtitle == null
            ? Text(label, textAlign: TextAlign.center)
            : Column(
                children: [
                  Text(label, textAlign: TextAlign.center),
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
