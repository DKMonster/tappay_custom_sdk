import 'package:flutter_test/flutter_test.dart';
import 'package:tappay_custom_sdk/tappay_custom_sdk.dart';
import 'package:tappay_custom_sdk/tappay_custom_sdk_platform_interface.dart';
import 'package:tappay_custom_sdk/tappay_custom_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTappayCustomSdkPlatform
    with MockPlatformInterfaceMixin
    implements TappayCustomSdkPlatform {
  @override
  Future<void> setupSDK({
    required int appId,
    required String appKey,
    required bool isDebug,
  }) async {}

  @override
  Future<Map<String, dynamic>> getCardPrime({
    required String cardNumber,
    required String dueMonth,
    required String dueYear,
    required String ccv,
  }) async {
    return {'prime': 'test_prime_123'};
  }
}

void main() {
  final TappayCustomSdkPlatform initialPlatform =
      TappayCustomSdkPlatform.instance;

  test('$MethodChannelTappayCustomSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTappayCustomSdk>());
  });

  test('setupSDK', () async {
    final plugin = TappayCustomSdk();
    final platform = MockTappayCustomSdkPlatform();
    TappayCustomSdkPlatform.instance = platform;

    await plugin.setupSDK(
      appId: 12345,
      appKey: 'test_key',
      isDebug: true,
    );
  });

  test('getCardPrime', () async {
    final plugin = TappayCustomSdk();
    final platform = MockTappayCustomSdkPlatform();
    TappayCustomSdkPlatform.instance = platform;

    final result = await plugin.getCardPrime(
      cardNumber: '4242424242424242',
      dueMonth: '01',
      dueYear: '23',
      ccv: '123',
    );

    expect(result, isA<Map<String, dynamic>>());
    expect(result['prime'], 'test_prime_123');
  });
}
