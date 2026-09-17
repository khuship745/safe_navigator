import 'package:flutter/material.dart';
import 'package:safe_navigator/safe_navigator.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'safe_navigator example',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('safe_navigator demo')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Try rapidly tapping each button below.\n'
              'You will only ever land on ONE detail screen,\n'
              'never a stack of duplicates.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Unsafe: plain Navigator.push, no protection.
            // Rapid-tapping this WILL push the Detail Page twice.
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DetailPage()),
                );
              },
              child: const Text('Push WITHOUT protection (buggy)'),
            ),
            const SizedBox(height: 12),

            // Option 1: use SafeNavigator directly instead of Navigator.
            ElevatedButton(
              onPressed: () {
                SafeNavigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DetailPage()),
                );
              },
              child: const Text('Push with SafeNavigator'),
            ),
            const SizedBox(height: 12),

            // Option 2: wrap any existing button with SafeButton.
            SafeButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DetailPage()),
                );
              },
              child: ElevatedButton(
                onPressed: null,
                child: const Text('Push with SafeButton wrapper'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => SafeNavigator.pop(context),
          child: const Text('Go back safely'),
        ),
      ),
    );
  }
}
