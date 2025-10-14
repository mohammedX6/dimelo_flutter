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
}
