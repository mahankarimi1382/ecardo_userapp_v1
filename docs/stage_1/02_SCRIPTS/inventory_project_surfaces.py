#!/usr/bin/env python3
"""Read-only inventory of Flutter project surfaces: files, ARB keys, tests, assets and CI workflow triggers."""
from __future__ import annotations
import argparse, csv, json, re
from pathlib import Path
from collections import Counter

SKIP={'.git','.dart_tool','build','Pods','DerivedData','node_modules','.idea','.vscode','coverage'}

def in_skip(p: Path) -> bool: return any(x in SKIP for x in p.parts)
def write_csv(path: Path, headers, rows):
    path.parent.mkdir(parents=True,exist_ok=True)
    with path.open('w',newline='',encoding='utf-8-sig') as f:
        w=csv.writer(f);w.writerow(headers);w.writerows(rows)

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--root',default='.')
    ap.add_argument('--out',default='/tmp/ecardo-project-surfaces')
    args=ap.parse_args(); root=Path(args.root).resolve(); out=Path(args.out).resolve()
    if not root.is_dir(): ap.error(f'Not a directory: {root}')
    all_files=sorted(p for p in root.rglob('*') if p.is_file() and not in_skip(p.relative_to(root)))
    ext_counter=Counter((p.suffix.lower() or '<no_extension>') for p in all_files)
    file_rows=[[p.relative_to(root).as_posix(),p.suffix.lower() or '<no_extension>',p.stat().st_size] for p in all_files]
    test_rows=[]; asset_rows=[]; arb_rows=[]; workflow_rows=[]; manifest_rows=[]
    for p in all_files:
        rel=p.relative_to(root).as_posix()
        low=rel.lower()
        if p.suffix=='.dart' and ('test' in p.relative_to(root).parts or 'integration_test' in p.relative_to(root).parts or low.endswith('_test.dart')):
            test_rows.append([rel, p.stat().st_size, 'DISCOVERED_NOT_EXECUTED'])
        if rel.startswith('assets/') or '/assets/' in rel:
            asset_rows.append([rel,p.suffix.lower(),p.stat().st_size])
        if p.suffix.lower()=='.arb' and ('l10n' in low or 'local' in low):
            try: raw=json.loads(p.read_text(encoding='utf-8'))
            except Exception as e: arb_rows.append([rel,'PARSE_ERROR','',str(e)]); continue
            keys=[k for k in raw.keys() if not k.startswith('@')]
            arb_rows.append([rel,'OK',len(keys),';'.join(keys[:8])])
        if '.github/workflows/' in low and p.suffix.lower() in {'.yml','.yaml'}:
            # Deliberately only surface trigger declarations; never print full workflow or secret values.
            try: lines=p.read_text(encoding='utf-8',errors='replace').splitlines()
            except Exception: lines=[]
            in_on=False; triggers=[]; event_names=[]
            for ix,line in enumerate(lines):
                if re.match(r'^on\s*:',line): in_on=True; triggers.append('on')
                elif in_on and line and not line[0].isspace() and not line.lstrip().startswith('#'): in_on=False
                if in_on:
                    m=re.match(r'^\s{2,}([A-Za-z_][A-Za-z0-9_-]*)\s*:',line)
                    if m: event_names.append(m.group(1))
            workflow_rows.append([rel,';'.join(sorted(set(event_names))) or 'TRIGGER_SHAPE_REQUIRES_MANUAL_REVIEW','REVIEW_WORKFLOW_SIDE_EFFECTS'])
        if p.name in {'AndroidManifest.xml','Info.plist','firebase.json','pubspec.yaml','l10n.yaml'} or (p.name=='strings.xml' and 'android' in low):
            try: raw=p.read_text(encoding='utf-8',errors='replace')
            except Exception: raw=''
            # Record only category flags, not raw manifest contents or secrets.
            flags=[]
            for label,pat in [('deep_link',r'VIEW|android:scheme|CFBundleURLSchemes|universal_links|applinks'),('notification',r'NOTIFICATION|firebase_messaging|remote-notification'),('camera_qr',r'CAMERA|mobile_scanner|qr|barcode'),('permissions',r'uses-permission|NS[A-Za-z]+UsageDescription')]:
                if re.search(pat,raw,re.I): flags.append(label)
            manifest_rows.append([rel,p.name,';'.join(flags) or 'NO_KNOWN_PATTERN_MATCH_REVIEW_REQUIRED'])
    out.mkdir(parents=True,exist_ok=True)
    write_csv(out/'PROJECT_FILE_INVENTORY.csv',['relative_path','extension','bytes'],file_rows)
    write_csv(out/'TEST_FILE_INVENTORY.csv',['relative_path','bytes','execution_status'],test_rows)
    write_csv(out/'ASSET_INVENTORY.csv',['relative_path','extension','bytes'],asset_rows)
    write_csv(out/'LOCALIZATION_ARB_INVENTORY.csv',['relative_path','parse_status','translation_key_count','sample_keys_or_error'],arb_rows)
    write_csv(out/'WORKFLOW_TRIGGER_INVENTORY.csv',['workflow_file','possible_events','review_status'],workflow_rows)
    write_csv(out/'PLATFORM_AND_CONFIG_SURFACES.csv',['relative_path','filename','pattern_flags'],manifest_rows)
    report={'root':str(root),'output':str(out),'file_count':len(all_files),'extension_counts':dict(sorted(ext_counter.items())),
      'dart_file_count':ext_counter.get('.dart',0),'test_file_count':len(test_rows),'asset_file_count':len(asset_rows),'arb_file_count':len(arb_rows),'workflow_file_count':len(workflow_rows),'manifest_config_file_count':len(manifest_rows),
      'limitations':['File and keyword inventory only; no Dart AST analysis.','No tests, builds, or app runtime are executed.','Workflow trigger extraction is heuristic; inspect each workflow manually before any CI action.','ARB key counts are not proof that translations are complete or semantically accurate.','Asset references/usages need a separate cross-reference pass.']}
    (out/'PROJECT_SURFACE_REPORT.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(report,ensure_ascii=False,indent=2)); return 0
if __name__=='__main__': raise SystemExit(main())
