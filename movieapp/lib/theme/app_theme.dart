import 'package:flutter/material.dart';

/// Centraliza toda a identidade visual do MovieApp.
///
/// As cores foram baseadas no wireframe do projeto,
/// utilizando azul como cor principal, roxo como apoio
/// e variações específicas para os temas claro e escuro.
class AppTheme {
  // Cores principais do projeto (identidade visual).
  static const Color primaryBlue = Color(0xFF3B82F6); // Cor de destaque principal (botões, títulos)
  static const Color secondaryPurple = Color(0xFF8B5CF6); // Cor secundária para badges e complementos
  static const Color ratingYellow = Color(0xFFF5C451); // Cor dourada/amarela para notas de avaliação e estrelas

  // Cores para a paleta do Tema Escuro.
  static const Color darkBackground = Color(0xFF08111F); // Fundo principal da aplicação no modo escuro
  static const Color darkSurface = Color(0xFF111B2A); // Superfície de cards, campos e modais no modo escuro
  static const Color darkSurfaceSecondary = Color(0xFF172235); // Superfície com leve contraste para containers
  static const Color darkBorder = Color(0xFF26344A); // Bordas e divisores sutis no modo escuro

  // Cores para a paleta do Tema Claro.
  static const Color lightBackground = Color(0xFFF5F7FC); // Fundo principal da aplicação no modo claro
  static const Color lightSurface = Color(0xFFFFFFFF); // Superfície branca para cards e elementos principais
  static const Color lightSurfaceSecondary = Color(0xFFF0F3F9); // Superfície cinza clara de apoio
  static const Color lightBorder = Color(0xFFDDE3ED); // Bordas e divisores sutis no modo claro

  /// Tema claro do aplicativo com estilização Material 3.
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Esquema de cores semântico para o tema claro
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

    // Cor de fundo padrão dos Scaffolds
    scaffoldBackgroundColor: lightBackground,

    // Estilo da barra superior (AppBar)
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: Color(0xFF111827),
      elevation: 0,
      scrolledUnderElevation: 0,
    ),

    // Estilo padrão dos Cards (cantos arredondados, sem sombra pesada e com borda sutil)
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

    // Estilização dos campos de texto (TextField/TextFormField)
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

    // Estilização da barra de navegação inferior (NavigationBar)
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: lightSurface,
      indicatorColor: const Color(0xFFDCEAFF),
      // Cores dos ícones baseadas no estado (selecionado vs não selecionado)
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
      // Estilo do texto dos rótulos baseado no estado
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

    // Estilo dos botões preenchidos principais (FilledButton)
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

    // Estilo visual dos Chips e tags de categorias
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

    // Cor das linhas divisórias
    dividerColor: lightBorder,
  );

  /// Tema escuro do aplicativo com estilização Material 3.
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Esquema de cores semântico para o tema escuro
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

    // Cor de fundo dos Scaffolds no tema escuro
    scaffoldBackgroundColor: darkBackground,

    // Estilo da barra superior no modo escuro
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),

    // Estilo dos Cards no tema escuro
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

    // Estilo dos campos de entrada de texto no tema escuro
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

    // Estilo da barra de navegação inferior no tema escuro
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: const Color(0xFF0D1725),
      indicatorColor: const Color(0xFF172E61),
      // Cores dos ícones baseadas no estado
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
      // Estilo do texto dos rótulos baseado no estado
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

    // Estilo dos botões preenchidos no tema escuro
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

    // Estilo visual dos Chips no tema escuro
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

    // Cor das linhas divisórias no tema escuro
    dividerColor: darkBorder,
  );

}