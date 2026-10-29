"""Crop and enlarge part of an image, to read small text or check detail.

Usage: python -I crop.py IMAGE X Y W H OUT [--scale 2]

X, Y, W, H are in pixels of the source image. Needs ffmpeg on PATH.
"""
import argparse
import subprocess
import sys


def main():
    p = argparse.ArgumentParser()
    p.add_argument("image")
    for name in ("x", "y", "w", "h"):
        p.add_argument(name, type=int)
    p.add_argument("out")
    p.add_argument("--scale", type=float, default=2.0)
    a = p.parse_args()
    vf = f"crop={a.w}:{a.h}:{a.x}:{a.y},scale=iw*{a.scale}:ih*{a.scale}:flags=lanczos"
    r = subprocess.run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", a.image, "-vf", vf, a.out],
                       capture_output=True, text=True)
    if r.returncode != 0:
        sys.exit(r.stderr.strip())
    print(a.out)


if __name__ == "__main__":
    main()
