#!/usr/bin/env python3
import hashlib
import json
import os
import stat
from dataclasses import dataclass, asdict
from typing import Dict, List, Optional, Tuple


SCAN_DIRS = [
    ".",  # repo root
    "data-transformation-scripts",
]
INCLUDE_EXT = {".sh", ".py"}
EXCLUDE_DIRS = {".git", ".venv", "node_modules", "__pycache__"}


@dataclass
class ScriptInfo:
    path: str
    name: str
    extension: str
    size_bytes: int
    is_executable: bool
    has_shebang: bool
    sha1: str
    first_line: Optional[str]
    duplicate_of: Optional[str]


def is_executable_file(path: str) -> bool:
    try:
        st = os.stat(path)
        return bool(st.st_mode & stat.S_IXUSR)
    except Exception:
        return False


def compute_sha1(path: str) -> str:
    h = hashlib.sha1()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def scan_scripts(repo_root: str) -> List[ScriptInfo]:
    results: List[ScriptInfo] = []
    for rel in SCAN_DIRS:
        base = os.path.join(repo_root, rel)
        if not os.path.exists(base):
            continue
        for root, dirs, files in os.walk(base):
            # Filter excluded directories
            dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
            for fn in files:
                ext = os.path.splitext(fn)[1].lower()
                if ext not in INCLUDE_EXT:
                    continue
                path = os.path.join(root, fn)
                try:
                    size = os.path.getsize(path)
                    sha1 = compute_sha1(path)
                    with open(path, "r", encoding="utf-8", errors="replace") as f:
                        first_line = f.readline().rstrip("\n")
                    has_shebang = first_line.startswith("#!")
                    results.append(
                        ScriptInfo(
                            path=os.path.relpath(path, repo_root),
                            name=fn,
                            extension=ext,
                            size_bytes=size,
                            is_executable=is_executable_file(path),
                            has_shebang=has_shebang,
                            sha1=sha1,
                            first_line=first_line if first_line else None,
                            duplicate_of=None,
                        )
                    )
                except Exception:
                    continue
    # Mark duplicates by sha1
    sha_to_first: Dict[str, str] = {}
    for s in results:
        if s.sha1 in sha_to_first:
            s.duplicate_of = sha_to_first[s.sha1]
        else:
            sha_to_first[s.sha1] = s.path
    return results


def write_outputs(repo_root: str, scripts: List[ScriptInfo]) -> None:
    # JSON manifest
    out_json = os.path.join(repo_root, "scripts", "SCRIPTS_MANIFEST.json")
    os.makedirs(os.path.dirname(out_json), exist_ok=True)
    with open(out_json, "w", encoding="utf-8") as f:
        json.dump(
            {
                "total": len(scripts),
                "duplicates": sum(1 for s in scripts if s.duplicate_of),
                "scripts": [asdict(s) for s in scripts],
            },
            f,
            indent=2,
            ensure_ascii=False,
        )
    # Markdown report
    out_md = os.path.join(repo_root, "WORKSPACE_MANIFEST.md")
    lines: List[str] = []
    lines.append("## Workspace Scripts Manifest")
    lines.append("")
    lines.append(f"- Total scripts: {len(scripts)}")
    dup_count = sum(1 for s in scripts if s.duplicate_of)
    lines.append(f"- Duplicates (exact content): {dup_count}")
    lines.append("")
    lines.append("| Path | Exec | Shebang | Size | Duplicate Of |")
    lines.append("|---|:---:|:---:|---:|---|")
    for s in sorted(scripts, key=lambda x: (x.path, x.name)):
        exec_flag = "✓" if s.is_executable else " "
        sb_flag = "✓" if s.has_shebang else " "
        lines.append(f"| `{s.path}` | {exec_flag} | {sb_flag} | {s.size_bytes} | `{s.duplicate_of or ''}` |")
    with open(out_md, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


def main() -> int:
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    scripts = scan_scripts(repo_root)
    write_outputs(repo_root, scripts)
    print(f"Wrote scripts manifest for {len(scripts)} files.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())


