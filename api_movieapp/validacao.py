"""Validação do registro da coleção, alinhada a UserMovie.toJson()."""

from __future__ import annotations

import re

IMDB_ID_PADRAO = re.compile(r"^tt\d{7,}$")
EPISODIO_CHAVE_PADRAO = re.compile(r"^\d+:\d+$")

CAMPOS_STRING_OBRIGATORIOS = ("imdbId", "title", "year", "type", "poster")
CAMPOS_BOOL_OBRIGATORIOS = ("isFavorite", "isWatched", "isWishlist")
CAMPOS_PERMITIDOS = frozenset(
    {
        "imdbId",
        "title",
        "year",
        "type",
        "poster",
        "imdbRating",
        "isFavorite",
        "isWatched",
        "isWishlist",
        "userRating",
        "watchedEpisodes",
        "lastWatchedSeason",
        "lastWatchedEpisode",
    }
)


class ErroValidacao(Exception):
    def __init__(self, mensagem: str, codigo: str = "VALIDACAO") -> None:
        super().__init__(mensagem)
        self.mensagem = mensagem
        self.codigo = codigo


def validar_imdb_id(imdb_id: str) -> str:
    if not isinstance(imdb_id, str) or not imdb_id.strip():
        raise ErroValidacao("O IMDb ID é obrigatório.")
    identificador = imdb_id.strip()
    if not IMDB_ID_PADRAO.fullmatch(identificador):
        raise ErroValidacao("O IMDb ID deve estar no formato tt seguido de dígitos.")
    return identificador


def registro_esta_vazio(item: dict) -> bool:
    """Mesma regra de CollectionService.saveMovie no Flutter."""
    episodios = item.get("watchedEpisodes") or []
    return (
        item.get("isFavorite") is False
        and item.get("isWatched") is False
        and item.get("isWishlist") is False
        and item.get("userRating") is None
        and len(episodios) == 0
    )


def validar_registro(dados: object, imdb_id_url: str) -> dict:
    if not isinstance(dados, dict):
        raise ErroValidacao("O corpo da requisição deve ser um objeto JSON.", "JSON_INVALIDO")

    extras = set(dados.keys()) - CAMPOS_PERMITIDOS
    if extras:
        raise ErroValidacao("O registro contém campos não reconhecidos.")

    identificador_url = validar_imdb_id(imdb_id_url)

    if "imdbId" not in dados:
        raise ErroValidacao("O campo imdbId é obrigatório.")
    identificador_corpo = validar_imdb_id(dados["imdbId"])
    if identificador_corpo != identificador_url:
        raise ErroValidacao("O IMDb ID da URL deve ser igual ao do registro.")

    for campo in CAMPOS_STRING_OBRIGATORIOS:
        valor = dados.get(campo)
        if not isinstance(valor, str):
            raise ErroValidacao(f"O campo {campo} deve ser uma string.")
        if campo == "imdbId":
            continue
        if campo in ("title", "year", "type") and not valor.strip():
            raise ErroValidacao(f"O campo {campo} não pode ficar vazio.")

    for campo in CAMPOS_BOOL_OBRIGATORIOS:
        if campo not in dados:
            raise ErroValidacao(f"O campo {campo} é obrigatório.")
        if type(dados[campo]) is not bool:
            raise ErroValidacao(f"O campo {campo} deve ser um valor booleano.")

    if "userRating" not in dados:
        raise ErroValidacao("O campo userRating é obrigatório (use null se não houver nota).")
    nota = dados["userRating"]
    if nota is not None:
        if type(nota) is not int:
            raise ErroValidacao("A nota pessoal deve ser um inteiro de 1 a 10 ou null.")
        if nota < 1 or nota > 10:
            raise ErroValidacao("A nota pessoal deve estar entre 1 e 10.")

    imdb_rating = dados.get("imdbRating", "")
    if not isinstance(imdb_rating, str):
        raise ErroValidacao("O campo imdbRating deve ser uma string.")

    episodios = dados.get("watchedEpisodes", [])
    if not isinstance(episodios, list):
        raise ErroValidacao("O campo watchedEpisodes deve ser uma lista.")
    episodios_normalizados: list[str] = []
    for item in episodios:
        if not isinstance(item, str) or not EPISODIO_CHAVE_PADRAO.fullmatch(item):
            raise ErroValidacao(
                "Cada episódio assistido deve ser uma string no formato temporada:episodio."
            )
        if item not in episodios_normalizados:
            episodios_normalizados.append(item)

    ultima_temporada = dados.get("lastWatchedSeason")
    ultimo_episodio = dados.get("lastWatchedEpisode")
    if ultima_temporada is not None and type(ultima_temporada) is not int:
        raise ErroValidacao("O campo lastWatchedSeason deve ser um inteiro ou null.")
    if ultimo_episodio is not None and type(ultimo_episodio) is not int:
        raise ErroValidacao("O campo lastWatchedEpisode deve ser um inteiro ou null.")
    if ultima_temporada is not None and ultima_temporada < 1:
        raise ErroValidacao("O campo lastWatchedSeason deve ser maior que zero.")
    if ultimo_episodio is not None and ultimo_episodio < 1:
        raise ErroValidacao("O campo lastWatchedEpisode deve ser maior que zero.")

    is_favorite = dados["isFavorite"]
    is_watched = dados["isWatched"]
    is_wishlist = dados["isWishlist"]
    if is_watched and is_wishlist:
        is_wishlist = False

    return {
        "imdbId": identificador_corpo,
        "title": dados["title"].strip(),
        "year": dados["year"].strip(),
        "type": dados["type"].strip(),
        "poster": dados["poster"],
        "imdbRating": imdb_rating,
        "isFavorite": is_favorite,
        "isWatched": is_watched,
        "isWishlist": is_wishlist,
        "userRating": nota,
        "watchedEpisodes": episodios_normalizados,
        "lastWatchedSeason": ultima_temporada,
        "lastWatchedEpisode": ultimo_episodio,
    }
