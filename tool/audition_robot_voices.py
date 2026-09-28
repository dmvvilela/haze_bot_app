#!/usr/bin/env python3
"""Offline sound sketches; does not modify the app or bundled voice assets.

Uses speech-band envelopes to drive synthetic carriers, then matches loudness.
Requires the existing voice-studio Python environment and ffmpeg.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import tempfile
from pathlib import Path

import numpy as np
import soundfile as sf
from scipy import signal
from scipy.ndimage import median_filter

ROOT = Path(__file__).resolve().parent.parent


def bandpass(audio, low, high, sample_rate):
    sos = signal.butter(3, [low, high], btype="bandpass", fs=sample_rate, output="sos")
    return signal.sosfiltfilt(sos, audio)


def pitch_contour(audio, sample_rate):
    """A restrained pitch contour, with stable pitch through unvoiced frames."""
    filtered = bandpass(audio, 65, 1100, sample_rate)
    window = int(sample_rate * 0.05)
    hop = int(sample_rate * 0.01)
    padded = np.pad(filtered, (window // 2, window))
    positions, pitches = [], []
    previous = 165.0
    for start in range(0, len(audio), hop):
        frame = padded[start : start + window] * np.hanning(window)
        ac = signal.correlate(frame, frame, mode="full", method="fft")[window - 1 :]
        low, high = int(sample_rate / 350), int(sample_rate / 70)
        peaks, _ = signal.find_peaks(ac[low:high])
        if peaks.size and ac[0] > 1e-7:
            lag = low + peaks[np.argmax(ac[low + peaks])]
            if ac[lag] / ac[0] > 0.35:
                previous = sample_rate / lag
        positions.append(start)
        pitches.append(previous)
    pitches = median_filter(np.array(pitches), size=9)
    # Keep a stable identity, with only a little of the speaker's intonation.
    pitches = 165 * (pitches / np.median(pitches)) ** 0.22
    return np.interp(np.arange(len(audio)), positions, np.clip(pitches, 145, 190))


def carrier(pitch, sample_rate, harmonics=60):
    phase = np.cumsum(np.asarray(pitch)) / sample_rate
    result = np.zeros_like(phase)
    for harmonic in range(1, harmonics + 1):
        if harmonic * np.max(pitch) >= sample_rate * 0.47:
            break
        result += np.sin(2 * np.pi * harmonic * phase) / harmonic
    return result / np.sqrt(np.mean(result**2))


def vocode(audio, excitation, sample_rate, bands, low, high):
    """Analysis/synthesis filterbank with a separate consonant noise carrier."""
    edges = np.geomspace(low, high, bands + 1)
    smoother = signal.butter(2, 35, fs=sample_rate, output="sos")
    noise = np.random.default_rng(20260927).standard_normal(len(audio))
    result = np.zeros_like(audio)
    for lower, upper in zip(edges[:-1], edges[1:]):
        speech = bandpass(audio, lower, upper, sample_rate)
        envelope = np.sqrt(np.maximum(signal.sosfiltfilt(smoother, speech**2), 0))
        tone = bandpass(excitation, lower, upper, sample_rate)
        hiss = bandpass(noise, lower, upper, sample_rate)
        tone /= max(np.sqrt(np.mean(tone**2)), 1e-8)
        hiss /= max(np.sqrt(np.mean(hiss**2)), 1e-8)
        # Preserve unvoiced consonants instead of making every sound a vowel.
        noise_mix = np.clip((np.sqrt(lower * upper) - 2200) / 4000, 0.02, 0.9)
        shaped = np.sqrt(1 - noise_mix) * tone + np.sqrt(noise_mix) * hiss
        result += envelope * shaped
    return result


def match_loudness(audio, sample_rate, output):
    audio = np.asarray(audio, dtype=np.float64)
    assert np.isfinite(audio).all()
    audio -= np.mean(audio)
    # Short fades eliminate file-boundary clicks without changing word timing.
    fade = min(int(sample_rate * 0.015), len(audio) // 2)
    audio[:fade] *= np.linspace(0, 1, fade)
    audio[-fade:] *= np.linspace(1, 0, fade)
    audio *= 0.85 / max(np.max(np.abs(audio)), 1e-8)
    with tempfile.TemporaryDirectory(prefix="haze-audition-") as temporary:
        raw = Path(temporary) / "raw.wav"
        sf.write(raw, audio, sample_rate, subtype="FLOAT")
        common = ["ffmpeg", "-hide_banner", "-nostats", "-y", "-i", str(raw)]
        first = subprocess.run(
            common + ["-af", "loudnorm=I=-19:TP=-2:LRA=7:print_format=json", "-f", "null", "-"],
            capture_output=True, text=True, check=True,
        )
        measured, _ = json.JSONDecoder().raw_decode(first.stderr[first.stderr.rfind("{") :])
        settings = ":".join([
            "loudnorm=I=-19:TP=-2:LRA=7",
            f"measured_I={measured['input_i']}",
            f"measured_TP={measured['input_tp']}",
            f"measured_LRA={measured['input_lra']}",
            f"measured_thresh={measured['input_thresh']}",
            f"offset={measured['target_offset']}",
            "linear=true",
        ])
        subprocess.run(common + ["-af", settings, "-ar", str(sample_rate), "-ac", "1", "-c:a", "pcm_s16le", str(output)], capture_output=True, check=True)
        # Match the rendered files, including any peak-limiter gain reduction.
        check = subprocess.run(
            ["ffmpeg", "-hide_banner", "-nostats", "-i", str(output), "-af",
             "loudnorm=I=-21:TP=-2:LRA=7:print_format=json", "-f", "null", "-"],
            capture_output=True, text=True, check=True,
        )
        actual, _ = json.JSONDecoder().raw_decode(check.stderr[check.stderr.rfind("{") :])
        decoded, _ = sf.read(output)
        decoded *= 10 ** ((-21 - float(actual["input_i"])) / 20)
        assert np.max(np.abs(decoded)) < 0.85, "Loudness correction exceeds headroom"
        sf.write(output, decoded, sample_rate, subtype="PCM_16")
    return measured


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=ROOT / "assets/voices/haze/compact_wit/hello.wav")
    parser.add_argument("--output", type=Path, default=ROOT / "tool/voice_output/robot_auditions")
    args = parser.parse_args()
    speech, sample_rate = sf.read(args.source)
    if speech.ndim == 2:
        speech = speech.mean(axis=1)
    original = speech.copy()
    speech = bandpass(speech, 75, min(9500, sample_rate * 0.45), sample_rate)
    high = min(8000, sample_rate * 0.43)
    pitch = pitch_contour(speech, sample_rate)
    soft = vocode(speech, carrier(pitch, sample_rate), sample_rate, 32, 90, high)
    musical_carrier = carrier(np.full(len(speech), 196.0), sample_rate)
    musical_carrier += 0.55 * carrier(np.full(len(speech), 293.665), sample_rate)
    musical = vocode(speech, musical_carrier, sample_rate, 24, 90, high)
    retro = vocode(speech, carrier(np.full(len(speech), 110.0), sample_rate), sample_rate, 16, 160, 6200)
    soft *= np.sqrt(np.mean(speech**2) / np.mean(soft**2))
    samples = {
        "00_original": original,
        "01_soft_scifi": 0.78 * soft + 0.22 * speech,
        "02_musical_vocoder": musical,
        "03_retro_robot": retro,
    }
    args.output.mkdir(parents=True, exist_ok=True)
    report = {"source": str(args.source.relative_to(ROOT)) if args.source.is_relative_to(ROOT) else str(args.source), "sample_rate": sample_rate, "duration_seconds": len(speech) / sample_rate, "target_lufs": -21, "samples": {}}
    for name, audio in samples.items():
        output = args.output / f"{name}.wav"
        match_loudness(audio, sample_rate, output)
        decoded, _ = sf.read(output)
        assert len(decoded) == len(speech), "Duration changed"
        assert np.isfinite(decoded).all() and np.max(np.abs(decoded)) < 0.999
        report["samples"][name] = {"peak_dbfs": round(20 * np.log10(np.max(np.abs(decoded))), 2), "bytes": output.stat().st_size}
        print(output)
    (args.output / "manifest.json").write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
