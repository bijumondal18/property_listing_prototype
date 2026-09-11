import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing_prototype/data/models/app_user.dart';
import 'package:property_listing_prototype/data/repositories/mock_auth_repository.dart';

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  group('MockAuthRepository', () {
    test('valid user login succeeds', () async {
      final user = await repository.login(
        email: 'user@test.com',
        password: 'user123',
        role: UserRole.user,
      );

      expect(user.id, 'user_001');
      expect(user.role, UserRole.user);
      expect(repository.currentUser, isNotNull);
    });

    test('valid owner login succeeds', () async {
      final user = await repository.login(
        email: 'owner@test.com',
        password: 'owner123',
        role: UserRole.propertyOwner,
      );

      expect(user.id, 'owner_001');
      expect(user.role, UserRole.propertyOwner);
    });

    test('invalid credentials throw AuthException', () async {
      expect(
        () => repository.login(
          email: 'user@test.com',
          password: 'wrong',
          role: UserRole.user,
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('invalid role throws AuthException', () async {
      expect(
        () => repository.login(
          email: 'user@test.com',
          password: 'user123',
          role: UserRole.propertyOwner,
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('logout clears current user', () async {
      await repository.login(
        email: 'user@test.com',
        password: 'user123',
        role: UserRole.user,
      );
      await repository.logout();
      expect(repository.currentUser, isNull);
    });
  });
}
