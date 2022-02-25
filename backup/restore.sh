#!/bin/bash

#-----------------------------------------------------------------------
#
# Restore backup script
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
echo "$@"
echo "$*"
#log "$@"

exit 0

# ----------------------------------------------------------------------
#
# Process arguments
#
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
            echoerror "Invalid option for --file-name";
            break;
        fi
        shift 1
        ;;
        -nu)
        ARG_NEW_URL="${2}"
        if [[ $ARG_NEW_URL == "" ]]; then 
            echoerror "Invalid option for -u";
            break;
        fi
        shift 2
        ;;
        --new-url=*)
        ARG_NEW_URL="${1#*=}"
        if [[ $ARG_NEW_URL == "" ]]; then 
            echoerror "Invalid option for --url";
            break;
        fi
        shift 1
        ;;
        -rsf)
        ARG_RESTORE_STAGE_FOLDER="${2}"
        if [[ $ARG_RESTORE_STAGE_FOLDER == "" ]]; then 
            echoerror "Invalid option for -rsf";
            break;
        fi
        shift 2
        ;;
        --restore-stage-folder=*)
        ARG_RESTORE_STAGE_FOLDER="${1#*=}"
        if [[ $ARG_RESTORE_STAGE_FOLDER == "" ]]; then 
            echoerror "Invalid option for --restore-stage-folder=''";
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
        --with-www)
        WITH_WWW=true
        shift 1
        ;;
        --from-storage)
        FROM_STORAGE=true
        shift 1
        ;;
        --backup-if-running)
        BACKUP_IF_RUNNING=true
        shift 1
        ;;
        --no-backup)
        NO_BACKUP=true
        shift 1
        ;;
        --keep-restore-files)
        KEEP_RESTORE_FILES=true
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
        usage_restore
        ;;
        *)
        echoerror "Unknown argument: $1" false
        usage_restore
        exit 0
        ;;
    esac
done

# ----------------------------------------------------------------------
#
# Initial check - DO NOT CHANGE SETTINGS BELOW
#
# ----------------------------------------------------------------------

# Specific PID File if needs to run multiple scripts
NEW_PID_FILE=".restore"

# Run initial check function
run_function initial_check $NEW_PID_FILE

# Check if there is an .env file in local folder
run_function check_local_env_file

# Save PID
save_pid $NEW_PID_FILE

# DO NOT CHANGE ANY OPTIONS ABOVE THIS LINE!

# ----------------------------------------------------------------------
#
# Arguments validation and variables fulfillment
#
# ----------------------------------------------------------------------

# 
# In the 'restore.sh' script the SOURCE_FOLDER and DESTINATION_FOLDER changes 'positions'
# the SOURCE_FOLDER is where the backup files are located (BACKUP_FOLDER in base .env)
# the DESTIANTION_FOLDER is where the backup will be restored (SITES_FOLDER in base .env)
#

# Check if Backup Folder is set (--source) or BACKUP_FOLDER from base .env file is set 
if [[ $ARG_SOURCE_FOLDER == "" ]] && [[ $BACKUP_FOLDER == "" ]]; then 
    echoerror "It seems you did not set the option BACKUP_FOLDER in your base .env file. If you intend to use this script without this settings please use --source='' option to set the backup directory location."
else
    SOURCE_FOLDER=${ARG_SOURCE_FOLDER:-$BACKUP_FOLDER}
    
    # Check if folder exists
    run_function check_folder_exists $SOURCE_FOLDER true
fi

# Check if Sites Folder is set (--destination) or SITES_FOLDER from base .env is set
if [[ $ARG_DESTINATION_FOLDER == "" ]] && [[ $SITES_FOLDER == "" ]]; then 
    echoerror "It seems you did not set the option SITES_FOLDER in your base .env file. If you intend to use this script without this settings please use --destination='' option to inform the initial directory where your sites are located."
else
    DESTINATION_FOLDER=${ARG_DESTINATION_FOLDER:-$SITES_FOLDER}
    
    # Check if folder exists
    run_function check_folder_exists $DESTINATION_FOLDER

    # Result from folder exists function
    if [[ "$FOLDER_EXIST" == false ]]; then
        [[ "$SILENT" != true ]] && echowarning "The destination folder, where you want to place the restored site, does not exist in your server. We will create it for your. Your site (restored) will be located at '$DESTINATION_FOLDER'."
        run_function create_folder $DESTINATION_FOLDER
    fi
fi

# Check if Restore Temporary Folder is set (-rsf / --restore-stage-folder) or RESTORE_STAGE_FOLDER in local .env file
if [[ $ARG_RESTORE_STAGE_FOLDER == "" ]] && [[ $RESTORE_STAGE_FOLDER == "" ]]; then 
    echoerror "It seems you did not set the local option RESTORE_STAGE_FOLDER in your .env file. If you intend to use this script without this settings please use --restore-stage-folder='' or -rsf option to inform the restore temporary folder required to run this script."
else
    RESTORE_STAGE_FOLDER=${ARG_RESTORE_STAGE_FOLDER:-$RESTORE_STAGE_FOLDER}
    
    # Check if folder exists
    run_function check_folder_exists $RESTORE_STAGE_FOLDER

    # Result from folder exists function
    if [[ "$FOLDER_EXIST" == false ]]; then
        [[ "$SILENT" != true ]] && echowarning "The required restore temp folder does not exist in your server. We will create it for your. Your temporary restore point will be located at '$RESTORE_STAGE_FOLDER'."
        run_function create_folder $RESTORE_STAGE_FOLDER
    fi
fi

# Check if user informed --url and --all-sites
if [[ $ARG_FILTER != "" ]] && [[ "$ARG_FILE_NAME" != "" ]]; then 
    echoerror "You have entered the option --filter and --file-name. Please check your command and inform only one of these options."
fi

# ----------------------------------------------------------------------
#
# Local functions required due to complexity of the script 
#
# ----------------------------------------------------------------------
local_check_domain()
{
    local LOCAL_CHECK_DOMAIN_SITE_URL

    LOCAL_CHECK_DOMAIN_SITE_URL=${1}

    # Check if url exist
    run_function check_domain_exists $LOCAL_CHECK_DOMAIN_SITE_URL

    # If url does not exists create subdomain
    if [[ "$DOMAIN_EXIST" == false ]]; then
        run_function create_domain_dns $LOCAL_CHECK_DOMAIN_SITE_URL

        # Verify if there were an error on creating the new domain
        if [[ "$CREATE_DOMAIN_DNS_ERROR" == true ]]; then
            echoerror "Error on creating the domain '$LOCAL_CHECK_DOMAIN_SITE_URL' - response '$RESPONSE'" false
            local_undo_restore
        fi

        # Check AGAIN if url exist
        run_function check_domain_exists $LOCAL_CHECK_DOMAIN_SITE_URL

        # If url does not exists create subdomain
        if [[ "$DOMAIN_EXIST" == false ]]; then
            echoerror "It seems there is an error related to the domain '$LOCAL_CHECK_DOMAIN_SITE_URL' - response '$RESPONSE'" false
            local_undo_restore
        fi
    fi
}

local_backup_function()
{
    LOCAL_BACKUP_ID="auto-backup-restore-script-$(date "+%Y%m%d_%H%M%S")"
    $SCRIPT_PATH/backup.sh "--source=$DESTINATION_FOLDER" "--destination=$SOURCE_FOLDER" "--url=$LOCAL_SITE_URL" "--backup-id=$LOCAL_BACKUP_ID" "--local-only"
    RESTORE_AUTO_BACKUP_FILE="$LOCAL_SITE_URL-$LOCAL_BACKUP_ID"

    [[ "$SILENT" != true ]] && echosuccess "Your backup is ready at: ${SOURCE_FOLDER%/}/$RESTORE_AUTO_BACKUP_FILE"
}

local_cleanup_restore_folder()
{
    local LOCAL_SAFE_CLEANUP

    LOCAL_SAFE_CLEANUP=${RESTORE_STAGE_FOLDER}

    [[ "$LOCAL_SAFE_CLEANUP" == "" ]] && echoerror "We faced some problems to clean up the restore stage folder. Please verify manually."

    echowarning "Cleaning up all files at restore stage folder... ($LOCAL_SAFE_CLEANUP)"
    sudo rm -rf $LOCAL_SAFE_CLEANUP/temp/*
    sudo rm -rf $LOCAL_SAFE_CLEANUP/old/*
    sudo rm -rf $LOCAL_SAFE_CLEANUP/*.tar.gz
}

local_undo_restore()
{
    local LOCAL_KEEP_RESTORE_FILES

    LOCAL_KEEP_RESTORE_FILES=${1:-$KEEP_RESTORE_FILES}
    
    echoerror "It seems something went wrong running '${FUNCNAME[0]}' we will try to UNDO all actions done by this script. Please make sure everything was back in place as when you started." false

    # If new/restored site was moved from restore point to SITES_FOLDER/DESTINATION_FOLDER
    if [[ "$ACTION_RESTORE_SITE_MOVED_TO_SITES_FOLDER" == true ]]; then
        [[ "$SILENT" != true ]] && echowarning "[undo] Moving back the restored site from '$DESTINATION_FOLDER' to '$TEMP_SITE_FOLDER_RESTORE'."
        sudo mv "$DESTINATION_FOLDER/$LOCAL_SITE_URL" $TEMP_SITE_FOLDER_RESTORE
        ACTION_RESTORE_SITE_MOVED_TO_SITES_FOLDER=false
    fi

    # If site folder was moved from SITES_FOLDER return it
    if [[ "$ACTION_CURRENT_SITE_FOLDER_MOVED" == true ]]; then
        [[ "$SILENT" != true ]] && echowarning "[undo] Moving back the site folder '$LOCAL_SITE_URL' from '$OLD_SITE_FOLDER_RESTORE' to '$DESTINATION_FOLDER'."
        sudo mv $OLD_SITE_FOLDER_RESTORE/$LOCAL_SITE_URL $DESTINATION_FOLDER/ 
        ACTION_CURRENT_SITE_FOLDER_MOVED=false
    fi

    # If site was running, start again
    if [[ "$ACTION_CURRENT_SITE_SERVICE_STOPPED" == true ]]; then
        [[ "$SILENT" != true ]] && echowarning "[undo] Stargint back the site '$LOCAL_SITE_URL' at '$DESTINATION_FOLDER'."
        run_function start_compose $DESTINATION_FOLDER $LOCAL_SITE_URL false
#        run_function docker_start_service $DESTINATION_FOLDER $LOCAL_SITE_URL false
        ACTION_CURRENT_SITE_SERVICE_STOPPED=false
    fi

    # Cleanup the restore folder if '--keep-restore-files' was not set
    if [[ "$LOCAL_KEEP_RESTORE_FILES" != true ]]; then
        local_cleanup_restore_folder
    else
        echowarning "All files at '$RESTORE_STAGE_FOLDER' are temporary. If you intend to keep some files you must place them somewhere else. BE ADVISED! All files will be ereased if you run this script again."
    fi

    exit 0
}

# ----------------------------------------------------------------------
#
# Start running script
#
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# Clenaup old files at the Restore Point
# ----------------------------------------------------------------------
local_cleanup_restore_folder

# ----------------------------------------------------------------------
# Download the backup file
# ----------------------------------------------------------------------
# Check if user informed the File Name (--file-name) that should restored.
if [[ $ARG_FILE_NAME != "" ]]; then 

    LOCAL_BACKUP_FULL_FILE_PATH=${SOURCE_FOLDER%/}"/"$ARG_FILE_NAME
    
    [[ ! -f $LOCAL_BACKUP_FULL_FILE_PATH ]] && echoerror "The file '$LOCAL_BACKUP_FULL_FILE_PATH' does not exists in your server. Please check again or run without the option --file-name to select one of the backup files."

# If the user did not inform the --file-name he must select one of the files from the selected source 
else
    if [[ "$FROM_STORAGE" == true ]]; then
        run_function ftp_select_file $BACKUP_SERVER $SOURCE_FOLDER $ARG_FILTER
       
        # @TODO - Before download check disk space and size of backup site
        
        # Download the file from the ftp storage
        run_function ftp_get_file_ftp $SELECTED_FILE_NAME $BACKUP_SERVER $SOURCE_FOLDER $RESTORE_STAGE_FOLDER

    else
        run_function select_file $SOURCE_FOLDER $ARG_FILTER

        # Copy file to restore point
        cp ${SOURCE_FOLDER%/}"/"$SELECTED_FILE_NAME ${RESTORE_STAGE_FOLDER%/}"/"
    fi
    LOCAL_BACKUP_FULL_FILE_PATH=${RESTORE_STAGE_FOLDER%/}"/"$SELECTED_FILE_NAME
fi

# ----------------------------------------------------------------------
# Create TEMP folder in restore path 
# ----------------------------------------------------------------------
TEMP_SITE_FOLDER_RESTORE="${RESTORE_STAGE_FOLDER%/}/temp"

# Create temp folder at Restore Point
run_function create_folder $TEMP_SITE_FOLDER_RESTORE

# ----------------------------------------------------------------------
# Decompress the backup file at restore point
# ----------------------------------------------------------------------
run_function backup_decompress_file $TEMP_SITE_FOLDER_RESTORE $LOCAL_BACKUP_FULL_FILE_PATH

# ----------------------------------------------------------------------
# Load the URL from --new-url or from the tar file (first folder name)
# ----------------------------------------------------------------------
if [[ $ARG_NEW_URL != "" ]]; then
    LOCAL_SITE_URL=$ARG_NEW_URL
else 
    LOCAL_SITE_URL=$(tar -tzf $LOCAL_BACKUP_FULL_FILE_PATH | head -1 | cut -f1 -d"/")
fi

# ----------------------------------------------------------------------
# Check if folder with the same name exist in SITES_FOLDER
# ----------------------------------------------------------------------
run_function check_folder_exists "$DESTINATION_FOLDER/$LOCAL_SITE_URL" 

if [[ "$FOLDER_EXIST" == true ]]; then
    [[ "$SILENT" != true ]] && echowarning "The folder '$LOCAL_SITE_URL' already exists in '$DESTINATION_FOLDER'. Please follow the next instructions carefuly."

    # ------------------------------------------------------------------
    # If folder already exist in SITES_FOLDER it must:
    # ------------------------------------------------------------------

    # 1. Check if service is running
    run_function check_service_running $DESTINATION_FOLDER $LOCAL_SITE_URL 0
    
    if [[ "$SERVICE_RUNNING" == true ]]; then

        if [[ "$REPLY_YES" != true ]]; then
            # 2. Confirm user action if should continue
            run_function confirm_user_action "It seems you already have the site '$LOCAL_SITE_URL' running at '$DESTINATION_FOLDER'. Do you want to continue?" true
        else
            USER_ACTION_RESPONSE=true
        fi

        # If user continue and --backup-if-running is not set and --no-backup was not set
        if [[ "$USER_ACTION_RESPONSE" == true ]] && [[ "$BACKUP_IF_RUNNING" != true ]] && [[ "$NO_BACKUP" != true ]]; then

            [[ "$SILENT" != true ]] && echowarning "Please PAY CLOSE ATTENTION to the following questions, once this site is running any wrong action might cause a DAMAGE in your site '$LOCAL_SITE_URL'. Please MAKE SURE you have a backup before continue."
            
            if [[ "$REPLY_YES" != true ]]; then
                # 3. Confirm user action if should backup
                run_function confirm_user_action "Do you want to BACKUP the current site before continue?" false true
            else
                USER_ACTION_RESPONSE=true
            fi

            # User will contine
            if [[ "$USER_ACTION_RESPONSE" == true ]]; then
                local_backup_function
            else
                if [[ "$REPLY_YES" != true ]]; then
                    # 4. Confirm user action if continue WITHOUT a backup
                    run_function confirm_user_action "We will stop the running service for '$LOCAL_SITE_URL' and DELETE the folder '${DESTINATION_FOLDER%/}/$LOCAL_SITE_URL'. ARE YOU SURE WE SHOULD CONTINUE?" true 
                fi
            fi

        # 3. If option --backup-if-running was set to true
        else
            if [[ "$NO_BACKUP" == true ]] && [[ "$BACKUP_IF_RUNNING" == true ]]; then
                echoerror "It seems you have set unapropriated arguments (--no-backup and --backup-if-running), so please choose if you rather run the backup or not and try again." false
                local_undo_restore
            fi
            if [[ "$NO_BACKUP" != true ]] && [[ "$BACKUP_IF_RUNNING" == true ]]; then
                local_backup_function
            fi
        fi

        # 5. Stop running service
        run_function stop_compose $DESTINATION_FOLDER $LOCAL_SITE_URL
#        run_function docker_stop_service $DESTINATION_FOLDER $LOCAL_SITE_URL
        ACTION_CURRENT_SITE_SERVICE_STOPPED=true
    fi

    # ----------------------------------------------------------------------
    # 6. Move old site to be deleted after restore is completed
    # ----------------------------------------------------------------------
    OLD_SITE_FOLDER_RESTORE="${RESTORE_STAGE_FOLDER%/}/old"

    # Create temp folder at Restore Point
    run_function create_folder $OLD_SITE_FOLDER_RESTORE

    # Move old site
    sudo mv $DESTINATION_FOLDER/$LOCAL_SITE_URL $OLD_SITE_FOLDER_RESTORE/ || echoerror "Moving from '$DESTINATION_FOLDER/$LOCAL_SITE_URL' to '$OLD_SITE_FOLDER_RESTORE' failed!"
    ACTION_CURRENT_SITE_FOLDER_MOVED=true
fi

# ----------------------------------------------------------------------
# If site was not stopped as in the SITES_FOLDER above (ex. a clone site)
# ----------------------------------------------------------------------
if [[ "$ACTION_CURRENT_SITE_SERVICE_STOPPED" != true ]]; then
    run_function proxy_check_domain_active $LOCAL_SITE_URL false

    # If site is running in the proxy under another url and not found in the SITES_FOLDER
    # inform the user to check the clone sites 
    if [[ "$DOMAIN_ACTIVE_IN_PROXY" == true ]]; then
        echoerror "It seems the site '$LOCAL_SITE_URL' is running in this server but it is not a production site (at: $DESTINATION_FOLDER), so please check your clone sites to see if there is a site running with the same URL you are trying to restore." false
        local_undo_restore
    fi 
fi

# ----------------------------------------------------------------------
# If new URL is informed update compose file
# ----------------------------------------------------------------------

# Get tar file first folder name, which is/should be the url 
LOCAL_TAR_DIR_NAME_RESTORE_FILE=$(tar -tzf $LOCAL_BACKUP_FULL_FILE_PATH | head -1 | cut -f1 -d"/")

if [[ $ARG_NEW_URL != "" ]] && [[ $LOCAL_TAR_DIR_NAME_RESTORE_FILE != $ARG_NEW_URL ]]; then

    # Local function to check domain
    local_check_domain $ARG_NEW_URL

    # Check domain with 'www'
    [[ "$WITH_WWW" == true ]] && local_check_domain "www.$ARG_NEW_URL"

    # ----------------------------------------------------------------------
    # Get the DOMAIN from the url and update compose file with base url name
    # ----------------------------------------------------------------------
    run_function get_domain_from_url $ARG_NEW_URL
    LOCAL_NEW_SERVICE_NAME="${DOMAIN_URL_RESPONSE%%.*}"
    run_function docker_update_docker_compose_service_name "$TEMP_SITE_FOLDER_RESTORE/$LOCAL_TAR_DIR_NAME_RESTORE_FILE/compose/docker-compose.yml" $LOCAL_NEW_SERVICE_NAME

    # Update .env file
    run_function docker_update_env_file_container_name "$TEMP_SITE_FOLDER_RESTORE/$LOCAL_TAR_DIR_NAME_RESTORE_FILE/compose/.env" $LOCAL_NEW_SERVICE_NAME
    run_function docker_update_env_file_domain "$TEMP_SITE_FOLDER_RESTORE/$LOCAL_TAR_DIR_NAME_RESTORE_FILE/compose/.env" $ARG_NEW_URL $WITH_WWW

    # Fix permissions
    run_function system_update_data_folder_permission "$TEMP_SITE_FOLDER_RESTORE/$LOCAL_TAR_DIR_NAME_RESTORE_FILE/data"

    # ----------------------------------------------------------------------
    # Renaming folder to the new URL name
    # ----------------------------------------------------------------------
    # Check if folder exists
    run_function check_folder_exists "$TEMP_SITE_FOLDER_RESTORE/$ARG_NEW_URL"

    # Result from folder exists function
    if [[ "$FOLDER_EXIST" == true ]]; then
        [[ "$SILENT" != true ]] && echowarning "It seems there is a folder with the same name of '$ARG_NEW_URL' at '$TEMP_SITE_FOLDER_RESTORE'. We will rename it to 'old-$ARG_NEW_URL'. Please make sure to keep the folder '$TEMP_SITE_FOLDER_RESTORE' clean next time you run this script."
        sudo mv "$TEMP_SITE_FOLDER_RESTORE/$ARG_NEW_URL" "$TEMP_SITE_FOLDER_RESTORE/old-$ARG_NEW_URL"
    fi

    # Rename backup folder to the new url name
    sudo mv "$TEMP_SITE_FOLDER_RESTORE/$LOCAL_TAR_DIR_NAME_RESTORE_FILE" "$TEMP_SITE_FOLDER_RESTORE/$ARG_NEW_URL"
else
    # Local function to check domain even if there is no NEW_URL informed
    local_check_domain $LOCAL_SITE_URL

    # Check domain with 'www'
    [[ "$WITH_WWW" == true ]] && local_check_domain "www.$LOCAL_SITE_URL"
fi

# ----------------------------------------------------------------------
# Move folder from temp to SITES_FOLDER (--destination)
# ----------------------------------------------------------------------
sudo mv "$TEMP_SITE_FOLDER_RESTORE/$LOCAL_SITE_URL" $DESTINATION_FOLDER
ACTION_RESTORE_SITE_MOVED_TO_SITES_FOLDER=true

# ----------------------------------------------------------------------
# Start Site
# ----------------------------------------------------------------------
run_function start_compose $DESTINATION_FOLDER $LOCAL_SITE_URL false

# ----------------------------------------------------------------------
# Check if user has set '--new-url' in order to update in the database
# ----------------------------------------------------------------------
if [[ $ARG_NEW_URL != "" ]] && [[ $LOCAL_TAR_DIR_NAME_RESTORE_FILE != $ARG_NEW_URL ]]; then
    
    WORKDIR=$DESTINATION_FOLDER"/"$LOCAL_SITE_URL

    # Check if cloned services is running before changing database info
#    run_function check_service_running $DESTINATION_FOLDER $LOCAL_SITE_URL
    run_function wpcli_check_db_running $DESTINATION_FOLDER $LOCAL_SITE_URL
    
    if [[ "$SERVICE_RUNNING" == true ]]; then
    
        LOCAL_WP_FILES_PATH="${DESTINATION_FOLDER%/}/$LOCAL_SITE_URL/data/site/wordpress-core"

        # Check if folder exists
        run_function check_folder_exists $LOCAL_WP_FILES_PATH

        # Result from folder exists function
        [[ "$FOLDER_EXIST" != true ]] && LOCAL_WP_FILES_PATH="${DESTINATION_FOLDER%/}/$LOCAL_SITE_URL/data/site"

        # Update wp-config.php
        #run_function wordpress_update_wp_config "${DESTINATION_FOLDER%/}/$LOCAL_SITE_URL/data/site/wordpress-core" $LOCAL_SITE_URL $DEBUG true
        run_function wordpress_update_wp_config $LOCAL_WP_FILES_PATH $LOCAL_SITE_URL $DEBUG true

        # Copy Active Plugins
        run_function plugins_list_active

        # Stop all running plugins
        run_function plugins_deactivate_all

        # Update URL in the Database
        run_function wpcli_update_site_url_db "${DESTINATION_FOLDER%/}/$LOCAL_SITE_URL/compose" $LOCAL_TAR_DIR_NAME_RESTORE_FILE $LOCAL_SITE_URL

        # Restart previous active plugins
        run_function plugins_activate_list "$PLUGINS_ACTIVE_LIST"
    else
        echoerror "There was some ERROR during the process of restoring a backup file which we could not prevent. The service for the site '$LOCAL_SITE_URL' restored from the file '$LOCAL_BACKUP_FULL_FILE_PATH' is not starting correctly. Please follow the next questions CAREFULLY." false

        # Check if site was running before the restor point
        if [[ "$ACTION_CURRENT_SITE_FOLDER_MOVED" == true ]] && [[ "$ACTION_CURRENT_SITE_SERVICE_STOPPED" == true ]]; then
        
            # Check with the user if should restore the current site instead of the backup site
            run_function confirm_user_action "You had a previous site before this restore proccess. Do you want to revert all actions made by this script?" false true

            # If user continue
            if [[ "$USER_ACTION_RESPONSE" == true ]]; then
                local_undo_restore    
            fi
        else
            # Check with the user wants to keep the restore files
            run_function confirm_user_action "You may keep the restore files to find out what was the error. Do you want to keep all files restored from '$LOCAL_BACKUP_FULL_FILE_PATH' to '$TEMP_SITE_FOLDER_RESTORE'?" false

            # If user continue 
            if [[ "$USER_ACTION_RESPONSE" == true ]]; then
                local_undo_restore true
            else
                local_undo_restore
            fi
        fi
    fi
fi

exit 0

