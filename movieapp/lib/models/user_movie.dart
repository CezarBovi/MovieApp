/// Representa os dados pessoais que o usuário associa a um filme.
///
/// Essas informações não vêm da OMDb. Elas são armazenadas
/// localmente no aplicativo e associadas ao IMDb ID da obra.
class UserMovie {
  final String imdbId;
  final String title;
  final String year;
  final String type;
  final String poster;
  final String imdbRating;

  final bool isFavorite;
  final bool isWatched;
  final bool isWishlist;

  /// Nota pessoal do usuário, variando de 1 a 10.
  final int? userRating;

  /// Episódios já assistidos (formato `temporada:episódio`, ex.: `2:5`).
  final List<String> watchedEpisodes;

  /// Último ponto assistido em uma série, para retomar de onde parou.
  final int? lastWatchedSeason;
  final int? lastWatchedEpisode;

  UserMovie({
    required this.imdbId,
    required this.title,
    required this.year,
    required this.type,
    required this.poster,
    required this.imdbRating,
    this.isFavorite = false,
    this.isWatched = false,
    this.isWishlist = false,
    this.userRating,
    this.watchedEpisodes = const [],
    this.lastWatchedSeason,
    this.lastWatchedEpisode,
  });

  bool get isSeries => type == 'series';

  bool get hasEpisodeProgress => watchedEpisodes.isNotEmpty;

  static String episodeKey(int season, int episode) => '$season:$episode';

  bool isEpisodeWatched(int season, int episode) {
    return watchedEpisodes.contains(episodeKey(season, episode));
  }

  String? get continueWatchingLabel {
    if (lastWatchedSeason == null || lastWatchedEpisode == null) {
      return null;
    }

    return 'Temporada $lastWatchedSeason · Episódio $lastWatchedEpisode';
  }

  /// Cria uma cópia do objeto alterando apenas os campos desejados.
  UserMovie copyWith({
    bool? isFavorite,
    bool? isWatched,
    bool? isWishlist,
    int? userRating,
    bool removeRating = false,
    List<String>? watchedEpisodes,
    int? lastWatchedSeason,
    int? lastWatchedEpisode,
    bool clearLastWatched = false,
  }) {
    return UserMovie(
      imdbId: imdbId,
      title: title,
      year: year,
      type: type,
      poster: poster,
      imdbRating: imdbRating,
      isFavorite: isFavorite ?? this.isFavorite,
      isWatched: isWatched ?? this.isWatched,
      isWishlist: isWishlist ?? this.isWishlist,
      userRating: removeRating
          ? null
          : userRating ?? this.userRating,
      watchedEpisodes: watchedEpisodes ?? this.watchedEpisodes,
      lastWatchedSeason: clearLastWatched
          ? null
          : lastWatchedSeason ?? this.lastWatchedSeason,
      lastWatchedEpisode: clearLastWatched
          ? null
          : lastWatchedEpisode ?? this.lastWatchedEpisode,
    );
  }

  /// Converte o objeto para JSON para permitir o armazenamento local.
  Map<String, dynamic> toJson() {
    return {
      'imdbId': imdbId,
      'title': title,
      'year': year,
      'type': type,
      'poster': poster,
      'imdbRating': imdbRating,
      'isFavorite': isFavorite,
      'isWatched': isWatched,
      'isWishlist': isWishlist,
      'userRating': userRating,
      'watchedEpisodes': watchedEpisodes,
      'lastWatchedSeason': lastWatchedSeason,
      'lastWatchedEpisode': lastWatchedEpisode,
    };
  }

  /// Cria um objeto a partir dos dados salvos localmente.
  factory UserMovie.fromJson(Map<String, dynamic> json) {
    return UserMovie(
      imdbId: json['imdbId'] ?? '',
      title: json['title'] ?? '',
      year: json['year'] ?? '',
      type: json['type'] ?? '',
      poster: json['poster'] ?? '',
      imdbRating: json['imdbRating'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      isWatched: json['isWatched'] ?? false,
      isWishlist: json['isWishlist'] ?? false,
      userRating: json['userRating'],
      watchedEpisodes: (json['watchedEpisodes'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      lastWatchedSeason: json['lastWatchedSeason'],
      lastWatchedEpisode: json['lastWatchedEpisode'],
    );
  }
}