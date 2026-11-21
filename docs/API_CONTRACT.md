# Contrato da API REST — MovieApp

**Status:** implementado na Fase 1.  
**Versão do contrato:** 1.0

Fonte dos campos: `movieapp/lib/models/user_movie.dart` (`toJson` / `fromJson`).  
Os nomes em português da proposta 0.1 **não** são usados no JSON: a Fase 1 segue a estrutura real do app, sem campos inventados.

---

## 1. Objetivo

API própria para a **coleção pessoal** (favoritos, assistidos, lista de desejos, nota e progresso de episódios).

A **OMDb** continua exclusiva do Flutter. Esta API **não** consulta a OMDb e **não** armazena a chave `.env`.

## 2. Adaptação da atividade (`GET /produtos`)

| Atividade genérica | MovieApp |
|--------------------|----------|
| `GET /produtos` | `GET /colecao` |

Confirmar com o professor se a rubrica exigir `GET /produtos` ao pé da letra. **Não** há endpoint de produtos.

## 3. Limitações

- Sem autenticação: **uma única coleção** em `colecao.json`.
- JSON em arquivo é adequado à demo acadêmica; não substitui banco em produção.
- Uso apenas em rede local. `debug=False` ao publicar na LAN.

## 4. Servidor

| Item | Valor |
|------|--------|
| Pasta | `api_movieapp/` |
| Entrada | `python api.py` |
| Host | `0.0.0.0` |
| Porta | `5000` |
| Persistência | `api_movieapp/colecao.json` |
| Debug na LAN | `False` |
| CORS | não habilitado |

## 5. Campos JSON (iguais ao `UserMovie`)

Identificador: `imdbId`, formato `tt` + 7 ou mais dígitos.

| Campo | Tipo | PUT | Notas |
|-------|------|-----|--------|
| `imdbId` | string | obrigatório | Deve coincidir com a URL |
| `title` | string | obrigatório | |
| `year` | string | obrigatório | |
| `type` | string | obrigatório | `movie`, `series`, … |
| `poster` | string | obrigatório | pode ser vazio ou `N/A` |
| `imdbRating` | string | opcional, default `""` | |
| `isFavorite` | boolean | obrigatório | **não** aceita `"true"` |
| `isWatched` | boolean | obrigatório | |
| `isWishlist` | boolean | obrigatório | se `isWatched` e `isWishlist` forem true, grava `isWishlist: false` (igual ao Flutter) |
| `userRating` | int ou `null` | obrigatório (`null` permitido) | inteiro **1–10** ou `null` |
| `watchedEpisodes` | array de string | opcional, default `[]` | `"temporada:episodio"`, ex. `"2:5"` |
| `lastWatchedSeason` | int ou `null` | opcional | |
| `lastWatchedEpisode` | int ou `null` | opcional | |

Campos extra no JSON são rejeitados.

### Remoção vazia (igual `CollectionService`)

Um título é considerado vazio quando:

`isFavorite == false` **e** `isWatched == false` **e** `isWishlist == false` **e** `userRating == null` **e** `watchedEpisodes` vazio.

- **PUT** de registro vazio: remove se existir; responde `200` `{"removido": true, "imdbId": "..."}`.
- **DELETE** `/colecao/<imdbId>`: remove explicitamente (`200` ou `404`).

### Exemplo (série)

```json
{
  "imdbId": "tt0903747",
  "title": "Breaking Bad",
  "year": "2008–2013",
  "type": "series",
  "poster": "https://exemplo.com/poster.jpg",
  "imdbRating": "9.5",
  "isFavorite": true,
  "isWatched": false,
  "isWishlist": false,
  "userRating": 9,
  "watchedEpisodes": ["1:1", "1:2"],
  "lastWatchedSeason": 1,
  "lastWatchedEpisode": 2
}
```

## 6. Endpoints

Erros:

```json
{ "erro": "mensagem", "codigo": "VALIDACAO" }
```

Códigos: `VALIDACAO`, `NAO_ENCONTRADO`, `JSON_INVALIDO`, `SERVIDOR`. Sem caminhos de arquivo nem traceback.

### `GET /health` → 200

```json
{ "status": "ok", "servico": "movieapp-colecao" }
```

### `GET /colecao` → 200 (array)

### `GET /colecao/<imdbId>` → 200 | 404 | 400

### `PUT /colecao/<imdbId>` → 201 (criado) | 200 (atualizado ou removido por ficar vazio) | 400 | 500

### `DELETE /colecao/<imdbId>` → 200 | 404 | 400

```json
{ "removido": true, "imdbId": "tt0133093" }
```

## 7. Persistência

- Cria `colecao.json` como `[]` se não existir.
- Gravação atômica (arquivo temporário + `os.replace`) com lock.
- Caminho definido no servidor (`create_app`), nunca pelo cliente.

## 8. Exemplos HTTP

```http
GET /health
GET /colecao
PUT /colecao/tt0133093
Content-Type: application/json

{ ...registro completo... }

GET /colecao/tt0133093
DELETE /colecao/tt0133093
```

## 9. Fora de escopo

Login, proxy OMDb, HTTPS, `/produtos`, integração Flutter (Fase 2).
