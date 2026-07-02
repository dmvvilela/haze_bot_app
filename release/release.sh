#!/usr/bin/env bash
# Flutter release driver: iOS via asc, Android via Fastlane supply.
# Usage: ./release/release.sh <version> [--ios-only] [--android-only] [--internal | --beta] [--no-submit] [--skip-metadata]

set -euo pipefail

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
  cat <<USAGE
Usage: $0 <version> [flags]

  --ios-only        only build/upload iOS
  --android-only    only build/upload Android
  --internal        TestFlight (iOS) + Play internal testing track (Android)
                    Fastest, no review, up to 100 testers by email.
  --beta            TestFlight (iOS) + Play closed testing track (Android)
                    Larger invite list, Play reviews the build.
  --no-submit       upload only; do not submit for App Store review
  --skip-metadata   skip metadata sync (faster iteration)

Example: $0 1.0.1
         $0 1.2.0 --internal --ios-only
         $0 1.3.0 --android-only --internal    # then fastlane promote_to_production
USAGE
  exit 1
fi
shift || true

IOS_ONLY=false
ANDROID_ONLY=false
INTERNAL=false
BETA=false
SUBMIT=true
SYNC_METADATA=true

while [ $# -gt 0 ]; do
  case "$1" in
    --ios-only)      IOS_ONLY=true ;;
    --android-only)  ANDROID_ONLY=true ;;
    --internal)      INTERNAL=true; SUBMIT=false ;;
    --beta)          BETA=true; SUBMIT=false ;;
    --no-submit)     SUBMIT=false ;;
    --skip-metadata) SYNC_METADATA=false ;;
    *) echo "Unknown flag: $1" >&2; exit 1 ;;
  esac
  shift
done

if $INTERNAL && $BETA; then
  echo "✗ --internal and --beta are mutually exclusive" >&2
  exit 1
fi

# Load env ------------------------------------------------------------
if [ -f .env.release ]; then
  set -a; . ./.env.release; set +a
else
  echo "✗ .env.release not found — copy .env.release.example and fill it in." >&2
  exit 1
fi

: "${ASC_APP_ID:?ASC_APP_ID must be set in .env.release}"
: "${ASC_PROFILE:?ASC_PROFILE must be set in .env.release}"

# Helpers -------------------------------------------------------------
RED=$'\033[31m'; GRN=$'\033[32m'; YLW=$'\033[33m'; BLU=$'\033[36m'; END=$'\033[0m'
step()  { echo; echo "${BLU}==> $*${END}"; }
ok()    { echo "${GRN}✓ $*${END}"; }
warn()  { echo "${YLW}⚠ $*${END}"; }
fail()  { echo "${RED}✗ $*${END}" >&2; exit 1; }

banner() {
  echo "${BLU}"
  echo "┌─────────────────────────────────────────────┐"
  printf "│  Release v%-33s │\n" "$VERSION"
  if $INTERNAL; then
    echo "│  Track: INTERNAL (TestFlight + Play internal)│"
  elif $BETA; then
    echo "│  Track: BETA (TestFlight + Play closed)     │"
  else
    echo "│  Track: PRODUCTION                          │"
  fi
  $IOS_ONLY && echo "│  Scope: iOS only                            │" || true
  $ANDROID_ONLY && echo "│  Scope: Android only                        │" || true
  echo "└─────────────────────────────────────────────┘"
  echo "${END}"
}

# Pre-flight ----------------------------------------------------------
preflight() {
  step "Pre-flight"
  command -v asc >/dev/null     || fail "asc not installed (brew install asc)"
  command -v fastlane >/dev/null || fail "fastlane not installed (brew install fastlane)"
  command -v flutter >/dev/null  || fail "flutter not installed"

  if [ -n "$(git status --porcelain 2>/dev/null || true)" ]; then
    warn "Working tree is dirty"
    read -r -p "  Continue anyway? [y/N] " yn
    case "$yn" in y|Y) ;; *) exit 1 ;; esac
  fi
  ok "Pre-flight passed"
}

# Split a Flutter-style version "1.0.0+2" into name "1.0.0" + number "2".
# If no '+', BUILD_NUMBER stays empty and pubspec's value is used.
BUILD_NAME="${VERSION%%+*}"
if [ "${VERSION#*+}" != "$VERSION" ]; then
  BUILD_NUMBER="${VERSION#*+}"
else
  BUILD_NUMBER=""
fi

# Per-version metadata fallback: if release/metadata/ios/version/<NEW>/en-US.json
# doesn't exist, copy from the most recent version dir as a starting
# point. This unblocks the release; we still warn so the user knows to
# edit whatsNew (and any other version-specific fields) before shipping.
META_DIR="release/metadata/ios/version"
if [ -d "$META_DIR" ] && [ ! -d "$META_DIR/$BUILD_NAME" ]; then
  PREV=$(ls -1 "$META_DIR" 2>/dev/null | grep -E '^[0-9]+\.' | sort -V | tail -1 || true)
  if [ -n "$PREV" ]; then
    YLW=$'\033[33m'; END=$'\033[0m'
    echo "${YLW}⚠ No metadata for v$BUILD_NAME. Copying from v$PREV as a template.${END}"
    echo "${YLW}  Edit $META_DIR/$BUILD_NAME/en-US.json (whatsNew at minimum) before re-running.${END}"
    cp -R "$META_DIR/$PREV" "$META_DIR/$BUILD_NAME"
    echo "${YLW}  Created. Halting so you can review.${END}"
    exit 1
  fi
fi

# iOS -----------------------------------------------------------------
do_ios() {
  step "Flutter build iOS (.ipa) — v$BUILD_NAME${BUILD_NUMBER:+ ($BUILD_NUMBER)}"
  if [ -n "$BUILD_NUMBER" ]; then
    flutter build ipa --release --build-name "$BUILD_NAME" --build-number "$BUILD_NUMBER"
  else
    flutter build ipa --release --build-name "$BUILD_NAME"
  fi
  IPA=$(ls -t build/ios/ipa/*.ipa 2>/dev/null | head -n1 || true)
  [ -n "$IPA" ] || fail "No .ipa produced at build/ios/ipa/"
  ok "IPA: $IPA"

  if $BETA || $INTERNAL; then
    step "asc → upload IPA (TestFlight)"
    # `asc builds upload` uploads + waits for processing. The build then
    # appears in TestFlight automatically for any internal team member
    # (App Manager / Admin / Developer roles). To distribute to a named
    # group use `asc testflight groups add-build` after the upload, or
    # call `asc publish testflight --group <NAME>` directly.
    asc --profile "$ASC_PROFILE" builds upload \
      --app "$ASC_APP_ID" --ipa "$IPA" --wait
    # Belt-and-suspenders: declare export-compliance on the just-uploaded
    # build in case ITSAppUsesNonExemptEncryption isn't in Info.plist yet.
    # No-op if it is. Without this Apple holds builds in TestFlight limbo
    # showing "Missing Compliance" with no email warning.
    asc --profile "$ASC_PROFILE" builds update --app "$ASC_APP_ID" --latest \
      --uses-non-exempt-encryption=false >/dev/null 2>&1 || true
    ok "Internal testers can install via the TestFlight app."
  else
    # Order matters: `asc metadata apply` requires the App Store version
    # to already exist on Apple's side. So we publish first (creates the
    # version + uploads + attaches the build), then sync metadata, then
    # call publish again with --submit to send for review. The second
    # publish detects the existing build and skips re-upload.
    step "asc → App Store upload (v$BUILD_NAME)"
    asc --profile "$ASC_PROFILE" publish appstore \
      --app "$ASC_APP_ID" --ipa "$IPA" --version "$BUILD_NAME"
    asc --profile "$ASC_PROFILE" builds update --app "$ASC_APP_ID" --latest \
      --uses-non-exempt-encryption=false >/dev/null 2>&1 || true

    if $SYNC_METADATA && [ -d release/metadata/ios ]; then
      step "asc → sync iOS metadata"
      asc --profile "$ASC_PROFILE" metadata apply \
        --app "$ASC_APP_ID" --version "$BUILD_NAME" \
        --dir release/metadata/ios
    fi

    if $SUBMIT; then
      step "asc → submit for App Store review"
      # `asc publish appstore --submit` always tries to upload the IPA
      # first, which fails on this second call ("bundle version must be
      # higher than previously uploaded"). Use `asc review submit`
      # instead — it attaches an already-uploaded build and submits.
      asc --profile "$ASC_PROFILE" review submit \
        --app "$ASC_APP_ID" --version "$BUILD_NAME" --confirm
    fi
  fi
  ok "iOS done"
}

# Android -------------------------------------------------------------
do_android() {
  step "Flutter build Android (.aab) — v$BUILD_NAME${BUILD_NUMBER:+ ($BUILD_NUMBER)}"
  if [ -n "$BUILD_NUMBER" ]; then
    flutter build appbundle --release --build-name "$BUILD_NAME" --build-number "$BUILD_NUMBER"
  else
    flutter build appbundle --release --build-name "$BUILD_NAME"
  fi
  AAB=$(ls -t build/app/outputs/bundle/release/*.aab 2>/dev/null | head -n1 || true)
  [ -n "$AAB" ] || fail "No .aab produced at build/app/outputs/bundle/release/"
  ok "AAB: $AAB"

  # Play tracks: internal (fastest, no review) → beta (closed testing,
  # reviewed) → production. For a simple dev-loop, prefer --internal
  # to smoke-test on device, then `fastlane promote_to_production` to
  # push the same AAB to prod without a rebuild.
  local TRACK="production"
  $BETA && TRACK="beta"
  $INTERNAL && TRACK="internal"

  local META_FLAG=""
  $SYNC_METADATA && [ -d release/metadata/android ] && META_FLAG="--metadata_path=../metadata/android"
  $SYNC_METADATA || META_FLAG="--skip_upload_metadata"

  step "fastlane supply → Play Store ($TRACK)"
  (cd release/fastlane && fastlane supply \
    --aab "../../$AAB" \
    --track "$TRACK" \
    $META_FLAG \
    --skip_upload_screenshots \
    --skip_upload_images)
  ok "Android done"
}

# Main ----------------------------------------------------------------
banner
preflight
$ANDROID_ONLY || do_ios
$IOS_ONLY     || do_android

step "All uploads complete"
if $SUBMIT && ! $BETA && ! $INTERNAL && ! $ANDROID_ONLY; then
  echo
  echo "Watch App Store review status:"
  echo "  asc --profile $ASC_PROFILE status --app $ASC_APP_ID --watch"
fi

if $INTERNAL && ! $IOS_ONLY; then
  echo
  echo "To promote the Play internal build to production (no rebuild):"
  echo "  cd release/fastlane && fastlane promote_to_production"
fi
