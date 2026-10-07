import 'package:flutter/material.dart';

import '../models/user_movie.dart';
import '../services/collection_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import 'details_screen.dart';

/// Exibe os filmes que o usuário pretende assistir.
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late Future<List<UserMovie>> _wishlistFuture;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  /// Carrega os filmes da lista de desejos.
  void _loadWishlist() {
    _wishlistFuture = CollectionService.getWishlist();
  }

  void _refresh() {
    setState(() {
      _loadWishlist();
    });
  }

  /// Remove um filme da lista de desejos.
  Future<void> _remove(UserMovie movie) async {
    await CollectionService.saveMovie(movie.copyWith(isWishlist: false));

    _refresh();
  }

  /// Marca a obra como assistida e a remove
  /// da lista de desejos.
  Future<void> _markWatched(UserMovie movie) async {
    await CollectionService.saveMovie(
      movie.copyWith(isWatched: true, isWishlist: false),
    );

    _refresh();
  }

  Future<void> _openDetails(UserMovie movie) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(imdbId: movie.imdbId),
      ),
    );

    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<UserMovie>>(
        future: _wishlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final movies = snapshot.data ?? [];

          if (movies.isEmpty) {
            return const _EmptyWishlist();
          }

          return _WishlistContent(
            movies: movies,
            onOpenDetails: _openDetails,
            onRemove: _remove,
            onWatched: _markWatched,
          );
        },
      ),
    );
  }
}

class _WishlistContent extends StatelessWidget {
  final List<UserMovie> movies;
  final Future<void> Function(UserMovie) onOpenDetails;
  final Future<void> Function(UserMovie) onRemove;
  final Future<void> Function(UserMovie) onWatched;

  const _WishlistContent({
    required this.movies,
    required this.onOpenDetails,
    required this.onRemove,
    required this.onWatched,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            const AppHeader(subtitle: 'MINHAS LISTAS'),

            const SizedBox(height: 34),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Lista de desejos',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                _CounterBadge(count: movies.length),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Suas próximas sessões começam aqui. '
              'Guarde os filmes que quer ver.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            ...movies.map(
              (movie) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _WishlistCard(
                  movie: movie,
                  onTap: () {
                    onOpenDetails(movie);
                  },
                  onWatched: () {
                    onWatched(movie);
                  },
                  onRemove: () {
                    onRemove(movie);
                  },
                ),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Depois de assistir, marque o filme '
              'como assistido e dê a sua nota nos detalhes.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final UserMovie movie;
  final VoidCallback onTap;
  final VoidCallback onWatched;
  final VoidCallback onRemove;

  const _WishlistCard({
    required this.movie,
    required this.onTap,
    required this.onWatched,
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
              onTap: onTap,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Poster(poster: movie.poster),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${movie.year} · '
                          '${_formatType(movie.type)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: 17,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Quero assistir',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _RatingBox(
                    title: 'Nota IMDb · OMDb',
                    value: _displayRating(movie.imdbRating),
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
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: onWatched,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Marcar como assistido'),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remover'),
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

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

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
              Icons.bookmark_border,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 18),
            Text(
              'Lista de desejos vazia',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione filmes que você pretende assistir.',
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

class _CounterBadge extends StatelessWidget {
  final int count;

  const _CounterBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count ${count == 1 ? 'filme' : 'filmes'}',
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _RatingBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _RatingBox({
    required this.title,
    required this.value,
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
          Text(title, style: theme.textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  final String poster;

  const _Poster({required this.poster});

  @override
  Widget build(BuildContext context) {
    if (poster.isEmpty || poster == 'N/A') {
      return const SizedBox(
        width: 84,
        height: 116,
        child: Icon(Icons.movie_outlined, size: 40),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(poster, width: 84, height: 116, fit: BoxFit.cover),
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
  return rating.isEmpty || rating == 'N/A' ? 'Sem nota' : rating;
}
