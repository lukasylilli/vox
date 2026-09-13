// FILE: lib/core/widgets/vox_dialog.dart
// STATUS: [x] LIVE (B9 — 2026-07-04)
// PURPOSE: Design System — every dialog goes through these helpers.
//          quizResult() is THE result dialog for all quiz screens.
import 'package:flutter/material.dart';

import '../utils/formatters.dart';
import '../../core/l10n/app_l10n.dart';

abstract final class VoxDialog {
  /// Standard quiz result: big score + verdict + repeat/back actions.
  /// Both actions pop the dialog first; [onBack] additionally leaves the quiz.
  static Future<void> quizResult(
    BuildContext context, {
    required int correct,
    required int total,
    required VoidCallback onRepeat,
    required VoidCallback onBack,
  }) {
    final verdict = correct == total
        ? AppL10n.t(context, 'quiz_perfect')
        : correct >= total ~/ 2
            ? AppL10n.t(context, 'quiz_good')
            : AppL10n.t(context, 'quiz_needs_practice');

    return showDialog<void>(
      context           : context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title  : Text(AppL10n.t(ctx, 'quiz_result')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${Formatters.faDigits(correct)} / ${Formatters.faDigits(total)}',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(verdict),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onBack();
            },
            child: Text(AppL10n.t(ctx, 'go_back')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onRepeat();
            },
            child: Text(AppL10n.t(ctx, 'try_again')),
          ),
        ],
      ),
    );
  }

  /// Yes/no confirmation; resolves to true when confirmed.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'confirm',
    String cancelLabel  = 'dismiss',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title  : Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child    : Text(AppL10n.t(ctx, cancelLabel)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child    : Text(AppL10n.t(ctx, confirmLabel)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Plain info dialog with a single OK button.
  static Future<void> info(
    BuildContext context, {
    required String title,
    required String message,
  }) =>
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title  : Text(title),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child    : Text(AppL10n.t(ctx, 'okay')),
            ),
          ],
        ),
      );
}
