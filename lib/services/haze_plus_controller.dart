import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/haze_look.dart';
import 'haze_plus_store.dart';

enum PlusMessage {
  unavailable,
  failed,
  pending,
  unlocked,
  restored,
  nothingToRestore,
  saveFailed,
}

class HazePlusController extends ChangeNotifier with WidgetsBindingObserver {
  static const lookKey = 'haze_plus_look';
  final HazePlusStore _store;
  StreamSubscription<bool>? _subscription;
  Future<void>? _initializing;
  bool _disposed = false;
  bool _ready = false;
  bool _busy = false;
  bool _owned = false;
  HazeLook _savedLook = const HazeLook();
  PlusOffer? offer;
  PlusMessage? message;

  HazePlusController({HazePlusStore? store})
    : _store = store ?? RevenueCatPlusStore();

  bool get ownsPlus => _owned;
  bool get busy => _busy;
  bool get canRestore => _ready && !_busy;
  bool get canPurchase =>
      _ready &&
      !_busy &&
      !_owned &&
      offer != null &&
      message != PlusMessage.pending;
  HazeLook get look => _owned ? _savedLook : const HazeLook();

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> initialize() => _initializing ??= _initialize();

  Future<void> _initialize() async {
    WidgetsBinding.instance.addObserver(this);
    _busy = true;
    _notify();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(lookKey);
      if (raw != null) {
        try {
          _savedLook = HazeLook.fromJson(
            jsonDecode(raw) as Map<String, dynamic>,
          );
        } catch (_) {
          _savedLook = const HazeLook();
        }
      }
    } catch (_) {
      // A preference failure must not prevent purchase restoration.
    }
    if (_disposed) return;
    try {
      _subscription = _store.ownershipChanges.listen((owned) {
        if (_disposed) return;
        _owned = owned;
        if (owned &&
            (message == PlusMessage.pending ||
                message == PlusMessage.unavailable ||
                message == PlusMessage.nothingToRestore)) {
          message = PlusMessage.unlocked;
        }
        _notify();
      }, onError: (_) {});
      await _store.initialize();
      if (_disposed) return;
      _ready = true;
      _owned = await _store.ownsPlus();
      offer = await _store.loadOffer();
      if (offer == null && !_owned) message = PlusMessage.unavailable;
    } catch (_) {
      message = _owned ? null : PlusMessage.unavailable;
    } finally {
      _busy = false;
      _notify();
    }
  }

  /// Retry product lookup separately from ownership. A network error must
  /// never wipe a previously verified entitlement or saved look.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(refresh());
  }

  Future<void> refresh() async {
    await initialize();
    if (_busy || _disposed) return;
    _busy = true;
    message = null;
    _notify();
    try {
      if (!_ready) {
        await _store.initialize();
        _ready = true;
      }
      _owned = await _store.ownsPlus(refresh: true);
      offer = await _store.loadOffer();
      if (offer == null && !_owned) message = PlusMessage.unavailable;
    } catch (_) {
      message = _owned ? null : PlusMessage.unavailable;
    } finally {
      _busy = false;
      _notify();
    }
  }

  Future<void> purchase() async {
    if (!canPurchase) return;
    _busy = true;
    message = null;
    _notify();
    try {
      _owned = await _store.purchase();
      message = _owned ? PlusMessage.unlocked : PlusMessage.pending;
    } on PlusStoreError catch (error) {
      message = switch (error) {
        PlusStoreError.cancelled => null,
        PlusStoreError.pending => PlusMessage.pending,
        PlusStoreError.unavailable => PlusMessage.unavailable,
        PlusStoreError.failed => PlusMessage.failed,
      };
    } catch (_) {
      message = PlusMessage.failed;
    } finally {
      _busy = false;
      _notify();
    }
  }

  Future<void> restore() async {
    if (!canRestore) return;
    _busy = true;
    message = null;
    _notify();
    try {
      _owned = await _store.restore();
      message = _owned ? PlusMessage.restored : PlusMessage.nothingToRestore;
    } catch (_) {
      message = PlusMessage.failed;
    } finally {
      _busy = false;
      _notify();
    }
  }

  Future<bool> apply(HazeLook next) async {
    await initialize();
    if (_disposed || _busy || (next.needsPlus && !_owned)) return false;
    _busy = true;
    _notify();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString(lookKey, jsonEncode(next.toJson()))) {
        throw StateError('Look was not saved');
      }
      _savedLook = next;
      message = null;
      return true;
    } catch (_) {
      message = PlusMessage.saveFailed;
      return false;
    } finally {
      _busy = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    _store.dispose();
    super.dispose();
  }
}
