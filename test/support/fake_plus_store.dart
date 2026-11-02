import 'dart:async';
import 'package:haze_bot_app/services/haze_plus_store.dart';

class FakePlusStore implements HazePlusStore {
  final changes = StreamController<bool>.broadcast(sync: true);
  bool owned = false;
  bool unavailable = false;
  PlusOffer? offer = const PlusOffer('R\$ 19,90');
  Object? purchaseError;
  Object? restoreError;
  Completer<bool>? purchaseCompleter;
  int purchases = 0;
  bool purchaseGrants = true;
  int restores = 0;

  @override
  Stream<bool> get ownershipChanges => changes.stream;
  @override
  Future<void> initialize() async {
    if (unavailable) throw PlusStoreError.unavailable;
  }

  @override
  Future<bool> ownsPlus({bool refresh = false}) async {
    if (unavailable) throw PlusStoreError.unavailable;
    return owned;
  }

  @override
  Future<PlusOffer?> loadOffer() async => offer;
  @override
  Future<bool> purchase() async {
    purchases++;
    if (purchaseError != null) throw purchaseError!;
    owned = purchaseCompleter == null
        ? purchaseGrants
        : await purchaseCompleter!.future;
    return owned;
  }

  @override
  Future<bool> restore() async {
    restores++;
    if (restoreError != null) throw restoreError!;
    return owned;
  }

  void setOwned(bool value) {
    owned = value;
    changes.add(value);
  }

  @override
  void dispose() => changes.close();
}
