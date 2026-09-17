# safe_navigator example

Demonstrates `safe_navigator`'s three ways to prevent double-tap navigation bugs:

1. **Unsafe (buggy)** — plain `Navigator.push`, shown for comparison. Rapid-tapping this can push the Detail Page multiple times.
2. **`SafeNavigator.push`** — drop-in replacement for `Navigator` static methods.
3. **`SafeButton`** — wraps any button and debounces its tap, without disabling its ripple/enabled styling.

## Run it

```bash
flutter pub get
flutter run
```

See the main package README for full usage docs: [../README.md](../README.md)