#!/bin/bash

SGPT_CONFIG="$HOME/.config/shell_gpt/.sgptrc"

SGPT_DIR="$HOME/.shell_gpt"
SGPT_BIN="$SGPT_DIR/bin"
SGPT_ENV=$SGPT_BIN"/venv"
SGPT_CONVERSATIONS="$SGPT_DIR/conversations"

if ! test -d "$SGPT_ENV"; then
    echo "$SGPT_ENV does not exist – will install ShellGPT there"
    mkdir -p $SGPT_BIN
    cd $SGPT_BIN
    echo "Creating venv…"
    /usr/bin/env python3 -m venv venv
    echo "Activating venv…"
    . venv/bin/activate
    echo "Installing shell-gpt[litellm]…"
    pip install shell-gpt[litellm]
fi

if ! test -f "$SGPT_CONFIG"; then
    echo "File $SGPT_CONFIG does not exist"
    echo "Starting sgpt to create it (you may enter "$(uuid -v 4)" when asked for the API key…"
    cd $SGPT_BIN
    . venv/bin/activate
    sgpt

    echo "Storing original config file at "$SGPT_CONFIG".original"
    cp -a $SGPT_CONFIG $SGPT_CONFIG".original"
    echo "Adapting config for local use (following https://www.tuxedocomputers.com/de/ShellGPT-und-Ollama-Erste-Schritte-mit-AI-und-Ihrem-TUXEDO.tuxedo)"
    sed -i 's#^DEFAULT_MODEL=.*#DEFAULT_MODEL=ollama/NAME_OF_MODEL:SIZE#g' $SGPT_CONFIG
    sed -i 's/^OPENAI_USE_FUNCTIONS=.*/OPENAI_USE_FUNCTIONS=false/g' $SGPT_CONFIG
    sed -i 's/^USE_LITELLM=.*/USE_LITELLM=true/g' $SGPT_CONFIG



    exit 1
fi


TOPIC=$(echo $1 | sed 's/\s/_/g')

MODEL=$(egrep "^DEFAULT_MODEL=" $SGPT_CONFIG | cut -d'=' -f 2 | sed 's#/#_#g' | sed 's/:/_/g')

CACHE_NAME=$(date -Iseconds | sed 's/:/-/g' | sed 's/+.*//g' | sed 's/T/t/g')"__"$MODEL
if ! test -z "$TOPIC"; then
    CACHE_NAME=$CACHE_NAME"__"$TOPIC
fi

echo $CACHE_NAME

CHAT_CACHE_FILE=$(egrep "^CHAT_CACHE_PATH=" $SGPT_CONFIG | cut -d'=' -f 2)"/"$CACHE_NAME



# echo "--------------------------------------------------------------------------------"
# echo "CONFIGURATION (read from $SGPT_CONFIG):"
# echo
# cat $SGPT_CONFIG
# echo "----------------------------------------"

cd $SGPT_BIN
. venv/bin/activate
sgpt --repl $CACHE_NAME

echo "TODO: Read "$CHAT_CACHE_FILE" an convert to human readable (HTML?) format."

