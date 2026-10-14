import 'package:flutter/material.dart';

import 'favorites_screen.dart';
import 'search_screen.dart';
import 'watched_screen.dart';
import 'wishlist_screen.dart';

/// Controla a navegação principal do aplicativo.
///
/// O MovieApp possui quatro áreas principais:
/// - Pesquisa;
/// - Favoritos;
/// - Já assistidos;
/// - Lista de desejos.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
  });

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  /// Índice da opção atualmente selecionada.
  int _selectedIndex = 0;

  /// Telas disponíveis na navegação principal.
  final List<Widget> _screens = const [
    SearchScreen(),
    FavoritesScreen(),
    WatchedScreen(),
    WishlistScreen(),
  ];

  /// Atualiza o índice da opção selecionada na barra inferior e reconstrói o Scaffold.
  void _changeScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Exibe a tela correspondente ao índice ativo
      body: _screens[_selectedIndex],

      // Barra de navegação inferior padrão Material 3
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _changeScreen,
        destinations: const [
          // Aba 1: Pesquisa de filmes e séries
          NavigationDestination(
            icon: Icon(
              Icons.search_outlined,
            ),
            selectedIcon: Icon(
              Icons.search,
            ),
            label: 'Pesquisa',
          ),

          // Aba 2: Lista de filmes favoritos
          NavigationDestination(
            icon: Icon(
              Icons.favorite_border,
            ),
            selectedIcon: Icon(
              Icons.favorite,
            ),
            label: 'Favoritos',
          ),

          // Aba 3: Histórico de filmes e séries já assistidos
          NavigationDestination(
            icon: Icon(
              Icons.check_circle_outline,
            ),
            selectedIcon: Icon(
              Icons.check_circle,
            ),
            label: 'Já assistidos',
          ),

          // Aba 4: Lista de desejos (quero assistir)
          NavigationDestination(
            icon: Icon(
              Icons.bookmark_border,
            ),
            selectedIcon: Icon(
              Icons.bookmark,
            ),
            label: 'Lista de desejos',
          ),
        ],
      ),
    );
  }
}