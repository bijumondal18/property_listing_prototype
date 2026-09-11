import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing_prototype/data/models/app_user.dart';
import 'package:property_listing_prototype/data/models/property.dart';
import 'package:property_listing_prototype/data/repositories/mock_auth_repository.dart';
import 'package:property_listing_prototype/data/repositories/mock_favorites_repository.dart';
import 'package:property_listing_prototype/data/repositories/mock_property_repository.dart';

void main() {
  group('Auth signup', () {
    late MockAuthRepository auth;

    setUp(() {
      auth = MockAuthRepository();
    });

    test('user signup succeeds and logs in', () async {
      final user = await auth.signup(
        name: 'Demo User',
        email: 'new.user@example.com',
        mobile: '9876543210',
        password: 'password123',
        role: UserRole.user,
      );
      expect(user.role, UserRole.user);
      expect(auth.currentUser, isNotNull);
      expect(user.email, 'new.user@example.com');
    });

    test('owner signup succeeds', () async {
      final user = await auth.signup(
        name: 'Demo Owner',
        email: 'new.owner@example.com',
        mobile: '9123456780',
        password: 'password123',
        role: UserRole.propertyOwner,
      );
      expect(user.role, UserRole.propertyOwner);
      expect(user.id.startsWith('owner_'), isTrue);
    });

    test('duplicate email is rejected', () async {
      expect(
        () => auth.signup(
          name: 'Someone',
          email: 'user@test.com',
          mobile: '9876543210',
          password: 'password123',
          role: UserRole.user,
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('signup then login works', () async {
      await auth.signup(
        name: 'Login Later',
        email: 'later@example.com',
        mobile: '9988776655',
        password: 'password123',
        role: UserRole.user,
      );
      await auth.logout();
      final user = await auth.login(
        email: 'later@example.com',
        password: 'password123',
        role: UserRole.user,
      );
      expect(user.email, 'later@example.com');
    });
  });

  group('Property CRUD ownership', () {
    late MockPropertyRepository repo;

    setUp(() {
      repo = MockPropertyRepository(initialProperties: []);
    });

    test('add property', () async {
      final added = await repo.addProperty(
        const Property(
          id: '',
          name: 'Test Home',
          type: 'Apartment',
          location: 'Salt Lake, Kolkata',
          city: 'Kolkata',
          price: 5000000,
          area: 1000,
          bedrooms: 2,
          status: 'Available',
          description: 'A lovely fictional apartment for testing purposes.',
          imageUrl: 'https://picsum.photos/seed/t/800/600',
          ownerId: 'owner_001',
          ownerName: 'Priya Sharma',
        ),
      );
      expect(added.id, isNotEmpty);
      expect(repo.allProperties.length, 1);
    });

    test('owner can update own property', () async {
      final added = await repo.addProperty(
        const Property(
          id: '',
          name: 'Test Home',
          type: 'Apartment',
          location: 'Salt Lake, Kolkata',
          city: 'Kolkata',
          price: 5000000,
          area: 1000,
          bedrooms: 2,
          status: 'Available',
          description: 'A lovely fictional apartment for testing purposes.',
          imageUrl: 'https://picsum.photos/seed/t/800/600',
          ownerId: 'owner_001',
          ownerName: 'Priya Sharma',
        ),
      );
      final updated = await repo.updateProperty(
        property: added.copyWith(name: 'Updated Home'),
        requesterOwnerId: 'owner_001',
      );
      expect(updated.name, 'Updated Home');
    });

    test('owner cannot update another owner property', () async {
      final added = await repo.addProperty(
        const Property(
          id: '',
          name: 'Test Home',
          type: 'Apartment',
          location: 'Salt Lake, Kolkata',
          city: 'Kolkata',
          price: 5000000,
          area: 1000,
          bedrooms: 2,
          status: 'Available',
          description: 'A lovely fictional apartment for testing purposes.',
          imageUrl: 'https://picsum.photos/seed/t/800/600',
          ownerId: 'owner_001',
          ownerName: 'Priya Sharma',
        ),
      );
      expect(
        () => repo.updateProperty(
          property: added.copyWith(name: 'Hacked'),
          requesterOwnerId: 'owner_002',
        ),
        throwsA(isA<PropertyException>()),
      );
    });

    test('owner can delete own property only', () async {
      final added = await repo.addProperty(
        const Property(
          id: '',
          name: 'Test Home',
          type: 'Apartment',
          location: 'Salt Lake, Kolkata',
          city: 'Kolkata',
          price: 5000000,
          area: 1000,
          bedrooms: 2,
          status: 'Available',
          description: 'A lovely fictional apartment for testing purposes.',
          imageUrl: 'https://picsum.photos/seed/t/800/600',
          ownerId: 'owner_001',
          ownerName: 'Priya Sharma',
        ),
      );
      expect(
        () => repo.deleteProperty(
          propertyId: added.id,
          requesterOwnerId: 'owner_002',
        ),
        throwsA(isA<PropertyException>()),
      );
      await repo.deleteProperty(
        propertyId: added.id,
        requesterOwnerId: 'owner_001',
      );
      expect(repo.allProperties, isEmpty);
    });
  });

  group('Favorites', () {
    late MockFavoritesRepository favorites;

    setUp(() {
      favorites = MockFavoritesRepository();
    });

    test('toggle favorite and unfavorite', () async {
      var ids = await favorites.toggleFavorite(
        userId: 'user_001',
        propertyId: 'property_001',
      );
      expect(ids.contains('property_001'), isTrue);
      ids = await favorites.toggleFavorite(
        userId: 'user_001',
        propertyId: 'property_001',
      );
      expect(ids.contains('property_001'), isFalse);
    });

    test('favorites are isolated per user', () async {
      await favorites.addFavorite(
        userId: 'user_001',
        propertyId: 'property_001',
      );
      final other = await favorites.getFavorites('user_999');
      expect(other, isEmpty);
    });
  });
}
