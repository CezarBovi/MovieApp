import 'package:flutter/material.dart';

/// Centraliza toda a identidade visual do MovieApp.
///
/// As cores foram baseadas no wireframe do projeto,
/// utilizando azul como cor principal, roxo como apoio
/// e variações específicas para os temas claro e escuro.
class AppTheme {
  // Cores principais do projeto.
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color secondaryPurple = Color(0xFF8B5CF6);
  static const Color ratingYellow = Color(0xFFF5C451);

  // Tema escuro.
  static const Color darkBackground = Color(0xFF08111F);
  static const Color darkSurface = Color(0xFF111B2A);
  static const Color darkSurfaceSecondary = Color(0xFF172235);
  static const Color darkBorder = Color(0xFF26344A);

  // Tema claro.
  static const Color lightBackground = Color(0xFFF5F7FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFF0F3F9);
  static const Color lightBorder = Color(0xFFDDE3ED);

  /// Tema claro do aplicativo.
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
    ).copyWith(
      primary: primaryBlue,
      secondary: secondaryPurple,
      surface: lightSurface,
      onSurface: const Color(0xFF111827),
      surfaceContainerHighest: lightSurfaceSecondary,
      outlineVariant: lightBorder,
    ),

    scaffoldBackgroundColor: lightBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: Color(0xFF111827),
      elevation: 0,
      scrolledUnderElevation: 0,
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: lightBorder,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF7A8494),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: lightBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: lightBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryBlue,
          width: 2,
        ),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: lightSurface,
      indicatorColor: const Color(0xFFDCEAFF),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: primaryBlue,
            );
          }

          return const IconThemeData(
            color: Color(0xFF6B7280),
          );
        },
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            );
          }

          return const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
          );
        },
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF0ECFF),
      selectedColor: const Color(0xFFE6DEFF),
      side: const BorderSide(
        color: Color(0xFFDDD5F8),
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF5B3FA3),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    dividerColor: lightBorder,
  );

  /// Tema escuro do aplicativo.
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primaryBlue,
      secondary: secondaryPurple,
      surface: darkSurface,
      onSurface: const Color(0xFFF6F8FC),
      surfaceContainerHighest: darkSurfaceSecondary,
      outlineVariant: darkBorder,
    ),

    scaffoldBackgroundColor: darkBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: darkBorder,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF8290A3),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: darkBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: darkBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryBlue,
          width: 2,
        ),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: const Color(0xFF0D1725),
      indicatorColor: const Color(0xFF172E61),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: primaryBlue,
            );
          }

          return const IconThemeData(
            color: Color(0xFF8B98AA),
          );
        },
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            );
          }

          return const TextStyle(
            color: Color(0xFF8B98AA),
            fontSize: 12,
          );
        },
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF201A3B),
      selectedColor: const Color(0xFF30255C),
      side: const BorderSide(
        color: Color(0xFF413474),
      ),
      labelStyle: const TextStyle(
        color: Color(0xFFCABFFF),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    dividerColor: darkBorder,
  );
}