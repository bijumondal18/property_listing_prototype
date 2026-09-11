part of 'owner_dashboard_bloc.dart';

enum OwnerDashboardStatus { initial, loading, success, failure }

final class OwnerDashboardState extends Equatable {
  const OwnerDashboardState({
    this.status = OwnerDashboardStatus.initial,
    this.ownerId,
    this.properties = const [],
    this.interests = const [],
    this.interestCounts = const {},
    this.selectedPropertyFilterId,
    this.errorMessage,
  });

  final OwnerDashboardStatus status;
  final String? ownerId;
  final List<Property> properties;
  final List<Interest> interests;
  final Map<String, int> interestCounts;
  final String? selectedPropertyFilterId;
  final String? errorMessage;

  bool get isLoading =>
      status == OwnerDashboardStatus.loading ||
      status == OwnerDashboardStatus.initial;
  bool get hasError => status == OwnerDashboardStatus.failure;

  int get totalProperties => properties.length;
  int get totalInterests => interests.length;

  int get activeListings => properties
      .where((p) => p.status != 'Sold Out')
      .length;

  String? get mostInterestedPropertyName {
    if (interestCounts.isEmpty) return null;
    var maxCount = 0;
    String? propertyId;
    interestCounts.forEach((id, count) {
      if (count > maxCount) {
        maxCount = count;
        propertyId = id;
      }
    });
    if (maxCount == 0 || propertyId == null) return null;
    try {
      return properties.firstWhere((p) => p.id == propertyId).name;
    } catch (_) {
      return null;
    }
  }

  List<Interest> get filteredInterests {
    if (selectedPropertyFilterId == null) return interests;
    return interests
        .where((i) => i.propertyId == selectedPropertyFilterId)
        .toList();
  }

  OwnerDashboardState copyWith({
    OwnerDashboardStatus? status,
    String? ownerId,
    List<Property>? properties,
    List<Interest>? interests,
    Map<String, int>? interestCounts,
    String? selectedPropertyFilterId,
    String? errorMessage,
    bool clearError = false,
    bool clearPropertyFilter = false,
  }) {
    return OwnerDashboardState(
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,
      properties: properties ?? this.properties,
      interests: interests ?? this.interests,
      interestCounts: interestCounts ?? this.interestCounts,
      selectedPropertyFilterId: clearPropertyFilter
          ? null
          : (selectedPropertyFilterId ?? this.selectedPropertyFilterId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        ownerId,
        properties,
        interests,
        interestCounts,
        selectedPropertyFilterId,
        errorMessage,
      ];
}
