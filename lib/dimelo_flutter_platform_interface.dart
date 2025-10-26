import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'dimelo_flutter_method_channel.dart';

/// The interface that implementations of dimelo_flutter must implement.
///
/// Platform-specific implementations should extend this class rather than
/// implement it as `dimelo_flutter` does not consider newly added methods
/// to be breaking changes. Extending this class (using `extends`) ensures
/// that the subclass will get the default implementation, while platform
/// implementations that `implements` this interface will be broken by newly
/// added [DimeloFlutterPlatform] methods.
abstract class DimeloFlutterPlatform extends PlatformInterface {
  /// Constructs a DimeloFlutterPlatform.
  DimeloFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static DimeloFlutterPlatform _instance = MethodChannelDimeloFlutter();

  /// The default instance of [DimeloFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelDimeloFlutter].
  static DimeloFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DimeloFlutterPlatform] when
  /// they register themselves.
  static set instance(DimeloFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Get the platform version information.
  ///
  /// Returns the platform version string or null if unavailable.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

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
  }) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Open the messaging UI if available on the native SDK.
  ///
  /// This method displays the Dimelo messaging interface to the user.
  /// Make sure to call [initialize] first.
  ///
  /// Returns `true` if the messenger was shown successfully, `false` otherwise.
  Future<bool> showMessenger() {
    throw UnimplementedError('showMessenger() has not been implemented.');
  }

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
  }) {
    throw UnimplementedError('setUser() has not been implemented.');
  }

  /// Logout/clear the current user session if supported.
  ///
  /// This method clears the current user session and any cached data.
  ///
  /// Returns `true` if logout was successful, `false` otherwise.
  Future<bool> logout() {
    throw UnimplementedError('logout() has not been implemented.');
  }

  /// Check if the SDK was initialized and is available.
  ///
  /// Returns `true` if the SDK is initialized and ready to use, `false` otherwise.
  Future<bool> isAvailable() {
    throw UnimplementedError('isAvailable() has not been implemented.');
  }

  /// Set arbitrary authentication info key/values (e.g., ticket_id).
  ///
  /// This method allows you to pass additional authentication information
  /// to the Dimelo SDK.
  ///
  /// Parameters:
  /// - [info] - Map of key-value pairs containing authentication information
  ///
  /// Returns `true` if auth info was set successfully, `false` otherwise.
  Future<bool> setAuthInfo(Map<String, String> info) {
    throw UnimplementedError('setAuthInfo() has not been implemented.');
  }

  /// Fetch unread messages count from the SDK.
  ///
  /// This method returns the number of unread messages for the current user.
  /// Useful for showing badges or notifications.
  ///
  /// Returns the number of unread messages, or 0 if none or if an error occurred.
  Future<int> getUnreadCount() {
    throw UnimplementedError('getUnreadCount() has not been implemented.');
  }

  /// Pass the device push token to the SDK.
  ///
  /// This method should be called when you receive a push token from the
  /// platform's push notification service.
  ///
  /// Parameters:
  /// - [token] - The device push token
  ///
  /// Returns `true` if the token was set successfully, `false` otherwise.
  Future<bool> setDeviceToken(String token) {
    throw UnimplementedError('setDeviceToken() has not been implemented.');
  }

  /// Let the SDK handle an incoming push payload.
  ///
  /// This method should be called when your app receives a push notification
  /// that might be related to Dimelo messaging.
  ///
  /// Parameters:
  /// - [payload] - The push notification payload
  ///
  /// Returns `true` if the payload was consumed by Dimelo, `false` otherwise.
  Future<bool> handlePush(Map<String, String> payload) {
    throw UnimplementedError('handlePush() has not been implemented.');
  }

  /// Set the app bar title dynamically.
  ///
  /// This method allows you to change the app bar title at runtime.
  ///
  /// Parameters:
  /// - [title] - The new title for the app bar
  ///
  /// Returns `true` if the title was set successfully, `false` otherwise.
  Future<bool> setAppBarTitle(String title) {
    throw UnimplementedError('setAppBarTitle() has not been implemented.');
  }

  /// Set the app bar color dynamically.
  ///
  /// This method allows you to change the app bar background color at runtime.
  ///
  /// Parameters:
  /// - [color] - The new color for the app bar (hex format like "#FF0000")
  ///
  /// Returns `true` if the color was set successfully, `false` otherwise.
  Future<bool> setAppBarColor(String color) {
    throw UnimplementedError('setAppBarColor() has not been implemented.');
  }

  /// Set the app bar title color dynamically.
  ///
  /// This method allows you to change the app bar title text color at runtime.
  ///
  /// Parameters:
  /// - [color] - The new color for the app bar title (hex format like "#000000")
  ///
  /// Returns `true` if the title color was set successfully, `false` otherwise.
  Future<bool> setAppBarTitleColor(String color) {
    throw UnimplementedError('setAppBarTitleColor() has not been implemented.');
  }

  /// Set the back arrow color dynamically.
  ///
  /// This method allows you to change the back arrow color at runtime.
  ///
  /// Parameters:
  /// - [color] - The new color for the back arrow (hex format like "#000000")
  ///
  /// Returns `true` if the back arrow color was set successfully, `false` otherwise.
  Future<bool> setBackArrowColor(String color) {
    throw UnimplementedError('setBackArrowColor() has not been implemented.');
  }

  /// Set the app bar visibility dynamically.
  ///
  /// This method allows you to show or hide the app bar at runtime.
  ///
  /// Parameters:
  /// - [visible] - Whether the app bar should be visible
  ///
  /// Returns `true` if the visibility was set successfully, `false` otherwise.
  Future<bool> setAppBarVisibility({required bool visible}) {
    throw UnimplementedError('setAppBarVisibility() has not been implemented.');
  }

  /// Set the back button visibility dynamically.
  ///
  /// This method allows you to show or hide the back button in the app bar.
  ///
  /// Parameters:
  /// - [visible] - Whether the back button should be visible
  ///
  /// Returns `true` if the back button visibility was set successfully, `false` otherwise.
  Future<bool> setBackButtonVisibility({required bool visible}) {
    throw UnimplementedError('setBackButtonVisibility() has not been implemented.');
  }

  /// Get the current app bar configuration.
  ///
  /// This method returns the current app bar settings including title, color, and visibility.
  ///
  /// Returns a map containing the current app bar configuration.
  Future<Map<String, dynamic>> getAppBarConfig() {
    throw UnimplementedError('getAppBarConfig() has not been implemented.');
  }

  /// Set the presentation style for iOS (full screen vs bottom sheet).
  ///
  /// This method controls how the chat interface is presented on iOS.
  ///
  /// Parameters:
  /// - [fullScreen] - Whether to present as full screen (true) or bottom sheet (false)
  ///
  /// Returns `true` if the presentation style was set successfully, `false` otherwise.
  Future<bool> setFullScreenPresentation({required bool fullScreen}) {
    throw UnimplementedError('setFullScreenPresentation() has not been implemented.');
  }
}
