# MovieApp

Aplicativo desenvolvido em **Flutter** para pesquisa, consulta e organização de filmes e séries.

O aplicativo utiliza a **OMDb API** para obter informações sobre as obras e armazena localmente as listas e avaliações pessoais do usuário.

## Funcionalidades

* Pesquisar filmes e séries por título
* Exibir resultados com pôster, título, ano e tipo
* Consultar detalhes completos de uma obra
* Adicionar e remover filmes e séries dos favoritos
* Marcar obras como assistidas
* Criar uma lista de desejos
* Avaliar obras com uma nota de **1 a 10**
* Armazenar as informações localmente
* Alternar entre tema claro e escuro
* Exibir mensagens para erros, pesquisas sem resultados e listas vazias

## Tecnologias utilizadas

* **Flutter**
* **Dart**
* **OMDb API**
* **HTTP** para comunicação com a API
* **SharedPreferences** para armazenamento local
* **JSON** para tratamento dos dados
* **flutter_dotenv** para utilização da chave da API

## OMDb API

A [OMDb API](https://www.omdbapi.com/) é responsável por fornecer os dados dos filmes e séries.

Endereço base:

```text
https://www.omdbapi.com/
```

O aplicativo utiliza principalmente duas consultas:

### Pesquisa por título

```text
GET https://www.omdbapi.com/?apikey=SUA_CHAVE&s=Batman
```

O parâmetro `s` realiza a pesquisa e retorna uma lista de obras.

### Consulta de detalhes

```text
GET https://www.omdbapi.com/?apikey=SUA_CHAVE&i=tt0372784&plot=full
```

O parâmetro `i` recebe o **IMDb ID** da obra e retorna suas informações detalhadas.

Entre os dados obtidos estão:

* Título
* Ano
* Pôster
* Gênero
* Diretor
* Roteirista
* Elenco
* Sinopse
* Idioma
* País
* Data de lançamento
* Duração
* Prêmios
* Nota do IMDb
* Quantidade de votos
* Avaliações de outras fontes


### Organização

**models/**
Contém as classes responsáveis por representar os dados recebidos da API e os dados pessoais do usuário.

**screens/**
Contém as telas do aplicativo e o fluxo de navegação.

**services/**
Responsável pela comunicação com a OMDb API e pelo armazenamento local.

**theme/**
Contém as configurações dos temas do aplicativo.

**widgets/**
Contém componentes reutilizáveis da interface.

## Serviços

### OmdbService

Responsável pelas requisições à OMDb API.

Principais métodos:

```dart
searchMovies(query)
```

Pesquisa filmes e séries pelo título.

```dart
getMovieDetails(imdbId)
```

Busca os detalhes de uma obra utilizando seu IMDb ID.

### CollectionService

Responsável pelo armazenamento dos dados pessoais do usuário utilizando **SharedPreferences** em formato JSON.

Principais métodos:

```dart
getAllMovies()
getMovie(imdbId)
saveMovie(movie)
getFavorites()
getWatched()
getWishlist()
```

Quando uma obra é marcada como assistida, ela é automaticamente removida da lista de desejos.

## Modelos principais

### MovieSummary

Representa uma obra encontrada na pesquisa.

Possui informações como:

* título
* ano
* IMDb ID
* tipo
* pôster

### MovieDetails

Representa os dados completos de uma obra.

### Rating

Representa uma avaliação recebida de uma fonte externa.

### UserMovie

Representa a relação entre o usuário e uma obra, armazenando informações como:

* IMDb ID
* título
* ano
* tipo
* pôster
* nota do IMDb
* favorito
* assistido
* lista de desejos
* nota pessoal

## Fluxo do aplicativo

```text
Pesquisa
   ↓
Resultados
   ↓
Detalhes
   ↓
Favoritar / Assistir / Lista de desejos / Avaliar
```

A navegação inferior permite acessar:

* **Pesquisa**
* **Favoritos**
* **Já assistidos**
* **Lista de desejos**

## Tratamento de erros

O aplicativo possui tratamento para diferentes situações, como:

* Campo de pesquisa vazio
* Carregamento dos dados
* Nenhum resultado encontrado
* Erro na requisição
* Resposta inválida da API
* Pôster indisponível
* Informações retornadas como `N/A`
* Listas pessoais vazias

## Como executar o projeto

O projeto foi desenvolvido utilizando **Flutter 3.47.5** e **Dart 3.13.4**.

### 1. Instale as dependências

No terminal, dentro da pasta do projeto:

```bash
flutter pub get
```

### 2. Configure a chave da OMDb API

Crie um arquivo `.env` na raiz do projeto:

```env
OMDB_API_KEY=SUA_CHAVE_AQUI
```

O projeto possui um `.env.example` como modelo.

### 3. Verifique os dispositivos disponíveis

```bash
flutter devices
```

### 4. Execute o aplicativo

```bash
flutter run
```

## Verificação

Para verificar possíveis problemas no código:

```bash
flutter analyze
```

Para executar os testes:

```bash
flutter test
```

## Segurança

A chave da OMDb API deve ser armazenada no arquivo `.env` e **não deve ser enviada para o GitHub**.

O arquivo `.env` deve permanecer no `.gitignore`, enquanto o `.env.example` pode ser disponibilizado no repositório como modelo.


Projeto desenvolvido para a disciplina de **Desenvolvimento para Dispositivos Móveis**.
