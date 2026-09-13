// FILE: lib/core/widgets/quiz_launch_button.dart
// DEPS: app_routes.dart
// PURPOSE: Shared button — launches grammar quiz for a specific lesson (or grammatik home)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_routes.dart';
import '../l10n/app_l10n.dart';
import 'vox_button.dart';

class QuizLaunchButton extends StatelessWidget {
  const QuizLaunchButton({super.key, this.lessonId, this.compact = false});
  final int?  lessonId;
  final bool  compact;

  @override
  Widget build(BuildContext context) {
    void go() {
      if (lessonId != null) {
        context.push('${AppRoutes.grammatik}/lesson/$lessonId/quiz');
      } else {
        context.push(AppRoutes.grammatik);
      }
    }

    if (compact) {
      return VoxIconButton(
        icon     : Icons.quiz_rounded,
        tooltip  : AppL10n.t(context, 'quiz'),
        onPressed: go,
      );
    }
    return VoxButton.primary(
      label    : AppL10n.t(context, 'quiz'),
      icon     : Icons.quiz_rounded,
      onPressed: go,
    );
  }
}
