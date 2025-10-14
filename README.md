# dimelo_flutter

Flutter plugin to integrate Dimelo / RingCentral Engage Digital Messaging SDKs on Android and iOS.

## Quick start

1) Install

```yaml
dependencies:
  dimelo_flutter:
    path: ../dimelo_flutter
```

2) Initialize

```dart
final dimelo = DimeloFlutter();
await dimelo.initialize(apiKey: 'YOUR_API_KEY', domain: 'YOUR_DOMAIN');
```

3) Use

```dart
await dimelo.setUser(userId: '123', name: 'John');
await dimelo.showMessenger();
```

## Platform setup

Android
- Add vendor Maven repository and dependency in `android/build.gradle` (placeholders included).
- Min SDK 24+.

iOS
- Add vendor pods to `ios/dimelo_flutter.podspec` (placeholders included).
- iOS 13+.

Provide these details so we can wire the SDKs:
- Android: Maven coordinates (`group:artifact:version`) and repository URL.
- iOS: Pod names/versions or XCFrameworks. Also list any Info.plist keys, URL schemes.

## API
- `initialize({apiKey, domain, userId})`
- `showMessenger()`
- `setUser({userId, name, email, phone})`
- `logout()`
- `isAvailable()`

Note: Native calls are currently stubbed and will be connected once SDK coordinates are provided.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/to/develop-plugins),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

