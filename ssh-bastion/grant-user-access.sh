#!/bin/bash

#-----------------------------------------------------------------------
#
# Grant access to other containers for a specific user in the ssh-bastion container (docker-ssh-bastion)
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

        # User's public key
        -k)
        ARG_KEY_STRING="${2}"
        if [[ $ARG_KEY_STRING == "" ]]; then
            echoerror "Invalid option for -k";
            break;
        fi
        shift 2
        ;;
        --key-string=*)
        ARG_KEY_STRING="${1#*=}"
        if [[ $ARG_KEY_STRING == "" ]]; then
            echoerror "Invalid option for --key-string";
            break;
        fi
        shift 1
        ;;

        # Array of sites coming from the add user script
        --sites-from-adduser-script=*)
        ARG_SITES_FROM_ADDUSER_SCRIPT=(${1#*=})
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
        usage_grantuseraccess
        ;;
        *)
        echoerror "Unknown argument: $1"
        usage_grantuseraccess
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
LOCAL_NEW_PID_FILE=${PID_FILE_NEW_SITE:-".ssh_grant_user_access.pid"}
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
# This is the container which will hold all ssh connections, it should not
# have the docker socket mounted into it, or you might face a greta risk
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
    echoerror "The container '$SSH_BASTION' exist in your envronment but it seems it's not running. But if you do \
      \nhave it runnig please inform the correct container name by the option '--ssh-bastion=YOUR_CONTAINER_NAME'."
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
if [[ "$DOCKER_USER_EXISTS_IN_CONTAINER" != true ]]; then
    echoerror "The user '$USER_NAME' does not exist in container the ssh-container: '$SSH_BASTION'.\
      \nIf you want to grant access to this user to any other container in your environment, firt add the user as following: \
      \n./add-user.sh --user-name=$USER_NAME"
fi

#-----------------------------------------------------------------------
# User's key (-k|--key-string=|ARG_KEY_STRING|USER_SSH_KEY)
#
# This key will be used to grant access to all containers informed in
# '--site-container' option, if you don't set this option manually
# the default user's key from ssh-bastion container will be used
#-----------------------------------------------------------------------
if [[ $ARG_KEY_STRING == "" ]]; then

    # Get user's pub key
    run_function docker_get_user_ssh_pub_key $SSH_BASTION $USER_NAME

    USER_SSH_KEY="$DOCKER_USER_SSH_PUB_KEY"

    if [[ $USER_SSH_KEY == "" ]]; then
        echoerror "We could not find the pub key for the user '$USER_NAME' in container '$SSH_BASTION'"
    fi
else
    USER_SSH_KEY="${ARG_KEY_STRING}"
fi

#-----------------------------------------------------------------------
# Sites containers' name (-s|--site-container=|ARG_SITES_CONTAINERS [ARRAY])
#
# This options is used to inform which container the newly created user
# will have access granted, please make sure to specify only services
# the user owns, once the access in container may have root access
#-----------------------------------------------------------------------
if [[ $ARG_SITES_FROM_ADDUSER_SCRIPT == "" ]]; then
    
    # Check if Site Argument was passed
    if [[ $ARG_SITES_CONTAINERS == "" ]]; then
        
        # Get list of containers
        run_function docker_list_container

        # Show running site to be chosen by the user
        run_function select_multiple_data "${DOCKER_LIST_CONTAINER_RESPONSE[*]}"
        
        SITES_CONTAINERS=(${USER_MULTIDATA_SELECTIONS[@]})
    else
        SITES_CONTAINERS=("${ARG_SITES_CONTAINERS[@]}")
    fi
else
    SITES_CONTAINERS=(${ARG_SITES_FROM_ADDUSER_SCRIPT[@]})
fi

# Check if Sites Container is empty 
if [[ $SITES_CONTAINERS == "" ]]; then
    echoerror "Site must be informed in order to grant user access. Please use --site-container option. \
      \nYou might set it multiple times as --site-container=site1 --site-container=site2 --site-container=site3 \
      \nor choose as many containers as you need from the list"
fi

#-----------------------------------------------------------------------
# Confirm action
#-----------------------------------------------------------------------
if [[ ! "$SILENT" == true  ]] || [[ ! "$REPLY_YES" == true ]]; then
    SITE_CONTAINER_STRING=${SITES_CONTAINERS[*]}
    run_function confirm_user_action "You are allowing the user '$USER_NAME' to access the container(s) '${SITE_CONTAINER_STRING// / - }'. \
      \nAre you sure you want to continue?" true
fi

#-----------------------------------------------------------------------
# Loop through the sites containers and add users' key to the main user
#-----------------------------------------------------------------------
for SITE_CONTAINER in "${SITES_CONTAINERS[@]}"; do

    # Check if site is running
    run_function docker_check_container_is_running $SITE_CONTAINER

    if [[ "$DOCKER_CONTAINER_IS_RUNNING" == true ]]; then

        # Check if openssh-server is running
        run_function docker_check_service_is_running_with_procps $SITE_CONTAINER "ssh"

        if [[ "$DOCKER_SERVICE_IS_RUNNING" != true ]]; then
            # Install openssh-server
            run_function docker_install_package_with_apt $SITE_CONTAINER "openssh-server"

            # Config openssh-server
            run_function local_config_openssh_service $SITE_CONTAINER

            # Start openssh-server
            run_function docker_start_service_with_service $SITE_CONTAINER "ssh"
        fi

        # Save users' ssh pub key in site container
        run_function docker_add_ssh_key_to_main_user "$SITE_CONTAINER" "$USER_SSH_KEY"
    else
        echowarning "Container '$SITE_CONTAINER' is not running."
    fi
done

#-----------------------------------------------------------------------
# Final message
#-----------------------------------------------------------------------
if [[ ! "$SILENT" == true  ]]; then
    echosuccess "You can access the sites selected using the key from '$USER_NAME': \
      \nssh $USER_NAME@$SSH_BASTION -t 'ssh $SITE_CONTAINER'"
fi

exit 0


# if user does not exist ask to create one


# corrigir permissão da pasta .ssh para 700 e do arquivo .ssh/config para 644
