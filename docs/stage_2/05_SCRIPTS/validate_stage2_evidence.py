#!/usr/bin/env python3
"""Validate evidence hygiene for the eCardo Stage 2 CSV registers.
This checks structure and PASS/evidence consistency; it does not prove correctness of code or tests."""
import csv, sys
from pathlib import Path
ROOT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path('.')
CAT = ROOT / 'docs' / 'integration'
FILES = {
  'CONTRACT_REGISTRY.csv': ['contract_id','status','evidence_ref'],
  'ISSUE_REGISTER.csv': ['issue_id','priority','status','evidence'],
  'TEST_EVIDENCE.csv': ['evidence_id','result','artifact_or_log_path','sha','exit_code'],
}
errors=[]; warnings=[]
for name, required in FILES.items():
    p=CAT/name
    if not p.exists():
        warnings.append(f'MISSING: {p} (expected until stage 2 work creates it)')
        continue
    with p.open(newline='',encoding='utf-8-sig') as f:
        reader=csv.DictReader(f)
        missing=[c for c in required if c not in (reader.fieldnames or [])]
        if missing:
            errors.append(f'{name}: missing columns {missing}'); continue
        rows=list(reader)
    if name=='CONTRACT_REGISTRY.csv':
        for i,r in enumerate(rows,2):
            if (r.get('status') or '').upper()=='CONFIRMED' and not (r.get('evidence_ref') or '').strip():
                errors.append(f'{name}:{i}: CONFIRMED contract lacks evidence_ref')
    if name=='ISSUE_REGISTER.csv':
        for i,r in enumerate(rows,2):
            if (r.get('status') or '').upper() in {'RESOLVED','CLOSED','PASS'} and not (r.get('evidence') or '').strip():
                errors.append(f'{name}:{i}: closed/resolved issue lacks evidence')
            if (r.get('priority') or '').upper() not in {'P0','P1','P2','P3','INFO','UNKNOWN'}:
                warnings.append(f'{name}:{i}: unusual priority {r.get("priority")}')
    if name=='TEST_EVIDENCE.csv':
        for i,r in enumerate(rows,2):
            if (r.get('result') or '').upper()=='PASS':
                for c in ['artifact_or_log_path','sha','exit_code']:
                    if not (r.get(c) or '').strip(): errors.append(f'{name}:{i}: PASS lacks {c}')
                if (r.get('exit_code') or '').strip() not in {'0','0.0'}:
                    errors.append(f'{name}:{i}: PASS requires exit_code 0')
print(f'Root: {ROOT.resolve()}')
for w in warnings: print('WARNING:',w)
for e in errors: print('ERROR:',e)
if errors:
    print(f'FAIL: {len(errors)} error(s), {len(warnings)} warning(s)')
    sys.exit(1)
print(f'PASS: no evidence-schema violations detected; {len(warnings)} warning(s)')
print('NOTE: schema validation is not proof that code, business rules, or tests are correct.')
