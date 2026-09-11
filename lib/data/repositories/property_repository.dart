import '../models/property.dart';
import '../models/property_filters.dart';

abstract class PropertyRepository {
  Future<List<Property>> getProperties({PropertyFilters? filters});

  Future<Property?> getPropertyById(String id);

  Future<List<Property>> getPropertiesByOwner(String ownerId);
}
