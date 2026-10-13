/// Episódio de uma temporada retornado pela OMDb.
class EpisodeSummary {
  final String title;
  final String episodeNumber;
  final String imdbId;
  final String released;
  final String imdbRating;

  EpisodeSummary({
    required this.title,
    required this.episodeNumber,
    required this.imdbId,
    required this.released,
    required this.imdbRating,
  });

  factory EpisodeSummary.fromJson(Map<String, dynamic> json) {
    return EpisodeSummary(
      title: json['Title'] ?? '',
      episodeNumber: json['Episode'] ?? '',
      imdbId: json['imdbID'] ?? '',
      released: json['Released'] ?? '',
      imdbRating: json['imdbRating'] ?? '',
    );
  }

  int get episodeAsInt => int.tryParse(episodeNumber) ?? 0;
}
