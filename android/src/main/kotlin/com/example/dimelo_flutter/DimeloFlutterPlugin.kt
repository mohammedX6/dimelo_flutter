package com.example.dimelo_flutter

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.content.Context
import com.dimelo.dimelosdk.main.Dimelo
import org.json.JSONObject
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** DimeloFlutterPlugin */
class DimeloFlutterPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private lateinit var appContext: Context

    private var initialized: Boolean = false
    private var apiKey: String? = null
    private var applicationSecret: String? = null
    private var apiSecret: String? = null
    private var domain: String? = null
    private var userId: String? = null
    private var userName: String? = null
    private var userEmail: String? = null
    private var userPhone: String? = null
    private var authInfo: HashMap<String, Any> = HashMap()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "dimelo_flutter")
        channel.setMethodCallHandler(this)
        appContext = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "initialize" -> {
                if (initialized) {
                    // Already initialized; do not re-init
                    result.success(true)
                    return
                }
                applicationSecret = call.argument("applicationSecret")
                apiKey = call.argument("apiKey")
                apiSecret = call.argument("apiSecret")
                domain = call.argument("domain")
                userId = call.argument("userId")

                // Initialize Dimelo SDK
                val secretToUse = apiSecret ?: apiKey
                if (!secretToUse.isNullOrBlank() && !domain.isNullOrBlank()) {
                    // Ensure SDK is setup with a non-null context
                    Dimelo.setup(appContext)
                    val dimelo = Dimelo.getInstance()
                    // Third parameter is a DimeloListener, pass null and set user separately
                    dimelo.initWithApiSecret(secretToUse, domain, null)
                    userId?.let { dimelo.userIdentifier = it }
                    initialized = true
                } else {
                    initialized = false
                }
                result.success(initialized)
            }
            "showMessenger" -> {
                if (!initialized) {
                    result.success(false)
                    return
                }
                val hasActivity = activity != null
                if (!hasActivity) {
                    result.success(false)
                    return
                }
                // Navigate to new screen with Dimelo chat
                Handler(Looper.getMainLooper()).post {
                    val dimelo = Dimelo.getInstance()
                    activity?.let { act ->
                        val intent = android.content.Intent(act, com.dimelo.dimelosdk.main.ChatActivity::class.java)
                        // Add flags to ensure proper back navigation
                        intent.flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK or android.content.Intent.FLAG_ACTIVITY_CLEAR_TOP
                        act.startActivity(intent)
                        result.success(true)
                    } ?: run {
                        result.success(false)
                    }
                }
            }
            "setUser" -> {
                userId = call.argument("userId")
                userName = call.argument("name")
                userEmail = call.argument("email")
                userPhone = call.argument("phone")
                if (Dimelo.isInstantiated()) {
                    val dimelo = Dimelo.getInstance()
                    userId?.let { dimelo.userIdentifier = it }
                    userName?.let { dimelo.userName = it }
                    val authJson = dimelo.authenticationInfo?.let { JSONObject(it.toString()) } ?: JSONObject()
                    userEmail?.let { authJson.put("email", it) }
                    userPhone?.let { authJson.put("phone", it) }
                    // merge cached extra auth fields
                    authInfo.forEach { (k, v) -> authJson.put(k, v) }
                    dimelo.authenticationInfo = authJson
                }
                result.success(true)
            }
            "setAuthInfo" -> {
                val map = HashMap<String, Any>()
                call.arguments?.let { args ->
                    if (args is Map<*, *>) {
                        for ((k, v) in args) {
                            if (k is String && v is String) {
                                map[k] = v
                            }
                        }
                    }
                }
                authInfo.putAll(map)
                if (Dimelo.isInstantiated()) {
                    val dimelo = Dimelo.getInstance()
                    val authJson = dimelo.authenticationInfo?.let { JSONObject(it.toString()) } ?: JSONObject()
                    authInfo.forEach { (k, v) -> authJson.put(k, v) }
                    dimelo.authenticationInfo = authJson
                }
                result.success(true)
            }
            "logout" -> {
                if (Dimelo.isInstantiated()) {
                    val dimelo = Dimelo.getInstance()
                    dimelo.userIdentifier = null
                    dimelo.userName = null
                    dimelo.authenticationInfo = null
                }
                userId = null
                userName = null
                userEmail = null
                userPhone = null
                authInfo.clear()
                result.success(true)
            }
            "isAvailable" -> {
                result.success(initialized)
            }
            "getUnreadCount" -> {
                if (Dimelo.isInstantiated()) {
                    val count = Dimelo.getInstance().unreadCount
                    result.success(count)
                } else {
                    result.success(0)
                }
            }
            "setDeviceToken" -> {
                val token: String? = call.argument("token")
                if (Dimelo.isInstantiated() && !token.isNullOrBlank()) {
                    Dimelo.getInstance().setDeviceToken(token)
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            "handlePush" -> {
                val map: Map<String, String> = (call.arguments as? Map<*, *>)
                    ?.filterKeys { it is String }
                    ?.mapKeys { it.key as String }
                    ?.filterValues { it is String }
                    ?.mapValues { it.value as String } ?: emptyMap()
                if (Dimelo.isInstantiated()) {
                    val consumed = Dimelo.consumeReceivedRemoteNotification(appContext, map, null)
                    result.success(consumed)
                } else {
                    result.success(false)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // ActivityAware implementation to access current Activity for presenting UI
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
