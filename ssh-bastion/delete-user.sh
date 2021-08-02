#!/bin/bash

#-----------------------------------------------------------------------
#
# Delete user from the ssh-bastion container (docker-ssh-bastion)
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

         # ssh-bastion container name
         -c)
         ARG_SSH_BASTION="${2}"
         if [[ $ARG_SSH_BASTION == "" ]]; then
             echoerror "Invalid option for -c";
             break;
         fi
         shift 2
         ;;
         --ssh-bastion=*)
         ARG_SSH_BASTION="${1#*=}"
         if [[ $ARG_SSH_BASTION == "" ]]; then
             echoerror "Invalid option for --ssh-bastion";
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

        # Do not run the revoke-user-access script
        --remove-user-only)
        REMOVE_USER_ONLY=true
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
        usage_deleteuser
        ;;
        *)
        echoerror "Unknown argument: $1"
        usage_deleteuser
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
LOCAL_NEW_PID_FILE=${PID_FILE_NEW_SITE:-".ssh_delete_user.pid"}
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
# ssh-bastion container name (-c|--ssh-bastion=|ARG_SSH_BASTION|SSH_BASTION)
#
# This is the container that holds all ssh connections from external network,
# it should not have docker socket mounted, or you might face a great risk
# of being hacked, once your user might gain access to your host server ⚠
#-----------------------------------------------------------------------
SSH_BASTION="${ARG_SSH_BASTION:-ssh-bastion}"

# Check if ssh-bastion exists in your environment
run_function docker_check_container_exists $SSH_BASTION

if [[ "$DOCKER_CONTAINER_EXISTS" != true ]]; then
    echoerror "It seems the ssh-bastion does not exist in your environment under the name '$SSH_BASTION', if you changed the \
      \ndefault name for the ssh-bastion, please use the option '--ssh-bastion=YOUR_CONTAINER_NAME'."
fi

# Check if SSH_BASTION is running
run_function docker_check_container_is_running $SSH_BASTION

if [[ "$DOCKER_CONTAINER_IS_RUNNING" != true ]]; then
    echoerror "The container '$SSH_BASTION' exist in your environment but it seems it's not running. But if you do \
      \nhave it running please inform the correct container name by the option '--ssh-bastion=YOUR_CONTAINER_NAME'."
fi

#-----------------------------------------------------------------------
# Username (-u|--user-name=|ARG_USER_NAME|USER_NAME)
#
# The username that will be deleted from the ssh-bastion container, this
# action can not be undone. Once deleted the user will have no access
# to ssh-bastion or any container in your docker environment or host
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

# Check if user already exists in the ssh-bastion
run_function docker_check_user_exists_in_container $SSH_BASTION $USER_NAME
if [[ "$DOCKER_USER_EXISTS_IN_CONTAINER" != true ]]; then
    echoerror "The user '$USER_NAME' does not exist in container '$SSH_BASTION'.\
      \n'$USER_NAME' no longer has access to '$SSH_BASTION' neither other containers in your network."
fi

#-----------------------------------------------------------------------
# Confirm action
#-----------------------------------------------------------------------
if [[ "$SILENT" != true ]] && [[ "$REPLY_YES" != true ]]; then
    run_function confirm_user_action "You are removing user '$USER_NAME' from container '$SSH_BASTION'. \
      \nAre you sure you want to continue?" true
fi

#-----------------------------------------------------------------------
# Delete user in ssh-bastion container
#-----------------------------------------------------------------------
run_function docker_delete_user $SSH_BASTION $USER_NAME

#-----------------------------------------------------------------------
# Revoke access from all containers, unless if you set --remove-user-only
#-----------------------------------------------------------------------
if [[ "$REMOVE_USER_ONLY" != true ]]; then
    if [[ "$SILENT" == true ]]; then
        $SCRIPT_PATH/revoke-user-access.sh "--user-name=$USER_NAME" "--all-sites" "--silent"
    else
        $SCRIPT_PATH/revoke-user-access.sh "--user-name=$USER_NAME" "--all-sites"
    fi
fi 

exit 0
