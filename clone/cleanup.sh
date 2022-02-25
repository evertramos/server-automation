#!/bin/bash

# ----------------------------------------------------------------------
#
# Script to cleanup cloned sites
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
#        -s)
#        ARG_SOURCE_FOLDER="${2}"
#        if [[ $ARG_SOURCE_FOLDER == "" ]]; then 
#            echoerror "Invalid option for -s";
#            break;
#        fi
#        shift 2
#        ;;
#        --source=*)
#        ARG_SOURCE_FOLDER="${1#*=}"
#        if [[ $ARG_SOURCE_FOLDER == "" ]]; then 
#            echoerror "Invalid option for --source=''";
#            break;
#        fi
#        shift 1
#        ;;
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
        --clean-storage)
        CLEAN_STORAGE=true
        shift 1
        ;;
        -y)
        REPLY_YES=true
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
#
# Initial check - DO NOT CHANGE SETTINGS BELOW
#
# ----------------------------------------------------------------------

# Specific PID File if needs to run multiple scripts
NEW_PID_FILE=".clone_cleanup"

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
# Check if Source Folder or SITES_FOLDER from base .env file is set 
#if [[ $ARG_SOURCE_FOLDER == "" ]] && [[ $SITES_FOLDER == "" ]]; then 
#    echoerror "It seems you did not set the option SITES_FOLDER in your base .env file. If you intend to use this script without this settings please use --source='' option to inform the initial directory where your sites are located."
#else
#    SOURCE_FOLDER=${ARG_SOURCE_FOLDER:-$SITES_FOLDER}
#    
#    # Check if folder exists
#    run_function check_folder_exists $SOURCE_FOLDER true
#fi

# Check if Clone Folder is set (CLONE_FOLDER in base .env file)
if [[ $ARG_DESTINATION_FOLDER == "" ]] && [[ $CLONE_FOLDER == "" ]]; then 
    echoerror "It seems you did not set the option CLONE_FOLDER in your base .env file. If you intend to use this script without this settings please use --destination='' option to determina the clone directory location."
else
    DESTINATION_FOLDER=${ARG_DESTINATION_FOLDER:-$CLONE_FOLDER}
    
    # Check if folder exists
    run_function check_folder_exists $DESTINATION_FOLDER

    # Result from folder exists function
    if [[ "$FOLDER_EXIST" == false ]]; then
        echoerror "The clone folder '$DESTINATION_FOLDER' does not exist in your server. Please check your command and try again."
    fi
fi

# Check if user informed --url and --all-sites
if [[ $ARG_URL != "" ]] && [[ "$ALL_SITES" == true ]]; then 
    echoerror "You have entered the option --url='' and --all-sites. Please check your command and inform only one of these options."
fi

# Final message before starting cleaning process
[[ "$SILENT" != true ]] && echowarning "[BE ADVISED] You are removing a clone site completely from this server. This action can not be reverted. Make sure you know what you are doing."
[[ "$SILENT" != true ]] && echowarning "[BE ADVISED] Thi action will also DELETE the domain DNS even if this URL is running in the server PROXY!"

# Check if user informed the --all-sites option
if [[ "$ALL_SITES" != true ]]; then

    # Check if user informed the --url (ARG_URL) or should list the clone sites
    if [[ $ARG_URL == "" ]]; then

        cd $DESTINATION_FOLDER > /dev/null 2>&1
        if [[ $ARG_FILTER != "" ]]; then 
            ALL_FILES_IN_FOLDER=($(ls -p | grep $ARG_FILTER | grep /))
        else
            ALL_FILES_IN_FOLDER=($(ls -p | grep /))
        fi
        cd - > /dev/null 2>&1


        echowarning "Select all clones you want delete."
     
        # Show list of clone file for this url
        run_function select_multiple_data "${ALL_FILES_IN_FOLDER[*]}"

        LIST_CLONE_FOLDERS=(${USER_MULTIDATA_SELECTIONS[@]})
    else
        run_function domain_get_domain_from_url ${ARG_URL}
        LIST_CLONE_FOLDERS=(${DOMAIN_URL_RESPONSE})
    fi
fi


# ----------------------------------------------------------------------
#
# Start running script
#
# ----------------------------------------------------------------------

# function to be called by the next lines

function local_clone_cleanup()
{
    local LOCAL_CLONE_SITE_FOLDER

    LOCAL_CLONE_SITE_FOLDER=${1}

    # Confirm user action if --yes was not informed
    if [[ "$REPLY_YES" != true ]]; then
        
        run_function confirm_user_action "Do you want to DELETE all files for the selected sites (${LOCAL_CLONE_SITE_FOLDER%/})?" false
        
        # Set send storage if user confirmed
        if [[ "$USER_ACTION_RESPONSE" != true ]]; then
            echowarning "You have canceled this function. No changes were done!" true
        fi
    fi

    if [[ $LOCAL_CLONE_SITE_FOLDER != "" ]]; then

        # Stop service
        run_function docker_stop_docker_compose_service "${LOCAL_CLONE_SITE_FOLDER%/}/compose"

        # Get domain name
        run_function domain_get_domain_from_env_file "${LOCAL_CLONE_SITE_FOLDER%/}/compose" false
 
        # Remove folder
        run_function system_safe_delete_folder $LOCAL_CLONE_SITE_FOLDER true

        # Delete domain from Digital Ocean
        run_function domain_delete_domain_dns $DOMAIN_NAME true
    fi

    return 
}

# Verify if should cleanup all sites
if [[ "$ALL_SITES" == true ]]; then

    # Loop all sites folder and clean it
    return_all_folders $DESTINATION_FOLDER
    for i in ${!RETURN_ALL_FOLDERS[@]}; do
        [[ "$SILENT" != true ]] && echowarning "Deleting clone for site '${RETURN_ALL_FOLDERS[i]}'"

        LOCAL_URL=${RETURN_ALL_FOLDERS[i]%/}
        CLONE_SITE_FOLDER=${DESTINATION_FOLDER%/}"/"$LOCAL_URL

        if [[ $LOCAL_URL != "" ]]; then
            local_clone_cleanup $CLONE_SITE_FOLDER
        else
            echoerror "Some error in the loop"
        fi
    done
else
    # Loop through all files selected by the user
    for LOCAL_BACKUP_FILE in "${LIST_CLONE_FOLDERS[@]}"; do
        CLONE_SITE_FOLDER=${DESTINATION_FOLDER%/}"/"$LOCAL_BACKUP_FILE
        if [[ $LOCAL_BACKUP_FILE != "" ]]; then
            local_clone_cleanup $CLONE_SITE_FOLDER
        else
            echoerror "Some error site folder"
        fi
    done
fi

exit 0

