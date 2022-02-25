#!/usr/bin/env bash

# ----------------------------------------------------------------------
#
# Show the size of a WordPress site
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

# Echo error
# Process arguments
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
        --debug)
        DEBUG=true
        shift 1
        ;;
        --silent)
        SILENT=true
        shift 1
        ;;
        -h | --help)
        usage_show_db_size
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
if [[ $SITES_FOLDER == "" ]] && [[ $SOURCE_FOLDER == "" ]]; then
    echoerror "You must inform the option --source=/path/to/sites or set your SITES_FOLDER variable in your .env file."
elif [[ $SOURCE_FOLDER == "" ]]; then
    SOURCE_FOLDER=${SITES_FOLDER%/}
fi

# Check if DOMAIN was informed
if [[ $DOMAIN == "" ]]; then 
    # List all sites (folders) in the SOURCE_FOLDER/SITES_FOLDER
    run_function select_folder

    DOMAIN=${FOLDER_NAME%/}
    
    if [[ $DOMAIN == "" ]]; then 
        echoerror "The DOMAIN was not found. Please try again."
    fi
fi

# Check if current services is running
run_function check_service_running

# If new url was not set we must check if --no-start
if [[ "$SERVICE_RUNNING" != true ]]; then

    echowarning "The site '$DOMAIN' is not running. In order to run this script '$SCRIPT_NAME' your services must be running. Please start the services and try again."
fi

# Check if SOURCE_FOLDER already exists
run_function check_folder_exists $SOURCE_FOLDER"/"$DOMAIN

if [[ "$FOLDER_EXIST" != true ]]; then
    echoerror "We could not find the folder '$SOURCE_FOLDER/$DOMAIN'. Please update our --source option or the SITES_FOLDER in your .env file. This PATH should hold the folder where all your sites data are located."
fi

# ---------------------------------------------------
#
# Start running script
#
# ---------------------------------------------------

# Show Database Size
WORKDIR=$SOURCE_FOLDER"/"$DOMAIN
run_function show_db_size


exit 0

