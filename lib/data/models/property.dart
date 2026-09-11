import 'package:equatable/equatable.dart';

class Property extends Equatable {
  const Property({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.city,
    required this.price,
    required this.area,
    required this.bedrooms,
    required this.status,
    required this.description,
    required this.imageUrl,
    required this.ownerId,
    required this.ownerName,
  });

  final String id;
  final String name;
  final String type;
  final String location;
  final String city;
  final double price;
  final double area;
  final int bedrooms;
  final String status;
  final String description;
  final String imageUrl;
  final String ownerId;
  final String ownerName;

  String get configuration => '$bedrooms BHK';

  Property copyWith({
    String? id,
    String? name,
    String? type,
    String? location,
    String? city,
    double? price,
    double? area,
    int? bedrooms,
    String? status,
    String? description,
    String? imageUrl,
    String? ownerId,
    String? ownerName,
  }) {
    return Property(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      city: city ?? this.city,
      price: price ?? this.price,
      area: area ?? this.area,
      bedrooms: bedrooms ?? this.bedrooms,
      status: status ?? this.status,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        location,
        city,
        price,
        area,
        bedrooms,
        status,
        description,
        imageUrl,
        ownerId,
        ownerName,
      ];
}
