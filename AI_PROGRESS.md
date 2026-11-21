# AI_PROGRESS.md

## Identificação

- **Projeto:** MovieApp
- **Objetivo:** criar uma API REST própria (Python + Flask + JSON) para a coleção pessoal do usuário e integrá-la ao aplicativo Flutter já existente, mantendo a OMDb para pesquisa e detalhes.
- **Repositório Git:** `https://github.com/CezarBovi/MovieApp.git`
- **Branch:** `main` (`749e904` — *ajustes*; working tree limpa)
- **Data desta atualização:** 2026-11-21 (Fase 1)

## Fase atual

**Fase 1 — Desenvolvimento do back-end** — status `[x] Concluída`  
**Não avançar para a Fase 2 sem autorização.**

## Última fase concluída

Fase 1 (API Flask + JSON + testes). Flutter **não** foi modificado.

## Status das fases

| Fase | Descrição | Status |
|------|-----------|--------|
| 0 | Auditoria do projeto | `[x] Concluída` |
| 1 | Desenvolvimento do back-end | `[x] Concluída` |
| 2 | Model e Repository no Flutter | `[ ] Não iniciada` |
| 3 | Integração com o MovieApp | `[ ] Não iniciada` |
| 4 | Testes de integração e correções | `[ ] Não iniciada` |
| 5 | Documentação e apresentação | `[ ] Não iniciada` |

---

## Relatório da Fase 1

### Conferência contrato × `UserMovie`

O rascunho 0.1 usava nomes em português (`imdb_id`, `titulo`, `nota`, `episodios_assistidos`).  
O código real (`user_movie.dart` → `toJson`) usa:

`imdbId`, `title`, `year`, `type`, `poster`, `imdbRating`, `isFavorite`, `isWatched`, `isWishlist`, `userRating`, `watchedEpisodes`, `lastWatchedSeason`, `lastWatchedEpisode`.

**Decisão:** JSON da API = estrutura do `toJson`. Nenhum campo inventado. Contrato atualizado para v1.0.

Remoção vazia = mesma regra de `CollectionService.saveMovie`. PUT vazio remove; DELETE também existe.

Overflow de episódios: **fora desta fase**; nenhum arquivo Flutter alterado.

### Endpoints

- `GET /health`
- `GET /colecao`
- `GET /colecao/<imdbId>`
- `PUT /colecao/<imdbId>` (201 criar, 200 atualizar, 200 `{removido:true}` se ficar vazio)
- `DELETE /colecao/<imdbId>`

Servidor: `python api.py` → `0.0.0.0:5000`, `debug=False`. Sem CORS.

### Testes reais (Fase 1)

```text
cd api_movieapp
.venv\Scripts\python.exe -m pytest tests -v
```

**19 passed in 1.05s** (pytest 8.4.2, Flask 3.1.2, Python 3.11.9).  
`colecao.json` real permaneceu `[]`.

### Arquivos criados

- `api_movieapp/api.py`
- `api_movieapp/persistencia.py`
- `api_movieapp/validacao.py`
- `api_movieapp/colecao.json`
- `api_movieapp/requirements.txt`
- `api_movieapp/README.md`
- `api_movieapp/tests/test_api.py`
- `.gitignore` (raiz: venv, pycache, `.env`)

### Arquivos modificados

- `docs/API_CONTRACT.md` (v1.0, campos do `UserMovie`)
- `AI_PROGRESS.md`

### Arquivos Flutter

Nenhum.

### Pendências

- Fase 2: Repository Dart (JSON já no formato do model).
- Overflow UI (Fase 4).
- `GET /produtos` vs `/colecao` (professor).
- Enunciado original com JSON em português vs contrato v1.0 alinhado ao app — explicar na apresentação.

---

## 1. Organização atual do MovieApp

Raiz do workspace: `MovieApp/`

- `README.md` — documentação acadêmica do Flutter (OMDb + SharedPreferences).
- `movieapp/` — aplicativo Flutter (código em `movieapp/lib/`).
- `api_movieapp/` — API Flask da coleção (Fase 1).
- `docs/API_CONTRACT.md` — contrato v1.0.
- Ainda **não** existe `movieapp/lib/repositories/`.

### Flutter (`movieapp/lib/`)

| Pasta | Papel |
|-------|--------|
| `models/` | Dados OMDb e coleção pessoal |
| `services/` | OMDb (`OmdbService`) e persistência local (`CollectionService`) |
| `screens/` | Telas e navegação |
| `widgets/` | Cabeçalho e painel de episódios |
| `theme/` | Temas Material 3 e `ThemeController` |
| `constants/` | Caminho da logo |

Não há Provider, Riverpod, Bloc nem Repository. Estado: `StatefulWidget` + `FutureBuilder` nas listas; tema via `ValueNotifier` global (`themeController`).

### Telas

- `splash_screen.dart` → `main_navigation_screen.dart` (4 abas)
- Pesquisa → resultados → detalhes (`details_screen.dart`)
- Séries: `series_episodes_panel.dart` + `episode_details_screen.dart`
- Favoritos, já assistidos, lista de desejos recarregam ao voltar da tela de detalhes

### Dependências (`movieapp/pubspec.yaml`)

- `http` — OMDb
- `shared_preferences` — coleção pessoal
- `flutter_dotenv` — chave OMDb (`.env`, **não** versionar)
- `flutter_native_splash`

Pacote `http` já existe; a Fase 2 reutiliza-o. Não adicionar dependências sem necessidade.

---

## 2. Funcionalidades pessoais (como estão)

Tudo passa por `UserMovie` + `CollectionService`. **Não há Repository HTTP.**

| Função | Onde | Persistência |
|--------|------|----------------|
| Favoritar / desfavoritar | `details_screen`, `favorites_screen` | `saveMovie` + `isFavorite` |
| Assistido (filme) | `details_screen`, `watched_screen`, `wishlist_screen` | `isWatched`; se assistido, tira da wishlist |
| Lista de desejos | `details_screen`, `wishlist_screen` | `isWishlist` |
| Nota 1 a 10 | `details_screen` (estrelas); exibida nas listas | `userRating` (`int?`) |
| Episódios de série | painel + tela do episódio | `watchedEpisodes`, `lastWatchedSeason`, `lastWatchedEpisode` |

Regras atuais:

- Filme assistido sai da wishlist.
- Série: progresso por episódio; “já assistidos” inclui `hasEpisodeProgress`.
- Nota só se filme assistido **ou** série com ao menos um episódio marcado.
- Registro some da coleção se não restar favorito, assistido, progresso, wishlist nem nota (`CollectionService.saveMovie`).
- **Não há DELETE explícito** no app; a remoção é implícita ao zerar flags.

OMDb permanece para busca (`s=`), detalhes (`i=` + `plot=full`) e temporadas (`Season=`).

---

## 3. Armazenamento atual

**Confirmado: SharedPreferences**, chave `movie_collection`, JSON array no formato camelCase de `UserMovie.toJson()`.

Não há SQLite, Hive nem API própria.

Campos persistidos hoje:

`imdbId`, `title`, `year`, `type`, `poster`, `imdbRating`, `isFavorite`, `isWatched`, `isWishlist`, `userRating`, `watchedEpisodes`, `lastWatchedSeason`, `lastWatchedEpisode`.

Nota: escala **1 a 10**, inteiro, **nula** se não avaliado. UI não envia string no lugar de bool.

---

## 4. Arquivos que precisarão ser modificados (fases futuras)

**Não alterados nesta Fase 0 (exceto checkpoints):**

- `movieapp/lib/services/collection_service.dart` — Fase 3: deixar de ser a fonte da verdade; passar a chamar o Repository (ou o Repository substitui o service).
- `movieapp/lib/models/user_movie.dart` — Fase 2: mapear JSON da API (pt-BR) ↔ Dart, **sem perder episódios**.
- Telas que chamam `CollectionService`: `details_screen.dart`, `episode_details_screen.dart`, `favorites_screen.dart`, `watched_screen.dart`, `wishlist_screen.dart`.
- `movieapp/android/app/src/main/AndroidManifest.xml` — HTTP local (cleartext) **só em debug**; INTERNET no manifest principal se for build de release.
- `movieapp/.gitignore` e, se criado, `.gitignore` na raiz — venv, `__pycache__`, `colecao.json` de desenvolvimento se não for demo, etc.
- `README.md` da raiz — **não sobrescrever**; complementar na Fase 5.

**Telas de pesquisa/OMDb:** não precisam mudar para a coleção, salvo mensagens se a API própria cair ao salvar.

---

## 5. Arquivos novos previstos

Já criados na Fase 0:

- `AI_PROGRESS.md` (este arquivo)
- `docs/API_CONTRACT.md`

Previstos (Fase 1+), sem duplicar pastas:

```
MovieApp/
  api_movieapp/
    api.py
    colecao.json          (criado em runtime; avaliar gitignore)
    requirements.txt
    tests/
  movieapp/lib/
    config/               (URL base da API)
    repositories/         (HTTP da coleção)
  movieapp/test/          (model + repository)
```

A API fica **ao lado** de `movieapp/`, não dentro do Flutter.

---

## 6. Riscos de integração

1. **Contrato de campos:** o enunciado usa `imdb_id`, `titulo`, `favorito`, `nota`. O app usa `imdbId`, `title`, `isFavorite`, `userRating`. O Repository deve traduzir; o JSON persistido no servidor segue o contrato da API.
2. **Episódios:** o exemplo do enunciado **não** inclui `watchedEpisodes` / último ponto. Sem esses campos a feature de séries quebra. **Decisão proposta:** estender o contrato (ver `docs/API_CONTRACT.md`). Confirmar na Fase 1 se o professor exigir o JSON mínimo literal.
3. **Adaptação da atividade:** material original cita `GET /produtos`. O projeto usa `GET /colecao`. Registrar e **confirmar com o professor** se o enunciado for cobrado ao pé da letra. **Não implementar API de produtos sem autorização.**
4. **Sem autenticação:** uma coleção única. Documentar.
5. **Rede:** emulador `10.0.2.2:5000`; celular físico IP LAN, **não** `localhost`. Flask em `0.0.0.0:5000`, **sem** `debug=True` na rede. Firewall Windows. Android bloqueia HTTP claro por padrão (config **somente debug**).
6. **CORS:** app nativo não usa CORS. Web Flutter sim. **Não** abrir `*` sem necessidade; só origens locais se testarem web.
7. **OMDb `.env`:** nunca logar, commitár ou devolver a chave. A API própria **não** chama a OMDb.
8. **Widget test atual** chama `dotenv.load('.env')`; testes novos não devem depender de chave real.
9. **INTERNET:** só em `debug`/`profile`. Release pode falhar OMDb/API se não for adicionado no manifest main.
10. **Overflow UI:** texto longo de progresso de série (`"N ep. · Temporada X · Episódio Y"`) gerou *RenderFlex overflow ~14px* na lista “Já assistidos”. No código atual de `watched_screen.dart` já há `Expanded` + `ellipsis`. **Verificar no celular na Fase 4**; se persistir, corrigir layout **sem** mudar o design. Não faz parte da Fase 0/1.
11. **Concorrência:** várias telas fazem `getAll` + `save` completos. Na API, PUT deve ser atômico; lock no arquivo JSON.
12. **Migração:** dados só no aparelho. Subir a API vazia **apaga a coleção visível** se o app só ler o servidor. Ver seção 7.
13. **Falha de rede:** hoje `saveMovie` não trata HTTP. Fase 3 precisa de mensagens amigáveis e **não** perder estado local se o PUT falhar (manter cópia até confirmação, ou rollback na UI).

JSON em arquivo é adequado para demo acadêmica; **não** substitui banco com vários usuários.

---

## 7. Migração dos dados locais

Estratégia proposta (executar **somente na Fase 3**, após API estável):

1. Ler SharedPreferences `movie_collection`.
2. Se vazio: não migrar.
3. Se houver itens: `GET /colecao` na API.
   - API vazia → PUT de cada título; só então marcar flag `collection_migrated_v1`.
   - API já com dados **e** local com dados: **não sobrescrever automaticamente**. Parar e pedir orientação (enunciado).
4. **Não apagar** SharedPreferences até confirmar GET equivalente ao local.
5. Após sucesso: local pode ficar como fallback de leitura se a API cair (decisão a fechar na Fase 3). Padrão sugerido: API é fonte da verdade **depois** da migração; local só cache/migração.

Se a API estiver offline na primeira abertura pós-integração: mostrar erro e **não** apagar local.

---

## 8. Planejamento das próximas fases

### Fase 1 — Back-end (após autorização)

- Criar `api_movieapp/` com Flask, `colecao.json`, gravação atômica + lock, validações, `/health`, CRUD `/colecao`.
- Testes pytest/Flask com arquivo temporário.
- `debug=False` ao publicar na LAN.
- Atualizar este arquivo e **parar**.

### Fase 2 — Flutter model + repository (sem ligar todas as telas)

- Config central da URL (emulador vs físico, sem IP espalhado).
- `UserMovie` from/to JSON da API.
- Repository HTTP + testes.
- `flutter analyze` e `flutter test`.
- **Parar.**

### Fase 3 — Integração

- Trocar `CollectionService` (ou fazê-lo delegar ao Repository).
- Favoritos, assistidos, wishlist, nota, episódios.
- Migração segura.
- Mensagens se API cair.
- **Parar.**

### Fase 4 — Testes reais (emulador + celular)

- Incluir HTTP cleartext só em debug, se necessário.
- Overflow de episódios, regressões OMDb.
- **Parar.**

### Fase 5 — Docs e roteiro 8–10 min

- Completar README sem apagar o atual.
- Roteiro e perguntas do professor.
- Relatório final.

---

## Arquivos criados (Fase 0)

- `AI_PROGRESS.md`
- `docs/API_CONTRACT.md`

## Arquivos modificados (Fase 0)

- Nenhum arquivo do aplicativo Flutter ou da OMDb.

## Arquivos ainda não modificados (relevantes)

Todo o `movieapp/lib/**`, `pubspec.yaml`, Android/iOS, `README.md` da raiz (conteúdo original preservado).

## Funcionalidades concluídas

- Auditoria (Fase 0).
- API Flask com persistência atômica, validação, DELETE, progresso de séries (Fase 1).
- Testes pytest em JSON temporário.

## Funcionalidades pendentes

- Model/Repository Flutter, integração, testes no celular, documentação de apresentação (Fases 2–5).

## Testes executados (Fase 0)

Comando na pasta `movieapp/`:

- `flutter analyze` → **No issues found** (2026-11-21).
- `flutter test` → **All tests passed** (`test/widget_test.dart`, 1 teste: app chega na pesquisa após a splash).

Fase 1: **19 testes pytest passaram** (`api_movieapp/tests/test_api.py`).  
Ainda não há testes Dart de `UserMovie` / Repository.

O teste de widget depende de `.env` via `main()`; não foi inspecionado o valor da chave.

## Erros conhecidos / débitos

- Overflow de texto na lista de assistidos em séries (relatado no celular; mitigação já presente no código — validar na Fase 4).
- `INTERNET` ausente no `AndroidManifest` principal (só debug/profile).
- README da raiz não cita episódios, splash nem API própria.
- Atividade original `GET /produtos` ≠ `GET /colecao` (confirmar com o professor).

## Decisões técnicas

- API em `MovieApp/api_movieapp/`, Flask 3.1.2, porta 5000, `colecao.json`.
- Coleção única, sem login.
- **JSON = `UserMovie.toJson()`** (camelCase). Nomes em português do enunciado não foram adotados, para não inventar campos nem quebrar o app.
- CORS desligado.
- PUT de registro vazio remove (espelha o Flutter); DELETE explícito disponível.
- `isWatched && isWishlist` → `isWishlist = false`.
- Booleanos e nota: tipos estritos (string `"true"` / `"9"` rejeitados; `bool` não conta como `int`).
- Sem `debug=True` na LAN.

## Problemas que precisam de orientação (se o professor discordar)

- JSON mínimo do enunciado vs campos de episódios.
- Exigência literal de `GET /produtos`.
- Conflito de migração local × remoto.

## Próxima ação exata

**Aguardar autorização para a Fase 2** (Model + Repository no Flutter, sem religar todas as telas).  
Não alterar a API salvo correção pedida.

## Regras para o próximo agente

1. Ler este arquivo e `docs/API_CONTRACT.md` v1.0.
2. Não repetir a Fase 1.
3. Não iniciar a Fase 2 sem o usuário pedir.
4. Não executar duas fases ao mesmo tempo.
5. Não fazer commit/push sem autorização.
6. Não alterar telas Flutter na Fase 2 além do necessário para model/repository/testes.
