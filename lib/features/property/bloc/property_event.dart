part of 'property_bloc.dart';

sealed class PropertyEvent extends Equatable {
  const PropertyEvent();

  @override
  List<Object?> get props => [];
}

final class PropertyLoadRequested extends PropertyEvent {
  const PropertyLoadRequested();
}

final class PropertySearchChanged extends PropertyEvent {
  const PropertySearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class PropertyFiltersApplied extends PropertyEvent {
  const PropertyFiltersApplied(this.filters);

  final PropertyFilters filters;

  @override
  List<Object?> get props => [filters];
}

final class PropertyFiltersReset extends PropertyEvent {
  const PropertyFiltersReset();
}

final class PropertySortChanged extends PropertyEvent {
  const PropertySortChanged(this.sort);

  final PropertySort sort;

  @override
  List<Object?> get props => [sort];
}

final class PropertySelected extends PropertyEvent {
  const PropertySelected(this.property);

  final Property property;

  @override
  List<Object?> get props => [property];
}

final class PropertyAddRequested extends PropertyEvent {
  const PropertyAddRequested(this.property);

  final Property property;

  @override
  List<Object?> get props => [property];
}

final class PropertyUpdateRequested extends PropertyEvent {
  const PropertyUpdateRequested({
    required this.property,
    required this.requesterOwnerId,
  });

  final Property property;
  final String requesterOwnerId;

  @override
  List<Object?> get props => [property, requesterOwnerId];
}

final class PropertyDeleteRequested extends PropertyEvent {
  const PropertyDeleteRequested({
    required this.propertyId,
    required this.requesterOwnerId,
  });

  final String propertyId;
  final String requesterOwnerId;

  @override
  List<Object?> get props => [propertyId, requesterOwnerId];
}

final class PropertyMutationStatusCleared extends PropertyEvent {
  const PropertyMutationStatusCleared();
}
