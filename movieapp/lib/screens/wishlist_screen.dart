import 'package:flutter/material.dart';

import '../models/user_movie.dart';
import '../services/collection_service.dart';
import 'details_screen.dart';

/// Tela responsável por exibir os filmes da lista de desejos.
///
/// A lista contém as obras que o usuário pretende assistir.
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

  /// Carrega a lista de desejos salva localmente.
  void _loadWishlist() {
    _wishlistFuture = CollectionService.getWishlist();
  }

  /// Atualiza os dados apresentados na tela.
  void _refresh() {
    setState(() {
      _loadWishlist();
    });
  }

  /// Remove o filme da lista de desejos.
  Future<void> _remove(UserMovie movie) async {
    await CollectionService.saveMovie(
      movie.copyWith(
        isWishlist: false,
      ),
    );

    _refresh();
  }

  /// Marca o filme como assistido.
  ///
  /// O filme também é removido automaticamente
  /// da lista de desejos.
  Future<void> _markWatched(UserMovie movie) async {
    await CollectionService.saveMovie(
      movie.copyWith(
        isWatched: true,
        isWishlist: false,
      ),
    );

    _refresh();
  }

  /// Abre os detalhes do filme.
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
        future: _wishlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final movies = snapshot.data ?? [];

          if (movies.isEmpty) {
            return const _EmptyWishlist();
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
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Lista de desejos',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '${movies.length} ${movies.length == 1 ? 'filme' : 'filmes'}',
              ),

              const SizedBox(height: 8),

              const Text(
                'Suas próximas sessões começam aqui. '
                'Guarde os filmes que quer ver.',
              ),

              const SizedBox(height: 24),

              ...movies.map(
                (movie) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        _openDetails(movie);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
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
                                    style: theme
                                        .textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    '${movie.year} · ${_formatType(movie.type)}',
                                  ),

                                  const SizedBox(height: 8),

                                  const Chip(
                                    label: Text(
                                      'Quero assistir',
                                    ),
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

                                  const SizedBox(height: 12),

                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () {
                                          _markWatched(movie);
                                        },
                                        child: const Text(
                                          'Marcar como assistido',
                                        ),
                                      ),

                                      TextButton(
                                        onPressed: () {
                                          _remove(movie);
                                        },
                                        child: const Text(
                                          'Remover',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

/// Estado exibido quando a lista de desejos está vazia.
class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Lista de desejos vazia',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Adicione filmes que você pretende assistir.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Exibe o pôster salvo junto ao filme.
class _Poster extends StatelessWidget {
  final String poster;

  const _Poster({
    required this.poster,
  });

  @override
  Widget build(BuildContext context) {
    if (poster.isEmpty || poster == 'N/A') {
      return const SizedBox(
        width: 80,
        height: 115,
        child: Icon(
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