import 'package:flutter/widgets.dart';

/// A drop-in replacement for [Navigator] static methods that prevents
/// duplicate navigation actions caused by rapid double-taps.
///
/// Every Flutter app eventually ships a bug where a fast double-tap on a
/// button pushes the same screen twice. [SafeNavigator] fixes that with a
/// simple cooldown lock shared across the whole app.
///
/// Usage:
/// ```dart
/// SafeNavigator.push(context, MaterialPageRoute(builder: (_) => NextPage()));
/// SafeNavigator.pushNamed(context, '/details');
/// SafeNavigator.pop(context);
/// ```
class SafeNavigator {
  SafeNavigator._();

  /// Global cooldown duration applied to every navigation call.
  ///
  /// Defaults to 800ms. Override once at app startup if you need a
  /// different value, e.g. `SafeNavigator.cooldown = Duration(milliseconds: 500);`
  static Duration cooldown = const Duration(milliseconds: 800);

  static DateTime? _lastActionTime;

  /// Returns true and records the action if enough time has passed since
  /// the last navigation action. Returns false if the call should be
  /// ignored because it happened too soon after the previous one.
  static bool _shouldProceed() {
    final now = DateTime.now();
    if (_lastActionTime != null &&
        now.difference(_lastActionTime!) < cooldown) {
      return false;
    }
    _lastActionTime = now;
    return true;
  }

  /// Resets the internal lock. Rarely needed — mainly useful in tests.
  static void reset() {
    _lastActionTime = null;
  }

  /// Safe equivalent of [Navigator.push].
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    Route<T> route,
  ) async {
    if (!_shouldProceed()) return null;
    return Navigator.of(context).push<T>(route);
  }

  /// Safe equivalent of [Navigator.pushNamed].
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    if (!_shouldProceed()) return null;
    return Navigator.of(context)
        .pushNamed<T>(routeName, arguments: arguments);
  }

  /// Safe equivalent of [Navigator.pushReplacement].
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    Route<T> route, {
    TO? result,
  }) async {
    if (!_shouldProceed()) return null;
    return Navigator.of(context)
        .pushReplacement<T, TO>(route, result: result);
  }

  /// Safe equivalent of [Navigator.pushReplacementNamed].
  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    if (!_shouldProceed()) return null;
    return Navigator.of(context).pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  /// Safe equivalent of [Navigator.pushAndRemoveUntil].
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    Route<T> newRoute,
    RoutePredicate predicate,
  ) async {
    if (!_shouldProceed()) return null;
    return Navigator.of(context)
        .pushAndRemoveUntil<T>(newRoute, predicate);
  }

  /// Safe equivalent of [Navigator.pop]. Guards against rapid multi-pop
  /// as well (e.g. a user tapping the back button several times fast).
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    if (!_shouldProceed()) return;
    Navigator.of(context).pop<T>(result);
  }

  /// Safe equivalent of [Navigator.maybePop].
  static Future<bool> maybePop<T extends Object?>(
    BuildContext context, [
    T? result,
  ]) async {
    if (!_shouldProceed()) return false;
    return Navigator.of(context).maybePop<T>(result);
  }
}
