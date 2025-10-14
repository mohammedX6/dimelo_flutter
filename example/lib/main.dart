import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dimelo_flutter/dimelo_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _dimeloFlutterPlugin = DimeloFlutter();
  bool _isInitialized = false;
  int _unreadCount = 0;
  String _statusMessage = 'Ready to initialize';

  // Replace these with your actual Dimelo credentials
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  static const String _domain = 'your-domain.dimelo.com';
  static const String _userId = 'user123';
  static const String _userName = 'Demo User';
  static const String _userEmail = 'demo@example.com';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dimelo Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dimelo Flutter Example'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: $_statusMessage',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Unread Messages: $_unreadCount'),
                      Text('Initialized: ${_isInitialized ? "Yes" : "No"}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              ElevatedButton(
                onPressed: _isInitialized ? null : _initializeDimelo,
                child: const Text('Initialize Dimelo'),
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _isInitialized ? _setUser : null,
                child: const Text('Set User Info'),
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _isInitialized ? _showMessenger : null,
                child: const Text('Show Messenger'),
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _isInitialized ? _refreshUnreadCount : null,
                child: const Text('Refresh Unread Count'),
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _isInitialized ? _logout : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Initialize Dimelo SDK
  Future<void> _initializeDimelo() async {
    if (_apiKey == 'YOUR_API_KEY_HERE' || _domain == 'your-domain.dimelo.com') {
      if (kDebugMode) {
        print('Please update API Key and Domain in the code');
      }
      return;
    }

    setState(() => _statusMessage = 'Initializing...');

    try {
      final success = await _dimeloFlutterPlugin.initialize(
        apiKey: _apiKey,
        domain: _domain,
        userId: _userId,
        developmentApns: kDebugMode,
      );

      if (mounted) {
        setState(() {
          _isInitialized = success;
          _statusMessage = success ? 'Initialized successfully!' : 'Initialization failed';
        });

        if (success) {
          if (kDebugMode) {
            print('Dimelo initialized successfully!');
          }
          await _refreshUnreadCount();
        } else {
          if (kDebugMode) {
            print('Failed to initialize Dimelo');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = 'Error: $e');
        if (kDebugMode) {
          print('Error: $e');
        }
      }
    }
  }

  /// Set user information
  Future<void> _setUser() async {
    setState(() => _statusMessage = 'Setting user...');

    try {
      final success = await _dimeloFlutterPlugin.setUser(
        userId: _userId,
        name: _userName,
        email: _userEmail,
      );

      if (mounted) {
        setState(() => _statusMessage = success ? 'User set successfully!' : 'Failed to set user');
        if (kDebugMode) {
          print(success ? 'User information set!' : 'Failed to set user');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = 'Error: $e');
        if (kDebugMode) {
          print('Error: $e');
        }
      }
    }
  }

  /// Show the messaging interface
  Future<void> _showMessenger() async {
    try {
      final isAvailable = await _dimeloFlutterPlugin.isAvailable();
      if (isAvailable) {
        await _dimeloFlutterPlugin.showMessenger();
        await _refreshUnreadCount();
      } else {
        if (kDebugMode) {
          print('Messaging is not available');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  /// Refresh unread message count
  Future<void> _refreshUnreadCount() async {
    try {
      final count = await _dimeloFlutterPlugin.getUnreadCount();
      if (mounted) {
        setState(() => _unreadCount = count);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting unread count: $e');
      }
    }
  }

  /// Logout from Dimelo
  Future<void> _logout() async {
    try {
      await _dimeloFlutterPlugin.logout();
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _unreadCount = 0;
          _statusMessage = 'Logged out';
        });
        if (kDebugMode) {
          print('Logged out successfully');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }
}
