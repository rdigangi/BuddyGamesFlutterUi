# Flutter Result Apps v2

[![Flutter CI](https://github.com/OWNER/REPO/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/flutter-ci.yml)
[![Lint](https://img.shields.io/badge/lint-flutter__analyze-0175C2)](https://docs.flutter.dev/testing/code-debugging#analyze-your-code)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Applicazione Flutter per la gestione dei risultati partite, con autenticazione mock, inserimento risultati e visualizzazione elenco.

> Nota: sostituisci `OWNER/REPO` con il tuo utente/organizzazione e nome repository GitHub.

## Funzionalità

- Login e registrazione (mock)
- Home con navigazione alle sezioni principali
- Inserimento nuovo risultato partita
- Lista risultati salvati in memoria (mock service)
- Tema personalizzato con Material

## Stack tecnico

- Flutter
- Dart SDK `^3.11.1`

## Struttura principale

- `lib/main.dart`: entrypoint app
- `lib/pages/`: schermate (`login`, `register`, `home`, `add_result`, `results_list`)
- `lib/models/`: modelli dominio (`app_user`, `match_result`)
- `lib/services/`: servizi mock (`mock_auth_service`, `mock_results_service`)
- `lib/core/`: configurazione tema

## Requisiti

- Flutter SDK installato e configurato
- Dart SDK compatibile con `^3.11.1`

## Avvio locale

1. Installare dipendenze:
	- `flutter pub get`
2. Eseguire l'app:
	- `flutter run`

## Qualità codice

- Analisi statica:
  - `flutter analyze`

## Licenza

Questo progetto è distribuito con licenza MIT. Vedi [LICENSE](LICENSE).
