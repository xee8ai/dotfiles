#!/usr/bin/env python3

from datetime import datetime, timezone
import os.path
from pprint import pprint
import sys

infile = "/tmp/root-packetfilter_check_state"


################################################################################
def read_infile(infile):

    # read the status file
    try:
        with open(infile, "r") as fh:
            content = [l.strip() for l in fh.readlines()]
    except Exception as ex:
        print(
            f"CRITICAL: Error reading status file {infile} ({type(ex).__name__} – {ex})"
        )
        sys.exit(2)

    return content


################################################################################
def analyze_content(content):

    max_delta_warn = 305  # script runs every five minutes – add five seconds tolerance
    max_delta_crit = 2 * max_delta_warn

    if len(content) != 2:
        output = "\\n".join(content)
        print(
            f"CRITICAL: Malformed status file, expect 2 lines but got {len(content)}: {output}"
        )
        sys.exit(2)

    # try to calculate delta between checktime and now
    try:
        now = datetime.now(timezone.utc)
        checktime = datetime.fromisoformat(content[0])
        delta = round((now - checktime).total_seconds())
    except Exception as ex:
        print(f"CRITICAL: Could not calculate time delta ({type(ex).__name__} – {ex})")
        sys.exit(2)

    if delta < 0:
        print(
            f"CRITICAL: Check script claims to be executed in future ({content[0]})??"
        )
        sys.exit(2)

    if delta > max_delta_crit:
        print(
            f"CRITICAL: Last check script run was {delta} sec ago – check your cron job."
        )
        sys.exit(2)

    if delta > max_delta_warn:
        print(
            f"WARNING: Last check script run was {delta} sec ago – check your cron job."
        )
        sys.exit(1)

    if content[1] != "OK":
        print(f"CRITICAL: Check script status {content[1]}")
        sys.exit(2)

    # if we end up here: everything seems to be fine :-)
    print(f"OK (check script executed at {content[0]})")
    sys.exit(0)


################################################################################
################################################################################
if __name__ == "__main__":
    try:
        content = read_infile(infile)
        analyze_content(content)
    except Exception as ex:
        print(f"CRITICAL: Something unexpected happened: {type(ex).__name__} – {ex}")
        sys.exit(2)
