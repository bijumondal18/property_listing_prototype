import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/interest.dart';
import '../../../data/repositories/interest_repository.dart';
import '../../../data/repositories/mock_interest_repository.dart';

part 'interest_event.dart';
part 'interest_state.dart';

class InterestBloc extends Bloc<InterestEvent, InterestState> {
  InterestBloc({required this._interestRepository})
      : super(const InterestState()) {
    on<InterestSubmitRequested>(_onSubmitRequested);
    on<InterestLoadForOwnerRequested>(_onLoadForOwner);
    on<InterestResetStatus>(_onResetStatus);
  }

  final InterestRepository _interestRepository;

  Future<void> _onSubmitRequested(
    InterestSubmitRequested event,
    Emitter<InterestState> emit,
  ) async {
    emit(
      state.copyWith(
        submitStatus: InterestSubmitStatus.loading,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      final interest = Interest(
        id: '',
        propertyId: event.propertyId,
        propertyName: event.propertyName,
        ownerId: event.ownerId,
        userName: event.userName,
        mobile: event.mobile,
        email: event.email,
        message: event.message,
        submittedAt: DateTime.now(),
      );
      final saved = await _interestRepository.submitInterest(interest);
      emit(
        state.copyWith(
          submitStatus: InterestSubmitStatus.success,
          lastSubmitted: saved,
          interests: [saved, ...state.interests],
        ),
      );
    } on InterestException catch (e) {
      emit(
        state.copyWith(
          submitStatus: InterestSubmitStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          submitStatus: InterestSubmitStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> _onLoadForOwner(
    InterestLoadForOwnerRequested event,
    Emitter<InterestState> emit,
  ) async {
    emit(
      state.copyWith(
        loadStatus: InterestLoadStatus.loading,
        clearError: true,
      ),
    );
    try {
      final interests =
          await _interestRepository.getInterestsForOwner(event.ownerId);
      emit(
        state.copyWith(
          loadStatus: InterestLoadStatus.success,
          interests: interests,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loadStatus: InterestLoadStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  void _onResetStatus(InterestResetStatus event, Emitter<InterestState> emit) {
    emit(
      state.copyWith(
        submitStatus: InterestSubmitStatus.initial,
        clearError: true,
        clearSuccess: true,
      ),
    );
  }
}
