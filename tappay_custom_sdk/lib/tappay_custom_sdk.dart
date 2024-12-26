import 'tappay_custom_sdk_platform_interface.dart';

class TappayCustomSdk {
  // 初始化 SDK
  Future<void> setupSDK(
      {required int appId, required String appKey, required bool isDebug}) {
    return TappayCustomSdkPlatform.instance
        .setupSDK(appId: appId, appKey: appKey, isDebug: isDebug);
  }

  // 取得信用卡 Prime
  Future<Map<String, dynamic>> getCardPrime(
      {required String cardNumber,
      required String dueMonth,
      required String dueYear,
      required String ccv}) {
    return TappayCustomSdkPlatform.instance.getCardPrime(
        cardNumber: cardNumber, dueMonth: dueMonth, dueYear: dueYear, ccv: ccv);
  }
}
