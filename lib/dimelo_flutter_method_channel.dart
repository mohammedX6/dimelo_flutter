import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dimelo_flutter_platform_interface.dart';

/// An implementation of [DimeloFlutterPlatform] that uses method channels.
///
/// This class handles communication between Flutter and native platforms
/// (Android/iOS) for Dimelo messaging functionality.
class MethodChannelDimeloFlutter extends DimeloFlutterPlatform {
  /// The method channel used to interact with the native platform.
  ///
  /// This channel is used for all communication between Flutter and
  /// the native Dimelo SDK implementations.
  static const MethodChannel _methodChannel = MethodChannel('dimelo_flutter');

  /// Getter for the method channel.
  @visibleForTesting
  MethodChannel get methodChannel => _methodChannel;

  @override
  Future<String?> getPlatformVersion() async {
    try {
      final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
      return version;
    } on PlatformException catch (e) {
      debugPrint('Failed to get platform version: ${e.message}');
      return null;
    }
  }

  @override
  Future<bool> initialize({
    String? applicationSecret,
    String? apiKey,
    String? apiSecret,
    String? domain,
    String? userId,
    bool? developmentApns,
  }) async {
    try {
      // Prepare parameters for native SDK initialization
      final result = await methodChannel.invokeMethod<bool>('initialize', <String, dynamic>{
        'applicationSecret': applicationSecret,
        'apiKey': apiKey,
        'apiSecret': apiSecret,
        'domain': domain,
        'userId': userId,
        'developmentApns': developmentApns,
      });
      // Return result or false if null
      return result ?? false;
    } on PlatformException catch (e) {
      // Log error and return false on platform exception
      debugPrint('Failed to initialize Dimelo: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> showMessenger() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('showMessenger');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to show messenger: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> setUser({
    String? userId,
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('setUser', <String, String?>{
        'userId': userId,
        'name': name,
        'email': email,
        'phone': phone,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to set user: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('logout');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to logout: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to check availability: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> setAuthInfo(Map<String, String> info) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('setAuthInfo', info);
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to set auth info: ${e.message}');
      return false;
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      // Request unread message count from native SDK
      final result = await methodChannel.invokeMethod<int>('getUnreadCount');
      // Return count or 0 if null/error
      return result ?? 0;
    } on PlatformException catch (e) {
      // Log error and return 0 on platform exception
      debugPrint('Failed to get unread count: ${e.message}');
      return 0;
    }
  }

  @override
  Future<bool> setDeviceToken(String token) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('setDeviceToken', <String, String>{
        'token': token,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to set device token: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> handlePush(Map<String, String> payload) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('handlePush', payload);
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to handle push: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> setAppBarTitle(String title) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('setAppBarTitle', <String, String>{
        'title': title,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to set app bar title: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> setAppBarColor(String color) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('setAppBarColor', <String, String>{
        'color': color,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to set app bar color: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> setAppBarVisibility({required bool visible}) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('setAppBarVisibility', <String, bool>{
        'visible': visible,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to set app bar visibility: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> setBackButtonVisibility({required bool visible}) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('setBackButtonVisibility', <String, bool>{
        'visible': visible,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to set back button visibility: ${e.message}');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getAppBarConfig() async {
    try {
      final result = await methodChannel.invokeMethod<Map<Object?, Object?>>('getAppBarConfig');
      return Map<String, dynamic>.from(result ?? {});
    } on PlatformException catch (e) {
      debugPrint('Failed to get app bar config: ${e.message}');
      return {};
    }
  }

  @override
  Future<bool> setFullScreenPresentation({required bool fullScreen}) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('setFullScreenPresentation', <String, bool>{
        'fullScreen': fullScreen,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to set full screen presentation: ${e.message}');
      return false;
    }
  }
}
