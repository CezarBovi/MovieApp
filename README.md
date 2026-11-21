# MovieApp

Aplicativo desenvolvido em **Flutter** para pesquisa, consulta e organização de filmes e séries, integrado a uma **API REST própria em Python (Flask)** e à **OMDb API**.

O aplicativo utiliza a **OMDb API** para obter informações públicas sobre as obras e uma **API REST própria** para persistir as listas, avaliações pessoais e o progresso de episódios do usuário, contando ainda com cache local e resiliência offline via **SharedPreferences**.

---

## Funcionalidades

* **Pesquisar filmes e séries por título:** consulta ao vivo na OMDb API.
* **Exibir resultados detalhados:** pôster, título, ano, tipo e classificação.
* **Consultar detalhes completos:** sinopse, elenco, diretor, prêmios, notas públicas e temporadas.
* **Controle de episódios de séries:** marcação de episódios assistidos e ponto de retomada ("Continuar de onde parou").
* **Gerenciamento de listas pessoais:**
  * Adicionar e remover dos **Favoritos**.
  * Marcar obras como **Assistidas**.
  * Adicionar à **Lista de desejos** (obras assistidas saem automaticamente da wishlist).
  * Avaliar obras com nota pessoal de **1 a 10** (habilitada para filmes assistidos ou séries com progresso).
* **Sincronização em nuvem / API própria:** persistência centralizada através da API Flask.
* **Modo offline e resiliência:** caso o servidor esteja inacessível, o aplicativo opera normalmente através do cache local em `SharedPreferences` e avisa o usuário.
* **Migração transparente:** migração automática e segura dos dados armazenados previamente no dispositivo para a API própria.
* **Tema dinâmico:** alternância instantânea entre tema claro e escuro.

---

## Tecnologias utilizadas

* **Flutter & Dart:** aplicativo móvel multiplataforma.
* **Python & Flask:** API REST própria para persistência da coleção pessoal.
* **OMDb API:** API externa para dados públicos de obras e episódios.
* **HTTP:** comunicação REST tanto com a OMDb quanto com o back-end próprio.
* **SharedPreferences:** cache local e mecanismo de fallback offline.
* **JSON:** formato padronizado de troca de dados.
* **Pytest:** suíte de testes automatizados do back-end (19 testes).
* **Flutter Test:** suíte de testes unitários e de integração do front-end (43 testes).

---

## Arquitetura da Solução

```text
┌────────────────────────────────────────────────────────┐
│                   MovieApp (Flutter)                   │
├──────────────────────────┬─────────────────────────────┤
│      Busca e Detalhes    │       Coleção Pessoal       │
│        (Público)         │          (Privado)          │
└────────────┬─────────────┴──────────────┬──────────────┘
             │                            │
             ▼                            ▼
      ┌──────────────┐          ┌───────────────────┐
      │   OMDb API   │          │  CollectionService│
      │  (omdbapi)   │          └─────────┬─────────┘
      └──────────────┘                    │
                         ┌────────────────┴────────────────┐
                         ▼                                 ▼
               ┌────────────────────┐            ┌───────────────────┐
               │CollectionRepository│            │ SharedPreferences │
               │     (HTTP REST)    │            │  (Cache Local)    │
               └─────────┬──────────┘            └───────────────────┘
                         │
                         ▼
               ┌────────────────────┐
               │    API MovieApp    │
               │   (Flask :5000)    │
               └─────────┬──────────┘
                         │
                         ▼
               ┌────────────────────┐
               │    colecao.json    │
               └────────────────────┘
```

---

## 1. API REST Própria (Python + Flask)

A API da coleção está localizada no diretório `api_movieapp/` e é responsável pelo armazenamento dos dados pessoais.

### Endpoints da API

| Método | Rota | Descrição | Status Sucesso |
|--------|------|-----------|----------------|
| `GET` | `/health` | Verificação de integridade do serviço | `200 OK` |
| `GET` | `/colecao` | Lista todos os títulos da coleção pessoal | `200 OK` |
| `GET` | `/colecao/<imdbId>` | Obtém os dados pessoais de um título específico | `200 OK` (ou `404`) |
| `PUT` | `/colecao/<imdbId>` | Adiciona ou atualiza um título (remove se ficar vazio) | `201 Created` / `200 OK` |
| `DELETE` | `/colecao/<imdbId>` | Remove explicitamente um título da coleção | `200 OK` (ou `404`) |

### Estrutura do JSON (`UserMovie`)

O payload JSON utiliza identificadores em *camelCase*, rigorosamente alinhados ao modelo do Flutter:

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
  "userRating": 10,
  "watchedEpisodes": ["1:1", "1:2", "1:3"],
  "lastWatchedSeason": 1,
  "lastWatchedEpisode": 3
}
```

*Regra de negócio:* Se um registro for salvo com todas as interações vazias (`isFavorite: false`, `isWatched: false`, `isWishlist: false`, `userRating: null` e sem episódios), a API remove automaticamente o registro do arquivo e retorna `{"removido": true}`.

### Como executar a API

1. Abra um terminal na pasta da API:
   ```bash
   cd api_movieapp
   ```
2. Crie e ative o ambiente virtual:
   ```bash
   python -m venv .venv
   # Windows:
   .venv\Scripts\activate
   # Linux / macOS:
   source .venv/bin/activate
   ```
3. Instale as dependências:
   ```bash
   pip install -r requirements.txt
   ```
4. Inicie o servidor:
   ```bash
   python api.py
   ```
   O servidor iniciará em `0.0.0.0:5000` (acessível no computador, no emulador Android e em celulares na mesma rede local).

---

## 2. Aplicativo Flutter

### Organização do Código (`movieapp/lib/`)

* **`config/`:** `ApiConfig` centraliza as URLs base (emulador `10.0.2.2:5000`, desktop/web `127.0.0.1:5000` e IP local via `.env`).
* **`models/`:** Modelos de dados (`UserMovie`, `MovieDetails`, `MovieSummary`, `Rating`, `EpisodeSummary`, `SeasonDetails`).
* **`repositories/`:** `CollectionRepository` realiza requisições HTTP REST com tratamento tipado de exceções (`CollectionNetworkException`, `CollectionValidationException`, etc.).
* **`services/`:**
  * `OmdbService`: pesquisa e detalhes de obras na OMDb.
  * `CollectionService`: coordena as chamadas ao repositório, realiza migração de dados antigos do SharedPreferences e gerencia o cache local para fallback offline.
* **`screens/`:** Telas da aplicação (`SearchScreen`, `ResultsScreen`, `DetailsScreen`, `EpisodeDetailsScreen`, `FavoritesScreen`, `WatchedScreen`, `WishlistScreen`, `SplashScreen`, `MainNavigationScreen`).
* **`widgets/`:** Componentes reutilizáveis (cabeçalho, painel de episódios de séries, cartões de filmes).
* **`theme/`:** Tema visual Material 3 e `ThemeController`.

### Como executar o aplicativo

1. No terminal, entre na pasta do app Flutter:
   ```bash
   cd movieapp
   ```
2. Instale os pacotes:
   ```bash
   flutter pub get
   ```
3. Configure o arquivo `.env`:
   Crie o arquivo `movieapp/.env` baseado no `.env.example`:
   ```env
   OMDB_API_KEY=sua_chave_omdb_aqui
   API_BASE_URL=http://10.0.2.2:5000
   ```
   *Dica de rede:*
   * No **Emulador Android**: utilize `http://10.0.2.2:5000`.
   * No **Celular físico**: utilize o IP do seu computador na rede Wi-Fi (ex.: `http://192.168.1.100:5000`).
   * No **Windows Desktop / Web**: utilize `http://127.0.0.1:5000`.
4. Execute o aplicativo:
   ```bash
   flutter run
   ```

---

## Verificação e Testes

### Testes do Flutter (43 testes)

```bash
cd movieapp
flutter analyze
flutter test
```

* `flutter analyze`: **0 issues** (código limpo, seguindo as diretrizes oficiais de lint do Flutter).
* `flutter test`: **43 testes passando**, cobrindo modelos, serialização, URLs, CRUD do repositório, resiliência offline, migração de dados e ciclo de vida de widgets.

### Testes da API Flask (19 testes)

```bash
cd api_movieapp
pytest tests -v
```

* `pytest`: **19 testes passando**, validando todos os endpoints, regras de consistência, tipagem estrita de dados, persistência atômica e isolamento do arquivo de produção.

---

## Guia de Perguntas e Respostas para a Banca / Professor

### 1. Por que manter duas APIs (OMDb e API própria)?
> **Resposta:** A OMDb é uma API pública global para catálogo (sinopse, elenco, pôsteres). A API própria do MovieApp (Flask) foi construída para atender à exigência de persistência da coleção pessoal do usuário (favoritos, assistidos, wishlist, nota pessoal de 1 a 10 e progresso de episódios de séries). Manter essa separação reflete a arquitetura real de sistemas modernos, onde dados globais de catálogo e dados privados do usuário são desacoplados.

### 2. Por que os campos do JSON estão em inglês (`imdbId`, `title`, etc.) e não em português conforme o exemplo básico da atividade?
> **Resposta:** O contrato da API (v1.0) foi intencionalmente alinhado à estrutura real do model `UserMovie` já existente no app. Criar campos em português no servidor forçaria traduções artificiais e desnecessárias no cliente e colocaria em risco funcionalidades avançadas já consolidadas no aplicativo, como o controle de episódios assistidos de séries (`watchedEpisodes`, `lastWatchedSeason`, `lastWatchedEpisode`). Alinhar a API à modelagem do cliente é uma boa prática da engenharia de software (padrão *Backend-for-Frontend*).

### 3. Por que foi utilizado `/colecao` em vez de `/produtos`?
> **Resposta:** A rota `/produtos` constava no enunciado original genérico da atividade. Adaptamos para `/colecao` para manter a coerência semântica com o domínio da aplicação (catálogo cinematográfico).

### 4. Como funciona o tratamento de erros caso o servidor Flask esteja desligado?
> **Resposta:** O aplicativo possui uma estratégia de fallback resiliente. Caso a API esteja inacessível, o `CollectionService` captura a falha de conexão (`CollectionNetworkException`) e recorre de forma imediata ao cache local armazenado no `SharedPreferences`. O usuário recebe uma notificação sutil na tela (`SnackBar`) informando que a operação foi salva no dispositivo, permitindo continuar utilizando o app mesmo sem conexão com o back-end.

### 5. Como foi realizada a migração dos dados locais existentes?
> **Resposta:** Foi implementada a rotina `ensureMigrated()` no `CollectionService`. Ao abrir o aplicativo, o serviço verifica se os dados locais já foram transferidos. Se a coleção remota estiver vazia e o celular tiver dados locais, eles são sincronizados com o servidor. Se a API estiver offline no momento da abertura, o aplicativo não apaga os dados locais, garantindo tolerância a falhas.

### 6. Como é garantida a integridade do arquivo `colecao.json` contra escritas corrompidas?
> **Resposta:** A API utiliza persistência atômica com thread lock. Toda alteração grava primeiro os dados em um arquivo temporário (`tempfile`) e o substitui atomicamente no sistema de arquivos através de `os.replace`. Dessa forma, mesmo em caso de interrupção abrupta do processo, o arquivo nunca fica corrompido ou parcialmente gravado.

---

## Roteiro de Apresentação (8 a 10 minutos)

| Tempo | Etapa | O que apresentar / demonstrar |
|-------|-------|-------------------------------|
| **00:00 – 01:30** | **Introdução e Escopo** | Apresentar o MovieApp: aplicativo de filmes e séries desenvolvido em Flutter para a disciplina de DSDM, agora expandido com uma API REST própria em Flask para armazenamento centralizado da coleção pessoal. |
| **01:30 – 03:00** | **Arquitetura da Solução** | Explicar o papel da OMDb API (dados públicos) versus a API própria Flask (dados do usuário). Mostrar a organização em `ApiConfig`, `CollectionRepository` e `CollectionService`. |
| **03:00 – 05:30** | **Demonstração Prática: Fluxo Online** | 1. Com a API Flask rodando no terminal, abrir o app.<br>2. Pesquisar um filme (ex.: *The Matrix*) e adicioná-lo aos Favoritos e Assistidos com nota 9.<br>3. Pesquisar uma série (ex.: *Breaking Bad*) e marcar 2 episódios como assistidos.<br>4. Abrir o arquivo `api_movieapp/colecao.json` e mostrar que os registros foram persistidos no servidor em tempo real. |
| **05:30 – 07:30** | **Resiliência Offline e Tratamento de Erros** | 1. Interromper o servidor Flask no terminal (Ctrl+C).<br>2. Realizar uma alteração no app (ex.: desfavoritar ou avaliar).<br>3. Mostrar o feedback visual amigável (`SnackBar`) avisando que o servidor está offline e que o dado foi salvo localmente.<br>4. Reiniciar a API e mostrar que os dados permanecem consistentes. |
| **07:30 – 08:30** | **Qualidade e Testes Automatizados** | Mostrar no terminal a execução de `flutter test` (43 testes passando) e `pytest` (19 testes passando), além do `flutter analyze` sem nenhum aviso. |
| **08:30 – 10:00** | **Conclusão e Perguntas** | Recapitular as decisões de arquitetura (persistência atômica, migração transparente, cache local e tipagem estrita) e abrir para perguntas da banca. |

---

## Segurança

* A chave da OMDb API e a URL base da API própria são gerenciadas através do arquivo `.env` e **não são versionadas no Git**.
* O `.gitignore` protege arquivos `.env`, ambientes virtuais (`.venv/`), caches do Python (`__pycache__/`) e artefatos de compilação.
