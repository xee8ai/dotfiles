#!/bin/bash

# Runs "composer audit" for a project and stores the result in a state file.
# Meant to be run by cron as a user that is allowed to read the project dir;
# the state file is evaluated by the icinga plugin check_composer_audit_par.py.
#
# Usage: audit__composer_write_state.sh PROJECT_DIR [STATE_FILE]

export PATH="/usr/local/bin:/usr/bin:/bin"

PROJECT_DIR="$1"
CHECKFILE="${2:-/tmp/$(id -un)-composer_audit_state}"

# time of day (local time) the daily audit is done
REFRESH_TIME="07:00"

if test -z "$PROJECT_DIR"; then
        echo "Usage: $0 PROJECT_DIR [STATE_FILE]" >&2
        exit 1
fi

# the audit is done once a day only (so cron can call this script every few
# minutes to get a missing state file rebuilt soon, e.g. after a reboot) – the
# state file is (re)written if
#   - it does not exist (or holds no valid time of the check)
#   - it is older than 24h
#   - this is the first run after $REFRESH_TIME (local time)
if test -f "$CHECKFILE"; then
        NOW=$(date +%s)
        REFRESH=$(date -d "today $REFRESH_TIME" +%s)
        CHECKTIME=$(date -d "$(head -n 1 "$CHECKFILE")" +%s 2> /dev/null)
        if test -n "$CHECKTIME" && test $((NOW - CHECKTIME)) -lt 86400; then
                if test "$NOW" -lt "$REFRESH" || test "$CHECKTIME" -ge "$REFRESH"; then
                        exit 0
                fi
        fi
fi

# write to a temp file first – the plugin shall never see a half written state
TMPFILE=$(mktemp "${CHECKFILE}.XXXXXX") || exit 1
trap 'rm -f "$TMPFILE" "$TMPFILE.err"' EXIT

# first line: time of the check, then the audit report (JSON), then stderr
# (appended behind the report to keep the JSON intact; shows the reason if
# there is no report)
date -u -Iseconds > "$TMPFILE"

# composer exits with non-zero on found advisories and on errors, too – so the
# exit code is ignored here; the plugin decides by looking at the report
composer audit --no-dev --locked --format=json --no-interaction \
        --working-dir="$PROJECT_DIR" >> "$TMPFILE" 2> "$TMPFILE.err"
cat "$TMPFILE.err" >> "$TMPFILE"

chmod 644 "$TMPFILE"
mv -f "$TMPFILE" "$CHECKFILE" || exit 1
