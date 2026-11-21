import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:movieapp/config/api_config.dart';
import 'package:movieapp/models/user_movie.dart';
import 'package:movieapp/repositories/collection_repository.dart';
import 'package:movieapp/repositories/collection_repository_exception.dart';

void main() {
  group('CollectionRepository', () {
    setUp(() {
      ApiConfig.baseUrl = 'http://127.0.0.1:5000';
    });

    tearDown(() {
      ApiConfig.reset();
    });

    final sampleMovie = UserMovie(
      imdbId: 'tt0133093',
      title: 'The Matrix',
      year: '1999',
      type: 'movie',
      poster: 'https://exemplo.com/matrix.jpg',
      imdbRating: '8.7',
      isFavorite: true,
      isWatched: true,
      isWishlist: false,
      userRating: 9,
    );

    final sampleSeries = UserMovie(
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

    final sampleWishlist = UserMovie(
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

    group('checkHealth', () {
      test('retorna true quando o servidor responde status 200 com status ok', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/health');
          return http.Response(
            jsonEncode({'status': 'ok', 'servico': 'movieapp-colecao'}),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final repo = CollectionRepository(client: mockClient);
        final isHealthy = await repo.checkHealth();
        expect(isHealthy, isTrue);
      });

      test('retorna false quando o servidor responde com erro 500', () async {
        final mockClient = MockClient((request) async {
          return http.Response('Internal Server Error', 500);
        });

        final repo = CollectionRepository(client: mockClient);
        final isHealthy = await repo.checkHealth();
        expect(isHealthy, isFalse);
      });

      test('retorna false quando ocorre exceção de conexão', () async {
        final mockClient = MockClient((request) async {
          throw http.ClientException('Falha de rede');
        });

        final repo = CollectionRepository(client: mockClient);
        final isHealthy = await repo.checkHealth();
        expect(isHealthy, isFalse);
      });
    });

    group('getAll', () {
      test('retorna lista com todos os itens da coleção', () async {
        final mockClient = MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/colecao');
          return http.Response(
            jsonEncode([sampleMovie.toJson(), sampleSeries.toJson()]),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final repo = CollectionRepository(client: mockClient);
        final result = await repo.getAll();

        expect(result.length, 2);
        expect(result[0].imdbId, 'tt0133093');
        expect(result[1].imdbId, 'tt0903747');
      });

      test('retorna lista vazia quando coleção estiver vazia', () async {
        final mockClient = MockClient((request) async {
          return http.Response('[]', 200, headers: {'content-type': 'application/json'});
        });

        final repo = CollectionRepository(client: mockClient);
        final result = await repo.getAll();
        expect(result, isEmpty);
      });

      test('lança CollectionException em caso de erro no servidor', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'erro': 'Erro no servidor.', 'codigo': 'SERVIDOR'}),
            500,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final repo = CollectionRepository(client: mockClient);
        expect(
          () => repo.getAll(),
          throwsA(isA<CollectionException>()),
        );
      });
    });

    group('getById', () {
      test('retorna UserMovie quando encontrado (HTTP 200)', () async {
        final mockClient = MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/colecao/tt0133093');
          return http.Response(
            jsonEncode(sampleMovie.toJson()),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final repo = CollectionRepository(client: mockClient);
        final result = await repo.getById('tt0133093');

        expect(result, isNotNull);
        expect(result!.imdbId, 'tt0133093');
        expect(result.title, 'The Matrix');
      });

      test('retorna null quando não encontrado (HTTP 404)', () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/colecao/tt9999999');
          return http.Response(
            jsonEncode({'erro': 'Não encontrado.', 'codigo': 'NAO_ENCONTRADO'}),
            404,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final repo = CollectionRepository(client: mockClient);
        final result = await repo.getById('tt9999999');
        expect(result, isNull);
      });

      test('lança CollectionValidationException em caso de IMDb ID inválido (HTTP 400)', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'erro': 'IMDb ID inválido.', 'codigo': 'VALIDACAO'}),
            400,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final repo = CollectionRepository(client: mockClient);
        expect(
          () => repo.getById('invalido'),
          throwsA(isA<CollectionValidationException>()),
        );
      });
    });

    group('saveMovie', () {
      test('salva ou atualiza filme com sucesso (HTTP 200/201)', () async {
        final mockClient = MockClient((request) async {
          expect(request.method, 'PUT');
          expect(request.url.path, '/colecao/tt0133093');

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['imdbId'], 'tt0133093');
          expect(body['title'], 'The Matrix');

          return http.Response(
            request.body,
            201,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final repo = CollectionRepository(client: mockClient);
        final saved = await repo.saveMovie(sampleMovie);

        expect(saved, isNotNull);
        expect(saved!.imdbId, 'tt0133093');
        expect(saved.isFavorite, isTrue);
      });

      test('garante que filme assistido remove isWishlist antes de enviar', () async {
        final conflictMovie = sampleMovie.copyWith(
          isWatched: true,
          isWishlist: true,
        );

        final mockClient = MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['isWatched'], isTrue);
          expect(body['isWishlist'], isFalse); // Sanitizado para false

          return http.Response(
            jsonEncode(body),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final repo = CollectionRepository(client: mockClient);
        final result = await repo.saveMovie(conflictMovie);
        expect(result!.isWishlist, isFalse);
      });

      test('retorna null quando registro vazio é removido pelo servidor ({"removido": true})', () async {
        final emptyMovie = UserMovie(
          imdbId: 'tt0133093',
          title: 'The Matrix',
          year: '1999',
          type: 'movie',
          poster: '',
          imdbRating: '8.7',
        );

        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'removido': true, 'imdbId': 'tt0133093'}),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final repo = CollectionRepository(client: mockClient);
        final result = await repo.saveMovie(emptyMovie);
        expect(result, isNull);
      });

      test('lança CollectionValidationException em dados inválidos (HTTP 400)', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'erro': 'A nota deve estar entre 1 e 10.', 'codigo': 'VALIDACAO'}),
            400,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final repo = CollectionRepository(client: mockClient);
        expect(
          () => repo.saveMovie(sampleMovie),
          throwsA(isA<CollectionValidationException>()),
        );
      });
    });

    group('deleteMovie', () {
      test('retorna true quando removido com sucesso (HTTP 200)', () async {
        final mockClient = MockClient((request) async {
          expect(request.method, 'DELETE');
          expect(request.url.path, '/colecao/tt0133093');
          return http.Response(
            jsonEncode({'removido': true, 'imdbId': 'tt0133093'}),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final repo = CollectionRepository(client: mockClient);
        final success = await repo.deleteMovie('tt0133093');
        expect(success, isTrue);
      });

      test('retorna false quando item não é encontrado para remoção (HTTP 404)', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'erro': 'Não encontrado.', 'codigo': 'NAO_ENCONTRADO'}),
            404,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final repo = CollectionRepository(client: mockClient);
        final success = await repo.deleteMovie('tt9999999');
        expect(success, isFalse);
      });
    });

    group('métodos de filtro de conveniência', () {
      test('getFavorites, getWatched e getWishlist filtram a lista corretamente', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode([
              sampleMovie.toJson(),
              sampleSeries.toJson(),
              sampleWishlist.toJson(),
            ]),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final repo = CollectionRepository(client: mockClient);

        final favorites = await repo.getFavorites();
        expect(favorites.length, 2);
        expect(favorites.map((m) => m.imdbId), containsAll(['tt0133093', 'tt0903747']));

        final watched = await repo.getWatched();
        expect(watched.length, 2);
        expect(watched.map((m) => m.imdbId), containsAll(['tt0133093', 'tt0903747']));

        final wishlist = await repo.getWishlist();
        expect(wishlist.length, 1);
        expect(wishlist.first.imdbId, 'tt0068646');
      });
    });

    group('tratamento de erro de rede', () {
      test('lança CollectionNetworkException quando ocorre falha de conexão', () async {
        final mockClient = MockClient((request) async {
          throw http.ClientException('Connection refused');
        });

        final repo = CollectionRepository(client: mockClient);
        expect(
          () => repo.getAll(),
          throwsA(isA<CollectionNetworkException>()),
        );
      });
    });
  });
}
