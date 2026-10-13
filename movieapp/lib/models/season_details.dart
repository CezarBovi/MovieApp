import 'episode_summary.dart';

/// Temporada de uma série com a lista de episódios.
class SeasonDetails {
  final String title;
  final String seasonNumber;
  final List<EpisodeSummary> episodes;

  SeasonDetails({
    required this.title,
    required this.seasonNumber,
    required this.episodes,
  });

  factory SeasonDetails.fromJson(Map<String, dynamic> json) {
    final List<dynamic> episodesJson =
        json['Episodes'] is List ? json['Episodes'] : [];

    return SeasonDetails(
      title: json['Title'] ?? '',
      seasonNumber: json['Season'] ?? '',
      episodes: episodesJson
          .map(
            (item) => EpisodeSummary.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  int get seasonAsInt => int.tryParse(seasonNumber) ?? 0;
}
