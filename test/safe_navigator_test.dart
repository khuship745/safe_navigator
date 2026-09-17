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
                    builder: (_) => const Scaffold(body: Text('Second Page')),
                  ),
                );
              },
              child: const Text('Go'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Go'));
    await tester.tap(find.text('Go'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Second Page'), findsOneWidget);
  });

  testWidgets(
      'SafeNavigator.pop right after push is not blocked by push cooldown',
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
                    builder: (innerContext) => Scaffold(
                      body: ElevatedButton(
                        onPressed: () => SafeNavigator.pop(innerContext),
                        child: const Text('Back'),
                      ),
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

    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Go'), findsOneWidget);
    expect(find.text('Back'), findsNothing);
  });

  testWidgets('SafeButton ignores second tap within cooldown', (tester) async {
    int tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeButton(
            onTap: () => tapCount++,
            cooldown: const Duration(milliseconds: 500),
            builder: (context, onSafeTap) => ElevatedButton(
              onPressed: onSafeTap,
              child: const Text('Tap me'),
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
            builder: (context, onSafeTap) => ElevatedButton(
              onPressed: onSafeTap,
              child: const Text('Tap me'),
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

  testWidgets('SafeButton keeps the button visually enabled (has onPressed)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeButton(
            onTap: () {},
            builder: (context, onSafeTap) => ElevatedButton(
              onPressed: onSafeTap,
              child: const Text('Tap me'),
            ),
          ),
        ),
      ),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);
  });
}
