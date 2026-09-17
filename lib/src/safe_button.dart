import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';

/// Debounces any tap action so rapid double/triple taps only fire once
/// within [cooldown] — without disabling the wrapped button's ripple or
/// enabled styling.
class SafeButton extends StatefulWidget {
  const SafeButton({
    super.key,
    required this.builder,
    required this.onTap,
    this.cooldown = const Duration(milliseconds: 800),
  });

  /// Builds the actual button widget. Pass [onSafeTap] directly to the
  /// button's own `onPressed`/`onTap` — it is already debounced.
  final Widget Function(BuildContext context, VoidCallback onSafeTap) builder;

  /// Callback fired on every accepted (non-debounced) tap.
  final VoidCallback onTap;

  /// How long to ignore subsequent taps after one is accepted.
  final Duration cooldown;

  @override
  State<SafeButton> createState() => _SafeButtonState();
}

class _SafeButtonState extends State<SafeButton> {
  DateTime? _lastTapTime;

  void _handleTap() {
    final now = clock.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < widget.cooldown) {
      return;
    }
    _lastTapTime = now;
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _handleTap);
  }
}
