import 'episode_summary.dart';

/// Temporada de uma série com a lista de episódios retornada pela OMDb API.
class SeasonDetails {
  /// Título da série à qual a temporada pertence.
  final String title;

  /// Número da temporada em formato de texto (ex: "1", "2").
  final String seasonNumber;

  /// Lista com o resumo dos episódios pertencentes a esta temporada.
  final List<EpisodeSummary> episodes;

  /// Construtor que inicializa os detalhes da temporada e seus episódios.
  SeasonDetails({
    required this.title,
    required this.seasonNumber,
    required this.episodes,
  });

  /// Construtor de fábrica que processa a resposta JSON da OMDb API.
  /// Mapeia o array 'Episodes' para uma lista de instâncias de [EpisodeSummary].
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

  /// Retorna o número da temporada convertido para inteiro (ou 0 caso a conversão falhe).
  int get seasonAsInt => int.tryParse(seasonNumber) ?? 0;
}

