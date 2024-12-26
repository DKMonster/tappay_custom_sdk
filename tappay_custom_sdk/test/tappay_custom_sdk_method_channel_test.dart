import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tappay_custom_sdk/tappay_custom_sdk_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelTappayCustomSdk platform = MethodChannelTappayCustomSdk();
  const MethodChannel channel = MethodChannel('tappay_custom_sdk');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'setupSDK':
            return null;
          case 'getCardPrime':
            return {'prime': 'test_prime_123'};
          default:
            throw PlatformException(
              code: 'UNIMPLEMENTED',
              message: 'Method not implemented',
            );
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('setupSDK', () async {
    await platform.setupSDK(
      appId: 12345,
      appKey: 'test_key',
      isDebug: true,
    );
  });

  test('getCardPrime', () async {
    final result = await platform.getCardPrime(
      cardNumber: '4242424242424242',
      dueMonth: '01',
      dueYear: '23',
      ccv: '123',
    );

    expect(result, isA<Map<String, dynamic>>());
    expect(result['prime'], 'test_prime_123');
  });
}
