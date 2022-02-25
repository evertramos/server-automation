#!/bin/bash

# Get the script name and its file real path
SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
SCRIPT_NAME="${0##*/}"

# Source basescript functions
source $SCRIPT_PATH"/../basescript/bootstrap.sh"

# Source localscripts
#source $SCRIPT_PATH"/localscript/bootstrap.sh"

run_function string_remove_all_special_char_stringf "tes. AARRRte-vai%$.avv"
run_function

echo $REMOVE_ALL_SPECIAL_CHAR_STRING_RESPONSE

echo
echo 'fim'
echo

exit 0
