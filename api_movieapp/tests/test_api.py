"""Testes da API de coleção usando arquivo JSON temporário."""

from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

RAIZ_API = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RAIZ_API))

from api import create_app  # noqa: E402

FILME = {
    "imdbId": "tt0133093",
    "title": "Matrix",
    "year": "1999",
    "type": "movie",
    "poster": "https://exemplo.com/poster.jpg",
    "imdbRating": "8.7",
    "isFavorite": True,
    "isWatched": False,
    "isWishlist": True,
    "userRating": 9,
    "watchedEpisodes": [],
    "lastWatchedSeason": None,
    "lastWatchedEpisode": None,
}

SERIE = {
    "imdbId": "tt0903747",
    "title": "Breaking Bad",
    "year": "2008–2013",
    "type": "series",
    "poster": "https://exemplo.com/bb.jpg",
    "imdbRating": "9.5",
    "isFavorite": False,
    "isWatched": False,
    "isWishlist": False,
    "userRating": None,
    "watchedEpisodes": ["1:1", "1:2"],
    "lastWatchedSeason": 1,
    "lastWatchedEpisode": 2,
}


@pytest.fixture
def cliente(tmp_path):
    arquivo = tmp_path / "colecao.json"
    app = create_app(arquivo)
    app.config["TESTING"] = True
    return app.test_client(), arquivo


def test_health(cliente):
    client, _ = cliente
    resposta = client.get("/health")
    assert resposta.status_code == 200
    corpo = resposta.get_json()
    assert corpo["status"] == "ok"
    assert corpo["servico"] == "movieapp-colecao"


def test_colecao_vazia(cliente):
    client, _ = cliente
    resposta = client.get("/colecao")
    assert resposta.status_code == 200
    assert resposta.get_json() == []


def test_criar_titulo(cliente):
    client, _ = cliente
    resposta = client.put("/colecao/tt0133093", json=FILME)
    assert resposta.status_code == 201
    assert resposta.get_json()["title"] == "Matrix"


def test_atualizar_favorito(cliente):
    client, _ = cliente
    client.put("/colecao/tt0133093", json=FILME)
    atualizado = dict(FILME)
    atualizado["isFavorite"] = False
    resposta = client.put("/colecao/tt0133093", json=atualizado)
    assert resposta.status_code == 200
    assert resposta.get_json()["isFavorite"] is False


def test_atualizar_assistido_remove_wishlist(cliente):
    client, _ = cliente
    client.put("/colecao/tt0133093", json=FILME)
    atualizado = dict(FILME)
    atualizado["isWatched"] = True
    atualizado["isWishlist"] = True
    resposta = client.put("/colecao/tt0133093", json=atualizado)
    assert resposta.status_code == 200
    corpo = resposta.get_json()
    assert corpo["isWatched"] is True
    assert corpo["isWishlist"] is False


def test_atualizar_lista_desejos(cliente):
    client, _ = cliente
    client.put("/colecao/tt0133093", json=FILME)
    atualizado = dict(FILME)
    atualizado["isWishlist"] = False
    resposta = client.put("/colecao/tt0133093", json=atualizado)
    assert resposta.status_code == 200
    assert resposta.get_json()["isWishlist"] is False


def test_atualizar_nota(cliente):
    client, _ = cliente
    client.put("/colecao/tt0133093", json=FILME)
    atualizado = dict(FILME)
    atualizado["userRating"] = 10
    resposta = client.put("/colecao/tt0133093", json=atualizado)
    assert resposta.status_code == 200
    assert resposta.get_json()["userRating"] == 10


def test_consultar_titulo_especifico(cliente):
    client, _ = cliente
    client.put("/colecao/tt0133093", json=FILME)
    resposta = client.get("/colecao/tt0133093")
    assert resposta.status_code == 200
    assert resposta.get_json()["imdbId"] == "tt0133093"


def test_progresso_de_serie(cliente):
    client, _ = cliente
    resposta = client.put("/colecao/tt0903747", json=SERIE)
    assert resposta.status_code == 201
    corpo = resposta.get_json()
    assert corpo["watchedEpisodes"] == ["1:1", "1:2"]
    assert corpo["lastWatchedSeason"] == 1
    assert corpo["lastWatchedEpisode"] == 2


def test_put_vazio_remove_titulo(cliente):
    client, _ = cliente
    client.put("/colecao/tt0133093", json=FILME)
    vazio = dict(FILME)
    vazio.update(
        {
            "isFavorite": False,
            "isWatched": False,
            "isWishlist": False,
            "userRating": None,
            "watchedEpisodes": [],
        }
    )
    resposta = client.put("/colecao/tt0133093", json=vazio)
    assert resposta.status_code == 200
    assert resposta.get_json()["removido"] is True
    assert client.get("/colecao/tt0133093").status_code == 404


def test_remover_titulo(cliente):
    client, _ = cliente
    client.put("/colecao/tt0133093", json=FILME)
    resposta = client.delete("/colecao/tt0133093")
    assert resposta.status_code == 200
    assert resposta.get_json()["removido"] is True
    assert client.get("/colecao").get_json() == []


def test_imdb_inexistente_get_e_delete(cliente):
    client, _ = cliente
    assert client.get("/colecao/tt0000001").status_code == 404
    assert client.delete("/colecao/tt0000001").status_code == 404


def test_json_invalido(cliente):
    client, _ = cliente
    resposta = client.put(
        "/colecao/tt0133093",
        data="{nao-json",
        content_type="application/json",
    )
    assert resposta.status_code == 400
    assert resposta.get_json()["codigo"] == "JSON_INVALIDO"


def test_booleano_como_string_rejeitado(cliente):
    client, _ = cliente
    invalido = dict(FILME)
    invalido["isFavorite"] = "true"
    resposta = client.put("/colecao/tt0133093", json=invalido)
    assert resposta.status_code == 400
    assert resposta.get_json()["codigo"] == "VALIDACAO"


def test_nota_fora_do_intervalo(cliente):
    client, _ = cliente
    invalido = dict(FILME)
    invalido["userRating"] = 11
    resposta = client.put("/colecao/tt0133093", json=invalido)
    assert resposta.status_code == 400


def test_nota_string_rejeitada(cliente):
    client, _ = cliente
    invalido = dict(FILME)
    invalido["userRating"] = "9"
    resposta = client.put("/colecao/tt0133093", json=invalido)
    assert resposta.status_code == 400


def test_imdb_url_diferente_do_corpo(cliente):
    client, _ = cliente
    resposta = client.put("/colecao/tt0111161", json=FILME)
    assert resposta.status_code == 400


def test_persistencia_apos_reinicio(tmp_path):
    arquivo = tmp_path / "colecao.json"
    app1 = create_app(arquivo)
    app1.config["TESTING"] = True
    app1.test_client().put("/colecao/tt0133093", json=FILME)

    with arquivo.open(encoding="utf-8") as handle:
        gravado = json.load(handle)
    assert gravado[0]["imdbId"] == "tt0133093"

    app2 = create_app(arquivo)
    app2.config["TESTING"] = True
    resposta = app2.test_client().get("/colecao/tt0133093")
    assert resposta.status_code == 200
    assert resposta.get_json()["title"] == "Matrix"


def test_nao_altera_colecao_real():
    real = RAIZ_API / "colecao.json"
    conteudo_antes = real.read_text(encoding="utf-8")
    assert json.loads(conteudo_antes) == []
