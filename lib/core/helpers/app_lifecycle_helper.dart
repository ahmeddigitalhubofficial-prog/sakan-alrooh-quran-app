import 'package:flutter/widgets.dart';

/// Helper to check application lifecycle and protect against
/// invoking `setState` or `scheduleFrame` when FlutterJNI is detached in background.
class AppLifecycleHelper with WidgetsBindingObserver {
  VoidCallback? onResumed;
  VoidCallback? onPaused;
  VoidCallback? onHidden;

  /// Returns true if the application is currently in the foreground (resumed)
  /// and actively able to render frames safely.
  static bool get isForeground {
    final state = WidgetsBinding.instance.lifecycleState;
    return state == null || state == AppLifecycleState.resumed;
  }

  /// Returns true if the application is in any background or detached state.
  static bool get isBackground => !isForeground;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed?.call();
    } else if (state == AppLifecycleState.paused) {
      onPaused?.call();
    } else if (state == AppLifecycleState.hidden) {
      onHidden?.call();
    }
  }
}

/// Extension on [State] to safely update state without triggering
/// `scheduleFrame` when the engine is detached in the background.
extension SafeStateExtension<T extends StatefulWidget> on State<T> {
  void safeSetState(VoidCallback fn) {
    if (!mounted) return;
    if (AppLifecycleHelper.isBackground) {
      // Execute the state update mutations locally so variables remain accurate,
      // but bypass `setState` to prevent FlutterJNI.scheduleFrame crashes.
      fn();
      return;
    }
    // ignore: invalid_use_of_protected_member
    setState(fn);
  }
}
