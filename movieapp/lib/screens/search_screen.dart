import 'package:flutter/material.dart';

import '../widgets/app_header.dart';

/// Tela inicial de pesquisa do MovieApp.
///
/// Permite ao usuário informar o nome de um filme ou série.
/// A integração real com a OMDb será adicionada posteriormente.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  /// Controla o texto digitado na barra de pesquisa.
  final TextEditingController _searchController =
      TextEditingController();

  /// Executa temporariamente a pesquisa.
  ///
  /// Nesta etapa apenas informa o texto pesquisado.
  /// Posteriormente será feita uma requisição à OMDb.
  void _searchMovie() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Digite o nome de um filme ou série.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pesquisando por "$query"...',
        ),
      ),
    );
  }

  /// Insere automaticamente uma pesquisa popular no campo.
  void _selectPopularSearch(String title) {
    _searchController.text = title;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(
              subtitle: 'Busca cinematográfica',
            ),

            const SizedBox(height: 36),

            Text(
              'O que você vai assistir\nhoje à noite?',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.15,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Busque milhões de filmes e séries com o MovieApp.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 26),

            TextField(
              controller: _searchController,
              onSubmitted: (_) => _searchMovie(),
              decoration: const InputDecoration(
                hintText: 'Pesquisar filmes ou séries...',
                prefixIcon: Icon(Icons.search),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _searchMovie,
                icon: const Icon(Icons.search),
                label: const Text(
                  'Pesquisar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 38),

            Text(
              'Destaque da noite',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_movies_outlined,
                        color: theme.colorScheme.primary,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        'DESTAQUE DO EDITOR',
                        style:
                            theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Dune: Part Two',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '2024 · Filme · 2h 46m',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          'Ficção científica',
                        ),
                      ),
                      Chip(
                        label: Text('Aventura'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            Text(
              'Buscas populares',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ActionChip(
                  avatar: const Icon(
                    Icons.trending_up,
                    size: 18,
                  ),
                  label: const Text('Batman'),
                  onPressed: () {
                    _selectPopularSearch('Batman');
                  },
                ),
                ActionChip(
                  avatar: const Icon(
                    Icons.trending_up,
                    size: 18,
                  ),
                  label: const Text('The Bear'),
                  onPressed: () {
                    _selectPopularSearch('The Bear');
                  },
                ),
                ActionChip(
                  avatar: const Icon(
                    Icons.trending_up,
                    size: 18,
                  ),
                  label: const Text('Oppenheimer'),
                  onPressed: () {
                    _selectPopularSearch('Oppenheimer');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}