#!/bin/bash

# ----------------------------------------------------------------------
#
# List all domains in Digital Ocean API account 
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

# Debug true will show all debug messages
DEBUG=true

# Silent true will hide all information
#SILENT=true

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

# List all URL available in our account
run_function list_all_domains

exit 0
