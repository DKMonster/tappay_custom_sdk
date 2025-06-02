import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tappay_custom_sdk/tappay_sdk.dart';
import 'package:tappay_custom_sdk/tappay_config.dart';
import 'package:tappay_custom_sdk/payment_info.dart';
import 'package:tappay_custom_sdk/direct_pay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TapPay SDK Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PaymentPage(),
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _securityCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _initializeSDK();
  }

  Future<void> _initializeSDK() async {
    try {
      final config = TapPayConfig(
        appId: '',
        appKey: '',
        isProduction: false,
      );

      await TapPaySDK.instance.initialize(config);
    } catch (e) {
      setState(() {
        _errorMessage = '初始化失敗：$e';
      });
    }
  }

  Future<void> _processPayment() async {
    log('processPayment');
    if (!_formKey.currentState!.validate()) return;
    log('validate');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    log('isCardValid');
    log('cardNumber: ${_cardNumberController.text}');
    log('expiryDate: ${_expiryDateController.text}');
    log('securityCode: ${_securityCodeController.text}');

    try {
      final expiry = _expiryDateController.text;
      final expiryMonth = expiry.substring(0, 2);
      final expiryYear = expiry.substring(2, 4);

      // 驗證卡片
      final isValid = await TapPaySDK.instance.directPay.isCardValid(
        cardNumber: _cardNumberController.text,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        securityCode: _securityCodeController.text,
      );

      log('isValid: $isValid');

      if (!isValid) {
        setState(() {
          _errorMessage = '卡片資訊無效';
          _isLoading = false;
        });
        return;
      }

      // 處理支付
      final paymentInfo = PaymentInfo(
        amount: '100',
        currency: 'TWD',
        orderNumber: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      final result = await TapPaySDK.instance.directPay.pay(paymentInfo);

      setState(() {
        if (result.success) {
          _successMessage = '支付成功！交易編號：${result.transactionId}';
        } else {
          _errorMessage = result.message ?? '支付失敗';
        }
      });
    } catch (e) {
      log('error: $e');
      setState(() {
        _errorMessage = '處理支付時發生錯誤：$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TapPay SDK Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: '卡片號碼',
                  hintText: '4242 4242 4242 4242',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請輸入卡片號碼';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryDateController,
                      decoration: const InputDecoration(
                        labelText: '到期日',
                        hintText: 'MM/YY',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '請輸入到期日';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _securityCodeController,
                      decoration: const InputDecoration(
                        labelText: '安全碼',
                        hintText: '123',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '請輸入安全碼';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('支付'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _securityCodeController.dispose();
    super.dispose();
  }
}
