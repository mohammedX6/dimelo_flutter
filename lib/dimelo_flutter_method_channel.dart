import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dimelo_flutter_platform_interface.dart';

/// An implementation of [DimeloFlutterPlatform] that uses method channels.
class MethodChannelDimeloFlutter extends DimeloFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('dimelo_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
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
    final result = await methodChannel.invokeMethod<bool>('initialize', {
      'applicationSecret': applicationSecret,
      'apiKey': apiKey,
      'apiSecret': apiSecret,
      'domain': domain,
      'userId': userId,
      'developmentApns': developmentApns,
    });
    return result ?? false;
  }

  @override
  Future<bool> showMessenger() async {
    final result = await methodChannel.invokeMethod<bool>('showMessenger');
    return result ?? false;
  }

  @override
  Future<bool> setUser({
    String? userId,
    String? name,
    String? email,
    String? phone,
  }) async {
    final result = await methodChannel.invokeMethod<bool>('setUser', {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
    });
    return result ?? false;
  }

  @override
  Future<bool> logout() async {
    final result = await methodChannel.invokeMethod<bool>('logout');
    return result ?? false;
  }

  @override
  Future<bool> isAvailable() async {
    final result = await methodChannel.invokeMethod<bool>('isAvailable');
    return result ?? false;
  }

  @override
  Future<bool> setAuthInfo(Map<String, String> info) async {
    final result = await methodChannel.invokeMethod<bool>('setAuthInfo', info);
    return result ?? false;
  }

  @override
  Future<int> getUnreadCount() async {
    final result = await methodChannel.invokeMethod<int>('getUnreadCount');
    return result ?? 0;
  }

  @override
  Future<bool> setDeviceToken(String token) async {
    final result = await methodChannel.invokeMethod<bool>('setDeviceToken', {
      'token': token,
    });
    return result ?? false;
  }

  @override
  Future<bool> handlePush(Map<String, String> payload) async {
    final result = await methodChannel.invokeMethod<bool>('handlePush', payload);
    return result ?? false;
  }
}
