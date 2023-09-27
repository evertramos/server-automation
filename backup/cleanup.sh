#!/bin/bash

# ----------------------------------------------------------------------
#
# Cleanup script
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
log "'$*'"

# ----------------------------------------------------------------------
# Process arguments
# ----------------------------------------------------------------------
while [[ $# -gt 0 ]]
do
    case "$1" in
        -s)
        ARG_SOURCE_FOLDER="${2}"
        if [[ $ARG_SOURCE_FOLDER == "" ]]; then 
            echoerror "Invalid option for -s";
            break;
        fi
        shift 2
        ;;
        --source=*)
        ARG_SOURCE_FOLDER="${1#*=}"
        if [[ $ARG_SOURCE_FOLDER == "" ]]; then 
            echoerror "Invalid option for --source=''";
            break;
        fi
        shift 1
        ;;
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
        --backup-id=*)
        ARG_BACKUP_ID="${1#*=}"
        if [[ $ARG_BACKUP_ID == "" ]]; then 
            echoerror "Invalid option for --backup-id=''";
            break;
        fi
        shift 1
        ;;
        --filter=*)
        ARG_FILTER="${1#*=}"
        # Here we kept the ARG_URL once the filter is being done by this option
        ARG_URL="${1#*=}"
        if [[ $ARG_URL == "" ]]; then 
            echoerror "Invalid option for --filter=''";
            break;
        fi
        shift 1
        ;;
        --all-sites)
        ALL_SITES=true
        shift 1
        ;;
        --clean-storage)
        CLEAN_STORAGE=true
        shift 1
        ;;
        --storage-only)
        STORAGE_ONLY=true
        shift 1
        ;;
        --local-only)
        LOCAL_ONLY=true
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
        usage_cleanup
        exit 0
        ;;
        *)
        echoerror "Unknown argument: $1" false
        usage_cleanup
        exit 0
        ;;
    esac
done

# ----------------------------------------------------------------------
# Initial check - DO NOT CHANGE SETTINGS BELOW
# ----------------------------------------------------------------------

# Check if there is an .env file in local folder
#run_function check_local_env_file

# Specific PID File if needs to run multiple scripts
LOCAL_NEW_PID_FILE=${LOCAL_SCRIPT_PID_FILE_NAME:-".backup.pid"}
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

# ----------------------------------------------------------------------
# Arguments validation and variables fulfillment
# ----------------------------------------------------------------------
# Check if Source Folder or SITES_FOLDER from base .env file is set 
if [[ $ARG_SOURCE_FOLDER == "" ]] && [[ $SITES_FOLDER == "" ]]; then 
    echoerror "It seems you did not set the option SITES_FOLDER in your base .env file. If you intend to use this script without this settings please use --source='' option to inform the initial directory where your sites are located."
else
    SOURCE_FOLDER=${ARG_SOURCE_FOLDER:-$SITES_FOLDER}
    
    # Check if folder exists
    run_function check_folder_exists $SOURCE_FOLDER true
fi

# Check if Backup Folder is set (BACKUP_FOLDER in base .env file)
if [[ $ARG_DESTINATION_FOLDER == "" ]] && [[ $BACKUP_FOLDER == "" ]]; then 
    echoerror "It seems you did not set the option BACKUP_FOLDER in your base .env file. If you intend to use this script without this settings please use --destination='' option to determina the backup directory location."
else
    DESTINATION_FOLDER=${ARG_DESTINATION_FOLDER:-$BACKUP_FOLDER}
    
    # Check if folder exists
    run_function check_folder_exists $DESTINATION_FOLDER

    # Result from folder exists function
    if [[ "$FOLDER_EXIST" == false ]]; then
        echoerror "The backup folder '$DESTINATION_FOLDER' does not exist in your server. Please check your command and try again."
    fi
fi

# Make backup or get --backup-id if it is informed
if [[ "$ARG_BACKUP_ID" == "" ]]; then
    ARG_BACKUP_ID=$(date "+%Y%m%d_%H%M%S")
    
    # Inform the user if the --backup-id was empty
    if [[ "$SILENT" != true ]] && [[ "$ALL_SITES" == true ]]; then
        echowarning "You have not informed a --backup-id string, so we have considered the id: '$ARG_BACKUP_ID'."
    fi
fi
BACKUP_ID=$ARG_BACKUP_ID

# Check if user informed --url and --all-sites
if [[ $ARG_URL != "" ]] && [[ "$ALL_SITES" == true ]]; then 
    echoerror "You have entered the option --url and --all-sites. Please check your command and inform only one of these options."
fi

# Check if user informed the Site (ARG_URL) that should list the backup files
if [[ "$ALL_SITES" != true ]]; then

    # If user did not set --storage-only get list of local files
    if [[ "$STORAGE_ONLY" != true ]]; then 
        cd $DESTINATION_FOLDER
        if [[ $ARG_URL != "" ]]; then 
            ALL_FILES_IN_FOLDER=($(ls -p | grep $ARG_URL | grep -v /))
        else
            ALL_FILES_IN_FOLDER=($(ls -p | grep -v /))
        fi
        cd - > /dev/null 2>&1
    else
        # If youser set --storage-only we must list all files from the ftp storage
        if [[ $ARG_URL != "" ]]; then 
            ALL_FILES_IN_FOLDER=$(echo -e "cd $DESTINATION_FOLDER \n ls" | sftp $BACKUP_SERVER | awk '{print $NF}' | grep -v "ls" | grep -v "$DESTINATION_FOLDER" | grep $ARG_URL)
        else
            ALL_FILES_IN_FOLDER=$(echo -e "cd $DESTINATION_FOLDER \n ls" | sftp $BACKUP_SERVER | awk '{print $NF}' | grep -v "ls" | grep -v "$DESTINATION_FOLDER")
        fi
    fi
    echowarning "Select all files you want to delete."
 
    # Show list of backup file for this url
    run_function select_multiple_data "${ALL_FILES_IN_FOLDER[*]}"

    LIST_BACKUP_FILES=(${USER_MULTIDATA_SELECTIONS[@]})
fi

# Check if user informed --storage-only and --local-only
if [[ "$STORAGE_ONLY" == true ]] && [[ "$LOCAL_ONLY" == true ]]; then 
    echoerror "You have entered the options --storage-only and --local-only. By default the script will clean the backup locally, if you choose to clean storage backup and the local backup just add --clean-storage option. Please check your command and try again."
fi

# If --clean-storage is not set ask the user what to do
if [[ "$STORAGE_ONLY" != true ]] && [[ "$CLEAN_STORAGE" != true ]] && [[ "$LOCAL_ONLY" != true ]]; then

    if [[ "$REPLY_YES" != true ]]; then
        run_function confirm_user_action "Do you want to clean the backup storage as well?" false

        # Set send storage if user confirmed
        if [[ "$USER_ACTION_RESPONSE" == true ]]; then
            CLEAN_STORAGE=true
        fi
    else
        CLEAN_STORAGE=true
    fi
fi

# ----------------------------------------------------------------------
# Start running script
# ----------------------------------------------------------------------

# Funcion to be called by the next lines
function local_backup_cleanup()
{
    local LOCAL_REMOTE_FILE_NAME

    LOCAL_REMOTE_FILE_NAME=${1:-null}

    if [[ "$STORAGE_ONLY" == true ]] || [[ "$CLEAN_STORAGE" == true ]]; then
        # Delete backup storage file
        echowarning "Deleting backup file: ${LOCAL_REMOTE_FILE_NAME} in Storage: $BACKUP_SERVER"
               
        # Delete file in the backup storage
        run_function ftp_delete_file_ftp $LOCAL_REMOTE_FILE_NAME $BACKUP_SERVER 
    fi
     
    if [[ "$STORAGE_ONLY" != true ]]; then
        # Delete local backup file
        run_function file_delete_local_file $BACKUP_FULLFILE_PATH 
    fi


    # Listing files in the Backup Storage
    if [[ "$SILENT" != true ]] && [[ "$DEBUG" == true ]] &&[[ "$STORAGE_ONLY" == true ]] || [[ "$CLEAN_STORAGE" == true ]]; then
        run_function ftp_list_folder_ftp "/" $BACKUP_SERVER
    fi

    return
}

# Verify if should backup all sites
if [[ "$ALL_SITES" == true ]]; then

    # Loop all sites folder and clean it
    cd ${SOURCE_FOLDER%/}
    RETURN_ALL_FOLDERS=($(ls -d */ | sed 's#/##'))
    cd - > /dev/null 2>&1
    for i in ${!RETURN_ALL_FOLDERS[@]}; do
        [[ "$SILENT" != true ]] && echo "Deleting backup for site '${RETURN_ALL_FOLDERS[i]}'"

        LOCAL_URL=${RETURN_ALL_FOLDERS[i]%/}
        FULL_DESTINATION_FOLDER=${DESTINATION_FOLDER%/}"/"$LOCAL_URL
        BACKUP_FULLFILE_PATH=$FULL_DESTINATION_FOLDER"-"$BACKUP_ID".tar.gz"

        local_backup_cleanup "${LOCAL_URL}-${BACKUP_ID}.tar.gz"
    done
else
    # Loop through all files selected by the user
    for LOCAL_BACKUP_FILE in "${LIST_BACKUP_FILES[@]}"; do
        BACKUP_FULLFILE_PATH=${DESTINATION_FOLDER%/}"/"$LOCAL_BACKUP_FILE
        local_backup_cleanup $LOCAL_BACKUP_FILE
    done
fi

exit 0

