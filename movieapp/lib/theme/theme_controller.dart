import 'package:flutter/material.dart';

/// Controla o tema utilizado pelo aplicativo.
///
/// O usuário pode alternar manualmente entre
/// o tema claro e o tema escuro.
/// Estende [ValueNotifier] para notificar os listeners sempre que o tema mudar.
class ThemeController extends ValueNotifier<ThemeMode> {
  // Inicializa o estado com o tema claro (ThemeMode.light) por padrão.
  ThemeController() : super(ThemeMode.light);

  /// Alterna entre os temas claro e escuro.
  /// Se o valor atual for claro, muda para escuro; caso contrário, muda para claro.
  void toggleTheme() {
    value =
        value == ThemeMode.light
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  /// Informa se o tema escuro está ativo atualmente.
  bool get isDark => value == ThemeMode.dark;
}

/// Instância única (Singleton/global) utilizada por todo o aplicativo para escutar e alternar o tema.
final ThemeController themeController = ThemeController();