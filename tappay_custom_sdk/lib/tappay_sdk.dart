import 'package:flutter/services.dart';
import 'tappay_config.dart';
import 'payment_info.dart';
import 'direct_pay.dart';

class TapPaySDK {
  static TapPaySDK? _instance;
  TapPayConfig? _config;
  static const MethodChannel _channel = MethodChannel('tappay_custom_sdk');

  // 支付方式實例
  late final DirectPay directPay;

  TapPaySDK._() {
    directPay = DirectPay(this);
  }

  static TapPaySDK get instance {
    _instance ??= TapPaySDK._();
    return _instance!;
  }

  bool get isInitialized => _config != null;

  Future<void> initialize(TapPayConfig config) async {
    if (config.appId.isEmpty || config.appKey.isEmpty) {
      throw PlatformException(
        code: 'INVALID_CONFIG',
        message: 'appId and appKey are required',
      );
    }

    _config = config;
    try {
      final result = await _channel.invokeMethod('initialize', config.toJson());
      if (result == null) {
        throw PlatformException(
          code: 'INITIALIZATION_FAILED',
          message: 'Failed to initialize TapPay SDK',
        );
      }

      // 初始化各支付方式
      await Future.wait([
        directPay.initialize(),
      ]);
    } catch (e) {
      _config = null;
      throw PlatformException(
        code: 'INITIALIZATION_FAILED',
        message: 'Failed to initialize TapPay SDK: $e',
      );
    }
  }
}
