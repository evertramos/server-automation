#!/bin/bash

# ----------------------------------------------------------------------
#
# 
#
# ----------------------------------------------------------------------
#
# Developed by
#   Evert Ramos <evert.ramos@gmail.com>
#
# Copyright Evert Ramos 
#
# ----------------------------------------------------------------------

# Bash settings (do not mess with it)
shopt -s nullglob globstar

# Get the script name and its file real path
SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
SCRIPT_NAME="${0##*/}"

# Source basescript functions
source $SCRIPT_PATH"/../basescript/bootstrap.sh"

# Source localscripts
source $SCRIPT_PATH"/localscript/bootstrap.sh"

# ----------------------------------------------------------------------
#
# Initial check - DO NOT CHANGE SETTINGS BELOW
#
# ----------------------------------------------------------------------

# Run initial check function
run_function starts_initial_check

# Check if there is an .env file in local folder
run_function check_local_env_file

# Save PID
system_save_pid

# DO NOT CHANGE ANY OPTIONS ABOVE THIS LINE!

# ----------------------------------------------------------------------
#
# Process arguments
#
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
#
# Arguments validation and variables fulfillment
#
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
#
# Start running script
#
# ----------------------------------------------------------------------
run_function common_generate_random_string ${1:-12}
echo $RANDOM_STRING

exit 0

