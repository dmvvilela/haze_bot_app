import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PlusOffer {
  final String localizedPrice;
  const PlusOffer(this.localizedPrice);
}

enum PlusStoreError { unavailable, cancelled, pending, failed }

/// The adapter returns verified entitlement state, never a local paid flag.
abstract class HazePlusStore {
  Stream<bool> get ownershipChanges;
  Future<void> initialize();
  Future<bool> ownsPlus({bool refresh = false});
  Future<PlusOffer?> loadOffer();
  Future<bool> purchase();
  Future<bool> restore();
  void dispose();
}

class RevenueCatPlusStore implements HazePlusStore {
  static const entitlementId = 'haze_plus';
  static const productId = 'haze_plus_lifetime';
  final _changes = StreamController<bool>.broadcast();
  bool _ready = false;
  bool _disposed = false;
  StoreProduct? _product;

  @override
  Stream<bool> get ownershipChanges => _changes.stream;

  static bool hasPlus(CustomerInfo info) {
    final entitlement = info.entitlements.active[entitlementId];
    // A mistaken subscription mapping must never be sold as a permanent pack.
    return entitlement != null &&
        entitlement.productIdentifier == productId &&
        entitlement.expirationDate == null &&
        entitlement.verification != VerificationResult.failed &&
        info.entitlements.verification != VerificationResult.failed;
  }

  void _updated(CustomerInfo info) {
    if (!_disposed) _changes.add(hasPlus(info));
  }

  @override
  Future<void> initialize() async {
    if (_ready) return;
    final key = kIsWeb
        ? ''
        : switch (defaultTargetPlatform) {
            TargetPlatform.iOS => const String.fromEnvironment(
              'HAZE_RC_APPLE_KEY',
            ),
            TargetPlatform.android => const String.fromEnvironment(
              'HAZE_RC_GOOGLE_KEY',
            ),
            _ => '',
          };
    if (key.isEmpty || (kReleaseMode && key.startsWith('test_'))) {
      throw PlusStoreError.unavailable;
    }
    await Purchases.configure(
      PurchasesConfiguration(key)
        ..automaticDeviceIdentifierCollectionEnabled = false
        ..entitlementVerificationMode =
            EntitlementVerificationMode.informational,
    );
    if (_disposed) return;
    _ready = true;
    Purchases.addCustomerInfoUpdateListener(_updated);
  }

  void _requireReady() {
    if (!_ready || _disposed) throw PlusStoreError.unavailable;
  }

  @override
  Future<bool> ownsPlus({bool refresh = false}) async {
    _requireReady();
    if (refresh) await Purchases.invalidateCustomerInfoCache();
    return hasPlus(await Purchases.getCustomerInfo());
  }

  @override
  Future<PlusOffer?> loadOffer() async {
    _requireReady();
    final products = await Purchases.getProducts([
      productId,
    ], productCategory: ProductCategory.nonSubscription);
    _product = products
        .where(
          (p) =>
              p.identifier == productId &&
              p.productCategory == ProductCategory.nonSubscription &&
              p.subscriptionPeriod == null,
        )
        .firstOrNull;
    return _product == null ? null : PlusOffer(_product!.priceString);
  }

  @override
  Future<bool> purchase() async {
    _requireReady();
    final product = _product;
    if (product == null) throw PlusStoreError.unavailable;
    try {
      final result = await Purchases.purchase(
        PurchaseParams.storeProduct(product),
      );
      return hasPlus(result.customerInfo);
    } on PlatformException catch (error) {
      switch (PurchasesErrorHelper.getErrorCode(error)) {
        case PurchasesErrorCode.purchaseCancelledError:
          throw PlusStoreError.cancelled;
        case PurchasesErrorCode.paymentPendingError:
          throw PlusStoreError.pending;
        default:
          throw PlusStoreError.failed;
      }
    }
  }

  @override
  Future<bool> restore() async {
    _requireReady();
    return hasPlus(await Purchases.restorePurchases());
  }

  @override
  void dispose() {
    _disposed = true;
    if (_ready) Purchases.removeCustomerInfoUpdateListener(_updated);
    _changes.close();
  }
}
