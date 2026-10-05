import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movieapp/main.dart';

/// Teste básico para verificar se o aplicativo inicia corretamente.
void main() {
  testWidgets('MovieApp inicia corretamente', (WidgetTester tester) async {
    // Inicializa o widget principal do aplicativo.
    await tester.pumpWidget(const MovieApp());

    // Verifica se o texto da tela inicial está sendo exibido.
    expect(find.text('MovieApp funcionando!'), findsOneWidget);

    // Confirma que a aplicação possui uma estrutura Scaffold.
    expect(find.byType(Scaffold), findsOneWidget);
  });
}