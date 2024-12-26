import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'tappay_custom_sdk_method_channel.dart';

abstract class TappayCustomSdkPlatform extends PlatformInterface {
  /// Constructs a TappayCustomSdkPlatform.
  TappayCustomSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static TappayCustomSdkPlatform _instance = MethodChannelTappayCustomSdk();

  /// The default instance of [TappayCustomSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelTappayCustomSdk].
  static TappayCustomSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TappayCustomSdkPlatform] when
  /// they register themselves.
  static set instance(TappayCustomSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // 初始化 SDK
  Future<void> setupSDK(
      {required int appId, required String appKey, required bool isDebug}) {
    throw UnimplementedError('setupSDK() has not been implemented.');
  }

  // 取得信用卡 Prime
  Future<Map<String, dynamic>> getCardPrime(
      {required String cardNumber,
      required String dueMonth,
      required String dueYear,
      required String ccv}) {
    throw UnimplementedError('getCardPrime() has not been implemented.');
  }
}
