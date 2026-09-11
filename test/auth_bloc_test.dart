import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing_prototype/data/models/app_user.dart';
import 'package:property_listing_prototype/data/repositories/mock_auth_repository.dart';
import 'package:property_listing_prototype/features/auth/bloc/auth_bloc.dart';

void main() {
  group('AuthBloc', () {
    late MockAuthRepository repository;

    setUp(() {
      repository = MockAuthRepository();
    });

    blocTest<AuthBloc, AuthState>(
      'emits authenticated on valid user login',
      build: () => AuthBloc(authRepository: repository),
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'user@test.com',
          password: 'user123',
          role: UserRole.user,
        ),
      ),
      wait: const Duration(milliseconds: 800),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user?.role, 'role', UserRole.user),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits failure on invalid credentials',
      build: () => AuthBloc(authRepository: repository),
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'user@test.com',
          password: 'bad',
          role: UserRole.user,
        ),
      ),
      wait: const Duration(milliseconds: 800),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.failure),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits failure on invalid role',
      build: () => AuthBloc(authRepository: repository),
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'owner@test.com',
          password: 'owner123',
          role: UserRole.user,
        ),
      ),
      wait: const Duration(milliseconds: 800),
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.failure),
      ],
    );
  });
}
