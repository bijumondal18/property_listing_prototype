import '../../core/constants/app_constants.dart';
import '../mock/mock_data.dart';
import '../models/interest.dart';
import 'interest_repository.dart';

class MockInterestRepository implements InterestRepository {
  MockInterestRepository({List<Interest>? initialInterests})
      : _interests = List<Interest>.from(
          initialInterests ?? MockData.seedInterests,
        );

  final List<Interest> _interests;
  int _idCounter = 100;

  /// Exposed for unit tests.
  List<Interest> get allInterests => List.unmodifiable(_interests);

  @override
  Future<Interest> submitInterest(Interest interest) async {
    await Future<void>.delayed(AppConstants.mockDelay);

    final duplicate = _interests.any(
      (i) =>
          i.propertyId == interest.propertyId &&
          i.email.toLowerCase() == interest.email.toLowerCase(),
    );
    if (duplicate) {
      throw InterestException(
        'You have already submitted interest for this property.',
      );
    }

    final saved = Interest(
      id: interest.id.isNotEmpty ? interest.id : 'interest_${_idCounter++}',
      propertyId: interest.propertyId,
      propertyName: interest.propertyName,
      ownerId: interest.ownerId,
      userName: interest.userName,
      mobile: interest.mobile,
      email: interest.email,
      message: interest.message,
      submittedAt: interest.submittedAt,
    );
    _interests.insert(0, saved);
    return saved;
  }

  @override
  Future<List<Interest>> getInterestsForOwner(String ownerId) async {
    await Future<void>.delayed(AppConstants.mockDelay);
    return _interests.where((i) => i.ownerId == ownerId).toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  @override
  Future<List<Interest>> getInterestsForProperty(String propertyId) async {
    await Future<void>.delayed(AppConstants.mockDelay);
    return _interests.where((i) => i.propertyId == propertyId).toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  @override
  Future<bool> hasUserSubmittedInterest({
    required String propertyId,
    required String email,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _interests.any(
      (i) =>
          i.propertyId == propertyId &&
          i.email.toLowerCase() == email.toLowerCase(),
    );
  }
}

class InterestException implements Exception {
  InterestException(this.message);
  final String message;

  @override
  String toString() => message;
}
