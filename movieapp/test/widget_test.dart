import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movieapp/main.dart';

/// Verifica se a estrutura principal do MovieApp é carregada.
void main() {
  testWidgets(
    'MovieApp inicia na tela de pesquisa',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MovieApp());

      expect(find.text('Busca cinematográfica'), findsOneWidget);
      expect(find.text('Pesquisar'), findsWidgets);
      expect(find.byType(NavigationBar), findsOneWidget);
    },
  );
}