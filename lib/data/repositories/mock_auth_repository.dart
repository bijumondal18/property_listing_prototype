import '../../core/constants/app_constants.dart';
import '../mock/mock_data.dart';
import '../models/app_user.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository()
      : _users = List<AppUser>.from(MockData.users),
        _passwords = Map<String, String>.from(MockData.passwords);

  final List<AppUser> _users;
  final Map<String, String> _passwords;
  AppUser? _currentUser;
  int _userCounter = 100;

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
    for (final candidate in _users) {
      if (candidate.email.toLowerCase() == normalizedEmail) {
        user = candidate;
        break;
      }
    }

    if (user == null) {
      throw AuthException('Invalid email or password');
    }

    final expectedPassword = _passwords[normalizedEmail];
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
  Future<AppUser> signup({
    required String name,
    required String email,
    required String mobile,
    required String password,
    required UserRole role,
  }) async {
    await Future<void>.delayed(AppConstants.mockLoginDelay);

    final normalizedEmail = email.trim().toLowerCase();
    final exists = _users.any(
      (u) => u.email.toLowerCase() == normalizedEmail,
    );
    if (exists) {
      throw AuthException('An account with this email already exists.');
    }

    final prefix = role == UserRole.propertyOwner ? 'owner' : 'user';
    final user = AppUser(
      id: '${prefix}_${_userCounter++}',
      email: normalizedEmail,
      name: name.trim(),
      role: role,
      mobile: mobile.trim(),
    );

    _users.add(user);
    _passwords[normalizedEmail] = password;
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
