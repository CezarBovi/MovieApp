import 'package:flutter/material.dart';

import '../models/movie_details.dart';
import '../models/rating.dart';
import '../models/user_movie.dart';
import '../services/collection_service.dart';
import '../services/omdb_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import 'details_screen.dart';

/// Detalhes de um episódio, com progresso ligado à série pai.
class EpisodeDetailsScreen extends StatefulWidget {
  final String episodeImdbId;
  final String seriesImdbId;
  final String seriesTitle;
  final String seriesPoster;
  final String seriesYear;
  final String seriesImdbRating;
  final int season;
  final int episodeNumber;

  const EpisodeDetailsScreen({
    super.key,
    required this.episodeImdbId,
    required this.seriesImdbId,
    required this.seriesTitle,
    required this.seriesPoster,
    required this.seriesYear,
    required this.seriesImdbRating,
    required this.season,
    required this.episodeNumber,
  });

  @override
  State<EpisodeDetailsScreen> createState() => _EpisodeDetailsScreenState();
}

class _EpisodeDetailsScreenState extends State<EpisodeDetailsScreen> {
  late Future<MovieDetails> _episodeFuture;
  UserMovie? _seriesMovie;
  bool _loadingCollection = true;

  @override
  void initState() {
    super.initState();
    _episodeFuture = OmdbService.getMovieDetails(widget.episodeImdbId);
    _loadSeriesCollection();
  }

  Future<void> _loadSeriesCollection() async {
    final saved = await CollectionService.getMovie(widget.seriesImdbId);

    if (!mounted) {
      return;
    }

    setState(() {
      _seriesMovie =
          saved ??
          UserMovie(
            imdbId: widget.seriesImdbId,
            title: widget.seriesTitle,
            year: widget.seriesYear,
            type: 'series',
            poster: widget.seriesPoster,
            imdbRating: widget.seriesImdbRating,
          );
      _loadingCollection = false;
    });
  }

  UserMovie _withSyncedProgress(UserMovie movie) {
    if (movie.watchedEpisodes.isEmpty) {
      return movie.copyWith(isWatched: false, clearLastWatched: true);
    }

    var bestSeason = 0;
    var bestEpisode = 0;

    for (final key in movie.watchedEpisodes) {
      final parts = key.split(':');
      if (parts.length != 2) {
        continue;
      }

      final season = int.tryParse(parts[0]) ?? 0;
      final episode = int.tryParse(parts[1]) ?? 0;

      if (season > bestSeason ||
          (season == bestSeason && episode > bestEpisode)) {
        bestSeason = season;
        bestEpisode = episode;
      }
    }

    return movie.copyWith(
      lastWatchedSeason: bestSeason,
      lastWatchedEpisode: bestEpisode,
      isWatched: false,
    );
  }

  Future<void> _toggleEpisodeWatched() async {
    final current = _seriesMovie;
    if (current == null) {
      return;
    }

    final key = UserMovie.episodeKey(widget.season, widget.episodeNumber);
    final watched = List<String>.from(current.watchedEpisodes);
    final marking = !current.isEpisodeWatched(
      widget.season,
      widget.episodeNumber,
    );

    if (marking) {
      watched.add(key);
    } else {
      watched.remove(key);
    }

    var updated = current.copyWith(
      watchedEpisodes: watched,
      isWishlist: marking ? false : current.isWishlist,
    );
    updated = _withSyncedProgress(updated);

    await CollectionService.saveMovie(updated);

    if (!mounted) {
      return;
    }

    setState(() {
      _seriesMovie = updated;
    });
  }

  void _openSeries() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => DetailsScreen(imdbId: widget.seriesImdbId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Episódio'),
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
        future: _episodeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _EpisodeErrorState(message: snapshot.error.toString());
          }

          final episode = snapshot.data;
          if (episode == null) {
            return const Center(
              child: Text('Nenhuma informação disponível.'),
            );
          }

          return _EpisodeDetailsBody(
            episode: episode,
            seriesTitle: widget.seriesTitle,
            season: widget.season,
            episodeNumber: widget.episodeNumber,
            seriesMovie: _seriesMovie,
            loadingCollection: _loadingCollection,
            onOpenSeries: _openSeries,
            onToggleWatched: _toggleEpisodeWatched,
          );
        },
      ),
    );
  }
}

class _EpisodeDetailsBody extends StatelessWidget {
  final MovieDetails episode;
  final String seriesTitle;
  final int season;
  final int episodeNumber;
  final UserMovie? seriesMovie;
  final bool loadingCollection;
  final VoidCallback onOpenSeries;
  final VoidCallback onToggleWatched;

  const _EpisodeDetailsBody({
    required this.episode,
    required this.seriesTitle,
    required this.season,
    required this.episodeNumber,
    required this.seriesMovie,
    required this.loadingCollection,
    required this.onOpenSeries,
    required this.onToggleWatched,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final watched = seriesMovie?.isEpisodeWatched(season, episodeNumber) ?? false;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _EpisodePoster(posterUrl: episode.poster),
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
                                'EPISÓDIO · T$season E$episodeNumber',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              episode.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              seriesTitle,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              [
                                if (_hasValue(episode.released)) episode.released,
                                if (_hasValue(episode.runtime)) episode.runtime,
                                if (_hasValue(episode.year)) episode.year,
                              ].join(' · '),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (_hasValue(episode.imdbRating)) ...[
                              const SizedBox(height: 14),
                              _ImdbBadge(rating: episode.imdbRating),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onOpenSeries,
                  icon: const Icon(Icons.tv_outlined),
                  label: Text('Ver série · $seriesTitle'),
                ),
              ),
              if (_hasValue(episode.genre)) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: episode.genre
                      .split(',')
                      .map((genre) => Chip(label: Text(genre.trim())))
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              const _SectionTitle(title: 'SINOPSE'),
              const SizedBox(height: 8),
              Text(
                _hasValue(episode.plot)
                    ? episode.plot
                    : 'Sinopse não disponível.',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _InfoCard(
                      children: [
                        if (_hasValue(episode.director))
                          _InfoRow(
                            label: 'Diretor',
                            value: episode.director,
                          ),
                        if (_hasValue(episode.writer))
                          _InfoRow(label: 'Roteiro', value: episode.writer),
                        if (_hasValue(episode.actors))
                          _InfoRow(label: 'Elenco', value: episode.actors),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      children: [
                        _InfoRow(
                          label: 'Temporada',
                          value: season.toString(),
                        ),
                        _InfoRow(
                          label: 'Episódio',
                          value: episodeNumber.toString(),
                        ),
                        if (_hasValue(episode.released))
                          _InfoRow(
                            label: 'Exibição',
                            value: episode.released,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (episode.ratings.isNotEmpty) ...[
                const SizedBox(height: 24),
                const _SectionTitle(title: 'AVALIAÇÕES · OMDb'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: episode.ratings
                      .map((rating) => _RatingChip(rating: rating))
                      .toList(),
                ),
              ],
              const SizedBox(height: 26),
              const _SectionTitle(title: 'MEU PROGRESSO'),
              const SizedBox(height: 10),
              if (loadingCollection)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(
                          watched
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color: watched
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            watched
                                ? 'Episódio assistido'
                                : 'Ainda não assisti este episódio',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        watched
                            ? FilledButton.tonal(
                                onPressed: onToggleWatched,
                                child: const Text('Desmarcar'),
                              )
                            : OutlinedButton(
                                onPressed: onToggleWatched,
                                child: const Text('Marcar'),
                              ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static bool _hasValue(String value) {
    return value.isNotEmpty && value != 'N/A';
  }
}

class _EpisodePoster extends StatelessWidget {
  final String posterUrl;

  const _EpisodePoster({required this.posterUrl});

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
        child: const Icon(Icons.play_circle_outline, size: 48),
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

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

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

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

class _RatingChip extends StatelessWidget {
  final Rating rating;

  const _RatingChip({required this.rating});

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

class _EpisodeErrorState extends StatelessWidget {
  final String message;

  const _EpisodeErrorState({required this.message});

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
              'Não foi possível carregar o episódio.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
