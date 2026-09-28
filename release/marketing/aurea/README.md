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
`source/metadata.json` contains the 2.2.0 store descriptions, subtitles,
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

## Release 2.2.0 · build 6

On 2026-09-28, all 30 screenshots were uploaded: 20 to App Store Connect
(iPhone and iPad) and 10 to Google Play (phone). The saved store assets were
checked against local checksums and ordering; all Apple assets reached COMPLETE.
Inherited iPad screenshots from the previous version were removed from the new
version. English and Portuguese store descriptions were also updated.

The app release commit is `97e7668`. All 112 app tests passed, all 30 captures
rendered, and the artwork validator passed. Signed iOS and Android release
artifacts were built and uploaded; artifact identities and hashes were checked.
All 22 Android 64-bit native libraries have at least 16 KB ELF load alignment.
The simulator voice smoke tests passed. Optional physical-device AI inference
remains unverified; the user requested simulator-only testing.

App Store review submission and Google Play production review preparation are
recorded in [the release record](../../releases/2.2.0.json). These are submission
states, not proof of public availability. iOS releases automatically after
approval with a seven-day phased rollout; Google Play managed publishing is off.

Rendering and local validation do not establish store state. The manifest and
verification report describe the local artwork; the versioned release record
contains the separate upload and submission evidence. `release.sh` does not
automatically select this campaign directory.
