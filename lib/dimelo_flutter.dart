import 'dimelo_flutter_platform_interface.dart';

/// A Flutter plugin for integrating Dimelo (RingCentral Engage Digital
/// Messaging) SDKs.
///
/// This plugin provides cross-platform messaging functionality for Android and
/// iOS by wrapping the native Dimelo SDKs.
class DimeloFlutter {
  /// Get the platform version information.
  ///
  /// Returns the platform version string or null if unavailable.
  Future<String?> getPlatformVersion() => DimeloFlutterPlatform.instance.getPlatformVersion();

  /// Initialize Dimelo/Engage Digital Messaging SDK on the native side.
  ///
  /// This method must be called before using any other functionality.
  ///
  /// Parameters:
  /// - [apiKey] - Your Dimelo API key (required)
  /// - [domain] - The service domain/endpoint (required)
  /// - [userId] - Optional external user ID to bind the session
  /// - [applicationSecret] - Optional application secret
  /// - [apiSecret] - Optional API secret
  /// - [developmentApns] - Whether to use development APNS (iOS only)
  ///
  /// Returns `true` if initialization was successful, `false` otherwise.
  Future<bool> initialize({
    String? applicationSecret,
    String? apiKey,
    String? apiSecret,
    String? domain,
    String? userId,
    bool? developmentApns,
  }) =>
      DimeloFlutterPlatform.instance.initialize(
        applicationSecret: applicationSecret,
        apiKey: apiKey,
        apiSecret: apiSecret,
        domain: domain,
        userId: userId,
        developmentApns: developmentApns,
      );

  /// Open the messaging UI if available on the native SDK.
  ///
  /// This method displays the Dimelo messaging interface to the user.
  /// Make sure to call [initialize] first.
  ///
  /// Returns `true` if the messenger was shown successfully, `false` otherwise.
  Future<bool> showMessenger() => DimeloFlutterPlatform.instance.showMessenger();

  /// Set/update the current user information.
  ///
  /// This method should be called after initialization to identify the user.
  ///
  /// Parameters:
  /// - [userId] - Unique identifier for the user
  /// - [name] - User's display name
  /// - [email] - User's email address
  /// - [phone] - User's phone number
  ///
  /// Returns `true` if user information was set successfully, `false` otherwise.
  Future<bool> setUser({
    String? userId,
    String? name,
    String? email,
    String? phone,
  }) =>
      DimeloFlutterPlatform.instance.setUser(
        userId: userId,
        name: name,
        email: email,
        phone: phone,
      );

  /// Logout/clear the current user session if supported.
  ///
  /// This method clears the current user session and any cached data.
  ///
  /// Returns `true` if logout was successful, `false` otherwise.
  Future<bool> logout() => DimeloFlutterPlatform.instance.logout();

  /// Check if the SDK was initialized and is available.
  ///
  /// Returns `true` if the SDK is initialized and ready to use, `false` otherwise.
  Future<bool> isAvailable() => DimeloFlutterPlatform.instance.isAvailable();

  /// Set arbitrary authentication info key/values (e.g., ticket_id).
  ///
  /// This method allows you to pass additional authentication information
  /// to the Dimelo SDK.
  ///
  /// Parameters:
  /// - [info] - Map of key-value pairs containing authentication information
  ///
  /// Returns `true` if auth info was set successfully, `false` otherwise.
  Future<bool> setAuthInfo(Map<String, String> info) => DimeloFlutterPlatform.instance.setAuthInfo(info);

  /// Fetch unread messages count from the SDK.
  ///
  /// This method returns the number of unread messages for the current user.
  /// Useful for showing badges or notifications.
  ///
  /// Returns the number of unread messages, or 0 if none or if an error occurred.
  Future<int> getUnreadCount() => DimeloFlutterPlatform.instance.getUnreadCount();

  /// Pass the device push token to the SDK.
  ///
  /// This method should be called when you receive a push token from the
  /// platform's push notification service.
  ///
  /// Parameters:
  /// - [token] - The device push token
  ///
  /// Returns `true` if the token was set successfully, `false` otherwise.
  Future<bool> setDeviceToken(String token) => DimeloFlutterPlatform.instance.setDeviceToken(token);

  /// Let the SDK handle an incoming push payload.
  ///
  /// This method should be called when your app receives a push notification
  /// that might be related to Dimelo messaging.
  ///
  /// Parameters:
  /// - [payload] - The push notification payload
  ///
  /// Returns `true` if the payload was consumed by Dimelo, `false` otherwise.
  Future<bool> handlePush(Map<String, String> payload) => DimeloFlutterPlatform.instance.handlePush(payload);

  /// Set the app bar title dynamically.
  ///
  /// This method allows you to change the app bar title at runtime.
  ///
  /// Parameters:
  /// - [title] - The new title for the app bar
  ///
  /// Returns `true` if the title was set successfully, `false` otherwise.
  Future<bool> setAppBarTitle(String title) => DimeloFlutterPlatform.instance.setAppBarTitle(title);

  /// Set the app bar color dynamically.
  ///
  /// This method allows you to change the app bar background color at runtime.
  ///
  /// Parameters:
  /// - [color] - The new color for the app bar (hex format like "#FF0000")
  ///
  /// Returns `true` if the color was set successfully, `false` otherwise.
  Future<bool> setAppBarColor(String color) => DimeloFlutterPlatform.instance.setAppBarColor(color);

  /// Set the app bar title color dynamically.
  ///
  /// This method allows you to change the app bar title text color at runtime.
  ///
  /// Parameters:
  /// - [color] - The new color for the app bar title (hex format like "#000000")
  ///
  /// Returns `true` if the title color was set successfully, `false` otherwise.
  Future<bool> setAppBarTitleColor(String color) => DimeloFlutterPlatform.instance.setAppBarTitleColor(color);

  /// Set the back arrow color dynamically.
  ///
  /// This method allows you to change the back arrow color at runtime.
  ///
  /// Parameters:
  /// - [color] - The new color for the back arrow (hex format like "#000000")
  ///
  /// Returns `true` if the back arrow color was set successfully, `false` otherwise.
  Future<bool> setBackArrowColor(String color) => DimeloFlutterPlatform.instance.setBackArrowColor(color);

  /// Set the app bar visibility dynamically.
  ///
  /// This method allows you to show or hide the app bar at runtime.
  ///
  /// Parameters:
  /// - [visible] - Whether the app bar should be visible
  ///
  /// Returns `true` if the visibility was set successfully, `false` otherwise.
  Future<bool> setAppBarVisibility({required bool visible}) => DimeloFlutterPlatform.instance.setAppBarVisibility(visible: visible);

  /// Set the back button visibility dynamically.
  ///
  /// This method allows you to show or hide the back button in the app bar.
  ///
  /// Parameters:
  /// - [visible] - Whether the back button should be visible
  ///
  /// Returns `true` if the back button visibility was set successfully, `false` otherwise.
  Future<bool> setBackButtonVisibility({required bool visible}) => DimeloFlutterPlatform.instance.setBackButtonVisibility(visible: visible);

  /// Get the current app bar configuration.
  ///
  /// This method returns the current app bar settings including title, color, and visibility.
  ///
  /// Returns a map containing the current app bar configuration.
  Future<Map<String, dynamic>> getAppBarConfig() => DimeloFlutterPlatform.instance.getAppBarConfig();

  /// Set the presentation style for iOS (full screen vs bottom sheet).
  ///
  /// This method controls how the chat interface is presented on iOS.
  ///
  /// Parameters:
  /// - [fullScreen] - Whether to present as full screen (true) or bottom sheet (false)
  ///
  /// Returns `true` if the presentation style was set successfully, `false` otherwise.
  Future<bool> setFullScreenPresentation({required bool fullScreen}) => DimeloFlutterPlatform.instance.setFullScreenPresentation(fullScreen: fullScreen);

  /// Get a stream of Dimelo events.
  ///
  /// This method returns a stream that emits events from the Dimelo chat interface,
  /// including:
  /// - `onChatActivityClosed`: When the chat interface is closed by the user
  /// - `onChatActivityOpened`: When the chat interface is opened
  /// - `onUnreadCountChanged`: When the unread message count changes
  ///
  /// Each event is a Map containing:
  /// - `event`: The event type (String)
  /// - `timestamp`: The event timestamp in milliseconds (int)
  /// - Additional event-specific data:
  ///   - For `onUnreadCountChanged`: `unreadCount`, `userId`, `userName`
  ///
  /// Example usage:
  /// ```dart
  /// DimeloFlutter().eventStream.listen((event) {
  ///   switch (event['event']) {
  ///     case 'onChatActivityClosed':
  ///       print('Chat closed at ${event['timestamp']}');
  ///       // Perfect time to show feedback dialog or perform post-chat actions
  ///       showFeedbackDialog();
  ///       break;
  ///     case 'onChatActivityOpened':
  ///       print('Chat opened at ${event['timestamp']}');
  ///       // Track analytics or update UI state
  ///       break;
  ///     case 'onUnreadCountChanged':
  ///       int unreadCount = event['unreadCount'] ?? 0;
  ///       String userId = event['userId'] ?? '';
  ///       String userName = event['userName'] ?? '';
  ///       print('Unread messages: $unreadCount for user $userName ($userId)');
  ///       // Update UI badge or notification for specific user
  ///       updateUnreadBadge(unreadCount, userId);
  ///       break;
  ///   }
  /// });
  /// ```
  ///
  /// Returns a stream of maps containing event data.
  Stream<Map<String, dynamic>> get eventStream => DimeloFlutterPlatform.instance.eventStream;

  /// Get the current user information.
  ///
  /// This method returns information about the currently logged in user.
  /// Useful for identifying which user the unread messages belong to.
  ///
  /// Returns a map containing:
  /// - `userId`: The user's unique identifier
  /// - `userName`: The user's display name
  /// - `userEmail`: The user's email address
  /// - `userPhone`: The user's phone number
  ///
  /// Example usage:
  /// ```dart
  /// final userInfo = await DimeloFlutter().getCurrentUser();
  /// String userId = userInfo['userId'] ?? '';
  /// String userName = userInfo['userName'] ?? '';
  /// print('Current user: $userName ($userId)');
  /// ```
  ///
  /// Returns a map containing the current user information.
  Future<Map<String, dynamic>> getCurrentUser() => DimeloFlutterPlatform.instance.getCurrentUser();
}
