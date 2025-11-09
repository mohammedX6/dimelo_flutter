package com.flyingapps.dimelo_flutter

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.Toolbar
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar as AppCompatToolbar
import org.json.JSONObject
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import android.view.MenuItem

import com.dimelo.dimelosdk.main.Dimelo
import com.dimelo.dimelosdk.main.DimeloConnection

/** DimeloFlutterPlugin */
class DimeloFlutterPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    StreamHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventSink? = null
    private var activity: Activity? = null
    private lateinit var appContext: Context
    
    // Unread count monitoring
    private var lastUnreadCount: Int = 0
    private var unreadCountTimer: java.util.Timer? = null
    private var currentUserId: String? = null

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

    // App bar customization properties
    private var appBarTitle: String = "ssssssDimelo Chat"
    private var appBarColor: Int = Color.BLUE
    private var appBarTitleColor: Int = Color.BLACK
    private var backArrowColor: Int = Color.BLACK     // Added back arrow color property
    private var showBackButton: Boolean = true
    private var appBarVisible: Boolean = true

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "dimelo_flutter")
        channel.setMethodCallHandler(this)
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "dimelo_flutter_events")
        eventChannel.setStreamHandler(this)
        appContext = flutterPluginBinding.applicationContext
        setInstance(this)
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
                    // Initialize Dimelo SDK without listener (will implement custom event handling)
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
                println("Showing Dimelo Messenger")

                Handler(Looper.getMainLooper()).post {
                    activity?.let { act ->
                        // Use our custom chat activity that handles back button properly
                        val intent = android.content.Intent(act, CustomChatActivity::class.java)
                        intent.addFlags(android.content.Intent.FLAG_ACTIVITY_CLEAR_TOP)

                        // Pass app bar configuration to the chat activity
                        intent.putExtra("appBarTitle", appBarTitle)
                        intent.putExtra("appBarColor", appBarColor)
                        intent.putExtra("appBarTitleColor", appBarTitleColor)
                        intent.putExtra("backArrowColor", backArrowColor)      // Pass back arrow color
                        intent.putExtra("appBarVisible", appBarVisible)
                        intent.putExtra("showBackButton", showBackButton)
                        
                        // Debug logging
                        android.util.Log.d("DimeloFlutterPlugin", "Passing to CustomChatActivity - Title: $appBarTitle, TitleColor: ${String.format("#%06X", 0xFFFFFF and appBarTitleColor)}, BackArrowColor: ${String.format("#%06X", 0xFFFFFF and backArrowColor)}")

                        act.startActivity(intent)
                        // Notify Flutter that chat was opened
                        notifyChatOpened()
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
                
                // Update current user ID for unread count tracking
                currentUserId = userId
                
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
                currentUserId = null
                authInfo.clear()
                // Reset unread count when user logs out
                lastUnreadCount = 0
                result.success(true)
            }
            "isAvailable" -> {
                result.success(initialized)
            }
            "getUnreadCount" -> {
                if (Dimelo.isInstantiated()) {
                    Dimelo.getInstance().fetchUnreadCount(object : Dimelo.UnreadCountCallback {
                        override fun onSuccess(unreadCount: Int) {
                            println("Dimelo unread count: $unreadCount")
                            // Also trigger event if count changed
                            if (unreadCount != lastUnreadCount) {
                                lastUnreadCount = unreadCount
                                sendEventToFlutter("onUnreadCountChanged", mapOf(
                                    "unreadCount" to unreadCount,
                                    "userId" to (currentUserId ?: ""),
                                    "userName" to (userName ?: "")
                                ))
                            }
                            result.success(unreadCount)
                        }

                        override fun onError(error: DimeloConnection.DimeloError?) {
                            println("Error fetching unread count: code=${error}, message=${error}")
                            result.success(0)
                        }
                    })
                } else {
                    println("Dimelo is not instantiated; unread count is 0")
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
            "setAppBarTitle" -> {
                val title: String? = call.argument("title")
                title?.let {
                    appBarTitle = it
                    updateAppBar()
                }
                result.success(true)
            }
            "setAppBarColor" -> {
                val color: String? = call.argument("color")
                color?.let {
                    try {
                        appBarColor = Color.parseColor(it)
                        updateAppBar()
                    } catch (e: IllegalArgumentException) {
                        result.success(false)
                        return
                    }
                }
                result.success(true)
            }
            "setAppBarTitleColor" -> {
                val color: String? = call.argument("color")
                color?.let {
                    try {
                        appBarTitleColor = Color.parseColor(it)
                        updateAppBar()
                        activity?.let { act ->
                            if (act is CustomChatActivity) {
                                act.updateTitleColor(appBarTitleColor)
                            }
                        }
                    } catch (e: IllegalArgumentException) {
                        result.success(false)
                        return
                    }
                }
                result.success(true)
            }
            "setBackArrowColor" -> {  // New method to set back arrow color
                val color: String? = call.argument("color")
                color?.let {
                    try {
                        backArrowColor = Color.parseColor(it)
                        android.util.Log.d("DimeloFlutterPlugin", "Set back arrow color to: $it (parsed: ${String.format("#%06X", 0xFFFFFF and backArrowColor)})")
                        updateAppBar()
                    } catch (e: IllegalArgumentException) {
                        android.util.Log.e("DimeloFlutterPlugin", "Invalid color format: $it", e)
                        result.success(false)
                        return
                    }
                }
                result.success(true)
            }
            "setAppBarVisibility" -> {
                val visible: Boolean? = call.argument("visible")
                visible?.let {
                    appBarVisible = it
                    updateAppBar()
                }
                result.success(true)
            }
            "setBackButtonVisibility" -> {
                val visible: Boolean? = call.argument("visible")
                visible?.let {
                    showBackButton = it
                    updateAppBar()
                }
                result.success(true)
            }
            "getAppBarConfig" -> {
                val config = mapOf(
                    "title" to appBarTitle,
                    "color" to String.format("#%06X", 0xFFFFFF and appBarColor),
                    "titleColor" to String.format("#%06X", 0xFFFFFF and appBarTitleColor),
                    "visible" to appBarVisible,
                    "showBackButton" to showBackButton
                )
                result.success(config)
            }
            "getCurrentUser" -> {
                val userInfo = mapOf(
                    "userId" to (currentUserId ?: ""),
                    "userName" to (userName ?: ""),
                    "userEmail" to (userEmail ?: ""),
                    "userPhone" to (userPhone ?: "")
                )
                result.success(userInfo)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        stopUnreadCountMonitoring()
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

    /**
     * Setup back button handling for the activity
     * This ensures the back button works properly in the chat activity
     */
    private fun setupBackButtonHandling(activity: Activity) {
        if (activity is AppCompatActivity) {
            // Set up the action bar with proper back button handling
            activity.supportActionBar?.let { actionBar ->
                actionBar.setDisplayHomeAsUpEnabled(showBackButton)
                actionBar.setDisplayShowHomeEnabled(showBackButton)

                if (showBackButton) {
                    // Set a proper back arrow icon
                    actionBar.setHomeAsUpIndicator(android.R.drawable.ic_menu_revert)
                }
            }
        }
    }

    /**
     * Handle back button press
     * This method should be called from the activity's onOptionsItemSelected
     */
    fun handleBackButtonPress(activity: Activity): Boolean {
        if (showBackButton) {
            // Finish the current activity to go back
            println("Back button pressed, finishing activity")
            activity.finish()
            return true
        }
        return false
    }

    /**
     * Update the app bar configuration for the current activity
     * This method applies the current app bar settings to the activity
     */
    private fun updateAppBar() {
        activity?.let { act ->
            Handler(Looper.getMainLooper()).post {
                if (act is AppCompatActivity) {
                    // Update the support action bar
                    act.supportActionBar?.let { actionBar ->
                        actionBar.title = appBarTitle
                        actionBar.setBackgroundDrawable(
                            android.graphics.drawable.ColorDrawable(appBarColor)
                        )
                        

                        actionBar.setDisplayHomeAsUpEnabled(showBackButton)
                        actionBar.setDisplayShowHomeEnabled(showBackButton)

                        // Set up back button click listener
                        if (showBackButton) {
                            actionBar.setHomeAsUpIndicator(android.R.drawable.ic_menu_revert)
                        }

                        if (appBarVisible) {
                            actionBar.show()
                        } else {
                            actionBar.hide()
                        }
                    }
                } else {
                    // For regular Activity, update the action bar
                    act.actionBar?.let { actionBar ->
                        actionBar.title = appBarTitle
                        actionBar.setBackgroundDrawable(
                            android.graphics.drawable.ColorDrawable(appBarColor)
                        )
                        actionBar.setDisplayHomeAsUpEnabled(showBackButton)
                        actionBar.setDisplayShowHomeEnabled(showBackButton)

                        if (appBarVisible) {
                            actionBar.show()
                        } else {
                            actionBar.hide()
                        }
                    }
                }
            }
        }
    }

    // StreamHandler implementation for EventChannel
    override fun onListen(arguments: Any?, events: EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    /**
     * Send event to Flutter via event channel
     */
    private fun sendEventToFlutter(eventType: String, data: Map<String, Any> = emptyMap()) {
        Handler(Looper.getMainLooper()).post {
            val eventData = mutableMapOf<String, Any>(
                "event" to eventType,
                "timestamp" to System.currentTimeMillis()
            )
            eventData.putAll(data)
            eventSink?.success(eventData)
        }
    }

    /**
     * Notify Flutter about chat close event
     * This method can be called from CustomChatActivity when it's closed
     */
    fun notifyChatClosed() {
        sendEventToFlutter("onChatActivityClosed")
        println("Dimelo chat activity closed")
        // Stop monitoring unread count when chat is closed
        stopUnreadCountMonitoring()
    }

    /**
     * Notify Flutter about chat open event
     * This method can be called when chat is opened
     */
    fun notifyChatOpened() {
        sendEventToFlutter("onChatActivityOpened")
        println("Dimelo chat activity opened")
        // Start monitoring unread count when chat is opened
        startUnreadCountMonitoring()
    }

    /**
     * Start monitoring unread message count
     */
    private fun startUnreadCountMonitoring() {
        stopUnreadCountMonitoring() // Stop any existing timer
        
        if (!initialized || !Dimelo.isInstantiated()) {
            return
        }

        unreadCountTimer = java.util.Timer()
        unreadCountTimer?.scheduleAtFixedRate(object : java.util.TimerTask() {
            override fun run() {
                checkUnreadCount()
            }
        }, 0, 5000) // Check every 5 seconds
    }

    /**
     * Stop monitoring unread message count
     */
    private fun stopUnreadCountMonitoring() {
        unreadCountTimer?.cancel()
        unreadCountTimer = null
    }

    /**
     * Check current unread count and notify if changed
     */
    private fun checkUnreadCount() {
        if (!initialized || !Dimelo.isInstantiated()) {
            return
        }

        try {
            Dimelo.getInstance().fetchUnreadCount(object : Dimelo.UnreadCountCallback {
                override fun onSuccess(unreadCount: Int) {
                    if (unreadCount != lastUnreadCount) {
                        lastUnreadCount = unreadCount
                        sendEventToFlutter("onUnreadCountChanged", mapOf(
                            "unreadCount" to unreadCount,
                            "userId" to (currentUserId ?: ""),
                            "userName" to (userName ?: "")
                        ))
                        println("Dimelo unread count changed: $unreadCount for user: $currentUserId")
                    }
                }

                override fun onError(error: DimeloConnection.DimeloError?) {
                    println("Error checking unread count: $error")
                }
            })
        } catch (e: Exception) {
            println("Exception checking unread count: ${e.message}")
        }
    }

    companion object {
        @JvmStatic
        private var instance: DimeloFlutterPlugin? = null

        @JvmStatic
        fun getInstance(): DimeloFlutterPlugin? = instance

        @JvmStatic
        fun setInstance(plugin: DimeloFlutterPlugin) {
            instance = plugin
        }
    }
}
