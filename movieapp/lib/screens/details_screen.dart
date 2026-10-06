import 'package:flutter/material.dart';

import '../models/movie_details.dart';
import '../models/rating.dart';
import '../services/omdb_service.dart';

/// Tela responsável por exibir todas as informações de uma obra.
///
/// Os dados são carregados da OMDb utilizando o IMDb ID selecionado
/// na tela de resultados.
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
  /// Requisição utilizada para carregar os detalhes da obra.
  late Future<MovieDetails> _movieFuture;

  @override
  void initState() {
    super.initState();

    _movieFuture = OmdbService.getMovieDetails(widget.imdbId);
  }

  /// Tenta carregar novamente os dados caso ocorra um erro.
  void _retry() {
    setState(() {
      _movieFuture = OmdbService.getMovieDetails(widget.imdbId);
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

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
class _MovieDetailsContent extends StatelessWidget {
  final MovieDetails movie;

  const _MovieDetailsContent({
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informações principais do filme.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Poster(posterUrl: movie.poster),

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

          _SectionTitle(title: 'Sinopse'),

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

          _SectionTitle(title: 'Informações'),

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

          if (_hasValue(movie.awards)) ...[
            const SizedBox(height: 20),

            _SectionTitle(title: 'Prêmios'),

            const SizedBox(height: 10),

            Text(
              movie.awards,
              style: theme.textTheme.bodyLarge,
            ),
          ],

          if (movie.ratings.isNotEmpty) ...[
            const SizedBox(height: 30),

            _SectionTitle(title: 'Avaliações · OMDb'),

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

          // Este espaço já prepara a tela para as funcionalidades
          // pessoais que serão implementadas posteriormente.
          _SectionTitle(title: 'Minha coleção'),

          const SizedBox(height: 12),

          Text(
            'Favoritos, filmes assistidos, lista de desejos e '
            'nota pessoal serão adicionados na próxima etapa.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Verifica se uma informação recebida da OMDb pode ser exibida.
  static bool _hasValue(String value) {
    return value.isNotEmpty && value != 'N/A';
  }

  /// Traduz o tipo retornado pela OMDb.
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

/// Exibe o pôster da obra ou uma imagem substituta.
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

/// Título utilizado para separar as seções da tela.
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

/// Linha utilizada para apresentar uma informação e seu valor.
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

/// Cartão utilizado para mostrar uma avaliação da OMDb.
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

/// Estado apresentado caso a requisição de detalhes falhe.
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