import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

/// Ponto inicial da aplicação.
///
/// Antes de iniciar a interface, carrega o arquivo `.env`,
/// onde está armazenada a chave da OMDb API.
Future<void> main() async {
  // Garante que os bindings do Flutter estejam inicializados antes de chamadas assíncronas
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega as variáveis de ambiente do arquivo .env (contém a chave da OMDb API)
  await dotenv.load(fileName: '.env');

  // Inicializa a árvore de widgets da aplicação chamando a classe raiz MovieApp
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
    // Escuta reativamente as alterações de modo de tema (claro/escuro) notificadas pelo themeController
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, themeMode, child) {
        // Configura as opções globais do app (título, rotas, tema e tela inicial)
        return MaterialApp(
          title: 'MovieApp',
          // Oculta a faixa de 'DEBUG' no canto superior direito
          debugShowCheckedModeBanner: false,

          // Configurações de tema visual claro e escuro definidos na classe AppTheme
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,

          // Tela de abertura (Splash) apresentada inicialmente ao abrir o app
          home: const SplashScreen(),
        );
      },
    );
  }
}