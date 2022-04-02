#!/bin/bash

#-----------------------------------------------------------------------
#
# WordPress script - delete site
#
# Server Automation - https://github.com/evertramos/server-automation 
#
# Developed by
#   Evert Ramos <evert.ramos@gmail.com>
#
# Copyright Evert Ramos
#
#-----------------------------------------------------------------------

# Bash settings (do not mess with it)
shopt -s nullglob globstar
# =) unless you have read the following with good care! =)
# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html

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
printf "${energy} Start execution '${SCRIPT_PATH}/${SCRIPT_NAME} "
echo "$@':"
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
            echoerror "Invalid option for -d";
            break;
        fi
        shift 2
        ;;
        --destination=*)
        ARG_DESTINATION_FOLDER="${1#*=}"
        if [[ $ARG_DESTINATION_FOLDER == "" ]]; then 
            echoerror "Invalid option for --destination=''";
            break;
        fi
        shift 1
        ;;
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

        # @todo - add backup option before deleting - option might be used to send it to 'cold storage'
#        --backup)
#        BACKUP_BEFORE_DELETE=true
#        shift 1
#        ;;

        # @todo - improve script to remove dns using dns service API (CloudFlare|DigitalOcean|AWS)
#        --remove-dns)
#        REMOVE_DNS=true
#        shift 1
#        ;;
#        --dns-service-name)
#        DNS_SERVICE_NAME=true
#        shift 1
#        ;;

        --skip-output-colors)
        BASESCRIPT_SKIP_COLOR=true
        shift 1
        ;;
        --pid-tag=*)
        ARG_PID_TAG="${1#*=}"
        if [[ $ARG_PID_TAG == "" ]]; then
            echoerror "Invalid option for --pid-tag";
            break;
        fi
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
        usage_delete_site
        exit 0
        ;;
        *)
        echoerror "Unknown argument: $1" false
        usage_delete_site
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
LOCAL_NEW_PID_FILE=${PID_FILE_NEW_SITE:-".delete_site.pid"}
if [[ $ARG_PID_TAG == "" ]]; then
  NEW_PID_FILE=${LOCAL_NEW_PID_FILE}
else
  NEW_PID_FILE=".${ARG_PID_TAG}-${LOCAL_NEW_PID_FILE:1}"
fi

# Run initial check function
run_function starts_initial_check $NEW_PID_FILE

# Save PID
system_save_pid $NEW_PID_FILE

# DO NOT CHANGE ANY OPTIONS ABOVE THIS LINE!

#-----------------------------------------------------------------------
# Check if the .env file was already configured for Server-Automation
#-----------------------------------------------------------------------
# @todo - update this function to server-automation .env file if not present it must be configured before running this script
# [?] this is done by the env function - check if needed
run_function check_server_automation_env_file_exists

# Result from function above
if [[ "$SERVER_AUTOMATION_ENV_FILE_EXISTS" != true ]]; then
  [[ "$SILENT" != true ]] && echowarning \
    "It seems you are running server-automation for the first time! \
    We will first need to run You must configure the server-automation '.env' file before continue!"
fi

#-----------------------------------------------------------------------
# Arguments validation and variables fulfillment
#
# The DESTINATION_FOLDER is where the site is placed
# SITES_FOLDER in base .env
#-----------------------------------------------------------------------

# Check if Sites Folder is set (--destination) or SITES_FOLDER from base .env is set
if [[ $ARG_DESTINATION_FOLDER == "" ]] && [[ $SITES_FOLDER == "" ]]; then 
    echoerror "It seems you did not set the option SITES_FOLDER in your base .env file. If you intend to use this script without this settings please use --destination='' option to inform where your site should be located."
else
    DESTINATION_FOLDER=${ARG_DESTINATION_FOLDER:-$SITES_FOLDER}
    
    # Check if folder exists
    run_function check_folder_exists $DESTINATION_FOLDER

    # Result from folder exists function
    if [[ "$FOLDER_EXIST" == false ]]; then
        echoerror "The site folder does not exists at '$DESTINATION_FOLDER'."
    fi
fi

#-----------------------------------------------------------------------
# Site URL (-u|--url=|ARG_URL|URL)
#-----------------------------------------------------------------------
if [[ $ARG_URL == "" ]]; then
    # Ask for the new URL 
    run_function common_read_user_input "Please enter the Site URL:"

    URL=$USER_INPUT_RESPONSE
else
    URL=${ARG_URL}
fi

# Clean up url
run_function domain_get_domain_from_url $URL
LOCAL_URL=$DOMAIN_URL_RESPONSE

#-----------------------------------------------------------------------
# Check site URL folder at destination
#-----------------------------------------------------------------------
LOCAL_SITE_FULL_PATH=${DESTINATION_FOLDER%/}"/"$(echo ${LOCAL_URL} | cut -f1 -d",")

# Check if folder exists
run_function check_folder_exists $LOCAL_SITE_FULL_PATH

# Result from folder exists function
if [[ "$FOLDER_EXIST" == false ]]; then
    # Stop execution if folder does not exist
    echoerror "The destination folder does not exists at '$LOCAL_SITE_FULL_PATH'."
fi

#-----------------------------------------------------------------------
# Stop docker-composer services for the new site
#-----------------------------------------------------------------------
run_function docker_compose_stop "${LOCAL_SITE_FULL_PATH%/}/compose"

if [[ "$ERROR_DOCKER_COMPOSE_STOP" == true ]]; then
    echoerror "There was an error stopping the service at '${LOCAL_SITE_FULL_PATH%/}/compose'"
fi

#-----------------------------------------------------------------------
# Backup
#-----------------------------------------------------------------------
# @todo - backup

#-----------------------------------------------------------------------
# Remove the site folder completely
#-----------------------------------------------------------------------
run_function system_safe_delete_folder $LOCAL_SITE_FULL_PATH ${BASE_SERVER_PATH} ${ALLOW_RUN_WITH_SUDO:-false}

exit 0
