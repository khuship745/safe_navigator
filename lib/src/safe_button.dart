import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

/// Wraps any tappable child and debounces its tap callback, so rapid
/// double/triple taps only fire [onTap] once within [cooldown].
///
/// Useful for anything you don't want triggered twice — not just
/// navigation, but also form submits, API calls, add-to-cart buttons, etc.
///
/// Usage:
/// ```dart
/// SafeButton(
///   onTap: () => submitForm(),
///   child: ElevatedButton(
///     onPressed: null, // handled by SafeButton's GestureDetector
///     child: Text('Submit'),
///   ),
/// )
/// ```
///
/// For simple cases, wrap the whole button:
/// ```dart
/// SafeButton(
///   onTap: () => Navigator.pushNamed(context, '/next'),
///   child: ElevatedButton(onPressed: null, child: Text('Next')),
/// )
/// ```
class SafeButton extends StatefulWidget {
  const SafeButton({
    super.key,
    required this.onTap,
    required this.child,
    this.cooldown = const Duration(milliseconds: 800),
    this.behavior = HitTestBehavior.opaque,
  });

  /// Callback fired on the first tap within the cooldown window.
  final VoidCallback onTap;

  /// The widget to display. Typically a button with `onPressed: null`
  /// since SafeButton itself handles the tap via [GestureDetector].
  final Widget child;

  /// How long to ignore subsequent taps after one is accepted.
  final Duration cooldown;

  /// Hit test behavior passed to the internal [GestureDetector].
  final HitTestBehavior behavior;

  @override
  State<SafeButton> createState() => _SafeButtonState();
}

class _SafeButtonState extends State<SafeButton> {
  DateTime? _lastTapTime;

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < widget.cooldown) {
      return;
    }
    _lastTapTime = now;
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTap: _handleTap,
      child: widget.child,
    );
  }
}
