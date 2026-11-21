import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:movieapp/models/user_movie.dart';
import 'package:movieapp/repositories/collection_repository.dart';
import 'package:movieapp/repositories/collection_repository_exception.dart';
import 'package:movieapp/services/collection_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final movieMatrix = UserMovie(
    imdbId: 'tt0133093',
    title: 'The Matrix',
    year: '1999',
    type: 'movie',
    poster: 'https://exemplo.com/matrix.jpg',
    imdbRating: '8.7',
    isFavorite: true,
    isWatched: true,
    isWishlist: false,
    userRating: 10,
  );

  final seriesBreakingBad = UserMovie(
    imdbId: 'tt0903747',
    title: 'Breaking Bad',
    year: '2008–2013',
    type: 'series',
    poster: 'https://exemplo.com/bb.jpg',
    imdbRating: '9.5',
    isFavorite: true,
    isWatched: false,
    isWishlist: false,
    watchedEpisodes: ['1:1', '1:2'],
    lastWatchedSeason: 1,
    lastWatchedEpisode: 2,
  );

  final movieGodfather = UserMovie(
    imdbId: 'tt0068646',
    title: 'The Godfather',
    year: '1972',
    type: 'movie',
    poster: 'https://exemplo.com/godfather.jpg',
    imdbRating: '9.2',
    isFavorite: false,
    isWatched: false,
    isWishlist: true,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CollectionService.resetRepository();
  });

  tearDown(() {
    CollectionService.resetRepository();
  });

  group('CollectionService - Cache Local', () {
    test('getLocalCache retorna lista vazia quando inicializado sem dados', () async {
      final list = await CollectionService.getLocalCache();
      expect(list, isEmpty);
    });

    test('saveLocalCache e getLocalCache persistem e recuperam itens', () async {
      await CollectionService.saveLocalCache([movieMatrix, seriesBreakingBad]);
      final list = await CollectionService.getLocalCache();

      expect(list.length, 2);
      expect(list[0].imdbId, 'tt0133093');
      expect(list[1].imdbId, 'tt0903747');
    });
  });

  group('CollectionService - Migração Segura', () {
    test('se local estiver vazio, marca como migrado imediatamente', () async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('collection_migrated_v1'), isNull);

      await CollectionService.ensureMigrated();
      expect(prefs.getBool('collection_migrated_v1'), isTrue);
    });

    test('se local contiver filmes e API vazia, migra itens para a API e marca migrado', () async {
      // Prepara dados no SharedPreferences simulando versão anterior
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'movie_collection',
        jsonEncode([movieMatrix.toJson()]),
      );

      final List<Map<String, dynamic>> savedOnServer = [];

      final mockClient = MockClient((request) async {
        if (request.url.path == '/health') {
          return http.Response(jsonEncode({'status': 'ok'}), 200);
        }
        if (request.method == 'GET' && request.url.path == '/colecao') {
          return http.Response(jsonEncode(savedOnServer), 200);
        }
        if (request.method == 'PUT' && request.url.path.startsWith('/colecao/')) {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          savedOnServer.add(body);
          return http.Response(request.body, 201);
        }
        return http.Response('Not Found', 404);
      });

      CollectionService.setRepository(CollectionRepository(client: mockClient));

      await CollectionService.ensureMigrated();

      expect(savedOnServer.length, 1);
      expect(savedOnServer.first['imdbId'], 'tt0133093');
      expect(prefs.getBool('collection_migrated_v1'), isTrue);
    });

    test('se API estiver offline durante tentativa de migração, não apaga local e não marca migrado', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'movie_collection',
        jsonEncode([movieMatrix.toJson()]),
      );

      final mockClient = MockClient((request) async {
        throw http.ClientException('Falha de conexão com a API');
      });

      CollectionService.setRepository(CollectionRepository(client: mockClient));

      await CollectionService.ensureMigrated();

      expect(prefs.getBool('collection_migrated_v1'), isNull);
      final local = await CollectionService.getLocalCache();
      expect(local.length, 1);
      expect(local.first.imdbId, 'tt0133093');
    });
  });

  group('CollectionService - Operações Online e Fallback Offline', () {
    test('getAllMovies busca da API quando online e atualiza cache local', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/health') {
          return http.Response(jsonEncode({'status': 'ok'}), 200);
        }
        if (request.url.path == '/colecao') {
          return http.Response(
            jsonEncode([movieMatrix.toJson(), seriesBreakingBad.toJson()]),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      CollectionService.setRepository(CollectionRepository(client: mockClient));

      final result = await CollectionService.getAllMovies();
      expect(result.length, 2);

      // Confere se o cache local foi atualizado
      final cached = await CollectionService.getLocalCache();
      expect(cached.length, 2);
      expect(cached[0].imdbId, 'tt0133093');
    });

    test('getAllMovies recorre ao cache local se a API estiver offline', () async {
      // Grava filme no cache local
      await CollectionService.saveLocalCache([movieMatrix]);

      final mockClient = MockClient((request) async {
        throw http.ClientException('Servidor offline');
      });

      CollectionService.setRepository(CollectionRepository(client: mockClient));

      final result = await CollectionService.getAllMovies();
      expect(result.length, 1);
      expect(result.first.imdbId, 'tt0133093');
    });

    test('getMovie busca item na API e atualiza o cache local', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/health') {
          return http.Response(jsonEncode({'status': 'ok'}), 200);
        }
        if (request.url.path == '/colecao/tt0133093') {
          return http.Response(
            jsonEncode(movieMatrix.toJson()),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      CollectionService.setRepository(CollectionRepository(client: mockClient));

      final movie = await CollectionService.getMovie('tt0133093');
      expect(movie, isNotNull);
      expect(movie!.title, 'The Matrix');

      final cached = await CollectionService.getLocalCache();
      expect(cached.length, 1);
      expect(cached.first.imdbId, 'tt0133093');
    });

    test('getMovie retorna do cache local quando a API estiver offline', () async {
      await CollectionService.saveLocalCache([movieMatrix]);

      final mockClient = MockClient((request) async {
        throw http.ClientException('Servidor offline');
      });

      CollectionService.setRepository(CollectionRepository(client: mockClient));

      final movie = await CollectionService.getMovie('tt0133093');
      expect(movie, isNotNull);
      expect(movie!.imdbId, 'tt0133093');

      final nonExistent = await CollectionService.getMovie('tt9999999');
      expect(nonExistent, isNull);
    });

    test('saveMovie salva localmente e na API quando online', () async {
      var serverSaved = false;
      final mockClient = MockClient((request) async {
        if (request.method == 'PUT' && request.url.path == '/colecao/tt0133093') {
          serverSaved = true;
          return http.Response(request.body, 201);
        }
        return http.Response('Not Found', 404);
      });

      CollectionService.setRepository(CollectionRepository(client: mockClient));

      await CollectionService.saveMovie(movieMatrix);

      expect(serverSaved, isTrue);
      final cached = await CollectionService.getLocalCache();
      expect(cached.length, 1);
      expect(cached.first.imdbId, 'tt0133093');
    });

    test('saveMovie persiste localmente e lança CollectionNetworkException se API estiver offline', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Servidor offline');
      });

      CollectionService.setRepository(CollectionRepository(client: mockClient));

      await expectLater(
        () => CollectionService.saveMovie(movieMatrix),
        throwsA(isA<CollectionNetworkException>()),
      );

      // Mesmo lançando a exceção de rede, o dado foi persistido no cache local com segurança
      final cached = await CollectionService.getLocalCache();
      expect(cached.length, 1);
      expect(cached.first.imdbId, 'tt0133093');
    });

    test('saveMovie de registro vazio remove o item do cache local', () async {
      await CollectionService.saveLocalCache([movieMatrix]);

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'removido': true, 'imdbId': 'tt0133093'}),
          200,
        );
      });

      CollectionService.setRepository(CollectionRepository(client: mockClient));

      final emptyMatrix = UserMovie(
        imdbId: 'tt0133093',
        title: 'The Matrix',
        year: '1999',
        type: 'movie',
        poster: '',
        imdbRating: '8.7',
      );

      await CollectionService.saveMovie(emptyMatrix);

      final cached = await CollectionService.getLocalCache();
      expect(cached, isEmpty);
    });

    test('filtros getFavorites, getWatched e getWishlist operam sobre a coleção integrada', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/health') {
          return http.Response(jsonEncode({'status': 'ok'}), 200);
        }
        if (request.url.path == '/colecao') {
          return http.Response(
            jsonEncode([
              movieMatrix.toJson(),
              seriesBreakingBad.toJson(),
              movieGodfather.toJson(),
            ]),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not Found', 404);
      });

      CollectionService.setRepository(CollectionRepository(client: mockClient));

      final favorites = await CollectionService.getFavorites();
      expect(favorites.length, 2);

      final watched = await CollectionService.getWatched();
      expect(watched.length, 2);

      final wishlist = await CollectionService.getWishlist();
      expect(wishlist.length, 1);
      expect(wishlist.first.imdbId, 'tt0068646');
    });

    test('deleteMovie remove do cache local e da API', () async {
      await CollectionService.saveLocalCache([movieMatrix]);

      var deleteCalled = false;
      final mockClient = MockClient((request) async {
        if (request.method == 'DELETE' && request.url.path == '/colecao/tt0133093') {
          deleteCalled = true;
          return http.Response(
            jsonEncode({'removido': true, 'imdbId': 'tt0133093'}),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      CollectionService.setRepository(CollectionRepository(client: mockClient));

      final success = await CollectionService.deleteMovie('tt0133093');
      expect(success, isTrue);
      expect(deleteCalled, isTrue);

      final cached = await CollectionService.getLocalCache();
      expect(cached, isEmpty);
    });
  });
}
