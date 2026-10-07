import 'package:flutter/material.dart';

import '../models/movie_details.dart';
import '../models/rating.dart';
import '../models/user_movie.dart';
import '../services/collection_service.dart';
import '../services/omdb_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';

/// Tela responsável por exibir os detalhes completos de uma obra.
///
/// Os dados principais são obtidos através da OMDb API.
/// As informações pessoais do usuário são armazenadas localmente.
class DetailsScreen extends StatefulWidget {
  /// Identificador único da obra no IMDb.
  final String imdbId;

  const DetailsScreen({super.key, required this.imdbId});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  /// Requisição utilizada para buscar os detalhes da obra.
  late Future<MovieDetails> _movieFuture;

  @override
  void initState() {
    super.initState();
    _loadMovie();
  }

  /// Inicia a consulta dos detalhes da obra na OMDb.
  void _loadMovie() {
    _movieFuture = OmdbService.getMovieDetails(widget.imdbId);
  }

  /// Refaz a consulta caso tenha ocorrido algum erro.
  void _retry() {
    setState(() {
      _loadMovie();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeController,
            builder: (context, themeMode, child) {
              final isDark = themeMode == ThemeMode.dark;

              return IconButton(
                tooltip: isDark ? 'Ativar tema claro' : 'Ativar tema escuro',
                onPressed: themeController.toggleTheme,
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<MovieDetails>(
        future: _movieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString(),
              onRetry: _retry,
            );
          }

          final movie = snapshot.data;

          if (movie == null) {
            return const Center(child: Text('Nenhuma informação disponível.'));
          }

          return _MovieDetailsContent(movie: movie);
        },
      ),
    );
  }
}

/// Conteúdo principal da tela de detalhes.
///
/// Além das informações da OMDb, também controla:
/// - Favoritos;
/// - Filmes assistidos;
/// - Lista de desejos;
/// - Nota pessoal.
class _MovieDetailsContent extends StatefulWidget {
  final MovieDetails movie;

  const _MovieDetailsContent({required this.movie});

  @override
  State<_MovieDetailsContent> createState() => _MovieDetailsContentState();
}

class _MovieDetailsContentState extends State<_MovieDetailsContent> {
  /// Dados pessoais associados ao filme.
  UserMovie? _userMovie;

  /// Controla o carregamento das informações locais.
  bool _loadingCollection = true;

  /// Facilita o acesso ao objeto recebido pelo widget.
  MovieDetails get movie => widget.movie;

  @override
  void initState() {
    super.initState();
    _loadCollection();
  }

  /// Carrega os dados pessoais armazenados localmente.
  ///
  /// Caso o filme ainda não tenha dados registrados,
  /// cria um objeto inicial com as informações da OMDb.
  Future<void> _loadCollection() async {
    final savedMovie = await CollectionService.getMovie(movie.imdbId);

    if (!mounted) {
      return;
    }

    setState(() {
      _userMovie =
          savedMovie ??
          UserMovie(
            imdbId: movie.imdbId,
            title: movie.title,
            year: movie.year,
            type: movie.type,
            poster: movie.poster,
            imdbRating: movie.imdbRating,
          );

      _loadingCollection = false;
    });
  }

  /// Salva localmente uma alteração feita pelo usuário.
  Future<void> _save(UserMovie updatedMovie) async {
    await CollectionService.saveMovie(updatedMovie);

    if (!mounted) {
      return;
    }

    setState(() {
      _userMovie = updatedMovie;
    });
  }

  /// Adiciona ou remove o filme dos favoritos.
  Future<void> _toggleFavorite() async {
    final current = _userMovie;

    if (current == null) {
      return;
    }

    await _save(current.copyWith(isFavorite: !current.isFavorite));
  }

  /// Marca ou desmarca o filme como assistido.
  ///
  /// Filmes marcados como assistidos saem da lista de desejos.
  Future<void> _toggleWatched() async {
    final current = _userMovie;

    if (current == null) {
      return;
    }

    final willBeWatched = !current.isWatched;

    await _save(
      current.copyWith(
        isWatched: willBeWatched,
        isWishlist: willBeWatched ? false : current.isWishlist,
        removeRating: !willBeWatched,
      ),
    );
  }

  /// Adiciona ou remove o filme da lista de desejos.
  Future<void> _toggleWishlist() async {
    final current = _userMovie;

    if (current == null || (current.isWatched && !current.isWishlist)) {
      return;
    }

    await _save(current.copyWith(isWishlist: !current.isWishlist));
  }

  /// Define a nota pessoal atribuída pelo usuário.
  Future<void> _setRating(int rating) async {
    final current = _userMovie;

    if (current == null || !current.isWatched) {
      return;
    }

    await _save(current.copyWith(userRating: rating));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card principal com pôster, título e nota.
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Poster(posterUrl: movie.poster),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withValues(
                                  alpha: 0.13,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _formatType(movie.type).toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              movie.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              [
                                movie.year,
                                if (_hasValue(movie.runtime)) movie.runtime,
                              ].join(' · '),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),

                            if (_hasValue(movie.imdbRating)) ...[
                              const SizedBox(height: 14),

                              _ImdbBadge(rating: movie.imdbRating),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Gêneros.
              if (_hasValue(movie.genre))
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: movie.genre
                      .split(',')
                      .map((genre) => Chip(label: Text(genre.trim())))
                      .toList(),
                ),

              const SizedBox(height: 24),

              const _SmallSectionTitle(title: 'SINOPSE'),

              const SizedBox(height: 8),

              Text(
                _hasValue(movie.plot) ? movie.plot : 'Sinopse não disponível.',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
              ),

              const SizedBox(height: 24),

              // Informações em cards, semelhantes ao wireframe.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _InformationCard(
                      children: [
                        if (_hasValue(movie.director))
                          _CompactInfo(label: 'Diretor', value: movie.director),

                        if (_hasValue(movie.actors))
                          _CompactInfo(label: 'Elenco', value: movie.actors),

                        if (_hasValue(movie.writer))
                          _CompactInfo(label: 'Roteiro', value: movie.writer),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _InformationCard(
                      children: [
                        if (_hasValue(movie.language))
                          _CompactInfo(label: 'Idioma', value: movie.language),

                        if (_hasValue(movie.country))
                          _CompactInfo(label: 'País', value: movie.country),

                        if (_hasValue(movie.released))
                          _CompactInfo(
                            label: 'Lançamento',
                            value: movie.released,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              if (_hasValue(movie.awards)) ...[
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.ratingYellow.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.ratingYellow.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_outlined,
                        color: AppTheme.ratingYellow,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PRÊMIOS',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppTheme.ratingYellow,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              movie.awards,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (movie.ratings.isNotEmpty) ...[
                const SizedBox(height: 24),

                const _SmallSectionTitle(title: 'AVALIAÇÕES · OMDb'),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: movie.ratings
                      .map((rating) => _RatingCard(rating: rating))
                      .toList(),
                ),
              ],

              const SizedBox(height: 26),

              const _SmallSectionTitle(title: 'MINHA COLEÇÃO'),

              const SizedBox(height: 10),

              if (_loadingCollection)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_userMovie != null)
                _CollectionCard(
                  userMovie: _userMovie!,
                  onFavorite: _toggleFavorite,
                  onWatched: _toggleWatched,
                  onWishlist: _toggleWishlist,
                  onRatingSelected: _setRating,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Verifica se um valor recebido da OMDb
  /// pode ser exibido na interface.
  static bool _hasValue(String value) {
    return value.isNotEmpty && value != 'N/A';
  }

  /// Traduz os tipos retornados pela OMDb.
  static String _formatType(String type) {
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
}

/// Card responsável por agrupar informações secundárias.
class _InformationCard extends StatelessWidget {
  final List<Widget> children;

  const _InformationCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

/// Mostra uma informação curta com título e conteúdo.
class _CompactInfo extends StatelessWidget {
  final String label;
  final String value;

  const _CompactInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge utilizado para destacar a nota IMDb.
class _ImdbBadge extends StatelessWidget {
  final String rating;

  const _ImdbBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.ratingYellow.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.ratingYellow.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: AppTheme.ratingYellow),

          const SizedBox(width: 5),

          Text(
            '$rating IMDb',
            style: const TextStyle(
              color: AppTheme.ratingYellow,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card contendo as ações pessoais do usuário.
class _CollectionCard extends StatelessWidget {
  final UserMovie userMovie;
  final VoidCallback onFavorite;
  final VoidCallback onWatched;
  final VoidCallback onWishlist;
  final void Function(int rating) onRatingSelected;

  const _CollectionCard({
    required this.userMovie,
    required this.onFavorite,
    required this.onWatched,
    required this.onWishlist,
    required this.onRatingSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _CollectionRow(
              icon: userMovie.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              title: userMovie.isFavorite ? 'Favoritado' : 'Favoritar',
              buttonText: userMovie.isFavorite ? 'Remover' : 'Adicionar',
              active: userMovie.isFavorite,
              onPressed: onFavorite,
            ),

            const Divider(height: 22),

            _CollectionRow(
              icon: userMovie.isWatched
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
              title: userMovie.isWatched ? 'Já assisti' : 'Ainda não assisti',
              buttonText: userMovie.isWatched ? 'Desmarcar' : 'Marcar',
              active: userMovie.isWatched,
              onPressed: onWatched,
            ),

            const Divider(height: 22),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Minha nota · Você',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            if (userMovie.isWatched)
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 1,
                      children: List.generate(10, (index) {
                        final rating = index + 1;

                        final selected =
                            userMovie.userRating != null &&
                            rating <= userMovie.userRating!;

                        return InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            onRatingSelected(rating);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              selected ? Icons.star : Icons.star_border,
                              size: 21,
                              color: AppTheme.ratingYellow,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    userMovie.userRating == null
                        ? '-/10'
                        : '${userMovie.userRating}/10',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.ratingYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Marque como assistido para dar uma nota.',
                  style: theme.textTheme.bodySmall,
                ),
              ),

            const Divider(height: 22),

            _CollectionRow(
              icon: userMovie.isWishlist
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              title: 'Lista de desejos',
              buttonText: userMovie.isWishlist
                  ? 'Remover'
                  : userMovie.isWatched
                  ? 'Já assistido'
                  : 'Adicionar',
              active: userMovie.isWishlist,
              enabled: userMovie.isWishlist || !userMovie.isWatched,
              onPressed: onWishlist,
            ),
          ],
        ),
      ),
    );
  }
}

/// Linha utilizada para as ações da coleção pessoal.
class _CollectionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String buttonText;
  final bool active;
  final bool enabled;
  final VoidCallback onPressed;

  const _CollectionRow({
    required this.icon,
    required this.title,
    required this.buttonText,
    required this.active,
    this.enabled = true,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          color: active
              ? theme.colorScheme.secondary
              : theme.colorScheme.onSurfaceVariant,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        active
            ? FilledButton.tonal(
                onPressed: enabled ? onPressed : null,
                child: Text(buttonText),
              )
            : OutlinedButton(
                onPressed: enabled ? onPressed : null,
                child: Text(buttonText),
              ),
      ],
    );
  }
}

/// Título pequeno utilizado nas seções.
class _SmallSectionTitle extends StatelessWidget {
  final String title;

  const _SmallSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}

/// Exibe uma avaliação recebida da OMDb.
class _RatingCard extends StatelessWidget {
  final Rating rating;

  const _RatingCard({required this.rating});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rating.source,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            rating.value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.ratingYellow,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Exibe o pôster retornado pela OMDb.
class _Poster extends StatelessWidget {
  final String posterUrl;

  const _Poster({required this.posterUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (posterUrl.isEmpty || posterUrl == 'N/A') {
      return Container(
        width: 120,
        height: 175,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.movie_outlined, size: 48),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        posterUrl,
        width: 120,
        height: 175,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 175,
            color: theme.colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.broken_image_outlined),
          );
        },
      ),
    );
  }
}

/// Estado apresentado quando ocorre algum erro
/// durante o carregamento dos detalhes.
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),

            const SizedBox(height: 16),

            Text(
              'Não foi possível carregar os detalhes.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(message, textAlign: TextAlign.center),

            const SizedBox(height: 22),

            FilledButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
