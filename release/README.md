# Release

Automation for shipping Haze Bot to the App Store (iOS) and Google Play (Android).

## One-time setup

### App Store Connect (iOS)
```bash
# Create an API key at https://appstoreconnect.apple.com/access/integrations/api
# Save AuthKey_XXX.p8 OUTSIDE this repo (e.g. ~/.asc/keys/)
asc auth login \
  --name Haze Bot \
  --key-id <KEY_ID> \
  --issuer-id <ISSUER_ID> \
  --private-key ~/.asc/keys/AuthKey_XXX.p8
asc auth status --validate
```

### Google Play (Android)
1. Play Console → Setup → **API access** → create service account
2. Grant the service account the **Release Manager** role for the app
3. Download the JSON key → save to `release/fastlane/play-console-key.json`
4. Pull existing metadata: `cd release/fastlane && fastlane supply init`

### Env
```bash
cp .env.release.example .env.release
# Edit .env.release with ASC_APP_ID, ASC_PROFILE
```

## Shipping

```bash
# Production release, both stores:
./release/release.sh 1.0.1

# Beta (TestFlight + Play beta track):
./release/release.sh 1.1.0 --beta

# iOS only:
./release/release.sh 1.0.1 --ios-only

# Android only, no metadata sync:
./release/release.sh 1.0.1 --android-only --skip-metadata

# Upload without submitting for App Store review (just stage the build):
./release/release.sh 1.0.1 --no-submit
```

## Directory layout

```
release/
├── release.sh                    # main driver
├── metadata/
│   ├── ios/<locale>/             # App Store Connect metadata per locale
│   └── android/<locale>/         # Play Store metadata per locale (Fastlane format)
├── screenshots/
│   ├── ios/                      # iPhone & iPad screenshots per device class
│   └── android/                  # phone & tablet screenshots per density
├── fastlane/
│   ├── Appfile                   # package name, JSON key path
│   └── Fastfile                  # (optional) custom lanes
└── asc/                          # asc workspace (gitignored)
```

## Adding a locale

Duplicate the `en-US` folders under both `metadata/ios/` and `metadata/android/`, translate the `.txt` contents. Next release will sync them automatically.

## Troubleshooting

- `asc auth doctor` — diagnoses auth/keychain issues
- `asc review doctor --app $ASC_APP_ID` — shows review blockers
- `fastlane supply init` — re-pulls current Play Store metadata
- Dry-run a metadata sync before committing: `asc metadata apply --dir release/metadata/ios --dry-run`
