/// Exceção lançada quando a busca na OMDb retorna mais resultados do que o limite permitido ("Too many results.").
/// Permite que a interface capture esse caso específico e apresente uma tela instrutiva amigável ao usuário.
class SearchTooBroadException implements Exception {
  /// Construtor constante para a exceção de busca excessivamente ampla.
  const SearchTooBroadException();
}

