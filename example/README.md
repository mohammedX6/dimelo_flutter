# Dimelo Flutter Example App

This example app demonstrates how to use the Dimelo Flutter plugin for in-app messaging.

## Quick Start

1. **Configure your credentials** in `lib/main.dart`:
   ```dart
   // Replace these with your actual Dimelo credentials
   static const String _apiKey = 'YOUR_API_KEY_HERE';
   static const String _domain = 'your-domain.dimelo.com';
   static const String _userId = 'demo_user_123';
   static const String _userName = 'Demo User';
   static const String _userEmail = 'demo@example.com';
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

3. **Test the features**:
   - Click "Initialize Dimelo" to start
   - Click "Set User Information" to set user details
   - Click "Open Messenger" to test messaging
   - Try other features like auth info and unread count

## Features Demonstrated

- ✅ SDK Initialization
- ✅ User Management
- ✅ Messaging Interface
- ✅ Unread Message Count
- ✅ Authentication Info
- ✅ Error Handling
- ✅ Status Monitoring

## Getting Dimelo Credentials

To get your Dimelo credentials:

1. Sign up at [Dimelo](https://mobile-messaging.dimelo.com/)
2. Create a new app in your Dimelo dashboard
3. Copy the API Key and Domain from your app settings
4. Replace the placeholder values in the code

## Troubleshooting

- **"Please update API Key and Domain constants"**: Make sure you've replaced the placeholder values with your actual credentials
- **"Failed to initialize Dimelo"**: Check that your API key and domain are correct
- **Messaging not working**: Ensure you've called `initialize()` and `setUser()` before showing the messenger

## Platform Setup

Make sure you've completed the platform setup as described in the main README:

- **Android**: Add Dimelo SDK dependency and permissions
- **iOS**: Add Dimelo pod and configure Info.plist

For detailed setup instructions, see the main [README.md](../README.md).