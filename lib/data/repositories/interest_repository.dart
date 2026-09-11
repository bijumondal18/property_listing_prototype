import '../models/interest.dart';

abstract class InterestRepository {
  Future<Interest> submitInterest(Interest interest);

  Future<List<Interest>> getInterestsForOwner(String ownerId);

  Future<List<Interest>> getInterestsForProperty(String propertyId);

  Future<bool> hasUserSubmittedInterest({
    required String propertyId,
    required String email,
  });
}
