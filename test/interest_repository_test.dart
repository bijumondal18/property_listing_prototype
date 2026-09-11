import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing_prototype/data/models/interest.dart';
import 'package:property_listing_prototype/data/repositories/mock_interest_repository.dart';

void main() {
  late MockInterestRepository repository;

  setUp(() {
    repository = MockInterestRepository(initialInterests: []);
  });

  group('Interest repository', () {
    test('submit interest stores and returns interest', () async {
      final submitted = await repository.submitInterest(
        Interest(
          id: '',
          propertyId: 'property_001',
          propertyName: 'Modern Skyline Apartment',
          ownerId: 'owner_001',
          userName: 'Test User',
          mobile: '9876543210',
          email: 'test.user@example.com',
          message: 'Please contact me.',
          submittedAt: DateTime(2026, 9, 11),
        ),
      );

      expect(submitted.id, isNotEmpty);
      expect(submitted.propertyId, 'property_001');
      expect(repository.allInterests.length, 1);
    });

    test('duplicate interest for same email/property is rejected', () async {
      final interest = Interest(
        id: '',
        propertyId: 'property_001',
        propertyName: 'Modern Skyline Apartment',
        ownerId: 'owner_001',
        userName: 'Test User',
        mobile: '9876543210',
        email: 'dup@example.com',
        message: 'Hello',
        submittedAt: DateTime(2026, 9, 11),
      );

      await repository.submitInterest(interest);
      expect(
        () => repository.submitInterest(interest),
        throwsA(isA<InterestException>()),
      );
    });

    test('retrieve owner interests returns only that owner', () async {
      await repository.submitInterest(
        Interest(
          id: '',
          propertyId: 'property_001',
          propertyName: 'Modern Skyline Apartment',
          ownerId: 'owner_001',
          userName: 'User A',
          mobile: '9876543210',
          email: 'a@example.com',
          message: 'Hi',
          submittedAt: DateTime(2026, 9, 11),
        ),
      );
      await repository.submitInterest(
        Interest(
          id: '',
          propertyId: 'property_003',
          propertyName: 'Urban Nest Apartment',
          ownerId: 'owner_002',
          userName: 'User B',
          mobile: '9123456780',
          email: 'b@example.com',
          message: 'Hi',
          submittedAt: DateTime(2026, 9, 11),
        ),
      );

      final owner1 = await repository.getInterestsForOwner('owner_001');
      final owner2 = await repository.getInterestsForOwner('owner_002');

      expect(owner1.length, 1);
      expect(owner1.first.ownerId, 'owner_001');
      expect(owner2.length, 1);
      expect(owner2.first.ownerId, 'owner_002');
    });

    test('owner isolation — owner cannot see other owner interests', () async {
      await repository.submitInterest(
        Interest(
          id: '',
          propertyId: 'property_001',
          propertyName: 'Modern Skyline Apartment',
          ownerId: 'owner_001',
          userName: 'User A',
          mobile: '9876543210',
          email: 'isolation@example.com',
          message: 'Private',
          submittedAt: DateTime(2026, 9, 11),
        ),
      );

      final otherOwner =
          await repository.getInterestsForOwner('owner_003');
      expect(otherOwner, isEmpty);
    });
  });
}
