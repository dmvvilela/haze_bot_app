# Haze · Aurea store campaign

Five distinct feature stories, in English and Brazilian Portuguese:

1. An expressive pocket companion
2. Interactive Aurea experiments
3. The feelings game
4. Focus timer and desk company
5. Custom colors and light mode

## Deliverables

`exports/iphone/<locale>` contains five 1320 × 2868 PNGs per locale.
`exports/ipad/<locale>` contains five 2752 × 2064 PNGs per locale.
`exports/android/<locale>` contains five 1080 × 1920 PNGs per locale.
All 30 exports are opaque RGB. Filenames define store order.

`preview-<locale>-<device>.jpg` contact sheets show each complete set.
`source/metadata.json` contains proposed 2.2.0 store descriptions, subtitles,
keywords, promotional copy, and release notes. Old five-face-style claims have
been removed. No scientific or clinical effectiveness claims are made.

## Reproduce

From the project root, with Flutter installed and Python containing Pillow/numpy:

```sh
flutter test tool/capture_store.dart
python3 release/marketing/aurea/source/render.py
python3 release/marketing/aurea/source/verify.py
```

Captures render the production Flutter screens at each platform's viewport size,
with real localized copy, seeded game state, and a paused Aurea timeline. The
harness disables sounds, mocks local preferences/wakelock, and loads local fonts
instead of the test engine's square placeholder glyphs. The development-only
font fallback resolution changes no app text or features. It currently uses the
local macOS SF font and Flutter's Roboto font; marketing Inter fonts and their
license are included. Set `FLUTTER_ROOT` for a different SDK location.

Artwork uses original vector-style device frames, shadows, typography, and
gradients. Actual app captures are scaled proportionally and shown in full;
no generated app UI or invented conversations are used. iPad uses the real
tablet layout. Android uses its own capture and a generic punch-hole frame.

The dimension reference is Apple's [screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)
and Google's [preview asset guidance](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en-GB),
checked on 2026-09-27. `verification.json` checks dimensions, opacity, hashes,
ordering, framing, copy clearance, and metadata length limits.

## Release handoff

Prepared locally; **nothing has been uploaded or submitted**. Existing store
assets and old release metadata have not been replaced.

App Store Connect was checked on 2026-09-27: live iOS version **2.1.0**, latest
uploaded build **5**, processing VALID. Suggested next version: **2.2.0**, with
build 6 available on iOS at the time of that check. Google Play's current track
and version code still need a fresh check before choosing its build number.

The preceding app commit is `475a448`; its 104 tests, analyzer, iOS simulator build,
and Android debug build passed. The optional upgraded Gemma model still needs
a physical-device conversation smoke test before shipping. A debug/simulator
build does not validate release signing or physical-device inference.

Validation repeated on 2026-09-27: all 104 app tests passed, the capture test
rendered all 30 localized scenes successfully, static analysis found no issues,
and regenerated exports passed `source/verify.py`. A fresh simulator restart
and Lab navigation reported no runtime errors. A physical-device launch was
attempted, but Xcode could not obtain build settings and `devicectl` reported
the wireless iPhone as `unavailable`. Physical AI inference remains unverified;
retry with the phone unlocked and connected, preferably by USB.

Before submission: approve the artwork, finalize the version/build numbers,
apply the proposed metadata, build signed release artifacts, upload the new
screenshot sets explicitly, and verify the resulting store state. The existing
`release.sh` does not automatically select this campaign directory.
