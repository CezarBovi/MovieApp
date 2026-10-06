import 'package:flutter/material.dart';

import '../models/user_movie.dart';
import '../services/collection_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import 'details_screen.dart';

/// Exibe todos os filmes marcados como favoritos.
///
/// Os favoritos são armazenados localmente e associados
/// ao IMDb ID de cada obra.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() =>
      _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<UserMovie>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  /// Carrega os favoritos armazenados localmente.
  void _loadFavorites() {
    _favoritesFuture = CollectionService.getFavorites();
  }

  /// Atualiza os dados exibidos na tela.
  void _refresh() {
    setState(() {
      _loadFavorites();
    });
  }

  /// Remove uma obra da lista de favoritos.
  Future<void> _removeFavorite(UserMovie movie) async {
    await CollectionService.saveMovie(
      movie.copyWith(
        isFavorite: false,
      ),
    );

    _refresh();
  }

  /// Abre os detalhes e atualiza a lista ao retornar.
  Future<void> _openDetails(UserMovie movie) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          imdbId: movie.imdbId,
        ),
      ),
    );

    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<UserMovie>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final movies = snapshot.data ?? [];

          if (movies.isEmpty) {
            return const _EmptyFavorites();
          }

          return _FavoritesContent(
            movies: movies,
            onOpenDetails: _openDetails,
            onRemove: _removeFavorite,
          );
        },
      ),
    );
  }
}

/// Conteúdo da tela quando existem filmes favoritos.
class _FavoritesContent extends StatelessWidget {
  final List<UserMovie> movies;
  final Future<void> Function(UserMovie) onOpenDetails;
  final Future<void> Function(UserMovie) onRemove;

  const _FavoritesContent({
    required this.movies,
    required this.onOpenDetails,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 760,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            32,
          ),
          children: [
            const AppHeader(
              subtitle: 'MINHAS LISTAS',
            ),

            const SizedBox(height: 34),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Favoritos',
                    style:
                        theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                _CounterBadge(
                  count: movies.length,
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Os filmes que ficaram com você. '
              'Reúna aqui os seus favoritos.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            ...movies.map(
              (movie) => Padding(
                padding: const EdgeInsets.only(
                  bottom: 14,
                ),
                child: _FavoriteCard(
                  movie: movie,
                  onTap: () {
                    onOpenDetails(movie);
                  },
                  onRemove: () {
                    onRemove(movie);
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color:
                      theme.colorScheme.onSurfaceVariant,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    'Remover dos favoritos não altera '
                    'seu histórico nem a sua nota.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Card visual de um filme favorito.
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Poster(
                    poster: movie.poster,
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          '${movie.year} · '
                          '${_formatType(movie.type)}',
                          style:
                              theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme
                                .onSurfaceVariant,
                          ),
                        ),

                        if (movie.isWatched) ...[
                          const SizedBox(height: 7),

                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 17,
                                color:
                                    theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Assistido',
                                style: TextStyle(
                                  color: theme
                                      .colorScheme.primary,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  Icon(
                    Icons.chevron_right,
                    color:
                        theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _RatingBox(
                    title: 'Nota IMDb · OMDb',
                    value:
                        _displayRating(movie.imdbRating),
                    icon: Icons.star,
                    color: AppTheme.ratingYellow,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _RatingBox(
                    title: 'Minha nota · Você',
                    value: movie.userRating == null
                        ? 'Ainda sem nota'
                        : '${movie.userRating}/10',
                    icon: Icons.star_outline,
                    color:
                        Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.delete_outline,
                ),
                label: const Text(
                  'Remover dos favoritos',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tela vazia apresentada quando não há favoritos.
class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 18),
            Text(
              'Nenhum favorito ainda',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Abra os detalhes de um filme e '
              'adicione-o aos favoritos.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge com a quantidade de filmes da lista.
class _CounterBadge extends StatelessWidget {
  final int count;

  const _CounterBadge({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count ${count == 1 ? 'filme' : 'filmes'}',
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Caixa utilizada para exibir avaliações.
class _RatingBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _RatingBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Exibe o pôster salvo localmente.
class _Poster extends StatelessWidget {
  final String poster;

  const _Poster({
    required this.poster,
  });

  @override
  Widget build(BuildContext context) {
    if (poster.isEmpty || poster == 'N/A') {
      return Container(
        width: 84,
        height: 116,
        alignment: Alignment.center,
        child: const Icon(
          Icons.movie_outlined,
          size: 40,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        poster,
        width: 84,
        height: 116,
        fit: BoxFit.cover,
      ),
    );
  }
}

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

String _displayRating(String rating) {
  if (rating.isEmpty || rating == 'N/A') {
    return 'Sem nota';
  }

  return rating;
}