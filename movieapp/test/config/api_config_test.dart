import 'package:flutter_test/flutter_test.dart';
import 'package:movieapp/config/api_config.dart';

void main() {
  group('ApiConfig', () {
    setUp(() {
      ApiConfig.reset();
    });

    tearDown(() {
      ApiConfig.reset();
    });

    test('Valores padrão de configuração', () {
      expect(ApiConfig.defaultEmulatorUrl, 'http://10.0.2.2:5000');
      expect(ApiConfig.defaultLocalhostUrl, 'http://127.0.0.1:5000');
      expect(ApiConfig.baseUrl, ApiConfig.defaultEmulatorUrl);
    });

    test('Normaliza URLs removendo barras finais e espaços', () {
      ApiConfig.baseUrl = ' http://192.168.1.50:5000/// ';
      expect(ApiConfig.baseUrl, 'http://192.168.1.50:5000');

      ApiConfig.reset();
      expect(ApiConfig.baseUrl, ApiConfig.defaultEmulatorUrl);
    });

    test('Geração correta de URIs para os endpoints', () {
      ApiConfig.baseUrl = 'http://10.0.2.2:5000';

      expect(
        ApiConfig.healthUri,
        Uri.parse('http://10.0.2.2:5000/health'),
      );
      expect(
        ApiConfig.collectionUri,
        Uri.parse('http://10.0.2.2:5000/colecao'),
      );
      expect(
        ApiConfig.movieUri('tt0133093'),
        Uri.parse('http://10.0.2.2:5000/colecao/tt0133093'),
      );
    });
  });
}
