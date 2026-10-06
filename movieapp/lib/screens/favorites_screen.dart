import 'package:flutter/material.dart';

import '../models/user_movie.dart';
import '../services/collection_service.dart';
import 'details_screen.dart';

/// Tela responsável por exibir os filmes marcados como favoritos.
///
/// Os dados são carregados do armazenamento local do aplicativo.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  /// Lista de favoritos carregada do armazenamento local.
  late Future<List<UserMovie>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  /// Carrega os filmes favoritos salvos localmente.
  void _loadFavorites() {
    _favoritesFuture = CollectionService.getFavorites();
  }

  /// Atualiza a lista exibida na tela.
  void _refresh() {
    setState(() {
      _loadFavorites();
    });
  }

  /// Remove um filme dos favoritos.
  Future<void> _removeFavorite(UserMovie movie) async {
    await CollectionService.saveMovie(
      movie.copyWith(
        isFavorite: false,
      ),
    );

    _refresh();
  }

  /// Abre a tela de detalhes do filme.
  ///
  /// Quando o usuário retorna, a lista é atualizada.
  Future<void> _openDetails(UserMovie movie) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return DetailsScreen(
            imdbId: movie.imdbId,
          );
        },
      ),
    );

    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: FutureBuilder<List<UserMovie>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final movies = snapshot.data ?? [];

          if (movies.isEmpty) {
            return const _EmptyFavorites();
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'MovieApp',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'MINHAS LISTAS',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Favoritos',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '${movies.length} ${movies.length == 1 ? 'filme' : 'filmes'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Os filmes que ficaram com você. Reúna aqui os seus favoritos.',
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 24),

              ...movies.map(
                (movie) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _FavoriteCard(
                    movie: movie,
                    onTap: () {
                      _openDetails(movie);
                    },
                    onRemove: () {
                      _removeFavorite(movie);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Estado exibido quando não existem favoritos.
class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum favorito ainda',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Abra um filme e marque-o como favorito.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Cartão utilizado para representar um filme favorito.
class _FavoriteCard extends StatelessWidget {
  final UserMovie movie;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.movie,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Poster(
                poster: movie.poster,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${movie.year} · ${_formatType(movie.type)}',
                    ),

                    const SizedBox(height: 8),

                    if (movie.isWatched)
                      const Chip(
                        label: Text('Assistido'),
                      ),

                    const SizedBox(height: 6),

                    Text(
                      'IMDb: ${_displayRating(movie.imdbRating)}',
                    ),

                    Text(
                      movie.userRating == null
                          ? 'Minha nota: Ainda sem nota'
                          : 'Minha nota: ${movie.userRating}/10',
                    ),

                    const SizedBox(height: 10),

                    TextButton.icon(
                      onPressed: onRemove,
                      icon: const Icon(
                        Icons.favorite,
                      ),
                      label: const Text(
                        'Remover dos favoritos',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Exibe o pôster salvo com os dados do filme.
class _Poster extends StatelessWidget {
  final String poster;

  const _Poster({
    required this.poster,
  });

  @override
  Widget build(BuildContext context) {
    if (poster.isEmpty || poster == 'N/A') {
      return Container(
        width: 80,
        height: 115,
        alignment: Alignment.center,
        child: const Icon(
          Icons.movie_outlined,
          size: 42,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        poster,
        width: 80,
        height: 115,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            width: 80,
            height: 115,
            child: Icon(
              Icons.broken_image_outlined,
            ),
          );
        },
      ),
    );
  }
}

/// Traduz o tipo salvo pela OMDb.
String _formatType(String type) {
  switch (type) {
    case 'movie':
      return 'Filme';
    case 'series':
      return 'Série';
    case 'episode':
      return 'Episódio';
    default:
      return type;
  }
}

/// Trata notas IMDb vazias.
String _displayRating(String rating) {
  if (rating.isEmpty || rating == 'N/A') {
    return 'Sem nota';
  }

  return rating;
}