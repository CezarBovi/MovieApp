/// Representa um filme ou série retornado pela pesquisa da OMDb.
///
/// A pesquisa da OMDb retorna apenas informações básicas.
/// Os dados completos serão buscados posteriormente usando o IMDb ID.
class MovieSummary {
  /// Título do filme ou série.
  final String title;

  /// Ano de lançamento.
  final String year;

  /// Identificador único da obra no IMDb.
  final String imdbId;

  /// Tipo da obra, como "movie", "series" ou "episode".
  final String type;

  /// URL do pôster da obra.
  final String poster;

  MovieSummary({
    required this.title,
    required this.year,
    required this.imdbId,
    required this.type,
    required this.poster,
  });

  /// Cria um objeto [MovieSummary] a partir do JSON retornado pela OMDb.
  factory MovieSummary.fromJson(Map<String, dynamic> json) {
    return MovieSummary(
      title: json['Title'] ?? '',
      year: json['Year'] ?? '',
      imdbId: json['imdbID'] ?? '',
      type: json['Type'] ?? '',
      poster: json['Poster'] ?? '',
    );
  }
}