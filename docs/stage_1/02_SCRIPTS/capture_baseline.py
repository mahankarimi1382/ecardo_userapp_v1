#!/usr/bin/env python3
"""Read-only baseline capture for a Flutter repository. Python standard library only.
Does not fetch, checkout, modify, build, test, release, or deploy anything.
"""
from __future__ import annotations
import argparse, json, re, subprocess, shutil
from pathlib import Path
from datetime import datetime, timezone

EXCLUDE = {'.git', '.dart_tool', 'build', 'Pods', 'DerivedData', 'node_modules', '.idea', '.vscode', 'coverage'}

def run(cmd: list[str], cwd: Path) -> dict:
    if not shutil.which(cmd[0]):
        return {"command": " ".join(cmd), "available": False, "exit_code": None, "stdout": "", "stderr": f"{cmd[0]} not found"}
    try:
        p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=20, check=False)
        return {"command": " ".join(cmd), "available": True, "exit_code": p.returncode,
                "stdout": p.stdout.strip()[:12000], "stderr": p.stderr.strip()[:3000]}
    except Exception as e:
        return {"command": " ".join(cmd), "available": True, "exit_code": None, "stdout": "", "stderr": str(e)}

def excluded(path: Path) -> bool:
    return any(part in EXCLUDE for part in path.parts)

def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--root', default='.', help='Flutter repository root')
    ap.add_argument('--out', default='/tmp/ecardo-baseline', help='Output directory; default is outside checkout')
    args = ap.parse_args()
    root = Path(args.root).resolve(); out = Path(args.out).resolve()
    if not root.is_dir():
        ap.error(f'Root directory does not exist: {root}')
    git = lambda *args: run(['git', *args], root)
    files = [p for p in root.rglob('*') if p.is_file() and not excluded(p.relative_to(root))]
    dart_files = [p for p in files if p.suffix == '.dart']
    test_files = [p for p in files if ('test' in p.relative_to(root).parts or 'integration_test' in p.relative_to(root).parts) and p.suffix == '.dart']
    pubspec = root / 'pubspec.yaml'
    version = None
    if pubspec.exists():
        m = re.search(r'^version:\s*([^\s#]+)', pubspec.read_text(encoding='utf-8', errors='replace'), re.M)
        version = m.group(1) if m else None
    meta = {
        'captured_at_utc': datetime.now(timezone.utc).isoformat(), 'root': str(root), 'output': str(out),
        'safety': 'READ_ONLY; no network, checkout, test, build, release, or deploy commands run',
        'pubspec_version': version, 'file_counts': {'all_files_excluding_build_caches': len(files), 'dart_files': len(dart_files), 'test_dart_files': len(test_files)},
        'git': {
            'inside_work_tree': git('rev-parse', '--is-inside-work-tree'),
            'branch': git('branch', '--show-current'), 'head_sha': git('rev-parse', 'HEAD'),
            'head_short': git('rev-parse', '--short=12', 'HEAD'), 'last_commit': git('log', '-1', '--format=%H%n%cI%n%s'),
            'status_short': git('status', '--short'), 'diff_stat': git('diff', '--stat'),
            'staged_diff_stat': git('diff', '--cached', '--stat'), 'nearest_tag': git('describe', '--tags', '--always', '--dirty'),
            'local_tags_recent': git('tag', '--sort=-creatordate'),
        },
        'tool_versions': {'flutter': run(['flutter', '--version'], root), 'dart': run(['dart', '--version'], root), 'python': run(['python3', '--version'], root)},
        'notes': [
            'This is a metadata baseline, not a source audit and not proof that tests pass.',
            'Git status and diffs may list pre-existing changes; preserve them and do not reset/stash/checkout.',
            'Remote state is deliberately not fetched; compare public remote/release evidence separately.',
            'No environment variables or secrets are read or emitted.'
        ]
    }
    out.mkdir(parents=True, exist_ok=True)
    (out/'BASELINE.json').write_text(json.dumps(meta, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    def result_text(v):
        if isinstance(v, dict):
            return f"command: `{v.get('command','')}`\n\n- Available: `{v.get('available')}`\n- Exit code: `{v.get('exit_code')}`\n```text\n{v.get('stdout','')}\n{v.get('stderr','')}\n```"
        return '```text\n'+str(v)+'\n```'
    lines = ['# Local repository baseline', '', f"Captured UTC: `{meta['captured_at_utc']}`", f"Repository root: `{root}`", f"Pubspec version: `{version or 'NOT_FOUND'}`", '', '## Counts', '', f"- Files scanned: {len(files)}", f"- Dart files: {len(dart_files)}", f"- Test/integration Dart files: {len(test_files)}", '', '## Git state', '']
    for key, value in meta['git'].items():
        lines += [f'### {key.replace("_", " ").title()}', '', result_text(value), '']
    lines += ['## Tool versions', '']
    for key, value in meta['tool_versions'].items():
        lines += [f'### {key}', '', result_text(value), '']
    lines += ['## Limits', ''] + [f'- {x}' for x in meta['notes']]
    (out/'BASELINE.md').write_text('\n'.join(lines)+'\n', encoding='utf-8')
    print(json.dumps({'output':str(out),'pubspec_version':version,'file_counts':meta['file_counts'],'head_short':meta['git']['head_short'].get('stdout'),'status_exit':meta['git']['status_short'].get('exit_code')},ensure_ascii=False,indent=2))
    return 0
if __name__ == '__main__':
    raise SystemExit(main())
