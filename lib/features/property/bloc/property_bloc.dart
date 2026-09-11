import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/property.dart';
import '../../../data/models/property_filters.dart';
import '../../../data/repositories/mock_property_repository.dart';
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
    on<PropertyAddRequested>(_onAddRequested);
    on<PropertyUpdateRequested>(_onUpdateRequested);
    on<PropertyDeleteRequested>(_onDeleteRequested);
    on<PropertyMutationStatusCleared>(_onMutationCleared);
  }

  final PropertyRepository _propertyRepository;

  Future<void> _reload(Emitter<PropertyState> emit) async {
    final properties = await _propertyRepository.getProperties(
      filters: state.filters,
    );
    emit(
      state.copyWith(
        status: PropertyStatus.success,
        properties: properties,
      ),
    );
  }

  Future<void> _onLoadRequested(
    PropertyLoadRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(state.copyWith(status: PropertyStatus.loading, clearError: true));
    try {
      await _reload(emit);
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

  Future<void> _onAddRequested(
    PropertyAddRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(
      state.copyWith(
        mutationStatus: PropertyMutationStatus.loading,
        clearMutationMessage: true,
        clearError: true,
      ),
    );
    try {
      await _propertyRepository.addProperty(event.property);
      await _reload(emit);
      emit(
        state.copyWith(
          mutationStatus: PropertyMutationStatus.success,
          mutationMessage: 'Property added successfully!',
        ),
      );
    } on PropertyException catch (e) {
      emit(
        state.copyWith(
          mutationStatus: PropertyMutationStatus.failure,
          mutationMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          mutationStatus: PropertyMutationStatus.failure,
          mutationMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onUpdateRequested(
    PropertyUpdateRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(
      state.copyWith(
        mutationStatus: PropertyMutationStatus.loading,
        clearMutationMessage: true,
        clearError: true,
      ),
    );
    try {
      await _propertyRepository.updateProperty(
        property: event.property,
        requesterOwnerId: event.requesterOwnerId,
      );
      await _reload(emit);
      emit(
        state.copyWith(
          mutationStatus: PropertyMutationStatus.success,
          mutationMessage: 'Property updated successfully!',
        ),
      );
    } on PropertyException catch (e) {
      emit(
        state.copyWith(
          mutationStatus: PropertyMutationStatus.failure,
          mutationMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          mutationStatus: PropertyMutationStatus.failure,
          mutationMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    PropertyDeleteRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(
      state.copyWith(
        mutationStatus: PropertyMutationStatus.loading,
        clearMutationMessage: true,
        clearError: true,
      ),
    );
    try {
      await _propertyRepository.deleteProperty(
        propertyId: event.propertyId,
        requesterOwnerId: event.requesterOwnerId,
      );
      await _reload(emit);
      emit(
        state.copyWith(
          mutationStatus: PropertyMutationStatus.success,
          mutationMessage: 'Property deleted successfully.',
        ),
      );
    } on PropertyException catch (e) {
      emit(
        state.copyWith(
          mutationStatus: PropertyMutationStatus.failure,
          mutationMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          mutationStatus: PropertyMutationStatus.failure,
          mutationMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  void _onMutationCleared(
    PropertyMutationStatusCleared event,
    Emitter<PropertyState> emit,
  ) {
    emit(
      state.copyWith(
        mutationStatus: PropertyMutationStatus.idle,
        clearMutationMessage: true,
      ),
    );
  }
}
