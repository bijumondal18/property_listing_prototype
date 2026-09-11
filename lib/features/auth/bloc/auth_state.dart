part of 'auth_bloc.dart';

enum AuthStatus { unauthenticated, loading, authenticated, failure }

final class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.selectedRole = UserRole.user,
    this.errorMessage,
  });

  const AuthState.unauthenticated()
      : this(status: AuthStatus.unauthenticated, selectedRole: UserRole.user);

  final AuthStatus status;
  final AppUser? user;
  final UserRole selectedRole;
  final String? errorMessage;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    UserRole? selectedRole,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      selectedRole: selectedRole ?? this.selectedRole,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, user, selectedRole, errorMessage];
}
