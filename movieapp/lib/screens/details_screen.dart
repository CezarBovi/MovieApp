
import 'package:flutter/material.dart';

import '../models/movie_details.dart';
import '../models/rating.dart';
import '../models/user_movie.dart';
import '../services/omdb_service.dart';
import '../services/collection_service.dart';

/// Tela responsável por exibir os detalhes de um filme ou série.
///
/// Os dados são consultados na OMDb utilizando o IMDb ID.
/// Também permite gerenciar favoritos, filmes assistidos,
/// lista de desejos e avaliações pessoais.
class DetailsScreen extends StatefulWidget {
  /// Identificador único da obra no IMDb.
  final String imdbId;

  const DetailsScreen({
    super.key,
    required this.imdbId,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  /// Requisição responsável por carregar os detalhes da obra.
  late Future<MovieDetails> _movieFuture;

  @override
  void initState() {
    super.initState();
    _loadMovie();
  }

  /// Realiza a consulta dos detalhes na OMDb.
  void _loadMovie() {
    _movieFuture = OmdbService.getMovieDetails(widget.imdbId);
  }

  /// Repete a consulta caso ocorra algum erro.
  void _retry() {
    setState(() {
      _loadMovie();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
      ),
      body: FutureBuilder<MovieDetails>(
        future: _movieFuture,
        builder: (context, snapshot) {
          // Aguarda a resposta da API.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Exibe uma mensagem caso a requisição falhe.
          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString(),
              onRetry: _retry,
            );
          }

          final movie = snapshot.data;

          if (movie == null) {
            return const Center(
              child: Text('Nenhuma informação disponível.'),
            );
          }

          return _MovieDetailsContent(movie: movie);
        },
      ),
    );
  }
}

/// Conteúdo principal da tela de detalhes.
///
/// Apresenta as informações da OMDb e gerencia os dados
/// pessoais do usuário armazenados localmente.
class _MovieDetailsContent extends StatefulWidget {
  final MovieDetails movie;

  const _MovieDetailsContent({
    required this.movie,
  });

  @override
  State<_MovieDetailsContent> createState() =>
      _MovieDetailsContentState();
}

class _MovieDetailsContentState
    extends State<_MovieDetailsContent> {

  /// Informações pessoais relacionadas ao filme.
  UserMovie? _userMovie;

  /// Indica se os dados locais estão sendo carregados.
  bool _loadingCollection = true;

  /// Facilita o acesso às informações da obra.
  MovieDetails get movie => widget.movie;

  @override
  void initState() {
    super.initState();
    _loadCollection();
  }

  /// Carrega os dados pessoais já salvos para o filme.
  ///
  /// Caso não exista um registro, cria um objeto inicial
  /// com as informações recebidas da OMDb.
  Future<void> _loadCollection() async {
    final savedMovie =
        await CollectionService.getMovie(movie.imdbId);

    if (!mounted) return;

    setState(() {
      _userMovie = savedMovie ??
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

  /// Salva as alterações feitas pelo usuário
  /// utilizando o armazenamento local.
  Future<void> _save(UserMovie updatedMovie) async {
    await CollectionService.saveMovie(updatedMovie);

    if (!mounted) return;

    setState(() {
      _userMovie = updatedMovie;
    });
  }

  /// Adiciona ou remove o filme dos favoritos.
  Future<void> _toggleFavorite() async {
    final current = _userMovie;

    if (current == null) return;

    await _save(
      current.copyWith(
        isFavorite: !current.isFavorite,
      ),
    );
  }

  /// Marca ou desmarca o filme como assistido.
  ///
  /// Ao marcar como assistido, o filme é removido
  /// automaticamente da lista de desejos.
  Future<void> _toggleWatched() async {
    final current = _userMovie;

    if (current == null) return;

    final willBeWatched = !current.isWatched;

    await _save(
      current.copyWith(
        isWatched: willBeWatched,
        isWishlist: willBeWatched
            ? false
            : current.isWishlist,
      ),
    );
  }

  /// Adiciona ou remove o filme da lista de desejos.
  Future<void> _toggleWishlist() async {
    final current = _userMovie;

    if (current == null) return;

    await _save(
      current.copyWith(
        isWishlist: !current.isWishlist,
      ),
    );
  }

  /// Abre uma janela para o usuário escolher
  /// uma avaliação pessoal entre 1 e 10.
  Future<void> _selectRating() async {
    final selectedRating = await showDialog<int>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Minha nota'),
          children: List.generate(
            10,
            (index) {
              final rating = index + 1;

              return SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, rating);
                },
                child: Text('$rating / 10'),
              );
            },
          ),
        );
      },
    );

    // Não altera a nota caso a janela seja fechada.
    if (!mounted ||
        selectedRating == null ||
        _userMovie == null) {
      return;
    }

    await _save(
      _userMovie!.copyWith(
        userRating: selectedRating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Informações principais da obra.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Poster(
                posterUrl: movie.poster,
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${movie.year} · ${_formatType(movie.type)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    if (_hasValue(movie.runtime)) ...[
                      const SizedBox(height: 6),
                      Text(movie.runtime),
                    ],

                    if (_hasValue(movie.imdbRating)) ...[
                      const SizedBox(height: 14),

                      Chip(
                        avatar: const Icon(
                          Icons.star,
                          size: 18,
                        ),
                        label: Text(
                          '${movie.imdbRating} IMDb',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Gêneros da obra.
          if (_hasValue(movie.genre)) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: movie.genre
                  .split(',')
                  .map(
                    (genre) => Chip(
                      label: Text(genre.trim()),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 28),
          ],

          // Sinopse.
          const _SectionTitle(
            title: 'Sinopse',
          ),

          const SizedBox(height: 10),

          Text(
            _hasValue(movie.plot)
                ? movie.plot
                : 'Sinopse não disponível.',
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
            ),
          ),

          const SizedBox(height: 30),

          // Informações detalhadas.
          const _SectionTitle(
            title: 'Informações',
          ),

          const SizedBox(height: 14),

          if (_hasValue(movie.director))
            _InfoRow(
              label: 'Diretor',
              value: movie.director,
            ),

          if (_hasValue(movie.writer))
            _InfoRow(
              label: 'Roteiro',
              value: movie.writer,
            ),

          if (_hasValue(movie.actors))
            _InfoRow(
              label: 'Elenco',
              value: movie.actors,
            ),

          if (_hasValue(movie.language))
            _InfoRow(
              label: 'Idioma',
              value: movie.language,
            ),

          if (_hasValue(movie.country))
            _InfoRow(
              label: 'País',
              value: movie.country,
            ),

          if (_hasValue(movie.released))
            _InfoRow(
              label: 'Lançamento',
              value: movie.released,
            ),

          if (_hasValue(movie.rated))
            _InfoRow(
              label: 'Classificação',
              value: movie.rated,
            ),

          if (movie.totalSeasons != null &&
              _hasValue(movie.totalSeasons!))
            _InfoRow(
              label: 'Temporadas',
              value: movie.totalSeasons!,
            ),

          // Prêmios e indicações.
          if (_hasValue(movie.awards)) ...[
            const SizedBox(height: 20),

            const _SectionTitle(
              title: 'Prêmios',
            ),

            const SizedBox(height: 10),

            Text(
              movie.awards,
              style: theme.textTheme.bodyLarge,
            ),
          ],

          // Avaliações fornecidas pela OMDb.
          if (movie.ratings.isNotEmpty) ...[
            const SizedBox(height: 30),

            const _SectionTitle(
              title: 'Avaliações · OMDb',
            ),

            const SizedBox(height: 14),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: movie.ratings
                  .map(
                    (rating) => _RatingCard(
                      rating: rating,
                    ),
                  )
                  .toList(),
            ),
          ],

          const SizedBox(height: 32),

          // Coleção pessoal do usuário.
          const _SectionTitle(
            title: 'Minha coleção',
          ),

          const SizedBox(height: 14),

          if (_loadingCollection)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_userMovie != null) ...[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [

                // Favoritos.
                FilterChip(
                  selected: _userMovie!.isFavorite,
                  avatar: Icon(
                    _userMovie!.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                  label: Text(
                    _userMovie!.isFavorite
                        ? 'Favoritado'
                        : 'Favoritar',
                  ),
                  onSelected: (_) {
                    _toggleFavorite();
                  },
                ),

                // Filmes assistidos.
                FilterChip(
                  selected: _userMovie!.isWatched,
                  avatar: Icon(
                    _userMovie!.isWatched
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                  ),
                  label: Text(
                    _userMovie!.isWatched
                        ? 'Já assisti'
                        : 'Marcar como assistido',
                  ),
                  onSelected: (_) {
                    _toggleWatched();
                  },
                ),

                // Lista de desejos.
                FilterChip(
                  selected: _userMovie!.isWishlist,
                  avatar: Icon(
                    _userMovie!.isWishlist
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                  ),
                  label: Text(
                    _userMovie!.isWishlist
                        ? 'Na lista de desejos'
                        : 'Lista de desejos',
                  ),
                  onSelected: (_) {
                    _toggleWishlist();
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Avaliação pessoal de 1 a 10.
            OutlinedButton.icon(
              onPressed: _selectRating,
              icon: const Icon(
                Icons.star_outline,
              ),
              label: Text(
                _userMovie!.userRating == null
                    ? 'Dar minha nota'
                    : 'Minha nota: ${_userMovie!.userRating}/10',
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Verifica se a informação da OMDb é válida.
  static bool _hasValue(String value) {
    return value.isNotEmpty && value != 'N/A';
  }

  /// Traduz o tipo de conteúdo para português.
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

/// Widget responsável por exibir o pôster da obra.
///
/// Caso a imagem não esteja disponível,
/// mostra um ícone substituto.
class _Poster extends StatelessWidget {
  final String posterUrl;

  const _Poster({
    required this.posterUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasPoster =
        posterUrl.isNotEmpty && posterUrl != 'N/A';

    if (!hasPoster) {
      return Container(
        width: 120,
        height: 175,
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.movie_outlined,
          size: 48,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        posterUrl,
        width: 120,
        height: 175,
        fit: BoxFit.cover,

        // Substitui a imagem caso ocorra erro no carregamento.
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 175,
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            child: const Icon(
              Icons.broken_image_outlined,
            ),
          );
        },
      ),
    );
  }
}

/// Widget reutilizável para os títulos das seções.
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Exibe uma informação e seu respectivo valor.
///
/// Exemplo: Diretor - Christopher Nolan.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

/// Cartão responsável por exibir uma avaliação da OMDb.
///
/// Cada avaliação possui uma fonte e um valor,
/// como IMDb, Rotten Tomatoes ou Metacritic.
class _RatingCard extends StatelessWidget {
  final Rating rating;

  const _RatingCard({
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rating.source,
            style: theme.textTheme.labelMedium,
          ),

          const SizedBox(height: 4),

          Text(
            rating.value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget exibido quando ocorre um erro na consulta
/// dos detalhes do filme.
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
            ),

            const SizedBox(height: 16),

            const Text(
              'Não foi possível carregar os detalhes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

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
