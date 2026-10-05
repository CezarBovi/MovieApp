import 'package:flutter/material.dart';

/// Tela responsável pela lista de desejos do usuário.
///
/// Aqui serão armazenados os filmes que o usuário
/// pretende assistir futuramente.
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Lista de desejos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Sua lista de desejos está vazia.',
            ),
          ],
        ),
      ),
    );
  }
}