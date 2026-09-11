import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing_prototype/core/validators/validators.dart';

void main() {
  group('Validators', () {
    test('email validator', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('bad'), isNotNull);
      expect(Validators.email('user@test.com'), isNull);
    });

    test('password validator', () {
      expect(Validators.password(null), isNotNull);
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('user123'), isNull);
    });

    test('phone validator', () {
      expect(Validators.phone(null), isNotNull);
      expect(Validators.phone('12345'), isNotNull);
      expect(Validators.phone('abcdefghij'), isNotNull);
      expect(Validators.phone('9876543210'), isNull);
      expect(Validators.phone('+91 98765 43210'), isNull);
    });

    test('name validator', () {
      expect(Validators.name(''), isNotNull);
      expect(Validators.name('A'), isNotNull);
      expect(Validators.name('John Doe'), isNull);
    });
  });
}
