# MovieApp

Aplicativo desenvolvido em Flutter utilizando a OMDb API.

O MovieApp permite pesquisar filmes e séries através da OMDb API.
Durante o desenvolvimento também serão adicionadas funcionalidades
como favoritos, filmes já assistidos, lista de desejos e avaliação pessoal.

---

## Integrantes

- Cezar Bovi
- Bianca Golfe

---

## Tecnologias utilizadas

- Flutter
- Dart
- OMDb API
- HTTP
- flutter_dotenv
- Git
- GitHub

---

## Versões utilizadas

### Ambiente de desenvolvimento

- Flutter: `3.47.5`
- Dart: `3.13.4`
- DevTools: `2.60.0`
- Canal Flutter: `stable`

### Projeto

- Versão do aplicativo: `1.0.0+1`
- SDK Dart utilizado no projeto: `^3.13.4`

### Dependências

Versões declaradas no arquivo `pubspec.yaml`:

- `cupertino_icons: ^1.0.8`
- `flutter_dotenv: ^6.0.1`
- `http: ^1.6.0`

### Dependências de desenvolvimento

- `flutter_lints: ^6.0.0`
- `flutter_test`: fornecido pelo SDK do Flutter

As versões e dependências do projeto também podem ser consultadas nos arquivos:

- `movieapp/pubspec.yaml`
- `movieapp/pubspec.lock`

---

## Funcionalidades implementadas

Atualmente o projeto possui:

- Estrutura inicial do aplicativo em Flutter
- Tema claro
- Tema escuro
- Alternância manual entre os temas
- Navegação entre as principais áreas do aplicativo
- Integração com a OMDb API
- Pesquisa de filmes e séries por nome
- Exibição dos resultados da pesquisa
- Exibição dos pôsteres retornados pela API
- Tratamento de pesquisas sem resultados
- Tratamento básico de erros

---

## Funcionalidades planejadas

Ainda serão implementadas:

- Tela completa de detalhes do filme
- Favoritos
- Filmes já assistidos
- Lista de desejos
- Nota pessoal de 1 a 10
- Armazenamento local dos dados
- Ajustes visuais conforme o wireframe

Para acompanhar o andamento do projeto, consulte:

`PENDENCIAS.md`

---

# Como executar o aplicativo

## 1. Pré-requisitos

Para executar o projeto é necessário possuir:

- Flutter instalado
- Dart instalado
- Git instalado
- Visual Studio Code ou Android Studio
- Emulador Android ou dispositivo físico configurado
- Uma chave válida da OMDb API

Para verificar se o Flutter está configurado corretamente:

```bash
flutter doctor