import 'package:flutter/material.dart';

import '../models/movie_summary.dart';
import '../services/omdb_service.dart';

/// Tela responsável por exibir os resultados de uma pesquisa.
///
/// Ao ser aberta, realiza uma consulta na OMDb utilizando
/// o texto recebido em [query].
class ResultsScreen extends StatefulWidget {
  /// Texto pesquisado pelo usuário.
  final String query;

  const ResultsScreen({
    super.key,
    required this.query,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  /// Future responsável pela pesquisa realizada na OMDb.
  late Future<List<MovieSummary>> _moviesFuture;

  @override
  void initState() {
    super.initState();

    _moviesFuture = OmdbService.searchMovies(widget.query);
  }

  /// Executa novamente a mesma pesquisa.
  void _retrySearch() {
    setState(() {
      _moviesFuture = OmdbService.searchMovies(widget.query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados da pesquisa'),
      ),
      body: FutureBuilder<List<MovieSummary>>(
        future: _moviesFuture,
        builder: (context, snapshot) {
          // Exibe carregamento enquanto espera a resposta da API.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Exibe uma mensagem caso ocorra algum erro.
          if (snapshot.hasError) {
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
                    Text(
                      'Não foi possível realizar a pesquisa.',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _retrySearch,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final movies = snapshot.data ?? [];

          // Estado exibido quando a OMDb não encontra resultados.
          if (movies.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.search_off,
                      size: 72,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum resultado encontrado',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Não encontramos filmes ou séries para '
                      '"${widget.query}".',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Tentar outra pesquisa'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  12,
                ),
                child: Text(
                  'Resultados para "${widget.query}"',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    4,
                    16,
                    24,
                  ),
                  itemCount: movies.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 12);
                  },
                  itemBuilder: (context, index) {
                    final movie = movies[index];

                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),

                        // A tela de detalhes será implementada
                        // na próxima etapa do projeto.
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Selecionado: ${movie.title}',
                              ),
                            ),
                          );
                        },

                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              _PosterImage(
                                posterUrl: movie.poster,
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie.title,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      movie.year,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Chip(
                                      label: Text(
                                        _formatType(movie.type),
                                      ),
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
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Converte o tipo enviado pela OMDb para português.
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
}

/// Widget responsável por exibir o pôster de um resultado.
///
/// Caso não exista uma imagem válida, exibe um ícone substituto.
class _PosterImage extends StatelessWidget {
  final String posterUrl;

  const _PosterImage({
    required this.posterUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasPoster =
        posterUrl.isNotEmpty && posterUrl != 'N/A';

    if (!hasPoster) {
      return Container(
        width: 75,
        height: 110,
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.movie_outlined,
          size: 36,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        posterUrl,
        width: 75,
        height: 110,
        fit: BoxFit.cover,

        // Exibe um ícone caso a imagem da internet falhe.
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 75,
            height: 110,
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