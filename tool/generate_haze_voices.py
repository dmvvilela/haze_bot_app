#!/usr/bin/env python3
"""Generate local Haze voice auditions with Qwen3-TTS VoiceDesign."""

from __future__ import annotations

import argparse
import json
import platform
from pathlib import Path

import soundfile as sf
import torch
from huggingface_hub import snapshot_download
from huggingface_hub.errors import HfHubHTTPError
from qwen_tts import Qwen3TTSModel


ROOT = Path(__file__).resolve().parent.parent
DEFAULT_CONFIG = ROOT / "tool" / "haze_voice_design.json"
DEFAULT_OUTPUT = ROOT / "tool" / "voice_output"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", type=Path, default=DEFAULT_CONFIG)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument(
        "--variant",
        action="append",
        help="Generate only this voice variant; may be passed more than once",
    )
    parser.add_argument("--line", help="Generate only this line ID")
    parser.add_argument("--cpu", action="store_true", help="Disable Apple MPS")
    return parser.parse_args()


def load_model(model_id: str, force_cpu: bool) -> Qwen3TTSModel:
    use_mps = not force_cpu and torch.backends.mps.is_available()
    device = "mps" if use_mps else "cpu"
    dtype = torch.float16 if use_mps else torch.float32
    print(f"Downloading/checking {model_id}")
    try:
        # Respect the user's configured Hugging Face CLI account. This also
        # supports gated models if we add one to the studio later.
        model_path = snapshot_download(model_id)
    except HfHubHTTPError as error:
        if error.response is None or error.response.status_code != 401:
            raise
        print("Configured Hugging Face login was rejected; retrying public model anonymously")
        model_path = snapshot_download(model_id, token=False)
    print(f"Loading {model_path} on {device} ({dtype})")
    return Qwen3TTSModel.from_pretrained(
        model_path,
        device_map=device,
        dtype=dtype,
        attn_implementation="eager",
    )


def main() -> None:
    args = parse_args()
    config = json.loads(args.config.read_text())
    variants = config["variants"]
    lines = config["lines"]
    if args.variant:
        variants = {variant: variants[variant] for variant in args.variant}
    if args.line:
        lines = {args.line: lines[args.line]}

    args.output.mkdir(parents=True, exist_ok=True)
    model = load_model(config["model"], args.cpu)
    print(f"Host: {platform.machine()} / {platform.mac_ver()[0]}")

    for variant_id, instruction in variants.items():
        variant_dir = args.output / variant_id
        variant_dir.mkdir(parents=True, exist_ok=True)
        for line_id, text in lines.items():
            output = variant_dir / f"{line_id}.wav"
            print(f"Generating {variant_id}/{line_id}: {text}")
            waves, sample_rate = model.generate_voice_design(
                text=text,
                language=config["language"],
                instruct=instruction,
            )
            sf.write(output, waves[0], sample_rate)
            print(f"Wrote {output}")


if __name__ == "__main__":
    main()
