#!/usr/bin/env python3
"""Validate eCardo route/catalog coverage fields without claiming runtime completeness."""
from __future__ import annotations
import argparse, csv, json
from pathlib import Path

ROUTE_REQUIRED = ['route_id','module','route_name','source_file','source_mapping_status','runtime_status','implementation_status','test_status','evidence_ref']
ALLOWED = {
 'source_mapping_status': {'UNKNOWN','CANDIDATE','SOURCE_MAPPED','NOT_APPLICABLE','BLOCKED'},
 'runtime_status': {'UNKNOWN','NOT_RUN','RUNTIME_VERIFIED','RUNTIME_FAILED','BLOCKED','NOT_APPLICABLE'},
 'implementation_status': {'UNKNOWN','NOT_ASSESSED','NEEDS_WORK','IN_PROGRESS','UPGRADED','DEPRECATED','BLOCKED'},
 'test_status': {'UNKNOWN','NOT_RUN','PASS','FAIL','BLOCKED','NOT_APPLICABLE'},
}

def load_csv(p: Path):
    with p.open(newline='',encoding='utf-8-sig') as f:
        reader=csv.DictReader(f)
        return list(reader), list(reader.fieldnames or [])

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--routes', required=True, help='ROUTE_CATALOG.csv')
    ap.add_argument('--out', default='app-map-validation.json')
    args=ap.parse_args()
    route_path=Path(args.routes).resolve()
    if not route_path.exists(): ap.error(f'Not found: {route_path}')
    rows, headers=load_csv(route_path)
    errors=[]; warnings=[]
    missing=[x for x in ROUTE_REQUIRED if x not in headers]
    if missing: errors.append({'kind':'MISSING_COLUMNS','columns':missing})
    if not rows: errors.append({'kind':'EMPTY_ROUTE_CATALOG','message':'Empty catalog cannot be accepted as discovery output'})
    ids={}; names={}
    for i,r in enumerate(rows, start=2):
        rid=(r.get('route_id') or '').strip(); name=(r.get('route_name') or '').strip()
        if not rid: errors.append({'kind':'EMPTY_ROUTE_ID','line':i})
        elif rid in ids: errors.append({'kind':'DUPLICATE_ROUTE_ID','route_id':rid,'lines':[ids[rid],i]})
        else: ids[rid]=i
        if name:
            key=((r.get('route_pattern') or '').strip(), name)
            names.setdefault(key,[]).append(i)
        for col, allowed in ALLOWED.items():
            v=(r.get(col) or '').strip()
            if v not in allowed:
                errors.append({'kind':'INVALID_STATUS','line':i,'column':col,'value':v,'allowed':sorted(allowed)})
        if (r.get('source_mapping_status') or '').strip()=='SOURCE_MAPPED' and not (r.get('source_file') or '').strip():
            errors.append({'kind':'SOURCE_MAPPED_WITHOUT_SOURCE_FILE','line':i,'route_id':rid})
        if (r.get('runtime_status') or '').strip()=='RUNTIME_VERIFIED' and not (r.get('evidence_ref') or '').strip():
            errors.append({'kind':'RUNTIME_VERIFIED_WITHOUT_EVIDENCE','line':i,'route_id':rid})
        if (r.get('test_status') or '').strip()=='PASS' and not (r.get('test_ref') or '').strip():
            warnings.append({'kind':'TEST_PASS_WITHOUT_TEST_REF','line':i,'route_id':rid})
        if not (r.get('source_file') or '').strip(): warnings.append({'kind':'MISSING_SOURCE_FILE','line':i,'route_id':rid})
    for key, lines in names.items():
        if len(lines)>1: warnings.append({'kind':'DUPLICATE_ROUTE_NAME_OR_PATTERN_REVIEW','key':key,'lines':lines})
    counts={}
    for col in ALLOWED:
        counts[col]={}
        for r in rows:
            val=(r.get(col) or '').strip() or '<EMPTY>'
            counts[col][val]=counts[col].get(val,0)+1
    report={'route_catalog':str(route_path),'row_count':len(rows),'validation':'FAIL' if errors else ('PASS_WITH_WARNINGS' if warnings else 'PASS'),'errors':errors,'warnings':warnings,'status_counts':counts,
      'honesty_note':'A valid catalog proves schema consistency only. It does not prove that all screens/routes have been discovered or runtime-tested.'}
    out=Path(args.out).resolve(); out.parent.mkdir(parents=True,exist_ok=True); out.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'validation':report['validation'],'rows':len(rows),'errors':len(errors),'warnings':len(warnings),'output':str(out)},ensure_ascii=False,indent=2))
    return 1 if errors else 0
if __name__=='__main__': raise SystemExit(main())
