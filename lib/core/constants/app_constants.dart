class AppConstants {
  static const String appName = 'NestFind';
  static const String appTagline = 'Find your perfect property';

  static const List<String> locations = [
    'Kolkata',
    'Bangalore',
    'Pune',
    'Hyderabad',
    'Mumbai',
    'Delhi',
  ];

  static const List<String> propertyTypes = [
    'Apartment',
    'Villa',
    'Row House',
  ];

  static const List<String> statuses = [
    'Ready to Move',
    'Under Construction',
    'Available',
    'Sold Out',
  ];

  static const List<int> bedroomOptions = [1, 2, 3, 4, 5];

  static const Duration mockDelay = Duration(milliseconds: 500);
  static const Duration mockLoginDelay = Duration(milliseconds: 700);
}

class DemoCredentials {
  static const String userEmail = 'user@test.com';
  static const String userPassword = 'user123';

  static const String ownerEmail = 'owner@test.com';
  static const String ownerPassword = 'owner123';

  static const String owner2Email = 'owner2@test.com';
  static const String owner2Password = 'owner123';

  static const String owner3Email = 'owner3@test.com';
  static const String owner3Password = 'owner123';
}
