import 'dart:async';
import 'package:flutter/foundation.dart';

/// Adapts any [Stream] into a [Listenable] so go_router's `refreshListenable`
/// re-evaluates its `redirect` callback whenever the stream emits — used
/// here to re-run redirect logic on every AuthBloc state change.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
