import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_navigator/safe_navigator.dart';

void main() {
  setUp(() {
    SafeNavigator.reset();
    SafeNavigator.cooldown = const Duration(milliseconds: 500);
  });

  testWidgets('SafeNavigator.push only navigates once on rapid double tap',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                SafeNavigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Scaffold(
                      body: Text('Second Page'),
                    ),
                  ),
                );
              },
              child: const Text('Go'),
            ),
          ),
        ),
      ),
    );

    // Simulate two rapid taps.
    await tester.tap(find.text('Go'));
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    // Only one 'Second Page' should exist — not stacked twice.
    expect(find.text('Second Page'), findsOneWidget);
  });

  testWidgets('SafeButton ignores second tap within cooldown',
      (tester) async {
    int tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeButton(
            onTap: () => tapCount++,
            cooldown: const Duration(milliseconds: 500),
            child: const ElevatedButton(
              onPressed: null,
              child: Text('Tap me'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tap me'));
    await tester.tap(find.text('Tap me'));
    await tester.pump();

    expect(tapCount, 1);
  });

  testWidgets('SafeButton allows a second tap after cooldown passes',
      (tester) async {
    int tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeButton(
            onTap: () => tapCount++,
            cooldown: const Duration(milliseconds: 100),
            child: const ElevatedButton(
              onPressed: null,
              child: Text('Tap me'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tap me'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Tap me'));
    await tester.pump();

    expect(tapCount, 2);
  });
}
