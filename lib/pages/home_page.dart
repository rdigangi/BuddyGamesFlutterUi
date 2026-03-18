import 'package:flutter/material.dart';
import '../services/auth_api_service.dart';
import '../services/auth_session_service.dart';
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
    final sessionUsername = AuthSessionService.instance.username?.trim();
    final roles = AuthSessionService.instance.roles;
    final isAdmin = roles.any(
      (role) =>
          role.trim().toLowerCase() == 'admin' ||
          role.trim().toLowerCase() == 'administrator' ||
          role.trim().toLowerCase() == 'amministratore',
    );
    final usernameToShow =
        (sessionUsername != null && sessionUsername.isNotEmpty)
            ? sessionUsername
            : currentUsername;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 14,
                  child: Icon(Icons.person_outline, size: 16),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    usernameToShow,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Admin',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              AuthApiService.instance.logout();
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