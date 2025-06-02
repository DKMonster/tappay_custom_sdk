import Foundation
import TPDirect
import Flutter

@objc class TPDirectBridge: NSObject {
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleMethodCall(_:)), name: NSNotification.Name("TapPayMethodCall"), object: nil)
    }

    @objc func handleMethodCall(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let method = userInfo["method"] as? String,
              let args = userInfo["args"] as? [String: Any],
              let result = userInfo["result"] as? FlutterResult else { return }

        switch method {
        case "initialize":
            guard let appId = args["appId"] as? Int,
                  let appKey = args["appKey"] as? String,
                  let serverType = args["serverType"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for initialize", details: nil))
                return
            }
            let env: TPDServerType = (serverType == "production") ? .production : .sandBox
            TPDSetup.setWithAppId(Int32(appId), withAppKey: appKey, with: env)
            result(true)
        case "pay":
            guard let cardNumber = args["cardNumber"] as? String,
                  let expiryMonth = args["expiryMonth"] as? Int,
                  let expiryYear = args["expiryYear"] as? Int,
                  let ccv = args["ccv"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for pay", details: nil))
                return
            }
            let card = TPDCard.setWithCardNumber(cardNumber, withDueMonth: String(format: "%02d", expiryMonth), withDueYear: String(expiryYear), withCCV: ccv)
            card.onSuccessCallback { prime, cardInfo, cardIdentifier, merchantReferenceInfo in
                let cardInfoDict: [String: Any] = [
                    "issuer": cardInfo?.issuer ?? "",
                    "funding": cardInfo?.funding ?? 0,
                    "cardType": cardInfo?.cardType ?? 0,
                    "level": cardInfo?.level ?? "",
                    "country": cardInfo?.country ?? "",
                    "lastFour": cardInfo?.lastFour ?? ""
                ]
                let response: [String: Any] = [
                    "success": true,
                    "prime": prime ?? "",
                    "cardInfo": cardInfoDict,
                    "cardIdentifier": cardIdentifier ?? "",
                    "merchantReferenceInfo": merchantReferenceInfo
                ]
                result(response)
            }.onFailureCallback { status, msg in
                let response: [String: Any] = [
                    "success": false,
                    "message": msg
                ]
                result(response)
            }
            card.getPrime()
        case "isCardValid":
            guard let cardNumber = args["cardNumber"] as? String,
                  let expiryMonth = args["expiryMonth"] as? String,
                  let expiryYear = args["expiryYear"] as? String,
                  let ccv = args["securityCode"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for isCardValid", details: nil))
                return
            }
            let isValid = TPDCard.validate(withCardNumber: cardNumber, withDueMonth: expiryMonth, withDueYear: expiryYear, withCCV: ccv)
            result(isValid)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

// AppDelegate.swift 裡面要初始化 TPDirectBridge
// _ = TPDirectBridge() 
