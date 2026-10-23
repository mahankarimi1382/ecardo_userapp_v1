#!/usr/bin/env python3
"""Build a screen-upgrade registry from the actual Stage 1 route catalog.
This script copies source columns and appends workflow fields; it does not prove route completeness.
"""
import argparse, csv, sys
from pathlib import Path

ALIASES = {
 'screen_id': ['screen_id','route_id','id','stable_id','route_key'],
 'route_name': ['route_name','route','name','title','screen_name','path'],
 'source_file': ['source_file','file','source_path','dart_file','page_file'],
 'discovery_status': ['discovery_status','status','verification_status'],
}
EXTRA_FIELDS = [
 'scope_decision','scope_reason','flow_ids','design_spec_ref','ui_status','behavior_status',
 'state_coverage_status','accessibility_status','localization_status','responsive_status',
 'test_status','before_screenshot','after_screenshot','evidence_refs','owner','priority',
 'blocker','reviewer','updated_at','notes'
]


def read_csv(path):
    with path.open('r', encoding='utf-8-sig', newline='') as f:
        sample = f.read(4096); f.seek(0)
        try: dialect = csv.Sniffer().sniff(sample, delimiters=',;\t')
        except csv.Error: dialect = csv.excel
        reader = csv.DictReader(f, dialect=dialect)
        if not reader.fieldnames:
            raise ValueError('Input CSV has no header row')
        return [x.strip() for x in reader.fieldnames], list(reader)


def resolve(fields, kind):
    low = {f.lower().strip(): f for f in fields}
    for alias in ALIASES[kind]:
        if alias in low: return low[alias]
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--input', required=True, help='Actual Stage 1 route catalog CSV')
    ap.add_argument('--output', required=True, help='Output screen-upgrade registry CSV')
    args = ap.parse_args()
    inp, out = Path(args.input), Path(args.output)
    if not inp.is_file():
        print(f'ERROR: route catalog not found: {inp}', file=sys.stderr); return 2
    try: fields, rows = read_csv(inp)
    except Exception as e:
        print(f'ERROR: {e}', file=sys.stderr); return 2
    id_field = resolve(fields, 'screen_id')
    name_field = resolve(fields, 'route_name')
    if not id_field or not name_field:
        print('ERROR: could not identify screen/route ID and route name/path columns.', file=sys.stderr)
        print('Available headers: ' + ', '.join(fields), file=sys.stderr)
        print('Rename columns or enhance ALIASES in this script; do not fabricate identifiers.', file=sys.stderr)
        return 2
    out.parent.mkdir(parents=True, exist_ok=True)
    out_fields = fields + [x for x in ['screen_id', 'route_name'] + EXTRA_FIELDS if x not in fields]
    seen = set()
    with out.open('w', encoding='utf-8-sig', newline='') as f:
        w = csv.DictWriter(f, fieldnames=out_fields); w.writeheader()
        for i, src in enumerate(rows, 1):
            row = dict(src)
            sid = (src.get(id_field) or '').strip()
            name = (src.get(name_field) or '').strip()
            if not sid: sid = f'REVIEW-MISSING-ID-{i:04d}'
            if sid in seen: sid = f'{sid}-DUPLICATE-{i:04d}'
            seen.add(sid)
            row['screen_id'] = sid
            row['route_name'] = name
            row.setdefault('scope_decision', 'PENDING_REVIEW')
            row.setdefault('ui_status', 'NOT_STARTED')
            row.setdefault('behavior_status', 'NOT_STARTED')
            row.setdefault('state_coverage_status', 'NOT_STARTED')
            row.setdefault('accessibility_status', 'NOT_STARTED')
            row.setdefault('localization_status', 'NOT_STARTED')
            row.setdefault('responsive_status', 'NOT_STARTED')
            row.setdefault('test_status', 'NOT_RUN')
            row.setdefault('evidence_refs', '')
            row.setdefault('notes', 'Generated from Stage 1 inventory; revalidate against source/runtime.')
            w.writerow(row)
    print(f'Generated {len(rows)} rows at {out}')
    print('WARNING: generated rows are not proof of complete discovery or implementation.')
    return 0

if __name__ == '__main__': raise SystemExit(main())
