// Basic smoke test that the app widget tree can be constructed
// with injected mock repositories (offline).

import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing_prototype/app/app.dart';
import 'package:property_listing_prototype/data/repositories/mock_auth_repository.dart';
import 'package:property_listing_prototype/data/repositories/mock_interest_repository.dart';
import 'package:property_listing_prototype/data/repositories/mock_property_repository.dart';

void main() {
  testWidgets('App launches to login screen', (tester) async {
    await tester.pumpWidget(
      PropertyListingApp(
        authRepository: MockAuthRepository(),
        propertyRepository: MockPropertyRepository(),
        interestRepository: MockInterestRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('NestFind'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Demo Credentials'), findsOneWidget);
  });
}
