#!/usr/bin/env python3
"""Knowledge-graph upkeep hooks. None of them blocks or interrupts the reply.

  kg_hooks.py track  (PostToolUse Write|Edit|MultiEdit|NotebookEdit) -> record edited paths
  kg_hooks.py nudge  (UserPromptSubmit, PostToolUse Agent|Task)      -> when enough has changed, tell the main
                                                                        agent to start knowledge-keeper in the
                                                                        background and carry on
  kg_hooks.py stop   (Stop)  -> delete nodes whose sources are gone (no model needed)
"""
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "lib"))
sys.path.insert(0, os.path.join(HERE, "..", "tools"))
from common import add_context, load_config, project_dir, rel_to, run_soft, state_dir  # noqa: E402
import kg as kgmod  # noqa: E402

NUDGE_EVERY_S = 20 * 60  # one keeper at a time: do not ask again while one is likely still running


def track(event):
    proj = project_dir(event)
    ti = event.get("tool_input") or {}
    path = ti.get("file_path") or ti.get("notebook_path")
    if not path:
        return
    rel = rel_to(proj, path)
    if rel.startswith("..") or rel.startswith(".claude/"):
        return
    with open(os.path.join(state_dir(proj), "kg-pending"), "a", encoding="utf-8") as fh:
        fh.write(rel + "\n")
    nudge(event)


def prune(event):
    """Remove nodes whose every source was deleted. Returns the removed ids."""
    return kgmod.auto_prune(kgmod.KG(project_dir(event)))


def stop(event):
    prune(event)


def refresh_reason(event):
    """The [harness:kg] note when pending edits or aged nodes need the keeper, else None."""
    proj = project_dir(event)
    cfg = load_config(proj)["knowledge"]
    kg = kgmod.KG(proj)
    pending = [p for p in kgmod.read_pending(kg) if not kgmod.is_ignored(kg, p)]
    ref = kgmod.referencing(kg)
    referenced = [p for p in pending if p in ref or any(p.startswith(d + "/") and d.count("/") >= 1 for d in ref)]
    aged = [i for i, _ in kgmod.aged_nodes(kg)]
    # Edits in areas the graph does not cover yet wait until enough files are pending.
    if not (referenced or aged or len(pending) >= int(cfg["pending_trigger_count"])):
        return None
    parts = []
    if pending:
        parts.append("Changed: " + ", ".join(pending[:12]) + (f" (+{len(pending) - 12} more)" if len(pending) > 12 else ""))
    if aged:
        parts.append(f"Not verified for over {kg.max_age_days} days: " + ", ".join(aged[:12]))
    return (
        "[harness:kg] The knowledge graph needs a refresh. " + ". ".join(parts) + ". "
        "Start the `knowledge-keeper` subagent in the background now (Agent tool with `run_in_background: true`) with: "
        "\"Update the KG for pending changes. Re-verify or remove stale and aged nodes (`kg.py pending`, `kg.py stale`), "
        "delete what no longer holds, then `kg.py index && kg.py validate` and `kg.py pending --clear`.\" "
        "Do not wait for it and do not mention it unless it fails: carry on with the user's request. "
        "Start only one keeper at a time.")


def nudge(event):
    if event.get("agent_id"):
        return  # a subagent cannot start the keeper; the main session is told instead
    proj = project_dir(event)
    sfile = os.path.join(state_dir(proj), "kg-nudge.json")
    try:
        with open(sfile) as fh:
            last = float(json.load(fh).get("ts", 0))
    except (OSError, ValueError, TypeError, AttributeError):
        last = 0.0
    if time.time() - last < NUDGE_EVERY_S:
        return
    reason = refresh_reason(event)
    if not reason:
        return
    with open(sfile, "w") as fh:
        json.dump({"ts": time.time()}, fh)
    add_context(event.get("hook_event_name") or "PostToolUse", reason)


if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    run_soft({"track": track, "nudge": nudge, "stop": stop}.get(mode, lambda e: None))
