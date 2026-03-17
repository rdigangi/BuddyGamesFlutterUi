import 'package:flutter/material.dart';
import '../models/match_result.dart';
import '../services/mock_results_service.dart';

class ResultsListPage extends StatefulWidget {
  const ResultsListPage({super.key});

  @override
  State<ResultsListPage> createState() => _ResultsListPageState();
}

class _ResultsListPageState extends State<ResultsListPage> {
  @override
  Widget build(BuildContext context) {
    final List<MatchResult> results = MockResultsService.instance.getResults();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elenco risultati'),
      ),
      body: SafeArea(
        child: results.isEmpty
            ? const Center(
                child: Text('Nessun risultato disponibile'),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = results[index];

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.player1} vs ${item.player2}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 6),
                                Text('Risultato: ${item.score1} - ${item.score2}'),
                                const SizedBox(height: 4),
                                Text(_formatDate(item.playedAt)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}