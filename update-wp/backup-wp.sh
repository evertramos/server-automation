#!/usr/bin/env bash

# ----------------------------------------------------------------------
#
# Script to backup the wordrpess site 
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
echoerror()
{ 
    echo "${red}>>> -----------------------------------------------------${reset}"
    echo "${red}>>>${reset}"
    echo "${red}>>>[ERROR] $@${reset}" 1>&2; 
    echo "${red}>>>${reset}"
    echo "${red}>>> -----------------------------------------------------${reset}"
    exit 1;
}

# process arguments
while [[ $# -gt 0 ]]
do
    case "$1" in
        -s)
        SOURCE_FOLDER="${2}"
        if [[ $SOURCE_FOLDER == "" ]]; then 
            echoerror "Invalid option for -s";
            break;
        fi
        shift 2
        ;;
        --source=*)
        SOURCE_FOLDER="${1#*=}"
        if [[ $SOURCE_FOLDER == "" ]]; then 
            echoerror "Invalid option for --source";
            break;
        fi
        shift 1
        ;;
        -u)
        NEW_URL="${2}"
        DOMAIN="${2}"
        if [[ $NEW_URL == "" ]]; then 
            echoerror "Invalid option for -u";
            break;
        fi
        shift 2
        ;;
        --url=*)
        NEW_URL="${1#*=}"
        DOMAIN="${1#*=}"
        if [[ $NEW_URL == "" ]]; then 
            echoerror "Invalid option for --url";
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
        usage
        ;;
        *)
        echoerror "Unknown argument: $1"
        usage
        ;;
    esac
done

# Check if required options are satisfied
if [[ $SOURCE_FOLDER == "" ]] && [[ $DOMAIN == "" ]]; then 
    echoerror "Source folder OR url are required. Please check the documentation.";
    usage
fi

# Function to check if exists and run functions
run_function() {

    # Check $SILENT mode
    if [ "$SILENT" = true ]; then
        $1
    else
        echo "${yellow}[start]--------------------------------------------------${reset}"

        # Call the specified function
        if [ -n "$(type -t "$1")" ] && [ "$(type -t "$1")" = function ]; then
            echo "${cyan}...running function \"${1}\" to:${reset}"
            $1
        else
            echo "${red}>>> -----------------------------------------------------${reset}"
            echo "${red}>>>${reset}"
            echo "${red}>>>[ERROR] Function \"$1\" not found!${reset}"
            echo "${red}>>>${reset}"
            echo "${red}>>> -----------------------------------------------------${reset}"
            echo "${yellow}[ended with ${red}[ERROR]${yellow}]-------------------------------------${reset}"
            exit 1
        fi

        # Show result from the function execution
        if [ $? -ne 0 ]; then
            echo "${red}>>> -----------------------------------------------------${reset}"
            echo "${red}>>>${reset}"
            echo "${red}>>> Ups! Something went wrong...${reset}"
            echo "${red}>>>${reset}"
            echo "${red}>>> ${MESSAGE}${reset}"
            echo "${red}>>>${reset}"
            echo "${red}>>> -----------------------------------------------------${reset}"
            echo "${yellow}[ended with ${red}ERROR${yellow}/WARNING ($?)----------------------------${reset}"
            exit 1
        else
            echo "${green}>>> Success!${reset}"
        fi

        echo "${yellow}[end]----------------------------------------------------${reset}"
        echo
    fi
}

# ---------------------------------------------------
#
# Here start to run this script
#
# ---------------------------------------------------

# Check if docker is installed
#run_function check_docker

# Check if there is an .env file in local folder
run_function check_local_env_file

# Check if you are already running an instance of this Script
run_function check_running_script

# Check if script is already running
system_save_pid
trap 'system_delete_pid' EXIT SIGQUIT SIGINT SIGSTOP SIGTERM ERR

# Fullfil the Source folder if only informed URL
if [[ $SOURCE_FOLDER == "" ]] && [[ ! $DOMAIN == "" ]]; then 

    # Check if the sites folder variable is set in the .env file    
    if [[ $SITES_FOLDER == "" ]]; then
        echoerror "When informing the URL make sure you have set the SITES_FOLDER option in your .env file. Please update your settings."
    fi
    SOURCE_FOLDER=$SITES_FOLDER"/"$DOMAIN
else
    # Check if user informed the SOURCE FOLDER and get the SITES FOLDER if not set in the .env file
    # This is required for the tar command
    if [[ $SITES_FOLDER == "" ]]; then
        cd $SOURCE_FOLDER
        SITES_FOLDER=${PWD%/*}
        cd -
    fi
fi

# Check if the backup folder option is set in the .env file
if [[ $BACKUP_FOLDER == "" ]]; then
    echoerror "You need to set where the backup will be located. Please set the option BACKUP_FOLDER in your .env file."
else
    DESTINATION_FOLDER=$BACKUP_FOLDER
fi

# Check if destination folder exists
run_function check_folder_exists

# If url does not exists probably there is no site running on the server
if [ "$FOLDER_EXIST" = false ]; then
    echoerror "We could not find the folder $SOURCE_FOLDER in your server. Please check try again with correct information."
    #run_function domain_create_domain_dns
fi

# Backup the whole folder into the backup folder
run_function backup_folder

if [ "$DEBUG" = true ]; then
    echo "Your backup was finished: "$BACKUP_FILE_NAME" at "$DESTINATION_FOLDER
    echo 
fi

exit 0
