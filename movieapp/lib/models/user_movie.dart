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
  });

  /// Cria uma cópia do objeto alterando apenas os campos desejados.
  UserMovie copyWith({
    bool? isFavorite,
    bool? isWatched,
    bool? isWishlist,
    int? userRating,
    bool removeRating = false,
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
    );
  }
}