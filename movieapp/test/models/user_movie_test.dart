import 'package:flutter_test/flutter_test.dart';
import 'package:movieapp/models/user_movie.dart';

void main() {
  group('UserMovie Model', () {
    test('Serialização e desserialização completa via toJson e fromJson', () {
      final original = UserMovie(
        imdbId: 'tt0903747',
        title: 'Breaking Bad',
        year: '2008–2013',
        type: 'series',
        poster: 'https://exemplo.com/poster.jpg',
        imdbRating: '9.5',
        isFavorite: true,
        isWatched: false,
        isWishlist: false,
        userRating: 10,
        watchedEpisodes: ['1:1', '1:2', '1:3'],
        lastWatchedSeason: 1,
        lastWatchedEpisode: 3,
      );

      final json = original.toJson();
      expect(json['imdbId'], 'tt0903747');
      expect(json['title'], 'Breaking Bad');
      expect(json['year'], '2008–2013');
      expect(json['type'], 'series');
      expect(json['poster'], 'https://exemplo.com/poster.jpg');
      expect(json['imdbRating'], '9.5');
      expect(json['isFavorite'], true);
      expect(json['isWatched'], false);
      expect(json['isWishlist'], false);
      expect(json['userRating'], 10);
      expect(json['watchedEpisodes'], ['1:1', '1:2', '1:3']);
      expect(json['lastWatchedSeason'], 1);
      expect(json['lastWatchedEpisode'], 3);

      final restored = UserMovie.fromJson(json);
      expect(restored, equals(original));
      expect(restored.isSeries, isTrue);
      expect(restored.hasEpisodeProgress, isTrue);
      expect(restored.continueWatchingLabel, 'Temporada 1 · Episódio 3');
    });

    test('fromJson trata valores nulos e ausentes com defaults seguros', () {
      final minimalJson = {
        'imdbId': 'tt0133093',
        'title': 'The Matrix',
        'year': '1999',
        'type': 'movie',
        'poster': 'https://exemplo.com/matrix.jpg',
      };

      final movie = UserMovie.fromJson(minimalJson);
      expect(movie.imdbId, 'tt0133093');
      expect(movie.title, 'The Matrix');
      expect(movie.imdbRating, '');
      expect(movie.isFavorite, isFalse);
      expect(movie.isWatched, isFalse);
      expect(movie.isWishlist, isFalse);
      expect(movie.userRating, isNull);
      expect(movie.watchedEpisodes, isEmpty);
      expect(movie.lastWatchedSeason, isNull);
      expect(movie.lastWatchedEpisode, isNull);
      expect(movie.isEmpty, isTrue);
      expect(movie.isNotEmpty, isFalse);
    });

    test('isEmpty e isNotEmpty respondem a qualquer dado pessoal', () {
      final base = UserMovie(
        imdbId: 'tt0133093',
        title: 'The Matrix',
        year: '1999',
        type: 'movie',
        poster: '',
        imdbRating: '8.7',
      );

      expect(base.isEmpty, isTrue);
      expect(base.isNotEmpty, isFalse);

      expect(base.copyWith(isFavorite: true).isEmpty, isFalse);
      expect(base.copyWith(isWatched: true).isEmpty, isFalse);
      expect(base.copyWith(isWishlist: true).isEmpty, isFalse);
      expect(base.copyWith(userRating: 9).isEmpty, isFalse);
      expect(base.copyWith(watchedEpisodes: ['1:1']).isEmpty, isFalse);
    });

    test('Controle de episódios de séries', () {
      final series = UserMovie(
        imdbId: 'tt0903747',
        title: 'Breaking Bad',
        year: '2008–2013',
        type: 'series',
        poster: '',
        imdbRating: '9.5',
        watchedEpisodes: ['1:1', '1:2', '2:1'],
      );

      expect(series.isEpisodeWatched(1, 1), isTrue);
      expect(series.isEpisodeWatched(1, 2), isTrue);
      expect(series.isEpisodeWatched(2, 1), isTrue);
      expect(series.isEpisodeWatched(1, 3), isFalse);
      expect(series.isEpisodeWatched(2, 2), isFalse);
    });

    test('copyWith atualiza campos e permite remoção de nota e último ponto', () {
      final movie = UserMovie(
        imdbId: 'tt0133093',
        title: 'The Matrix',
        year: '1999',
        type: 'movie',
        poster: '',
        imdbRating: '8.7',
        isFavorite: false,
        userRating: 8,
        lastWatchedSeason: 1,
        lastWatchedEpisode: 2,
      );

      final updated = movie.copyWith(
        isFavorite: true,
        removeRating: true,
        clearLastWatched: true,
      );

      expect(updated.isFavorite, isTrue);
      expect(updated.userRating, isNull);
      expect(updated.lastWatchedSeason, isNull);
      expect(updated.lastWatchedEpisode, isNull);
      expect(updated.title, 'The Matrix');
    });

    test('Igualdade e hashCode entre instâncias de UserMovie', () {
      final movie1 = UserMovie(
        imdbId: 'tt0133093',
        title: 'The Matrix',
        year: '1999',
        type: 'movie',
        poster: 'poster.jpg',
        imdbRating: '8.7',
        isFavorite: true,
        watchedEpisodes: ['1:1'],
      );

      final movie2 = UserMovie(
        imdbId: 'tt0133093',
        title: 'The Matrix',
        year: '1999',
        type: 'movie',
        poster: 'poster.jpg',
        imdbRating: '8.7',
        isFavorite: true,
        watchedEpisodes: ['1:1'],
      );

      expect(movie1, equals(movie2));
      expect(movie1.hashCode, equals(movie2.hashCode));

      final movie3 = movie1.copyWith(isFavorite: false);
      expect(movie1 == movie3, isFalse);
    });
  });
}
