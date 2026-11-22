
"""API REST da coleção pessoal do MovieApp."""

from __future__ import annotations

from pathlib import Path
from urllib.parse import urlsplit

from flask import Flask, jsonify, request
from werkzeug.exceptions import BadRequest

from persistencia import ErroPersistencia, gravar_colecao, ler_colecao
from validacao import ErroValidacao, registro_esta_vazio, validar_imdb_id, validar_registro

CAMINHO_PADRAO = Path(__file__).resolve().parent / "colecao.json"


def _resposta_erro(mensagem: str, codigo: str, status: int):
    return jsonify({"erro": mensagem, "codigo": codigo}), status


def create_app(caminho_colecao: str | Path | None = None) -> Flask:
    """Fábrica da aplicação. Testes passam um JSON temporário."""
    app = Flask(__name__)
    arquivo = Path(caminho_colecao) if caminho_colecao else CAMINHO_PADRAO
    app.config["CAMINHO_COLECAO"] = arquivo

    # Permite requisições do Flutter Web executado localmente.
    @app.after_request
    def adicionar_cors(resposta):
        origem = request.headers.get("Origin")

        if origem:
            partes = urlsplit(origem)
            host_permitido = partes.hostname in ("localhost", "127.0.0.1")

            if partes.scheme == "http" and host_permitido:
                resposta.headers["Access-Control-Allow-Origin"] = origem
                resposta.headers["Vary"] = "Origin"
                resposta.headers["Access-Control-Allow-Methods"] = (
                    "GET, PUT, DELETE, OPTIONS"
                )
                resposta.headers["Access-Control-Allow-Headers"] = (
                    "Content-Type, Authorization"
                )
                resposta.headers["Access-Control-Max-Age"] = "600"

        return resposta

    @app.get("/health")
    def health():
        return jsonify({"status": "ok", "servico": "movieapp-colecao"})

    @app.get("/colecao")
    def listar_colecao():
        try:
            itens = ler_colecao(arquivo)
        except ErroPersistencia:
            return _resposta_erro("Não foi possível ler a coleção.", "SERVIDOR", 500)
        return jsonify(itens)

    @app.get("/colecao/<imdb_id>")
    def obter_titulo(imdb_id: str):
        try:
            identificador = validar_imdb_id(imdb_id)
        except ErroValidacao as erro:
            return _resposta_erro(erro.mensagem, erro.codigo, 400)

        try:
            itens = ler_colecao(arquivo)
        except ErroPersistencia:
            return _resposta_erro("Não foi possível ler a coleção.", "SERVIDOR", 500)

        for item in itens:
            if item.get("imdbId") == identificador:
                return jsonify(item)
        return _resposta_erro("Título não encontrado na coleção.", "NAO_ENCONTRADO", 404)

    @app.put("/colecao/<imdb_id>")
    def salvar_titulo(imdb_id: str):
        try:
            dados = request.get_json(force=False, silent=False)
        except BadRequest:
            return _resposta_erro("O corpo da requisição não é um JSON válido.", "JSON_INVALIDO", 400)

        if dados is None:
            return _resposta_erro("O corpo da requisição não é um JSON válido.", "JSON_INVALIDO", 400)

        try:
            registro = validar_registro(dados, imdb_id)
        except ErroValidacao as erro:
            status = 400
            return _resposta_erro(erro.mensagem, erro.codigo, status)

        try:
            itens = ler_colecao(arquivo)
        except ErroPersistencia:
            return _resposta_erro("Não foi possível ler a coleção.", "SERVIDOR", 500)

        indice = next(
            (i for i, item in enumerate(itens) if item.get("imdbId") == registro["imdbId"]),
            -1,
        )
        existia = indice != -1

        if registro_esta_vazio(registro):
            if existia:
                itens.pop(indice)
                try:
                    gravar_colecao(arquivo, itens)
                except ErroPersistencia:
                    return _resposta_erro(
                        "Não foi possível salvar a coleção.",
                        "SERVIDOR",
                        500,
                    )
            return jsonify({"removido": True, "imdbId": registro["imdbId"]}), 200

        if existia:
            itens[indice] = registro
            status = 200
        else:
            itens.append(registro)
            status = 201

        try:
            gravar_colecao(arquivo, itens)
        except ErroPersistencia:
            return _resposta_erro("Não foi possível salvar a coleção.", "SERVIDOR", 500)

        return jsonify(registro), status

    @app.delete("/colecao/<imdb_id>")
    def remover_titulo(imdb_id: str):
        try:
            identificador = validar_imdb_id(imdb_id)
        except ErroValidacao as erro:
            return _resposta_erro(erro.mensagem, erro.codigo, 400)

        try:
            itens = ler_colecao(arquivo)
        except ErroPersistencia:
            return _resposta_erro("Não foi possível ler a coleção.", "SERVIDOR", 500)

        indice = next(
            (i for i, item in enumerate(itens) if item.get("imdbId") == identificador),
            -1,
        )
        if indice == -1:
            return _resposta_erro("Título não encontrado na coleção.", "NAO_ENCONTRADO", 404)

        itens.pop(indice)
        try:
            gravar_colecao(arquivo, itens)
        except ErroPersistencia:
            return _resposta_erro("Não foi possível salvar a coleção.", "SERVIDOR", 500)

        return jsonify({"removido": True, "imdbId": identificador}), 200

    return app


app = create_app()


if __name__ == "__main__":
    # debug=False: a API será usada na rede local de demonstração.
    app.run(host="0.0.0.0", port=5000, debug=False)
