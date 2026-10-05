import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'theme/app_theme.dart';

/// Ponto inicial da aplicação.
///
/// Antes de iniciar o aplicativo, o arquivo `.env` é carregado.
/// Esse arquivo contém informações privadas, como a chave da OMDb API,
/// e não será enviado para o GitHub.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  runApp(const MovieApp());
}

/// Widget principal do MovieApp.
///
/// Responsável por configurar:
/// - nome do aplicativo;
/// - tema claro;
/// - tema escuro;
/// - tema utilizado pelo sistema;
/// - primeira tela exibida.
class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MovieApp',
      debugShowCheckedModeBanner: false,

      // Temas definidos no arquivo app_theme.dart.
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Por enquanto, o aplicativo acompanha o tema do dispositivo.
      // Posteriormente será possível alterar o tema dentro do próprio app.
      themeMode: ThemeMode.system,

      home: const HomeTestScreen(),
    );
  }
}

/// Tela temporária utilizada para verificar se a aplicação
/// e os temas foram configurados corretamente.
///
/// Esta tela será substituída posteriormente pela tela de pesquisa.
class HomeTestScreen extends StatelessWidget {
  const HomeTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MovieApp'),
      ),
      body: const Center(
        child: Text(
          'MovieApp funcionando!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}