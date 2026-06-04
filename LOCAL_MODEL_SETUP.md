# Haze's on-device brain (local, no server)

Haze now thinks **entirely on the phone** using [`flutter_gemma`](https://pub.dev/packages/flutter_gemma).
There is no backend and no API key at runtime — a small Gemma model is downloaded
once on first use and then runs fully offline. If the model can't be downloaded or
the device can't run it, Haze falls back to built-in canned lines (so it never breaks).

## How it works

- **Model:** Gemma 3 1B (`gemma3-1b-it-int4.task`, ~0.5 GB), text-only.
- **Contract:** the model replies with one line of JSON — `{"emotion": "...", "say": "..."}` —
  where `emotion` is one of Haze's 8 existing faces. The cubit drives the face and
  speaks the line through the existing TTS. See `lib/services/haze_brain.dart`.
- **Lifecycle:** first AI action downloads + loads the model (progress shown in the
  Talk dialog), then it's cached for next launches.

## Getting the model onto the device (first run)

Config is read from a runtime **`.env`** file (loaded by `flutter_dotenv`). Gemma is
license-gated on Hugging Face, so the first-run download needs a **free** token:

1. Accept the Gemma license once at <https://huggingface.co/litert-community/Gemma3-1B-IT>.
2. Create a read token at <https://huggingface.co/settings/tokens>.
3. Put it in `.env` (gitignored):

   ```
   HUGGINGFACE_TOKEN=hf_xxxxxxxxxxxxxxxxx
   ```

4. Run normally:

   ```bash
   flutter run
   ```

### Alternative: self-host the model (no token)

Host the `.task` file anywhere static (your own bucket / a GitHub release) and point
Haze at it via `.env` — no Hugging Face token needed:

```
HAZE_MODEL_URL=https://example.com/gemma3-1b-it-int4.task
```

Both keys are read in `lib/services/haze_brain.dart` (`HAZE_MODEL_URL`, `HUGGINGFACE_TOKEN`).

## Platform notes

- **Android:** `INTERNET` permission + optional OpenCL libs are already declared in
  `AndroidManifest.xml`.
- **iOS:** Podfile is pinned to iOS 16 with static linking. Run `pod install` in `ios/`
  after `flutter pub get`.

## Tuning

- Swap the model by changing the default URL (e.g. `gemma3-1b-it-int8.task` for a bit
  more quality, or a Gemma 3 270M build for ultra-low-end devices).
- Personality lives in `_systemInstruction` in `haze_brain.dart`; sampling
  (`temperature`, `topK`, `topP`) is set in `createChat(...)`.
