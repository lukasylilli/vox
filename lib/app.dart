// FILE: lib/app.dart
// DEPS: app_router.dart, app_theme.dart, app_l10n.dart, geraete_sprache.dart, dokument_sprache.dart, settings_controller.dart
// EXPORTS: VoxApp
// PURPOSE: Root widget — theme, locale, RTL scroll behavior, router
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_l10n.dart';
import 'core/l10n/geraete_sprache.dart';
import 'core/utils/dokument_sprache.dart';
import 'core/utils/formatters.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/more/controllers/konto_abgleich.dart';
import 'features/more/controllers/settings_controller.dart';

// Removes the glow overscroll effect that looks odd with RTL + Material 3
class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();
  @override
  Widget buildOverscrollIndicator(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child;
}

class VoxApp extends ConsumerWidget {
  const VoxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // S.3 Schritt 3: Konto-Abgleich im Hintergrund (ohne Konfiguration: nichts).
    ref.watch(kontoAbgleichStarterProvider);
    final themeMode     = ref.watch(themeModeProvider);
    final settingsAsync = ref.watch(settingsProvider);

    final resolvedMode   = settingsAsync.valueOrNull?.themeMode ?? themeMode;
    // L.3: solange die Einstellungen laden, schon die Gerätesprache zeigen —
    // nie kurz Persisch für einen englischsprachigen Besucher.
    final resolvedLocale = Locale(
        settingsAsync.valueOrNull?.uiLanguage ?? GeraeteSprache.aktuell);
    // فاز L: statische Sprach-Flags für kontextlose Schichten
    AppL10n.activeLang = resolvedLocale.languageCode;
    Formatters.useFa   = resolvedLocale.languageCode == 'fa';
    // <html lang> mitziehen, damit der Browser keine falsche Übersetzung anbietet.
    setzeDokumentSprache(resolvedLocale.languageCode);

    return MaterialApp.router(
      title              : 'VOX',
      debugShowCheckedModeBanner: false,
      theme              : AppTheme.light,
      darkTheme          : AppTheme.dark,
      themeMode          : resolvedMode,
      locale             : resolvedLocale,
      supportedLocales   : AppL10n.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      scrollBehavior : const _NoGlowScrollBehavior(),
      routerConfig   : appRouter,
    );
  }
}
