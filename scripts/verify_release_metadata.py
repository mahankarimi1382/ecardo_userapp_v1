#!/usr/bin/env python3
"""Check the repository's canonical current-release metadata for obvious drift.

Place this script at scripts/verify_release_metadata.py and keep a canonical file at
 docs/release/CURRENT_RELEASE.md. This script does not query GitHub or prove signing;
it only checks local Git/tag/pubspec/current-release agreement.
"""
from __future__ import annotations
import re
import subprocess
import sys
from pathlib import Path


def find_repo_root() -> Path:
    current = Path(__file__).resolve()
    for parent in [current] + list(current.parents):
        if (parent / "pubspec.yaml").is_file():
            return parent
    return current.parents[1]


ROOT = find_repo_root()
PUBSPEC = ROOT / "pubspec.yaml"


def find_current_release_file(root: Path) -> Path:
    candidates = [
        root / "docs" / "release" / "CURRENT_RELEASE.md",
        root / "docs" / "CURRENT_RELEASE.md",
        root / "docs" / "roadmap_v171" / "ecardo_v1_0_171_roadmap" / "15_CURRENT_RELEASE_EVIDENCE.md",
    ]
    for c in candidates:
        if c.is_file():
            return c
    return root / "docs" / "release" / "CURRENT_RELEASE.md"


def command(*args: str) -> str:
    result = subprocess.run(args, cwd=ROOT, text=True, capture_output=True)
    if result.returncode != 0:
        raise RuntimeError(f"Command failed: {' '.join(args)}\n{result.stderr.strip()}")
    return result.stdout.strip()


def value(text: str, field: str) -> str | None:
    match = re.search(
        rf"(?im)^\s*(?:-\s*)?\*?\*?{re.escape(field)}\*?\*?\s*:\s*\*?\*?\s*(.+?)\s*$",
        text,
    )
    if not match:
        return None
    val = match.group(1).strip()
    backtick_m = re.match(r"^`([^`]+)`", val)
    if backtick_m:
        return backtick_m.group(1).strip()
    return val.strip("` ")


def main() -> int:
    errors: list[str] = []
    if not PUBSPEC.exists():
        print(f"ERROR: pubspec.yaml not found at {PUBSPEC}", file=sys.stderr)
        return 2

    current_file = (
        Path(sys.argv[1]).resolve()
        if len(sys.argv) > 1
        else find_current_release_file(ROOT)
    )
    if not current_file.exists():
        print(
            f"ERROR: {current_file} missing. Create the canonical release pointer first.",
            file=sys.stderr,
        )
        return 2

    pub = PUBSPEC.read_text(encoding="utf-8")
    doc = current_file.read_text(encoding="utf-8")
    m = re.search(r"(?m)^version:\s*([0-9]+\.[0-9]+\.[0-9]+\+[0-9]+)\s*$", pub)
    if not m:
        errors.append("Cannot parse version X.Y.Z+N from pubspec.yaml")
        pub_version = None
    else:
        pub_version = m.group(1)

    doc_version = (
        value(doc, "pubspec version")
        or value(doc, "Active Release Version")
        or value(doc, "Version")
    )
    if pub_version and doc_version and pub_version not in doc_version:
        errors.append(f"Version mismatch: pubspec={pub_version}, current release file={doc_version}")
    elif not doc_version:
        errors.append("Current release file has no 'pubspec version:' field")

    tag = (
        value(doc, "Release tag")
        or value(doc, "Active Release Git Tag")
    )
    sha = (
        value(doc, "tag/commit SHA")
        or value(doc, "Commit SHA")
        or value(doc, "Active Release Commit SHA")
    )

    if pub_version and tag:
        semver = pub_version.split("+", 1)[0]
        if tag.strip("`") != f"v{semver}":
            errors.append(f"Tag mismatch: expected v{semver}, found {tag}")
    elif not tag:
        errors.append("Current release file has no 'Release tag:' field")

    head = command("git", "rev-parse", "HEAD")
    clean_sha = sha.strip("` ") if sha else ""
    if clean_sha and clean_sha != "HEAD" and head != clean_sha and not head.startswith(clean_sha) and not clean_sha.startswith(head):
        errors.append(
            f"Current release SHA {sha} differs from local HEAD {head}; update evidence only after confirming target release"
        )
    elif not clean_sha:
        errors.append("Current release file has no commit SHA")

    if tag:
        clean_tag = tag.strip("` ")
        try:
            tag_sha = command("git", "rev-parse", f"{clean_tag}^{{commit}}")
            if clean_sha and clean_sha != "HEAD" and tag_sha != clean_sha and not tag_sha.startswith(clean_sha) and not clean_sha.startswith(tag_sha):
                errors.append(f"Tag target mismatch: {tag} points to {tag_sha}, evidence says {sha}")
            elif clean_sha == "HEAD" and tag_sha != head:
                errors.append(f"Tag target mismatch: {tag} points to {tag_sha}, HEAD is {head}")
        except RuntimeError as exc:
            errors.append(f"Cannot verify tag: {exc}")

    if errors:
        print(f"RELEASE METADATA CHECK ({current_file.name}): FAIL")
        for item in errors:
            print(f"- {item}")
        return 1
    print(
        f"RELEASE METADATA CHECK ({current_file.name}): PASS (local consistency only; does not verify GitHub artifacts, CI logs, or signatures)"
    )
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
