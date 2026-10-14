import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_movie.dart';

/// Serviço responsável pelo armazenamento local da coleção do usuário.
///
/// Favoritos, filmes assistidos, lista de desejos e notas pessoais
/// são salvos utilizando o pacote SharedPreferences.
class CollectionService {
  /// Chave utilizada para salvar a lista de filmes no armazenamento local.
  static const String _storageKey = 'movie_collection';

  /// Retorna todos os filmes armazenados localmente no SharedPreferences.
  static Future<List<UserMovie>> getAllMovies() async {
    // Obtém a instância assíncrona do SharedPreferences
    final preferences = await SharedPreferences.getInstance();

    // Recupera a string JSON associada à chave da coleção
    final storedData = preferences.getString(_storageKey);

    // Se não houver dados salvos ou estiver vazia, retorna lista vazia
    if (storedData == null || storedData.isEmpty) {
      return [];
    }

    // Decodifica a string em uma lista dinâmica
    final List<dynamic> decoded = jsonDecode(storedData);

    // Converte cada item do JSON para uma instância de UserMovie
    return decoded
        .map((item) => UserMovie.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Busca um filme salvo utilizando seu IMDb ID.
  ///
  /// Retorna `null` quando o filme ainda não possui
  /// nenhuma informação pessoal registrada.
  static Future<UserMovie?> getMovie(String imdbId) async {
    // Obtém todos os filmes salvos na coleção
    final movies = await getAllMovies();

    // Itera pela lista procurando o filme com o imdbId correspondente
    for (final movie in movies) {
      if (movie.imdbId == imdbId) {
        return movie;
      }
    }

    // Retorna null caso não seja encontrado
    return null;
  }

  /// Salva ou atualiza um filme na coleção local.
  static Future<void> saveMovie(UserMovie movie) async {
    final preferences = await SharedPreferences.getInstance();
    final movies = await getAllMovies();
    // Se o filme estiver assistido, remove automaticamente da lista de desejos
    final movieToSave = movie.isWatched && movie.isWishlist
        ? movie.copyWith(isWishlist: false)
        : movie;

    // Localiza se o filme já existe na lista
    final index = movies.indexWhere(
      (item) => item.imdbId == movieToSave.imdbId,
    );

    // Caso o filme ainda não exista, ele é adicionado; se já existir, é atualizado.
    if (index == -1) {
      movies.add(movieToSave);
    } else {
      movies[index] = movieToSave;
    }

    // Remove automaticamente filmes que não possuem
    // nenhuma informação pessoal associada (limpeza de storage).
    movies.removeWhere(
      (item) =>
          !item.isFavorite &&
          !item.isWatched &&
          !item.hasEpisodeProgress &&
          !item.isWishlist &&
          item.userRating == null,
    );

    // Converte a lista atualizada de volta para string JSON
    final encoded = jsonEncode(movies.map((movie) => movie.toJson()).toList());

    // Persiste no SharedPreferences
    await preferences.setString(_storageKey, encoded);
  }

  /// Retorna apenas os filmes marcados como favoritos.
  static Future<List<UserMovie>> getFavorites() async {
    final movies = await getAllMovies();

    // Filtra apenas onde isFavorite for verdadeiro
    return movies.where((movie) => movie.isFavorite).toList();
  }

  /// Retorna apenas os filmes marcados como assistidos ou séries com progresso de episódios.
  static Future<List<UserMovie>> getWatched() async {
    final movies = await getAllMovies();

    // Filtra obras assistidas ou séries com episódios marcados
    return movies
        .where((movie) => movie.isWatched || movie.hasEpisodeProgress)
        .toList();
  }

  /// Retorna apenas os filmes adicionados à lista de desejos.
  static Future<List<UserMovie>> getWishlist() async {
    final movies = await getAllMovies();

    // Filtra obras onde isWishlist for verdadeiro
    return movies.where((movie) => movie.isWishlist).toList();
  }
}
