import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'tappay_custom_sdk_platform_interface.dart';

/// An implementation of [TappayCustomSdkPlatform] that uses method channels.
class MethodChannelTappayCustomSdk extends TappayCustomSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('tappay_custom_sdk');

  @override
  Future<void> setupSDK(
      {required int appId,
      required String appKey,
      required bool isDebug}) async {
    try {
      await methodChannel.invokeMethod('setupSDK', {
        'appId': appId,
        'appKey': appKey,
        'isDebug': isDebug,
      });
    } catch (e) {
      throw Exception('Failed to setup SDK: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getCardPrime(
      {required String cardNumber,
      required String dueMonth,
      required String dueYear,
      required String ccv}) async {
    try {
      final result = await methodChannel.invokeMethod('getCardPrime', {
        'cardNumber': cardNumber,
        'dueMonth': dueMonth,
        'dueYear': dueYear,
        'ccv': ccv,
      });

      return Map<String, dynamic>.from(result);
    } catch (e) {
      throw Exception('Failed to get card prime: $e');
    }
  }
}
