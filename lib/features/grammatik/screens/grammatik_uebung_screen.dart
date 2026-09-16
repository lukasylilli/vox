// FILE: lib/features/grammatik/screens/grammatik_uebung_screen.dart
// PHASE: فاز G → G7a (2026-09-16)
// DEPS: grammatik_lektion_controller.dart, uebungs_sitzung.dart
// PURPOSE: Übungen einer Grammatik-Lektion — Route
//          /grammatik/lektion/:slug/uebung (AppRoutes.grammatikLektionUebung).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_empty_state.dart';
import '../controllers/grammatik_lektion_controller.dart';
import '../widgets/uebungs_sitzung.dart';

class GrammatikUebungScreen extends ConsumerWidget {
  const GrammatikUebungScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lek = ref.watch(grammatikLektionProvider(slug)).valueOrNull;
    final uebungenAsync = ref.watch(grammatikLektionUebungenProvider(slug));
    final titel = lek?.titleDe ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titel.isEmpty
              ? AppL10n.t(context, 'practice')
              : AppL10n.tf(context, 'practice_dash', {'x': titel}),
        ),
      ),
      body: uebungenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('${AppL10n.t(context, 'error')}: $e')),
        data: (uebungen) {
          if (uebungen.isEmpty) return const VoxEmptyState.comingSoon();
          return UebungsSitzung(
            uebungen: uebungen,
            onZurueck: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.grammatikLektion(slug));
              }
            },
          );
        },
      ),
    );
  }
}
