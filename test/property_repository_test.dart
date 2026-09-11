import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing_prototype/data/models/property_filters.dart';
import 'package:property_listing_prototype/data/repositories/mock_property_repository.dart';

void main() {
  late MockPropertyRepository repository;

  setUp(() {
    repository = MockPropertyRepository();
  });

  group('Property filtering', () {
    test('location filtering returns only matching city', () async {
      final results = await repository.getProperties(
        filters: const PropertyFilters(location: 'Kolkata'),
      );
      expect(results, isNotEmpty);
      expect(results.every((p) => p.city == 'Kolkata'), isTrue);
    });

    test('type filtering returns only apartments', () async {
      final results = await repository.getProperties(
        filters: const PropertyFilters(propertyType: 'Apartment'),
      );
      expect(results, isNotEmpty);
      expect(results.every((p) => p.type == 'Apartment'), isTrue);
    });

    test('price filtering respects range', () async {
      final results = await repository.getProperties(
        filters: const PropertyFilters(
          minPrice: 4000000,
          maxPrice: 8000000,
        ),
      );
      expect(results, isNotEmpty);
      expect(
        results.every((p) => p.price >= 4000000 && p.price <= 8000000),
        isTrue,
      );
    });

    test('area filtering respects range', () async {
      final results = await repository.getProperties(
        filters: const PropertyFilters(minArea: 1000, maxArea: 1200),
      );
      expect(results, isNotEmpty);
      expect(
        results.every((p) => p.area >= 1000 && p.area <= 1200),
        isTrue,
      );
    });

    test('configuration filtering returns matching bedrooms', () async {
      final results = await repository.getProperties(
        filters: const PropertyFilters(bedrooms: 2),
      );
      expect(results, isNotEmpty);
      expect(results.every((p) => p.bedrooms == 2), isTrue);
    });

    test('status filtering returns matching status', () async {
      final results = await repository.getProperties(
        filters: const PropertyFilters(status: 'Ready to Move'),
      );
      expect(results, isNotEmpty);
      expect(results.every((p) => p.status == 'Ready to Move'), isTrue);
    });

    test('combined filters require all conditions', () async {
      final results = await repository.getProperties(
        filters: const PropertyFilters(
          location: 'Kolkata',
          propertyType: 'Apartment',
          bedrooms: 2,
          minPrice: 4000000,
          maxPrice: 8000000,
        ),
      );
      expect(results, isNotEmpty);
      expect(
        results.every(
          (p) =>
              p.city == 'Kolkata' &&
              p.type == 'Apartment' &&
              p.bedrooms == 2 &&
              p.price >= 4000000 &&
              p.price <= 8000000,
        ),
        isTrue,
      );
    });

    test('search matches location text', () async {
      final results = await repository.getProperties(
        filters: const PropertyFilters(searchQuery: 'Kolkata'),
      );
      expect(results, isNotEmpty);
      expect(
        results.every(
          (p) =>
              p.city.contains('Kolkata') ||
              p.location.contains('Kolkata') ||
              p.name.contains('Kolkata') ||
              p.description.contains('Kolkata'),
        ),
        isTrue,
      );
    });

    test('sort price low to high', () async {
      final results = await repository.getProperties(
        filters: const PropertyFilters(sort: PropertySort.priceLowToHigh),
      );
      for (var i = 1; i < results.length; i++) {
        expect(results[i].price >= results[i - 1].price, isTrue);
      }
    });

    test('getPropertyById returns property', () async {
      final property = await repository.getPropertyById('property_001');
      expect(property, isNotNull);
      expect(property!.name, 'Modern Skyline Apartment');
    });

    test('getPropertiesByOwner isolates owner properties', () async {
      final owner1 = await repository.getPropertiesByOwner('owner_001');
      final owner2 = await repository.getPropertiesByOwner('owner_002');
      expect(owner1.every((p) => p.ownerId == 'owner_001'), isTrue);
      expect(owner2.every((p) => p.ownerId == 'owner_002'), isTrue);
      expect(
        owner1.any((p) => owner2.map((e) => e.id).contains(p.id)),
        isFalse,
      );
    });
  });
}
