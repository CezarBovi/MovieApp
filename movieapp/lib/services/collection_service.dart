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

  /// Retorna todos os filmes armazenados localmente.
  static Future<List<UserMovie>> getAllMovies() async {
    final preferences = await SharedPreferences.getInstance();

    final storedData = preferences.getString(_storageKey);

    if (storedData == null || storedData.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(storedData);

    return decoded
        .map((item) => UserMovie.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Busca um filme salvo utilizando seu IMDb ID.
  ///
  /// Retorna `null` quando o filme ainda não possui
  /// nenhuma informação pessoal registrada.
  static Future<UserMovie?> getMovie(String imdbId) async {
    final movies = await getAllMovies();

    for (final movie in movies) {
      if (movie.imdbId == imdbId) {
        return movie;
      }
    }

    return null;
  }

  /// Salva ou atualiza um filme na coleção local.
  static Future<void> saveMovie(UserMovie movie) async {
    final preferences = await SharedPreferences.getInstance();
    final movies = await getAllMovies();
    final movieToSave = movie.isWatched && movie.isWishlist
        ? movie.copyWith(isWishlist: false)
        : movie;

    final index = movies.indexWhere(
      (item) => item.imdbId == movieToSave.imdbId,
    );

    // Caso o filme ainda não exista, ele é adicionado.
    if (index == -1) {
      movies.add(movieToSave);
    } else {
      movies[index] = movieToSave;
    }

    // Remove automaticamente filmes que não possuem
    // nenhuma informação pessoal associada.
    movies.removeWhere(
      (item) =>
          !item.isFavorite &&
          !item.isWatched &&
          !item.isWishlist &&
          item.userRating == null,
    );

    final encoded = jsonEncode(movies.map((movie) => movie.toJson()).toList());

    await preferences.setString(_storageKey, encoded);
  }

  /// Retorna apenas os filmes marcados como favoritos.
  static Future<List<UserMovie>> getFavorites() async {
    final movies = await getAllMovies();

    return movies.where((movie) => movie.isFavorite).toList();
  }

  /// Retorna apenas os filmes marcados como assistidos.
  static Future<List<UserMovie>> getWatched() async {
    final movies = await getAllMovies();

    return movies.where((movie) => movie.isWatched).toList();
  }

  /// Retorna apenas os filmes adicionados à lista de desejos.
  static Future<List<UserMovie>> getWishlist() async {
    final movies = await getAllMovies();

    return movies.where((movie) => movie.isWishlist).toList();
  }
}
