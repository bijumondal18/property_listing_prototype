part of 'interest_bloc.dart';

enum InterestSubmitStatus { initial, loading, success, failure }

enum InterestLoadStatus { initial, loading, success, failure }

final class InterestState extends Equatable {
  const InterestState({
    this.submitStatus = InterestSubmitStatus.initial,
    this.loadStatus = InterestLoadStatus.initial,
    this.interests = const [],
    this.lastSubmitted,
    this.errorMessage,
  });

  final InterestSubmitStatus submitStatus;
  final InterestLoadStatus loadStatus;
  final List<Interest> interests;
  final Interest? lastSubmitted;
  final String? errorMessage;

  bool get isSubmitting => submitStatus == InterestSubmitStatus.loading;
  bool get isSubmitSuccess => submitStatus == InterestSubmitStatus.success;
  bool get isLoadingInterests => loadStatus == InterestLoadStatus.loading;

  InterestState copyWith({
    InterestSubmitStatus? submitStatus,
    InterestLoadStatus? loadStatus,
    List<Interest>? interests,
    Interest? lastSubmitted,
    String? errorMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return InterestState(
      submitStatus: submitStatus ?? this.submitStatus,
      loadStatus: loadStatus ?? this.loadStatus,
      interests: interests ?? this.interests,
      lastSubmitted: clearSuccess
          ? null
          : (lastSubmitted ?? this.lastSubmitted),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [submitStatus, loadStatus, interests, lastSubmitted, errorMessage];
}
