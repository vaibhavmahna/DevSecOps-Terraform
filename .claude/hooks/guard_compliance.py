#!/usr/bin/env python3
"""PostToolUse Agent|Task: record the compliance-reviewer's verdict for the commit gate.

Only a result from the `compliance-reviewer` subagent counts, on whichever model it ran (Fable, or Opus as the
fallback where Fable is not available). On `COMPLIANCE: PASS <id>` the hook works out the
id of the staged changes itself and records the PASS only when the two match, so a verdict for other content
unlocks nothing. On `COMPLIANCE: FAIL` any earlier PASS is dropped. Every verdict is written to the audit log.
guard_bash.py refuses `git commit` until a PASS covers what is staged. A crash here records nothing, which
leaves the commit blocked.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "lib"))
sys.path.insert(0, os.path.join(HERE, "..", "tools"))
from common import add_context, iter_strings, project_dir, run_soft  # noqa: E402
import compliance  # noqa: E402

REVIEWER = "compliance-reviewer"
VERDICT_RE = re.compile(r"COMPLIANCE:\s*(PASS\s+`?([0-9a-f]{16})`?|FAIL)\b")
NOTE_RE = re.compile(r"(## Compliance note.*?)(?=\n\s*(?:COMPLIANCE:|STATUS:|```)|\Z)", re.S)
TAG = "[harness:compliance]"


def result_text(event) -> str:
    resp = event.get("tool_response")
    if isinstance(resp, str):
        return resp
    return "\n".join(s for _, s in iter_strings(resp))


def main(event):
    if (event.get("tool_input") or {}).get("subagent_type") != REVIEWER:
        return
    proj = project_dir(event)
    text = result_text(event)
    verdicts = VERDICT_RE.findall(text)
    session = str(event.get("session_id") or "")
    if not verdicts:
        compliance.log_event(proj, REVIEWER, "review", "", "no-verdict", session=session)
        return add_context("PostToolUse", f"{TAG} The compliance-reviewer returned no `COMPLIANCE:` verdict line, so "
                           "nothing was recorded and commits stay blocked. Run it again in the foreground.")
    whole, quoted = verdicts[-1]  # the last verdict line is the one that stands
    if whole == "FAIL" or any(w == "FAIL" for w, _ in verdicts):
        compliance.clear_pass(proj)
        compliance.log_event(proj, REVIEWER, "review", "", "fail", session=session)
        return add_context("PostToolUse", f"{TAG} FAIL recorded. Commits stay blocked. Send the BLOCK and REQUIRE "
                           "findings to the builder (a BLOCK also goes to Security), then review again.")
    changes = compliance.staged_changes(proj)
    current = compliance.changes_id(changes)
    if quoted != current:
        compliance.log_event(proj, REVIEWER, "review", quoted, "pass-stale", staged=current, session=session)
        return add_context("PostToolUse", f"{TAG} The PASS was for {quoted} but {current} is staged now, so it was not "
                           "recorded. Staged files changed during the review. Run the compliance-reviewer again.")
    note = NOTE_RE.search(text)
    compliance.record_pass(proj, changes, REVIEWER, note.group(1) if note else "")
    compliance.log_event(proj, REVIEWER, "review", current, "pass", files=len(changes), session=session)
    add_context("PostToolUse", f"{TAG} PASS recorded for {current} ({len(changes)} file(s)). commit-helper may commit "
                "these staged files. Any edit to them needs a new review. Put the compliance note in the PR "
                "description (`python3 .claude/tools/compliance.py note`).")


if __name__ == "__main__":
    run_soft(main)
