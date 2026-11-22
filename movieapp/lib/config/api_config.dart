
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String defaultEmulatorUrl = 'http://10.0.2.2:5000';

  static const String defaultLocalhostUrl = 'http://127.0.0.1:5000';

  static const String defaultAndroidUrl = 'http://192.168.0.110:5000';

  static String get defaultPlatformUrl {
    return kIsWeb ? defaultLocalhostUrl : defaultAndroidUrl;
  }

  static String _baseUrl = defaultPlatformUrl;

  static String get baseUrl => _baseUrl;

  static set baseUrl(String url) {
    _baseUrl = _normalizeUrl(url);
  }

  static String _normalizeUrl(String url) {
    var trimmed = url.trim();

    while (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }

    return trimmed;
  }

  static void reset() {
    _baseUrl = defaultPlatformUrl;
  }

  static void configureFromEnv() {
    try {
      if (dotenv.isInitialized) {
        final envUrl = dotenv.env['API_BASE_URL'];

        if (envUrl != null && envUrl.trim().isNotEmpty) {
          baseUrl = envUrl;
        } else {
          baseUrl = defaultPlatformUrl;
        }
      }
    } catch (_) {
      baseUrl = defaultPlatformUrl;
    }
  }

  static Uri get healthUri => Uri.parse('$_baseUrl/health');

  static Uri get collectionUri => Uri.parse('$_baseUrl/colecao');

  static Uri movieUri(String imdbId) {
    return Uri.parse('$_baseUrl/colecao/$imdbId');
  }
}
