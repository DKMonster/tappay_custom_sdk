package com.example.tappay_custom_sdk

import android.app.Activity
import android.content.Context
import com.google.gson.Gson
import com.tappay.sdk.TapPay
import com.tappay.sdk.TapPayInstance
import com.tappay.sdk.callback.TapPayCallback
import com.tappay.sdk.model.CardInfo
import com.tappay.sdk.model.PaymentResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import androidx.annotation.NonNull
import com.tappay.sdk.TPDCard
import com.tappay.sdk.TPDCardValidation
import com.tappay.sdk.TPDSetup
import com.tappay.sdk.TPDSetup.Companion.getInstance
import android.graphics.Color
import android.graphics.Typeface
import android.view.View
import android.widget.EditText
import tech.cherri.tpdirect.api.TPDCard as TPDCardTpdirect
import tech.cherri.tpdirect.api.TPDConsumer
import tech.cherri.tpdirect.api.TPDMerchant
import tech.cherri.tpdirect.api.TPDServerType
import tech.cherri.tpdirect.api.TPDSetup as TPDSetupTpdirect

/** TappayCustomSdkPlugin */
class TappayCustomSdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var tpdSetup: TPDSetup
  private var cardNumberEditText: EditText? = null
  private var cardExpiryEditText: EditText? = null
  private var cardCcvEditText: EditText? = null
  private var activity: Activity? = null
  private var context: Context? = null
  private var config: Map<String, Any>? = null
  private val gson = Gson()

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(binding.binaryMessenger, "tappay_custom_sdk")
    channel.setMethodCallHandler(this)
    context = binding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "setupSDK" -> {
        val appId = call.argument<Int>("appId")
        val appKey = call.argument<String>("appKey")
        val isDebug = call.argument<Boolean>("isDebug")

        if (appId == null || appKey == null || isDebug == null) {
          result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
          return
        }

        try {
          tpdSetup = getInstance()
          tpdSetup.initSDK(binding.applicationContext, appId, appKey, isDebug)
          result.success(null)
        } catch (e: Exception) {
          result.error("SETUP_FAILED", e.message, null)
        }
      }
      "getDeviceId" -> {
        try {
          val deviceId = tpdSetup.getDeviceId()
          result.success(deviceId)
        } catch (e: Exception) {
          result.error("GET_DEVICE_ID_FAILED", e.message, null)
        }
      }
      "getCardPrime" -> {
        val cardNumber = call.argument<String>("cardNumber")
        val dueMonth = call.argument<String>("dueMonth")
        val dueYear = call.argument<String>("dueYear")
        val ccv = call.argument<String>("ccv")

        if (cardNumber == null || dueMonth == null || dueYear == null || ccv == null) {
          result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
          return
        }

        try {
          val card = TPDCard()
          card.cardNumber = cardNumber
          card.dueMonth = dueMonth
          card.dueYear = dueYear
          card.ccv = ccv

          card.getPrime { prime, cardInfo, cardIdentifier, status ->
            if (status == 0) {
              val response = mapOf(
                "prime" to prime,
                "cardInfo" to cardInfo?.toMap(),
                "cardIdentifier" to cardIdentifier
              )
              result.success(gson.toJson(response))
            } else {
              result.error("GET_PRIME_FAILED", "Failed to get prime", null)
            }
          }
        } catch (e: Exception) {
          result.error("GET_PRIME_FAILED", e.message, null)
        }
      }
      "validateCard" -> {
        val cardNumber = call.argument<String>("cardNumber")
        val dueMonth = call.argument<String>("dueMonth")
        val dueYear = call.argument<String>("dueYear")
        val ccv = call.argument<String>("ccv")

        if (cardNumber == null || dueMonth == null || dueYear == null || ccv == null) {
          result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
          return
        }

        try {
          val card = TPDCard()
          card.cardNumber = cardNumber
          card.dueMonth = dueMonth
          card.dueYear = dueYear
          card.ccv = ccv

          val validation = TPDCardValidation()
          val isValid = validation.validate(card)
          result.success(isValid)
        } catch (e: Exception) {
          result.error("VALIDATE_CARD_FAILED", e.message, null)
        }
      }
      "getCardInfo" -> {
        val cardNumber = call.argument<String>("cardNumber")

        if (cardNumber == null) {
          result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
          return
        }

        try {
          val card = TPDCard()
          card.cardNumber = cardNumber

          val cardInfo = mapOf(
            "cardType" to card.cardType,
            "cardLastFour" to card.lastFour,
            "cardIssuer" to card.issuer,
            "cardFunding" to card.funding,
            "cardLevel" to card.level,
            "cardCountry" to card.country
          )
          result.success(gson.toJson(cardInfo))
        } catch (e: Exception) {
          result.error("GET_CARD_INFO_FAILED", e.message, null)
        }
      }
      "setCardStyle" -> {
        val style = call.argument<Map<String, Any>>("style")

        if (style == null) {
          result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
          return
        }

        try {
          val cardNumberStyle = style["cardNumberStyle"] as? Map<String, Any>
          val cardExpiryStyle = style["cardExpiryStyle"] as? Map<String, Any>
          val cardCcvStyle = style["cardCcvStyle"] as? Map<String, Any>

          cardNumberStyle?.let { applyStyle(cardNumberEditText, it) }
          cardExpiryStyle?.let { applyStyle(cardExpiryEditText, it) }
          cardCcvStyle?.let { applyStyle(cardCcvEditText, it) }

          result.success(null)
        } catch (e: Exception) {
          result.error("SET_CARD_STYLE_FAILED", e.message, null)
        }
      }
      "initialize" -> handleInitialize(call, result)
      "pay" -> handlePay(call, result)
      "isCardValid" -> handleIsCardValid(call, result)
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun applyStyle(editText: EditText?, style: Map<String, Any>) {
    editText?.let {
      style["color"]?.let { color ->
        it.setTextColor(Color.parseColor(color.toString()))
      }
      style["fontSize"]?.let { fontSize ->
        it.textSize = (fontSize as Number).toFloat()
      }
      style["fontFamily"]?.let { fontFamily ->
        it.typeface = Typeface.create(fontFamily.toString(), Typeface.NORMAL)
      }
      style["backgroundColor"]?.let { backgroundColor ->
        it.setBackgroundColor(Color.parseColor(backgroundColor.toString()))
      }
      style["borderColor"]?.let { borderColor ->
        it.background?.setColorFilter(Color.parseColor(borderColor.toString()))
      }
      style["borderWidth"]?.let { borderWidth ->
        it.background?.setAlpha((borderWidth as Number).toInt())
      }
      style["borderRadius"]?.let { borderRadius ->
        it.background?.setAlpha((borderRadius as Number).toInt())
      }
    }
  }

  private fun handleInitialize(call: MethodCall, result: Result) {
    val appId = call.argument<Int>("appId")
    val appKey = call.argument<String>("appKey")
    val serverType = call.argument<String>("serverType")

    if (appId == null || appKey == null || serverType == null) {
      result.error("INVALID_ARGUMENTS", "Invalid arguments for initialize", null)
      return
    }

    // TODO: 實作 TapPay SDK 初始化
    result.success(true)
  }

  private fun handlePay(call: MethodCall, result: Result) {
    val amount = call.argument<Int>("amount")
    val currency = call.argument<String>("currency")
    val cardNumber = call.argument<String>("cardNumber")
    val expiryMonth = call.argument<Int>("expiryMonth")
    val expiryYear = call.argument<Int>("expiryYear")
    val ccv = call.argument<String>("ccv")

    if (amount == null || currency == null || cardNumber == null || 
        expiryMonth == null || expiryYear == null || ccv == null) {
      result.error("INVALID_ARGUMENTS", "Invalid arguments for pay", null)
      return
    }

    // TODO: 實作 TapPay SDK 支付功能
    val response = mapOf(
      "success" to true,
      "message" to "Payment successful",
      "transactionId" to "123456789"
    )
    result.success(response)
  }

  private fun handleIsCardValid(call: MethodCall, result: Result) {
    val cardNumber = call.argument<String>("cardNumber")
    val expiryMonth = call.argument<Int>("expiryMonth")
    val expiryYear = call.argument<Int>("expiryYear")
    val ccv = call.argument<String>("ccv")

    if (cardNumber == null || expiryMonth == null || expiryYear == null || ccv == null) {
      result.error("INVALID_ARGUMENTS", "Invalid arguments for isCardValid", null)
      return
    }

    // TODO: 實作 TapPay SDK 卡片驗證功能
    result.success(true)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }
}

private fun CardInfo?.toMap(): Map<String, Any>? {
  if (this == null) return null
  return mapOf(
    "issuer" to (issuer ?: ""),
    "funding" to (funding ?: 0),
    "type" to (type ?: 0),
    "level" to (level ?: ""),
    "country" to (country ?: ""),
    "lastFour" to (lastFour ?: ""),
    "binCode" to (binCode ?: "")
  )
}
