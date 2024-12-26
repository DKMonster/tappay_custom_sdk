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
        TPDSetup.setWithAppId(appId, withAppKey: appKey, with: isDebug ? .sandBox : .production)
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for setupSDK", details: nil))
      }
      
    case "getCardPrime":
      if let args = call.arguments as? [String: Any],
         let cardNumber = args["cardNumber"] as? String,
         let dueMonth = args["dueMonth"] as? String,
         let dueYear = args["dueYear"] as? String,
         let ccv = args["ccv"] as? String {
        
        // 建立並設定 TPDForm
        guard let form = TPDForm.setup(withContainer: nil) else {
          result(FlutterError(code: "FORM_ERROR",
                             message: "Failed to setup form",
                             details: nil))
          return
        }
        
        // 驗證卡片資訊
        guard let cardValidation = TPDCard.validate(withCardNumber: cardNumber,
                                                  withDueMonth: dueMonth,
                                                  withDueYear: dueYear,
                                                  withCCV: ccv) else {
          result(FlutterError(code: "VALIDATION_ERROR",
                             message: "Failed to validate card",
                             details: nil))
          return
        }
        
        if cardValidation.isCardNumberValid && 
           cardValidation.isExpiryDateValid && 
           cardValidation.isCCVValid {
          
          // 使用 TPDCard 取得 Prime
          let card = TPDCard.setup(form)
          
          card.onSuccessCallback { (prime, cardInfo, cardIdentifier, merchantReferenceInfo) in
            if let prime = prime {
              let response = ["prime": prime]
              result(response)
            } else {
              result(FlutterError(code: "PRIME_ERROR",
                                message: "Failed to get prime",
                                details: nil))
            }
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
