import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movieapp/main.dart';

/// Verifica se a estrutura principal do MovieApp é carregada corretamente após a Splash Screen.
void main() {
  testWidgets(
    'MovieApp inicia na tela de pesquisa após a splash',
    (WidgetTester tester) async {
      // Constrói o widget da aplicação
      await tester.pumpWidget(const MovieApp());

      // Avança o tempo para permitir que a SplashScreen complete seu delay e navegue para a tela principal
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      // Valida a presença dos elementos principais da tela de pesquisa
      expect(find.text('Busca cinematográfica'), findsOneWidget);
      expect(find.text('Pesquisar'), findsWidgets);
      expect(find.byType(NavigationBar), findsOneWidget);
    },
  );
}