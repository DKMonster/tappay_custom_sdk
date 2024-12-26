// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:tappay_custom_sdk/tappay_custom_sdk.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TapPay SDK integration test', (WidgetTester tester) async {
    final TappayCustomSdk plugin = TappayCustomSdk();

    // 測試 setupSDK
    await plugin.setupSDK(
      appId: 12345,
      appKey: 'test_key',
      isDebug: true,
    );

    // 測試 getCardPrime
    final result = await plugin.getCardPrime(
      cardNumber: '4242424242424242',
      dueMonth: '01',
      dueYear: '23',
      ccv: '123',
    );

    expect(result, isA<Map<String, dynamic>>());
    expect(result['prime'], isNotNull);
  });
}
