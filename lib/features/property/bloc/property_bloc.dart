import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/property.dart';
import '../../../data/models/property_filters.dart';
import '../../../data/repositories/property_repository.dart';

part 'property_event.dart';
part 'property_state.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  PropertyBloc({required this._propertyRepository})
      : super(const PropertyState()) {
    on<PropertyLoadRequested>(_onLoadRequested);
    on<PropertySearchChanged>(_onSearchChanged);
    on<PropertyFiltersApplied>(_onFiltersApplied);
    on<PropertyFiltersReset>(_onFiltersReset);
    on<PropertySortChanged>(_onSortChanged);
    on<PropertySelected>(_onSelected);
  }

  final PropertyRepository _propertyRepository;

  Future<void> _onLoadRequested(
    PropertyLoadRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(state.copyWith(status: PropertyStatus.loading, clearError: true));
    try {
      final properties = await _propertyRepository.getProperties(
        filters: state.filters,
      );
      emit(
        state.copyWith(
          status: PropertyStatus.success,
          properties: properties,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: PropertyStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onSearchChanged(
    PropertySearchChanged event,
    Emitter<PropertyState> emit,
  ) async {
    final filters = state.filters.copyWith(searchQuery: event.query);
    emit(state.copyWith(filters: filters, status: PropertyStatus.loading));
    try {
      final properties =
          await _propertyRepository.getProperties(filters: filters);
      emit(
        state.copyWith(
          status: PropertyStatus.success,
          properties: properties,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: PropertyStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onFiltersApplied(
    PropertyFiltersApplied event,
    Emitter<PropertyState> emit,
  ) async {
    final filters = event.filters.copyWith(
      searchQuery: state.filters.searchQuery,
      sort: state.filters.sort,
    );
    emit(state.copyWith(filters: filters, status: PropertyStatus.loading));
    try {
      final properties =
          await _propertyRepository.getProperties(filters: filters);
      emit(
        state.copyWith(
          status: PropertyStatus.success,
          properties: properties,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: PropertyStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onFiltersReset(
    PropertyFiltersReset event,
    Emitter<PropertyState> emit,
  ) async {
    final filters = state.filters.reset();
    emit(state.copyWith(filters: filters, status: PropertyStatus.loading));
    try {
      final properties =
          await _propertyRepository.getProperties(filters: filters);
      emit(
        state.copyWith(
          status: PropertyStatus.success,
          properties: properties,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: PropertyStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onSortChanged(
    PropertySortChanged event,
    Emitter<PropertyState> emit,
  ) async {
    final filters = state.filters.copyWith(sort: event.sort);
    emit(state.copyWith(filters: filters, status: PropertyStatus.loading));
    try {
      final properties =
          await _propertyRepository.getProperties(filters: filters);
      emit(
        state.copyWith(
          status: PropertyStatus.success,
          properties: properties,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: PropertyStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  void _onSelected(PropertySelected event, Emitter<PropertyState> emit) {
    emit(state.copyWith(selectedProperty: event.property));
  }
}
