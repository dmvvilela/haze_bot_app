#!/usr/bin/env python3
"""Freeze approved VoiceDesign auditions into consistent Qwen voice packs."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import soundfile as sf
import torch
from huggingface_hub import snapshot_download
from qwen_tts import Qwen3TTSModel


ROOT = Path(__file__).resolve().parent.parent
CONFIG = ROOT / "tool" / "haze_voice_design.json"
REFERENCES = ROOT / "tool" / "voice_output"
PORTUGUESE_REFERENCES = ROOT / "tool" / "voice_output_pt"
DEFAULT_OUTPUT = ROOT / "tool" / "voice_pack_output"
PORTUGUESE_OUTPUT = ROOT / "tool" / "voice_pack_output_pt"
MODEL_ID = "Qwen/Qwen3-TTS-12Hz-1.7B-Base"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--locale", choices=["en", "pt-BR"], default="en")
    parser.add_argument("--voice", action="append", help="Voice ID; repeatable")
    parser.add_argument("--line", action="append", help="Line ID; repeatable")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    config = json.loads(CONFIG.read_text())
    output_root = args.output or (
        PORTUGUESE_OUTPUT if args.locale == "pt-BR" else DEFAULT_OUTPUT
    )
    target_lines = (
        config["portuguese_lines"] if args.locale == "pt-BR" else config["lines"]
    )
    target_language = "Portuguese" if args.locale == "pt-BR" else "English"
    voices = args.voice or list(config["variants"])
    lines = args.line or list(target_lines)
    reference_root = PORTUGUESE_REFERENCES if args.locale == "pt-BR" else REFERENCES
    ref_text = target_lines["hello"]

    if not torch.backends.mps.is_available():
        raise RuntimeError("This studio expects Apple Silicon MPS")
    model_path = snapshot_download(MODEL_ID)
    print(f"Loading {MODEL_ID} on MPS")
    model = Qwen3TTSModel.from_pretrained(
        model_path,
        device_map="mps",
        dtype=torch.float16,
        attn_implementation="eager",
    )

    for voice_id in voices:
        reference = reference_root / voice_id / "hello.wav"
        if not reference.exists():
            raise FileNotFoundError(f"Generate reference first: {reference}")
        print(f"Freezing voice identity from {reference}")
        prompt = model.create_voice_clone_prompt(
            ref_audio=str(reference),
            ref_text=ref_text,
        )
        voice_dir = output_root / voice_id
        voice_dir.mkdir(parents=True, exist_ok=True)
        for line_id in lines:
            text = target_lines[line_id]
            output = voice_dir / f"{line_id}.wav"
            if line_id == "hello" and args.locale == "en":
                output.write_bytes(reference.read_bytes())
                continue
            print(f"Generating {voice_id}/{line_id}: {text}")
            waves, sample_rate = model.generate_voice_clone(
                text=text,
                language=target_language,
                voice_clone_prompt=prompt,
            )
            sf.write(output, waves[0], sample_rate)


if __name__ == "__main__":
    main()
