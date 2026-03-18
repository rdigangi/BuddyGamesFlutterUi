# Flutter Result Apps v2

[![Flutter CI](https://github.com/OWNER/REPO/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/flutter-ci.yml)
[![Lint](https://img.shields.io/badge/lint-flutter__analyze-0175C2)](https://docs.flutter.dev/testing/code-debugging#analyze-your-code)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Applicazione Flutter per la gestione dei risultati partite, con autenticazione backend (login/register/refresh), inserimento risultati e visualizzazione elenco.

> Nota: sostituisci `OWNER/REPO` con il tuo utente/organizzazione e nome repository GitHub.

## Funzionalità

- Registrazione via API (`POST /api/Authentication/register`) con campi:
	- `nome`, `cognome`, `username`, `email`, `password`
- Login via API (`POST /api/authentication/login`) con:
	- `usernameOrEmail`, `password`
- Gestione sessione token:
	- `accessToken`, `refreshToken`
	- `accessTokenExpiresAtUtc`, `refreshTokenExpiresAtUtc`
- Refresh automatico token su `401` (`POST /api/authentication/refresh`) e retry della chiamata protetta
- Logout forzato con redirect a login se refresh fallisce/scade
- Home con navigazione alle sezioni principali
- Header home con avatar profilo placeholder + username
- Badge ruolo admin in home se presente nei claim JWT (`role = Amministratore`)
- Messaggio di benvenuto con nome utente dai claim JWT (`nome` / `given_name` / `ClaimTypes.GivenName`)
- Inserimento nuovo risultato partita
- Lista risultati salvati in memoria (mock service)
- Tema personalizzato con Material
- Icona applicazione personalizzata da `assets/images/logo.png`

## Stack tecnico

- Flutter
- Dart SDK `^3.11.1`
- `http` per integrazione REST API
- `flutter_launcher_icons` per generazione icone app

## Struttura principale

- `lib/main.dart`: entrypoint app
- `lib/pages/`: schermate (`login`, `register`, `home`, `add_result`, `results_list`)
- `lib/models/`: modelli dominio (`app_user`, `match_result`)
- `lib/services/`:
	- `auth_api_service.dart`: chiamate login/register/refresh
	- `auth_session_service.dart`: stato sessione e claim JWT
	- `authenticated_api_client.dart`: chiamate protette con header Bearer + retry post-refresh
	- `mock_results_service.dart`: risultati demo in memoria
- `lib/core/`:
	- `app_config.dart`: base URL configurabile + endpoint auth
	- `app_navigator.dart`: redirect centralizzato alla login
	- `app_theme.dart`: tema applicazione

## Requisiti

- Flutter SDK installato e configurato
- Dart SDK compatibile con `^3.11.1`

## Avvio locale

1. Installare dipendenze:
	- `flutter pub get`
2. Eseguire l'app:
	- `flutter run`

### Configurazione Backend API

Il base URL API è configurabile via `dart-define`.

- Default: `http://localhost:5152`
- Override esempio:
  - `flutter run --dart-define=API_BASE_URL=http://localhost:5152`

Endpoint auth attesi:

- `POST /api/Authentication/register`
- `POST /api/authentication/login`
- `POST /api/authentication/refresh`

> Nota: su emulatori/simulatori, `localhost` può richiedere un host alternativo in base alla piattaforma.

### Flusso autenticazione implementato

1. Login riuscito (`200`): salvataggio token + scadenze UTC in sessione client.
2. Chiamate protette: invio `Authorization: Bearer <accessToken>`.
3. Se risposta `401`: tentativo refresh token.
4. Se refresh OK: retry automatico chiamata originale.
5. Se refresh fallisce: pulizia sessione, logout e redirect login.

### JWT Claims usati dalla UI

- Nome visualizzato in home: `nome` / `given_name` / `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname`
- Username header home: `username` (con fallback)
- Ruoli: `role` / `roles` / `http://schemas.microsoft.com/ws/2008/06/identity/claims/role`
  - Badge admin se valore `Amministratore` (oltre a `admin`/`administrator`)

### Icona app

Le icone sono generate da `assets/images/logo.png` con `flutter_launcher_icons` (Android/iOS/Web/macOS/Windows).

## Qualità codice

- Analisi statica:
  - `flutter analyze`

## Licenza

Questo progetto è distribuito con licenza MIT. Vedi [LICENSE](LICENSE).
