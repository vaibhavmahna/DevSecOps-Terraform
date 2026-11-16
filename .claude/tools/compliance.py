#!/usr/bin/env python3
"""Compliance commit gate: what is staged, and whether the compliance-reviewer passed it.

  compliance.py id       print the id of the staged changes (the reviewer quotes it in its verdict)
  compliance.py status   say whether the staged changes are covered by a recorded PASS
  compliance.py check    same as status, exit 1 when not covered (used by the optional git pre-commit hook)
  compliance.py note     print the compliance note from the last PASS (paste it into the PR description)

A PASS is recorded only by the guard_compliance.py hook, from the compliance-reviewer's own result. It stores
the blob id of every staged file. A commit is allowed when every file it would change is in that record with
the same blob id, so an edit made after the review needs a new review, and reviewed files can still be split
across several commits. State lives in .claude/state/, which agents cannot write.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import subprocess
import sys
import time
from typing import Dict, List, Optional, Tuple

PASS_FILE = "compliance-pass.json"
LOG_FILE = "compliance-log.jsonl"
NOTE_FILE = "compliance-note.md"
LOG_MAX_BYTES = 5 * 1024 * 1024  # retention: the current log plus one rotated file, about 10 MB of verdicts
Changes = Dict[str, Optional[str]]  # path -> staged blob id, None when the file is deleted


def _git(proj: str, *args: str) -> Tuple[int, str]:
    r = subprocess.run(["git", "-C", proj, *args], capture_output=True, encoding="utf-8", errors="replace",
                       timeout=20, env={**os.environ, "GIT_OPTIONAL_LOCKS": "0"})
    return r.returncode, r.stdout


def is_repo(proj: str) -> bool:
    try:
        rc, out = _git(proj, "rev-parse", "--is-inside-work-tree")
    except (OSError, subprocess.SubprocessError):
        return False
    return rc == 0 and out.strip() == "true"


def staged_changes(proj: str) -> Changes:
    """Every path the next `git commit` would change, with its staged blob id. Raises if git cannot say."""
    changes: Changes = {}
    rc, _ = _git(proj, "rev-parse", "--verify", "-q", "HEAD")
    if rc == 0:
        rc, out = _git(proj, "diff", "--cached", "--raw", "-z", "--no-renames", "--no-abbrev", "HEAD")
        if rc != 0:
            raise RuntimeError("git diff --cached failed")
        parts = out.split("\0")
        for i in range(0, len(parts) - 1, 2):
            meta = parts[i].split()  # :old_mode new_mode old_blob new_blob status
            if len(meta) >= 5:
                changes[parts[i + 1]] = None if meta[4].startswith("D") else meta[3]
    else:  # no commit yet: everything in the index is new
        rc, out = _git(proj, "ls-files", "-s", "-z")
        if rc != 0:
            raise RuntimeError("git ls-files failed")
        for entry in out.split("\0"):
            if "\t" in entry:
                meta, path = entry.split("\t", 1)
                changes[path] = meta.split()[1]
    return changes


def changes_id(changes: Changes) -> str:
    return hashlib.sha256(json.dumps(sorted(changes.items())).encode()).hexdigest()[:16]


def _state(proj: str, name: str) -> str:
    d = os.path.join(proj, ".claude", "state")
    os.makedirs(d, exist_ok=True)
    return os.path.join(d, name)


def load_pass(proj: str) -> Optional[dict]:
    try:
        with open(_state(proj, PASS_FILE), encoding="utf-8") as fh:
            rec = json.load(fh)
        return rec if isinstance(rec.get("changes"), dict) else None
    except (OSError, ValueError, AttributeError):
        return None


def log_event(proj: str, actor: str, action: str, target: str, outcome: str, **extra) -> None:
    """Append one audit line: actor, action, target, outcome, timestamp. Identifiers only, never file content."""
    rec = {"ts": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), "actor": actor, "action": action,
           "target": target, "outcome": outcome, **extra}
    path = _state(proj, LOG_FILE)
    try:
        if os.path.getsize(path) > LOG_MAX_BYTES:
            os.replace(path, path + ".1")  # keep one older file; anything before that is dropped
    except OSError:
        pass
    with open(path, "a", encoding="utf-8") as fh:
        fh.write(json.dumps(rec) + "\n")


def record_pass(proj: str, changes: Changes, actor: str, note: str = "") -> None:
    with open(_state(proj, PASS_FILE), "w", encoding="utf-8") as fh:
        json.dump({"id": changes_id(changes), "changes": changes, "actor": actor, "ts": int(time.time())}, fh)
    with open(_state(proj, NOTE_FILE), "w", encoding="utf-8") as fh:
        fh.write(note.strip() + "\n" if note.strip() else "")


def clear_pass(proj: str) -> None:
    for name in (PASS_FILE, NOTE_FILE):
        try:
            os.remove(_state(proj, name))
        except OSError:
            pass


def uncovered(proj: str) -> List[str]:
    """Staged paths that no recorded PASS covers. Empty means the commit may go ahead."""
    changes = staged_changes(proj)
    if not changes:
        return []
    reviewed = (load_pass(proj) or {}).get("changes", {})
    return sorted(p for p, blob in changes.items() if p not in reviewed or reviewed[p] != blob)


def commit_allowed(proj: str) -> Tuple[bool, str]:
    missing = uncovered(proj)
    if not missing:
        return True, "staged changes are covered by a compliance PASS"
    shown = ", ".join(missing[:8]) + (f" (+{len(missing) - 8} more)" if len(missing) > 8 else "")
    return False, f"no compliance PASS covers: {shown}"


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--root", default=os.environ.get("CLAUDE_PROJECT_DIR") or
                    os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")))
    ap.add_argument("cmd", choices=["id", "status", "check", "note"])
    a = ap.parse_args(argv)
    proj = a.root
    if a.cmd == "note":
        try:
            with open(_state(proj, NOTE_FILE), encoding="utf-8") as fh:
                text = fh.read().strip()
        except OSError:
            text = ""
        print(text or "no compliance note recorded; run the compliance-reviewer on the staged changes")
        return 0 if text else 1
    if not is_repo(proj):
        print("not a git repository")
        return 1
    try:
        if a.cmd == "id":
            changes = staged_changes(proj)
            print(changes_id(changes))
            print(f"{len(changes)} staged file(s)", file=sys.stderr)
            return 0
        ok, why = commit_allowed(proj)
    except (RuntimeError, OSError, subprocess.SubprocessError) as exc:
        print(f"BLOCKED: cannot read the staged changes ({exc})")
        return 1
    print(("PASS: " if ok else "BLOCKED: ") + why)
    if not ok:
        print("Run the compliance-reviewer agent on the staged changes, then commit.")
    return 0 if ok or a.cmd == "status" else 1


if __name__ == "__main__":
    sys.exit(main())
