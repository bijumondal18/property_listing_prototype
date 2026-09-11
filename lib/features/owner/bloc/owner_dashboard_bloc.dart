import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/interest.dart';
import '../../../data/models/property.dart';
import '../../../data/repositories/interest_repository.dart';
import '../../../data/repositories/property_repository.dart';

part 'owner_dashboard_event.dart';
part 'owner_dashboard_state.dart';

class OwnerDashboardBloc
    extends Bloc<OwnerDashboardEvent, OwnerDashboardState> {
  OwnerDashboardBloc({
    required this._propertyRepository,
    required this._interestRepository,
  }) : super(const OwnerDashboardState()) {
    on<OwnerDashboardLoadRequested>(_onLoadRequested);
    on<OwnerInterestPropertyFilterChanged>(_onFilterChanged);
  }

  final PropertyRepository _propertyRepository;
  final InterestRepository _interestRepository;

  Future<void> _onLoadRequested(
    OwnerDashboardLoadRequested event,
    Emitter<OwnerDashboardState> emit,
  ) async {
    emit(
      state.copyWith(
        status: OwnerDashboardStatus.loading,
        ownerId: event.ownerId,
        clearError: true,
      ),
    );
    try {
      final properties =
          await _propertyRepository.getPropertiesByOwner(event.ownerId);
      final interests =
          await _interestRepository.getInterestsForOwner(event.ownerId);

      final interestCounts = <String, int>{};
      for (final property in properties) {
        interestCounts[property.id] =
            interests.where((i) => i.propertyId == property.id).length;
      }

      emit(
        state.copyWith(
          status: OwnerDashboardStatus.success,
          properties: properties,
          interests: interests,
          interestCounts: interestCounts,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: OwnerDashboardStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  void _onFilterChanged(
    OwnerInterestPropertyFilterChanged event,
    Emitter<OwnerDashboardState> emit,
  ) {
    if (event.propertyId == null) {
      emit(state.copyWith(clearPropertyFilter: true));
    } else {
      emit(state.copyWith(selectedPropertyFilterId: event.propertyId));
    }
  }
}
