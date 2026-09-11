import 'package:equatable/equatable.dart';

class Interest extends Equatable {
  const Interest({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.ownerId,
    required this.userName,
    required this.mobile,
    required this.email,
    required this.message,
    required this.submittedAt,
  });

  final String id;
  final String propertyId;
  final String propertyName;
  final String ownerId;
  final String userName;
  final String mobile;
  final String email;
  final String message;
  final DateTime submittedAt;

  @override
  List<Object?> get props => [
        id,
        propertyId,
        propertyName,
        ownerId,
        userName,
        mobile,
        email,
        message,
        submittedAt,
      ];
}
