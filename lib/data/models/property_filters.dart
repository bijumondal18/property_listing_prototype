import 'package:equatable/equatable.dart';

enum PropertySort {
  none,
  priceLowToHigh,
  priceHighToLow,
  areaSmallToLarge,
  areaLargeToSmall,
}

class PropertyFilters extends Equatable {
  const PropertyFilters({
    this.searchQuery = '',
    this.location,
    this.propertyType,
    this.minPrice = 2000000,
    this.maxPrice = 20000000,
    this.minArea = 500,
    this.maxArea = 3000,
    this.status,
    this.bedrooms,
    this.sort = PropertySort.none,
  });

  static const double defaultMinPrice = 2000000;
  static const double defaultMaxPrice = 20000000;
  static const double defaultMinArea = 500;
  static const double defaultMaxArea = 3000;

  final String searchQuery;
  final String? location;
  final String? propertyType;
  final double minPrice;
  final double maxPrice;
  final double minArea;
  final double maxArea;
  final String? status;
  final int? bedrooms;
  final PropertySort sort;

  int get activeFilterCount {
    var count = 0;
    if (location != null && location!.isNotEmpty) count++;
    if (propertyType != null && propertyType!.isNotEmpty) count++;
    if (minPrice > defaultMinPrice || maxPrice < defaultMaxPrice) count++;
    if (minArea > defaultMinArea || maxArea < defaultMaxArea) count++;
    if (status != null && status!.isNotEmpty) count++;
    if (bedrooms != null) count++;
    return count;
  }

  bool get hasActiveFilters => activeFilterCount > 0;

  PropertyFilters copyWith({
    String? searchQuery,
    String? location,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    String? status,
    int? bedrooms,
    PropertySort? sort,
    bool clearLocation = false,
    bool clearPropertyType = false,
    bool clearStatus = false,
    bool clearBedrooms = false,
  }) {
    return PropertyFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      location: clearLocation ? null : (location ?? this.location),
      propertyType:
          clearPropertyType ? null : (propertyType ?? this.propertyType),
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      status: clearStatus ? null : (status ?? this.status),
      bedrooms: clearBedrooms ? null : (bedrooms ?? this.bedrooms),
      sort: sort ?? this.sort,
    );
  }

  PropertyFilters reset() {
    return PropertyFilters(searchQuery: searchQuery, sort: sort);
  }

  @override
  List<Object?> get props => [
        searchQuery,
        location,
        propertyType,
        minPrice,
        maxPrice,
        minArea,
        maxArea,
        status,
        bedrooms,
        sort,
      ];
}
