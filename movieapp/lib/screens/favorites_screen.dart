import 'package:flutter/material.dart';

/// Tela responsável por exibir os filmes favoritos do usuário.
///
/// A persistência dos favoritos será implementada posteriormente.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Favoritos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Nenhum filme favorito ainda.',
            ),
          ],
        ),
      ),
    );
  }
}