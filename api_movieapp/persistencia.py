"""Leitura e gravação atômica da coleção em JSON."""

from __future__ import annotations

import json
import os
import tempfile
import threading
from pathlib import Path

_lock = threading.Lock()


class ErroPersistencia(Exception):
    """Falha ao ler ou gravar a coleção, sem expor caminhos ao cliente."""


def garantir_arquivo(caminho: Path) -> None:
    """Cria o arquivo com uma lista vazia se ele ainda não existir."""
    caminho.parent.mkdir(parents=True, exist_ok=True)
    if not caminho.exists():
        _gravar_lista(caminho, [])


def ler_colecao(caminho: Path) -> list[dict]:
    garantir_arquivo(caminho)
    with _lock:
        try:
            with caminho.open(encoding="utf-8") as arquivo:
                dados = json.load(arquivo)
        except json.JSONDecodeError as erro:
            raise ErroPersistencia("Não foi possível ler a coleção.") from erro
        except OSError as erro:
            raise ErroPersistencia("Não foi possível ler a coleção.") from erro

    if not isinstance(dados, list):
        raise ErroPersistencia("Não foi possível ler a coleção.")
    return dados


def gravar_colecao(caminho: Path, itens: list[dict]) -> None:
    with _lock:
        try:
            _gravar_lista(caminho, itens)
        except OSError as erro:
            raise ErroPersistencia("Não foi possível salvar a coleção.") from erro


def _gravar_lista(caminho: Path, itens: list[dict]) -> None:
    diretorio = caminho.parent
    diretorio.mkdir(parents=True, exist_ok=True)
    descritor, temporario = tempfile.mkstemp(
        prefix="colecao-",
        suffix=".tmp",
        dir=str(diretorio),
    )
    try:
        with os.fdopen(descritor, "w", encoding="utf-8") as arquivo:
            json.dump(itens, arquivo, ensure_ascii=False, indent=2)
            arquivo.write("\n")
            arquivo.flush()
            os.fsync(arquivo.fileno())
        os.replace(temporario, caminho)
    except Exception:
        if os.path.exists(temporario):
            os.remove(temporario)
        raise
