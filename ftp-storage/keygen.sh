#!/bin/bash

# ----------------------------------------------------------------------
#
# Generate key for FTP Storage
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

# Get the script name and its file real path
SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
SCRIPT_NAME="${0##*/}"

# Source basescript functions
source $SCRIPT_PATH"/../basescript/bootstrap.sh"

# Source localscripts
source $SCRIPT_PATH"/localscript/bootstrap.sh"

# ----------------------------------------------------------------------
#
# Process arguments
#
# ----------------------------------------------------------------------
while [[ $# -gt 0 ]]
do
    case "$1" in
        -f)
        ARG_FILE_NAME="${2}"
        if [[ $ARG_FILE_NAME == "" ]]; then 
            echoerror "Invalid option for -f";
            break;
        fi
        shift 2
        ;;
        --file-name=*)
        ARG_FILE_NAME="${1#*=}"
        if [[ $ARG_FILE_NAME == "" ]]; then 
            echoerror "Invalid option for --file-name=''";
            break;
        fi
        shift 1
        ;;
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

# ----------------------------------------------------------------------
#
# Initial check - DO NOT CHANGE SETTINGS BELOW
#
# ----------------------------------------------------------------------

# Specific PID File if needs to run multiple scripts
#NEW_PID_FILE=".new_script_file"

# Run initial check function
run_function starts_initial_check $NEW_PID_FILE

# Check if there is an .env file in local folder
run_function check_local_env_file

# Save PID
system_save_pid $NEW_PID_FILE

# DO NOT CHANGE ANY OPTIONS ABOVE THIS LINE!

# ----------------------------------------------------------------------
#
# Arguments validation and variables fulfillment
#
# ----------------------------------------------------------------------
# Check SSH Key file name was informed
if [[ $ARG_FILE_NAME == "" ]]; then

    # Ask for SSH Key file name
    run_function common_read_user_input "Please enter the name of your SSH Key file (ONLY THE NAME):"

    #run_function remove_all_special_char_string $USER_INPUT_RESPONSE
    #SSH_KEY_FILE_NAME=$REMOVE_ALL_SPECIAL_CHAR_STRING_RESPONSE
    run_function remove_dot_slash_string $USER_INPUT_RESPONSE
    SSH_KEY_FILE_NAME=$REMOVE_DOT_SLASH_STRING_RESPONSE

    run_function confirm_user_action "You are creating a ssh key at '~/.ssh/$SSH_KEY_FILE_NAME'. Are you sure you want to continue?"
    
    [[ "$USER_ACTION_RESPONSE" != true ]] && echoerror "You have canceled this action. No changes were made."
else
    run_function remove_dot_slash_string $ARG_FILE_NAME
    SSH_KEY_FILE_NAME=$REMOVE_DOT_SLASH_STRING_RESPONSE
fi

# Check if file already exists
[[ -e ~/.ssh/$SSH_KEY_FILE_NAME ]] && echoerror "This key name already exists. Please inform a new key name"

# Check SSH Key file name was informed
if [[ $ARG_SERVER != "" ]]; then
    LOCAL_BACKUP_SERVER=$ARG_SERVER
elif [[ $BACKUP_SERVER == "" ]]; then

    # Ask for Server access information
    run_function common_read_user_input "Please enter the server access info (ex. <username>@<server>):"

    LOCAL_BACKUP_SERVER=$USER_INPUT_RESPONSE
else
    LOCAL_BACKUP_SERVER=$BACKUP_SERVER
fi

# ----------------------------------------------------------------------
#
# Start running script
#
# ----------------------------------------------------------------------
# Generate ssh key
ssh-keygen -f ~/.ssh/$SSH_KEY_FILE_NAME

# Convert key to the right format
ssh-keygen -e -f ~/.ssh/$SSH_KEY_FILE_NAME.pub | grep -v "Comment:" > ~/.ssh/$SSH_KEY_FILE_NAME"_rfc.pub"

# Get Authorized keys from ftp storage
echo -e "get .ssh/authorized_keys" | sftp $LOCAL_BACKUP_SERVER

# Add new key to the authorized_keys
cat ~/.ssh/$SSH_KEY_FILE_NAME"_rfc.pub" >> authorized_keys

# Send new authorized keys to the server
echo -e "mkdir .ssh \n chmod 700 .ssh \n put authorized_keys .ssh/authorized_keys \n chmod 600 .ssh/authorized_keys" | sftp $LOCAL_BACKUP_SERVER

# Remove local authorized_keys
rm authorized_keys

exit 0

