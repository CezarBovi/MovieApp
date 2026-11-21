import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/user_movie.dart';
import 'collection_repository_exception.dart';

/// Repositório responsável pela comunicação HTTP com a API da coleção pessoal.
///
/// Realiza operações de leitura, criação, atualização e remoção (CRUD)
/// consumindo os endpoints da API REST Flask (porta 5000).
class CollectionRepository {
  final http.Client _client;
  final String? customBaseUrl;

  /// Permite injetar um [http.Client] customizado (ideal para testes unitários com MockClient)
  /// e opcionalmente uma URL base diferente da configurada em [ApiConfig].
  CollectionRepository({
    http.Client? client,
    this.customBaseUrl,
  })  : _client = client ?? http.Client();

  /// Resolve a URI de integridade (`GET /health`).
  Uri get _healthUri {
    if (customBaseUrl != null) {
      return Uri.parse('$customBaseUrl/health');
    }
    return ApiConfig.healthUri;
  }

  /// Resolve a URI da coleção (`GET /colecao`).
  Uri get _collectionUri {
    if (customBaseUrl != null) {
      return Uri.parse('$customBaseUrl/colecao');
    }
    return ApiConfig.collectionUri;
  }

  /// Resolve a URI de um título específico (`/colecao/<imdbId>`).
  Uri _movieUri(String imdbId) {
    if (customBaseUrl != null) {
      return Uri.parse('$customBaseUrl/colecao/$imdbId');
    }
    return ApiConfig.movieUri(imdbId);
  }

  /// Executa uma chamada tratando exceções comuns de rede.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on CollectionException {
      rethrow;
    } on http.ClientException catch (e) {
      throw CollectionNetworkException(
        'Erro de comunicação com o servidor da coleção: ${e.message}',
      );
    } on TimeoutException {
      throw const CollectionNetworkException(
        'Tempo limite excedido ao se comunicar com a API da coleção.',
      );
    } catch (e) {
      if (e is Exception && e.runtimeType.toString() == 'SocketException') {
        throw CollectionNetworkException(
          'Não foi possível conectar ao servidor da coleção: $e',
        );
      }
      throw CollectionException('Erro inesperado na coleção: $e');
    }
  }

  /// Extrai a mensagem e o código de erro a partir da resposta HTTP JSON.
  CollectionException _parseError(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        final message = decoded['erro']?.toString() ?? 'Erro desconhecido na API.';
        final code = decoded['codigo']?.toString();

        if (response.statusCode == 404) {
          return CollectionNotFoundException('', message: message);
        }
        if (response.statusCode == 400) {
          return CollectionValidationException(message, code: code);
        }
        return CollectionException(
          message,
          code: code,
          statusCode: response.statusCode,
        );
      }
    } catch (_) {
      // Ignora falhas de parse do corpo de erro
    }

    return CollectionException(
      'Falha na API da coleção (HTTP ${response.statusCode}).',
      statusCode: response.statusCode,
    );
  }

  /// Verifica se o serviço da coleção está online (`GET /health`).
  ///
  /// Retorna `true` se a API responder com status 200 e status "ok".
  /// Retorna `false` em caso de erro de conexão, status diferente ou timeout.
  Future<bool> checkHealth({Duration timeout = const Duration(seconds: 4)}) async {
    try {
      final response = await _client.get(_healthUri).timeout(timeout);
      if (response.statusCode != 200) {
        return false;
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return decoded is Map<String, dynamic> && decoded['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  /// Retorna todos os títulos salvos na coleção do usuário (`GET /colecao`).
  Future<List<UserMovie>> getAll() async {
    return _guard(() async {
      final response = await _client.get(_collectionUri);

      if (response.statusCode != 200) {
        throw _parseError(response);
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! List) {
        throw const CollectionException(
          'Formato inesperado retornado pela API da coleção (esperado array).',
        );
      }

      return decoded
          .map((item) => UserMovie.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  /// Busca um título específico na coleção pelo seu IMDb ID (`GET /colecao/<imdbId>`).
  ///
  /// Retorna [UserMovie] se encontrado.
  /// Retorna `null` caso o item não esteja na coleção (HTTP 404),
  /// espelhando o comportamento esperado da aplicação.
  Future<UserMovie?> getById(String imdbId) async {
    return _guard(() async {
      final response = await _client.get(_movieUri(imdbId));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        return UserMovie.fromJson(decoded as Map<String, dynamic>);
      }

      if (response.statusCode == 404) {
        return null;
      }

      throw _parseError(response);
    });
  }

  /// Salva ou atualiza um título na coleção (`PUT /colecao/<imdbId>`).
  ///
  /// Aplica a regra de negócio onde obras assistidas saem da lista de desejos.
  /// Caso o registro esteja totalmente vazio (sem favoritos, assistidos, nota ou episódios),
  /// a API remove o item e este método retorna `null`.
  /// Caso contrário, retorna o [UserMovie] persistido.
  Future<UserMovie?> saveMovie(UserMovie movie) async {
    return _guard(() async {
      // Regra de negócio: se for marcado como assistido, sai da wishlist
      final movieToSave = movie.isWatched && movie.isWishlist
          ? movie.copyWith(isWishlist: false)
          : movie;

      final body = jsonEncode(movieToSave.toJson());
      final response = await _client.put(
        _movieUri(movieToSave.imdbId),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic> && decoded['removido'] == true) {
          return null;
        }
        return UserMovie.fromJson(decoded as Map<String, dynamic>);
      }

      throw _parseError(response);
    });
  }

  /// Remove explicitamente um título da coleção (`DELETE /colecao/<imdbId>`).
  ///
  /// Retorna `true` se o título foi removido com sucesso (HTTP 200).
  /// Retorna `false` se o título não existia na coleção (HTTP 404).
  /// Lança [CollectionException] para outros códigos de erro.
  Future<bool> deleteMovie(String imdbId) async {
    return _guard(() async {
      final response = await _client.delete(_movieUri(imdbId));

      if (response.statusCode == 200) {
        return true;
      }

      if (response.statusCode == 404) {
        return false;
      }

      throw _parseError(response);
    });
  }

  /// Retorna apenas os títulos marcados como favoritos.
  Future<List<UserMovie>> getFavorites() async {
    final all = await getAll();
    return all.where((movie) => movie.isFavorite).toList();
  }

  /// Retorna apenas os títulos marcados como assistidos ou séries com episódios assistidos.
  Future<List<UserMovie>> getWatched() async {
    final all = await getAll();
    return all
        .where((movie) => movie.isWatched || movie.hasEpisodeProgress)
        .toList();
  }

  /// Retorna apenas os títulos na lista de desejos.
  Future<List<UserMovie>> getWishlist() async {
    final all = await getAll();
    return all.where((movie) => movie.isWishlist).toList();
  }
}
