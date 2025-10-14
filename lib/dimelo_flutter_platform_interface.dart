import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'dimelo_flutter_method_channel.dart';

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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

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

  Future<bool> showMessenger() {
    throw UnimplementedError('showMessenger() has not been implemented.');
  }

  Future<bool> setUser({
    String? userId,
    String? name,
    String? email,
    String? phone,
  }) {
    throw UnimplementedError('setUser() has not been implemented.');
  }

  Future<bool> logout() {
    throw UnimplementedError('logout() has not been implemented.');
  }

  Future<bool> isAvailable() {
    throw UnimplementedError('isAvailable() has not been implemented.');
  }

  Future<bool> setAuthInfo(Map<String, String> info) {
    throw UnimplementedError('setAuthInfo() has not been implemented.');
  }

  Future<int> getUnreadCount() {
    throw UnimplementedError('getUnreadCount() has not been implemented.');
  }

  Future<bool> setDeviceToken(String token) {
    throw UnimplementedError('setDeviceToken() has not been implemented.');
  }

  Future<bool> handlePush(Map<String, String> payload) {
    throw UnimplementedError('handlePush() has not been implemented.');
  }
}
