import 'package:flutter/material.dart';

import '../models/episode_summary.dart';
import '../models/season_details.dart';
import '../models/user_movie.dart';
import '../screens/episode_details_screen.dart';
import '../services/omdb_service.dart';
import '../theme/app_theme.dart';

/// Lista temporadas e episódios de uma série para marcar o progresso.
class SeriesEpisodesPanel extends StatefulWidget {
  final String imdbId;
  final String seriesTitle;
  final String seriesPoster;
  final String seriesYear;
  final String seriesImdbRating;
  final int totalSeasons;
  final UserMovie userMovie;
  final Future<void> Function(UserMovie updated) onSave;
  final Future<void> Function()? onRefreshCollection;

  const SeriesEpisodesPanel({
    super.key,
    required this.imdbId,
    required this.seriesTitle,
    required this.seriesPoster,
    required this.seriesYear,
    required this.seriesImdbRating,
    required this.totalSeasons,
    required this.userMovie,
    required this.onSave,
    this.onRefreshCollection,
  });

  @override
  State<SeriesEpisodesPanel> createState() => _SeriesEpisodesPanelState();
}

class _SeriesEpisodesPanelState extends State<SeriesEpisodesPanel> {
  int _selectedSeason = 1;
  SeasonDetails? _seasonDetails;
  bool _loadingSeason = false;
  String? _seasonError;

  @override
  void initState() {
    super.initState();
    if (widget.userMovie.lastWatchedSeason != null) {
      _selectedSeason = widget.userMovie.lastWatchedSeason!.clamp(
        1,
        widget.totalSeasons,
      );
    }
    _loadSeason(_selectedSeason);
  }

  Future<void> _loadSeason(int season) async {
    setState(() {
      _loadingSeason = true;
      _seasonError = null;
      _seasonDetails = null;
    });

    try {
      final details = await OmdbService.getSeasonEpisodes(
        widget.imdbId,
        season,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _seasonDetails = details;
        _loadingSeason = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _seasonError = error.toString();
        _loadingSeason = false;
      });
    }
  }

  UserMovie _withSyncedProgress(UserMovie movie) {
    if (movie.watchedEpisodes.isEmpty) {
      return movie.copyWith(
        isWatched: false,
        clearLastWatched: true,
      );
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

  Future<void> _toggleEpisode(int season, int episode) async {
    final key = UserMovie.episodeKey(season, episode);
    final watched = List<String>.from(widget.userMovie.watchedEpisodes);
    final marking = !widget.userMovie.isEpisodeWatched(season, episode);

    if (marking) {
      watched.add(key);
    } else {
      watched.remove(key);
    }

    var updated = widget.userMovie.copyWith(
      watchedEpisodes: watched,
      isWishlist: marking ? false : widget.userMovie.isWishlist,
    );

    updated = _withSyncedProgress(updated);

    await widget.onSave(updated);
  }

  Future<void> _openEpisodeDetails(
    EpisodeSummary episode,
    int episodeNumber,
  ) async {
    if (episode.imdbId.isEmpty) {
      return;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) {
          return EpisodeDetailsScreen(
            episodeImdbId: episode.imdbId,
            seriesImdbId: widget.imdbId,
            seriesTitle: widget.seriesTitle,
            seriesPoster: widget.seriesPoster,
            seriesYear: widget.seriesYear,
            seriesImdbRating: widget.seriesImdbRating,
            season: _selectedSeason,
            episodeNumber: episodeNumber,
          );
        },
      ),
    );

    await widget.onRefreshCollection?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final continueLabel = widget.userMovie.continueWatchingLabel;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Episódios',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Toque em um episódio para ver a sinopse. '
              'Marque o que você já assistiu para saber onde parou.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            if (continueLabel != null) ...[
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Continuar de onde parou',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            continueLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            DropdownButtonFormField<int>(
              initialValue: _selectedSeason,
              decoration: const InputDecoration(
                labelText: 'Temporada',
              ),
              items: List.generate(widget.totalSeasons, (index) {
                final season = index + 1;
                return DropdownMenuItem(
                  value: season,
                  child: Text('Temporada $season'),
                );
              }),
              onChanged: (season) {
                if (season == null) {
                  return;
                }

                setState(() {
                  _selectedSeason = season;
                });

                _loadSeason(season);
              },
            ),

            const SizedBox(height: 12),

            if (_loadingSeason)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_seasonError != null)
              Text(
                'Não foi possível carregar os episódios.',
                style: TextStyle(color: theme.colorScheme.error),
              )
            else if (_seasonDetails != null)
              ..._seasonDetails!.episodes.map((episode) {
                final episodeNumber = episode.episodeAsInt;
                final watched = widget.userMovie.isEpisodeWatched(
                  _selectedSeason,
                  episodeNumber,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        _openEpisodeDetails(episode, episodeNumber);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: watched,
                              onChanged: (_) {
                                _toggleEpisode(
                                  _selectedSeason,
                                  episodeNumber,
                                );
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'E$episodeNumber · ${episode.title}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (episode.imdbRating.isNotEmpty &&
                                      episode.imdbRating != 'N/A') ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '${episode.imdbRating} IMDb',
                                      style: const TextStyle(
                                        color: AppTheme.ratingYellow,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(
                                    'Ver detalhes',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

            if (widget.userMovie.watchedEpisodes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${widget.userMovie.watchedEpisodes.length} '
                '${widget.userMovie.watchedEpisodes.length == 1 ? 'episódio' : 'episódios'} assistidos',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
