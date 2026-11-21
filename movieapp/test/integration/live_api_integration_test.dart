import 'package:flutter_test/flutter_test.dart';
import 'package:movieapp/config/api_config.dart';
import 'package:movieapp/models/user_movie.dart';
import 'package:movieapp/repositories/collection_repository.dart';

void main() {
  group('Live API Integration Tests (Flutter <-> Flask na porta 5000)', () {
    late CollectionRepository repository;

    setUpAll(() {
      ApiConfig.baseUrl = 'http://127.0.0.1:5000';
      repository = CollectionRepository(customBaseUrl: 'http://127.0.0.1:5000');
    });

    tearDownAll(() {
      ApiConfig.reset();
    });

    test('Health check na API Flask real responde status ok', () async {
      final isHealthy = await repository.checkHealth();
      expect(isHealthy, isTrue);
    });

    test('Ciclo completo de CRUD (criação, leitura, atualização e remoção) no servidor Flask', () async {
      final testMovie = UserMovie(
        imdbId: 'tt0133093',
        title: 'The Matrix (Teste Integração)',
        year: '1999',
        type: 'movie',
        poster: 'https://exemplo.com/matrix.jpg',
        imdbRating: '8.7',
        isFavorite: true,
        isWatched: true,
        isWishlist: false,
        userRating: 10,
      );

      // 1. Salvar no servidor real
      final saved = await repository.saveMovie(testMovie);
      expect(saved, isNotNull);
      expect(saved!.imdbId, 'tt0133093');
      expect(saved.title, 'The Matrix (Teste Integração)');

      // 2. Consultar pelo IMDb ID no servidor real
      final retrieved = await repository.getById('tt0133093');
      expect(retrieved, isNotNull);
      expect(retrieved!.imdbId, 'tt0133093');
      expect(retrieved.userRating, 10);
      expect(retrieved.isFavorite, isTrue);

      // 3. Atualizar nota no servidor real
      final updated = await repository.saveMovie(testMovie.copyWith(userRating: 9));
      expect(updated, isNotNull);
      expect(updated!.userRating, 9);

      // 4. Remover do servidor real
      final deleted = await repository.deleteMovie('tt0133093');
      expect(deleted, isTrue);

      // 5. Confirmar que não existe mais
      final notFound = await repository.getById('tt0133093');
      expect(notFound, isNull);
    });
  });
}
