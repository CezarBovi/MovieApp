/// Representa os dados pessoais que o usuário associa a um filme.
///
/// Essas informações não vêm da OMDb. Elas são armazenadas
/// localmente no aplicativo e associadas ao IMDb ID da obra.
class UserMovie {
  /// Identificador exclusivo da obra no IMDb.
  final String imdbId;

  /// Título do filme ou série.
  final String title;

  /// Ano de lançamento da obra.
  final String year;

  /// Tipo da produção ("movie", "series", etc.).
  final String type;

  /// URL da imagem do pôster para exibição nas listas locais.
  final String poster;

  /// Nota pública registrada no IMDb.
  final String imdbRating;

  /// Indica se a obra foi favoritada pelo usuário.
  final bool isFavorite;

  /// Indica se o filme foi marcado como totalmente assistido.
  final bool isWatched;

  /// Indica se o item está na lista de desejos ("Quero assistir").
  final bool isWishlist;

  /// Nota pessoal do usuário, variando de 1 a 10.
  final int? userRating;

  /// Episódios já assistidos (formato `temporada:episódio`, ex.: `2:5`).
  final List<String> watchedEpisodes;

  /// Último ponto assistido em uma série, para retomar de onde parou.
  final int? lastWatchedSeason;
  final int? lastWatchedEpisode;

  /// Construtor que inicializa todos os dados do filme do usuário.
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

  /// Verifica se o item é uma série de TV.
  bool get isSeries => type == 'series';

  /// Informa se existe progresso registrado (ao menos um episódio assistido).
  bool get hasEpisodeProgress => watchedEpisodes.isNotEmpty;

  /// Gera a chave única de identificação de um episódio no formato "temporada:episodio".
  static String episodeKey(int season, int episode) => '$season:$episode';

  /// Verifica se um determinado episódio de uma temporada específica já foi marcado como assistido.
  bool isEpisodeWatched(int season, int episode) {
    return watchedEpisodes.contains(episodeKey(season, episode));
  }

  /// Retorna o texto formatado para retomar a série ("Temporada X · Episódio Y") ou null se não houver registro.
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