import '../models/app_user.dart';
import '../models/interest.dart';
import '../models/property.dart';

class MockData {
  static const List<AppUser> users = [
    AppUser(
      id: 'user_001',
      email: 'user@test.com',
      name: 'Aarav Mehta',
      role: UserRole.user,
    ),
    AppUser(
      id: 'owner_001',
      email: 'owner@test.com',
      name: 'Priya Sharma',
      role: UserRole.propertyOwner,
    ),
    AppUser(
      id: 'owner_002',
      email: 'owner2@test.com',
      name: 'Rohan Kapoor',
      role: UserRole.propertyOwner,
    ),
    AppUser(
      id: 'owner_003',
      email: 'owner3@test.com',
      name: 'Sneha Reddy',
      role: UserRole.propertyOwner,
    ),
  ];

  /// Demo passwords keyed by email.
  static const Map<String, String> passwords = {
    'user@test.com': 'user123',
    'owner@test.com': 'owner123',
    'owner2@test.com': 'owner123',
    'owner3@test.com': 'owner123',
  };

  static final List<Property> properties = [
    const Property(
      id: 'property_001',
      name: 'Modern Skyline Apartment',
      type: 'Apartment',
      location: 'Salt Lake, Kolkata, West Bengal',
      city: 'Kolkata',
      price: 6500000,
      area: 1050,
      bedrooms: 2,
      status: 'Ready to Move',
      description:
          'Beautiful modern apartment with panoramic city views, modular kitchen, '
          'and premium amenities including a clubhouse and swimming pool. '
          'Located in a well-connected neighbourhood with excellent schools nearby.',
      imageUrl: 'https://picsum.photos/seed/skylineapt/800/600',
      ownerId: 'owner_001',
      ownerName: 'Priya Sharma',
    ),
    const Property(
      id: 'property_002',
      name: 'Green Valley Villa',
      type: 'Villa',
      location: 'Whitefield, Bangalore, Karnataka',
      city: 'Bangalore',
      price: 18000000,
      area: 2400,
      bedrooms: 4,
      status: 'Ready to Move',
      description:
          'Spacious villa surrounded by greenery with a private garden, '
          'home theatre, and smart home features. Ideal for families seeking '
          'tranquillity with proximity to IT hubs.',
      imageUrl: 'https://picsum.photos/seed/greenvalley/800/600',
      ownerId: 'owner_001',
      ownerName: 'Priya Sharma',
    ),
    const Property(
      id: 'property_003',
      name: 'Urban Nest Apartment',
      type: 'Apartment',
      location: 'Hinjewadi, Pune, Maharashtra',
      city: 'Pune',
      price: 7200000,
      area: 1150,
      bedrooms: 2,
      status: 'Available',
      description:
          'Contemporary apartment close to major IT parks. Features open living '
          'spaces, balcony with garden view, and access to a well-equipped gym.',
      imageUrl: 'https://picsum.photos/seed/urbannest/800/600',
      ownerId: 'owner_002',
      ownerName: 'Rohan Kapoor',
    ),
    const Property(
      id: 'property_004',
      name: 'Harmony Row House',
      type: 'Row House',
      location: 'Gachibowli, Hyderabad, Telangana',
      city: 'Hyderabad',
      price: 9500000,
      area: 1800,
      bedrooms: 3,
      status: 'Under Construction',
      description:
          'Elegant row house in a gated community with designer interiors, '
          'dedicated parking, and landscaped common areas. Possession expected soon.',
      imageUrl: 'https://picsum.photos/seed/harmonyrow/800/600',
      ownerId: 'owner_002',
      ownerName: 'Rohan Kapoor',
    ),
    const Property(
      id: 'property_005',
      name: 'Sea Breeze Heights',
      type: 'Apartment',
      location: 'Andheri West, Mumbai, Maharashtra',
      city: 'Mumbai',
      price: 14500000,
      area: 980,
      bedrooms: 2,
      status: 'Ready to Move',
      description:
          'Premium sea-facing apartment with stylish interiors, covered parking, '
          'and 24/7 security. Minutes from metro and lifestyle destinations.',
      imageUrl: 'https://picsum.photos/seed/seabreeze/800/600',
      ownerId: 'owner_003',
      ownerName: 'Sneha Reddy',
    ),
    const Property(
      id: 'property_006',
      name: 'Capital Pride Villa',
      type: 'Villa',
      location: 'Dwarka, Delhi',
      city: 'Delhi',
      price: 20000000,
      area: 2800,
      bedrooms: 5,
      status: 'Available',
      description:
          'Luxurious villa with expansive living areas, private terrace, '
          'servant quarters, and landscaped lawn. Perfect for large families.',
      imageUrl: 'https://picsum.photos/seed/capitalpride/800/600',
      ownerId: 'owner_003',
      ownerName: 'Sneha Reddy',
    ),
    const Property(
      id: 'property_007',
      name: 'Lakeview Comfort Homes',
      type: 'Apartment',
      location: 'New Town, Kolkata, West Bengal',
      city: 'Kolkata',
      price: 4200000,
      area: 850,
      bedrooms: 1,
      status: 'Available',
      description:
          'Compact and efficient 1 BHK with lake views, modern fittings, '
          'and low maintenance costs. Great for first-time buyers and professionals.',
      imageUrl: 'https://picsum.photos/seed/lakeview/800/600',
      ownerId: 'owner_001',
      ownerName: 'Priya Sharma',
    ),
    const Property(
      id: 'property_008',
      name: 'Palm Grove Residences',
      type: 'Row House',
      location: 'Electronic City, Bangalore, Karnataka',
      city: 'Bangalore',
      price: 11000000,
      area: 1650,
      bedrooms: 3,
      status: 'Ready to Move',
      description:
          'Stylish row house with duplex layout, private courtyard, '
          'and community amenities including a kids play area and jogging track.',
      imageUrl: 'https://picsum.photos/seed/palmgrove/800/600',
      ownerId: 'owner_002',
      ownerName: 'Rohan Kapoor',
    ),
    const Property(
      id: 'property_009',
      name: 'Sunrise Garden Estate',
      type: 'Villa',
      location: 'Baner, Pune, Maharashtra',
      city: 'Pune',
      price: 15500000,
      area: 2200,
      bedrooms: 4,
      status: 'Under Construction',
      description:
          'Upcoming villa project with premium finishes, solar panels, '
          'and rainwater harvesting. Designed for sustainable modern living.',
      imageUrl: 'https://picsum.photos/seed/sunrisegarden/800/600',
      ownerId: 'owner_003',
      ownerName: 'Sneha Reddy',
    ),
    const Property(
      id: 'property_010',
      name: 'Metro Central Flat',
      type: 'Apartment',
      location: 'Kukatpally, Hyderabad, Telangana',
      city: 'Hyderabad',
      price: 5500000,
      area: 1100,
      bedrooms: 2,
      status: 'Sold Out',
      description:
          'Well-maintained apartment near metro connectivity with covered parking '
          'and power backup. Currently sold out — waitlist available.',
      imageUrl: 'https://picsum.photos/seed/metrocentral/800/600',
      ownerId: 'owner_001',
      ownerName: 'Priya Sharma',
    ),
    const Property(
      id: 'property_011',
      name: 'Harbour View Towers',
      type: 'Apartment',
      location: 'Powai, Mumbai, Maharashtra',
      city: 'Mumbai',
      price: 17500000,
      area: 1350,
      bedrooms: 3,
      status: 'Ready to Move',
      description:
          'High-rise apartment overlooking the lake with premium club facilities, '
          'concierge services, and world-class fitness centre.',
      imageUrl: 'https://picsum.photos/seed/harbourview/800/600',
      ownerId: 'owner_002',
      ownerName: 'Rohan Kapoor',
    ),
    const Property(
      id: 'property_012',
      name: 'Heritage Lane Homes',
      type: 'Row House',
      location: 'South Delhi, Delhi',
      city: 'Delhi',
      price: 12500000,
      area: 1950,
      bedrooms: 3,
      status: 'Available',
      description:
          'Charming row house blending heritage aesthetics with modern comforts. '
          'Quiet residential lane with parks and markets within walking distance.',
      imageUrl: 'https://picsum.photos/seed/heritagelane/800/600',
      ownerId: 'owner_003',
      ownerName: 'Sneha Reddy',
    ),
  ];

  /// Seed interests so owner dashboards are not empty on first login.
  static final List<Interest> seedInterests = [
    Interest(
      id: 'interest_seed_001',
      propertyId: 'property_001',
      propertyName: 'Modern Skyline Apartment',
      ownerId: 'owner_001',
      userName: 'Karan Patel',
      mobile: '9876543210',
      email: 'karan.patel@example.com',
      message: 'I would like to schedule a site visit this weekend.',
      submittedAt: DateTime(2026, 9, 8, 10, 30),
    ),
    Interest(
      id: 'interest_seed_002',
      propertyId: 'property_002',
      propertyName: 'Green Valley Villa',
      ownerId: 'owner_001',
      userName: 'Meera Iyer',
      mobile: '9123456780',
      email: 'meera.iyer@example.com',
      message: 'Interested in financing options for this villa.',
      submittedAt: DateTime(2026, 9, 9, 14, 15),
    ),
    Interest(
      id: 'interest_seed_003',
      propertyId: 'property_003',
      propertyName: 'Urban Nest Apartment',
      ownerId: 'owner_002',
      userName: 'Vikram Singh',
      mobile: '9988776655',
      email: 'vikram.singh@example.com',
      message: 'Please share floor plans and available units.',
      submittedAt: DateTime(2026, 9, 10, 9, 0),
    ),
  ];
}
