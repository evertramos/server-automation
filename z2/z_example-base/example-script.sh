#!/bin/bash

# ----------------------------------------------------------------------
#
# SCRIPT_DESCRIPTION_
#
# Server Automation - https://github.com/evertramos/server-automation
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

# Source server-automation functions
source $SCRIPT_PATH"/../localscript/bootstrap.sh"

# Source localscripts
source $SCRIPT_PATH"/localscript/bootstrap.sh"

# Log
log "Start execution"
log "'$*'"

#-----------------------------------------------------------------------
# Process arguments
#-----------------------------------------------------------------------
while [[ $# -gt 0 ]]
do
    case "$1" in
        -d)
        ARG_DESTINATION_FOLDER="${2}"
        if [[ $ARG_DESTINATION_FOLDER == "" ]]; then
            echoerror "Invalid option for -d"
            break;
        fi
        shift 2
        ;;
        --destination=*)
        ARG_DESTINATION_FOLDER="${1#*=}"
        if [[ $ARG_DESTINATION_FOLDER == "" ]]; then
            echoerror "Invalid option for --destination=''"
            break;
        fi
        shift 1
        ;;

        --only-option)
        ONLY_OPTION=true
        shift 1
        ;;

        --yes)
        REPLY_YES=true
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
        usage_
        exit 0
        ;;
        *)
        echoerror "Unknown argument: $1" false
        usage_
        exit 0
        ;;
    esac
done

#-----------------------------------------------------------------------
# Initial check - DO NOT CHANGE SETTINGS BELOW
#-----------------------------------------------------------------------

# Check if there is an .env file in local folder
run_function check_local_env_file

# Specific PID File if needs to run multiple scripts
NEW_PID_FILE=${PID_FILE_NEW_SITE:-".SCRIPT_DESCRIPTION__script"}

# Run initial check function
run_function starts_initial_check $NEW_PID_FILE

# Save PID
system_save_pid $NEW_PID_FILE

# DO NOT CHANGE ANY OPTIONS ABOVE THIS LINE!

#-----------------------------------------------------------------------
# [function] Undo script actions
#-----------------------------------------------------------------------
local_undo_restore()
{
    local LOCAL_KEEP_RESTORE_FILES

    LOCAL_KEEP_RESTORE_FILES=${1:-$KEEP_RESTORE_FILES}

    echoerror "It seems something went wrong running '${FUNCNAME[0]}' \
      \nwe will try to UNDO all actions done by this script. \
      \nPlease make sure everything was back in place as when you started." false

    # If any service was started make sure to stop it
    if [[ "$ACTION_DOCKER_COMPOSE_STARTED" == true ]]; then
        [[ "$SILENT" != true ]] && echowarning "[undo] Starting docker-compose service '$LOCAL_SITE_FULL_PATH'."
        run_function docker_compose_stop "${LOCAL_SITE_FULL_PATH%/}/compose"
        ACTION_DOCKER_COMPOSE_STARTED=false
    fi

    # If site folder was created
    if [[ "$ACTION_SITE_PATH_CREATED" == true ]]; then
        [[ "$SILENT" != true ]] && echowarning "[undo] Creating site folder '$LOCAL_SITE_FULL_PATH'."
        # Remove folder
        run_function system_safe_delete_folder $LOCAL_SITE_FULL_PATH true
        ACTION_SITE_PATH_CREATED=false
    fi

    # If site domain was created
    if [[ "$ACTION_SITE_URL_CREATED" == true ]]; then
        [[ "$SILENT" != true ]] && echowarning "[undo] Creating site domain '$LOCAL_NEW_URL'."
        run_function domain_delete_domain_dns $LOCAL_NEW_URL
        ACTION_SITE_URL_CREATED=false
        if [[ "$WITH_WWW" == true ]]; then
            run_function domain_delete_domain_dns "www.$LOCAL_NEW_URL"
        fi
    fi

    exit 0
}



# ---

exit 0

