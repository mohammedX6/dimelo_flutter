
import 'dimelo_flutter_platform_interface.dart';

class DimeloFlutter {
  Future<String?> getPlatformVersion() {
    return DimeloFlutterPlatform.instance.getPlatformVersion();
  }

  /// Initialize Dimelo/Engage Digital Messaging SDK on the native side.
  ///
  /// [apiKey] is your Dimelo API key.
  /// [domain] is the service domain/endpoint if required by your setup.
  /// [userId] optional external user id to bind the session.
  Future<bool> initialize({
    String? applicationSecret,
    String? apiKey,
    String? apiSecret,
    String? domain,
    String? userId,
    bool? developmentApns,
  }) {
    return DimeloFlutterPlatform.instance.initialize(
      applicationSecret: applicationSecret,
      apiKey: apiKey,
      apiSecret: apiSecret,
      domain: domain,
      userId: userId,
      developmentApns: developmentApns,
    );
  }

  /// Open the messaging UI if available on the native SDK.
  Future<bool> showMessenger() {
    return DimeloFlutterPlatform.instance.showMessenger();
  }

  /// Set/update the current user information.
  Future<bool> setUser({
    String? userId,
    String? name,
    String? email,
    String? phone,
  }) {
    return DimeloFlutterPlatform.instance.setUser(
      userId: userId,
      name: name,
      email: email,
      phone: phone,
    );
  }

  /// Logout/clear the current user session if supported.
  Future<bool> logout() {
    return DimeloFlutterPlatform.instance.logout();
  }

  /// Check if the SDK was initialized and is available.
  Future<bool> isAvailable() {
    return DimeloFlutterPlatform.instance.isAvailable();
  }

  /// Set arbitrary authentication info key/values (e.g., ticket_id).
  Future<bool> setAuthInfo(Map<String, String> info) {
    return DimeloFlutterPlatform.instance.setAuthInfo(info);
  }

  /// Fetch unread messages count from the SDK.
  Future<int> getUnreadCount() {
    return DimeloFlutterPlatform.instance.getUnreadCount();
  }

  /// Pass the device push token to the SDK.
  Future<bool> setDeviceToken(String token) {
    return DimeloFlutterPlatform.instance.setDeviceToken(token);
  }

  /// Let the SDK handle an incoming push payload.
  /// Returns true if consumed by Dimelo.
  Future<bool> handlePush(Map<String, String> payload) {
    return DimeloFlutterPlatform.instance.handlePush(payload);
  }
}
