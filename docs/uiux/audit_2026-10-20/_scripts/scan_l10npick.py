#!/usr/bin/env python3
"""Scan a Flutter tree for l10nPick( / l10nPickAuto( call sites and report
which of the six locale arguments (en, fa, ar, tr, ru, zh) are missing.

Missing ar/tr/ru/zh silently fall back to English in lib/src/helper/l10n_pick.dart
(see `ar ?? en` etc.), so a call site that omits them renders English text in
those locales with no compile error.

Read-only: walks the tree, never imports or executes inspected code.

Usage:
    python -I scan_l10npick.py <repo_root> [--json out.json] [--lib lib]

Run with the repo root as cwd so relative paths in the report are repo-relative.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys

LOCALES = ("en", "fa", "ar", "tr", "ru", "zh")
FUNCS = ("l10nPickAuto", "l10nPick")


def strip_comments(src: str) -> str:
    """Blank out // and /* */ comments while preserving offsets and newlines.
    Leaves string literals untouched (they may contain //)."""
    out = list(src)
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        if c in "'\"":
            raw = i > 0 and src[i - 1] == "r"
            triple = src.startswith(c * 3, i)
            q = c * 3 if triple else c
            i += len(q)
            while i < n:
                if not triple and src[i] == "\\" and not raw:
                    i += 2
                    continue
                if src.startswith(q, i):
                    i += len(q)
                    break
                i += 1
            continue
        if c == "/" and i + 1 < n and src[i + 1] == "/":
            while i < n and src[i] != "\n":
                out[i] = " "
                i += 1
            continue
        if c == "/" and i + 1 < n and src[i + 1] == "*":
            j = src.find("*/", i + 2)
            j = n if j < 0 else j + 2
            for k in range(i, j):
                if out[k] != "\n":
                    out[k] = " "
            i = j
            continue
        i += 1
    return "".join(out)


def match_close(src: str, open_idx: int, open_c: str, close_c: str) -> int:
    """Return index of the matching close char, string/interp aware."""
    depth = 0
    i, n = open_idx, len(src)
    while i < n:
        c = src[i]
        if c in "'\"":
            triple = src.startswith(c * 3, i)
            q = c * 3 if triple else c
            i += len(q)
            while i < n:
                if not triple and src[i] == "\\":
                    i += 2
                    continue
                if src.startswith(q, i):
                    i += len(q)
                    break
                # string interpolation may contain brackets; they are balanced
                # inside the literal, so plain scanning is safe for depth.
                i += 1
            continue
        if c == open_c:
            depth += 1
        elif c == close_c:
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return -1


def split_top_level_args(args: str) -> list[str]:
    """Split a Dart argument list on top-level commas."""
    parts, depth, i, start, n = [], 0, 0, 0, len(args)
    while i < n:
        c = args[i]
        if c in "'\"":
            triple = args.startswith(c * 3, i)
            q = c * 3 if triple else c
            i += len(q)
            while i < n:
                if not triple and args[i] == "\\":
                    i += 2
                    continue
                if args.startswith(q, i):
                    i += len(q)
                    break
                i += 1
            continue
        if c in "([{":
            depth += 1
        elif c in ")]}":
            depth -= 1
        elif c == "," and depth == 0:
            parts.append(args[start:i])
            start = i + 1
        i += 1
    tail = args[start:]
    if tail.strip():
        parts.append(tail)
    return parts


def parse_calls(path: str, rel: str) -> list[dict]:
    raw = open(path, encoding="utf-8", errors="replace").read()
    src = strip_comments(raw)
    line_starts = [0]
    for idx, ch in enumerate(src):
        if ch == "\n":
            line_starts.append(idx + 1)

    def line_of(pos: int) -> int:
        lo, hi = 0, len(line_starts) - 1
        while lo < hi:
            mid = (lo + hi + 1) // 2
            if line_starts[mid] <= pos:
                lo = mid
            else:
                hi = mid - 1
        return lo + 1

    findings = []
    for fn in FUNCS:
        needle = fn + "("
        pos = 0
        while True:
            hit = src.find(needle, pos)
            if hit < 0:
                break
            pos = hit + len(needle)
            # skip definition sites (`String l10nPick(` possibly across a
            # newline) and member accesses like foo.l10nPick(
            if re.search(r"String\s+$", src[max(0, hit - 40):hit]):
                continue
            before = src[max(0, hit - 3):hit]
            if "." in before:
                continue
            open_idx = hit + len(needle) - 1
            close = match_close(src, open_idx, "(", ")")
            if close < 0:
                continue
            args = src[open_idx + 1:close]
            names = []
            positional = []
            for a in split_top_level_args(args):
                a = a.strip()
                if not a:
                    continue
                if ":" not in a:
                    positional.append(a)
                    continue
                key, val = a.split(":", 1)
                key, val = key.strip(), val.strip()
                names.append(key)
            # `condition ? x : y` looks like a named arg; only count names that
            # appear on a call boundary (preceded by '(' or ',').
            provided = {k for k in names if k in LOCALES}
            missing = [l for l in LOCALES if l not in provided]
            findings.append({
                "file": rel,
                "line": line_of(hit),
                "func": fn,
                "missing": missing,
                "has_context": bool(positional) and positional[0] == "context",
            })
    return findings


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("repo", help="repo root to scan (read-only)")
    ap.add_argument("--lib", default="lib", help="subdir under repo root (default: lib)")
    ap.add_argument("--json", help="optional path for machine-readable output")
    ns = ap.parse_args()

    root = os.path.abspath(ns.repo)
    scan_root = os.path.join(root, ns.lib)
    if not os.path.isdir(scan_root):
        print(f"not a directory: {scan_root}", file=sys.stderr)
        return 2

    all_findings = []
    for dirpath, dirnames, filenames in os.walk(scan_root):
        dirnames[:] = [d for d in dirnames if d not in {".dart_tool", "build"}]
        for name in filenames:
            if not name.endswith(".dart"):
                continue
            full = os.path.join(dirpath, name)
            rel = os.path.relpath(full, root).replace(os.sep, "/")
            all_findings.extend(parse_calls(full, rel))

    total = len(all_findings)
    files = len({f["file"] for f in all_findings})
    by_missing = {}
    for f in all_findings:
        k = ",".join(f["missing"]) if f["missing"] else "(complete)"
        by_missing[k] = by_missing.get(k, 0) + 1

    offenders = {}
    for f in all_findings:
        if f["missing"]:
            offenders[f["file"]] = offenders.get(f["file"], 0) + 1

    print(f"repo: {root}")
    print(f"files scanned: {files} with calls; call sites: {total}")
    print("\n--- breakdown by missing set ---")
    for k, v in sorted(by_missing.items(), key=lambda kv: -kv[1]):
        print(f"{v:6d}  {k}")
    print(f"\n--- incomplete call sites: {sum(offenders.values())} in {len(offenders)} files ---")
    for fn, c in sorted(offenders.items(), key=lambda kv: (-kv[1], kv[0])):
        print(f"{c:5d}  {fn}")
    # per-locale miss counts
    print("\n--- misses per locale ---")
    for l in LOCALES:
        print(f"{l}: {sum(1 for f in all_findings if l in f['missing'])}")

    if ns.json:
        with open(ns.json, "w", encoding="utf-8") as fh:
            json.dump(all_findings, fh, ensure_ascii=False, indent=1)
        print(f"\nwrote {ns.json}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
