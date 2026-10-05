import 'package:flutter/material.dart';

/// Controla o tema utilizado pelo aplicativo.
///
/// O usuário pode alternar manualmente entre
/// o tema claro e o tema escuro.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.light);

  /// Alterna entre os temas claro e escuro.
  void toggleTheme() {
    value =
        value == ThemeMode.light
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  /// Informa se o tema escuro está ativo.
  bool get isDark => value == ThemeMode.dark;
}

/// Instância utilizada por todo o aplicativo.
final ThemeController themeController = ThemeController();