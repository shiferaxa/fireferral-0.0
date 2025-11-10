import 'package:flutter/material.dart';

void main() {
  runApp(const DebugApp());
}

class DebugApp extends StatelessWidget {
  const DebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iOS Debug Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DebugHomePage(),
    );
  }
}

class DebugHomePage extends StatelessWidget {
  const DebugHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iOS Debug Test'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'iOS App is Running!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'This is a minimal test to check if the iOS app works.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}