#!/usr/bin/env python3
"""Validate evidence discipline in a Stage 3 screen registry; not a UI correctness oracle."""
import argparse, csv, sys
from pathlib import Path

DONE = {'DONE','PASS','COMPLETED','VERIFIED'}
REQUIRED_ON_DONE = ['evidence_refs','owner']
REQUIRED_STATUSES = ['ui_status','behavior_status','state_coverage_status','accessibility_status','localization_status','responsive_status','test_status']

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--registry', required=True)
    ap.add_argument('--strict', action='store_true', help='Non-done rows are allowed but missing columns/false completion are errors')
    args = ap.parse_args()
    path = Path(args.registry)
    if not path.is_file(): print(f'ERROR: not found: {path}'); return 2
    with path.open('r', encoding='utf-8-sig', newline='') as f:
        reader = csv.DictReader(f); fields = reader.fieldnames or []; rows = list(reader)
    if not rows: print('ERROR: registry has no rows'); return 2
    missing = [x for x in ['screen_id','route_name'] + REQUIRED_STATUSES if x not in fields]
    if missing:
        print('ERROR: missing required columns: ' + ', '.join(missing)); return 2
    errors=[]; warnings=[]
    for n, row in enumerate(rows, 2):
        sid = row.get('screen_id','').strip() or f'line {n}'
        all_done = all((row.get(c,'').strip().upper() in DONE for c in REQUIRED_STATUSES))
        scope=(row.get('scope_decision','').strip().upper())
        if scope == 'OUT_OF_SCOPE' and not row.get('scope_reason','').strip():
            errors.append(f'{sid}: OUT_OF_SCOPE has no scope_reason')
        if all_done:
            for col in REQUIRED_ON_DONE:
                if not row.get(col,'').strip(): errors.append(f'{sid}: all statuses are done but {col} is empty')
            if not row.get('test_status','').strip().upper() in {'PASS','DONE','COMPLETED','VERIFIED'}:
                errors.append(f'{sid}: completed screen does not have a passing test status')
        if row.get('test_status','').strip().upper() in DONE and not row.get('evidence_refs','').strip():
            errors.append(f'{sid}: completed test status lacks evidence_refs')
        if scope not in {'IN_SCOPE','OUT_OF_SCOPE','BLOCKED','PENDING_REVIEW',''}:
            warnings.append(f'{sid}: unrecognized scope_decision={scope}')
    print(f'Rows: {len(rows)} | Errors: {len(errors)} | Warnings: {len(warnings)}')
    for x in errors: print('ERROR:',x)
    for x in warnings: print('WARN:',x)
    if not errors: print('PASS: no evidence-discipline violations found (does not prove actual visual or functional correctness).')
    return 1 if errors else 0
if __name__ == '__main__': raise SystemExit(main())
