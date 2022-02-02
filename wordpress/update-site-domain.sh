#!/bin/bash

#-----------------------------------------------------------------------
#
# WordPress script - update domain
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
# =) unless you have read the following with good care! =)
# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
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
printf "${energy} Start execution '${SCRIPT_PATH}/${SCRIPT_NAME} "
echo "$@':"
log "$@"

#-----------------------------------------------------------------------
# Process arguments
#-----------------------------------------------------------------------
while [[ $# -gt 0 ]]
do
    case "$1" in

        # Sites folder - where all sites folder are located in server
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

        # Current site/url/domain name which site's folder is named
        -u)
        ARG_URL_FROM="${2}"
        if [[ $ARG_URL_FROM == "" ]]; then
            echoerror "Invalid option for -cu";
            break;
        fi
        shift 2
        ;;
        -cu)
        ARG_URL_FROM="${2}"
        if [[ $ARG_URL_FROM == "" ]]; then
            echoerror "Invalid option for -cu";
            break;
        fi
        shift 2
        ;;
        --current-url=*)
        ARG_URL_FROM="${1#*=}"
        if [[ $ARG_URL_FROM == "" ]]; then
            echoerror "Invalid option for --current-url";
            break;
        fi
        shift 1
        ;;
        --from=*)
        ARG_URL_FROM="${1#*=}"
        if [[ $ARG_URL_FROM == "" ]]; then
            echoerror "Invalid option for --from";
            break;
        fi
        shift 1
        ;;

        # New site/url/domain name which site's folder will be named
        -nu)
        ARG_URL_TO="${2}"
        if [[ $ARG_URL_TO == "" ]]; then
            echoerror "Invalid option for -nu";
            break;
        fi
        shift 2
        ;;
        -to)
        ARG_URL_TO="${2}"
        if [[ $ARG_URL_TO == "" ]]; then
            echoerror "Invalid option for -nu";
            break;
        fi
        shift 2
        ;;
        --new-url=*)
        ARG_URL_TO="${1#*=}"
        if [[ $ARG_URL_TO == "" ]]; then
            echoerror "Invalid option for --new-url";
            break;
        fi
        shift 1
        ;;
        --to=*)
        ARG_URL_TO="${1#*=}"
        if [[ $ARG_URL_TO == "" ]]; then
            echoerror "Invalid option for --to";
            break;
        fi
        shift 1
        ;;

        # Extra URL for the site
        -eu)
        ARG_EXTRA_URL="${2}"
        if [[ $ARG_EXTRA_URL == "" ]]; then
            echoerror "Invalid option for -eu";
            break;
        fi
        shift 2
        ;;
        --extra-url=*)
        ARG_EXTRA_URL="${1#*=}"
        if [[ $ARG_EXTRA_URL == "" ]]; then
            echoerror "Invalid option for --extra-url";
            break;
        fi
        shift 1
        ;;

        # @todo - add backup option before run this function - option might be used to send it to 'cold storage'
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

        # Activate domain with 'www'
        --with-www)
        WITH_WWW=true
        shift 1
        ;;


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
        usage_update_site_domain
        exit 0
        ;;
        *)
        echoerror "Unknown argument: $1" false
        usage_update_site_domain
        exit 0
        ;;
    esac
done

#-----------------------------------------------------------------------
# Initial check - DO NOT CHANGE SETTINGS BELOW
#-----------------------------------------------------------------------

# Specific PID File if needs to run multiple scripts
LOCAL_NEW_PID_FILE=${LOCAL_SCRIPT_PID_FILE_NAME:-".update_site_domain.pid"}
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
# [function] Undo script actions
#-----------------------------------------------------------------------
local_undo_restore()
{
    echoerror "It seems something went wrong running '$SCRIPT_NAME'.\nWe will try to UNDO all actions done by this script.\nPlease make sure everything was back in place as when you started." false

    # If folder was renamed
    if [[ "$FOLDER_RENAMED" == true ]]; then
        [[ "$SILENT" != true ]] && echowarning "[undo] Renaming folder to original name at '$LOCAL_URL_FROM_FULL_PATH'."
        mv ${LOCAL_URL_TO_FULL_PATH%/} ${LOCAL_URL_FROM_FULL_PATH%/}
        FOLDER_RENAMED=false
    fi

    # If docker-composed was stopped
    if [[ "$ACTION_DOCKER_COMPOSE_STOPPED" == true ]]; then
        [[ "$SILENT" != true ]] && echowarning "[undo] Starting docker-compose services at '$LOCAL_URL_FROM_FULL_PATH'."
        run_function docker_compose_start "${LOCAL_URL_FROM_FULL_PATH%/}/compose"
        ACTION_DOCKER_COMPOSE_STARTED_IN_LOCAL_UNDO_RESTORE=true
        ACTION_DOCKER_COMPOSE_STOPPED=false
    fi

    # If domain was replaced in database
    if [[ "$ACTION_DOCKER_COMPOSE_SEARCH_REPLACED" == true ]]; then
        [[ "$SILENT" != true ]] && echowarning "[undo] Replacing strings in database '$LOCAL_URL_FROM_FULL_PATH'."
        if [[ "$ACTION_DOCKER_COMPOSE_STARTED_IN_LOCAL_UNDO_RESTORE" == true ]]; then
            # If the service was just started wait 20 seconds before run the search and replace script
            sleep 20
        fi
        run_function docker_compose_wpcli_search_replace "${LOCAL_URL_FROM_FULL_PATH%/}/compose" $LOCAL_URL_TO $LOCAL_URL_FROM
        ACTION_DOCKER_COMPOSE_SEARCH_REPLACED=false
    fi

    exit 0
}

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
# Current site URL (-u|-nu|--current-url|--from=|ARG_URL_FROM|URL_FROM)
#-----------------------------------------------------------------------
if [[ $ARG_URL_FROM == "" ]]; then
    # Ask for the current URL
    run_function common_read_user_input "Please enter the current site URL:"

    #---
    # @todo - improve here, give user option to list all sites in server
    #---

    URL_FROM=$USER_INPUT_RESPONSE
else
    URL_FROM=${ARG_URL_FROM}
fi

# Clean up url
run_function domain_get_domain_from_url $URL_FROM
LOCAL_URL_FROM=$DOMAIN_URL_RESPONSE

# Create full file path for current site folder
LOCAL_URL_FROM_FULL_PATH=${DESTINATION_FOLDER%/}"/"$(echo ${LOCAL_URL_FROM} | cut -f1 -d",")

#-----------------------------------------------------------------------
# Check current site URL folder exists at destination
#-----------------------------------------------------------------------
# Check if folder exists
run_function check_folder_exists $LOCAL_URL_FROM_FULL_PATH

# Result from folder exists function
if [[ "$FOLDER_EXIST" == false ]]; then
    # Stop execution if folder does not exist
    echoerror "The current site folder does not exists at '$LOCAL_URL_FROM_FULL_PATH'."
fi

#-----------------------------------------------------------------------
# New site URL (-nu|-to|--new-url|--to=|ARG_URL_TO|URL_FROM)
#-----------------------------------------------------------------------
if [[ $ARG_URL_TO == "" ]]; then
    # Ask for the new URL
    run_function common_read_user_input "Please enter the new site URL:"

    URL_TO=$USER_INPUT_RESPONSE
else
    URL_TO=${ARG_URL_TO}
fi

# Clean up url
run_function domain_get_domain_from_url $URL_TO
LOCAL_URL_TO=$DOMAIN_URL_RESPONSE

# Create full file path for destination folder
LOCAL_URL_TO_FULL_PATH=${DESTINATION_FOLDER%/}"/"$(echo ${LOCAL_URL_TO} | cut -f1 -d",")

#-----------------------------------------------------------------------
# Check new site URL folder exists at destination
#-----------------------------------------------------------------------
# Check if folder exists
run_function check_folder_exists $LOCAL_URL_TO_FULL_PATH

# Result from folder exists function
if [[ "$FOLDER_EXIST" == true ]]; then
    # Stop execution if folder alredy exists
    echoerror "The new site folder already exists at '$LOCAL_URL_TO_FULL_PATH'."
fi

#-----------------------------------------------------------------------
# Backup
#-----------------------------------------------------------------------
# @todo - improve here to create a backup of the whole site before any changes

#-----------------------------------------------------------------------
# Replace current domain with new one using wp-cli
#-----------------------------------------------------------------------
run_function docker_compose_wpcli_search_replace "${LOCAL_URL_FROM_FULL_PATH%/}/compose" $LOCAL_URL_FROM $LOCAL_URL_TO

ACTION_DOCKER_COMPOSE_SEARCH_REPLACED=true

if [[ "$ERROR_DOCKER_COMPOSE_WPCLI_SEARCH_REPLACE" == true ]]; then
    echoerror "There was an error replacing the new domain at '${LOCAL_URL_FROM_FULL_PATH%/}/compose'" false
    local_undo_restore
fi

#-----------------------------------------------------------------------
# Stop docker-composer services for the current site
#-----------------------------------------------------------------------
run_function docker_compose_stop "${LOCAL_URL_FROM_FULL_PATH%/}/compose"

ACTION_DOCKER_COMPOSE_STOPPED=true

if [[ "$ERROR_DOCKER_COMPOSE_STOP" == true ]]; then
    echoerror "There was an error stopping the service at '${LOCAL_URL_FROM_FULL_PATH%/}/compose'" false
    local_undo_restore
fi

#-----------------------------------------------------------------------
# Rename folder with new domain
#-----------------------------------------------------------------------
mv ${LOCAL_URL_FROM_FULL_PATH%/} ${LOCAL_URL_TO_FULL_PATH%/}
FOLDER_RENAMED=true

# Check if folder exists
run_function check_folder_exists ${LOCAL_URL_TO_FULL_PATH%/}

# Result from folder exists function
if [[ "$FOLDER_EXIST" == false ]]; then
    # Undo if folder does not exist
    echoerror "The new site folder could not be created at '${LOCAL_URL_TO_FULL_PATH%/}'." false
    local_undo_restore
fi

#-----------------------------------------------------------------------
# Update .env file with new domain
# and check the extra url argument
# Extra URL (-eu|-extra-url=|ARG_EXTRA_URL|EXTRA_URL)
#-----------------------------------------------------------------------
if [[ "$WITH_WWW" == true ]] && [[ ! $ARG_EXTRA_URL == '' ]]; then
    run_function env_update_variable "${LOCAL_URL_TO_FULL_PATH%/}/compose" "DOCKER_WORDPRESS_DOMAINS" "$LOCAL_URL_TO,www.$LOCAL_URL_TO,$ARG_EXTRA_URL" ".env" false true
elif [[ "$WITH_WWW" == true ]] && [[ $ARG_EXTRA_URL == '' ]]; then
    run_function env_update_variable "${LOCAL_URL_TO_FULL_PATH%/}/compose" "DOCKER_WORDPRESS_DOMAINS" "$LOCAL_URL_TO,www.$LOCAL_URL_TO" ".env" false true
elif [[ ! "$WITH_WWW" == true ]] && [[ ! $ARG_EXTRA_URL == '' ]]; then
    run_function env_update_variable "${LOCAL_URL_TO_FULL_PATH%/}/compose" "DOCKER_WORDPRESS_DOMAINS" "$LOCAL_URL_TO,$ARG_EXTRA_URL" ".env" false true
else
    run_function env_update_variable "${LOCAL_URL_TO_FULL_PATH%/}/compose" "DOCKER_WORDPRESS_DOMAINS" "$LOCAL_URL_TO" ".env" false true
fi

if [[ "$ENV_UPDATE_VARIABLE_ERROR" == true ]]; then
    # Undo if there was an error in env update
    echoerror "We could not update the .env file at '${LOCAL_URL_TO_FULL_PATH%/}'." false
    local_undo_restore
fi

#-----------------------------------------------------------------------
# Start docker-composer services for the new site
#-----------------------------------------------------------------------
run_function docker_compose_start "${LOCAL_URL_TO_FULL_PATH%/}/compose"

if [[ "$ERROR_DOCKER_COMPOSE_STOP" == true ]]; then
    echoerror "There was an error stopping the service at '${LOCAL_URL_TO_FULL_PATH%/}/compose'" false
    local_undo_restore
fi

[[ ! "$SILENT" == true ]] && echosuccess "[success=true] Your new site '$URL_TO' should be running by now!"

exit 0
