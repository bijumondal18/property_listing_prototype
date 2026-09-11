import '../models/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> login({
    required String email,
    required String password,
    required UserRole role,
  });

  Future<void> logout();

  AppUser? get currentUser;
}
