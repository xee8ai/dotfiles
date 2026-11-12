#!/bin/bash

CLAUDE="$HOME/.local/bin/claude"
CURSOR="$HOME/.local/bin/agent"
MISTRAL="$HOME/.local/bin/vibe"
OPENCODE="$HOME/.opencode/bin/opencode"

################################################################################
# formatter for headlines
function set_cons {
    tput smul
    tput bold
    tput setaf 39
}

################################################################################
# Show a nice header telling the user what is done next
function header {
    echo
    echo
    set_cons
    echo $1
    tput sgr0
}

################################################################################
function check_claudecode {
    header "Updating Claude Code"
    $CLAUDE upgrade
    if [ -e "$HOME/.claude/plugins/cache/claude-plugins-official/mattpocock-skills" ]; then
        header "Updating mattpocock-skills for Claude Code"
        claude plugin update mattpocock-skills@claude-plugins-official
    fi
}

################################################################################
function check_cursoragent {
    header "Updating Cursor Agent"
    $CURSOR update
}

################################################################################
function check_mistralvibe {
    header "Updating Mistral Vibe"
    $MISTRAL update
}

################################################################################
function check_opencode {
    header "Updating OpenCode"
    $OPENCODE upgrade
}

################################################################################
# update system wide installed tools and stuff
function check_system {
    if [ -e "$CLAUDE" ]; then
        check_claudecode
    fi
    if [ -e "$CURSOR" ]; then
        check_cursoragent
    fi
    if [ -e "$MISTRAL" ]; then
        check_mistralvibe
    fi
    if [ -e "$OPENCODE" ]; then
        check_opencode
    fi
}

function check_laravel_boost() {
    header "Updating or installing Laravel boost"
    php artisan boost:update || php artisan boost:install
}

################################################################################
# update Laravel project
function check_laravel {
    grep -q laravel/boost composer.json && check_laravel_boost
}

################################################################################
# update project related stuff
function check_project {
    if [ -e artisan ]; then
        check_laravel
    fi
}

################################################################################
################################################################################
check_system
check_project

echo
echo
