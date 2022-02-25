#!/bin/bash

# ----------------------------------------------------------------------
#
# Set correct files permissions in all Sites 
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

# Debug true will show all debug messages
DEBUG=true

# Silent true will hide all information
#SILENT=true

# Get the script name and its file real path
SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
SCRIPT_NAME="${0##*/}"

# Source basescript functions
source $SCRIPT_PATH"/../basescript/bootstrap.sh"

# Source localscripts
source $SCRIPT_PATH"/localscript/bootstrap.sh"

# ----------------------------------------------------------------------
#
# Initial check - DO NOT CHANGE SETTINGS BELOW
#
# ----------------------------------------------------------------------

# Run initial check function
run_function starts_initial_check

# Check if there is an .env file in local folder
run_function check_local_env_file

# Save PID
system_save_pid

# DO NOT CHANGE ANY OPTIONS ABOVE THIS LINE!

# ----------------------------------------------------------------------
#
# Process arguments
#
# ----------------------------------------------------------------------
while [[ $# -gt 0 ]]
do
    case "$1" in
        -u)
        DOMAIN="${2}"
        if [[ $DOMAIN == "" ]]; then 
            echoerror "Invalid option for -u";
            break;
        fi
        shift 2
        ;;
        --url=*)
        DOMAIN="${1#*=}"
        if [[ $DOMAIN == "" ]]; then 
            echoerror "Invalid option for --url";
            break;
        fi
        shift 1
        ;;
        -s)
        SOURCE_FOLDER="${2%/}"
        if [[ $SOURCE_FOLDER == "" ]]; then 
            echoerror "Invalid option for -s";
            break;
        fi
        shift 2
        ;;
        --source=*)
        SOURCE_FOLDER="${1#*=}"
        SOURCE_FOLDER="${SOURCE_FOLDER%/}"
        if [[ $SOURCE_FOLDER == "" ]]; then 
            echoerror "Invalid option for --source";
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
        --debug)
        DEBUG=true
        shift 1
        ;;
        --silent)
        SILENT=true
        shift 1
        ;;
        -h | --help)
        usage
        ;;
        *)
        echoerror "Unknown argument: $1"
        usage
        ;;
    esac
done

# ----------------------------------------------------------------------
#
# Arguments validation and variables fulfillment
#
# ----------------------------------------------------------------------
# Check if the Sites folder is set in the .env or informed as an option
if [[ $SITES_FOLDER == "" ]] && [[ $SOURCE_FOLDER == "" ]]; then
    echoerror "You must inform the option --source=/path/to/sites or set your SITES_FOLDER variable in your .env file."
elif [[ $SOURCE_FOLDER == "" ]]; then
    SOURCE_FOLDER=${SITES_FOLDER%/}
fi

# Check if DOMAIN was informed
if [[ $DOMAIN == "" ]] && [[ "$ALL_SITES" != true ]]; then 
    # List all sites (folders) in the SOURCE_FOLDER/SITES_FOLDER
    run_function select_folder $SOURCE_FOLDER $ARG_FILTER

    DOMAIN=${FOLDER_NAME%/}
    
    if [[ $DOMAIN == "" ]]; then 
        echoerror "The DOMAIN was not found. Please try again."
    fi

    # Check if SOURCE_FOLDER with DOMAIN exists
    run_function check_folder_exists $SOURCE_FOLDER"/"$DOMAIN

    if [[ "$FOLDER_EXIST" != true ]]; then
        echoerror "We could not find the folder '$SOURCE_FOLDER/$DOMAIN'. Please update our --source option or the SITES_FOLDER in your .env file. This PATH should hold the folder where all your sites data are located."
    fi
fi

# Confirm User's action
if [[ "$SILENT" != true ]]; then

    if [[ "$ALL_SITES" != true ]]; then
        run_function confirm_user_action "You will update folder permissions on '$SOURCE_FOLDER/$DOMAIN'. Are you sure you want to continue?"
    else
        run_function confirm_user_action "You will update folder permissions in all sites on '$SOURCE_FOLDER'. Are you sure you want to continue?"
    fi

    if [[ "$USER_ACTION_RESPONSE" != true ]]; then
        echoerror "You have canceled your action. No changes were made."
    fi
fi

# ----------------------------------------------------------------------
#
# Start running script
#
# ----------------------------------------------------------------------

# @TODO - CONVERT BELOW CODES INTO function (BASESCRIPT)

# Go to the Sites folder
cd $SOURCE_FOLDER
# Convert all files to same permission
sudo chmod -R 644 */data/site/*
# Convert only folder to same permission
sudo find */data/site/* -type d -print0 | sudo xargs -0 chmod 755
# Set permission to wp-config.php
sudo chmod 600 */data/site/wordpress-core/wp-config.php
# Set ownership to site's folder
sudo chown www-data.www-data -R */data/site/*


exit 0

## If NEW URL does not exist, create the DOMAIN
#if [[ "$DOMAIN_EXIST" == false ]]; then
#    run_function domain_create_domain_dns $NEW_URL
#fi
#
## Copying files from the source to destination folder
#run_function clone_site $SOURCE_FOLDER"/"$DOMAIN $DESTINATION_FOLDER"/"$DOMAIN
#
## Get Random string for clone service name
#run_function common_generate_random_string
#if [[ "$RANDOM_STRING" == 0 ]] || [[ "$RANDOM_STRING" == "" ]]; then
#    echoerror "Error generating random string to docker servide name"
#fi
#
## Update compose file
#WORKDIR=$DESTINATION_FOLDER"/"$DOMAIN
#run_function update_compose_file $RANDOM_STRING
#
## Update .env file
#WORKDIR=$DESTINATION_FOLDER"/"$DOMAIN
#run_function update_env_file $RANDOM_STRING
#
## Check NEW_URL
#if [[ $NEW_URL != "" ]]; then
#
#    # Set new url to wp-config and debug to true if applicable
#    UPDATE_URL=true
#    run_function update_wp_config $UPDATE_URL $SITE_URL
#
#    # Rename Folder
#    cd $DESTINATION_FOLDER
#    mv $DOMAIN $NEW_URL
#    cd - > /dev/null 2>&1
#
#    # Set DOMAIN to the current NEW URL
#    DOMAIN=$NEW_URL
#else
#    # If user set --wp-debug option update the wp-config.php
#    if [[ "$WP_DEBUG" == true ]]; then 
#        run_function update_wp_config
#    fi
#fi
#
## Fix permissions
#WORKDIR=$DESTINATION_FOLDER"/"$DOMAIN
#run_function fix_folder_permission
#
## Check if it should Start new environment
#if [[ "$NO_START" != true ]]; then
#    run_function start_compose $DESTINATION_FOLDER $DOMAIN
#    
#    WORKDIR=$DESTINATION_FOLDER"/"$DOMAIN
#
#    # Check if cloned services is running before changing database info
#    run_function check_service_running $DESTINATION_FOLDER $DOMAIN
#    
#    if [[ "$SERVICE_RUNNING" == true ]]; then
#        # Copy Active Plugins
#        run_function plugins_list_active
#
#        # Stop all running plugins
#        run_function plugins_deactivate_all
#
#        # Update URL in the Database
#        run_function update_site_url_db
#
#        # Restart previous active plugins
#        run_function plugins_activate_list "$PLUGINS_ACTIVE_LIST"
#    else
#        echoerror "For some reson the cloned site was not started correctly. Please check the files in the $WORKDIR and try to start manually."
#    fi
#fi


exit 0

