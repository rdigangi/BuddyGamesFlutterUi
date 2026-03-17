import '../models/app_user.dart';

class MockAuthService {
  MockAuthService._();

  static final MockAuthService instance = MockAuthService._();

  final List<AppUser> _users = [
    AppUser(id: 1, username: 'mario', email: 'mario@test.com', password: '1234'),
    AppUser(id: 2, username: 'luigi', email: 'luigi@test.com', password: '1234'),
    AppUser(id: 3, username: 'anna', email: 'anna@test.com', password: '1234'),
  ];

  AppUser? login({
    required String email,
    required String password,
  }) {
    try {
      return _users.firstWhere(
        (u) =>
            u.email.toLowerCase() == email.toLowerCase() &&
            u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  bool register({
    required String username,
    required String email,
    required String password,
  }) {
    final exists = _users.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );

    if (exists) {
      return false;
    }

    _users.add(
      AppUser(
        id: _users.length + 1,
        username: username,
        email: email,
        password: password,
      ),
    );

    return true;
  }

  List<AppUser> getUsers() => List.unmodifiable(_users);
}