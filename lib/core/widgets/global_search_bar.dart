// FILE: lib/core/widgets/global_search_bar.dart
// DEPS: app_routes.dart
// PURPOSE: Suchsymbol in der AppBar — öffnet SearchResultsScreen
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_routes.dart';
import '../../core/l10n/app_l10n.dart';

class GlobalSearchAction extends StatelessWidget {
  const GlobalSearchAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon   : const Icon(Icons.search_rounded),
      tooltip: AppL10n.t(context, 'search_label'),
      onPressed: () => context.push(AppRoutes.search),
    );
  }
}
