import 'package:get_storage/get_storage.dart';

/// Remembers which orders the current user has already reviewed.
///
/// Persisted to GetStorage so the "Give Feedback" / "Rate & Review" button
/// stays hidden across hot reloads AND full app restarts — not just the
/// current session. Shared across ChatView, OrderView and MyJobView.
///
/// The backend is the real source of truth (it rejects a second review with
/// "Your feedback already submited!"). When the views hit that response they
/// also call [mark], so even if this local cache is ever out of sync it
/// self-heals on the next attempt.
///
/// Place this file at: lib/app/service/reviewed_orders.dart
/// (GetStorage.init() is already called in main(), so no extra setup needed.)
class ReviewedOrders {
  ReviewedOrders._();

  static const String _key = 'reviewed_order_ids';

  static GetStorage get _box => GetStorage();

  static Set<int>? _cache;

  static Set<int> get _ids {
    if (_cache != null) return _cache!;
    Set<int> loaded = <int>{};
    try {
      final raw = _box.read(_key);
      if (raw is List) {
        loaded = raw
            .map((e) => e is num ? e.toInt() : int.tryParse('$e') ?? -1)
            .where((e) => e >= 0)
            .toSet();
      }
    } catch (_) {
      // storage not ready / corrupt — start empty
    }
    _cache = loaded;
    return _cache!;
  }

  /// True if [orderId] has already been reviewed by the current user.
  static bool has(int orderId) => _ids.contains(orderId);

  /// Marks [orderId] as reviewed and persists it.
  static void mark(int orderId) {
    final ids = _ids;
    if (ids.add(orderId)) {
      try {
        _box.write(_key, ids.toList());
      } catch (_) {
        // ignore write failures; in-memory cache still reflects it
      }
    }
  }
}