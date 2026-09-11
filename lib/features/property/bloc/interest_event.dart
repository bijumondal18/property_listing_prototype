part of 'interest_bloc.dart';

sealed class InterestEvent extends Equatable {
  const InterestEvent();

  @override
  List<Object?> get props => [];
}

final class InterestSubmitRequested extends InterestEvent {
  const InterestSubmitRequested({
    required this.propertyId,
    required this.propertyName,
    required this.ownerId,
    required this.userName,
    required this.mobile,
    required this.email,
    required this.message,
  });

  final String propertyId;
  final String propertyName;
  final String ownerId;
  final String userName;
  final String mobile;
  final String email;
  final String message;

  @override
  List<Object?> get props => [
        propertyId,
        propertyName,
        ownerId,
        userName,
        mobile,
        email,
        message,
      ];
}

final class InterestLoadForOwnerRequested extends InterestEvent {
  const InterestLoadForOwnerRequested(this.ownerId);

  final String ownerId;

  @override
  List<Object?> get props => [ownerId];
}

final class InterestResetStatus extends InterestEvent {
  const InterestResetStatus();
}
