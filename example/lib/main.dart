import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:dimelo_flutter/dimelo_flutter.dart';

/// Dimelo Flutter Example App
/// 
/// To use this example:
/// 1. Replace the constants below with your actual Dimelo credentials
/// 2. Run the app and test the messaging functionality
/// 
/// This example demonstrates all the main features of the Dimelo Flutter plugin.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  int _unreadCount = 0;
  bool _isInitialized = false;
  bool _isLoading = false;
  String _statusMessage = 'Initializing...';
  final _dimeloFlutterPlugin = DimeloFlutter();

  // Configuration constants - Replace these with your actual Dimelo credentials
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  static const String _domain = 'your-domain.dimelo.com';
  static const String _userId = '07XXXXXXXX';
  static const String _userName = 'Demo User';
  static const String _userEmail = 'demo@example.com';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Initialize the app and get platform information
  Future<void> _initializeApp() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Getting platform information...';
    });

    try {
      // Get platform version
      final platformVersion = await _dimeloFlutterPlugin.getPlatformVersion();
      
      if (mounted) {
        setState(() {
          _platformVersion = platformVersion ?? 'Unknown platform version';
          _statusMessage = 'Ready to configure Dimelo';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _platformVersion = 'Failed to get platform version: $e';
          _statusMessage = 'Error getting platform info';
          _isLoading = false;
        });
      }
    }
  }

  /// Initialize Dimelo SDK with predefined credentials
  Future<void> _initializeDimelo() async {
    if (_apiKey == 'YOUR_API_KEY_HERE' || _domain == 'your-domain.dimelo.com') {
      setState(() {
        _statusMessage = 'Please update API Key and Domain constants in the code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Initializing Dimelo SDK...';
    });

    try {
      final success = await _dimeloFlutterPlugin.initialize(
        apiKey: _apiKey,
        domain: _domain,
        userId: _userId,
        developmentApns: kDebugMode,
      );

      if (mounted) {
        if (success) {
          setState(() {
            _isInitialized = true;
            _statusMessage = 'Dimelo initialized successfully!';
            _isLoading = false;
          });
          _showSnackBar('Dimelo initialized successfully!');
          await _refreshUnreadCount();
        } else {
          setState(() {
            _statusMessage = 'Failed to initialize Dimelo';
            _isLoading = false;
          });
          _showSnackBar('Failed to initialize Dimelo', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error initializing Dimelo: $e';
          _isLoading = false;
        });
        _showSnackBar('Error: $e', isError: true);
      }
    }
  }

  /// Set user information
  Future<void> _setUser() async {
    if (!_isInitialized) {
      _showSnackBar('Please initialize Dimelo first', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Setting user information...';
    });

    try {
      final success = await _dimeloFlutterPlugin.setUser(
        userId: _userId,
        name: _userName,
        email: _userEmail,
      );

      if (mounted) {
        if (success) {
          setState(() {
            _statusMessage = 'User information set successfully';
            _isLoading = false;
          });
          _showSnackBar('User information set successfully!');
        } else {
          setState(() {
            _statusMessage = 'Failed to set user information';
            _isLoading = false;
          });
          _showSnackBar('Failed to set user information', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error setting user: $e';
          _isLoading = false;
        });
        _showSnackBar('Error: $e', isError: true);
      }
    }
  }

  /// Show the messaging interface
  Future<void> _showMessenger() async {
    if (!_isInitialized) {
      _showSnackBar('Please initialize Dimelo first', isError: true);
      return;
    }

    try {
      final success = await _dimeloFlutterPlugin.showMessenger();
      if (!success) {
        _showSnackBar('Failed to show messenger', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error showing messenger: $e', isError: true);
    }
  }

  /// Refresh unread message count
  Future<void> _refreshUnreadCount() async {
    if (!_isInitialized) return;

    try {
      final count = await _dimeloFlutterPlugin.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting unread count: $e');
      }
    }
  }

  /// Set authentication information
  Future<void> _setAuthInfo() async {
    if (!_isInitialized) {
      _showSnackBar('Please initialize Dimelo first', isError: true);
      return;
    }

    try {
      final success = await _dimeloFlutterPlugin.setAuthInfo({
        'ticket_id': 'DEMO_${DateTime.now().millisecondsSinceEpoch}',
        'source': 'flutter_example',
      });
      
      if (success) {
        _showSnackBar('Auth info set successfully!');
      } else {
        _showSnackBar('Failed to set auth info', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error setting auth info: $e', isError: true);
    }
  }

  /// Logout from Dimelo
  Future<void> _logout() async {
    if (!_isInitialized) {
      _showSnackBar('Dimelo is not initialized', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Logging out...';
    });

    try {
      final success = await _dimeloFlutterPlugin.logout();
      if (mounted) {
        if (success) {
          setState(() {
            _isInitialized = false;
            _unreadCount = 0;
            _statusMessage = 'Logged out successfully';
            _isLoading = false;
          });
          _showSnackBar('Logged out successfully!');
        } else {
          setState(() {
            _statusMessage = 'Failed to logout';
            _isLoading = false;
          });
          _showSnackBar('Failed to logout', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error during logout: $e';
          _isLoading = false;
        });
        _showSnackBar('Error: $e', isError: true);
      }
    }
  }

  /// Show a snackbar message
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    // Use a post-frame callback to ensure the widget tree is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: isError ? Colors.red : Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } catch (e) {
          // Fallback to debug print if ScaffoldMessenger is not available
          if (kDebugMode) {
            print('SnackBar: $message');
          }
        }
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
      home: ScaffoldMessenger(
        child: Scaffold(
        appBar: AppBar(
          title: const Text('Dimelo Flutter Example'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Please wait...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text('Platform: $_platformVersion'),
                            Text('Status: $_statusMessage'),
                            Text('Unread Messages: $_unreadCount'),
                            Text('Initialized: ${_isInitialized ? "Yes" : "No"}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Configuration Info
                    Card(
                      color: (_apiKey == 'YOUR_API_KEY_HERE' || _domain == 'your-domain.dimelo.com')
                          ? Colors.red.shade50
                          : Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Configuration',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                if (_apiKey == 'YOUR_API_KEY_HERE' || _domain == 'your-domain.dimelo.com')
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(Icons.warning, color: Colors.red, size: 20),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('API Key: $_apiKey'),
                            Text('Domain: $_domain'),
                            Text('User ID: $_userId'),
                            const SizedBox(height: 8),
                            if (_apiKey == 'YOUR_API_KEY_HERE' || _domain == 'your-domain.dimelo.com')
                              const Text(
                                '⚠️ Please update the constants in main.dart with your actual Dimelo credentials',
                                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red),
                              )
                            else
                              const Text(
                                '✅ Configuration looks good!',
                                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.green),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Initialize Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isInitialized ? null : _initializeDimelo,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Initialize Dimelo'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isInitialized ? _setUser : null,
                        icon: const Icon(Icons.person),
                        label: const Text('Set User Information'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isInitialized ? _showMessenger : null,
                        icon: const Icon(Icons.message),
                        label: const Text('Open Messenger'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isInitialized ? _setAuthInfo : null,
                        icon: const Icon(Icons.security),
                        label: const Text('Set Auth Info'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isInitialized ? _refreshUnreadCount : null,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Unread Count'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isInitialized ? _logout : null,
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Instructions
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instructions',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '1. Update the constants at the top of main.dart with your Dimelo credentials\n'
                              '2. Click "Initialize Dimelo" to start\n'
                              '3. Click "Set User Information" to set user details\n'
                              '4. Use "Open Messenger" to test messaging\n'
                              '5. Try other features like auth info and unread count',
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Current Configuration:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('• User: $_userName ($_userEmail)'),
                            Text('• User ID: $_userId'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}