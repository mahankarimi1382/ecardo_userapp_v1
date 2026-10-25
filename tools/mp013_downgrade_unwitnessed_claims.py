#!/usr/bin/env python3
"""MP-013 — Honest downgrade of unwitnessed claims in the two upstream catalogs.

Surgical, line-by-line editor (never a whole-file rewrite):
  * Reads the file as bytes, splits on CRLF, keeps BOM and every unchanged line
    byte-identical.
  * For each line that matches a task rule, re-serialises ONLY that line with
    csv.writer (QUOTE_MINIMAL, CRLF) after proving round-trip fidelity of the
    serialiser on every line of the file (unchanged re-serialisation must equal
    the original bytes, else the script aborts with no writes).
  * --apply writes; without it, it is a dry run reporting the change map.

Task rules (MP-013):
  SCREEN_UPGRADE_REGISTRY.csv
    ui_status    DONE  -> NEEDS_EVIDENCE   (before_screenshot/after_screenshot empty)
    test_status  PASS  -> NOT_RUN          (no real witness: evidence_refs=EVD-* strings
                                            resolve to no artifact anywhere in the workspace)
    status       SOURCE_MAPPED stays (never touched)
  ROUTE_CATALOG.csv
    runtime_status RUNTIME_VERIFIED -> NOT_RUN  (no evidence column in this catalog at all;
                                                 screenshot_before/after point to the
                                                 non-existent evidence/ folder; test_ids
                                                 absent from the test tree)
Any row not matching a rule is left untouched.
"""
import argparse, csv, io, sys
from collections import Counter
from pathlib import Path

RULES = {
    'ecardo_userapp_v1/docs/uiux/SCREEN_UPGRADE_REGISTRY.csv': [
        # (column, old, new, guard)  guard = lambda row,ix: bool
        ('ui_status', 'DONE', 'NEEDS_EVIDENCE',
         lambda r, ix: r[ix['before_screenshot']].strip() == '' or r[ix['after_screenshot']].strip() == ''),
        ('test_status', 'PASS', 'NOT_RUN',
         lambda r, ix: True),  # every PASS row: EVD-* refs have no artifact on disk (verified by grep)
    ],
    'ecardo_userapp_v1/docs/app-map/ROUTE_CATALOG.csv': [
        ('runtime_status', 'RUNTIME_VERIFIED', 'NOT_RUN',
         lambda r, ix: True),  # catalog has no evidence column at all (validator: errors=740)
    ],
}


def split_lines(data: bytes):
    parts = data.split(b'\r\n')
    if parts[-1] != b'':
        raise SystemExit('FATAL: file does not end with CRLF; aborting (unexpected format)')
    return parts[:-1]  # without trailing empty element; rejoined with trailing CRLF


def serialise(fields) -> str:
    buf = io.StringIO(newline='')
    csv.writer(buf, lineterminator='\r\n', quoting=csv.QUOTE_MINIMAL).writerow(fields)
    return buf.getvalue()[:-2]  # strip the CRLF the writer appended


def process(path: Path, rules, apply: bool):
    data = path.read_bytes()
    if not data.startswith(b'\xef\xbb\xbf'):
        raise SystemExit(f'FATAL: {path} lost BOM expectation')
    raw_lines = split_lines(data)
    text_lines = [ln.decode('utf-8-sig') if i == 0 else ln.decode('utf-8')
                  for i, ln in enumerate(raw_lines)]

    header = next(csv.reader(io.StringIO(text_lines[0], newline='')))
    ix = {c: i for i, c in enumerate(header)}

    # ---- fidelity gate: serialiser must reproduce EVERY original line bit-exactly
    for n, tl in enumerate(text_lines, start=1):
        fields = next(csv.reader(io.StringIO(tl, newline='')))
        if serialise(fields) != tl:
            raise SystemExit(f'FATAL: round-trip mismatch at line {n}; no writes performed')
    # ---- end gate

    changed_lines = []
    change_counter = Counter()          # (column, old, new) -> rows
    untouched_claims = Counter()        # claims seen but no rule fired -> report
    for n, tl in enumerate(text_lines[1:], start=2):
        fields = next(csv.reader(io.StringIO(tl, newline='')))
        new_fields = list(fields)
        touched = False
        for col, old, new, guard in rules:
            if col not in ix:
                raise SystemExit(f'FATAL: column {col} missing in {path}')
            cur = new_fields[ix[col]].strip()
            if cur == old and guard(fields, ix):
                new_fields[ix[col]] = new
                change_counter[(col, old, new)] += 1
                touched = True
        # record claims that REMAINED after this row's changes (final values, for honest reporting)
        for col in ('ui_status', 'behavior_status', 'state_coverage_status',
                    'accessibility_status', 'localization_status', 'responsive_status',
                    'test_status', 'runtime_status', 'upgrade_status'):
            if col in ix:
                final = new_fields[ix[col]].strip()
                if final in ('DONE', 'PASS', 'RUNTIME_VERIFIED', 'UPGRADED'):
                    untouched_claims[f'{col}={final} (kept, out of MP-013 scope)'] += 1
        if touched:
            assert len(new_fields) == len(fields)
            new_line = serialise(new_fields)
            # prove exactly the intended fields differ
            diffs = [(i, a, b) for i, (a, b) in enumerate(zip(fields, new_fields)) if a != b]
            assert all(header[i] in {c for c, _, _, _ in rules} for i, _, _ in diffs), diffs
            changed_lines.append((n, tl, new_line))

    report = {
        'file': str(path),
        'total_lines': len(text_lines),
        'changed_line_count': len(changed_lines),
        'changes': {f'{c}: {o} -> {nw}': cnt for (c, o, nw), cnt in sorted(change_counter.items())},
        'kept_claims': dict(untouched_claims),
    }
    if apply:
        out = list(raw_lines)
        for n, _old, new in changed_lines:
            out[n - 1] = (new.encode('utf-8') if n > 1 else new.encode('utf-8-sig'))
        assert out[0] == raw_lines[0], 'header line must never change'
        path.write_bytes(b'\r\n'.join(out) + b'\r\n')
        report['written'] = True
    else:
        report['written'] = False
    return report, changed_lines


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--apply', action='store_true', help='write changes (default: dry run)')
    args = ap.parse_args()
    base = Path(__file__).resolve().parents[2]  # ecardo/
    all_reports = []
    for rel, rules in RULES.items():
        rep, _ = process(base / rel, rules, args.apply)
        all_reports.append(rep)
        print(rep['file'])
        print('  lines:', rep['total_lines'], '| changed:', rep['changed_line_count'],
              '| written:', rep['written'])
        for k, v in rep['changes'].items():
            print(f'    {k}: {v} rows')
        if rep['kept_claims']:
            print('  kept (out of task scope):', rep['kept_claims'])
    if not args.apply:
        print('DRY RUN ONLY — no files written. Re-run with --apply to write.')
    else:
        print('APPLIED.')


if __name__ == '__main__':
    main()
