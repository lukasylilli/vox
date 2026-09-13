// FILE: lib/core/widgets/grammar_link_button.dart
// DEPS: app_routes.dart
// PURPOSE: Shared button — opens Grammatik section (optionally filtered to a level)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_routes.dart';
import '../l10n/app_l10n.dart';
import 'vox_button.dart';

class GrammarLinkButton extends StatelessWidget {
  const GrammarLinkButton({super.key, this.level, this.compact = false});
  final String? level;
  final bool    compact;

  @override
  Widget build(BuildContext context) {
    void go() {
      if (level != null) {
        context.push('${AppRoutes.grammatik}/$level');
      } else {
        context.push(AppRoutes.grammatik);
      }
    }

    if (compact) {
      return VoxIconButton(
        icon     : Icons.auto_stories_rounded,
        tooltip  : AppL10n.t(context, 'grammar_label'),
        onPressed: go,
      );
    }
    return VoxButton.secondary(
      label    : AppL10n.t(context, 'grammar_label'),
      icon     : Icons.auto_stories_rounded,
      onPressed: go,
    );
  }
}
