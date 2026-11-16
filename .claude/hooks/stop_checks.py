#!/usr/bin/env python3
"""Stop: end-of-turn checks.

Knowledge-graph nodes whose sources were deleted are removed here without a model and without blocking; the
refresh of changed nodes runs in the background (see kg_hooks.py). Leftover temporary files block at most
once per stop (stop_hook_active).
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "lib"))
sys.path.insert(0, HERE)
from common import emit, run_soft  # noqa: E402
import housekeeping  # noqa: E402
import kg_hooks  # noqa: E402


def main(event):
    try:
        kg_hooks.prune(event)
    except Exception:  # noqa: BLE001 - upkeep must never stop the cleanup check
        pass
    reason = housekeeping.stop_reason(event)
    if reason:
        emit({"decision": "block", "reason": reason})


if __name__ == "__main__":
    run_soft(main)
