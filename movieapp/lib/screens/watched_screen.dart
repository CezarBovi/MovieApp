import 'package:flutter/material.dart';

/// Tela responsável por exibir os filmes já assistidos.
///
/// Posteriormente também mostrará a nota pessoal
/// atribuída pelo usuário.
class WatchedScreen extends StatelessWidget {
  const WatchedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Já assistidos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Nenhum filme marcado como assistido.',
            ),
          ],
        ),
      ),
    );
  }
}