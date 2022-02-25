#!/usr/bin/env bash

# ----------------------------------------------------------------------
#
# Script to clone wordpress site in docker environment 
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
    echo "${red}$@${reset}" 1>&2; 
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
        -d)
        DESTINATION_FOLDER="${2}"
        if [[ $DESTINATION_FOLDER == "" ]]; then 
            echoerror "Invalid option for -d";
            break;
        fi
        shift 2
        ;;
        --destination=*)
        DESTINATION_FOLDER="${1#*=}"
        if [[ $DESTINATION_FOLDER == "" ]]; then 
            echoerror "Invalid option for --destination";
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

# TODO - check if required source and destination exists.. of will be in .env file
# Check if required options are satisfied
#if [[ $SOURCE_FOLDER == "" ]] || [[ $DESTINATION_FOLDER = "" ]]; then 
if [[ $DOMAIN == "" ]]; then 
    echoerror "Domain is required to use this script.";
    usage
fi
#echo "-s: "$SOURCE_FOLDER
#echo "-d: "$DESTINATION_FOLDER
#echo "-u: "$NEW_URL
#echo "-wp-debug: "$WP_DEBUG
#echo "--debug: "$DEBUG
#echo "--silent: "$SILENT
#exit 0

# Function to check if exists and run functions
run_function() {

    # Check $SILENT mode
    if [ "$SILENT" = true ]; then
        if [ ! -z $2 ]; then
            $1 $2
        else
            $1
        fi
    else
        echo "${yellow}[start]--------------------------------------------------${reset}"

        # Call the specified function
        if [ -n "$(type -t "$1")" ] && [ "$(type -t "$1")" = function ]; then
            echo "${cyan}...running function \"${1}\" to:${reset}"
            if [ ! -z $2 ]; then
                $1 $2
            else
                $1
            fi
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

# Check if curl is installed 

# Check if jq is installed

# Check if there is an .env file for the new environmnet (customer)
run_function check_local_env_file

# Check if you are already running an instance of this Script
run_function check_running_script

# Check if script is already running
system_save_pid
trap 'system_delete_pid' EXIT SIGQUIT SIGINT SIGSTOP SIGTERM ERR

# Check if webproxy is running
#run_function check_webproxy_is_running

# Check if destination folder already exists
# @TODO - remove? rename? or stop?
# @TODO - check if already runing? kill? stop? 

# Check if url exist
#run_function domain_check_domain_exists

if [[ $DOMAIN == "" ]]; then 
    run_function read_all_domains
else
    run_function read_all_domains $DOMAIN
fi

# If url does not exists create subdomain
#if [ "$DOMAIN_EXIST" = false ]; then
#    run_function domain_create_domain_dns
#fi

# Copying files from the source to destination folder
# @TODO - should remove previous cloned folder?
#run_function clone_site

# Update compose file
#run_function update_compose_file

# Update .env file
#run_function update_env_file

# Set new url to wp-config and debug to true if applicable
#run_function update_wp_config

# Start new environment
#run_function start_compose

exit 0
