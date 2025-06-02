# TapPay Custom SDK

TapPay Custom SDK 是一個 Flutter 插件，用於整合 TapPay 支付功能到 Flutter 應用程式中。

## 功能特點

- 支援信用卡支付
- 卡片資訊驗證
- 自訂卡片樣式
- 完整的錯誤處理
- 支援 iOS 和 Android 平台

## 安裝

在 `pubspec.yaml` 中加入：

```yaml
dependencies:
  tappay_custom_sdk: ^1.0.0
```

## 使用方法

### 初始化 SDK

```dart
import 'package:tappay_custom_sdk/src/core/tappay_config.dart';
import 'package:tappay_custom_sdk/src/core/tappay_sdk.dart';

// 初始化 SDK
final config = TapPayConfig(
  appId: 'YOUR_APP_ID',
  appKey: 'YOUR_APP_KEY',
  isProduction: false,
);

await TapPaySDK.instance.initialize(config);
```

### 處理支付

```dart
import 'package:tappay_custom_sdk/src/models/payment_info.dart';

// 建立支付資訊
final paymentInfo = PaymentInfo(
  amount: '100',
  currency: 'TWD',
  orderNumber: 'ORDER_123',
);

// 處理支付
final result = await TapPaySDK.instance.directPay.pay(paymentInfo);

if (result.success) {
  print('支付成功！交易編號：${result.transactionId}');
} else {
  print('支付失敗：${result.message}');
}
```

### 驗證卡片

```dart
final isValid = await TapPaySDK.instance.directPay.isCardValid(
  cardNumber: '4242424242424242',
  expiryDate: '1225',
  securityCode: '123',
);

if (isValid) {
  print('卡片資訊有效');
} else {
  print('卡片資訊無效');
}
```

## 平台設定

### iOS

在 `ios/Podfile` 中加入：

```ruby
pod 'TPDirect', '~> 2.0.0'
```

在 `ios/Runner/Info.plist` 中加入：

```xml
<key>NSCameraUsageDescription</key>
<string>需要使用相機來掃描信用卡</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>需要存取相簿來選擇信用卡照片</string>
```

### Android

在 `android/app/build.gradle` 中加入：

```gradle
dependencies {
    implementation 'com.github.cherri-tap:TapPay-Android-SDK:2.0.0'
}
```

在 `android/build.gradle` 中加入：

```gradle
allprojects {
    repositories {
        maven { url 'https://jitpack.io' }
    }
}
```

## 錯誤處理

SDK 會回傳以下錯誤：

- `INVALID_CONFIG`: 初始化配置無效
- `INITIALIZATION_FAILED`: SDK 初始化失敗
- `INVALID_ARGUMENTS`: 參數無效
- `PAYMENT_FAILED`: 支付失敗

## 範例

查看 [example](example) 目錄以獲取完整的使用範例。

## 授權

MIT License
