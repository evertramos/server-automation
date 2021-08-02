#!/bin/bash

#-----------------------------------------------------------------------
#
# Add user to the ssh-bastion container (docker-ssh-bastion)
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

        # User public key (ssh-key)
        -k)
        ARG_KEY_STRING="${2%/}"
        if [[ $ARG_KEY_STRING == "" ]]; then
            echoerror "Invalid option for -k";
            break;
        fi
        shift 2
        ;;
        --key-string=*)
        ARG_KEY_STRING="${1#*=}"
        ARG_KEY_STRING="${ARG_KEY_STRING%/}"
        if [[ $ARG_KEY_STRING == "" ]]; then
            echoerror "Invalid option for --key-string";
            break;
        fi
        shift 1
        ;;

        # Instead user key you might inform a key file
        -f)
        ARG_KEY_FILE="${2%/}"
        if [[ $ARG_KEY_FILE == "" ]]; then
            echoerror "Invalid option for -f";
            break;
        fi
        shift 2
        ;;
        --key-file=*)
        ARG_KEY_FILE="${1#*=}"
        ARG_KEY_FILE="${ARG_KEY_FILE%/}"
        if [[ $ARG_KEY_FILE == "" ]]; then
            echoerror "Invalid option for --key-file";
            break;
        fi
        shift 1
        ;;

        # Generate new key for the user - @todo (improvement)
#        --key-generate)
#        GENERATE_KEY=true
#        shift 1
#        ;;

        # Do not run the user-grant-access script
        --add-user-only)
        ADD_USER_ONLY=true
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
        usage_adduser
        ;;
        *)
        echoerror "Unknown argument: $1"
        usage_adduser
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
LOCAL_NEW_PID_FILE=${PID_FILE_NEW_SITE:-".ssh_add_user.pid"}
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
# Sites container name (-s|--site-container=|ARG_SITES_CONTAINERS [ARRAY])
#
# This options is used to inform which containers the newly created user
# will have access granted, so you might inform in this script and do
# one time job. All validations are done in grant-user-access script
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# ssh-bastion container name (-c|--ssh-bastion=|ARG_SSH_BASTION|SSH_BASTION)
#
# This is the container which will hold all ssh connections, it should not
# have the docker socket mounted into it, or you might face a great risk
# of being hacked, once user might gain access to your host server ⚠
#-----------------------------------------------------------------------
SSH_BASTION="${ARG_SSH_BASTION:-ssh-bastion}"

# Check if ssh-bastion exists in your environment
run_function docker_check_container_exists $SSH_BASTION

if [[ "$DOCKER_CONTAINER_EXISTS" != true ]]; then
    echoerror "You must have ssh-bastion running, and '$SSH_BASTION' does not exist in this server. \
      \nPlease inform the correct container name for this service or check the link below: \
      \nhttps://github.com/evertramos/docker-ssh-bastion/ \
      \nif you do have it runnig please inform the container name by the option '--ssh-bastion=YOUR_CONTAINER_NAME'."
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

# Check if user already exists in the ssh-bastion
run_function docker_check_user_exists_in_container $SSH_BASTION $USER_NAME
if [[ "$DOCKER_USER_EXISTS_IN_CONTAINER" == true ]]; then
    echoerror "The user '$USER_NAME' already exist in container '$SSH_BASTION'.\
      \nIf you want to grant access to this user to any other container in your environment, please run the following: \
      \n./grant-user-access.sh --user-name=$USER_NAME"
fi

#-----------------------------------------------------------------------
# User's key (-k|--key-string=|ARG_KEY_STRING|USER_SSH_KEY)
#            (-f|--key-file=|ARG_KEY_FILE|USER_SSH_KEY)
#
# The user created will only have access the ssh-bastion using a ssh-key,
# so, you must get the user's public key or generate one for him before
# run this script. This is a secure matter, please don't ignore it.
#-----------------------------------------------------------------------
if [[ $ARG_KEY_STRING == "" ]] && [[ $ARG_KEY_FILE == "" ]]; then
    
    # Get pasted user ssh pub key
    run_function common_read_user_input "Please paste user's ssh pub key (${red}SINGLE LINE${reset}) or hit ENTER to exit:"

    if [[ $USER_INPUT_RESPONSE == "" ]]; then 
        echoerror "You must past the user's ssh pub key or inform one of the options: --key-string='your_ssh_key_string' or --key-file='path_to_ssh_key_file'."
    else
        ARG_KEY_STRING=$USER_INPUT_RESPONSE
    fi
    
elif [[ $ARG_KEY_STRING != "" ]] && [[ $ARG_KEY_FILE != "" ]]; then
    echoerror "You must inform only one of the options: --key-string='your_ssh_key_string' or --key-file='path_to_ssh_key_file'"
fi

# Get the USER_SSH_KEY
[[ $ARG_KEY_STRING != "" ]] && USER_SSH_KEY=$ARG_KEY_STRING
[[ $ARG_KEY_FILE != "" ]] && USER_SSH_KEY=$(cat ${ARG_KEY_FILE})

#-----------------------------------------------------------------------
# Confirm action
#-----------------------------------------------------------------------
if [[ "$SILENT" != true ]] && [[ "$REPLY_YES" != true ]]; then
    run_function confirm_user_action "You are creating user '$USER_NAME' in container '$SSH_BASTION'. \
      \nAre you sure you want to continue?" true
fi

#-----------------------------------------------------------------------
# Create user in ssh-bastion container
#-----------------------------------------------------------------------
run_function docker_add_user_with_key $SSH_BASTION $USER_NAME "$USER_SSH_KEY"

# Verify if user was created as expected
run_function docker_check_user_exists_in_container $SSH_BASTION $USER_NAME
if [[ ! "$DOCKER_USER_EXISTS_IN_CONTAINER" == true ]]; then
    echoerror "The user '$USER_NAME' could not be created in container '$SSH_BASTION' for an unexppected reason. \
      \nPlease try again with option '--debug' to see if there is any specific errors."
fi

#-----------------------------------------------------------------------
# Grant access to the newly created user, unless if you set --add-user-only
#-----------------------------------------------------------------------
if [[ "$ADD_USER_ONLY" != true ]]; then
    if [[ "$SILENT" == true ]] && [[ "$REPLY_YES" == true ]]; then
        $SCRIPT_PATH/grant-user-access.sh "--ssh-bastion=$SSH_BASTION" "--user-name=$USER_NAME" "--sites-from-adduser-script=${ARG_SITES_CONTAINERS[*]}" "--silent" "--yes"
    elif [[ "$REPLY_YES" == true ]]; then
        $SCRIPT_PATH/grant-user-access.sh "--ssh-bastion=$SSH_BASTION" "--user-name=$USER_NAME" "--sites-from-adduser-script=${ARG_SITES_CONTAINERS[*]}" "--yes"
    elif [[ "$SILENT" == true ]]; then
        $SCRIPT_PATH/grant-user-access.sh "--ssh-bastion=$SSH_BASTION" "--user-name=$USER_NAME" "--sites-from-adduser-script=${ARG_SITES_CONTAINERS[*]}" "--silent"
    else
        $SCRIPT_PATH/grant-user-access.sh "--ssh-bastion=$SSH_BASTION" "--user-name=$USER_NAME" "--sites-from-adduser-script=${ARG_SITES_CONTAINERS[*]}"
    fi
fi 

exit 0
