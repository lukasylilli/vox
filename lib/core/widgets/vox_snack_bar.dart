// FILE: lib/core/widgets/vox_snack_bar.dart
// STATUS: [x] LIVE (B9 — 2026-07-04)
// PURPOSE: Design System — every SnackBar in the app goes through these
//          helpers. One look, one duration, one behavior.
import 'package:flutter/material.dart';

import '../constants/vox_colors.dart';
import '../../core/l10n/app_l10n.dart';

abstract final class VoxSnackBar {
  static void show(BuildContext context, String message) =>
      _show(context, message);

  /// '<title> — به‌زودی' — locked feature tapped.
  static void comingSoon(BuildContext context, String title) =>
      _show(context, '$title — ${AppL10n.t(context, 'coming_soon')}');

  static void success(BuildContext context, String message) =>
      _show(context, message, color: VoxColors.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, color: VoxColors.error);

  /// 'کپی شد' — after copy-to-clipboard.
  static void copied(BuildContext context) => _show(context, AppL10n.t(context, 'copied_check'));

  static void _show(BuildContext context, String message, {Color? color}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content        : Text(message),
        duration       : const Duration(seconds: 2),
        behavior       : SnackBarBehavior.floating,
        width          : 280,
        backgroundColor: color,
      ));
  }
}
