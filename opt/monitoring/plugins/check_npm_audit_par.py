#!/usr/bin/env python3

# Evaluates the state file written by audit__npm_write_state.sh
# (first line: time of the check, rest: output of "npm audit --json").

import argparse
from datetime import datetime, timezone
import json
import sys

default_infile = "/tmp/ls-dev-npm_audit_state"

# writer script is expected to run hourly – add five minutes tolerance
default_max_delta_warn = 3900
default_max_delta_crit = 2 * default_max_delta_warn

severities_crit = ("critical", "high")
severities_warn = ("moderate", "low", "info")


################################################################################
def parse_args():

    parser = argparse.ArgumentParser(description="Check the state of npm audit")
    parser.add_argument("--file", default=default_infile, help="state file to read")
    parser.add_argument(
        "--max-age-warn",
        type=int,
        default=default_max_delta_warn,
        help="age of the state file (seconds) to raise WARNING",
    )
    parser.add_argument(
        "--max-age-crit",
        type=int,
        default=default_max_delta_crit,
        help="age of the state file (seconds) to raise CRITICAL",
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
def check_age(checktime_raw, max_delta_warn, max_delta_crit):

    # try to calculate delta between checktime and now
    try:
        now = datetime.now(timezone.utc)
        checktime = datetime.fromisoformat(checktime_raw)
        delta = round((now - checktime).total_seconds())
    except Exception as ex:
        print(f"CRITICAL: Could not calculate time delta ({type(ex).__name__} – {ex})")
        sys.exit(2)

    if delta < 0:
        print(
            f"CRITICAL: Audit script claims to be executed in future ({checktime_raw})??"
        )
        sys.exit(2)

    if delta > max_delta_crit:
        print(
            f"CRITICAL: Last audit script run was {delta} sec ago – check your cron job."
        )
        sys.exit(2)

    if delta > max_delta_warn:
        print(
            f"WARNING: Last audit script run was {delta} sec ago – check your cron job."
        )
        sys.exit(1)


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
        check_age(checktime_raw.strip(), args.max_age_warn, args.max_age_crit)
        report = parse_report(report_raw)
        analyze_report(report, checktime_raw.strip())
    except Exception as ex:
        print(f"CRITICAL: Something unexpected happened: {type(ex).__name__} – {ex}")
        sys.exit(2)
