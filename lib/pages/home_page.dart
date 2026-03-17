import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import 'add_result_page.dart';
import 'login_page.dart';
import 'results_list_page.dart';

class HomePage extends StatelessWidget {
  final String currentUsername;

  const HomePage({
    super.key,
    required this.currentUsername,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(width: 300, height: 300, showTitle: false,),
                  const SizedBox(height: 24),
                  Text(
                    'Benvenuto, $currentUsername',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddResultPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Inserisci risultato'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ResultsListPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Visualizza risultati'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}