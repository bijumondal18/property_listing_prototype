part of 'owner_dashboard_bloc.dart';

sealed class OwnerDashboardEvent extends Equatable {
  const OwnerDashboardEvent();

  @override
  List<Object?> get props => [];
}

final class OwnerDashboardLoadRequested extends OwnerDashboardEvent {
  const OwnerDashboardLoadRequested(this.ownerId);

  final String ownerId;

  @override
  List<Object?> get props => [ownerId];
}

final class OwnerInterestPropertyFilterChanged extends OwnerDashboardEvent {
  const OwnerInterestPropertyFilterChanged(this.propertyId);

  /// null means "All"
  final String? propertyId;

  @override
  List<Object?> get props => [propertyId];
}
