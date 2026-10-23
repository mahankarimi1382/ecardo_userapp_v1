#!/usr/bin/env python3
"""Best-effort static inventory scanner for Flutter/Dart projects.

It produces candidates, not a proof of complete runtime route discovery. Review
its output against router configuration, dynamic navigation, platform/deep links,
overlays, tabs and actual runtime journeys.
Standard library only; intended for Python 3.10+.
"""
from __future__ import annotations
import argparse, csv, json, re, sys
from pathlib import Path

EXCLUDED_PARTS = {'.git','.dart_tool','build','.idea','.vscode','Pods','DerivedData','node_modules','coverage','graphify-out'}
ROUTE_DECL_RE = re.compile(r"\bGetPage\s*(?:<[^>]+>)?\s*\(", re.M)
ROUTE_NAME_RE = re.compile(r"\bname\s*:\s*(['\"])(.*?)\1", re.S)
ROUTE_PAGE_RE = re.compile(r"\bpage\s*:\s*\(\s*\)\s*=>\s*([A-Za-z_]\w*)", re.S)
NAV_RE = re.compile(r"\b(Get\.(?:toNamed|offNamed|offAllNamed|to|off|offAll|back)|Navigator\.(?:push|pushNamed|pushReplacement|pop|maybePop)|(?:context\.)?(?:go|push|pushReplacementNamed)|pushNamed)\s*(?:<[^>]+>)?\s*\(")
CLASS_RE = re.compile(r"\bclass\s+([A-Za-z_]\w*)\s+(?:extends|implements|with)\s+([^\{]+)\{", re.S)
HTTP_RE = re.compile(r"\b(?:dio|_dio|client|httpClient|apiClient)\s*\.\s*(get|post|put|patch|delete|request)\s*\(\s*(['\"])(.{1,240}?)\2", re.S|re.I)
STRING_ROUTE_RE = re.compile(r"['\"](/[A-Za-z0-9_{}:/?=&.%-]+)['\"]")

def excluded(path: Path) -> bool:
    return any(p in EXCLUDED_PARTS for p in path.parts)

def line_no(text: str, pos: int) -> int:
    return text.count('\n', 0, pos) + 1

def snippet(text: str, pos: int, width: int = 180) -> str:
    line = text.rfind('\n', 0, pos) + 1
    end = text.find('\n', pos)
    if end < 0: end = len(text)
    s = text[line:min(end, line+width)].strip()
    return re.sub(r'\s+', ' ', s)

def write_rows(path: Path, headers, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('w', newline='', encoding='utf-8-sig') as f:
        w=csv.writer(f); w.writerow(headers); w.writerows(rows)

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--root', default='.', help='Flutter repo root')
    ap.add_argument('--out', default='docs/app-map/generated', help='Output directory (relative to cwd unless absolute)')
    args=ap.parse_args()
    root=Path(args.root).resolve(); out=Path(args.out).resolve()
    if not root.exists() or not root.is_dir():
        print(f'ERROR: root is not a directory: {root}', file=sys.stderr); return 2
    dart_files=sorted(p for p in root.rglob('*.dart') if not excluded(p.relative_to(root)))
    route_rows=[]; nav_rows=[]; symbol_rows=[]; http_rows=[]; string_rows=[]
    for p in dart_files:
        rel=p.relative_to(root).as_posix()
        try: text=p.read_text(encoding='utf-8', errors='replace')
        except Exception as exc:
            print(f'WARN: cannot read {rel}: {exc}', file=sys.stderr); continue
        # Each declaration scan is bounded to avoid accidentally capturing the next route.
        matches=list(ROUTE_DECL_RE.finditer(text))
        for i,m in enumerate(matches):
            end=matches[i+1].start() if i+1<len(matches) else min(len(text),m.start()+3000)
            block=text[m.start():min(end,m.start()+3000)]
            nr=ROUTE_NAME_RE.search(block); pr=ROUTE_PAGE_RE.search(block)
            route_name=nr.group(2) if nr else ''
            page_class=pr.group(1) if pr else ''
            route_rows.append([rel,line_no(text,m.start()),route_name,page_class,'GetPage declaration',snippet(text,m.start()),'REVIEW_REQUIRED'])
        for m in NAV_RE.finditer(text):
            window=text[m.start():min(len(text),m.start()+500)]
            # The following literal route is only a candidate; dynamic variables won't resolve here.
            literal=STRING_ROUTE_RE.search(window)
            nav_rows.append([rel,line_no(text,m.start()),m.group(1),literal.group(1) if literal else '',snippet(text,m.start()),'REVIEW_REQUIRED'])
        for m in CLASS_RE.finditer(text):
            name=m.group(1); parents=re.sub(r'\s+',' ',m.group(2)).strip()
            joined=(name+' '+parents).lower()
            kinds=[]
            if any(x in joined for x in ['statelesswidget','statefulwidget','getview','getwidget','consumerwidget','hookwidget','page','screen']): kinds.append('SCREEN_OR_WIDGET_CANDIDATE')
            if any(x in joined for x in ['getxcontroller','controller','bloc','cubit','notifier','viewmodel']): kinds.append('STATE_OWNER_CANDIDATE')
            if any(x in name.lower() for x in ['service','repository','datasource','client','api']): kinds.append('DATA_OR_SERVICE_CANDIDATE')
            if any(x in name.lower() for x in ['model','dto','entity','response','request']): kinds.append('DATA_MODEL_CANDIDATE')
            if kinds: symbol_rows.append([rel,line_no(text,m.start()),name,parents,';'.join(kinds),snippet(text,m.start()),'REVIEW_REQUIRED'])
        for m in HTTP_RE.finditer(text):
            http_rows.append([rel,line_no(text,m.start()),m.group(1).upper(),m.group(3).strip(),snippet(text,m.start()),'ENDPOINT_CANDIDATE_REQUIRES_CONTRACT_REVIEW'])
        # Literal path candidates can surface route names not captured by GetPage.
        for m in STRING_ROUTE_RE.finditer(text):
            value=m.group(1)
            if len(value)>1 and not any(x[0]==rel and x[1]==line_no(text,m.start()) and x[2]==value for x in string_rows):
                string_rows.append([rel,line_no(text,m.start()),value,snippet(text,m.start()),'STRING_CANDIDATE_NOT_CONFIRMED_ROUTE'])
    out.mkdir(parents=True, exist_ok=True)
    write_rows(out/'GETPAGE_ROUTE_CANDIDATES.csv',['source_file','line','route_name','target_widget_class','detection','context','review_status'],route_rows)
    write_rows(out/'NAVIGATION_CALL_CANDIDATES.csv',['source_file','line','call','literal_path_candidate','context','review_status'],nav_rows)
    write_rows(out/'DART_SYMBOL_CANDIDATES.csv',['source_file','line','symbol','parent_types','candidate_kinds','context','review_status'],symbol_rows)
    write_rows(out/'HTTP_ENDPOINT_CANDIDATES.csv',['source_file','line','http_method_candidate','path_or_url_literal','context','review_status'],http_rows)
    write_rows(out/'ROUTE_STRING_CANDIDATES.csv',['source_file','line','string_candidate','context','review_status'],string_rows)
    # Report file counts and explicit scanner limitations.
    report={
      'root':str(root),'output':str(out),'dart_file_count':len(dart_files),
      'getpage_route_candidates':len(route_rows),'navigation_call_candidates':len(nav_rows),
      'dart_symbol_candidates':len(symbol_rows),'http_endpoint_candidates':len(http_rows),
      'route_string_candidates':len(string_rows),
      'limitations':['Regex-based, not a Dart AST or route registry integration.','Dynamic routes/variables, generated navigation, runtime feature gates and native deep links need manual/runtime reconciliation.','Class name heuristics can miss or over-report screen/service types.','HTTP path detection only catches selected literal patterns.','These counts are not app coverage percentages.']
    }
    (out/'SCAN_REPORT.json').write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding='utf-8')
    md=['# Flutter source scan — candidate inventory','',f"- Root: `{root}`",f"- Dart files scanned: **{len(dart_files)}**",f"- GetPage candidates: **{len(route_rows)}**",f"- Navigation calls: **{len(nav_rows)}**",f"- Symbols: **{len(symbol_rows)}**",f"- HTTP endpoint candidates: **{len(http_rows)}**",f"- Route-like strings: **{len(string_rows)}**",'', '## Important: not a completeness proof','', *[f'- {x}' for x in report['limitations']], '', '## Output CSVs','', '- `GETPAGE_ROUTE_CANDIDATES.csv`', '- `NAVIGATION_CALL_CANDIDATES.csv`', '- `DART_SYMBOL_CANDIDATES.csv`', '- `HTTP_ENDPOINT_CANDIDATES.csv`', '- `ROUTE_STRING_CANDIDATES.csv`', '','Compare these outputs against the actual route table, platform manifests, dynamic feature gates, runtime navigation and test inventory.']
    (out/'SCAN_REPORT.md').write_text('\n'.join(md)+'\n',encoding='utf-8')
    print(json.dumps(report,ensure_ascii=False,indent=2))
    return 0
if __name__=='__main__': raise SystemExit(main())
