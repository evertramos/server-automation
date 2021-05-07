#!/bin/bash

# ----------------------------------------------------------------------
#
# Config script - Configure the Severt Automation base settings
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

#-----------------------------------------------------------------------
# Process arguments
#-----------------------------------------------------------------------
while [[ $# -gt 0 ]]
do
    case "$1" in
        -b)
        ARG_BASE_FOLDER="${2}"
        if [[ $ARG_BASE_FOLDER == "" ]]; then
            echoerror "Invalid option for -b"
            break;
        fi
        shift 2
        ;;
        --base-folder=*)
        ARG_BASE_FOLDER="${1#*=}"
        if [[ $ARG_BASE_FOLDER == "" ]]; then
            echoerror "Invalid option for --base-folder=''"
            break;
        fi
        shift 1
        ;;
        -sf)
        ARG_SITES_FOLDER="${2}"
        if [[ $ARG_SITES_FOLDER == "" ]]; then
            echoerror "Invalid option for -sf"
            break;
        fi
        shift 2
        ;;
        --sites-folder=*)
        ARG_SITES_FOLDER="${1#*=}"
        if [[ $ARG_SITES_FOLDER == "" ]]; then
            echoerror "Invalid option for --sites-folder=''"
            break;
        fi
        shift 1
        ;;
        -cf)
        ARG_CLONES_FOLDER="${2}"
        if [[ $ARG_CLONES_FOLDER == "" ]]; then
            echoerror "Invalid option for -cf"
            break;
        fi
        shift 2
        ;;
        --clones-folder=*)
        ARG_CLONES_FOLDER="${1#*=}"
        if [[ $ARG_CLONES_FOLDER == "" ]]; then
            echoerror "Invalid option for --clones-folder=''"
            break;
        fi
        shift 1
        ;;
        -bf)
        ARG_BACKUP_FOLDER="${2}"
        if [[ $ARG_BACKUP_FOLDER == "" ]]; then
            echoerror "Invalid option for -bf"
            break;
        fi
        shift 2
        ;;
        --backup-folder=*)
        ARG_BACKUP_FOLDER="${1#*=}"
        if [[ $ARG_BACKUP_FOLDER == "" ]]; then
            echoerror "Invalid option for --backup-folder=''"
            break;
        fi
        shift 1
        ;;
        -lf)
        ARG_LOG_FOLDER="${2}"
        if [[ $ARG_LOG_FOLDER == "" ]]; then
            echoerror "Invalid option for -lf"
            break;
        fi
        shift 2
        ;;
        --log-folder=*)
        ARG_LOG_FOLDER="${1#*=}"
        if [[ $ARG_LOG_FOLDER == "" ]]; then
            echoerror "Invalid option for --log-folder=''"
            break;
        fi
        shift 1
        ;;

        # Proxy options
        -po)
        ARG_PROXY_OPTION="${2}"
        if [[ $ARG_PROXY_OPTION == "" ]]; then
            echoerror "Invalid option for -po"
            break;
        fi
        shift 2
        ;;
        --proxy-option=*)
        ARG_PROXY_OPTION="${1#*=}"
        if [[ $ARG_PROXY_OPTION == "" ]]; then
            echoerror "Invalid option for --proxy-option=''"
            break;
        fi
        shift 1
        ;;
        -pf)
        ARG_PROXY_FOLDER="${2}"
        if [[ $ARG_PROXY_FOLDER == "" ]]; then
            echoerror "Invalid option for -pf"
            break;
        fi
        shift 2
        ;;
        --proxy-folder=*)
        ARG_PROXY_FOLDER="${1#*=}"
        if [[ $ARG_PROXY_FOLDER == "" ]]; then
            echoerror "Invalid option for --proxy-folder=''"
            break;
        fi
        shift 1
        ;;
        -pcf)
        ARG_PROXY_COMPOSE_FOLDER="${2}"
        if [[ $ARG_PROXY_COMPOSE_FOLDER == "" ]]; then
            echoerror "Invalid option for -pcf"
            break;
        fi
        shift 2
        ;;
        --proxy-compose-folder=*)
        ARG_PROXY_COMPOSE_FOLDER="${1#*=}"
        if [[ $ARG_PROXY_COMPOSE_FOLDER == "" ]]; then
            echoerror "Invalid option for --proxy-compose-folder=''"
            break;
        fi
        shift 1
        ;;
        -pdf)
        ARG_PROXY_DATA_FOLDER="${2}"
        if [[ $ARG_PROXY_DATA_FOLDER == "" ]]; then
            echoerror "Invalid option for -pdf"
            break;
        fi
        shift 2
        ;;
        --proxy-data-folder=*)
        ARG_PROXY_DATA_FOLDER="${1#*=}"
        if [[ $ARG_PROXY_DATA_FOLDER == "" ]]; then
            echoerror "Invalid option for --proxy-data-folder=''"
            break;
        fi
        shift 1
        ;;

        # Backup options
        -bs)
        ARG_BACKUP_SERVER="${2}"
        if [[ $ARG_BACKUP_SERVER == "" ]]; then
            echoerror "Invalid option for -bs"
            break
        fi
        shift 2
        ;;
        --backup-server=*)
        ARG_BACKUP_SERVER="${1#*=}"
        if [[ $ARG_BACKUP_SERVER == "" ]]; then
            echoerror "Invalid option for --backup-server"
            break
        fi
        shift 1
        ;;

        # Server options
        -ip)
        ARG_IP_ADDRESS="${2}"
        if [[ $ARG_IP_ADDRESS == "" ]]; then
            echoerror "Invalid option for -ip"
            break
        fi
        shift 2
        ;;
        --ip-address=*)
        ARG_IP_ADDRESS="${1#*=}"
        if [[ $ARG_IP_ADDRESS == "" ]]; then
            echoerror "Invalid option for --ip-address"
            break
        fi
        shift 1
        ;;
        --activate-ipv6)
        ACTIVATE_IPV6=true
        shift 1
        ;;
        -ipv6)
        ARG_IPv6_ADDRESS="${2}"
        if [[ $ARG_IPv6_ADDRESS == "" ]]; then
            echoerror "Invalid option for -ipv6"
            break
        fi
        shift 2
        ;;
        --ipv6-address=*)
        ARG_IPv6_ADDRESS="${1#*=}"
        if [[ $ARG_IPv6_ADDRESS == "" ]]; then
            echoerror "Invalid option for --ipv6-address"
            break
        fi
        shift 1
        ;;

        # DNS API options
        -dap)
        ARG_DNS_API_PROVIDER="${2}"
        if [[ $ARG_DNS_API_PROVIDER == "" ]]; then
            echoerror "Invalid option for -dap"
            break
        fi
        shift 2
        ;;
        --dns-api-provider=*)
        ARG_DNS_API_PROVIDER="${1#*=}"
        if [[ $ARG_DNS_API_PROVIDER == "" ]]; then
            echoerror "Invalid option for --dns-api-provider"
            break
        fi
        shift 1
        ;;
        -dak)
        ARG_DNS_API_KEY="${2}"
        if [[ $ARG_DNS_API_KEY == "" ]]; then
            echoerror "Invalid option for -dak"
            break
        fi
        shift 2
        ;;
        --dns-api-key=*)
        ARG_DNS_API_KEY="${1#*=}"
        if [[ $ARG_DNS_API_KEY == "" ]]; then
            echoerror "Invalid option for --dns-api-key"
            break
        fi
        shift 1
        ;;

        --update-only-specified-option)
        UPDATE_ONLY_SPECIFIED_OPTION=true
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
NEW_PID_FILE=${PID_FILE_NEW_SITE:-".config_script"}

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

    # If .env file was renamed (backup)
    if [[ "$ACTION_ENV_FILE_RENAMED" == true ]]; then
        [[ "$SILENT" != true ]] && echowarning "[undo] Renaming .env file '$LOCAL_BACKUP_ENV_FILE'."
        mv $LOCAL_BACKUP_ENV_FILE "$SCRIPT_PATH/../.env"
        ACTION_ENV_FILE_RENAMED=false
    fi

    exit 0
}

#-----------------------------------------------------------------------
# Check if the .env file was already configured for Server-Automation
#-----------------------------------------------------------------------
run_function check_server_automation_env_file_exists

# Result from function above
if [[ "$SERVER_AUTOMATION_ENV_FILE_EXISTS" == true ]]; then
  [[ "$SILENT" != true ]] && echowarning \
    "It seems Server Automation was already configured in this server, \
      \ncurrent settings will be replaced with new ones and we will NOT \
      \nbe able to restore previous version automatically, but check \
      \nthe .env files with a '.backup_' tag plus a date placed at: \
       \n\n'$SCRIPT_PATH/'\n"

  if [[ "$REPLY_YES" == true ]]; then
    LOCAL_BACKUP_OLD_ENV_FILE=true
  else
    run_function confirm_user_action "Are you sure you want to replace current settings for Server Automation?"
    [[ "$USER_ACTION_RESPONSE" == true ]] && LOCAL_BACKUP_OLD_ENV_FILE=true
  fi
fi

#-----------------------------------------------------------------------
# Verify checksum of files
#-----------------------------------------------------------------------
run_function md5_check_checksum "$SCRIPT_PATH/../" ".env.example" $MD5_SUM_ENV_EXAMPLE
if [[ ! "$MD5_CHECKSUM" == true ]] && [[ ! "$REPLY_YES" == true ]]; then

  run_function confirm_user_action \
    "We could not verify the checksum (md5) for the default .env file, \
        \nare you sure you want to continue?"
fi

#-----------------------------------------------------------------------
# Arguments validation and variables fulfillment
#-----------------------------------------------------------------------

LOCAL_BASE_SERVER_PATH
LOCAL_SITES_FOLDER
LOCAL_CLONE_FOLDER
LOCAL_BACKUP_FOLDER
LOCAL_LOG_FOLDER
LOCAL_PROXY_OPTION
LOCAL_PROXY_FOLDER
LOCAL_PROXY_COMPOSE_FOLDER
LOCAL_PROXY_DATA_FOLDER
LOCAL_BACKUP_SERVER
LOCAL_IPv4
LOCAL_IPv6
LOCAL_API_PROVIDER
LOCAL_API_KEY


#-----------------------------------------------------------------------
# NGINX-proxy service/container name
#
# Parameters: -pn | --proxy-name
#
# Final result:
#   - NGINX_PROXY_SERVICE_NAME
#
# Further action:
#   - LOCAL_STOP_AND_REMOVE_NGINX_PROXY_SERVICE_CONTAINER
#-----------------------------------------------------------------------
LOCAL_DEFAULT_NGINX_PROXY_SERVICE_NAME="proxy-web-auto"
if [[ $ARG_NGINX_PROXY_SERVICE_NAME == "" ]] && [[ ! "$REPLY_YES" == true ]]; then

  # Get user's response
  run_function common_read_user_input "Please enter the nginx-proxy service name (default: $LOCAL_DEFAULT_NGINX_PROXY_SERVICE_NAME):"

  LOCAL_NGINX_PROXY_SERVICE_NAME=${USER_INPUT_RESPONSE:-$LOCAL_DEFAULT_NGINX_PROXY_SERVICE_NAME}
else
  LOCAL_NGINX_PROXY_SERVICE_NAME=${ARG_NGINX_PROXY_SERVICE_NAME:-$LOCAL_DEFAULT_NGINX_PROXY_SERVICE_NAME}
fi

# Validate the name
run_function string_remove_all_special_char_string $LOCAL_NGINX_PROXY_SERVICE_NAME
NGINX_PROXY_SERVICE_NAME=${STRING_REMOVE_ALL_SPECIAL_CHAR_STRING_RESPONSE:-null}
[[ $NGINX_PROXY_SERVICE_NAME == null ]] && echoerror "The service name can not contain special chars, neither be empty"

# Check exists a container with this name
run_function docker_check_container_exists $NGINX_PROXY_SERVICE_NAME

if [[ "$DOCKER_CONTAINER_EXISTS" == true ]]; then
  # Check if there is a container running with this name
  run_function docker_check_container_is_running $NGINX_PROXY_SERVICE_NAME

  if [[ "$DOCKER_CONTAINER_IS_RUNNING" == true ]]; then
    [[ "$SILENT" != true ]] && echowarning \
      "The container '$NGINX_PROXY_SERVICE_NAME' is running in this server \
            \nmake sure you have unique names for each container. This script \
            \nmight stop and remove the container if you set '--yes' or reply \
            \n'yes' on the line below, but, there is no turn back on this action!"

    if [[ "$REPLY_YES" == true ]]; then
      LOCAL_STOP_AND_REMOVE_NGINX_PROXY_SERVICE_CONTAINER=true
    else
      run_function confirm_user_action \
        "The container '$NGINX_PROXY_SERVICE_NAME' is running in this server. We will \
                \nstop and REMOVE it, do you want to continue?"

      [[ "$USER_ACTION_RESPONSE" == true ]] && LOCAL_STOP_AND_REMOVE_NGINX_PROXY_SERVICE_CONTAINER=true
    fi
  else
    [[ "$SILENT" != true ]] && echowarning \
      "The container '$NGINX_PROXY_SERVICE_NAME' is exist in this server, but it is not running \
            \nmake sure you have unique names for each container. This script \
            \nmight stop and remove the container if you set '--yes' or reply \
            \n'yes' on the line below, but, there is no turn back on this action!"

    if [[ "$REPLY_YES" == true ]]; then
      LOCAL_STOP_AND_REMOVE_NGINX_PROXY_SERVICE_CONTAINER=true
    else
      run_function confirm_user_action \
        "The container '$NGINX_PROXY_SERVICE_NAME' exist in this server. We will \
                \nREMOVE it, do you want to continue?"

      [[ "$USER_ACTION_RESPONSE" == true ]] && LOCAL_STOP_AND_REMOVE_NGINX_PROXY_SERVICE_CONTAINER=true
    fi
    # We kept STOP and REMOVE because the stop function will not break the script even if the container isn't running
  fi
fi



#-----------------------------------------------------------------------
# Start actions! =)
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Backup .env file if exists
#-----------------------------------------------------------------------
if [[ "$LOCAL_BACKUP_OLD_ENV_FILE" == true ]]; then
  run_function backup_file "$SCRIPT_PATH/../.env"
  ACTION_ENV_FILE_RENAMED=true
  LOCAL_BACKUP_ENV_FILE=$BACKUP_FILE
fi

#-----------------------------------------------------------------------
# Create and update .env file for nginx-proxy
#-----------------------------------------------------------------------
cp "$SCRIPT_PATH/../.env.example" "$SCRIPT_PATH/../.env"

run_function local_update_env_file "$SCRIPT_PATH/../"



# ---

exit 0

