import 'package:flutter/material.dart';

import '../models/user_movie.dart';
import '../services/collection_service.dart';
import 'details_screen.dart';

/// Tela responsável por exibir o histórico de filmes assistidos.
///
/// Também apresenta a nota IMDb e a avaliação pessoal do usuário.
class WatchedScreen extends StatefulWidget {
  const WatchedScreen({super.key});

  @override
  State<WatchedScreen> createState() => _WatchedScreenState();
}

class _WatchedScreenState extends State<WatchedScreen> {
  late Future<List<UserMovie>> _watchedFuture;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  /// Carrega os filmes marcados como assistidos.
  void _loadMovies() {
    _watchedFuture = CollectionService.getWatched();
  }

  /// Atualiza a tela após alguma alteração.
  void _refresh() {
    setState(() {
      _loadMovies();
    });
  }

  /// Desmarca um filme como assistido.
  Future<void> _removeWatched(UserMovie movie) async {
    await CollectionService.saveMovie(
      movie.copyWith(
        isWatched: false,
      ),
    );

    _refresh();
  }

  /// Abre os detalhes do filme selecionado.
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
        future: _watchedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final movies = snapshot.data ?? [];

          if (movies.isEmpty) {
            return const _EmptyWatched();
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
                'Já assistidos',
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
                'Seu histórico de cinema, com a sua opinião em notas de 1 a 10.',
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

                                  TextButton(
                                    onPressed: () {
                                      _removeWatched(movie);
                                    },
                                    child: const Text(
                                      'Desmarcar assistido',
                                    ),
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

/// Tela vazia exibida quando nenhum filme foi assistido.
class _EmptyWatched extends StatelessWidget {
  const _EmptyWatched();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum filme assistido',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Marque um filme como assistido nos detalhes.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Exibe o pôster do filme.
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