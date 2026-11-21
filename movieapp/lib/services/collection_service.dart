import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_movie.dart';
import '../repositories/collection_repository.dart';
import '../repositories/collection_repository_exception.dart';

/// Serviço responsável pelo gerenciamento da coleção pessoal do usuário.
///
/// Integra a API REST Flask (via [CollectionRepository]) como fonte da verdade oficial
/// e mantém o SharedPreferences local como cache resiliente e mecanismo de fallback.
class CollectionService {
  /// Chave utilizada para salvar a lista de filmes no armazenamento local (cache).
  static const String _storageKey = 'movie_collection';

  /// Chave que indica se os dados locais pré-integração já foram migrados para a API.
  static const String _migrationKey = 'collection_migrated_v1';

  static CollectionRepository _repository = CollectionRepository();

  /// Permite injetar um repositório customizado (para testes unitários ou integração).
  static void setRepository(CollectionRepository repository) {
    _repository = repository;
  }

  /// Restaura o repositório padrão.
  static void resetRepository() {
    _repository = CollectionRepository();
  }

  /// Retorna os filmes armazenados localmente no cache do SharedPreferences.
  static Future<List<UserMovie>> getLocalCache() async {
    final preferences = await SharedPreferences.getInstance();
    final storedData = preferences.getString(_storageKey);

    if (storedData == null || storedData.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(storedData);
      return decoded
          .map((item) => UserMovie.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Grava a lista de filmes no cache local do SharedPreferences.
  static Future<void> saveLocalCache(List<UserMovie> movies) async {
    final preferences = await SharedPreferences.getInstance();
    final filtered = movies.where((m) => m.isNotEmpty).toList();
    final encoded = jsonEncode(filtered.map((m) => m.toJson()).toList());
    await preferences.setString(_storageKey, encoded);
  }

  /// Atualiza ou remove um filme no cache local.
  static Future<void> _updateLocalItem(UserMovie movie) async {
    final movies = await getLocalCache();
    final movieToSave = movie.isWatched && movie.isWishlist
        ? movie.copyWith(isWishlist: false)
        : movie;

    final index = movies.indexWhere((item) => item.imdbId == movieToSave.imdbId);
    if (index == -1) {
      if (movieToSave.isNotEmpty) {
        movies.add(movieToSave);
      }
    } else {
      if (movieToSave.isEmpty) {
        movies.removeAt(index);
      } else {
        movies[index] = movieToSave;
      }
    }

    await saveLocalCache(movies);
  }

  /// Realiza a migração segura dos dados locais para a API própria da coleção.
  ///
  /// Regras de migração:
  /// 1. Se já migrado anteriormente, não reexecuta.
  /// 2. Se a coleção local estiver vazia, marca como migrado.
  /// 3. Se houver dados locais:
  ///    - Verifica se a API está online (`checkHealth`). Se offline, não apaga o local e aguarda.
  ///    - Se a API estiver online e vazia: envia os itens locais para a API e marca como migrado.
  ///    - Se a API já tiver dados: mantém os dados remotos como fonte da verdade e marca como migrado.
  static Future<void> ensureMigrated() async {
    final preferences = await SharedPreferences.getInstance();
    final alreadyMigrated = preferences.getBool(_migrationKey) ?? false;
    if (alreadyMigrated) {
      return;
    }

    final localMovies = await getLocalCache();
    if (localMovies.isEmpty) {
      await preferences.setBool(_migrationKey, true);
      return;
    }

    final isHealthy = await _repository.checkHealth();
    if (!isHealthy) {
      return;
    }

    try {
      final remoteMovies = await _repository.getAll();
      if (remoteMovies.isEmpty) {
        for (final movie in localMovies) {
          if (movie.isNotEmpty) {
            await _repository.saveMovie(movie);
          }
        }
      }
      await preferences.setBool(_migrationKey, true);
    } catch (_) {
      // Falha na migração preserva dados para nova tentativa
    }
  }

  /// Retorna todos os filmes da coleção.
  ///
  /// Consulta a API REST como fonte da verdade.
  /// Sincroniza o cache local em caso de sucesso.
  /// Em caso de falha de conexão, recorre ao cache local de forma transparente.
  static Future<List<UserMovie>> getAllMovies() async {
    await ensureMigrated();

    try {
      final remote = await _repository.getAll();
      await saveLocalCache(remote);
      return remote;
    } on CollectionNetworkException {
      return getLocalCache();
    } catch (_) {
      return getLocalCache();
    }
  }

  /// Busca um filme na coleção utilizando seu IMDb ID.
  ///
  /// Retorna null se não encontrado ou se o item não tiver dados pessoais.
  static Future<UserMovie?> getMovie(String imdbId) async {
    await ensureMigrated();

    try {
      final remote = await _repository.getById(imdbId);
      if (remote != null) {
        await _updateLocalItem(remote);
      }
      return remote;
    } on CollectionNetworkException {
      final local = await getLocalCache();
      for (final m in local) {
        if (m.imdbId == imdbId) {
          return m;
        }
      }
      return null;
    } catch (_) {
      final local = await getLocalCache();
      for (final m in local) {
        if (m.imdbId == imdbId) {
          return m;
        }
      }
      return null;
    }
  }

  /// Salva ou atualiza um filme na coleção.
  ///
  /// Atualiza o cache local imediatamente para garantir persistência no dispositivo
  /// e envia para a API REST. Se a API estiver offline, lança [CollectionNetworkException]
  /// para que a tela possa informar o usuário com mensagem apropriada.
  static Future<void> saveMovie(UserMovie movie) async {
    await _updateLocalItem(movie);

    try {
      await _repository.saveMovie(movie);
    } on CollectionNetworkException {
      rethrow;
    }
  }

  /// Retorna apenas os filmes marcados como favoritos.
  static Future<List<UserMovie>> getFavorites() async {
    final movies = await getAllMovies();
    return movies.where((movie) => movie.isFavorite).toList();
  }

  /// Retorna apenas os filmes marcados como assistidos ou séries com progresso de episódios.
  static Future<List<UserMovie>> getWatched() async {
    final movies = await getAllMovies();
    return movies
        .where((movie) => movie.isWatched || movie.hasEpisodeProgress)
        .toList();
  }

  /// Retorna apenas os filmes adicionados à lista de desejos.
  static Future<List<UserMovie>> getWishlist() async {
    final movies = await getAllMovies();
    return movies.where((movie) => movie.isWishlist).toList();
  }

  /// Remove explicitamente um título da coleção pelo IMDb ID.
  static Future<bool> deleteMovie(String imdbId) async {
    final movies = await getLocalCache();
    movies.removeWhere((item) => item.imdbId == imdbId);
    await saveLocalCache(movies);

    try {
      return await _repository.deleteMovie(imdbId);
    } on CollectionNetworkException {
      return true;
    }
  }
}
