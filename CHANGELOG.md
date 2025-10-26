# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

### [0.1.8] - 2025-10-26 
### Fixed
New parameters to customize the App Bar, including:
-Title text
-App bar color
-Back arrow support
-Full-screen layout support for iOS devices (replacing the previous bottom sheet design)


### Changed
- Enhanced UI consistency across Android and iOS
- Improved overall design and user experience for iOS full-screen display

## [0.1.7] - 2025-10-14

### Fixed
- Updated package naming from com.example to com.flyingapps.dimelo_flutter
- Simplified example app with cleaner code structure
- Fixed Gradle configuration for proper Android build support
- Improved error handling with debug mode logging

### Changed
- Example app now uses print statements instead of ScaffoldMessenger
- Updated Android package structure for better organization
- Enhanced example app with conditional debug logging
- Updated README with comprehensive Android setup instructions
- Added proper Maven repository configuration for Dimelo SDKs
- Added app compatibility requirements and version specifications

## [0.1.6] - 2025-10-14

### Added
- Core messaging functionality
- User authentication and management
- Unread message count tracking
- Push notification support
- Cross-platform Android and iOS support

### Features
- `initialize()` - Initialize Dimelo SDK
- `setUser()` - Set user information
- `showMessenger()` - Display messaging interface
- `logout()` - Logout current user
- `isAvailable()` - Check if messaging is available
- `getUnreadCount()` - Get count of unread messages
- `setAuthInfo()` - Set authentication information
- `setDeviceToken()` - Set device push token
- `handlePush()` - Handle incoming push notifications

### Documentation
- Comprehensive README with installation instructions
- Platform-specific setup guides for Android and iOS
- API reference with examples
- Troubleshooting section
- Clear disclaimer about unofficial status

## [0.0.1] - 2025-10-14

### Added
- Initial project setup
- Basic Flutter plugin structure
- Platform interface definitions
- Method channel implementation

---

**Note**: This is an unofficial Flutter plugin for Dimelo/RingCentral Engage Digital Messaging. 
For official support, please refer to the [official Dimelo documentation](https://mobile-messaging.dimelo.com/).