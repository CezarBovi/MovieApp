import 'rating.dart';

/// Representa as informações detalhadas de um filme ou série.
///
/// Esses dados são obtidos através da consulta pelo IMDb ID
/// utilizando o parâmetro `i` da OMDb API.
class MovieDetails {
  /// Título principal do filme ou série.
  final String title;

  /// Ano ou período de exibição (ex: "2008–2013").
  final String year;

  /// Classificação indicativa etária (ex: "PG-13", "TV-MA").
  final String rated;

  /// Data de lançamento oficial nos cinemas ou TV.
  final String released;

  /// Duração do filme ou média por episódio (ex: "148 min").
  final String runtime;

  /// Gêneros associados (ex: "Action, Sci-Fi").
  final String genre;

  /// Diretor ou diretores da obra.
  final String director;

  /// Roteirista(s) ou criador(es) da obra.
  final String writer;

  /// Principais atores e atrizes do elenco.
  final String actors;

  /// Sinopse completa da obra.
  final String plot;

  /// Idiomas originais do áudio.
  final String language;

  /// País ou países de origem da produção.
  final String country;

  /// Prêmios e indicações conquistados (ex: Oscars, Emmys).
  final String awards;

  /// URL da imagem do pôster oficial.
  final String poster;

  /// Lista de avaliações de diferentes veículos críticos (Rotten Tomatoes, Metacritic, IMDb).
  final List<Rating> ratings;

  /// Pontuação no Metascore (de 0 a 100).
  final String metascore;

  /// Nota média dos usuários no IMDb (de 0 a 10).
  final String imdbRating;

  /// Quantidade total de votos registrados no IMDb.
  final String imdbVotes;

  /// Identificador único IMDb (ex: "tt0111161").
  final String imdbId;

  /// Tipo da produção: "movie", "series" ou "episode".
  final String type;

  /// Quantidade total de temporadas.
  ///
  /// Esse campo normalmente existe apenas quando a obra é uma série.
  final String? totalSeasons;

  /// Temporada à qual o episódio pertence (quando [type] é `episode`).
  final String? season;

  /// Número do episódio dentro da temporada (quando [type] é `episode`).
  final String? episode;

  /// Construtor que inicializa todos os dados detalhados da obra cinematográfica.
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
    this.season,
    this.episode,
  });

  /// Converte o JSON retornado pela OMDb em um objeto [MovieDetails].
  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    final List<dynamic> ratingsJson =
    json['Ratings'] is List ? json['Ratings'] : [];

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
      season: json['Season'],
      episode: json['Episode'],
    );
  }
}