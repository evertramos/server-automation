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

# process arguments
while [[ $# -gt 0 ]]
do
    case "$1" in
        -u)
        ARG_URL="${2}"
        if [[ $ARG_URL == "" ]]; then 
            echoerror "Invalid option for -u";
            break;
        fi
        shift 2
        ;;
        --url=*)
        ARG_URL="${1#*=}"
        if [[ $ARG_URL == "" ]]; then 
            echoerror "Invalid option for --url";
            break;
        fi
        shift 1
        ;;
        --debug)
        DEBUG=true
        shift 1
        ;;
        --silent)
        SILENT=true
        shift 1
        ;;
        -h | --help)
        usage
        ;;
        *)
        echoerror "Unknown argument: $1"
        usage
        ;;
    esac
done

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
[[ $ARG_URL == "" ]] && echoerror "You must inform the url to check if is running in ths proxy --url=''"

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
run_function proxy_check_url_active $ARG_URL

if [[ "$DOMAIN_ACTIVE_IN_PROXY" == true ]]; then
    echowarning "The domain '$ARG_URL' is set in the proxy. One of the running containers is using this domain."
else
    echosuccess "No site is running in the proxy under this domain '$ARG_URL'"
fi

exit 0
