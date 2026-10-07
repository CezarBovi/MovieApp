import 'package:flutter/material.dart';

import '../models/movie_summary.dart';
import '../services/omdb_service.dart';
import '../widgets/app_header.dart';
import 'details_screen.dart';

/// Tela responsável por exibir os resultados de uma pesquisa.
///
/// Ao ser aberta, consulta a OMDb utilizando o texto recebido
/// em [query] e apresenta os filmes e séries encontrados.
class ResultsScreen extends StatefulWidget {
  /// Texto pesquisado pelo usuário.
  final String query;

  const ResultsScreen({super.key, required this.query});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  /// Requisição responsável por buscar os resultados na OMDb.
  late Future<List<MovieSummary>> _moviesFuture;
  late final TextEditingController _searchController;
  late String _query;

  @override
  void initState() {
    super.initState();
    _query = widget.query;
    _searchController = TextEditingController(text: _query);
    _loadMovies();
  }

  /// Realiza a pesquisa utilizando o serviço da OMDb.
  void _loadMovies() {
    _moviesFuture = OmdbService.searchMovies(_query);
  }

  /// Atualiza a pesquisa sem sair da tela de resultados.
  void _searchAgain(String query) {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _query = trimmedQuery;
      _searchController.text = trimmedQuery;
      _loadMovies();
    });
  }

  /// Tenta realizar novamente a pesquisa em caso de erro.
  void _retrySearch() {
    setState(() {
      _loadMovies();
    });
  }

  /// Abre a tela de detalhes da obra selecionada.
  void _openDetails(MovieSummary movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return DetailsScreen(imdbId: movie.imdbId);
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<MovieSummary>>(
          future: _moviesFuture,
          builder: (context, snapshot) {
            // Estado de carregamento.
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Estado de erro.
            if (snapshot.hasError) {
              return _ErrorState(
                message: snapshot.error.toString(),
                onRetry: _retrySearch,
              );
            }

            final movies = snapshot.data ?? [];

            // Estado sem resultados.
            if (movies.isEmpty) {
              return _EmptyResults(query: _query);
            }

            return _ResultsContent(
              query: _query,
              searchController: _searchController,
              onSearchSubmitted: _searchAgain,
              movies: movies,
              onMovieSelected: _openDetails,
            );
          },
        ),
      ),
    );
  }
}

/// Conteúdo apresentado quando existem resultados.
class _ResultsContent extends StatelessWidget {
  final String query;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchSubmitted;
  final List<MovieSummary> movies;
  final void Function(MovieSummary movie) onMovieSelected;

  const _ResultsContent({
    required this.query,
    required this.searchController,
    required this.onSearchSubmitted,
    required this.movies,
    required this.onMovieSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          children: [
            // Cabeçalho fixo.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Voltar',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),

                  const SizedBox(width: 8),

                  const Expanded(
                    child: AppHeader(subtitle: 'Resultados da pesquisa'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                children: [
                  // Mostra a pesquisa realizada.
                  TextField(
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: onSearchSubmitted,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        tooltip: 'Pesquisar',
                        onPressed: () {
                          onSearchSubmitted(searchController.text);
                        },
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Título e quantidade de resultados.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Resultados para “$query”',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${movies.length} resultados',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Cards dos resultados.
                  ...movies.map(
                    (movie) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MovieResultCard(
                        movie: movie,
                        onTap: () {
                          onMovieSelected(movie);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card utilizado para representar um resultado da OMDb.
class _MovieResultCard extends StatelessWidget {
  final MovieSummary movie;
  final VoidCallback onTap;

  const _MovieResultCard({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _PosterImage(posterUrl: movie.poster),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Text(
                          movie.year,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurfaceVariant,
                            shape: BoxShape.circle,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          _formatType(movie.type),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Ver detalhes',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Exibe o pôster de uma obra.
///
/// Caso não exista uma imagem válida, um ícone substituto
/// é apresentado.
class _PosterImage extends StatelessWidget {
  final String posterUrl;

  const _PosterImage({required this.posterUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasPoster = posterUrl.isNotEmpty && posterUrl != 'N/A';

    if (!hasPoster) {
      return Container(
        width: 82,
        height: 112,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.movie_outlined, size: 38),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        posterUrl,
        width: 82,
        height: 112,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 82,
            height: 112,
            color: theme.colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.broken_image_outlined),
          );
        },
      ),
    );
  }
}

/// Tela apresentada quando uma pesquisa não encontra resultados.
class _EmptyResults extends StatelessWidget {
  final String query;

  const _EmptyResults({required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),

                  const SizedBox(width: 8),

                  const Expanded(
                    child: AppHeader(subtitle: 'Resultados da pesquisa'),
                  ),
                ],
              ),

              const Spacer(),

              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off,
                  size: 48,
                  color: theme.colorScheme.secondary,
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Nenhum resultado\nencontrado',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'Não encontramos filmes ou séries que '
                'combinem com “$query”. Verifique o título '
                'ou tente algo mais amplo.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar outra pesquisa'),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Estado apresentado quando ocorre um erro durante a pesquisa.
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

            const SizedBox(height: 18),

            Text(
              'Não foi possível realizar a pesquisa.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

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

/// Traduz o tipo retornado pela OMDb para português.
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
