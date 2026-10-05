import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

/// Ponto inicial da aplicação.
///
/// Antes de iniciar a interface, carrega o arquivo `.env`,
/// onde está armazenada a chave da OMDb API.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  runApp(const MovieApp());
}

/// Widget principal do MovieApp.
///
/// Define os temas claro e escuro e acompanha
/// as alterações feitas pelo [ThemeController].
class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'MovieApp',
          debugShowCheckedModeBanner: false,

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,

          home: const MainNavigationScreen(),
        );
      },
    );
  }
}