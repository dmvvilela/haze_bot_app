#!/usr/bin/env python3
"""Generate fresh system TTS and audition two gentle character treatments.

Mac-only prototype: the mobile implementation is intentionally unchanged.
"""

import argparse
import json
import subprocess
import tempfile
from pathlib import Path

import numpy as np
import soundfile as sf

from audition_robot_voices import ROOT, bandpass, carrier, match_loudness, pitch_contour, vocode


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--text", default="Oh! There you are. I saved you a little spot next to me.")
    parser.add_argument("--voice", default="Samantha")
    parser.add_argument("--output", type=Path, default=ROOT / "tool/voice_output/cute_auditions")
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    sample_rate = 24000
    manifest = {"text": args.text, "source": "macOS system TTS generated for this audition", "voice": args.voice, "target_lufs": -21, "samples": {}}
    with tempfile.TemporaryDirectory(prefix="haze-cute-") as temporary:
        raw = Path(temporary) / "speech.aiff"
        subprocess.run(["/usr/bin/say", "-v", args.voice, "-r", "165", "-o", str(raw), args.text], check=True)
        for name, semitones, wet, fundamental in [
            ("01_tiny_companion", 2.5, 0.12, 235),
            ("02_little_droid", 4.0, 0.28, 270),
        ]:
            shifted = Path(temporary) / f"{name}.wav"
            _, source_rate = sf.read(raw)
            ratio = 2 ** (semitones / 12)
            filters = f"asetrate={round(source_rate * ratio)},aresample={sample_rate},atempo={1 / ratio}"
            subprocess.run([
                "ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", str(raw),
                "-af", filters, "-ac", "1", "-c:a", "pcm_f32le", str(shifted),
            ], check=True)
            speech, _ = sf.read(shifted)
            speech = bandpass(speech, 110, 7400, sample_rate)
            pitch = pitch_contour(speech, sample_rate) * (fundamental / 165)
            synthetic = vocode(speech, carrier(pitch, sample_rate), sample_rate, 32, 110, 7400)
            synthetic *= np.sqrt(np.mean(speech**2) / max(np.mean(synthetic**2), 1e-12))
            result = (1 - wet) * speech + wet * synthetic
            output = args.output / f"{name}.wav"
            match_loudness(result, sample_rate, output)
            decoded, rate = sf.read(output)
            assert np.isfinite(decoded).all() and np.max(np.abs(decoded)) < 0.999
            manifest["samples"][name] = {"semitones": semitones, "synthetic_mix": wet, "duration_seconds": len(decoded) / rate}
            print(output)
    (args.output / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")


if __name__ == "__main__":
    main()
