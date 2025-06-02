import Flutter
import UIKit

public class SwiftTappayCustomSdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "tappay_custom_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftTappayCustomSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // 只負責資料轉發，讓 App 端處理 TPDirectSDK
        NotificationCenter.default.post(name: NSNotification.Name("TapPayMethodCall"), object: nil, userInfo: [
            "method": call.method,
            "args": call.arguments as Any,
            "result": result
        ])
    }
}
