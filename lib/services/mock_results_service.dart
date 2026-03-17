import '../models/match_result.dart';

class MockResultsService {
  MockResultsService._();

  static final MockResultsService instance = MockResultsService._();

  final List<MatchResult> _results = [
    MatchResult(
      id: 1,
      player1: 'mario',
      player2: 'luigi',
      score1: 3,
      score2: 1,
      playedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MatchResult(
      id: 2,
      player1: 'anna',
      player2: 'mario',
      score1: 2,
      score2: 2,
      playedAt: DateTime.now(),
    ),
  ];

  List<MatchResult> getResults() => List.unmodifiable(_results.reversed);

  void addResult({
    required String player1,
    required String player2,
    required int score1,
    required int score2,
  }) {
    _results.add(
      MatchResult(
        id: _results.length + 1,
        player1: player1,
        player2: player2,
        score1: score1,
        score2: score2,
        playedAt: DateTime.now(),
      ),
    );
  }
}