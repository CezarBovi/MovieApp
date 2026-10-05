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

  Rating({
    required this.source,
    required this.value,
  });

  /// Cria um objeto [Rating] a partir do JSON retornado pela OMDb.
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      source: json['Source'] ?? '',
      value: json['Value'] ?? '',
    );
  }
}