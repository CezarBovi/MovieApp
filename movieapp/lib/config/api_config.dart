import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configurações centrais da API própria da coleção do MovieApp.
///
/// Centraliza as URLs da API REST Flask para evitar que endereços
/// de rede fiquem espalhados pelo aplicativo.
class ApiConfig {
  /// URL padrão para execução no emulador oficial do Android.
  /// O endereço 10.0.2.2 mapeia para o localhost da máquina hospedeira.
  static const String defaultEmulatorUrl = 'http://10.0.2.2:5000';

  /// URL padrão para execução em ambiente desktop, testes ou web local.
  static const String defaultLocalhostUrl = 'http://127.0.0.1:5000';

  static String _baseUrl = defaultEmulatorUrl;

  /// Retorna a URL base atualmente ativa (sempre sem barra final).
  static String get baseUrl => _baseUrl;

  /// Atualiza a URL base da API (remove eventuais barras no final).
  static set baseUrl(String url) {
    _baseUrl = _normalizeUrl(url);
  }

  /// Remove espaços e barras finais da URL informada.
  static String _normalizeUrl(String url) {
    var trimmed = url.trim();
    while (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  /// Restaura a URL base para o padrão do emulador Android.
  static void reset() {
    _baseUrl = defaultEmulatorUrl;
  }

  /// Permite carregar a URL base a partir da variável `API_BASE_URL` no `.env`, se configurada.
  static void configureFromEnv() {
    try {
      if (dotenv.isInitialized) {
        final envUrl = dotenv.env['API_BASE_URL'];
        if (envUrl != null && envUrl.trim().isNotEmpty) {
          baseUrl = envUrl;
        }
      }
    } catch (_) {
      // Ignora silenciosamente caso o dotenv não esteja disponível no momento
    }
  }

  /// Endpoint de verificação de integridade do serviço (`GET /health`).
  static Uri get healthUri => Uri.parse('$_baseUrl/health');

  /// Endpoint da coleção completa (`GET /colecao`).
  static Uri get collectionUri => Uri.parse('$_baseUrl/colecao');

  /// Endpoint para um título específico na coleção (`GET`, `PUT`, `DELETE /colecao/<imdbId>`).
  static Uri movieUri(String imdbId) => Uri.parse('$_baseUrl/colecao/$imdbId');
}
