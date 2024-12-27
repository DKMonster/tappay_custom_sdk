import 'package:flutter/material.dart';
import 'package:tappay_custom_sdk/tappay_custom_sdk.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final _tappaySDK = TappayCustomSdk();
  String _result = '';

  Future<void> _setupSDK() async {
    try {
      // for tappay official 11340 and app_whdEWBH8e8Lzy4N6BysVRRMILYORF6UxXbiOFsICkz0J9j1C0JUlCHv1tVJC
      await _tappaySDK.setupSDK(
        appId: 11340,
        appKey:
            'app_whdEWBH8e8Lzy4N6BysVRRMILYORF6UxXbiOFsICkz0J9j1C0JUlCHv1tVJC',
        isDebug: true,
      );
      setState(() {
        _result = 'Setup SDK 成功';
      });
    } catch (e) {
      print(e);
      setState(() {
        _result = 'Setup SDK 失敗: $e';
      });
    }
  }

  Future<void> _getCardPrime() async {
    try {
      final result = await _tappaySDK.getCardPrime(
        cardNumber: '4242424242424242', // 測試卡號
        dueMonth: '01',
        dueYear: '23',
        ccv: '123',
      );
      setState(() {
        _result = '取得 Prime 成功: ${result['prime']}';
      });
    } catch (e) {
      setState(() {
        _result = '取得 Prime 失敗: $e';
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TapPay SDK 測試')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _setupSDK,
              child: const Text('Setup SDK'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getCardPrime,
              child: const Text('Get Card Prime'),
            ),
            const SizedBox(height: 20),
            Text(_result),
          ],
        ),
      ),
    );
  }
}
