import '../models/property.dart';
import '../models/property_filters.dart';

abstract class PropertyRepository {
  Future<List<Property>> getProperties({PropertyFilters? filters});

  Future<Property?> getPropertyById(String id);

  Future<List<Property>> getPropertiesByOwner(String ownerId);

  Future<Property> addProperty(Property property);

  Future<Property> updateProperty({
    required Property property,
    required String requesterOwnerId,
  });

  Future<void> deleteProperty({
    required String propertyId,
    required String requesterOwnerId,
  });
}
