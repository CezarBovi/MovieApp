import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';

/// Cabeçalho padrão utilizado nas telas do MovieApp.
///
/// Exibe o nome do aplicativo e permite trocar
/// entre os temas claro e escuro.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    this.subtitle,
  });

  /// Texto opcional exibido abaixo do nome do aplicativo.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MovieApp',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),

        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeController,
          builder: (context, themeMode, child) {
            final isDark = themeMode == ThemeMode.dark;

            return IconButton(
              tooltip: isDark
                  ? 'Ativar tema claro'
                  : 'Ativar tema escuro',
              onPressed: themeController.toggleTheme,
              icon: Icon(
                isDark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
            );
          },
        ),
      ],
    );
  }
}