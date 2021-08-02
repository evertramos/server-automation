#!/bin/bash

#-----------------------------------------------------------------------
#
# Revoke access from containers for a specific user in the ssh-bastion container (docker-ssh-bastion)
#
# Repo: https://github.com/evertramos/docker-ssh-bastion
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
log "$@"

#-----------------------------------------------------------------------
# Process arguments
#-----------------------------------------------------------------------
while [[ $# -gt 0 ]]
do
    case "$1" in

        # Sites container is an array, you might add it multiple times
        -s)
        ARG_SITES_CONTAINERS+=("${2}")
        if [[ $ARG_SITES_CONTAINERS == "" ]]; then
            echoerror "Invalid option for -s";
            break;
        fi
        shift 2
        ;;
        --site-container=*)
        ARG_SITES_CONTAINERS+=("${1#*=}")
        if [[ $ARG_SITES_CONTAINERS == "" ]]; then
            echoerror "Invalid option for --site-container";
            break;
        fi
        shift 1
        ;;

        # Username
        -u)
        ARG_USER_NAME="${2}"
        if [[ $ARG_USER_NAME == "" ]]; then
            echoerror "Invalid option for -u";
            break;
        fi
        shift 2
        ;;
        --user-name=*)
        ARG_USER_NAME="${1#*=}"
        if [[ $ARG_USER_NAME == "" ]]; then
            echoerror "Invalid option for --user-name";
            break;
        fi
        shift 1
        ;;

        # Revoke from all containers
        --all-containers)
        REVOKE_FROM_ALL_CONTAINERS=true
        shift 1
        ;;

        # Other options
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
        usage_revokeuseraccess
        ;;
        *)
        echoerror "Unknown argument: $1"
        usage_revokeuseraccess
        exit 0
        ;;
    esac
done

#-----------------------------------------------------------------------
# Initial check - DO NOT CHANGE SETTINGS BELOW
#-----------------------------------------------------------------------

# Check if there is an .env file in local folder
#run_function check_local_env_file

# Specific PID File if needs to run multiple scripts
LOCAL_NEW_PID_FILE=${PID_FILE_NEW_SITE:-".ssh_revoke_user_access.pid"}
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

    # If any service was started make sure to stop it
#    if [[ "$ACTION_DOCKER_COMPOSE_STARTED" == true ]]; then
#        [[ "$SILENT" != true ]] && echowarning "[undo] Starting docker-compose service '$LOCAL_SITE_FULL_PATH'."
#        run_function docker_compose_stop "${LOCAL_SITE_FULL_PATH%/}/compose"
#        ACTION_DOCKER_COMPOSE_STARTED=false
#    fi

    exit 0
}

#-----------------------------------------------------------------------
# Arguments validation and variables fulfillment
#
# There is a few required arguments in this script, but you may run it without
# any arguments informed, when you will be prompted to inform required args.
# But I really would like you to try it with all required arguments! 🔥
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Username (-u|--user-name=|ARG_USER_NAME|USER_NAME)
#
# The username will be used to connect a user from outside of your network
# into the ssh-bastion container, where will be able to connect to other
# containers in your docker network, only those you granted access to
#-----------------------------------------------------------------------
if [[ $ARG_USER_NAME == "" ]]; then

    # Request user input - username
    run_function common_read_user_input "Please enter the username:"

    # Check if user input is empty
    if [[ $USER_INPUT_RESPONSE == "" ]]; then
        echoerror "You must inform a valid username. No actions taken. Please run the script again and inform a username or use ---user-name."
    else
        echoinfo "USERNAME: $USER_INPUT_RESPONSE"
        USER_NAME=$(echo ${USER_INPUT_RESPONSE} | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]')
    fi
else
    USER_NAME=$(echo $ARG_USER_NAME | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]')
fi

#-----------------------------------------------------------------------
# List all containers from your environment (--all-containers|REVOKE_FROM_ALL_CONTAINERS)
#
# If you set this option, the script will loop all containers in your network
# to make sure the user does not have access to any container, if you have
# many containers this might some time to finish, use with caution!
#-----------------------------------------------------------------------
if [[ "$REVOKE_FROM_ALL_CONTAINERS" == true ]]; then

    # Get list of containers
    run_function docker_list_container

    SITES_CONTAINERS=(${DOCKER_LIST_CONTAINER_RESPONSE[@]})
else
    #-----------------------------------------------------------------------
    # Sites containers' name (-s|--site-container=|ARG_SITES_CONTAINERS [ARRAY])
    #
    # Specify which containers the user must have its access revoked from,
    # this option will be overwritten if you set --all-containers, for
    # better performance always specify the containers in the script
    #-----------------------------------------------------------------------
    if [[ $ARG_SITES_CONTAINERS == "" ]]; then

        # Get list of containers
        run_function docker_list_container

        # Show running site to be chosen by the user
        run_function select_multiple_data "${DOCKER_LIST_CONTAINER_RESPONSE[*]}"

        SITES_CONTAINERS=(${USER_MULTIDATA_SELECTIONS[@]})
    else
        SITES_CONTAINERS=("${ARG_SITES_CONTAINERS[@]}")
    fi
fi

# Check if Sites Container is empty
if [[ $SITES_CONTAINERS == "" ]]; then
    echoerror "Site must be informed in order to revoke user access. Please use --site-container option. \
      \nYou might set it multiple times as --site-container=site1 --site-container=site2 --site-container=site3 \
      \nor choose as many containers as you need from the list"
fi

#-----------------------------------------------------------------------
# Confirm action
#-----------------------------------------------------------------------
if [[ ! "$SILENT" == true  ]] || [[ ! "$REPLY_YES" == true ]]; then
    if [[ "$REVOKE_FROM_ALL_CONTAINERS" == true ]]; then
        run_function confirm_user_action "You are revoking '$USER_NAME' access from all containers. Are you sure you want to continue?" true
    else
        SITE_CONTAINER_STRING=${SITES_CONTAINERS[*]}
        run_function confirm_user_action "You are revoking '$USER_NAME' access to container(s) '${SITE_CONTAINER_STRING// / - }'. \
          \nAre you sure you want to continue?" true
    fi
fi

#-----------------------------------------------------------------------
# Loop through the sites containers and add users' key to the main user
#-----------------------------------------------------------------------
for SITE_CONTAINER in "${SITES_CONTAINERS[@]}"; do

    # Check if site is running
    run_function docker_check_container_is_running $SITE_CONTAINER

    if [[ "$CONTAINER_RUNNING" == true ]]; then
        # Remove SSH Pub Key to Site Container for the specified user
        run_function docker_container_remove_user_ssh_key $SITE_CONTAINER $USER_NAME
    else
        echowarning "Container '$SITE_CONTAINER' is not running."
    fi
done

#-----------------------------------------------------------------------
# Final message
#-----------------------------------------------------------------------
if [[ ! "$SILENT" == true  ]]; then
    if [[ "$REVOKE_FROM_ALL_CONTAINERS" == true ]]; then
        echosuccess "User '$USER_NAME' does not have access to any container in your network."
    else
        SITE_CONTAINER_STRING=${SITES_CONTAINERS[*]}
        echosuccess "User '$USER_NAME' does not have acces to container(s) '${SITE_CONTAINER_STRING// / - }'. "
    fi
fi

exit 0
