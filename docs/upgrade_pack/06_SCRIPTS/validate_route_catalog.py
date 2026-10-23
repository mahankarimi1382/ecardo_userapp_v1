#!/usr/bin/env python3
"""Validate that a populated route catalog has no duplicate IDs or empty statuses.
Does not decide whether the inventory itself is complete; discovery reconciliation is still required.
"""
from pathlib import Path
import argparse, csv, sys
VALID = {'DISCOVERED','SOURCE_MAPPED','RUNTIME_VERIFIED','UPGRADED','REGRESSION_TESTED','BLOCKED','DEFERRED','DEPRECATED','COMPLETE'}
def main():
    ap=argparse.ArgumentParser(); ap.add_argument('csv_path', help='ROUTE_CATALOG.csv'); ap.add_argument('--strict',action='store_true', help='fail if any row is not COMPLETE/RUNTIME_VERIFIED/REGRESSION_TESTED or has missing core evidence')
    a=ap.parse_args(); p=Path(a.csv_path)
    if not p.exists(): print(f'ERROR: missing file: {p}',file=sys.stderr); return 2
    with p.open(newline='',encoding='utf-8-sig') as f:
        r=csv.DictReader(f); rows=list(r); fields=set(r.fieldnames or [])
    required={'route_id','screen_name','source_file','runtime_status','upgrade_status','owner'}
    missing=required-fields
    if missing: print('ERROR: missing columns: '+', '.join(sorted(missing)),file=sys.stderr); return 2
    errors=[]; seen=set()
    for i,row in enumerate(rows,start=2):
        rid=(row.get('route_id') or '').strip()
        if not rid: errors.append(f'row {i}: empty route_id')
        elif rid in seen: errors.append(f'row {i}: duplicate route_id {rid}')
        seen.add(rid)
        for fld in ('screen_name','source_file','owner'):
            if not (row.get(fld) or '').strip(): errors.append(f'row {i}: empty {fld}')
        for fld in ('runtime_status','upgrade_status'):
            val=(row.get(fld) or '').strip().upper()
            if val not in VALID: errors.append(f'row {i}: invalid/empty {fld}={val!r}; use one of {sorted(VALID)}')
        if a.strict:
            evidence=(row.get('screenshot_after') or '').strip()
            tests=(row.get('test_ids') or '').strip()
            if (row.get('upgrade_status') or '').upper() in {'UPGRADED','COMPLETE','REGRESSION_TESTED'} and not evidence:
                errors.append(f'row {i}: upgraded route has no screenshot_after evidence')
            if (row.get('upgrade_status') or '').upper() in {'COMPLETE','REGRESSION_TESTED'} and not tests:
                errors.append(f'row {i}: complete route has no test_ids')
    if errors:
        print('\n'.join(errors)); print(f'FAIL: {len(errors)} issue(s), {len(rows)} catalog rows'); return 1
    if not rows:
        print('WARN: catalog is empty; validation proves only CSV structure, not coverage.')
    else: print(f'PASS: {len(rows)} catalog rows, unique IDs and valid statuses. This does not prove inventory completeness.')
    return 0
if __name__=='__main__': raise SystemExit(main())
