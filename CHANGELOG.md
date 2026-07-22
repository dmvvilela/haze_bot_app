# Changelog

All notable changes to Haze Bot are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-07-22

### Added
- Haze character voices — pick how Haze sounds, grouped by voice type in settings
- Portuguese voice clips for every Haze persona, selected by app language
- Shake detection: shaking the device sends Haze dizzy (eyes spin, then a confused blink)
- Idle sleep: after 45 seconds without interaction Haze yawns and drifts off
- Chat composer for typing to Haze directly

### Changed
- AI replies are now spoken even when general speech is turned off
- Chat input stays visible instead of hiding after each message

### Fixed
- More reliable TTS capture and SoLoud audio error handling
- iOS audio playback via a dedicated AudioTools plugin and scene delegate
- Android Gradle and release signing configuration
- Portuguese Play Store release notes were previously published in English

## [2.0.0] - 2026-07-02

### Added
- Haze V3 face with smoother, more expressive animations
- Optional on-device AI chat powered by Gemma (no cloud required)
- Personality modes that change how Haze responds
- Focus and meditation timers with robot encouragement
- Feelings Game to practice recognizing emotions
- Sound effects library
- Installed TTS voice picker
- New sad and scared expressions
- Persistent settings across sessions

### Changed
- Major UI refresh across face styles and settings
- Updated store metadata and release automation

## [1.0.0] - 2025-06-15

### Added
- 8 unique expressions with tap-to-cycle interaction
- 4 face styles: Classic, LOOI-inspired, Minimal, and Bean Face
- Full color customization for eyes and mouth
- Text-to-speech with customizable voice settings
- English and Portuguese localization
- Dark and light theme support
- Automatic blinking for lifelike behavior
