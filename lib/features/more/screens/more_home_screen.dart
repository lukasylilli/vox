// FILE: lib/features/more/screens/more_home_screen.dart
// DEPS: app_routes.dart
// PURPOSE: خانه More — تنظیمات، سوالات، شبکه‌های اجتماعی
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';

class MoreHomeScreen extends StatelessWidget {
  const MoreHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          _Section(title: AppL10n.t(context, 'app_section'), children: [
            _Tile(
              icon    : Icons.account_circle_outlined,
              title   : 'Profil & Konto',
              titleFa : AppL10n.t(context, 'profile_title'),
              onTap   : () => context.push(AppRoutes.profil),
            ),
            _Tile(
              icon    : Icons.settings_rounded,
              title   : 'Einstellungen',
              titleFa : AppL10n.t(context, 'settings_title'),
              onTap   : () => context.push(AppRoutes.settings),
            ),
          ]),
          const SizedBox(height: AppSizes.md),
          _Section(title: AppL10n.t(context, 'support_section'), children: [
            _Tile(
              icon    : Icons.help_outline_rounded,
              title   : 'Fragen & Antworten',
              titleFa : AppL10n.t(context, 'faq_label'),
              onTap   : () => context.push(AppRoutes.fragen),
            ),
            _Tile(
              icon    : Icons.share_rounded,
              title   : 'Soziale Medien',
              titleFa : AppL10n.t(context, 'social_media_label'),
              onTap   : () => context.push(AppRoutes.sozialmedien),
            ),
          ]),
          const SizedBox(height: AppSizes.md),
          _Section(title: AppL10n.t(context, 'about_app'), children: [
            _Tile(
              icon    : Icons.star_rate_rounded,
              title   : 'Bewerten',
              titleFa : AppL10n.t(context, 'rate_app'),
              onTap   : () => _rateApp(),
            ),
            _Tile(
              icon    : Icons.privacy_tip_outlined,
              title   : 'Datenschutz',
              titleFa : AppL10n.t(context, 'privacy_label'),
              onTap   : () => context.push(AppRoutes.privacyPolicy),
            ),
            _Tile(
              icon    : Icons.info_outline_rounded,
              title   : 'Version',
              titleFa : AppL10n.t(context, 'version_label'),
              onTap   : null,
              trailing: const Text('1.0.0',
                  style: TextStyle(color: Colors.grey)),
            ),
          ]),
        ],
      ),
    );
  }

  void _rateApp() async {
    // Placeholder — در production با package_info_plus و store_redirect کامل می‌شود
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String        title;
  final List<Widget>  children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 4),
          child  : Text(title,
              style: TextStyle(
                fontSize  : 12,
                fontWeight: FontWeight.w700,
                color     : Theme.of(context).colorScheme.onSurfaceVariant,
              )),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.titleFa,
    required this.onTap,
    this.trailing,
  });

  final IconData     icon;
  final String       title;
  final String       titleFa;
  final VoidCallback? onTap;
  final Widget?      trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading : Icon(icon,
          color: Theme.of(context).colorScheme.primary),
      title   : Text(title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: Text(titleFa,
          style: TextStyle(
            fontSize: 12,
            color   : Theme.of(context).colorScheme.onSurfaceVariant,
          )),
      trailing: trailing ?? (onTap != null
          ? const Icon(Icons.chevron_right_rounded)
          : null),
      onTap   : onTap,
    );
  }
}
