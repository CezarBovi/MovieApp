/// Representa o resumo de um episódio de série retornado pela OMDb API.
class EpisodeSummary {
  /// Título do episódio.
  final String title;

  /// Número do episódio em formato de texto (ex: "1", "12").
  final String episodeNumber;

  /// Identificador único IMDb do episódio específico.
  final String imdbId;

  /// Data de lançamento/exibição original do episódio.
  final String released;

  /// Nota de avaliação média do episódio no IMDb.
  final String imdbRating;

  /// Construtor que inicializa o resumo do episódio.
  EpisodeSummary({
    required this.title,
    required this.episodeNumber,
    required this.imdbId,
    required this.released,
    required this.imdbRating,
  });

  /// Construtor de fábrica que converte o JSON retornado pela consulta de episódios da OMDb.
  factory EpisodeSummary.fromJson(Map<String, dynamic> json) {
    return EpisodeSummary(
      title: json['Title'] ?? '',
      episodeNumber: json['Episode'] ?? '',
      imdbId: json['imdbID'] ?? '',
      released: json['Released'] ?? '',
      imdbRating: json['imdbRating'] ?? '',
    );
  }

  /// Retorna o número do episódio convertido para inteiro (ou 0 se falhar).
  int get episodeAsInt => int.tryParse(episodeNumber) ?? 0;
}

