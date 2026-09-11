part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    required this.email,
    required this.password,
    required this.role,
  });

  final String email;
  final String password;
  final UserRole role;

  @override
  List<Object?> get props => [email, password, role];
}

final class AuthSignupRequested extends AuthEvent {
  const AuthSignupRequested({
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    required this.role,
  });

  final String name;
  final String email;
  final String mobile;
  final String password;
  final UserRole role;

  @override
  List<Object?> get props => [name, email, mobile, password, role];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthRoleSelected extends AuthEvent {
  const AuthRoleSelected(this.role);

  final UserRole role;

  @override
  List<Object?> get props => [role];
}
