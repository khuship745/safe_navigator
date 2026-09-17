import 'package:flutter_test/flutter_test.dart';
import 'package:safe_navigator/safe_navigator.dart';
import 'package:safe_navigator_example/main.dart';

void main() {
  setUp(() {
    // Without this, SafeNavigator's push cooldown from one test can still
    // be active when the next test starts, silently blocking its push.
    SafeNavigator.reset();
  });

  testWidgets('Home page shows all three demo buttons', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Push WITHOUT protection (buggy)'), findsOneWidget);
    expect(find.text('Push with SafeNavigator'), findsOneWidget);
    expect(find.text('Push with SafeButton wrapper'), findsOneWidget);
  });

  testWidgets('SafeNavigator button navigates to Detail Page', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Push with SafeNavigator'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Page'), findsOneWidget);
    expect(find.text('Go back safely'), findsOneWidget);
  });

  testWidgets('Detail Page pops back to Home', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Push with SafeNavigator'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Go back safely'));
    await tester.pumpAndSettle();

    expect(find.text('safe_navigator demo'), findsOneWidget);
  });
}
