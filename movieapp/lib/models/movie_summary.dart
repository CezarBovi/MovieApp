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

  /// Construtor que inicializa o resumo simplificado da obra pesquisada.
  MovieSummary({
    required this.title,
    required this.year,
    required this.imdbId,
    required this.type,
    required this.poster,
  });

  /// Construtor de fábrica que converte o JSON retornado pela lista de busca da OMDb API.
  /// Mapeia os campos da API ('Title', 'Year', 'imdbID', 'Type', 'Poster') para as propriedades da classe.
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