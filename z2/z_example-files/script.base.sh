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
log "'$*'"

#-----------------------------------------------------------------------
# Process arguments
#-----------------------------------------------------------------------
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
    if [[ $ARG_FILTER == "" ]]; then 
      echoerror "Invalid option for --filter=''";
      break;
    fi
    shift 1
    ;;
    --all-sites)
    ALL_SITES=true
    shift 1
    ;;
    --send-storage)
    SEND_STORAGE=true
    shift 1
    ;;
    --local-only)
    LOCAL_ONLY=true
    shift 1
    ;;
    --delete-local)
    DELETE_LOCAL=true
    shift 1
    ;;
    --yes)
    REPLY_YES=true
    shift 1
    ;;
    --skip-dns)
    SKIP_DNS=true
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
    usage_backup
    exit 0
    ;;
    *)
    echoerror "Unknown argument: $1" false
    usage_backup
    exit 0
    ;;
  esac
done

#-----------------------------------------------------------------------
# Initial check - DO NOT CHANGE SETTINGS BELOW
#-----------------------------------------------------------------------

# Specific PID File if needs to run multiple scripts
LOCAL_NEW_PID_FILE=${LOCAL_SCRIPT_PID_FILE_NAME:-".new_script_file.pid"}
if [[ $ARG_PID_TAG == "" ]]; then
  NEW_PID_FILE=${LOCAL_NEW_PID_FILE}
else
  NEW_PID_FILE=".${ARG_PID_TAG}-${LOCAL_NEW_PID_FILE:1}"
fi

# Run initial check function
run_function starts_initial_check $NEW_PID_FILE

# Check if there is an .env file in local folder
run_function check_local_env_file

# Save PID
system_save_pid $NEW_PID_FILE

# DO NOT CHANGE ANY OPTIONS ABOVE THIS LINE!

# ----------------------------------------------------------------------
# Undo function
# ----------------------------------------------------------------------
local_undo_restore()
{
    local LOCAL_KEEP_RESTORE_FILES

    LOCAL_KEEP_RESTORE_FILES=${1:-$KEEP_RESTORE_FILES}
    
    echoerror "It seems something went wrong running '${FUNCNAME[0]}' we will try to UNDO all actions done by this script. Please make sure everything was back in place as when you started." false

    # If any service was started make sure to stop it
    if [[ "$ACTION_DOCKER_COMPOSE_STARTED" == true ]]; then
        [[ "$SILENT" != true ]] && echowarning "[undo] Starting docker-compose service '$LOCAL_SITE_FULL_PATH'."
#        run_function docker_compose_stop "${LOCAL_SITE_FULL_PATH%/}/compose"
        ACTION_DOCKER_COMPOSE_STARTED=false
    fi

    # If site folder was created
    if [[ "$ACTION_SITE_PATH_CREATED" == true ]]; then
        [[ "$SILENT" != true ]] && echowarning "[undo] Creating site folder '$LOCAL_SITE_FULL_PATH'."
        # Remove folder
#        run_function system_safe_delete_folder $LOCAL_SITE_FULL_PATH true
        ACTION_SITE_PATH_CREATED=false
    fi

    # If site domain was created
    if [[ "$ACTION_SITE_URL_CREATED" == true ]]; then
        [[ "$SILENT" != true ]] && echowarning "[undo] Creating site domain '$LOCAL_NEW_URL'."
#        run_function domain_delete_domain_dns $LOCAL_NEW_URL
        ACTION_SITE_URL_CREATED=false
        if [[ "$WITH_WWW" == true ]]; then
#            run_function domain_delete_domain_dns "www.$LOCAL_NEW_URL"
        fi
    fi

    exit 0
}

#-----------------------------------------------------------------------
# Arguments validation and variables fulfillment
#-----------------------------------------------------------------------
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
  echoerror "It seems you did not set the option BACKUP_FOLDER in your base .env file. If you intend to use this script without this settings please use --destination='' option to set the backup directory location."
else
  DESTINATION_FOLDER=${ARG_DESTINATION_FOLDER:-$BACKUP_FOLDER}
  
  # Check if folder exists
  run_function check_folder_exists $DESTINATION_FOLDER

  # Result from folder exists function
  if [[ "$FOLDER_EXIST" == false ]]; then
    echowarning "The backup folder does not exist in your server. We will create it for your. Your backup will be located at '$DESTINATION_FOLDER'."
#    run_function common_create_folder $DESTINATION_FOLDER
    ACTION_SITE_URL_CREATED=true
  fi
fi

# Check if user informed --url and --all-sites
if [[ $ARG_URL != "" ]] && [[ "$ALL_SITES" == true ]]; then 
  echoerror "You have entered the option --url and --all-sites. Please check your command and inform only one of these options."
fi

# Check if user informed the Folder/Site (ARG_URL) that should backup
if [[ $ARG_URL != "" ]] && [[ "$ALL_SITES" != true ]]; then 
  
  run_function domain_get_domain_from_url $ARG_URL
  LOCAL_URL=$DOMAIN_URL_RESPONSE
  
  # Check if folder exists
  run_function check_folder_exists $SOURCE_FOLDER"/"$LOCAL_URL
  
  # Result from folder exists function
  if [[ "$FOLDER_EXIST" == true ]]; then
    FULL_SOURCE_FOLDER=$SOURCE_FOLDER"/"$LOCAL_URL
  else
    echowarning "You have informed the url '$LOCAL_URL', but it seems we could not find it. Please select one of the options."
  fi
fi

# If URL was not infomred list the folders available to backup
if [[ "$FULL_SOURCE_FOLDER" == "" ]] && [[ "$ALL_SITES" != true ]]; then

  # List all sites (folders) in the SOURCE_FOLDER/SITES_FOLDER
  run_function select_folder $SOURCE_FOLDER $ARG_FILTER

  LOCAL_URL=${FOLDER_NAME%/}
  FULL_SOURCE_FOLDER=$SOURCE_FOLDER"/"$LOCAL_URL

  # Check if folder exists
  run_function check_folder_exists $FULL_SOURCE_FOLDER true
fi

# If --send-storage is not set ask the user what to do
if [[ "$REPLY_YES" != true ]] && [[ "$SEND_STORAGE" != true ]] && [[ "$LOCAL_ONLY" != true ]]; then
  run_function confirm_user_action "Do you want to send to backup storage?" false
  
  # Set send storage if user confirmed
  if [[ "$USER_ACTION_RESPONSE" == true ]]; then
    SEND_STORAGE=true

    # If sending to the storage ask the user if should delete local file
    run_function confirm_user_action "Do you want to DELETE the local file after sending this file to backup storage?" false
    
    # Set send storage if user confirmed
    [[ "$USER_ACTION_RESPONSE" == true ]] && DELETE_LOCAL=true
  fi
fi

#-----------------------------------------------------------------------
# Start running script
#-----------------------------------------------------------------------

# function to be called by the next
function local_backup()
{
  # Backup folder 
#  run_function backup_folder $FULL_SOURCE_FOLDER $DESTINATION_FOLDER $ARG_BACKUP_ID
  #BACKUP_FOLDER_FILE_OUTPUT="/server/backup/sites/christforyou.info.tar.gz"

  # Test if backup file's integrity
#  run_function backup_check_tar_file_integrity $BACKUP_FOLDER_FILE_OUTPUT

  # Upload to Storage
  if [[ "$LOCAL_ONLY" != true ]] && [[ "$SEND_STORAGE" == true ]]; then
    echowarning "Uploading backup file to Storage ($BACKUP_SERVER)"

    # Send file
#    run_function ftp_send_file_ftp $BACKUP_FOLDER_FILE_OUTPUT $BACKUP_SERVER $DESTINATION_FOLDER

    # Check if file was sent to the Storage
   #   run_function ftp_check_file_exists_ftp $BACKUP_SERVER $BACKUP_FOLDER_FILE_OUTPUT
  # @TODO - CHECK IF FILE EXISTS IN FTP SERVER

    # If file exists in Storage and option DELETE_LOCAL is set
    if [[ "$DELETE_LOCAL" == true ]]; then
      
      # Delete local backup file
#      run_function file_delete_local_file $BACKUP_FOLDER_FILE_OUTPUT
    fi
    
    # Listing files in the Backup Storage on debug mode
    if [[ "$DEBUG" == true ]]; then
#      run_function ftp_list_folder_ftp $DESTINATION_FOLDER $BACKUP_SERVER
    fi
  fi

  return
}

# Verify if should backup all sites
if [[ "$ALL_SITES" == true ]]; then

  # Loop all sites folder and back it up
  return_all_folders 
  for i in ${!RETURN_ALL_FOLDERS[@]}; do
    [[ "$SILENT" != true ]] && echo "Backing up site '${RETURN_ALL_FOLDERS[i]}'"

    LOCAL_URL=${RETURN_ALL_FOLDERS[i]%/}
    FULL_SOURCE_FOLDER=$SOURCE_FOLDER"/"$LOCAL_URL

#    local_backup
  done
else
#  local_backup
fi

exit 0

