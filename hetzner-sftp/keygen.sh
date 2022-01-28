#!/bin/bash

#-----------------------------------------------------------------------
#
# Generate ssh key, convert to RFC4716 format and sent to Hetzner storage box over sftp
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

        # ssh key file name that will be created
        -k)
        ARG_FILE_NAME="${2}"
        if [[ $ARG_FILE_NAME == "" ]]; then 
            echoerror "Invalid option for -k";
            break;
        fi
        shift 2
        ;;
        --key-name=*)
        ARG_FILE_NAME="${1#*=}"
        if [[ $ARG_FILE_NAME == "" ]]; then 
            echoerror "Invalid option for --key-name=''";
            break;
        fi
        shift 1
        ;;

        # ssh key passphrase
        -kp)
        ARG_PASSPHRASE="${2}"
        if [[ $ARG_PASSPHRASE == "" ]]; then
            echoerror "Invalid option for -P";
            break;
        fi
        shift 2
        ;;
        --passphrase=*)
        ARG_PASSPHRASE="${1#*=}"
        if [[ $ARG_PASSPHRASE == "" ]]; then
            echoerror "Invalid option for --passphrase=''";
            break;
        fi
        shift 1
        ;;

        # backup server that key will be sent to (format: user@server)
        -s)
        ARG_SERVER="${2}"
        if [[ $ARG_SERVER == "" ]]; then 
            echoerror "Invalid option for -s";
            break;
        fi
        shift 2
        ;;
        --server=*)
        ARG_SERVER="${1#*=}"
        if [[ $ARG_SERVER == "" ]]; then 
            echoerror "Invalid option for --server=''";
            break;
        fi
        shift 1
        ;;

        # backup server password
        # NOT SAFE - @TODO [think possible alternatives sshpass -p <password> sftp user@host]
#        -sp)
#        ARG_SERVER_PASSWORD="${2}"
#        if [[ $ARG_SERVER_PASSWORD == "" ]]; then
#            echoerror "Invalid option for -sp";
#            break;
#        fi
#        shift 2
#        ;;
#        --server-password=*)
#        ARG_SERVER_PASSWORD="${1#*=}"
#        if [[ $ARG_SERVER_PASSWORD == "" ]]; then
#            echoerror "Invalid option for --server-password=''";
#            break;
#        fi
#        shift 1
#        ;;

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
        usage_keygen
        ;;
        *)
        echoerror "Unknown argument: $1"
        usage_keygen
        ;;
    esac
done

#-----------------------------------------------------------------------
# Initial check - DO NOT CHANGE SETTINGS BELOW
#-----------------------------------------------------------------------

# Specific PID File if needs to run multiple scripts
LOCAL_NEW_PID_FILE=${LOCAL_SCRIPT_PID_FILE_NAME:-".ssh_key_gen.pid"}
if [[ $ARG_PID_TAG == "" ]]; then
  NEW_PID_FILE=${LOCAL_NEW_PID_FILE}
else
  NEW_PID_FILE=".${ARG_PID_TAG}-${LOCAL_NEW_PID_FILE:1}"
fi

# Run initial check function
run_function starts_initial_check $NEW_PID_FILE

# Check if there is an .env file in local folder
#run_function check_local_env_file

# Save PID
system_save_pid $NEW_PID_FILE

# DO NOT CHANGE ANY OPTIONS ABOVE THIS LINE!

#-----------------------------------------------------------------------
# Arguments validation and variables fulfillment
#-----------------------------------------------------------------------
# Check SSH Key file name was informed
if [[ $ARG_FILE_NAME == "" ]]; then

    # Ask for SSH Key file name
    run_function common_read_user_input "Please enter the name of your SSH Key file (ONLY THE NAME)[default: id_rsa]:"

    if [[ $USER_INPUT_RESPONSE == "" ]]; then
        SSH_KEY_FILE_NAME="id_rsa"
    else
        run_function string_remove_dot_slash_from_string $USER_INPUT_RESPONSE
        SSH_KEY_FILE_NAME=$STRING_REMOVE_DOT_SLASH_FROM_STRING_RESPONSE

        if [[ ! "$REPLY_YES" == true ]]; then
            LOCAL_SITE_VERSION="latest"

            run_function confirm_user_action "You are creating a ssh key at '~/.ssh/$SSH_KEY_FILE_NAME'. Are you sure you want to continue?"

            [[ "$USER_ACTION_RESPONSE" != true ]] && echoerror "You have canceled this action. No changes were made."
        fi
    fi
else
    run_function string_remove_dot_slash_from_string $ARG_FILE_NAME
    SSH_KEY_FILE_NAME=$STRING_REMOVE_DOT_SLASH_FROM_STRING_RESPONSE
fi

# Check if file already exists
[[ -e ~/.ssh/$SSH_KEY_FILE_NAME ]] && echoerror "This key name already exists. Please inform a new key name"

#-----------------------------------------------------------------------
# Backup server (-s|--server=|ARG_SERVER|LOCAL_BACKUP_SERVER)
#-----------------------------------------------------------------------
if [[ $ARG_SERVER != "" ]]; then
    LOCAL_BACKUP_SERVER=$ARG_SERVER
elif [[ $BACKUP_SERVER == "" ]]; then

    # Ask for Server access information
    run_function common_read_user_input "Please enter the server access info (ex. <username>@<server>):"

    LOCAL_BACKUP_SERVER=$USER_INPUT_RESPONSE
else
    LOCAL_BACKUP_SERVER=$BACKUP_SERVER
fi

# Validate backup server
[[ $LOCAL_BACKUP_SERVER == "" ]] && echoerror "You must inform the backup server (--server=<user>@<server>)"

#-----------------------------------------------------------------------
# Start running script
#-----------------------------------------------------------------------
# Generate ssh key
[[ "$DEBUG" == true ]] && echoinfo "Creating key '~/.ssh/$SSH_KEY_FILE_NAME' with passphrase '${ARG_PASSPHRASE:-""}'"
ssh-keygen -q -f ~/.ssh/$SSH_KEY_FILE_NAME -N ${ARG_PASSPHRASE:-""}

# Convert key to the right format
[[ "$DEBUG" == true ]] && echoinfo "Converting key to format RFC4716 to '~/.ssh/${SSH_KEY_FILE_NAME}_rfc.pub'"
ssh-keygen -e -f ~/.ssh/$SSH_KEY_FILE_NAME.pub | grep -v "Comment:" > ~/.ssh/$SSH_KEY_FILE_NAME"_rfc.pub"

# Get Authorized keys from ftp storage
[[ "$DEBUG" == true ]] && echoinfo "Get current authorized_keys from backup server '$LOCAL_BACKUP_SERVER'"
[[ ! "$SILENT" == true ]] && echoinfo "You will be prompted to inform your password for your backup server: '$LOCAL_BACKUP_SERVER'"
echo -e "get .ssh/authorized_keys" | sftp $LOCAL_BACKUP_SERVER

# Add new key to the authorized_keys
[[ "$DEBUG" == true ]] && echoinfo "Add local key '~/.ssh/${SSH_KEY_FILE_NAME}_rfc.pub' to authorized_keys"
mkdir -p ssh_temp
cd ssh_temp
cat ~/.ssh/$SSH_KEY_FILE_NAME"_rfc.pub" >> authorized_keys

# Send new authorized keys to the server
[[ "$DEBUG" == true ]] && echoinfo "Send new updated authorized_keys to backup server '$LOCAL_BACKUP_SERVER'"
[[ ! "$SILENT" == true ]] && echoinfo "You will be prompted to inform your password for your backup server: '$LOCAL_BACKUP_SERVER'"
echo -e "mkdir .ssh \n chmod 700 .ssh \n put authorized_keys .ssh/authorized_keys \n chmod 600 .ssh/authorized_keys" | sftp $LOCAL_BACKUP_SERVER

# Remove local authorized_keys
[[ "$DEBUG" == true ]] && echoinfo "Removing temporary local 'authorized_keys'"
rm authorized_keys
cd - > /dev/null 2>&1

exit 0

