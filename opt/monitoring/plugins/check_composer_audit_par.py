#!/usr/bin/env python3

# Evaluates the state file written by audit__composer_write_state.sh
# (first line: time of the check, rest: output of "composer audit --format=json").

import argparse
from datetime import datetime
import json
import sys

default_infile = "/tmp/ls-dev-composer_audit_state"

# writer script runs the audit once a day – time (minutes) after midnight in
# which a state file from yesterday is still fine
default_grace = 30

# advisories without a (known) severity are counted as "unknown" and handled
# as critical – better safe than sorry
severities_crit = ("critical", "high", "unknown")
severities_warn = ("medium", "low")


################################################################################
def parse_args():

    parser = argparse.ArgumentParser(description="Check the state of composer audit")
    parser.add_argument("--file", default=default_infile, help="state file to read")
    parser.add_argument(
        "--grace",
        type=int,
        default=default_grace,
        help="minutes after midnight in which a state file from yesterday is still fine",
    )
    parser.add_argument(
        "--ignore-abandoned",
        action="store_true",
        help="do not raise WARNING on abandoned packages",
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

    # the audit script writes the state file once a day – so the state is fine
    # if it is from today (local time)
    try:
        now = datetime.now().astimezone()
        checktime = datetime.fromisoformat(checktime_raw).astimezone()
        age_days = (now.date() - checktime.date()).days
        midnight = now.replace(hour=0, minute=0, second=0, microsecond=0)
        minutes_since_midnight = (now - midnight).total_seconds() / 60
    except Exception as ex:
        print(f"CRITICAL: Could not calculate state age ({type(ex).__name__} – {ex})")
        sys.exit(2)

    if checktime > now:
        print(
            f"CRITICAL: Audit script claims to be executed in future ({checktime_raw})??"
        )
        sys.exit(2)

    if age_days == 0:
        return

    # give the cron job some time to write today's state
    if age_days == 1 and minutes_since_midnight <= grace:
        return

    if age_days == 1:
        print(
            f"WARNING: Last audit script run was yesterday ({checktime_raw}) – check your cron job."
        )
        sys.exit(1)

    print(
        f"CRITICAL: Last audit script run was {age_days} days ago ({checktime_raw}) – check your cron job."
    )
    sys.exit(2)


################################################################################
def parse_report(report_raw):

    # only the first JSON document is read – the audit script appends stderr
    try:
        report, _ = json.JSONDecoder().raw_decode(report_raw.strip())
        if not isinstance(report, dict) or "advisories" not in report:
            raise ValueError("no advisories section found")
    except Exception as ex:
        output = " ".join(report_raw.split())[:300]
        print(f"UNKNOWN: No valid audit report ({type(ex).__name__} – {ex}): {output}")
        sys.exit(3)

    return report


################################################################################
def analyze_report(report, checktime_raw, ignore_abandoned):

    severities = severities_crit + severities_warn
    counts = {s: 0 for s in severities}
    details = []

    try:
        # composer writes empty sections as list, filled ones as object
        advisories = report.get("advisories") or {}
        abandoned = report.get("abandoned") or {}

        for package, package_advisories in sorted(advisories.items()):
            if isinstance(package_advisories, dict):
                package_advisories = package_advisories.values()
            for advisory in package_advisories:
                severity = str(advisory.get("severity") or "unknown").lower()
                if severity not in severities:
                    severity = "unknown"
                counts[severity] += 1
                ident = advisory.get("cve") or advisory.get("advisoryId") or "no ID"
                details.append(
                    f"{package} ({severity}): {advisory.get('title', '')} [{ident}]"
                )

        for package, replacement in sorted(abandoned.items()):
            details.append(
                f"{package} (abandoned): use {replacement or 'no replacement'}"
            )
    except Exception as ex:
        print(f"UNKNOWN: Malformed audit report ({type(ex).__name__} – {ex})")
        sys.exit(3)

    count_crit = sum(counts[s] for s in severities_crit)
    count_warn = sum(counts[s] for s in severities_warn)
    perfdata = " ".join(f"{s}={counts[s]}" for s in severities)
    perfdata += f" abandoned={len(abandoned)}"

    summary = [f"{counts[s]} {s}" for s in severities if counts[s]]
    if abandoned:
        summary.append(f"{len(abandoned)} abandoned")
    summary = ", ".join(summary)

    if count_crit > 0:
        status, code = "CRITICAL", 2
    elif count_warn > 0 or (abandoned and not ignore_abandoned):
        status, code = "WARNING", 1
    else:
        # if we end up here: everything seems to be fine :-)
        status, code = "OK", 0

    if not summary:
        print(f"OK: No advisories (audit executed at {checktime_raw}) | {perfdata}")
        sys.exit(0)

    print(f"{status}: Composer packages with problems: {summary} | {perfdata}")
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
        analyze_report(report, checktime_raw.strip(), args.ignore_abandoned)
    except Exception as ex:
        print(f"CRITICAL: Something unexpected happened: {type(ex).__name__} – {ex}")
        sys.exit(2)
