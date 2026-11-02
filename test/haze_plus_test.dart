import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:haze_bot_app/models/haze_look.dart';
import 'package:haze_bot_app/services/haze_plus_controller.dart';
import 'package:haze_bot_app/services/haze_plus_store.dart';
import 'support/fake_plus_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakePlusStore store;
  late HazePlusController plus;
  const premium = HazeLook(
    style: HazeFaceStyle.aurora,
    accessory: HazeAccessory.crown,
  );
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'haze_robot_config': '{"eyeColor":123,"speechEnabled":true}',
    });
    store = FakePlusStore();
    plus = HazePlusController(store: store);
  });
  tearDown(() => plus.dispose());

  test(
    'old settings stay free and a saved cosmetic is not proof of purchase',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        HazePlusController.lookKey,
        jsonEncode(premium.toJson()),
      );
      await plus.initialize();
      expect(plus.look, const HazeLook());
      expect(await plus.apply(premium), isFalse);
      expect(await plus.apply(const HazeLook()), isTrue);
      expect(
        prefs.getString('haze_robot_config'),
        '{"eyeColor":123,"speechEnabled":true}',
      );
      expect(store.purchases, 0);
    },
  );

  test(
    'verified purchase unlocks and persists a look across sessions',
    () async {
      await plus.initialize();
      expect(plus.offer!.localizedPrice, 'R\$ 19,90');
      await plus.purchase();
      expect(plus.ownsPlus, isTrue);
      expect(await plus.apply(premium), isTrue);
      final second = HazePlusController(store: FakePlusStore()..owned = true);
      await second.initialize();
      expect(second.look, premium);
      second.dispose();
    },
  );

  test('double taps produce only one store purchase', () async {
    await plus.initialize();
    store.purchaseCompleter = Completer<bool>();
    final first = plus.purchase();
    await plus.purchase();
    expect(store.purchases, 1);
    expect(plus.ownsPlus, isFalse);
    store.purchaseCompleter!.complete(true);
    await first;
    expect(plus.ownsPlus, isTrue);
  });

  test('cancellation and failure never unlock', () async {
    await plus.initialize();
    store.purchaseError = PlusStoreError.cancelled;
    await plus.purchase();
    expect(plus.message, isNull);
    expect(plus.ownsPlus, isFalse);
    store.purchaseError = PlusStoreError.failed;
    await plus.purchase();
    expect(plus.message, PlusMessage.failed);
    expect(await plus.apply(premium), isFalse);
  });

  test(
    'pending waits for entitlement and cannot initiate a second checkout',
    () async {
      await plus.initialize();
      store.purchaseError = PlusStoreError.pending;
      await plus.purchase();
      expect(plus.ownsPlus, isFalse);
      expect(plus.canPurchase, isFalse);
      expect(plus.message, PlusMessage.pending);
      store.setOwned(true);
      expect(plus.ownsPlus, isTrue);
      expect(plus.message, PlusMessage.unlocked);
    },
  );

  test('unavailable store still allows original free look', () async {
    store.unavailable = true;
    await plus.initialize();
    expect(plus.canPurchase, isFalse);
    expect(await plus.apply(const HazeLook()), isTrue);
    store.unavailable = false;
    await plus.refresh();
    expect(plus.canPurchase, isTrue);
  });

  test(
    'restore can recover, revoke, and retain verified access on network failure',
    () async {
      await plus.initialize();
      await plus.restore();
      expect(plus.message, PlusMessage.nothingToRestore);
      store.owned = true;
      await plus.restore();
      expect(plus.message, PlusMessage.restored);
      await plus.apply(premium);
      store.restoreError = StateError('offline');
      await plus.restore();
      expect(plus.look, premium);
      store.setOwned(false);
      expect(plus.look, const HazeLook());
      store.setOwned(true);
      expect(plus.look, premium);
    },
  );

  test(
    'missing product keeps restore available, malformed preferences recover',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(HazePlusController.lookKey, 'broken');
      store.offer = null;
      store.owned = true;
      await plus.initialize();
      expect(plus.look, const HazeLook());
      expect(plus.canRestore, isTrue);
      expect(plus.canPurchase, isFalse);
    },
  );

  test('only the exact active permanent entitlement grants Plus', () {
    CustomerInfo customer({
      bool active = true,
      String product = RevenueCatPlusStore.productId,
      String? expiration,
      VerificationResult verification = VerificationResult.verified,
    }) {
      final entitlement = EntitlementInfo(
        RevenueCatPlusStore.entitlementId,
        active,
        false,
        '2026-10-31',
        '2026-10-31',
        product,
        false,
        expirationDate: expiration,
      );
      return CustomerInfo(
        EntitlementInfos(
          {RevenueCatPlusStore.entitlementId: entitlement},
          active ? {RevenueCatPlusStore.entitlementId: entitlement} : {},
          verification: verification,
        ),
        {},
        [],
        [],
        [],
        '2026-10-31',
        'test',
        {},
        '2026-10-31',
      );
    }

    expect(RevenueCatPlusStore.hasPlus(customer()), isTrue);
    expect(RevenueCatPlusStore.hasPlus(customer(active: false)), isFalse);
    expect(RevenueCatPlusStore.hasPlus(customer(product: 'monthly')), isFalse);
    expect(
      RevenueCatPlusStore.hasPlus(customer(expiration: '2027-01-01')),
      isFalse,
    );
    expect(
      RevenueCatPlusStore.hasPlus(
        customer(verification: VerificationResult.failed),
      ),
      isFalse,
    );
  });
}
