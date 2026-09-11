part of 'property_bloc.dart';

enum PropertyStatus { initial, loading, success, failure }

enum PropertyMutationStatus { idle, loading, success, failure }

final class PropertyState extends Equatable {
  const PropertyState({
    this.status = PropertyStatus.initial,
    this.properties = const [],
    this.filters = const PropertyFilters(),
    this.selectedProperty,
    this.errorMessage,
    this.mutationStatus = PropertyMutationStatus.idle,
    this.mutationMessage,
  });

  final PropertyStatus status;
  final List<Property> properties;
  final PropertyFilters filters;
  final Property? selectedProperty;
  final String? errorMessage;
  final PropertyMutationStatus mutationStatus;
  final String? mutationMessage;

  bool get isLoading =>
      status == PropertyStatus.loading || status == PropertyStatus.initial;
  bool get isEmpty => status == PropertyStatus.success && properties.isEmpty;
  bool get hasError => status == PropertyStatus.failure;
  bool get isMutating => mutationStatus == PropertyMutationStatus.loading;

  PropertyState copyWith({
    PropertyStatus? status,
    List<Property>? properties,
    PropertyFilters? filters,
    Property? selectedProperty,
    String? errorMessage,
    PropertyMutationStatus? mutationStatus,
    String? mutationMessage,
    bool clearError = false,
    bool clearSelected = false,
    bool clearMutationMessage = false,
  }) {
    return PropertyState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      filters: filters ?? this.filters,
      selectedProperty:
          clearSelected ? null : (selectedProperty ?? this.selectedProperty),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      mutationStatus: mutationStatus ?? this.mutationStatus,
      mutationMessage: clearMutationMessage
          ? null
          : (mutationMessage ?? this.mutationMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        properties,
        filters,
        selectedProperty,
        errorMessage,
        mutationStatus,
        mutationMessage,
      ];
}
