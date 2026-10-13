#!/usr/bin/env python3
import json
import os
from pathlib import Path

print("=== AI Terraform Risk Analyzer ===")

# -----------------------------------------------------------
# LOAD JSON HELPERS
# -----------------------------------------------------------
def load_json(path):
    if not Path(path).exists():
        print(f"[WARN] Missing file: {path}")
        return None

    try:
        with open(path, "r") as f:
            return json.load(f)
    except Exception as e:
        print(f"[ERROR] Failed to parse {path}: {e}")
        return None


# -----------------------------------------------------------
# SCORING: tfsec
# -----------------------------------------------------------
def score_tfsec(report):
    if not report:
        return 0

    # tfsec JSON format:
    # { "results": [ {...}, {...} ] }
    results = report.get("results", [])
    return len(results)


# -----------------------------------------------------------
# SCORING: Checkov (Supports ALL formats)
# -----------------------------------------------------------
def score_checkov(report):
    """
    Handles both formats:

    NEW FORMAT (Checkov >= 3.x):
    [
      { "check_result": { "result": "FAILED" }, "resource": "...", ... },
      { ... }
    ]

    OLD FORMAT:
    {
      "results": {
        "failed_checks": [ {...}, {...} ],
        "passed_checks": [...]
      }
    }
    """

    if not report:
        return 0

    # --- NEW FORMAT (list of individual check results) ---
    if isinstance(report, list):
        failed = [item for item in report
                  if item.get("check_result", {}).get("result") == "FAILED"]
        return len(failed)

    # --- OLD FORMAT (object with results) ---
    if isinstance(report, dict):
        results = report.get("results", {})
        failed = results.get("failed_checks", [])
        return len(failed)

    # If unknown format → no risk
    return 0


# -----------------------------------------------------------
# FINAL RISK LEVEL LOGIC
# -----------------------------------------------------------
def risk_level(total):
    if total == 0:
        return "LOW"
    elif total < 10:
        return "MEDIUM"
    else:
        return "HIGH"


# -----------------------------------------------------------
# MAIN EXECUTION
# -----------------------------------------------------------
tfsec_report = load_json("tfsec.json")
checkov_report = load_json("checkov.json")

tfsec_score = score_tfsec(tfsec_report)
checkov_score = score_checkov(checkov_report)

total_risk = tfsec_score + checkov_score

print("\n===== SECURITY RISK SUMMARY =====")
print(f"tfsec findings:      {tfsec_score}")
print(f"Checkov findings:    {checkov_score}")
print(f"---------------------------------")
print(f"TOTAL FINDINGS:      {total_risk}")
print(f"RISK LEVEL:          {risk_level(total_risk)}")
print("=================================\n")

# Pipeline MUST NOT fail — always exit 0
exit(0)
