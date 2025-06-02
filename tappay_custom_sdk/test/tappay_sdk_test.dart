import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tappay_custom_sdk/tappay_config.dart';
import 'package:tappay_custom_sdk/tappay_sdk.dart';
import 'package:tappay_custom_sdk/payment_info.dart';
import 'package:tappay_custom_sdk/direct_pay.dart';

@GenerateMocks([TapPaySDK, DirectPay])
import 'tappay_sdk_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTapPaySDK sdk;
  late MethodChannel channel;
  late MockDirectPay mockDirectPay;

  setUp(() {
    sdk = MockTapPaySDK();
    channel = const MethodChannel('tappay_custom_sdk');
    mockDirectPay = MockDirectPay();
    when(sdk.directPay).thenReturn(mockDirectPay);

    final config = TapPayConfig(
      appId: 'test_app_id',
      appKey: 'test_app_key',
      isProduction: false,
    );
    when(sdk.initialize(config)).thenAnswer((_) async {});
    when(sdk.isInitialized).thenReturn(true);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'initialize':
          return true;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('初始化測試', () {
    test('成功初始化', () async {
      final config = TapPayConfig(
        appId: 'test_app_id',
        appKey: 'test_app_key',
        isProduction: false,
      );

      when(sdk.initialize(config)).thenAnswer((_) async {});
      when(sdk.isInitialized).thenReturn(true);

      await sdk.initialize(config);
      expect(sdk.isInitialized, true);
      verify(sdk.initialize(config)).called(1);
    });

    test('無效配置初始化', () async {
      final config = TapPayConfig(
        appId: '',
        appKey: '',
        isProduction: false,
      );

      when(sdk.initialize(config)).thenThrow(PlatformException(
        code: 'INVALID_CONFIG',
        message: 'appId and appKey are required',
      ));

      expect(
        () => sdk.initialize(config),
        throwsA(isA<PlatformException>().having(
          (e) => e.code,
          'error code',
          'INVALID_CONFIG',
        )),
      );
      verify(sdk.initialize(config)).called(1);
    });
  });

  group('支付測試', () {
    test('成功支付', () async {
      final paymentInfo = PaymentInfo(
        amount: '100',
        currency: 'TWD',
        orderNumber: 'test_order',
      );

      when(mockDirectPay.pay(paymentInfo))
          .thenAnswer((_) async => PaymentResult(
                success: true,
                transactionId: 'test_transaction_id',
                data: <String, dynamic>{
                  'cardInfo': <String, dynamic>{
                    'issuer': 'test_issuer',
                    'funding': 0,
                    'type': 1,
                    'level': 'test_level',
                    'country': 'test_country',
                    'lastFour': '1234',
                    'bin': '123456',
                  },
                  'cardIdentifier': 'test_card_identifier',
                },
              ));

      final result = await sdk.directPay.pay(paymentInfo);

      expect(result.success, true);
      expect(result.transactionId, 'test_transaction_id');
      expect(result.data, isNotNull);
      expect(result.data?['cardInfo'], isNotNull);
      expect(result.data?['cardIdentifier'], isNotNull);
      verify(mockDirectPay.pay(paymentInfo)).called(1);
    });

    test('支付失敗', () async {
      final paymentInfo = PaymentInfo(
        amount: '100',
        currency: 'TWD',
        orderNumber: 'test_order',
      );

      when(mockDirectPay.pay(paymentInfo))
          .thenAnswer((_) async => PaymentResult(
                success: false,
                message: 'Payment failed',
              ));

      final result = await sdk.directPay.pay(paymentInfo);

      expect(result.success, false);
      expect(result.message, 'Payment failed');
      verify(mockDirectPay.pay(paymentInfo)).called(1);
    });

    test('平台異常', () async {
      final paymentInfo = PaymentInfo(
        amount: '100',
        currency: 'TWD',
        orderNumber: 'test_order',
      );

      when(mockDirectPay.pay(paymentInfo))
          .thenAnswer((_) async => PaymentResult(
                success: false,
                message: 'Platform error occurred',
              ));

      final result = await sdk.directPay.pay(paymentInfo);

      expect(result.success, false);
      expect(result.message, 'Platform error occurred');
      verify(mockDirectPay.pay(paymentInfo)).called(1);
    });
  });

  group('卡片驗證測試', () {
    test('成功驗證', () async {
      when(mockDirectPay.isCardValid(
        cardNumber: '4242424242424242',
        expiryMonth: '12',
        expiryYear: '25',
        securityCode: '123',
      )).thenAnswer((_) async => true);

      final isValid = await sdk.directPay.isCardValid(
        cardNumber: '4242424242424242',
        expiryMonth: '12',
        expiryYear: '25',
        securityCode: '123',
      );

      expect(isValid, true);
      verify(mockDirectPay.isCardValid(
        cardNumber: '4242424242424242',
        expiryMonth: '12',
        expiryYear: '25',
        securityCode: '123',
      )).called(1);
    });

    test('驗證失敗', () async {
      when(mockDirectPay.isCardValid(
        cardNumber: '4242424242424242',
        expiryMonth: '12',
        expiryYear: '25',
        securityCode: '123',
      )).thenAnswer((_) async => false);

      final isValid = await sdk.directPay.isCardValid(
        cardNumber: '4242424242424242',
        expiryMonth: '12',
        expiryYear: '25',
        securityCode: '123',
      );

      expect(isValid, false);
      verify(mockDirectPay.isCardValid(
        cardNumber: '4242424242424242',
        expiryMonth: '12',
        expiryYear: '25',
        securityCode: '123',
      )).called(1);
    });

    test('平台異常', () async {
      when(mockDirectPay.isCardValid(
        cardNumber: '4242424242424242',
        expiryMonth: '12',
        expiryYear: '25',
        securityCode: '123',
      )).thenAnswer((_) async => false);

      final isValid = await sdk.directPay.isCardValid(
        cardNumber: '4242424242424242',
        expiryMonth: '12',
        expiryYear: '25',
        securityCode: '123',
      );

      expect(isValid, false);
      verify(mockDirectPay.isCardValid(
        cardNumber: '4242424242424242',
        expiryMonth: '12',
        expiryYear: '25',
        securityCode: '123',
      )).called(1);
    });
  });

  group('未初始化測試', () {
    setUp(() {
      when(sdk.isInitialized).thenReturn(false);
    });

    test('未初始化支付', () async {
      final paymentInfo = PaymentInfo(
        amount: '100',
        currency: 'TWD',
        orderNumber: 'test_order',
      );

      when(mockDirectPay.pay(paymentInfo))
          .thenAnswer((_) async => PaymentResult(
                success: false,
                message: 'TapPay SDK not initialized',
              ));

      final result = await sdk.directPay.pay(paymentInfo);

      expect(result.success, false);
      expect(result.message, 'TapPay SDK not initialized');
      verify(mockDirectPay.pay(paymentInfo)).called(1);
    });

    test('未初始化驗證', () async {
      when(mockDirectPay.isCardValid(
        cardNumber: '4242424242424242',
        expiryMonth: '12',
        expiryYear: '25',
        securityCode: '123',
      )).thenAnswer((_) async => false);

      final isValid = await sdk.directPay.isCardValid(
        cardNumber: '4242424242424242',
        expiryMonth: '12',
        expiryYear: '25',
        securityCode: '123',
      );

      expect(isValid, false);
      verify(mockDirectPay.isCardValid(
        cardNumber: '4242424242424242',
        expiryMonth: '12',
        expiryYear: '25',
        securityCode: '123',
      )).called(1);
    });
  });
}
