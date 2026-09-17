# safe_navigator

[![pub package](https://img.shields.io/pub/v/safe_navigator.svg)](https://pub.dev/packages/safe_navigator)

Prevent double-tap navigation bugs in Flutter — lightweight, with no
Flutter-framework-replacing dependencies.

Almost every Flutter app has shipped with this bug at some point: a user
double-taps a button, and it pushes the same screen twice. `safe_navigator`
fixes it with a one-line change.

## Why

```dart
// Before: a fast double-tap can push DetailPage twice.
onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage())),

// After: guaranteed single navigation, no other code changes needed.
onPressed: () => SafeNavigator.push(context, MaterialPageRoute(builder: (_) => DetailPage())),
```

No code generation, no `Navigator` replacement or routing framework
migration required. Its only dependency is
[`clock`](https://pub.dev/packages/clock) — a tiny, official Dart-team
package used internally for testable timing, not a heavy framework. It
works alongside `go_router`, `auto_route`, or plain `Navigator` — just
call `SafeNavigator` instead of `Navigator` at the call site you want
protected.

## Install

```yaml
dependencies:
  safe_navigator: ^0.0.1
```

## Usage

### 1. Replace `Navigator` calls with `SafeNavigator`

```dart
import 'package:safe_navigator/safe_navigator.dart';

SafeNavigator.push(context, MaterialPageRoute(builder: (_) => NextPage()));
SafeNavigator.pushNamed(context, '/details');
SafeNavigator.pushReplacement(context, MaterialPageRoute(builder: (_) => NextPage()));
SafeNavigator.pushAndRemoveUntil(context, route, (route) => false);
SafeNavigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
SafeNavigator.popAndPushNamed(context, '/details');
SafeNavigator.pop(context);
SafeNavigator.maybePop(context);
SafeNavigator.popUntil(context, (route) => route.isFirst);
```

Pushes and pops use independent cooldown locks (default 500ms each), so popping right after pushing is never blocked.

Adjust the cooldown once at startup if needed:

```dart
void main() {
  SafeNavigator.cooldown = const Duration(milliseconds: 500);
  runApp(const MyApp());
}
```

### 2. Or wrap any button with `SafeButton`

Use this when you want debounced behavior for something that isn't
navigation — form submits, "Add to cart", API calls, etc.

```dart
SafeButton(
  onTap: () => submitForm(),
  builder: (context, onSafeTap) => ElevatedButton(
    onPressed: onSafeTap,
    child: const Text('Submit'),
  ),
)
```

`SafeButton` has its own independent cooldown, separate from
`SafeNavigator.cooldown`:

```dart
SafeButton(
  onTap: () => addToCart(item),
  cooldown: const Duration(milliseconds: 1000),
  builder: (context, onSafeTap) => ElevatedButton(
    onPressed: onSafeTap,
    child: const Text('Add to cart'),
  ),
)
```

> Note: Pass onSafeTap directly to your button's onPressed or onTap. This preserves the button's native ripple effect and styling while debouncing taps.

## How it works

Both `SafeNavigator` and `SafeButton` record a timestamp on the first
accepted action and simply ignore any further calls that happen before the
cooldown window elapses. No animations, transitions, or extra frames are
added — it's a plain timestamp check, so there's no performance cost.

## FAQ

**Does this replace go_router / auto_route?**
No. Use it alongside them — wrap the specific `context.go(...)` /
`context.push(...)` call, or your own callback, with `SafeButton` if you
want the same protection with those routers.

**Will this ever block a legitimate second navigation?**
Only if two navigation actions of the same type (both pushes, or both
pops) are genuinely fired within the cooldown window (default 500ms
each). That's intentional — that's the exact scenario this package exists
to catch. Lower `pushCooldown`/`popCooldown` if 500ms feels too
aggressive for your UX.
