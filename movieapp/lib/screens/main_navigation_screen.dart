import 'package:flutter/material.dart';

import 'favorites_screen.dart';
import 'search_screen.dart';
import 'watched_screen.dart';
import 'wishlist_screen.dart';

/// Tela principal responsável pela navegação entre as áreas do aplicativo.
///
/// As opções disponíveis são:
/// - Pesquisa;
/// - Favoritos;
/// - Já assistidos;
/// - Lista de desejos.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  /// Índice da tela atualmente selecionada.
  int _selectedIndex = 0;

  /// Telas exibidas pela navegação inferior.
  final List<Widget> _screens = const [
    SearchScreen(),
    FavoritesScreen(),
    WatchedScreen(),
    WishlistScreen(),
  ];

  /// Altera a tela exibida de acordo com a opção selecionada.
  void _changeScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _changeScreen,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Pesquisa',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Já assistidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Lista de desejos',
          ),
        ],
      ),
    );
  }
}