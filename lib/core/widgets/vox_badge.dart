// FILE: lib/core/widgets/vox_badge.dart
// PURPOSE: Design System — alle Badge/Chip-Varianten an einem Ort.
//          Screens dürfen KEINE eigenen Badge-Styles definieren.
import 'package:flutter/material.dart';

import '../constants/vox_colors.dart';

class VoxBadge extends StatelessWidget {
  const VoxBadge._({
    required this.label,
    required this._color,
    required this._textColor,
    this.small = false,
  });

  // ─── factory constructors ──────────────────────────────────────────────────

  /// Niveau-Badge: A1, A2, B1, B2, C1, C2
  factory VoxBadge.level(String level, {bool small = false}) {
    final color = VoxColors.cefr(level);
    return VoxBadge._(
      label    : level.toUpperCase(),
      color    : color.withValues(alpha: 0.15),
      textColor: color,
      small    : small,
    );
  }

  /// Wortart-Badge: Verb, Nomen, Adjektiv, ...
  factory VoxBadge.wordType(String type, {bool small = false}) {
    final color = VoxColors.wordType(type);
    return VoxBadge._(
      label    : type,
      color    : color.withValues(alpha: 0.12),
      textColor: color,
      small    : small,
    );
  }

  /// Generischer farbiger Badge
  factory VoxBadge.colored({
    required String label,
    required Color  color,
    bool            small = false,
  }) {
    return VoxBadge._(
      label    : label,
      color    : color.withValues(alpha: 0.15),
      textColor: color,
      small    : small,
    );
  }

  // ─── fields ────────────────────────────────────────────────────────────────

  final String label;
  final Color  _color;
  final Color  _textColor;
  final bool   small;

  // ─── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: small
          ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color       : _color,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color     : _textColor,
          fontSize  : small ? 10 : 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

}
