# Haze voice studio

This Mac-only tool uses Qwen3-TTS VoiceDesign to generate candidate character
voices. Its Python environment, model cache, and audition WAV files are not
part of the Flutter application.

## Setup

```sh
./tool/setup_voice_studio.sh
```

The first generation downloads the public VoiceDesign model to the standard
Hugging Face cache in `~/.cache/huggingface`. The generator uses the active HF
CLI login when valid and falls back to anonymous access for this public model
when the configured credential has expired. Refresh a rejected login with
`hf auth login --force`.

## Generate auditions

Generate every configured voice and line:

```sh
.voice-studio/bin/python tool/generate_haze_voices.py
```

Generate a single combination while iterating:

```sh
.voice-studio/bin/python tool/generate_haze_voices.py \
  --variant pocket_gremlin \
  --line hello
```

Pass `--variant` more than once to audition several selected personas without
reloading the model between them.

For Brazilian Portuguese, generate native `pt-BR` references first. This is
important because Qwen exposes only a generic `Portuguese` language token; an
English reference may drift toward European Portuguese:

```sh
.voice-studio/bin/python tool/generate_haze_voices.py \
  --locale pt-BR --line hello
```

Edit `tool/haze_voice_design.json` to change personas and audition lines.
Generated files appear under `tool/voice_output/` and remain ignored by Git
until a final voice pack is deliberately copied into app assets.

## Compare robotic sound treatments

Use the existing voice-studio environment plus `ffmpeg` to render three
sound sketches from the same bundled recording:

```sh
.voice-studio/bin/python tool/audition_robot_voices.py
```

The output is in `tool/voice_output/robot_auditions/`: an unprocessed reference,
a soft sci-fi blend, a musical vocoder, and a retro robot. All four use the
same timing and a -21 LUFS loudness target. A manifest records the source,
duration, and output peaks. These are offline auditions, not a mobile runtime
implementation or an approved replacement for the app's voice.

To compare Brazilian Portuguese with the same processing:

```sh
.voice-studio/bin/python tool/audition_robot_voices.py \
  --source assets/voices/haze/compact_wit/pt/hello.wav \
  --output tool/voice_output/robot_auditions_pt
```

## Audition lighter character voices

For lighter character sketches generated from fresh macOS system speech:

```sh
.voice-studio/bin/python tool/audition_cute_voices.py \
  --text "Oh! There you are. I saved you a little spot next to me."
```

This writes two gently pitched, lightly synthetic variants to
`tool/voice_output/cute_auditions/`. It requires permission to use macOS speech
services. These auditions use arbitrary input text, but their processing still
serves as a sound reference rather than the mobile runtime itself.

The approved first sketch is implemented in `lib/services/tiny_companion_voice.dart`:
a 2.5-semitone pitch lift with duration-preserving overlap-add, plus a 12% synthetic
layer. `RobotVoiceService` runs it in a background isolate after TTS synthesis,
and computes the mouth envelope from the resulting audio. Tiny Companion mode
uses generated speech for both reactions and conversations. The portable DSP
uses different filters from the Python audition, so listen to the in-app preview
when judging the final sound; installed system voices can also vary by device.

## Freeze consistent voice packs

VoiceDesign may invent a slightly different speaker on every call. Once an
audition is approved, use it as a reference for Qwen's Base clone model:

```sh
.voice-studio/bin/python tool/freeze_haze_voice_packs.py
```

Generate the same frozen identities speaking Brazilian Portuguese:

```sh
.voice-studio/bin/python tool/freeze_haze_voice_packs.py --locale pt-BR
```

The Portuguese freeze uses the Brazilian reference generated in the previous
step, preserving both the character identity and Brazilian pronunciation.

While iterating, generate only selected content:

```sh
.voice-studio/bin/python tool/freeze_haze_voice_packs.py \
  --voice compact_wit --line happy
```
