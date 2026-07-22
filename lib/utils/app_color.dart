import 'package:flutter/material.dart';

/// Cyberpunk-inspired colors used throughout the app.
///
/// Prefer semantic colors in widgets so light/dark mode is automatic:
/// `Theme.of(context).colorScheme.surface`.
abstract final class AppColor {
  AppColor._();

  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonGreenDark = Color(0xFF00B82E);
  static const Color electricCyan = Color(0xFF00F5FF);
  static const Color cyberPink = Color(0xFFFF2BD6);

  // Light theme values. Each name matches a ColorScheme property.
  static const Color lightPrimary = neonGreenDark;
  static const Color lightOnPrimary = Colors.black;
  static const Color lightPrimaryContainer = Color(0xFFB8FFAA);
  static const Color lightOnPrimaryContainer = Color(0xFF002204);
  static const Color lightSecondary = Color(0xFF007F70);
  static const Color lightOnSecondary = Colors.white;
  static const Color lightSecondaryContainer = Color(0xFFA4F2E2);
  static const Color lightOnSecondaryContainer = Color(0xFF00201B);
  static const Color lightTertiary = Color(0xFFAD008F);
  static const Color lightOnTertiary = Colors.white;
  static const Color lightTertiaryContainer = Color(0xFFFFD8F3);
  static const Color lightOnTertiaryContainer = Color(0xFF3A0030);
  static const Color lightBackground = Color(0xFFF2F8F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF071407);
  static const Color lightSurfaceContainer = Color(0xFFE2EEE2);
  static const Color lightOnSurfaceVariant = Color(0xFF3F4A3F);
  static const Color lightOutline = Color(0xFF5C735D);
  static const Color lightOutlineVariant = Color(0xFFBCCBBC);
  static const Color lightError = Color.fromARGB(255, 255, 0, 0);
  static const Color lightOnError = Colors.white;

  // Dark theme values. Each name matches a ColorScheme property.
  static const Color darkPrimary = neonGreen;
  static const Color darkOnPrimary = Colors.black;
  static const Color darkPrimaryContainer = Color(0xFF075E16);
  static const Color darkOnPrimaryContainer = Color(0xFFB8FFAA);
  static const Color darkSecondary = electricCyan;
  static const Color darkOnSecondary = Colors.black;
  static const Color darkSecondaryContainer = Color(0xFF004F54);
  static const Color darkOnSecondaryContainer = Color(0xFFA4F7FF);
  static const Color darkTertiary = cyberPink;
  static const Color darkOnTertiary = Colors.black;
  static const Color darkTertiaryContainer = Color(0xFF790065);
  static const Color darkOnTertiaryContainer = Color(0xFFFFD8F3);
  static const Color darkBackground = Color(0xFF030704);
  static const Color darkSurface = Color(0xFF080E09);
  static const Color darkOnSurface = Color(0xFFE9FFE8);
  static const Color darkSurfaceContainer = Color(0xFF101A12);
  static const Color darkOnSurfaceVariant = Color(0xFFBACABA);
  static const Color darkOutline = Color(0xFF668568);
  static const Color darkOutlineVariant = Color(0xFF3C4A3D);
  static const Color darkError = Color.fromARGB(255, 255, 0, 0);
  static const Color darkOnError = Colors.white;

  static final ColorScheme lightColorScheme =
      ColorScheme.fromSeed(
        seedColor: neonGreen,
        brightness: Brightness.light,
      ).copyWith(
        primary: lightPrimary,
        onPrimary: lightOnPrimary,
        primaryContainer: lightPrimaryContainer,
        onPrimaryContainer: lightOnPrimaryContainer,
        secondary: lightSecondary,
        onSecondary: lightOnSecondary,
        secondaryContainer: lightSecondaryContainer,
        onSecondaryContainer: lightOnSecondaryContainer,
        tertiary: lightTertiary,
        onTertiary: lightOnTertiary,
        tertiaryContainer: lightTertiaryContainer,
        onTertiaryContainer: lightOnTertiaryContainer,
        surface: lightSurface,
        onSurface: lightOnSurface,
        surfaceContainer: lightSurfaceContainer,
        onSurfaceVariant: lightOnSurfaceVariant,
        outline: lightOutline,
        outlineVariant: lightOutlineVariant,
        error: lightError,
        onError: lightOnError,
      );

  static final ColorScheme darkColorScheme =
      ColorScheme.fromSeed(
        seedColor: neonGreen,
        brightness: Brightness.dark,
      ).copyWith(
        primary: darkPrimary,
        onPrimary: darkOnPrimary,
        primaryContainer: darkPrimaryContainer,
        onPrimaryContainer: darkOnPrimaryContainer,
        secondary: darkSecondary,
        onSecondary: darkOnSecondary,
        secondaryContainer: darkSecondaryContainer,
        onSecondaryContainer: darkOnSecondaryContainer,
        tertiary: darkTertiary,
        onTertiary: darkOnTertiary,
        tertiaryContainer: darkTertiaryContainer,
        onTertiaryContainer: darkOnTertiaryContainer,
        surface: darkSurface,
        onSurface: darkOnSurface,
        surfaceContainer: darkSurfaceContainer,
        onSurfaceVariant: darkOnSurfaceVariant,
        outline: darkOutline,
        outlineVariant: darkOutlineVariant,
        error: darkError,
        onError: darkOnError,
      );
}
