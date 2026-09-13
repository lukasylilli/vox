// FILE: lib/core/theme/app_theme.dart
// DEPS: app_colors.dart
// PURPOSE: Material 3 ThemeData — dark/light modes, Vazirmatn font, component styles
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

const _vazirmatn = 'Vazirmatn';

class AppTheme {
  AppTheme._();

  static ThemeData get dark  => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark       = brightness == Brightness.dark;
    final bg           = isDark ? AppColors.bgDark        : AppColors.bgLight;
    final surface      = isDark ? AppColors.surfaceDark   : AppColors.surfaceLight;
    final surfaceVar   = isDark ? AppColors.surfaceVariantDark : const Color(0xFFE8E8F4);
    final onSurface    = isDark ? AppColors.textPrimary   : const Color(0xFF111122);
    final onSurfaceVar = isDark ? AppColors.textSecondary : const Color(0xFF444466);

    final colorScheme = ColorScheme(
      brightness           : brightness,
      primary              : AppColors.primary,
      onPrimary            : Colors.white,
      primaryContainer     : AppColors.primaryDark,
      onPrimaryContainer   : Colors.white,
      secondary            : AppColors.secondary,
      onSecondary          : Colors.black,
      secondaryContainer   : const Color(0xFF004D5F),
      onSecondaryContainer : Colors.white,
      error                : AppColors.error,
      onError              : Colors.white,
      errorContainer       : const Color(0xFF93000A),
      onErrorContainer     : Colors.white,
      surface              : surface,
      onSurface            : onSurface,
      surfaceContainerHighest: surfaceVar,
      onSurfaceVariant     : onSurfaceVar,
      outline              : isDark ? const Color(0xFF44445A) : const Color(0xFFAAAAAC),
    );

    final base = TextTheme(
      displayLarge  : TextStyle(color: onSurface,    fontWeight: FontWeight.w700),
      displayMedium : TextStyle(color: onSurface,    fontWeight: FontWeight.w700),
      headlineLarge : TextStyle(color: onSurface,    fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(color: onSurface,    fontWeight: FontWeight.w600),
      headlineSmall : TextStyle(color: onSurface,    fontWeight: FontWeight.w600),
      titleLarge    : TextStyle(color: onSurface,    fontWeight: FontWeight.w600),
      titleMedium   : TextStyle(color: onSurface,    fontWeight: FontWeight.w500),
      titleSmall    : TextStyle(color: onSurfaceVar, fontWeight: FontWeight.w500),
      bodyLarge     : TextStyle(color: onSurface),
      bodyMedium    : TextStyle(color: onSurface),
      bodySmall     : TextStyle(color: onSurfaceVar),
      labelLarge    : TextStyle(color: onSurface,    fontWeight: FontWeight.w600),
      labelMedium   : TextStyle(color: onSurfaceVar),
      labelSmall    : TextStyle(color: onSurfaceVar),
    );

    return ThemeData(
      useMaterial3          : true,
      colorScheme           : colorScheme,
      scaffoldBackgroundColor: bg,
      textTheme             : base.apply(fontFamily: _vazirmatn),
      appBarTheme: AppBarTheme(
        backgroundColor       : bg,
        elevation             : 0,
        scrolledUnderElevation: 0,
        centerTitle           : true,
        titleTextStyle        : TextStyle(
          fontFamily: _vazirmatn,
          color: onSurface, fontSize: 18, fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      cardTheme: CardThemeData(
        color    : isDark ? AppColors.cardDark : Colors.white,
        elevation: 0,
        shape    : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(
        color    : isDark ? const Color(0xFF2A2A3A) : const Color(0xFFE0E0EE),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled     : true,
        fillColor  : surfaceVar,
        border     : OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide  : BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      // Web: gleiche Übergänge, egal auf welchem Betriebssystem der Browser läuft.
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: const FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      snackBarTheme: SnackBarThemeData(
        behavior         : SnackBarBehavior.floating,
        shape            : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        backgroundColor  : isDark
            ? const Color(0xFF2A2A3A)
            : const Color(0xFF222233),
        contentTextStyle : TextStyle(fontFamily: _vazirmatn, color: Colors.white),
      ),
    );
  }
}
