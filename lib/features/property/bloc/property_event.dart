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
