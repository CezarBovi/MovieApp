/// Exceção base lançada em operações do repositório da coleção.
class CollectionException implements Exception {
  /// Mensagem descritiva do erro.
  final String message;

  /// Código de erro da API (ex.: "VALIDACAO", "NAO_ENCONTRADO", "SERVIDOR").
  final String? code;

  /// Código de status HTTP retornado, se aplicável.
  final int? statusCode;

  const CollectionException(this.message, {this.code, this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'CollectionException ($statusCode, ${code ?? "SEM_CODIGO"}): $message';
    }
    return 'CollectionException: $message';
  }
}

/// Exceção de falha de conexão, rede ou timeout ao acessar a API.
class CollectionNetworkException extends CollectionException {
  const CollectionNetworkException(super.message, {super.code = 'REDE'});
}

/// Exceção para títulos não encontrados na coleção (HTTP 404).
class CollectionNotFoundException extends CollectionException {
  final String imdbId;

  const CollectionNotFoundException(this.imdbId, {String? message})
      : super(
          message ?? 'Título com IMDb ID "$imdbId" não encontrado na coleção.',
          code: 'NAO_ENCONTRADO',
          statusCode: 404,
        );
}

/// Exceção para erros de validação retornados pela API (HTTP 400).
class CollectionValidationException extends CollectionException {
  const CollectionValidationException(super.message, {super.code = 'VALIDACAO', super.statusCode = 400});
}
