import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
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
    // Obtém o tema atual do contexto para tipografia e esquema de cores
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Coluna com a logo e título ocupando o espaço disponível à esquerda
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linha contendo a logo arredondada e o nome da aplicação
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      AppAssets.logo,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'MovieApp',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),

              // Subtítulo descritivo exibido caso tenha sido fornecido
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

        // Botão para alternar entre tema claro e escuro reativamente
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