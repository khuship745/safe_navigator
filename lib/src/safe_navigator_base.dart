import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';

/// A drop-in replacement for [Navigator] static methods that prevents
/// duplicate navigation actions caused by rapid double-taps.
class SafeNavigator {
  SafeNavigator._();

  /// Cooldown applied to push-type actions: [push], [pushNamed],
  /// [pushReplacement], [pushReplacementNamed], [pushAndRemoveUntil],
  /// [pushNamedAndRemoveUntil], and [popAndPushNamed].
  static Duration pushCooldown = const Duration(milliseconds: 500);

  /// Cooldown applied to pop-type actions: [pop], [maybePop], [popUntil].
  /// Kept separate from [pushCooldown] so popping a screen you just
  /// pushed is never blocked by the push's own cooldown.
  static Duration popCooldown = const Duration(milliseconds: 500);

  /// Convenience setter that applies the same value to both.
  static set cooldown(Duration value) {
    pushCooldown = value;
    popCooldown = value;
  }

  static DateTime? _lastPushTime;
  static DateTime? _lastPopTime;

  static bool _shouldProceedPush() {
    final now = clock.now();
    if (_lastPushTime != null &&
        now.difference(_lastPushTime!) < pushCooldown) {
      return false;
    }
    _lastPushTime = now;
    return true;
  }

  static bool _shouldProceedPop() {
    final now = clock.now();
    if (_lastPopTime != null && now.difference(_lastPopTime!) < popCooldown) {
      return false;
    }
    _lastPopTime = now;
    return true;
  }

  /// Resets both internal locks. Mainly useful in tests.
  static void reset() {
    _lastPushTime = null;
    _lastPopTime = null;
  }

  static Future<T?> push<T extends Object?>(
    BuildContext context,
    Route<T> route,
  ) async {
    if (!_shouldProceedPush()) return null;
    return Navigator.of(context).push<T>(route);
  }

  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    if (!_shouldProceedPush()) return null;
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    Route<T> route, {
    TO? result,
  }) async {
    if (!_shouldProceedPush()) return null;
    return Navigator.of(context).pushReplacement<T, TO>(route, result: result);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    if (!_shouldProceedPush()) return null;
    return Navigator.of(context).pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    Route<T> newRoute,
    RoutePredicate predicate,
  ) async {
    if (!_shouldProceedPush()) return null;
    return Navigator.of(context).pushAndRemoveUntil<T>(newRoute, predicate);
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  }) async {
    if (!_shouldProceedPush()) return null;
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      newRouteName,
      predicate,
      arguments: arguments,
    );
  }

  static Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    if (!_shouldProceedPush()) return null;
    return Navigator.of(context).popAndPushNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    if (!_shouldProceedPop()) return;
    Navigator.of(context).pop<T>(result);
  }

  static Future<bool> maybePop<T extends Object?>(
    BuildContext context, [
    T? result,
  ]) async {
    if (!_shouldProceedPop()) return false;
    return Navigator.of(context).maybePop<T>(result);
  }

  static void popUntil(BuildContext context, RoutePredicate predicate) {
    if (!_shouldProceedPop()) return;
    Navigator.of(context).popUntil(predicate);
  }
}
