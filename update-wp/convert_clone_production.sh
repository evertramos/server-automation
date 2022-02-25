#!/usr/bin/env bash

# ----------------------------------------------------------------------
#
# Convert a Cloned site to Production Site
#
# Developed by
#   Evert Ramos <evert.ramos@gmail.com>
#
# Copyright Evert Ramos with usage right granted to only Everet Ramos
#
# ----------------------------------------------------------------------

# Bash settings (do not mess with it)
shopt -s nullglob globstar

# Debug true will show all messages
#DEBUG=true

# Silent true will hide all information
#SILENT=true

# Get the script name and its file real path
SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
SCRIPT_NAME="${0##*/}"

# Read base scripts
source $SCRIPT_PATH"/base/bootstrap.sh"

# Process arguments
while [[ $# -gt 0 ]]
do
    case "$1" in
        -c)
        CLONED_SITE="${2}"
        if [[ $CLONED_SITE == "" ]]; then 
            echoerror "Invalid option for -c";
            break;
        fi
        shift 2
        ;;
        --clone=*)
        CLONED_SITE="${1#*=}"
        if [[ $CLONED_SITE == "" ]]; then 
            echoerror "Invalid option for --clone";
            break;
        fi
        shift 1
        ;;
        -u)
        DOMAIN="${2}"
        if [[ $DOMAIN == "" ]]; then 
            echoerror "Invalid option for -nu";
            break;
        fi
        shift 2
        ;;
        --new-url=*)
        DOMAIN="${1#*=}"
        if [[ $DOMAIN == "" ]]; then 
            echoerror "Invalid option for --new-url";
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
        -d)
        DESTINATION_FOLDER="${2%/}"
        if [[ $DESTINATION_FOLDER == "" ]]; then 
            echoerror "Invalid option for -d";
            break;
        fi
        shift 2
        ;;
        --destination=*)
        DESTINATION_FOLDER="${1#*=}"
        DESTINATION_FOLDER="${DESTINATION_FOLDER%/}"
        if [[ $DESTINATION_FOLDER == "" ]]; then 
            echoerror "Invalid option for --destination";
            break;
        fi
        shift 1
        ;;
        --wp-debug)
        WP_DEBUG=true
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

# ---------------------------------------------------
#
# Initial check 
#
# ---------------------------------------------------

# Check if docker is installed
run_function check_docker

# Check if there is an .env file in local folder
run_function check_local_env_file

# Check if you are already running an instance of this Script
run_function check_running_script

# Check if script is already running
system_save_pid
trap 'system_delete_pid' EXIT SIGQUIT SIGINT SIGSTOP SIGTERM ERR

# ---------------------------------------------------
#
# Fullfill variables for the script and check all options
#
# ---------------------------------------------------

# Check if the Sites folder is set in the .env or informed as an option
if [[ $CLONE_FOLDER == "" ]] && [[ $SOURCE_FOLDER == "" ]]; then
    echoerror "You must inform the option --source=/path/to/clones or set your CLONE_FOLDER variable in your .env file."
elif [[ $SOURCE_FOLDER == "" ]]; then
    SOURCE_FOLDER=${CLONE_FOLDER%/}
fi

# Check if Clone folder is set in .env or informed as an option
if [[ $SITES_FOLDER == "" ]] && [[ $DESTINATION_FOLDER == "" ]]; then
    echoerror "You must inform the option --destination=/path/to/sites or set your SITES_FOLDER in your .env file."
elif [[ $DESTINATION_FOLDER == "" ]]; then
    DESTINATION_FOLDER=${SITES_FOLDER%/}
fi

# Check if DESTINATION_FOLDER exists
run_function check_folder_exists $DESTINATION_FOLDER

if [[ "$FOLDER_EXIST" != true ]]; then
    echoerror "We could not find the folder '$DESTINATION_FOLDER'. Please update your --destination option or the SITES_FOLDER in your .env file. This PATH should hold the folder where all your sites data are located."
fi

# Check if SOURCE_FOLDER already exists
run_function check_folder_exists $SOURCE_FOLDER

if [[ "$FOLDER_EXIST" != true ]]; then
    echoerror "We could not find the folder '$SOURCE_FOLDER'. Please update our --source option or the CLONE_FOLDER in your .env file. This PATH should hold the folder where all your CLONED sites data are located."
fi

# Check if CLONED_SITE was informed
if [[ $CLONED_SITE == "" ]]; then 
    # List all sites (folders) in a Path
    SELECT_MESSAGE="Select one of the Clone Sites:"
    run_function select_folder $SOURCE_FOLDER "$SELECT_MESSAGE"

    CLONED_SITE=${FOLDER_NAME%/}
    
    if [[ $CLONED_SITE == "" ]]; then 
        echoerror "The CLONED_SITE was not found. Please try again."
    fi
fi

# Check if DOMAIN was informed
if [[ $DOMAIN == "" ]]; then 
    # List all sites (folders) in a Path
    SELECT_MESSAGE="Select the site that will REPLACED by the Clone:"
    run_function select_folder $DESTINATION_FOLDER "$SELECT_MESSAGE"

    DOMAIN=${FOLDER_NAME%/}
    
    if [[ $DOMAIN == "" ]]; then 
        echoerror "The SITE that should be replaced was not found. Please try again."
    fi
fi

# Check if DESTINATION_FOLDER exists
run_function check_folder_exists $DESTINATION_FOLDER"/"$DOMAIN

if [[ "$FOLDER_EXIST" != true ]]; then
    echoerror "We could not find the folder '$DESTINATION_FOLDER/$DOMAIN'. Please update your --destination option or the SITES_FOLDER in your .env file. This PATH should hold the folder where all your sites data are located."
fi

# Check if SOURCE_FOLDER already exists
run_function check_folder_exists $SOURCE_FOLDER"/"$CLONED_SITE

if [[ "$FOLDER_EXIST" != true ]]; then
    echoerror "We could not find the folder '$SOURCE_FOLDER/$CLONED_SITE'. Please update our --source option or the CLONE_FOLDER in your .env file. This PATH should hold the folder where all your CLONED sites data are located."
fi

# ---------------------------------------------------
#
# Start running script
#
# ---------------------------------------------------

# Stop Sites (clonned and pruduction) if Running

# Check if current services is running
run_function check_service_running $SOURCE_FOLDER $CLONED_SITE

# If service is running stop it
if [[ "$SERVICE_RUNNING" == true ]]; then
    run_function stop_compose $SOURCE_FOLDER $CLONED_SITE
fi

# Check if current services is running
run_function check_service_running $DESTINATION_FOLDER $DOMAIN

# If service is running stop it
if [[ "$SERVICE_RUNNING" == true ]]; then
    run_function stop_compose $DESTINATION_FOLDER $DOMAIN
fi

# Rename production site to backup
cd $DESTINATION_FOLDER
sudo mv $DOMAIN "old__"$DOMAIN
cd - > /dev/null 2>&1

# Rename cloned site to main domain
cd $SOURCE_FOLDER
sudo mv $CLONED_SITE $DOMAIN
sudo mv $DOMAIN $DESTINATION_FOLDER"/"
cd - > /dev/null 2>&1

# Set up WORKDIR for the functions below
WORKDIR=$DESTINATION_FOLDER"/"$DOMAIN

# Update compose file
run_function restore_compose_file 

# Update .env file
run_function restore_env_file 

# Update wp-config.php file
run_function restore_wp_config

# Fix permissions
run_function fix_folder_permission

# Start new environment
run_function start_compose $DESTINATION_FOLDER $DOMAIN

# Copy Active Plugins
run_function plugins_list_active

# Stop all running plugins
run_function plugins_deactivate_all

# Update URL in the Database
run_function update_site_url_db

# Restart previous active plugins
run_function plugins_activate_list "$PLUGINS_ACTIVE_LIST"


exit 0

