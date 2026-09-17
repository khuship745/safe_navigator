/// Prevent double-tap navigation bugs in Flutter.
///
/// Exports:
/// - [SafeNavigator]: drop-in replacement for `Navigator` static methods.
/// - [SafeButton]: a widget that debounces any tap callback.
library safe_navigator;

export 'src/safe_navigator_base.dart';
export 'src/safe_button.dart';
