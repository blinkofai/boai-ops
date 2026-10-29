"""Technical measurements for a video: specs, loudness, true peak, silence, black and frozen frames.

Usage: python -I auto_checks.py VIDEO

Prints one JSON object. Compare the values with `formats.video` in the client rulebook.
Needs ffmpeg and ffprobe on PATH.
"""
import json
import re
import shutil
import subprocess
import sys


def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")


def num(value):
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


def probe(path):
    r = run(["ffprobe", "-v", "error", "-print_format", "json", "-show_format", "-show_streams", path])
    if r.returncode != 0:
        sys.exit(f"ffprobe failed: {r.stderr.strip()}")
    data = json.loads(r.stdout)
    fmt = data.get("format", {})
    out = {
        "file_size_mb": round(int(fmt.get("size", 0)) / 1_000_000, 2),
        "duration_sec": round(num(fmt.get("duration")) or 0, 3),
        "video": None,
        "audio": None,
    }
    for s in data.get("streams", []):
        if s.get("codec_type") == "video" and out["video"] is None:
            out["video"] = {
                "codec": s.get("codec_name"),
                "width": s.get("width"),
                "height": s.get("height"),
                "r_frame_rate": s.get("r_frame_rate"),
                "avg_frame_rate": s.get("avg_frame_rate"),
                "pix_fmt": s.get("pix_fmt"),
            }
        elif s.get("codec_type") == "audio" and out["audio"] is None:
            out["audio"] = {
                "codec": s.get("codec_name"),
                "sample_rate": int(s.get("sample_rate", 0)),
                "channels": s.get("channels"),
            }
    return out


def loudness(path):
    r = run(["ffmpeg", "-hide_banner", "-nostats", "-i", path, "-af", "ebur128=peak=true", "-f", "null", "-"])
    summary = r.stderr[r.stderr.rfind("Summary:"):]
    integrated = re.search(r"I:\s+(-?[\d.]+|-inf) LUFS", summary)
    lra = re.search(r"LRA:\s+(-?[\d.]+) LU", summary)
    peak = re.search(r"Peak:\s+(-?[\d.]+|-inf) dBFS", summary)
    return {
        "integrated_lufs": num(integrated.group(1)) if integrated else None,
        "loudness_range_lu": num(lra.group(1)) if lra else None,
        "true_peak_dbtp": num(peak.group(1)) if peak else None,
    }


def events(path, duration, has_audio):
    cmd = ["ffmpeg", "-hide_banner", "-nostats", "-i", path,
           "-vf", "blackdetect=d=0.1:pix_th=0.10,freezedetect=n=0.003:d=1.5"]
    if has_audio:
        cmd += ["-af", "silencedetect=n=-45dB:d=0.7"]
    cmd += ["-f", "null", "-"]
    log = run(cmd).stderr

    black = [
        {"start": num(m.group(1)), "end": num(m.group(2)), "duration": num(m.group(3))}
        for m in re.finditer(r"black_start:([\d.]+) black_end:([\d.]+) black_duration:([\d.]+)", log)
    ]

    def spans(start_key, end_key):
        found, start = [], None
        for line in log.splitlines():
            s = re.search(start_key + r":\s*([\d.]+)", line)
            e = re.search(end_key + r":\s*([\d.]+)", line)
            if s:
                start = num(s.group(1))
            elif e and start is not None:
                found.append({"start": start, "end": num(e.group(1)), "duration": round(num(e.group(1)) - start, 3)})
                start = None
        if start is not None:  # runs to the end of the file
            found.append({"start": start, "end": duration, "duration": round(duration - start, 3), "to_end": True})
        return found

    return {
        "black": black,
        "freeze": spans(r"freeze_start", r"freeze_end"),
        "silence": spans(r"silence_start", r"silence_end") if has_audio else [],
    }


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    for tool in ("ffmpeg", "ffprobe"):
        if not shutil.which(tool):
            sys.exit(f"{tool} not found. Install it (Windows: winget install ffmpeg) and open a new terminal.")
    path = sys.argv[1]
    result = probe(path)
    has_audio = result["audio"] is not None
    if has_audio:
        result["loudness"] = loudness(path)
    result.update(events(path, result["duration_sec"], has_audio))
    result["thresholds_used"] = {
        "black": "pix_th 0.10, min 0.1 s",
        "freeze": "noise 0.003, min 1.5 s",
        "silence": "-45 dB, min 0.7 s",
    }
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
