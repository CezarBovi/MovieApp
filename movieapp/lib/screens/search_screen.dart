import 'package:flutter/material.dart';

import '../widgets/app_header.dart';
import 'results_screen.dart';

/// Tela principal de pesquisa do MovieApp.
///
/// Permite pesquisar filmes e séries pela OMDb,
/// acessar pesquisas populares e visualizar
/// um destaque cinematográfico.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  /// Controla o conteúdo digitado na pesquisa.
  final TextEditingController _searchController =
      TextEditingController();

  /// Valida o texto digitado e abre a tela de resultados.
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ResultsScreen(
            query: query,
          );
        },
      ),
    );
  }

  /// Executa diretamente uma pesquisa popular.
  void _searchPopular(String title) {
    _searchController.text = title;
    _searchMovie();
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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 760,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              22,
              20,
              22,
              36,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppHeader(
                  subtitle: 'Busca cinematográfica',
                ),

                const SizedBox(height: 48),

                Text(
                  'O que você vai assistir\nhoje à noite?',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: 39,
                    height: 1.03,
                    letterSpacing: -1.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Busque milhões de filmes e séries com o MovieApp.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 30),

                // Campo de pesquisa.
                TextField(
                  controller: _searchController,
                  onSubmitted: (_) {
                    _searchMovie();
                  },
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar filmes ou séries...',
                    prefixIcon: const Icon(
                      Icons.search,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(
                        right: 10,
                      ),
                      child: Center(
                        widthFactor: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius:
                                BorderRadius.circular(6),
                          ),
                          child: Text(
                            '⌘K',
                            style:
                                theme.textTheme.labelSmall,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _searchMovie,
                    icon: const Icon(
                      Icons.search,
                    ),
                    label: const Text(
                      'Pesquisar',
                    ),
                  ),
                ),

                const SizedBox(height: 44),

                Text(
                  'Destaque da noite',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 16),

                _FeaturedMovieCard(
                  onTap: () {
                    _searchPopular('Dune Part Two');
                  },
                ),

                const SizedBox(height: 40),

                Text(
                  'Buscas populares',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 14),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _PopularSearchChip(
                      title: 'Batman',
                      onPressed: () {
                        _searchPopular('Batman');
                      },
                    ),
                    _PopularSearchChip(
                      title: 'The Bear',
                      onPressed: () {
                        _searchPopular('The Bear');
                      },
                    ),
                    _PopularSearchChip(
                      title: 'Oppenheimer',
                      onPressed: () {
                        _searchPopular('Oppenheimer');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cartão utilizado para representar o destaque da página inicial.
///
/// Nesta etapa o destaque é fixo.
/// Ele apenas serve como atalho para pesquisar a obra.
class _FeaturedMovieCard extends StatelessWidget {
  final VoidCallback onTap;

  const _FeaturedMovieCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary,
              width: 1.4,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    'DESTAQUE DO EDITOR',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                'Dune: Part Two',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                '2024 · Filme · 2h 46m',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 18),

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
                    label: Text(
                      'Aventura',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_forward,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botão reutilizável para pesquisas populares.
class _PopularSearchChip extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const _PopularSearchChip({
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(
        Icons.trending_up,
        size: 17,
      ),
      label: Text(title),
      onPressed: onPressed,
    );
  }
}