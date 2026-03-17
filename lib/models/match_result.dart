class MatchResult {
  final int id;
  final String player1;
  final String player2;
  final int score1;
  final int score2;
  final DateTime playedAt;

  MatchResult({
    required this.id,
    required this.player1,
    required this.player2,
    required this.score1,
    required this.score2,
    required this.playedAt,
  });
}