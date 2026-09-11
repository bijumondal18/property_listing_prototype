import '../../core/constants/app_constants.dart';
import '../mock/mock_data.dart';
import '../models/property.dart';
import '../models/property_filters.dart';
import 'property_repository.dart';

class MockPropertyRepository implements PropertyRepository {
  MockPropertyRepository({List<Property>? initialProperties})
      : _properties = List<Property>.from(
          initialProperties ?? MockData.properties,
        );

  final List<Property> _properties;

  /// Exposed for unit tests.
  List<Property> get allProperties => List.unmodifiable(_properties);

  @override
  Future<List<Property>> getProperties({PropertyFilters? filters}) async {
    await Future<void>.delayed(AppConstants.mockDelay);
    return applyFilters(_properties, filters ?? const PropertyFilters());
  }

  @override
  Future<Property?> getPropertyById(String id) async {
    await Future<void>.delayed(AppConstants.mockDelay);
    try {
      return _properties.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Property>> getPropertiesByOwner(String ownerId) async {
    await Future<void>.delayed(AppConstants.mockDelay);
    return _properties.where((p) => p.ownerId == ownerId).toList();
  }

  /// Pure filtering logic — used by repository and unit tests.
  static List<Property> applyFilters(
    List<Property> source,
    PropertyFilters filters,
  ) {
    var results = source.where((property) {
      if (filters.searchQuery.trim().isNotEmpty) {
        final q = filters.searchQuery.trim().toLowerCase();
        final matchesSearch = property.name.toLowerCase().contains(q) ||
            property.location.toLowerCase().contains(q) ||
            property.city.toLowerCase().contains(q) ||
            property.type.toLowerCase().contains(q) ||
            property.description.toLowerCase().contains(q);
        if (!matchesSearch) return false;
      }

      if (filters.location != null &&
          filters.location!.isNotEmpty &&
          property.city.toLowerCase() != filters.location!.toLowerCase()) {
        return false;
      }

      if (filters.propertyType != null &&
          filters.propertyType!.isNotEmpty &&
          property.type.toLowerCase() !=
              filters.propertyType!.toLowerCase()) {
        return false;
      }

      if (property.price < filters.minPrice ||
          property.price > filters.maxPrice) {
        return false;
      }

      if (property.area < filters.minArea || property.area > filters.maxArea) {
        return false;
      }

      if (filters.status != null &&
          filters.status!.isNotEmpty &&
          property.status.toLowerCase() != filters.status!.toLowerCase()) {
        return false;
      }

      if (filters.bedrooms != null && property.bedrooms != filters.bedrooms) {
        return false;
      }

      return true;
    }).toList();

    results = _sort(results, filters.sort);
    return results;
  }

  static List<Property> _sort(List<Property> list, PropertySort sort) {
    final sorted = List<Property>.from(list);
    switch (sort) {
      case PropertySort.priceLowToHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case PropertySort.priceHighToLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
      case PropertySort.areaSmallToLarge:
        sorted.sort((a, b) => a.area.compareTo(b.area));
      case PropertySort.areaLargeToSmall:
        sorted.sort((a, b) => b.area.compareTo(a.area));
      case PropertySort.none:
        break;
    }
    return sorted;
  }
}
