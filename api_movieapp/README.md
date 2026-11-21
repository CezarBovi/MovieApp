# API da coleção — MovieApp

Back-end Flask da coleção pessoal. A OMDb continua apenas no aplicativo Flutter.

## Executar

```bash
cd api_movieapp
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python api.py
```

O servidor escuta em `0.0.0.0:5000` com `debug=False`.

Computador: `http://127.0.0.1:5000/health`  
Emulador Android: `http://10.0.2.2:5000`  
Celular físico: `http://IP_LOCAL:5000` (mesma Wi-Fi; não use localhost).

## Testes

```bash
cd api_movieapp
python -m pytest tests -q
```

Os testes usam arquivos JSON temporários e não gravam em `colecao.json`.

## Limitação

Não há autenticação: existe uma única coleção no arquivo `colecao.json`.
