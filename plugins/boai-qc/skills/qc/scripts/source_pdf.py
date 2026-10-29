"""Read a source PDF (article, script, approved copy): text plus page images.

Usage: python -I source_pdf.py PDF OUTDIR [--dpi 130]

Makes OUTDIR/text.txt (with page markers) and OUTDIR/page_1.png ...
Read the page images for charts and tables: the text layer loses chart labels and some symbols (₹).
Needs PyMuPDF: python -m pip install pymupdf
"""
import argparse
import sys
from pathlib import Path


def main():
    p = argparse.ArgumentParser()
    p.add_argument("pdf")
    p.add_argument("outdir")
    p.add_argument("--dpi", type=int, default=130)
    a = p.parse_args()
    try:
        import fitz
    except ImportError:
        sys.exit("PyMuPDF not found. Run: python -m pip install pymupdf")

    out = Path(a.outdir)
    out.mkdir(parents=True, exist_ok=True)
    doc = fitz.open(a.pdf)
    with open(out / "text.txt", "w", encoding="utf-8") as f:
        for i, page in enumerate(doc, start=1):
            f.write(f"\n===== page {i} =====\n")
            f.write(page.get_text())
            page.get_pixmap(dpi=a.dpi).save(out / f"page_{i}.png")
    print(f"{len(doc)} pages -> {out / 'text.txt'} and page_N.png")


if __name__ == "__main__":
    main()
