package com.example.tappay_custom_sdk

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.junit.Before
import org.junit.Test
import org.mockito.Mock
import org.mockito.Mockito.*
import org.mockito.MockitoAnnotations

/*
 * This demonstrates a simple unit test of the Kotlin portion of this plugin's implementation.
 *
 * Once you have built the plugin's example app, you can run these tests from the command
 * line by running `./gradlew testDebugUnitTest` in the `example/android/` directory, or
 * you can run them directly from IDEs that support JUnit such as Android Studio.
 */

class TappayCustomSdkPluginTest {
    @Mock
    private lateinit var mockResult: MethodChannel.Result

    @Mock
    private lateinit var mockFlutterPluginBinding: io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

    private lateinit var plugin: TappayCustomSdkPlugin

    @Before
    fun setup() {
        MockitoAnnotations.openMocks(this)
        plugin = TappayCustomSdkPlugin()
        plugin.onAttachedToEngine(mockFlutterPluginBinding)
    }

    @Test
    fun `test setupSDK with valid arguments`() {
        val call = MethodCall(
            "setupSDK",
            mapOf(
                "appId" to 12345,
                "appKey" to "test_key",
                "isDebug" to true
            )
        )

        plugin.onMethodCall(call, mockResult)
        verify(mockResult).success(null)
    }

    @Test
    fun `test setupSDK with invalid arguments`() {
        val call = MethodCall(
            "setupSDK",
            mapOf(
                "appId" to 12345,
                "appKey" to "test_key"
                // Missing isDebug
            )
        )

        plugin.onMethodCall(call, mockResult)
        verify(mockResult).error(
            "INVALID_ARGUMENTS",
            "Missing required arguments",
            null
        )
    }

    @Test
    fun `test getDeviceId`() {
        val call = MethodCall("getDeviceId", null)

        plugin.onMethodCall(call, mockResult)
        verify(mockResult).success(any())
    }

    @Test
    fun `test getCardPrime with valid arguments`() {
        val call = MethodCall(
            "getCardPrime",
            mapOf(
                "cardNumber" to "4242424242424242",
                "dueMonth" to "12",
                "dueYear" to "25",
                "ccv" to "123"
            )
        )

        plugin.onMethodCall(call, mockResult)
        verify(mockResult).success(any())
    }

    @Test
    fun `test getCardPrime with invalid arguments`() {
        val call = MethodCall(
            "getCardPrime",
            mapOf(
                "cardNumber" to "4242424242424242",
                "dueMonth" to "12",
                "dueYear" to "25"
                // Missing ccv
            )
        )

        plugin.onMethodCall(call, mockResult)
        verify(mockResult).error(
            "INVALID_ARGUMENTS",
            "Missing required arguments",
            null
        )
    }

    @Test
    fun `test validateCard with valid arguments`() {
        val call = MethodCall(
            "validateCard",
            mapOf(
                "cardNumber" to "4242424242424242",
                "dueMonth" to "12",
                "dueYear" to "25",
                "ccv" to "123"
            )
        )

        plugin.onMethodCall(call, mockResult)
        verify(mockResult).success(any())
    }

    @Test
    fun `test validateCard with invalid arguments`() {
        val call = MethodCall(
            "validateCard",
            mapOf(
                "cardNumber" to "4242424242424242",
                "dueMonth" to "12",
                "dueYear" to "25"
                // Missing ccv
            )
        )

        plugin.onMethodCall(call, mockResult)
        verify(mockResult).error(
            "INVALID_ARGUMENTS",
            "Missing required arguments",
            null
        )
    }

    @Test
    fun `test getCardInfo with valid arguments`() {
        val call = MethodCall(
            "getCardInfo",
            mapOf(
                "cardNumber" to "4242424242424242"
            )
        )

        plugin.onMethodCall(call, mockResult)
        verify(mockResult).success(any())
    }

    @Test
    fun `test getCardInfo with invalid arguments`() {
        val call = MethodCall(
            "getCardInfo",
            mapOf<String, Any>()
            // Missing cardNumber
        )

        plugin.onMethodCall(call, mockResult)
        verify(mockResult).error(
            "INVALID_ARGUMENTS",
            "Missing required arguments",
            null
        )
    }

    @Test
    fun `test setCardStyle with valid arguments`() {
        val call = MethodCall(
            "setCardStyle",
            mapOf(
                "style" to mapOf(
                    "cardNumberStyle" to mapOf(
                        "color" to "#000000",
                        "fontSize" to 16.0,
                        "fontFamily" to "Arial",
                        "backgroundColor" to "#FFFFFF",
                        "borderColor" to "#CCCCCC",
                        "borderWidth" to 1.0,
                        "borderRadius" to 4.0
                    )
                )
            )
        )

        plugin.onMethodCall(call, mockResult)
        verify(mockResult).success(null)
    }

    @Test
    fun `test setCardStyle with invalid arguments`() {
        val call = MethodCall(
            "setCardStyle",
            mapOf<String, Any>()
            // Missing style
        )

        plugin.onMethodCall(call, mockResult)
        verify(mockResult).error(
            "INVALID_ARGUMENTS",
            "Missing required arguments",
            null
        )
    }

    @Test
    fun `test unknown method`() {
        val call = MethodCall("unknownMethod", null)

        plugin.onMethodCall(call, mockResult)
        verify(mockResult).notImplemented()
    }
}
