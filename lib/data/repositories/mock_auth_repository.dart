import '../../core/constants/app_constants.dart';
import '../mock/mock_data.dart';
import '../models/app_user.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await Future<void>.delayed(AppConstants.mockLoginDelay);

    final normalizedEmail = email.trim().toLowerCase();
    AppUser? user;
    for (final candidate in MockData.users) {
      if (candidate.email.toLowerCase() == normalizedEmail) {
        user = candidate;
        break;
      }
    }

    if (user == null) {
      throw AuthException('Invalid email or password');
    }

    final expectedPassword = MockData.passwords[normalizedEmail];
    if (expectedPassword == null || expectedPassword != password) {
      throw AuthException('Invalid email or password');
    }

    if (user.role != role) {
      throw AuthException(
        role == UserRole.user
            ? 'This account is not registered as a User. Please select Property Owner.'
            : 'This account is not registered as a Property Owner. Please select User.',
      );
    }

    _currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
