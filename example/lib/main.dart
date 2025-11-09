import 'dart:developer';

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
  String _lastEvent = 'No events yet';

  // Replace these with your actual Dimelo credentials
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  static const String _domain = 'your-domain.dimelo.com';
  static const String _userId = 'user123';
  static const String _userName = 'Demo User';
  static const String _userEmail = 'demo@example.com';

  @override
  void initState() {
    super.initState();
    _setupEventListener();
  }

  /// Set up the Dimelo event stream listener
  void _setupEventListener() {
    _dimeloFlutterPlugin.eventStream.listen((event) {
      if (mounted) {
        final eventType = event['event'] as String? ?? 'unknown';
        final timestamp = event['timestamp'] as int? ?? 0;
        final formattedTime =
            DateTime.fromMillisecondsSinceEpoch(timestamp).toString();

        setState(() {
          switch (eventType) {
            case 'onChatActivityClosed':
              _lastEvent = 'Chat activity closed at $formattedTime';
              _statusMessage = 'Chat activity was closed';
              log("onChatActivityClosed event:========================= ");
              break;
            case 'onChatActivityOpened':
              _lastEvent = 'Chat activity opened at $formattedTime';
              _statusMessage = 'Chat activity is now open';
              log("onChatActivityOpened event:========================= ");
              break;
            case 'onClose':
              _lastEvent = 'Chat closed at $formattedTime';
              _statusMessage = 'Chat was closed by user';
              log("onClose event:========================= ");
              break;
            case 'onOpen':
              _lastEvent = 'Chat opened at $formattedTime';
              _statusMessage = 'Chat is now open';
              log("onOpen event:========================= ");
              break;
            case 'onMessage':
              final message = event['message'] as String? ?? '';
              _lastEvent = 'New message received: "$message" at $formattedTime';
              log("on message event:========================= $message");
              break;
            case 'onUnreadCountChanged':
              final count = event['unreadCount'] as int? ?? 0;
              final userId = event['userId'] as String? ?? '';
              final userName = event['userName'] as String? ?? '';
              _unreadCount = count;
              _lastEvent =
                  'Unread count changed to $count for user: $userName ($userId) at $formattedTime';
              log("onUnreadCountChanged event: $count messages for user $userId ($userName)");
              break;
            default:
              _lastEvent = 'Unknown event: $eventType at $formattedTime';
          }
        });

        // Show a snackbar for important events
        if (eventType == 'onClose' || eventType == 'onChatActivityClosed') {
          log("eventType == 'onClose' || eventType == 'onChatActivityClosed'======================== ");
          log("$eventType:========================= ");
        } else if (eventType == 'onUnreadCountChanged') {
          log("onUnreadCountChanged xonUnreadCountChanged ============== ");
          log("$eventType:========================= ");
        }
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _lastEvent = 'Event stream error: $error';
        });
      }
    });
  }

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
          child: SingleChildScrollView(
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
                const SizedBox(height: 16),

                // Event Card
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latest Event',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _lastEvent,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Listen to onClose events to perform actions when chat is closed',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                        ),
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
                  onPressed: _isInitialized ? _getCurrentUser : null,
                  child: const Text('Get Current User'),
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
                const SizedBox(height: 20),

                // App Bar Customization Section
                const Text(
                  'App Bar Customization',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: _isInitialized ? _changeAppBarTitle : null,
                  child: const Text('Change App Bar Title'),
                ),
                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: _isInitialized ? _changeAppBarColor : null,
                  child: const Text('Change App Bar Color'),
                ),
                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: _isInitialized ? _toggleAppBarVisibility : null,
                  child: const Text('Toggle App Bar Visibility'),
                ),
                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: _isInitialized ? _toggleBackButton : null,
                  child: const Text('Toggle Back Button'),
                ),
                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed:
                      _isInitialized ? _toggleFullScreenPresentation : null,
                  child: const Text('Toggle Full Screen (iOS)'),
                ),
                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: _isInitialized ? _testBackButton : null,
                  child: const Text('Test Back Button (Android)'),
                ),
              ],
            ),
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
        setState(() => _statusMessage =
            success ? 'User set successfully!' : 'Failed to set user');
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

  /// Change app bar title dynamically
  Future<void> _changeAppBarTitle() async {
    try {
      final success = await _dimeloFlutterPlugin.setAppBarTitle(
          'Dynamic Title ${DateTime.now().millisecondsSinceEpoch % 1000}');
      if (kDebugMode) {
        print(success
            ? 'App bar title changed!'
            : 'Failed to change app bar title');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error changing app bar title: $e');
      }
    }
  }

  /// Change app bar color dynamically
  Future<void> _changeAppBarColor() async {
    try {
      final colors = [
        '#FF0000',
        '#00FF00',
        '#0000FF',
        '#FFFF00',
        '#FF00FF',
        '#00FFFF'
      ];
      final randomColor =
          colors[DateTime.now().millisecondsSinceEpoch % colors.length];
      final success = await _dimeloFlutterPlugin.setAppBarColor(randomColor);
      if (kDebugMode) {
        print(success
            ? 'App bar color changed to $randomColor!'
            : 'Failed to change app bar color');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error changing app bar color: $e');
      }
    }
  }

  /// Toggle app bar visibility
  Future<void> _toggleAppBarVisibility() async {
    try {
      // Get current config to toggle visibility
      final config = await _dimeloFlutterPlugin.getAppBarConfig();
      final currentVisibility = config['visible'] as bool? ?? true;
      final success = await _dimeloFlutterPlugin.setAppBarVisibility(
          visible: !currentVisibility);
      if (kDebugMode) {
        print(success
            ? 'App bar visibility toggled!'
            : 'Failed to toggle app bar visibility');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling app bar visibility: $e');
      }
    }
  }

  /// Get current user information
  Future<void> _getCurrentUser() async {
    try {
      final userInfo = await _dimeloFlutterPlugin.getCurrentUser();
      final userId = userInfo['userId'] ?? '';
      final userName = userInfo['userName'] ?? '';
      final userEmail = userInfo['userEmail'] ?? '';
      final userPhone = userInfo['userPhone'] ?? '';

      setState(() {
        _statusMessage = 'Current user: $userName ($userId)';
      });
      // Show user info in status message and console (avoid dialog issues)
      print('=== CURRENT USER INFO ===');
      print('User ID: $userId');
      print('User Name: $userName');
      print('User Email: $userEmail');
      print('User Phone: $userPhone');
      print('========================');
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to get current user: $e';
      });
      print('Error getting current user: $e');
    }
  }

  /// Toggle back button visibility
  Future<void> _toggleBackButton() async {
    try {
      // Get current config to toggle back button
      final config = await _dimeloFlutterPlugin.getAppBarConfig();
      final currentBackButton = config['showBackButton'] as bool? ?? true;
      final success = await _dimeloFlutterPlugin.setBackButtonVisibility(
          visible: !currentBackButton);
      if (kDebugMode) {
        print(success
            ? 'Back button visibility toggled!'
            : 'Failed to toggle back button visibility');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling back button visibility: $e');
      }
    }
  }

  /// Toggle full screen presentation (iOS only)
  Future<void> _toggleFullScreenPresentation() async {
    try {
      // Get current config to toggle full screen presentation
      final config = await _dimeloFlutterPlugin.getAppBarConfig();
      final currentFullScreen =
          config['fullScreenPresentation'] as bool? ?? true;
      final success = await _dimeloFlutterPlugin.setFullScreenPresentation(
          fullScreen: !currentFullScreen);
      if (kDebugMode) {
        print(success
            ? 'Full screen presentation toggled!'
            : 'Failed to toggle full screen presentation');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling full screen presentation: $e');
      }
    }
  }

  /// Test back button functionality (Android)
  Future<void> _testBackButton() async {
    try {
      // Ensure back button is enabled
      await _dimeloFlutterPlugin.setBackButtonVisibility(visible: true);

      // Show messenger to test back button
      final success = await _dimeloFlutterPlugin.showMessenger();
      if (kDebugMode) {
        print(success
            ? 'Messenger opened - test the back button!'
            : 'Failed to open messenger');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error testing back button: $e');
      }
    }
  }
}
