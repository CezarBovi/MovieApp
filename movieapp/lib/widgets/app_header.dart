import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';

/// Cabeçalho padrão do MovieApp.
///
/// Exibe o nome do aplicativo, um subtítulo opcional
/// e o botão responsável pela troca de tema.
class AppHeader extends StatelessWidget {
  final String? subtitle;

  const AppHeader({
    super.key,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MovieApp',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              if (subtitle != null) ...[
                const SizedBox(height: 3),

                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
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

            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: IconButton(
                tooltip: isDark
                    ? 'Ativar tema claro'
                    : 'Ativar tema escuro',
                onPressed: themeController.toggleTheme,
                icon: Icon(
                  isDark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}