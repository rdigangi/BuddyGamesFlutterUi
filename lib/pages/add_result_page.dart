import 'package:flutter/material.dart';
import '../services/mock_auth_service.dart';
import '../services/mock_results_service.dart';

class AddResultPage extends StatefulWidget {
  const AddResultPage({super.key});

  @override
  State<AddResultPage> createState() => _AddResultPageState();
}

class _AddResultPageState extends State<AddResultPage> {
  final _formKey = GlobalKey<FormState>();
  final _score1Controller = TextEditingController();
  final _score2Controller = TextEditingController();

  final _authService = MockAuthService.instance;
  final _resultsService = MockResultsService.instance;

  String? _selectedPlayer1;
  String? _selectedPlayer2;

  @override
  void dispose() {
    _score1Controller.dispose();
    _score2Controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPlayer1 == null || _selectedPlayer2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona entrambi i partecipanti')),
      );
      return;
    }

    if (_selectedPlayer1 == _selectedPlayer2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('I partecipanti devono essere diversi')),
      );
      return;
    }

    _resultsService.addResult(
      player1: _selectedPlayer1!,
      player2: _selectedPlayer2!,
      score1: int.parse(_score1Controller.text.trim()),
      score2: int.parse(_score2Controller.text.trim()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Risultato salvato')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final users = _authService.getUsers().map((u) => u.username).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inserisci risultato'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedPlayer1,
                          decoration: const InputDecoration(
                            labelText: 'Partecipante 1',
                            prefixIcon: Icon(Icons.person),
                          ),
                          items: users
                              .map(
                                (username) => DropdownMenuItem(
                                  value: username,
                                  child: Text(username),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPlayer1 = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Seleziona il primo partecipante';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedPlayer2,
                          decoration: const InputDecoration(
                            labelText: 'Partecipante 2',
                            prefixIcon: Icon(Icons.person),
                          ),
                          items: users
                              .map(
                                (username) => DropdownMenuItem(
                                  value: username,
                                  child: Text(username),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPlayer2 = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Seleziona il secondo partecipante';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _score1Controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Punteggio partecipante 1',
                            prefixIcon: Icon(Icons.scoreboard_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Inserisci il punteggio';
                            }
                            if (int.tryParse(value.trim()) == null) {
                              return 'Inserisci un numero valido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _score2Controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Punteggio partecipante 2',
                            prefixIcon: Icon(Icons.scoreboard_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Inserisci il punteggio';
                            }
                            if (int.tryParse(value.trim()) == null) {
                              return 'Inserisci un numero valido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _save,
                          child: const Text('Salva risultato'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}