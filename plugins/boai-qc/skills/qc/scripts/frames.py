"""Extract frames from a video for vision checks.

Usage: python -I frames.py VIDEO OUTDIR [--fps 1]

Makes, in OUTDIR:
  frames/f_0001.png ...  full-size frames. Frame n is at (n - 1) / fps seconds.
  sheet_01.png ...       contact sheets, 5 x 3 frames, with timestamps (read these first)
  footer_01.png ...      the bottom 12% of each frame, 4 per row (SEBI line, disclaimers, sources)
Needs ffmpeg on PATH.
"""
import argparse
import shutil
import subprocess
import sys
from pathlib import Path

STAMP = "drawtext=text='%{pts\\:hms}':x=4:y=4:fontsize=18:fontcolor=yellow:box=1:boxcolor=black"


def ffmpeg(args):
    return subprocess.run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", *args],
                          capture_output=True, text=True, encoding="utf-8", errors="replace")


def with_stamp(video, filters, out):
    """Run with a timestamp overlay. Without a usable font, run again with no overlay."""
    r = ffmpeg(["-i", video, "-vf", filters.format(stamp="," + STAMP), out])
    if r.returncode != 0 or not any(Path(out).parent.glob(Path(out).name.replace("%02d", "*"))):
        ffmpeg(["-i", video, "-vf", filters.format(stamp=""), out])
        return False
    return True


def main():
    p = argparse.ArgumentParser()
    p.add_argument("video")
    p.add_argument("outdir")
    p.add_argument("--fps", type=float, default=1.0)
    a = p.parse_args()
    if not shutil.which("ffmpeg"):
        sys.exit("ffmpeg not found. Install it (Windows: winget install ffmpeg) and open a new terminal.")

    out = Path(a.outdir)
    (out / "frames").mkdir(parents=True, exist_ok=True)
    ffmpeg(["-i", a.video, "-vf", f"fps={a.fps}", str(out / "frames" / "f_%04d.png")])
    count = len(list((out / "frames").glob("f_*.png")))

    stamped = with_stamp(a.video, f"fps={a.fps},scale=240:-2{{stamp}},tile=5x3", str(out / "sheet_%02d.png"))
    with_stamp(a.video, f"fps={a.fps},crop=iw:ih*0.12:0:ih*0.88{{stamp}},tile=4x12", str(out / "footer_%02d.png"))

    print(f"{count} frames at {a.fps} fps in {out / 'frames'}")
    print("sheets:", ", ".join(sorted(f.name for f in out.glob("sheet_*.png"))))
    print("footers:", ", ".join(sorted(f.name for f in out.glob("footer_*.png"))))
    if not stamped:
        print(f"No font for timestamps. Tiles run left to right, top to bottom, 1 tile = {1 / a.fps:g} s, "
              "15 tiles per sheet, 48 per footer page.")


if __name__ == "__main__":
    main()
