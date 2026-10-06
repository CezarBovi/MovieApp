import 'dart:convert';

import '../models/movie_details.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/movie_summary.dart';

/// Serviço responsável pela comunicação com a OMDb API.
///
/// Esta classe concentra as requisições HTTP utilizadas pelo aplicativo,
/// evitando que as telas precisem conhecer diretamente os detalhes da API.
class OmdbService {
  /// Endereço principal da OMDb API.
  static const String _baseUrl = 'https://www.omdbapi.com/';

  /// Pesquisa filmes e séries pelo nome informado.
  ///
  /// [query] representa o texto digitado pelo usuário.
  ///
  /// Retorna uma lista de [MovieSummary].
  /// Caso nenhum resultado seja encontrado, retorna uma lista vazia.
  ///
  /// Pode lançar uma [Exception] caso ocorra um erro de conexão,
  /// configuração ou resposta da API.
  static Future<List<MovieSummary>> searchMovies(String query) async {
    final apiKey = dotenv.env['OMDB_API_KEY'];

    // Verifica se a chave da API foi configurada no arquivo .env.
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Chave da OMDb API não configurada.');
    }

    // Monta a URL utilizando queryParameters para evitar
    // problemas com espaços ou caracteres especiais.
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'apikey': apiKey,
        's': query,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao acessar a OMDb API. Código: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    // A OMDb utiliza "False" quando não encontra resultados
    // ou quando ocorre algum problema na consulta.
    if (data['Response'] == 'False') {
      if (data['Error'] == 'Movie not found!') {
        return [];
      }

      throw Exception(
        data['Error'] ?? 'Erro desconhecido ao pesquisar.',
      );
    }

    final List<dynamic> results = data['Search'] ?? [];

    return results
        .map(
          (movie) => MovieSummary.fromJson(
            movie as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// Busca as informações completas de uma obra utilizando o IMDb ID.
///
/// [imdbId] é o identificador único do filme, série ou episódio
/// fornecido pela própria OMDb.
///
/// Retorna um objeto [MovieDetails] contendo os dados detalhados.
///
/// Pode lançar uma [Exception] caso a obra não seja encontrada
/// ou ocorra algum problema na comunicação com a API.
static Future<MovieDetails> getMovieDetails(String imdbId) async {
  final apiKey = dotenv.env['OMDB_API_KEY'];

  // Garante que a chave da API foi configurada corretamente.
  if (apiKey == null || apiKey.isEmpty) {
    throw Exception('Chave da OMDb API não configurada.');
  }

  // A consulta utiliza o IMDb ID e solicita a sinopse completa.
  final uri = Uri.parse(_baseUrl).replace(
    queryParameters: {
      'apikey': apiKey,
      'i': imdbId,
      'plot': 'full',
    },
  );

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw Exception(
      'Erro ao acessar a OMDb API. Código: ${response.statusCode}',
    );
  }

  final Map<String, dynamic> data = jsonDecode(response.body);

  if (data['Response'] == 'False') {
    throw Exception(
      data['Error'] ?? 'Não foi possível carregar os detalhes.',
    );
  }

  return MovieDetails.fromJson(data);
}
}