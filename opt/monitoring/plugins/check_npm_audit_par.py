#!/usr/bin/env python3

# Evaluates the state file written by audit__npm_write_state.sh
# (first line: time of the check, rest: output of "npm audit --json").

import argparse
from datetime import datetime, timedelta
import json
import sys

default_infile = "/tmp/ls-dev-npm_audit_state"

# writer script runs the audit at least every 24h – time (minutes) a state file
# may be older than that
default_grace = 30

severities_crit = ("critical", "high")
severities_warn = ("moderate", "low", "info")


################################################################################
def parse_args():

    parser = argparse.ArgumentParser(description="Check the state of npm audit")
    parser.add_argument("--file", default=default_infile, help="state file to read")
    parser.add_argument(
        "--grace",
        type=int,
        default=default_grace,
        help="minutes a state file may be older than 24h",
    )

    return parser.parse_args()


################################################################################
def read_infile(infile):

    # read the status file
    try:
        with open(infile, "r") as fh:
            content = fh.read().strip()
    except Exception as ex:
        print(
            f"CRITICAL: Error reading status file {infile} ({type(ex).__name__} – {ex})"
        )
        sys.exit(2)

    return content


################################################################################
def check_age(checktime_raw, grace):

    # the audit script rewrites the state file at least every 24h – so the
    # state is fine if it is not older than that
    try:
        now = datetime.now().astimezone()
        checktime = datetime.fromisoformat(checktime_raw).astimezone()
        age = now - checktime
    except Exception as ex:
        print(f"CRITICAL: Could not calculate state age ({type(ex).__name__} – {ex})")
        sys.exit(2)

    if checktime > now:
        print(
            f"CRITICAL: Audit script claims to be executed in future ({checktime_raw})??"
        )
        sys.exit(2)

    # give the cron job some time to write the new state
    if age <= timedelta(hours=24, minutes=grace):
        return

    if age <= timedelta(hours=48):
        print(
            f"WARNING: Last audit script run was more than 24h ago ({checktime_raw}) – check your cron job."
        )
        sys.exit(1)

    print(
        f"CRITICAL: Last audit script run was {age.days} days ago ({checktime_raw}) – check your cron job."
    )
    sys.exit(2)


################################################################################
def parse_report(report_raw):

    # only the first JSON document is read – the audit script appends stderr
    try:
        report, _ = json.JSONDecoder().raw_decode(report_raw.strip())
        if not isinstance(report, dict):
            raise ValueError(f"expected JSON object, got {type(report).__name__}")
    except Exception as ex:
        output = " ".join(report_raw.split())[:300]
        print(f"UNKNOWN: No valid audit report ({type(ex).__name__} – {ex}): {output}")
        sys.exit(3)

    return report


################################################################################
def analyze_report(report, checktime_raw):

    # npm reports its own problems (e.g. registry not reachable) as JSON, too
    if "error" in report:
        error = report["error"]
        if isinstance(error, dict):
            error = " – ".join(
                str(error[k]) for k in ("code", "summary") if error.get(k)
            )
        print(f"UNKNOWN: npm audit failed: {error}")
        sys.exit(3)

    try:
        counts = report["metadata"]["vulnerabilities"]
        count_crit = sum(int(counts.get(s, 0)) for s in severities_crit)
        count_warn = sum(int(counts.get(s, 0)) for s in severities_warn)
        perfdata = " ".join(
            f"{s}={int(counts.get(s, 0))}" for s in severities_crit + severities_warn
        )
        details = [
            f"{name} ({vuln.get('severity', 'unknown')})"
            for name, vuln in sorted(report.get("vulnerabilities", {}).items())
        ]
    except Exception as ex:
        print(f"UNKNOWN: Malformed audit report ({type(ex).__name__} – {ex})")
        sys.exit(3)

    summary = ", ".join(
        f"{counts[s]} {s}" for s in severities_crit + severities_warn if counts.get(s)
    )

    if count_crit > 0:
        status, code = "CRITICAL", 2
    elif count_warn > 0:
        status, code = "WARNING", 1
    else:
        # if we end up here: everything seems to be fine :-)
        print(f"OK: No vulnerabilities (audit executed at {checktime_raw}) | {perfdata}")
        sys.exit(0)

    print(f"{status}: Vulnerable npm packages: {summary} | {perfdata}")
    for detail in details:
        print(detail)
    sys.exit(code)


################################################################################
################################################################################
if __name__ == "__main__":
    try:
        args = parse_args()
        content = read_infile(args.file)
        checktime_raw, _, report_raw = content.partition("\n")
        check_age(checktime_raw.strip(), args.grace)
        report = parse_report(report_raw)
        analyze_report(report, checktime_raw.strip())
    except Exception as ex:
        print(f"CRITICAL: Something unexpected happened: {type(ex).__name__} – {ex}")
        sys.exit(2)
