// FILE: lib/features/modalverben/screens/modalverben_list_screen.dart
// PURPOSE: Modalverben-Deck — Flashcard-Liste (7 Verben): Wort, Bedeutung,
//          Kurzbeispiel. Sprache (FA/EN) folgt der App-Sprache aus Settings.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/vox_colors.dart';
import '../../../core/widgets/vox_error_widget.dart';
import '../../../core/widgets/vox_loading_widget.dart';
import '../controllers/modalverben_controller.dart';
import '../models/modal_verb.dart';
import '../../../core/widgets/vox_button.dart';

class ModalverbenListScreen extends ConsumerWidget {
  const ModalverbenListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verbsAsync = ref.watch(modalVerbenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modalverben'),
        actions: [
          VoxIconButton(
            icon: Icons.account_tree_rounded,
            tooltip : 'Grammatik',
            onPressed: () => context.push(AppRoutes.modalverbenGrammar),
          ),
        ],
      ),
      body: verbsAsync.when(
        loading: () => const VoxLoadingWidget(),
        error  : (e, _) => VoxErrorWidget(error: e),
        data   : (verbs) => ListView.builder(
          padding    : const EdgeInsets.fromLTRB(
              AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.xl),
          itemCount  : verbs.length,
          itemBuilder: (_, i) => _VerbCard(verb: verbs[i]),
        ),
      ),
    );
  }
}

class _VerbCard extends StatelessWidget {
  const _VerbCard({required this.verb});
  final ModalVerb verb;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;
    final isEn  = Localizations.localeOf(context).languageCode == 'en';
    final firstExample =
        verb.examples.isNotEmpty ? verb.examples.first : null;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child : InkWell(
        onTap: () => context.push(
            AppRoutes.modalverbenDetail(verb.id), extra: verb),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      verb.infinitive,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color     : VoxColors.typeVerb,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color       : cs.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ich ${verb.praesens['ich']} · '
                      'ich ${verb.praeteritum['ich']}',
                      style: TextStyle(
                        fontSize  : 12,
                        fontWeight: FontWeight.w600,
                        color     : cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                isEn ? verb.meaningEn : verb.meaningFa,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant),
              ),
              if (firstExample != null) ...[
                const SizedBox(height: 8),
                Text(
                  firstExample.de,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color    : cs.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
