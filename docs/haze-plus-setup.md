# Haze Plus: implementation and store setup

Haze Plus is a **single non-consumable purchase** for three new face styles
(Orbit, Pixel, Aurora) and four accessories (Glasses, Crown, Headphones, Comet).
Classic, custom colors, themes, all expressions, all voices, conversations,
games, and labs remain free. The new cosmetics compose with the existing face
rig. Preview does not change the saved look. Ownership is obtained from
RevenueCat's verified customer information; SharedPreferences stores only the
selected cosmetic IDs.

## Billing identities

| Item | Value |
|---|---|
| RevenueCat project | Haze, `d9d7200f` |
| Entitlement | `haze_plus` |
| Both store product IDs | `haze_plus_lifetime` |
| Google package | `com.d2vsolutions.haze_bot_app` |
| Apple bundle | `com.d2vsolutions.hazeBotApp` |
| RevenueCat Android app | `app705571950e` |
| RevenueCat Android product | `prode01740888c` |
| RevenueCat Apple app | `app3a826d146e` |
| RevenueCat Apple product | `prod2b5795dd49` |

The RevenueCat project, entitlement, Android app identity, and non-consumable
product mapping were created on October 31, 2026. These records alone do not
create or activate an Apple/Google store product and cannot process payments.

After explicit user approval, the Google Play service-account file from this
app's release setup was uploaded and saved in RevenueCat. A full page reload
confirmed **File saved** and **Valid credentials**. That credential-upload step
did not change Google Cloud or Play permissions. On November 1, real-time
developer notifications were connected through a
dedicated Haze Pub/Sub topic, and Google Play test delivery was confirmed
in RevenueCat. See the notification verification section below.

On November 1, 2026, the user explicitly approved reusing shared Apple in-app
purchase key `8K2ZK6K749`. Haze's Apple app was created with the correct bundle
ID and RevenueCat reports **Valid credentials**. The Apple lifetime product
mapping was created as non-consumable and attached to `haze_plus`; a page
reload confirmed the entitlement association. The optional App Store Connect
catalog-management API key is not configured, so RevenueCat cannot import
or check Apple catalog products yet.

Both platform public SDK keys are stored in `release/haze-plus-public.json`
and passed to iOS/Android builds by `release/release.sh`. No private store
credentials are included in that file.

On November 1, the user approved unpublished store drafts at US$4.99 and
R$19.90. Apple IAP `6829523101` was created as `NON_CONSUMABLE` with English
and Portuguese localizations. The effective manual prices were read back as
USD 4.99 (USA) and BRL 19.90 (BRA). Its initial state was `MISSING_METADATA`. On November 1, availability and a
native iOS review screenshot were completed, and the product was submitted
together with iOS 2.3.0 / build 7. Both are now `WAITING_FOR_REVIEW`.

Google rejected product creation with: `Can't create product. To fix,
request billing permission.` Its current production build is version code 6.
A signed API-36 bundle, version 2.3.0 / code 7, was built with the billing
permission and the real public SDK keys. The first build encountered stale
integration-test registration; regenerating plugin metadata by building with
pub enabled resolved it. The final AAB signature and embedded billing
permission were verified.

After explicit user approval, build 7 was uploaded and committed as an
**unpublished internal-track draft** on November 1. A fresh API edit verified
its SHA-256 against the local artifact, internal draft 7 alongside completed
release 1, production completed 6, beta completed 5, and empty alpha. All
pre-existing releases were unchanged. No rollout or review submission occurred.

Play Console visibly confirms target SDK 36, 16 KB page-size support, and
`com.android.vending.BILLING` in the processed build 7 permissions. Google
product creation failed twice while build 7 remained a draft.

The user then explicitly approved releasing build 7 to the existing internal
testers. On November 1, the internal release was committed as `completed`.
A fresh API readback confirmed internal build 7, unchanged production build 6,
unchanged beta build 5 and alpha, and unchanged tester configuration. Play
Console also displayed **Available to internal testers** for 2.3.0. The old
internal build 1 was superseded. Production was not promoted or submitted.

After internal distribution, Google accepted product creation (HTTP 200).
The returned product `haze_plus_lifetime` has purchase option `lifetime`,
state `DRAFT`, English and Portuguese localizations, and verified prices
USD 4.99 (US) / BRL 19.90 (BR). Its buy option is legacy-compatible and does
not enable multi-quantity purchases. The billing-eligibility blocker is
resolved. After explicit user approval, the purchase option was activated on November 1.
API readback and Play Console both confirm `ACTIVE`, with prices and
localizations unchanged. Activation evidence is
`release/products/haze-plus-google-active.json`.

On November 1, Android purchase and restore passed on a physical Motorola
Edge 40 Neo using Google Play-installed version 2.3.0 / build 7. Checkout
showed R$19.90, an always-approved test card, and an explicit no-charge notice.
Haze displayed **Haze Plus unlocked**, retained ownership after a cold restart,
and displayed **Your Haze Plus purchase has been restored** after explicit
Restore Purchases. Pixel and Crown were applied and verified on the main screen.
Google's API independently confirmed a processed test order, purchased,
acknowledged, and not consumed. Evidence is
`release/products/haze-plus-android-purchase-proof.json`; screenshots are in
`build/haze-plus-proof/`. A subsequent user-authorized clean-install test
also passed: uninstall without preserving data, reinstall from Google Play,
then clear Haze app data before first launch to exclude backup restoration.
Build 7 recovered Plus automatically and explicit Restore Purchases returned
success. Screenshot: `build/haze-plus-proof/android-plus-clean-install-restored.png`.
This tested fresh data on the same physical phone and store account.

During setup, the existing two-member Internal Testers email list was enabled
for developer-account license testing, adding the owner's secondary account
(the primary account was already a license tester). The secondary account
accepted its existing Haze internal-test invitation. Installation and checkout
ultimately used the original primary Play account, which remains selected.
Haze app data was preserved during initial purchase testing; only Google Play
Store cache was cleared then. The later clean-install test explicitly erased
Haze app data at the user's request.
Installation link: https://play.google.com/apps/internaltest/4700845887214000676 .
Internal release evidence and historical product readback are saved in
`release/products/haze-plus-internal-release-evidence.json` and
`release/products/haze-plus-google-verified.json`.

The internal review reported 1,840 fewer supported devices compared with old
internal build 1 (API 21 minimum versus build 7 API 24 minimum). That comparison
is against internal build 1, not current production build 6.

Product details and readback evidence are in `release/products/haze-plus.json`
and `release/products/haze-plus-store-state.json`. The prepared Google payload
is `release/products/haze-plus-google-draft.json`.

## Remaining store setup

1. Google validation credentials are saved and valid. Real-time notifications
   are connected and test delivery passed. Access is scoped to Haze resources.
2. Apple purchase-validation credentials are saved and valid. Production and
   sandbox server notification URLs are configured; both delivery tests passed.
   The separate catalog-management API connection remains optional. No
   forwarding or new-purchase tracking settings were changed.
3. Apple Haze Plus and iOS 2.3.0 / build 7 are submitted together and
   `WAITING_FOR_REVIEW`, with approved US$4.99 / R$19.90 prices. Google's purchase option is now ACTIVE
   at the approved prices. Android license-test purchase, cold restart, explicit
   restore, and paid cosmetic application passed on November 1.
4. Both RevenueCat mappings are attached to `haze_plus`. Do not attach a
   subscription, consumable, or expiring promotional entitlement. The app
   deliberately requires the exact product ID and a non-expiring entitlement.
5. Build with platform-specific **public SDK keys**, never a secret REST API
   key or service-account JSON. For example:
   `flutter build appbundle --dart-define-from-file=release/haze-plus-public.json`
   and
   `flutter build ipa --dart-define-from-file=release/haze-plus-public.json`.
   Builds without a key support all free features and cosmetic previews but
   cannot sell or restore Plus. Test Store keys are rejected in release mode.
6. Remaining native Android tests: cancellation, pending approval, and
   refund/revocation. Android purchase, cold restart, explicit restore, and
   clean-install restore on the same store account passed.
   iOS sandbox purchase, explicit restore, paid cosmetics, and cold restart
   passed on a physical iPhone 16 Pro Max. Clean-install restore also passed
   using TestFlight 2.3.0 (7). Cancellation, pending approval, and
   refund/revocation remain untested.
7. The bilingual privacy policy is live at
   https://danvilela.com/haze/privacy-policy (website commit `88018fa`).
   Apple English and Portuguese privacy URLs were updated and submitted.
   Google has submitted the same URL after the user explicitly approved
   restarting the Android review. The production release, privacy URL, and
   Data Safety declaration are included together. The previous
   GitHub Pages URL remains available. Google Data Safety now declares
   purchase history collected, not ephemeral, required, encrypted in transit,
   for functionality and analytics, following RevenueCat guidance. No
   advertising IDs, custom identifying user attributes, or cross-app
   advertising integrations are configured here. The declaration was submitted
   with the production release.
8. After explicit user authorization on November 1, build 7 was promoted
   from internal to production with a full rollout and bilingual release notes.
   A fresh API readback confirms production code 7, status `completed`, and
   other tracks unchanged. Play Console shows the production release and Data
   Safety changes submitted and in review. Managed
   publishing is off, so publication is automatic after approval. This is not
   confirmation of public availability; the last confirmed public build was 6.
   See `release/products/haze-plus-production-release-evidence.json`. Google
   lifetime purchase remains ACTIVE. Apple is waiting for review; see
   `release/products/haze-plus-ios-release-evidence.json`.

## iOS submission and verification

On November 1 at 21:22 BRT, App Store Connect accepted a single submission
containing iOS 2.3.0 (7) and Haze Plus — Lifetime. Submission ID:
`80c892b0-1a52-4218-9bba-3fa116e6c4e6`. UI and API both confirm
`WAITING_FOR_REVIEW`. Release is automatic after approval, with full rollout.
This is not confirmation of public availability.

The signed production IPA passed signature validation. The native iOS app
loaded the real $4.99 store price and displayed Restore Purchases. The Apple
purchase-history privacy declaration was published, and the native
purchase-controls screenshot completed upload.

On November 1 at 22:56 BRT, a physical iPhone 16 Pro Max completed an Apple
sandbox purchase at R$19.90 using Haze 2.3.0 (7). Apple
confirmed success, and RevenueCat recorded `NON_RENEWING_PURCHASE` in
`SANDBOX` for `haze_plus_lifetime`, granting active `haze_plus` with unlimited
duration. The app applied Orbit and Headphones. Explicit Restore Purchases
showed "Your Haze Plus purchase has been restored." A full process restart
preserved ownership and the selected cosmetics. The original installation
source was not independently verified; `builtByDeveloper` alone cannot
distinguish it, because the later verified TestFlight installation reports
that flag too. Sanitized evidence is in
`release/products/haze-plus-ios-purchase-proof.json`.

## iOS clean-install restore verification

On November 1 at 23:28 BRT, clean-install restore passed on the physical
iPhone 16 Pro Max using TestFlight 2.3.0 (7). Haze was fully uninstalled,
then installed from the existing internal TestFlight group. The fresh app
had default cosmetics and Plus locked. Tapping Restore Purchases displayed
"Your Haze Plus purchase has been restored," unlocked all Plus cosmetics,
and allowed Orbit with Headphones to be applied to the main face.
RevenueCat showed the original unlimited-duration entitlement and a new
anonymous customer ID aliased to the original purchaser. No repeat purchase
was made.

The first attempt used a locally signed development build and returned no
purchase. The user confirmed the original purchase used their regular Apple
account. The subsequent clean TestFlight installation recovered it. The
exact cause of the development-build result was not conclusively diagnosed;
it is retained in the evidence rather than counted as a passing attempt.

## Store notification verification

On November 1, both stores were connected to RevenueCat. Apple production
and sandbox test notifications returned `SUCCESS` from Apple's test-status
API. Google Play has notifications enabled for subscriptions, voided
purchases, and all one-time products. RevenueCat confirmed receipt of the
Play Console test notification at 2026-11-02 01:37 UTC (November 1, 22:37 BRT).

Google uses dedicated topic `Haze-Play-Store-Notifications` and subscription
`RevenueCat-Subscriber-app705571950e` in `d-fit-dev`. The existing billing
service account has Pub/Sub Editor directly on these two resources. A custom
project role permits topic-name listing and subscription creation; it does
not grant access to other apps' messages. Google Play has Publisher only on
Haze's topic. The initial conditional binding did not permit subscription
attachment, so it was replaced with the approved direct resource bindings.

Full sanitized evidence is in
`release/products/haze-plus-notifications-evidence.json`. Notification URL
tokens and private keys are intentionally omitted. New-purchase tracking
from notifications remains off because Haze reports purchases through the
SDK; existing purchase and refund notifications remain enabled.

## Runtime behavior

- Price comes from the store's localized product; there is no hardcoded live
  price, fake discount, subscription, or automatic purchase.
- Restore is explicit. Empty restore removes access; errors retain the last
  verified state. Ownership updates and foreground refresh handle changed
  access, and never erase the user's saved cosmetic choice.
- New installs use RevenueCat's anonymous identity. Restore works through the
  same store account. No Haze login or cross-store transfer is promised.
- Pending and canceled purchases do not unlock. Rapid taps cannot open a
  second checkout. Saved preferences are not an entitlement.
- Unavailable products leave preview and Classic usable.
- `tool/plus_preview.dart` is a separate developer entry point with a clearly
  marked entitlement simulator and **no checkout**. It is not shipped by
  `lib/main.dart`.

## SDK compatibility

Pinned to purchases_flutter 10.18.1 (PurchasesHybridCommon 19.15.0).
RevenueCat's 11.0.0 changelog states its CocoaPods dependency is not yet
published. Haze currently requires CocoaPods for audio/Gemma; do not switch
the project to SPM just to resolve billing.
https://pub.dev/packages/purchases_flutter/changelog

## Local verification

`flutter test --no-pub`, `flutter analyze --no-pub`.

October 31 verification: 132 tests passed; analyzer clean; Android debug APK
and iOS simulator builds passed with SDK 10.18.1. Haze launched and initialized
on the iPhone simulator. The actual Plus screen was exercised in the browser
preview, including Portuguese, style/accessory selection, and applying a
simulated owned look. Android real license-test purchase and restore passed
on November 1 as documented above. Physical iOS sandbox purchase, explicit
restore, and cold restart also passed on November 1.

`flutter run -d web-server -t tool/plus_preview.dart --web-port 8745`
opens the real Plus screen with a developer-only store adapter.

Official references:
- https://www.revenuecat.com/docs/getting-started/entitlements
- https://www.revenuecat.com/docs/getting-started/restoring-purchases
- https://www.revenuecat.com/docs/platform-resources/apple-platform-resources/apple-app-privacy
