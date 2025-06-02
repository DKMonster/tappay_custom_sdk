import 'dart:developer';

import 'package:flutter/services.dart';
import 'tappay_sdk.dart';
import 'payment_info.dart';

class DirectPay {
  final TapPaySDK _sdk;
  static const MethodChannel _channel = MethodChannel('tappay_custom_sdk');

  DirectPay(this._sdk);

  Future<void> initialize() async {
    // DirectPay 不需要額外的初始化
  }

  Future<PaymentResult> pay(PaymentInfo paymentInfo) async {
    try {
      final result = await _channel.invokeMethod('pay', paymentInfo.toJson());

      if (result == null) {
        return PaymentResult(
          success: false,
          message: 'No response from platform',
        );
      }

      if (result is! Map) {
        return PaymentResult(
          success: false,
          message: 'Invalid response format',
        );
      }

      return PaymentResult.fromJson(Map<String, dynamic>.from(result));
    } catch (e) {
      return PaymentResult(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<bool> isCardValid({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String securityCode,
  }) async {
    try {
      log('isCardValid');
      log('cardNumber: $cardNumber');
      log('expiryMonth: $expiryMonth');
      log('expiryYear: $expiryYear');
      log('securityCode: $securityCode');

      final result = await _channel.invokeMethod('isCardValid', {
        'cardNumber': cardNumber,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'securityCode': securityCode,
      });
      return result as bool;
    } catch (e) {
      log('isCardValid error: $e');
      return false;
    }
  }
}
