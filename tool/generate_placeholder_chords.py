#!/usr/bin/env python3
"""자리표시자 코드 음원을 assets/chords/에 만듭니다.

실제 기타 샘플이 아닙니다. 코드 이름마다 짧은 합성 화음(wav)을 하나 만듭니다.
실제 녹음으로 바꿀 때는 같은 이름으로 mp3를 넣거나 wav를 덮어쓰면 됩니다.

    python3 tool/generate_placeholder_chords.py
"""

from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

SAMPLE_RATE = 22050
DURATION_SECONDS = 0.6
AMPLITUDE = 0.32


def midi_hz(note: int) -> float:
    return 440.0 * (2.0 ** ((note - 69) / 12.0))


def major(root: int) -> list[int]:
    return [root, root + 4, root + 7]


def minor(root: int) -> list[int]:
    return [root, root + 3, root + 7]


def dominant7(root: int) -> list[int]:
    return [root, root + 4, root + 7, root + 10]


# MIDI 음높이. 열린 코드가 주로 앉는 음역에 가깝게 잡았습니다.
CHORDS: dict[str, list[int]] = {
    "C": major(60),
    "D": major(62),
    "E": major(64),
    "F": major(65),
    "G": major(55),
    "A": major(57),
    "B": major(59),
    "Am": minor(57),
    "Dm": minor(62),
    "Em": minor(64),
    "Bm": minor(59),
    "C7": dominant7(60),
    "D7": dominant7(62),
    "E7": dominant7(64),
    "G7": dominant7(55),
    "A7": dominant7(57),
}


def render(notes: list[int]) -> bytes:
    count = int(SAMPLE_RATE * DURATION_SECONDS)
    frequencies = [midi_hz(note) for note in notes]
    attack = int(0.02 * SAMPLE_RATE)
    release = int(0.12 * SAMPLE_RATE)
    frames = bytearray()
    for index in range(count):
        if index < attack:
            envelope = index / attack
        elif index > count - release:
            envelope = max(0.0, (count - index) / release)
        else:
            progress = (index - attack) / max(1, count - attack - release)
            envelope = 1.0 - (0.25 * progress)
        sample = 0.0
        time = index / SAMPLE_RATE
        for frequency in frequencies:
            sample += math.sin(2.0 * math.pi * frequency * time)
        sample = (sample / len(frequencies)) * AMPLITUDE * envelope
        sample = max(-1.0, min(1.0, sample))
        frames += struct.pack("<h", int(sample * 32767))
    return bytes(frames)


def write_wav(path: Path, pcm: bytes) -> None:
    with wave.open(str(path), "w") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(SAMPLE_RATE)
        handle.writeframes(pcm)


def main() -> None:
    output = Path(__file__).resolve().parents[1] / "assets" / "chords"
    output.mkdir(parents=True, exist_ok=True)
    for name, notes in CHORDS.items():
        destination = output / f"{name}.wav"
        write_wav(destination, render(notes))
        print(f"wrote {destination} ({destination.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
