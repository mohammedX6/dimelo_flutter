> 🚧 **Early Development Notice**
> 
> This plugin is in a **very early stage** of development. Expect breaking changes and limited functionality while the API is being stabilized. Use in production at your own risk.

# Dimelo Flutter Plugin

[![pub package](https://img.shields.io/pub/v/dimelo_flutter.svg)](https://pub.dev/packages/dimelo_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin for integrating Dimelo (RingCentral Engage Digital Messaging) SDKs on Android and iOS platforms.

## ⚠️ Important Notice

**This is an unofficial Flutter plugin** for Dimelo/RingCentral Engage Digital Messaging. It is not officially supported or maintained by RingCentral or Dimelo. 

- **Official Dimelo Documentation**: https://mobile-messaging.dimelo.com/
- **Official iOS SDK**: Available through CocoaPods
- **Official Android SDK**: Available through Gradle

This plugin provides a Flutter wrapper around the native Dimelo SDKs to enable in-app messaging functionality in Flutter applications.

## Features

- 🔄 Cross-platform support (Android & iOS)
- 💬 In-app messaging integration
- 👤 User authentication and management
- 🔔 Push notification support
- 🎨 Customizable UI components
- 📱 Native SDK integration

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  dimelo_flutter: ^0.1.7
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize the Plugin

```dart
import 'package:dimelo_flutter/dimelo_flutter.dart';

final dimelo = DimeloFlutter();

// Initialize with your API credentials
await dimelo.initialize(
  apiKey: 'YOUR_API_KEY',
  domain: 'YOUR_DOMAIN',
);
```

### 2. Set User Information

```dart
// Set user details for authentication
await dimelo.setUser(
  userId: 'user123',
  name: 'John Doe',
  email: 'john@example.com',
  phone: '+1234567890',
);
```

### 3. Show Messaging Interface

```dart
// Display the messaging interface
await dimelo.showMessenger();
```

## Platform Setup

### Android

1. **Minimum SDK**: API level 24+ (Android 7.0)

2. **Add repositories to `android/build.gradle` (project level)**:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        // Add Dimelo repositories
        maven { url 'https://raw.github.com/ringcentral/engage-digital-messaging-android/master' }
        maven { url 'https://raw.github.com/ringcentral/engage-digital-messaging-android-location/master' }
        maven { url 'https://raw.github.com/dimelo/Dimelo-Android/master' }
    }
}
```

3. **Add dependencies to `android/app/build.gradle` (app level)**:

```gradle
dependencies {
    // Dimelo Android SDKs
    implementation 'com.dimelo.dimelosdk:dimelosdk:3.3.9'
    implementation 'com.ringcentral.edmessagingmapssdk:edmessagingmapssdk:1.0.1'
    // Required by Dimelo Chat UI
    implementation 'androidx.swiperefreshlayout:swiperefreshlayout:1.1.0'
}
```

4. **Add permissions to `android/app/src/main/AndroidManifest.xml`**:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

5. **Important**: Ensure your app's `android/app/build.gradle` has compatible versions:

```gradle
android {
    compileSdk 34
    minSdk 24
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }
}
```

**Note**: This plugin requires the Dimelo native SDKs to be properly configured in your host app. The plugin provides Flutter bindings but the actual messaging functionality depends on the native SDKs being correctly set up.

### iOS

1. **Minimum iOS**: 13.0+
2. **Add to `ios/Podfile`**:

```ruby
pod 'Dimelo-iOS', '~> VERSION'
```

3. **Run pod install**:

```bash
cd ios && pod install
```

4. **Add to `ios/Runner/Info.plist`**:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## API Reference

### Core Methods

| Method | Description | Parameters |
|--------|-------------|------------|
| `initialize()` | Initialize the Dimelo SDK | `apiKey`, `domain`, `userId`, `developmentApns` (optional) |
| `setUser()` | Set user information | `userId`, `name`, `email`, `phone` |
| `showMessenger()` | Display messaging interface | None |
| `logout()` | Logout current user | None |
| `isAvailable()` | Check if messaging is available | None |
| `getUnreadCount()` | Get count of unread messages | None |
| `setAuthInfo()` | Set authentication information | `Map<String, String> info` |
| `setDeviceToken()` | Set device push token | `String token` |
| `handlePush()` | Handle incoming push notification | `Map<String, String> payload` |

### Example Usage

```dart
import 'package:dimelo_flutter/dimelo_flutter.dart';

class MessagingService {
  final DimeloFlutter _dimelo = DimeloFlutter();
  
  Future<void> initializeMessaging() async {
    try {
      // Initialize the SDK
      await _dimelo.initialize(
        apiKey: 'your-api-key',
        domain: 'your-domain.dimelo.com',
      );
      
      // Set user information
      await _dimelo.setUser(
        userId: 'user123',
        name: 'John Doe',
        email: 'john@example.com',
      );
      
      print('Dimelo initialized successfully');
    } catch (e) {
      print('Failed to initialize Dimelo: $e');
    }
  }
  
  Future<void> openMessaging() async {
    if (await _dimelo.isAvailable()) {
      await _dimelo.showMessenger();
    } else {
      print('Messaging is not available');
    }
  }
  
  Future<void> checkUnreadMessages() async {
    try {
      final unreadCount = await _dimelo.getUnreadCount();
      print('Unread messages: $unreadCount');
      
      // Update UI badge or notification
      if (unreadCount > 0) {
        // Show badge or notification
        print('You have $unreadCount unread messages');
      }
    } catch (e) {
      print('Failed to get unread count: $e');
    }
  }
  
  Future<void> logout() async {
    await _dimelo.logout();
  }
}
```

## Requirements

- **Flutter**: >=3.29.0
- **Dart**: >=3.5.0
- **Android**: API level 24+ (Android 7.0)
- **iOS**: 13.0+

## Getting Started with Dimelo

To use this plugin, you'll need:

1. **Dimelo Account**: Sign up at [Dimelo](https://mobile-messaging.dimelo.com/)
2. **API Key**: Obtain from your Dimelo dashboard
3. **Domain**: Your Dimelo domain (e.g., `yourcompany.dimelo.com`)

## Troubleshooting

### Common Issues

1. **SDK Not Initialized**: Ensure you call `initialize()` before any other methods
2. **Platform Setup**: Verify native SDK dependencies are properly configured
3. **Permissions**: Check that required permissions are granted on both platforms

### Debug Mode

Enable debug logging by setting the debug flag:

```dart
await dimelo.initialize(
  apiKey: 'your-api-key',
  domain: 'your-domain',
  debug: true, // Enable debug logging
);
```

## Contributing

This is an unofficial plugin. Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Disclaimer

This plugin is not officially supported by RingCentral or Dimelo. Use at your own risk. For official support, please refer to the [official Dimelo documentation](https://mobile-messaging.dimelo.com/).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/dimelo_flutter/issues)
- **Documentation**: [Official Dimelo Docs](https://mobile-messaging.dimelo.com/)
- **Flutter**: [Flutter Documentation](https://docs.flutter.dev/)

---

**Note**: This plugin requires proper setup of native Dimelo SDKs on both Android and iOS platforms. Please refer to the official Dimelo documentation for detailed integration instructions.
