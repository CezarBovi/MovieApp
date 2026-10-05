import 'rating.dart';

/// Representa as informações detalhadas de um filme ou série.
///
/// Esses dados são obtidos através da consulta pelo IMDb ID
/// utilizando o parâmetro `i` da OMDb API.
class MovieDetails {
  final String title;
  final String year;
  final String rated;
  final String released;
  final String runtime;
  final String genre;
  final String director;
  final String writer;
  final String actors;
  final String plot;
  final String language;
  final String country;
  final String awards;
  final String poster;
  final List<Rating> ratings;
  final String metascore;
  final String imdbRating;
  final String imdbVotes;
  final String imdbId;
  final String type;

  /// Quantidade total de temporadas.
  ///
  /// Esse campo normalmente existe apenas quando a obra é uma série.
  final String? totalSeasons;

  MovieDetails({
    required this.title,
    required this.year,
    required this.rated,
    required this.released,
    required this.runtime,
    required this.genre,
    required this.director,
    required this.writer,
    required this.actors,
    required this.plot,
    required this.language,
    required this.country,
    required this.awards,
    required this.poster,
    required this.ratings,
    required this.metascore,
    required this.imdbRating,
    required this.imdbVotes,
    required this.imdbId,
    required this.type,
    this.totalSeasons,
  });

  /// Converte o JSON retornado pela OMDb em um objeto [MovieDetails].
  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    final List<dynamic> ratingsJson = json['Ratings'] ?? [];

    return MovieDetails(
      title: json['Title'] ?? '',
      year: json['Year'] ?? '',
      rated: json['Rated'] ?? '',
      released: json['Released'] ?? '',
      runtime: json['Runtime'] ?? '',
      genre: json['Genre'] ?? '',
      director: json['Director'] ?? '',
      writer: json['Writer'] ?? '',
      actors: json['Actors'] ?? '',
      plot: json['Plot'] ?? '',
      language: json['Language'] ?? '',
      country: json['Country'] ?? '',
      awards: json['Awards'] ?? '',
      poster: json['Poster'] ?? '',

      // Converte cada avaliação da lista para um objeto Rating.
      ratings: ratingsJson
          .map(
            (rating) =>
                Rating.fromJson(rating as Map<String, dynamic>),
          )
          .toList(),

      metascore: json['Metascore'] ?? '',
      imdbRating: json['imdbRating'] ?? '',
      imdbVotes: json['imdbVotes'] ?? '',
      imdbId: json['imdbID'] ?? '',
      type: json['Type'] ?? '',
      totalSeasons: json['totalSeasons'],
    );
  }
}