import Flutter
import UIKit
import TPDirect

public class TappayCustomSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tappay_custom_sdk", binaryMessenger: registrar.messenger())
    let instance = TappayCustomSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setupSDK":
      if let args = call.arguments as? [String: Any],
         let appId = args["appId"] as? Int32,
         let appKey = args["appKey"] as? String,
         let isDebug = args["isDebug"] as? Bool {
        
        // 設定 SDK
        TPDSetup.setWithAppId(appId, withAppKey: appKey, with: isDebug ? .sandBox : .production)
        
        // 檢查 SDK 狀態
        let status = TPDStatus()
        if !status.isHasAnyError() {
          result(nil)
        } else {
          result(FlutterError(code: "SETUP_ERROR",
                             message: "Failed to initialize TapPay SDK",
                             details: nil))
        }
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS",
                           message: "Invalid arguments for setupSDK",
                           details: nil))
      }
      
    case "getCardPrime":
      if let args = call.arguments as? [String: Any],
         let cardNumber = args["cardNumber"] as? String,
         let dueMonth = args["dueMonth"] as? String,
         let dueYear = args["dueYear"] as? String,
         let ccv = args["ccv"] as? String {
        
        // 確保在主線程中執行 UI 相關操作
        DispatchQueue.main.async {
          // 創建一個容器視圖
          let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
          
          // 設置 TPDForm
          let tpdForm = TPDForm.setup(withContainer: containerView)
          
          // 設置卡片資訊
          tpdForm.setCardNumber(cardNumber)
          tpdForm.setExpiryMonth(dueMonth)
          tpdForm.setExpiryYear(dueYear)
          tpdForm.setCCV(ccv)
          
          // 獲取 prime
          if tpdForm.isCanGetPrime() {
            tpdForm.onSuccessCallback { prime in
              result(["prime": prime])
            }.onFailureCallback { status, message in
              result(FlutterError(code: String(status),
                                message: message,
                                details: nil))
            }.getPrime()
          } else {
            result(FlutterError(code: "INVALID_CARD",
                               message: "Invalid card information",
                               details: nil))
          }
        }
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS",
                           message: "Invalid arguments for getCardPrime",
                           details: nil))
      }
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
