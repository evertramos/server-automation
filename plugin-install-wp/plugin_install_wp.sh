#!/usr/bin/env bash

# ----------------------------------------------------------------------
#
# Script to work with plugins for the WordPress environment
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
    echo "${red}>>> [ERROR] $@${reset}" 1>&2; 
    echo "${red}>>>${reset}"
    echo "${red}>>> -----------------------------------------------------${reset}"
    exit 1;
}

# Echo attention
echoatt() 
{
    echo "${yellow}>>> -----------------------------------------------------${reset}"
    echo "${yellow}>>>${reset}"
    echo "${yellow}>>> [ATTENTION] $@${reset}" 1>&2; 
    echo "${yellow}>>>${reset}"
    echo "${yellow}>>> -----------------------------------------------------${reset}"
    exit 1;
}

# process arguments
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
        -g)
        GIT_REPO="${2}"
        if [[ $GIT_REPO == "" ]]; then 
            echoerror "Invalid option for -g";
            break;
        fi
        shift 2
        ;;
        --git-repo=*)
        GIT_REPO="${1#*=}"
        if [[ $GIT_REPO == "" ]]; then 
            echoerror "Invalid option for --git-repo";
            break;
        fi
        shift 1
        ;;
        -f)
        FILE_NAME="${2}"
        if [[ $FILE_NAME == "" ]]; then 
            echoerror "Invalid option for -f";
            break;
        fi
        shift 2
        ;;
        --file=*)
        FILE_NAME="${1#*=}"
        if [[ $FILE_NAME == "" ]]; then 
            echoerror "Invalid option for --file";
            break;
        fi
        shift 1
        ;;
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
        --activate)
        ACTIVATE_PLUGIN=true
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
            echo "${red}>>> [ERROR] Function \"$1\" not found!${reset}"
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
run_function check_docker

# Check if there is an .env file in local folder
run_function check_local_env_file

# Check if you are already running an instance of this Script
run_function check_running_script

# Check if script is already running
system_save_pid
trap 'system_delete_pid' EXIT SIGQUIT SIGINT SIGSTOP SIGTERM ERR

#
# Check if required options are satisfied
#
if [[ $DOMAIN == "" ]] && [[ $DESTINATION_FOLDER == "" ]]; then 
    echoerror "Domain name OR Destination folder are required. Please check the documentation.";
else
    if [[ $GIT_REPO == "" ]] && [[ $FILE_NAME == "" ]] && [[ $SOURCE_FOLDER == "" ]]; then 
        echoerror "You must inform at least a file containing a list of plugins to install, a folder where you have your list of plugins or a git repo in order to run this script. Please check the documentation.";
    fi
fi

if [[ ! $FILE_NAME == "" ]] && [[ ! $GIT_REPO == "" ]]; then 
    echoerror "You must inform only one of the otions -f (file name) or -g (git repo). Please check the documentation.";
fi

if [[ ! $SOURCE_FOLDER == "" ]] && [[ ! $GIT_REPO == "" ]]; then 
    echoerror "You must inform only one of the otions -s (source folder) or -g (git repo). Please check the documentation.";
fi

#
# Fullfil variables for the script
#

# Check if the Sites folder s set in the .env
if [[ $SITES_FOLDER == "" ]] && [[ $DESTINATION_FOLDER == "" ]]; then
    echoerror "When informing the URL make sure you have set the SITES_FOLDER option in your .env file or pass the option --destination=/path/to/yout/site"
elif [[ $DESTINATION_FOLDER == "" ]]; then
    DESTINATION_FOLDER=$SITES_FOLDER"/"$DOMAIN
fi

# Check if domain exists in the folder
run_function check_folder_exists $DESTINATION_FOLDER

if [[ "$FOLDER_EXIST" == false ]]; then
    echoerror "The destination folder does not exist ["$DESTINATION_FOLDER"]. Please check and try again."
fi

# Check if the environment is running
run_function check_compose_up

# Check if there is multiple files in plugin folder
if [[ $FILE_NAME == "" ]] && [[ ! $SOURCE_FOLDER == "" ]]; then 

    # Check if source folder exists
    run_function check_folder_exists $SOURCE_FOLDER

    if [[ "$FOLDER_EXIST" == false ]]; then
        echoerror "The source folder does not exist. Please confirm if this is where you have the files with the plugin list: ["$SOURCE_FOLDER"]."
    fi

    # Check if more than one files
    cd $SOURCE_FOLDER
    NUMBER_FILES=$(ls -p | wc -l)
    cd - > /dev/null 2>&1

    # Check if find any file at the source folder 
    if [[ $NUMBER_FILES == 0 ]]; then
        echoerror "We could not find backup file for "$DOMAIN" in your backup folder "$SOURCE_FOLDER
    fi

    # Show all files so user can choose which one he wants to restore
    if [[ $NUMBER_FILES > 1 ]]; then
        run_function select_file
    fi
fi

# Check what type of instalation the user has informed
if [[ ! $GIT_REPO == "" ]] && [[ $FILE_NAME == "" ]] && [[ $SOURCE_FOLDER == "" ]]; then 
    # Install Plugin from Git
    run_function install_git_plugin $GIT_REPO
    
    # Check if should activate the plugings
    if [[ "$ACTIVATE_PLUGIN" == true ]]; then
        run_function activate_git_plugin $GIT_REPO
    fi
else
    # Install Plugins in the WP Site
    run_function install_plugins $FILE_NAME
    
    # Check if should activate the plugings
    if [[ "$ACTIVATE_PLUGIN" == true ]]; then
        run_function activate_plugins $FILE_NAME
    fi

    # Final message
    if [[ "$DEBUG" = true ]]; then
        LIST_ALL_PLUGINS=$(cat $SOURCE_FOLDER"/"$FILE_NAME)
        echoatt "Here is a list of the plugins in your file: ["$LIST_ALL_PLUGINS"]"
    fi
fi

# Fix site folder permission
run_function fix_folder_permission

exit 0
