/// Representa uma avaliação recebida da OMDb.
///
/// Cada avaliação possui uma fonte e um valor.
/// Exemplo:
/// Source: "Internet Movie Database"
/// Value: "9.0/10"
class Rating {
  /// Nome da fonte da avaliação.
  final String source;

  /// Valor da avaliação.
  final String value;

  /// Cria uma instância da avaliação com a fonte e o valor.
  Rating({
    required this.source,
    required this.value,
  });

  /// Construtor de fábrica que cria um objeto [Rating] a partir do mapa JSON retornado pela OMDb API.
  /// Trata valores ausentes atribuindo uma string vazia como fallback.
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      source: json['Source'] ?? '',
      value: json['Value'] ?? '',
    );
  }
}