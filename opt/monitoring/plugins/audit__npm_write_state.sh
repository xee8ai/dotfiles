#!/bin/bash

# Runs "npm audit" for a project and stores the result in a state file.
# Meant to be run by cron as a user that is allowed to read the project dir;
# the state file is evaluated by the icinga plugin check_npm_audit_par.py.
#
# Usage: audit__npm_write_state.sh PROJECT_DIR [STATE_FILE]

export PATH="/usr/local/bin:/usr/bin:/bin"

PROJECT_DIR="$1"
CHECKFILE="${2:-/tmp/$(id -un)-npm_audit_state}"

if test -z "$PROJECT_DIR"; then
        echo "Usage: $0 PROJECT_DIR [STATE_FILE]" >&2
        exit 1
fi

# write to a temp file first – the plugin shall never see a half written state
TMPFILE=$(mktemp "${CHECKFILE}.XXXXXX") || exit 1
trap 'rm -f "$TMPFILE" "$TMPFILE.err"' EXIT

# first line: time of the check, then the audit report (JSON), then stderr
# (appended behind the report to keep the JSON intact; shows the reason if
# there is no report)
date -u -Iseconds > "$TMPFILE"

# npm exits with 1 on found vulnerabilities and on errors, too – so the exit
# code is ignored here; the plugin decides by looking at the report
if cd "$PROJECT_DIR" 2> "$TMPFILE.err"; then
        npm audit --omit=dev --json >> "$TMPFILE" 2> "$TMPFILE.err"
fi
cat "$TMPFILE.err" >> "$TMPFILE"

chmod 644 "$TMPFILE"
mv -f "$TMPFILE" "$CHECKFILE" || exit 1
