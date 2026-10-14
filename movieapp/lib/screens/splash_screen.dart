import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';

/// Tela inicial exibida enquanto o aplicativo termina de carregar.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Inicia a contagem de tempo para redirecionar para a tela inicial
    _openHome();
  }

  /// Aguarda 1.2 segundos para exibir a animação/logo e substitui a rota para a navegação principal.
  Future<void> _openHome() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    // Garante que o widget ainda está montado na árvore antes de navegar
    if (!mounted) {
      return;
    }

    // Substitui a SplashScreen para não permitir retornar a ela com o botão voltar
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => const MainNavigationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo escuro fixo para manter consistência visual com a splash
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo grande centralizada
            Image.asset(
              AppAssets.logo,
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 28),
            // Indicador de progresso circular discreto
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
