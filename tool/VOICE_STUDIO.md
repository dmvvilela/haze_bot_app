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
