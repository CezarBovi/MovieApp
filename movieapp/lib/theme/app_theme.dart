import 'package:flutter/material.dart';

/// Classe responsável pela configuração visual do aplicativo.
///
/// Contém os temas claro e escuro utilizados pelo MovieApp.
/// Dessa forma, as configurações de cores e componentes ficam
/// centralizadas em apenas um arquivo.
class AppTheme {
  /// Tema claro do aplicativo.
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3B82F6),
      brightness: Brightness.light,
    ),

    // Cor principal do fundo das telas.
    scaffoldBackgroundColor: const Color(0xFFF7F7F8),

    // Configuração padrão das barras superiores.
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF7F7F8),
      foregroundColor: Color(0xFF111827),
      elevation: 0,
    ),

    // Configuração padrão dos cartões.
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
    ),

    // Aparência padrão dos campos de texto.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFD1D5DB),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFD1D5DB),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF3B82F6),
          width: 2,
        ),
      ),
    ),
  );

  /// Tema escuro do aplicativo.
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3B82F6),
      brightness: Brightness.dark,
    ),

    scaffoldBackgroundColor: const Color(0xFF0E1116),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0E1116),
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF171B22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF30363D),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF30363D),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF3B82F6),
          width: 2,
        ),
      ),
    ),
  );
}