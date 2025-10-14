import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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
  String _platformVersion = 'Unknown';
  int _unread = 0;
  final _dimeloFlutterPlugin = DimeloFlutter();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _dimeloFlutterPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // Initialize Dimelo SDK (replace with your real values)
    await _dimeloFlutterPlugin.initialize(
      applicationSecret: 'X',
      apiKey: 'X',
      apiSecret: 'X',
      domain: 'X',
      userId: 'X',
      developmentApns: false,
    );

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    final unread = await _dimeloFlutterPlugin.getUnreadCount();
    if (mounted) {
      setState(() {
        _platformVersion = platformVersion;
        _unread = unread;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Running on: $_platformVersion'),
              Text('Unread: $_unread'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _dimeloFlutterPlugin.showMessenger();
                },
                child: const Text('Open Messenger'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final ok = await _dimeloFlutterPlugin.setAuthInfo({'ticket_id': 'ABC123'});
                  print('setAuthInfo: $ok');
                },
                child: const Text('Set Auth (ticket_id)'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  await _dimeloFlutterPlugin.setUser(
                    userId: '123',
                    name: 'Test User',
                    email: 'test@example.com',
                    phone: '+123456789',
                  );
                },
                child: const Text('Set User'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final c = await _dimeloFlutterPlugin.getUnreadCount();
                  setState(() => _unread = c);
                },
                child: const Text('Get Unread Count'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  await _dimeloFlutterPlugin.logout();
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
