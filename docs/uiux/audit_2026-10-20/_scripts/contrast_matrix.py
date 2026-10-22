#!/usr/bin/env python3
"""WCAG 2.x contrast calculator for AppColors token pairs (read-only).

Source values copied verbatim from lib/src/app/constants/app_colors.dart.
Alpha channels (0x99, 0x8C, 0x4D ...) are composited over the given backdrop
before measuring, as Flutter does when painting.

Usage: python -I contrast_matrix.py [--md]
"""
import argparse
import sys


def parse(c):
    c = c.strip()
    if c.startswith("#"):
        c = c[1:]
    elif c[:2].lower() == "0x":
        c = c[2:]
    # Flutter Color literals are 0xAARRGGBB. Return (r, g, b, a).
    if len(c) == 8:
        a, r, g, b = (int(c[i:i + 2], 16) for i in (0, 2, 4, 6))
        return (r, g, b, a)
    return (*[int(c[i:i + 2], 16) for i in (0, 2, 4)], 255)


def over(fg, bg):
    """Source-over composite of fg (with alpha) onto opaque bg."""
    a = fg[3] / 255.0
    return tuple(round(fg[i] * a + bg[i] * (1 - a)) for i in range(3)) + (255,)


def lum(rgb):
    def ch(v):
        v /= 255.0
        return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4
    r, g, b = (ch(x) for x in rgb[:3])
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def ratio(fg, bg):
    f, b = lum(over(fg, bg)), lum(over(bg, bg))
    hi, lo = max(f, b), min(f, b)
    return (hi + 0.05) / (lo + 0.05)


T = {
    # light
    "lightBackground": "0xFFF5F7FB",
    "lightSurface": "0xFFFFFFFF",
    "lightSurfaceVariant": "0xFFF0F2F6",
    "lightPrimary": "0xFF7445FF",
    "lightTextPrimary": "0xFF161614",
    "lightTextSecondary": "0xFF656262",
    "lightTextTertiary": "0x99161614",
    "lightTextOnPrimary": "0xFFFFFFFF",
    "lightBorder": "0xFFD5CBC8",
    "lightSecondaryContainer": "0xFFE0F8F5",
    # dark
    "darkBackground": "0xFF161614",
    "darkSurface": "0xFF262625",
    "darkSurfaceVariant": "0xFF322F3A",
    "darkPrimary": "0xFFB79CFF",
    "darkTextPrimary": "0xFFE7E0DE",
    "darkTextSecondary": "0xFF656262",
    "darkTextTertiary": "0x8CE7E0DE",
    "darkTextOnPrimary": "0xFF161614",
    "darkBorder": "0x33D5CBC8",
    "darkSecondary": "0xFF00BFA6",
    # semantic
    "error": "0xFFDC3C22",
    "warning": "0xFFFFAA00",
    "success": "0xFF14AE6F",
    "info": "0xFF2196F3",
    "white": "0xFFFFFFFF",
    "darkGray": "0xFF262625",
}

PAIRS = [
    # (label, fg, bg, uses)
    ("light body text on page", "lightTextPrimary", "lightBackground", "normal"),
    ("light body text on card", "lightTextPrimary", "lightSurface", "normal"),
    ("light secondary on page", "lightTextSecondary", "lightBackground", "normal"),
    ("light secondary on card", "lightTextSecondary", "lightSurface", "normal"),
    ("light tertiary (60%) on card", "lightTextTertiary", "lightSurface", "normal"),
    ("light tertiary (60%) on page", "lightTextTertiary", "lightBackground", "normal"),
    ("light onPrimary on primary", "lightTextOnPrimary", "lightPrimary", "normal"),
    ("light primary text on card", "lightPrimary", "lightSurface", "link"),
    ("light primary text on page", "lightPrimary", "lightBackground", "link"),
    ("light border vs card", "lightBorder", "lightSurface", "nontext-3:1"),
    ("dark body text on page", "darkTextPrimary", "darkBackground", "normal"),
    ("dark body text on card", "darkTextPrimary", "darkSurface", "normal"),
    ("dark secondary on page", "darkTextSecondary", "darkBackground", "normal"),
    ("dark secondary on card", "darkTextSecondary", "darkSurface", "normal"),
    ("dark tertiary (55%) on page", "darkTextTertiary", "darkBackground", "normal"),
    ("dark tertiary (55%) on card", "darkTextTertiary", "darkSurface", "normal"),
    ("dark onPrimary on primary", "darkTextOnPrimary", "darkPrimary", "normal"),
    ("dark primary text on page", "darkPrimary", "darkBackground", "link"),
    ("dark secondary accent on card", "darkSecondary", "darkSurface", "link"),
    ("dark border vs page", "darkBorder", "darkBackground", "nontext-3:1"),
    ("error on light card", "error", "lightSurface", "normal"),
    ("error on dark card", "error", "darkSurface", "normal"),
    ("warning on light card", "warning", "lightSurface", "normal"),
    ("warning on dark card", "warning", "darkSurface", "normal"),
    ("success on light card", "success", "lightSurface", "normal"),
    ("success on dark card", "success", "darkSurface", "normal"),
    ("info on light card", "info", "lightSurface", "normal"),
    ("info on dark card", "info", "darkSurface", "normal"),
    ("white on error", "white", "error", "normal"),
    ("white on success", "success", "darkSurface", "normal"),
]


def verdict(r, kind):
    if kind == "nontext-3:1":
        return "PASS" if r >= 3.0 else "FAIL"
    if kind == "link":
        need = 3.0  # large/bold text or non-text UI; normal link text needs 4.5
        return ("PASS" if r >= 4.5 else "LARGE-ONLY" if r >= 3.0 else "FAIL")
    return "PASS" if r >= 4.5 else "LARGE-ONLY" if r >= 3.0 else "FAIL"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--md", action="store_true")
    ns = ap.parse_args()
    rows = []
    for label, fg, bg, kind in PAIRS:
        r = ratio(parse(T[fg]), parse(T[bg]))
        v = verdict(r, kind)
        rows.append((label, T[fg], T[bg], r, v, kind))
    if ns.md:
        print("| pair | fg | bg | ratio | AA |")
        print("|---|---|---|---|---|")
        for label, fg, bg, r, v, kind in rows:
            print(f"| {label} | `{fg}` | `{bg}` | {r:.2f}:1 | {v} |")
    else:
        for label, fg, bg, r, v, kind in rows:
            print(f"{r:6.2f}:1  {v:11s} {label}  ({fg} on {bg})")
    fails = [x for x in rows if x[4] == "FAIL"]
    print(f"\n{len(fails)} hard FAIL of {len(rows)} pairs", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
