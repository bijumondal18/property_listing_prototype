import 'package:equatable/equatable.dart';

enum UserRole { user, propertyOwner }

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.mobile,
  });

  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? mobile;

  bool get isOwner => role == UserRole.propertyOwner;
  bool get isUser => role == UserRole.user;

  @override
  List<Object?> get props => [id, email, name, role, mobile];
}
