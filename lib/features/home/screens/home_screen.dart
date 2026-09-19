// FILE: lib/features/home/screens/home_screen.dart
// DEPS: section_grid_item.dart, app_routes.dart, app_l10n.dart, app_colors.dart, app_sizes.dart
// EXPORTS: HomeScreen
// PURPOSE: Entry screen — 3×4 grid of 12 learning sections
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/services/feature_flags.dart';
import '../../../core/widgets/global_search_bar.dart';
import '../widgets/section_grid_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = _sections(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating : true,
              pinned   : false,
              title    : const Text(
                'VOX',
                style: TextStyle(
                  fontSize  : 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                ),
              ),
              actions: [
                const GlobalSearchAction(),
                const SizedBox(width: 4),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.gridPadding,
                8,
                AppSizes.gridPadding,
                AppSizes.gridPadding,
              ),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => SectionGridItem(
                    section: sections[i],
                    onTap  : () => context.push(sections[i].route),
                  ),
                  childCount: sections.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount   : AppSizes.gridColumns,
                  childAspectRatio : AppSizes.gridChildAspectRatio,
                  crossAxisSpacing : AppSizes.gridSpacing,
                  mainAxisSpacing  : AppSizes.gridSpacing,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<SectionData> _sections(BuildContext context) => [
    SectionData(
      titleDe   : 'Wortschatz',
      titleLocal: AppL10n.t(context, 'wortschatz'),
      icon      : Icons.menu_book_rounded,
      color     : AppColors.wortschatz,
      route     : AppRoutes.wortschatz,
    ),
    SectionData(
      titleDe   : 'Grammatik',
      titleLocal: AppL10n.t(context, 'grammatik'),
      icon      : Icons.auto_stories_rounded,
      color     : AppColors.grammatik,
      route     : AppRoutes.grammatik,
    ),
    SectionData(
      titleDe   : 'Lesen',
      titleLocal: AppL10n.t(context, 'lesen'),
      icon      : Icons.chrome_reader_mode_rounded,
      color     : AppColors.lesen,
      route     : AppRoutes.lesen,
    ),
    SectionData(
      titleDe   : 'Hören',
      titleLocal: AppL10n.t(context, 'hoeren'),
      icon      : Icons.headphones_rounded,
      color     : AppColors.hoeren,
      route     : AppRoutes.hoeren,
    ),
    if (FeatureFlags.isVisible('feature.sprechen'))
    SectionData(
      titleDe   : 'Sprechen',
      titleLocal: AppL10n.t(context, 'sprechen'),
      icon      : Icons.mic_rounded,
      color     : AppColors.sprechen,
      route     : AppRoutes.sprechen,
    ),
    if (FeatureFlags.isVisible('feature.schreiben'))
    SectionData(
      titleDe   : 'Schreiben',
      titleLocal: AppL10n.t(context, 'schreiben'),
      icon      : Icons.edit_rounded,
      color     : AppColors.schreiben,
      route     : AppRoutes.schreiben,
    ),
    SectionData(
      titleDe   : 'Auswendig\nlernen',
      titleLocal: AppL10n.t(context, 'auswendiglernen'),
      icon      : Icons.psychology_rounded,
      color     : AppColors.auswendig,
      route     : AppRoutes.auswendiglernen,
    ),
    SectionData(
      titleDe   : 'Prüfungen',
      titleLocal: AppL10n.t(context, 'pruefungen'),
      icon      : Icons.assignment_turned_in_rounded,
      color     : AppColors.pruefungen,
      route     : AppRoutes.pruefungen,
    ),
    SectionData(
      titleDe   : 'Selbst\nlernen',
      titleLocal: AppL10n.t(context, 'selbstlernen'),
      icon      : Icons.self_improvement_rounded,
      color     : AppColors.selbstlernen,
      route     : AppRoutes.selbstlernen,
    ),
    SectionData(
      titleDe   : 'Fragen',
      titleLocal: AppL10n.t(context, 'fragen'),
      icon      : Icons.help_outline_rounded,
      color     : AppColors.fragen,
      route     : AppRoutes.fragen,
    ),
    SectionData(
      titleDe   : 'Sozial\nmedien',
      titleLocal: AppL10n.t(context, 'sozialmedien'),
      icon      : Icons.groups_rounded,
      color     : AppColors.sozialmedien,
      route     : AppRoutes.sozialmedien,
    ),
    SectionData(
      titleDe   : 'More',
      titleLocal: AppL10n.t(context, 'more'),
      icon      : Icons.more_horiz_rounded,
      color     : AppColors.more,
      route     : AppRoutes.more,
    ),
  ];
}
