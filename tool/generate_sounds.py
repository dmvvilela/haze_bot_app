#!/usr/bin/env python3
"""Synthesizes Haze's chirp sound effects into assets/sounds/.

No external audio assets or licenses needed — every sound is a small
frequency-swept sine with a soft envelope, which is exactly the R2D2/Cozmo
family of robot voice. Tweak the recipes below and re-run:

    python3 tool/generate_sounds.py
"""

import math
import struct
import wave
from pathlib import Path

RATE = 44100
OUT_DIR = Path(__file__).resolve().parent.parent / "assets" / "sounds"


def tone(f0, f1, dur, amp=0.55, attack=0.012, release=0.5,
         vib_rate=0.0, vib_depth=0.0, harmonic=0.22):
    """One chirp: sine gliding f0->f1 with optional vibrato + 2nd harmonic."""
    n = int(dur * RATE)
    samples = []
    phase = 0.0
    for i in range(n):
        t = i / RATE
        p = i / max(1, n - 1)
        freq = f0 + (f1 - f0) * p
        if vib_depth:
            freq += vib_depth * math.sin(2 * math.pi * vib_rate * t)
        phase += 2 * math.pi * freq / RATE
        env = min(1.0, t / attack) if attack else 1.0
        rel_start = dur * (1 - release)
        if t > rel_start:
            env *= max(0.0, 1 - (t - rel_start) / (dur - rel_start))
        s = math.sin(phase) + harmonic * math.sin(2 * phase)
        samples.append(amp * env * s / (1 + harmonic))
    return samples


def silence(dur):
    return [0.0] * int(dur * RATE)


def write(name, samples):
    peak = max(1e-6, max(abs(s) for s in samples))
    scale = min(1.0, 0.89 / peak)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    path = OUT_DIR / name
    with wave.open(str(path), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(
            struct.pack("<h", int(s * scale * 32767)) for s in samples))
    print(f"wrote {path} ({len(samples) / RATE:.2f}s)")


# Quick happy blip when you poke the face.
write("poke.wav", tone(700, 1250, 0.09, amp=0.5, release=0.55))

# "Ding-ding!" — right answer in the feelings game.
write("correct.wav",
      tone(880, 900, 0.09, amp=0.5) + silence(0.03) +
      tone(1174, 1200, 0.14, amp=0.55, release=0.65))

# Soft, round double-boop — wrong guess, gentle on purpose (kids).
write("wrong.wav",
      tone(392, 370, 0.11, amp=0.32, harmonic=0.1) + silence(0.04) +
      tone(311, 296, 0.15, amp=0.28, release=0.7, harmonic=0.1))

# Little ascending arpeggio — streak milestones and celebrations.
write("win.wav",
      tone(1046, 1046, 0.10, amp=0.45) + tone(1318, 1318, 0.10, amp=0.47) +
      tone(1568, 1568, 0.10, amp=0.5) +
      tone(2093, 2093, 0.22, amp=0.52, release=0.7, vib_rate=9, vib_depth=18))

# R2D2-ish warble — greetings / game start.
write("hello.wav",
      tone(850, 1250, 0.30, amp=0.5, vib_rate=11, vib_depth=140,
           release=0.45))
