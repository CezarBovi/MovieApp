import 'package:flutter/material.dart';

import '../models/user_movie.dart';
import '../services/collection_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import 'details_screen.dart';

/// Exibe todos os filmes marcados como assistidos.
///
/// Também apresenta a nota IMDb e a avaliação
/// pessoal atribuída pelo usuário.
class WatchedScreen extends StatefulWidget {
  const WatchedScreen({super.key});

  @override
  State<WatchedScreen> createState() =>
      _WatchedScreenState();
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

  /// Atualiza os dados exibidos.
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
        watchedEpisodes: const [],
        clearLastWatched: true,
        removeRating: true,
      ),
    );

    _refresh();
  }

  /// Abre a tela de detalhes.
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

          return _WatchedContent(
            movies: movies,
            onOpenDetails: _openDetails,
            onRemove: _removeWatched,
          );
        },
      ),
    );
  }
}

/// Conteúdo exibido quando existem filmes ou séries assistidos na lista.
class _WatchedContent extends StatelessWidget {
  /// Lista dos filmes/séries assistidos pelo usuário.
  final List<UserMovie> movies;
  /// Callback para navegação para a tela de detalhes.
  final Future<void> Function(UserMovie) onOpenDetails;
  /// Callback para desmarcar o filme/série como assistido.
  final Future<void> Function(UserMovie) onRemove;

  const _WatchedContent({
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
            // Cabeçalho da aplicação
            const AppHeader(
              subtitle: 'MINHAS LISTAS',
            ),

            const SizedBox(height: 34),

            // Título da seção e badge com a quantidade de obras
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Já assistidos',
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

            // Texto descritivo auxiliar
            Text(
              'Seu histórico de cinema, com a sua opinião '
              'em notas de 1 a 10.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            // Lista de cartões para cada obra assistida
            ...movies.map(
              (movie) => Padding(
                padding:
                    const EdgeInsets.only(bottom: 14),
                child: _WatchedCard(
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

            const SizedBox(height: 6),

            // Nota informativa sobre as avaliações
            Row(
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
                    'A nota IMDb vem da OMDb. Minha nota '
                    'é a avaliação que você deu ao filme.',
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

/// Card que exibe os dados de uma obra assistida (pôster, título, progresso de episódios e notas).
class _WatchedCard extends StatelessWidget {
  /// Dados pessoais da obra salvos localmente.
  final UserMovie movie;
  /// Callback ao clicar no card para abrir detalhes.
  final VoidCallback onTap;
  /// Callback para remover o status de assistido.
  final VoidCallback onRemove;

  const _WatchedCard({
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
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              movie.isSeries
                                  ? Icons.playlist_play
                                  : Icons.check_circle_outline,
                              size: 17,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 5),
                            // O widget Expanded abaixo soluciona o erro "right overflowed by 14 pixels",
                            // garantindo que o texto descritivo do progresso da série ("X ep. · Temporada Y · Episódio Z")
                            // respeite a largura disponível na tela do celular sem estourar o layout.
                            Expanded(
                              child: Text(
                                _watchedStatus(movie),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Linha com caixas comparativas da Nota IMDb vs Minha Nota
            Row(
              children: [
                Expanded(
                  child: _RatingBox(
                    title: 'Nota IMDb · OMDb',
                    value:
                        _displayRating(movie.imdbRating),
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
                    color:
                        theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Botão para desmarcar o filme ou série como assistido
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.remove_circle_outline,
                ),
                label: const Text(
                  'Desmarcar assistido',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget apresentado quando ainda não há filmes ou séries marcados como assistidos.
class _EmptyWatched extends StatelessWidget {
  const _EmptyWatched();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone grande indicando lista vazia
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 18),
            Text(
              'Nenhum filme assistido',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Marque um filme como assistido '
              'na tela de detalhes.',
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

/// Badge que exibe o contador de itens assistidos com pluralização correta.
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
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Caixa retangular estilizada para exibir títulos e valores de notas de avaliação.
class _RatingBox extends StatelessWidget {
  /// Rótulo superior (ex: "Nota IMDb", "Minha nota").
  final String title;
  /// Valor formatado da avaliação (ex: "8.5/10", "Ainda sem nota").
  final String value;
  /// Cor temática do texto da nota.
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
          Text(
            title,
            style: theme.textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Componente para renderização do pôster com suporte a imagem de rede e fallback para ícone.
class _Poster extends StatelessWidget {
  final String poster;

  const _Poster({
    required this.poster,
  });

  @override
  Widget build(BuildContext context) {
    // Se não houver pôster cadastrado ou o valor for "N/A", exibe um placeholder com ícone
    if (poster.isEmpty || poster == 'N/A') {
      return const SizedBox(
        width: 84,
        height: 116,
        child: Icon(
          Icons.movie_outlined,
          size: 40,
        ),
      );
    }

    // Exibe a imagem remota com cantos arredondados
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

/// Converte o tipo da obra em inglês ("movie", "series", "episode") para o texto em português.
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

/// Trata e formata a exibição da nota, retornando 'Sem nota' quando ausente ou "N/A".
String _displayRating(String rating) {
  return rating.isEmpty || rating == 'N/A'
      ? 'Sem nota'
      : rating;
}

/// Monta a legenda do status assistido:
/// - Para séries: inclui o total de episódios e o ponto de retomada (ex: "5 ep. · Temporada 1 · Episódio 5").
/// - Para filmes: exibe "Assistido".
String _watchedStatus(UserMovie movie) {
  if (movie.isSeries) {
    if (movie.continueWatchingLabel != null) {
      return '${movie.watchedEpisodes.length} ep. · ${movie.continueWatchingLabel}';
    }

    return '${movie.watchedEpisodes.length} episódios assistidos';
  }

  return 'Assistido';
}