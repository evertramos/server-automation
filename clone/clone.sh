#!/bin/bash

# ----------------------------------------------------------------------
#
# Clone a WordPress site from the specified folder 
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
        -nu)
        NEW_URL="${2}"
        if [[ $NEW_URL == "" ]]; then 
            echoerror "Invalid option for -nu";
            break;
        fi
        shift 2
        ;;
        --new-url=*)
        NEW_URL="${1#*=}"
        if [[ $NEW_URL == "" ]]; then 
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
        --filter=*)
        ARG_FILTER="${1#*=}"
        if [[ $ARG_FILTER == "" ]]; then 
            echoerror "Invalid option for --filter=''";
            break;
        fi
        shift 1
        ;;
        --no-start)
        NO_START=true
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
        usage_clone
        exit 0
        ;;
        *)
        echoerror "Unknown argument: $1" false
        usage_clone
        exit 0
        ;;
    esac
done

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
# Arguments validation and variables fulfillment
#
# ----------------------------------------------------------------------
# Check if the Sites folder is set in the .env or informed as an option
if [[ $SITES_FOLDER == "" ]] && [[ $SOURCE_FOLDER == "" ]]; then
    echoerror "You must inform the option --source=/path/to/sites or set your SITES_FOLDER variable in your .env file."
elif [[ $SOURCE_FOLDER == "" ]]; then
    SOURCE_FOLDER=${SITES_FOLDER%/}
fi

# Check if Clone folder is set in .env or informed as an option
if [[ $CLONE_FOLDER == "" ]] && [[ $DESTINATION_FOLDER == "" ]]; then
    echoerror "You must inform the option --destination=/path/to/clones or set your CLONE_FOLDER in your .env file."
elif [[ $DESTINATION_FOLDER == "" ]]; then
    DESTINATION_FOLDER=${CLONE_FOLDER%/}
fi

# Check if DOMAIN was informed
if [[ $DOMAIN == "" ]]; then 
    # List all sites (folders) in the SOURCE_FOLDER/SITES_FOLDER
    run_function select_folder $SOURCE_FOLDER $ARG_FILTER

    DOMAIN=${FOLDER_NAME%/}
    
    if [[ $DOMAIN == "" ]]; then 
        echoerror "The DOMAIN was not found. Please try again."
    fi
fi

# Check NEW_URL
if [[ $NEW_URL == "" ]]; then

    # Check if current services is running
    run_function check_service_running

    # If new url was not set we must check if --no-start
    if [[ "$NO_START" != true ]] && [[ "$SERVICE_RUNNING" == true ]]; then

        echowarning "The site '$DOMAIN' is running. In order to clone this site you must inform a new URL which this NEW SITE (Clone) will be running on. Please make sure to inform a unique URL that is not running in this server."

        # Ask for the new URL 
        run_function common_read_user_input "Please enter the new URL for the Clone Site:"

        run_function domain_get_domain_from_url $USER_INPUT_RESPONSE
        NEW_URL=$DOMAIN_URL_RESPONSE

        run_function confirm_user_action "You are clonning the '$DOMAIN' to the new url '$NEW_URL'. Are you sure you want to continue?"
        
        if [[ "$USER_ACTION_RESPONSE" != true ]]; then
            echoerror "You have canceled the clonning process. No changes were made."
        fi
    elif [[ "$NO_START" == true ]]; then
        run_function confirm_user_action "You are clonning the '$DOMAIN' with --no-start option, which implies tha it will not ask you for a new url for the site. If you plan to use this clone with a new url, please the --NEW-URL option as well. If you are ure you want to continue, type 'yes'?"
        
        if [[ "$USER_ACTION_RESPONSE" != true ]]; then
            echoerror "You have canceled the clonning process. No changes were made."
        fi
    fi
    
    # If new url was not set we must check if --no-start
#    if [[ "$NO_START" == true ]] && [[ "$SERVICE_RUNNING" == true ]]; then
#        echowarning "Please make sure you know what you are doing, this option can mess up your current running site '$DOMAIN'."
#    fi
fi


# If New URL was informed
if [[ $NEW_URL != "" ]]; then
    # Check if new url exist
    run_function domain_check_domain_exists $NEW_URL

    SITE_URL=$NEW_URL

    # Check if DESTINATION_FOLDER already exists
    run_function check_folder_exists $DESTINATION_FOLDER"/"$NEW_URL

    if [[ "$FOLDER_EXIST" == true ]]; then
        echoerror "The URL '$NEW_URL' seems to be already running. Please check folder '$DESTINATION_FOLDER/$NEW_URL' or try a new url for this clone."
    fi
else
    # Check if DESTINATION_FOLDER already exists
    run_function check_folder_exists $DESTINATION_FOLDER"/"$DOMAIN

    if [[ "$FOLDER_EXIST" == true ]]; then
        echoerror "The URL '$DOMAIN' seems to be already running. Please check folder '$DESTINATION_FOLDER/$DOMAIN' or try a new url for this clone."
    fi
fi

# Check if SOURCE_FOLDER already exists
run_function check_folder_exists $SOURCE_FOLDER"/"$DOMAIN

if [[ "$FOLDER_EXIST" != true ]]; then
    echoerror "We could not find the folder '$SOURCE_FOLDER/$DOMAIN'. Please update our --source option or the SITES_FOLDER in your .env file. This PATH should hold the folder where all your sites data are located."
fi

# ---
# @TODO
#
# This line below checks if there is any clone in the old mode... keep it or remove it?
# Check if NEW URL is running in this server by mistake and stop the script
#WORKDIR=$SOURCE_FOLDER"/"$DOMAIN
#run_function check_clone_container_running
#
#if [[ "$CONTAINER_RUNNING" == true ]]; then
#    run_function get_clone_container_compose_workdir
#    echoerror "There is a clone for the '$DOMAIN' site alreary running. Please check the files under the folders: '$SITE_COTNAINER_COMPOSE_WORKDIR_RESULT' and '$DB_COTNAINER_COMPOSE_WORKDIR_RESULT'"
#fi
# ---

# ----------------------------------------------------------------------
#
# Start running script
#
# ----------------------------------------------------------------------
# If NEW URL does not exist, create the DOMAIN
if [[ "$DOMAIN_EXIST" == false ]]; then
    run_function domain_create_domain_dns $SITE_URL

    # Verify if there were an error on creating the new domain
    if [[ "$domain_create_domain_dns_ERROR" == true ]]; then
        echoerror "Error on creating the domain '$SITE_URL' - response '$RESPONSE'" true
    fi
fi

# Check if the requrested url is already running in this proxy
if [[ $NEW_URL != "" ]]; then
    run_function proxy_check_url_active $NEW_URL false

    # If site is running in the proxy under another url and not found in the SITES_FOLDER
    # inform the user to check the clone sites 
    if [[ "$DOMAIN_ACTIVE_IN_PROXY" == true ]]; then
        echoerror "It seems the site '$NEW_URL' is running in this server but it is not a production site (at: $DESTINATION_FOLDER), so please check your clone sites to see if there is a site running with the same URL you are trying to restore." false
    fi 
fi

# Copying files from the source to destination folder
run_function clone_site $SOURCE_FOLDER"/"$DOMAIN $DESTINATION_FOLDER"/"$DOMAIN

# Get Random string for clone service name
run_function common_generate_random_string
if [[ "$RANDOM_STRING" == 0 ]] || [[ "$RANDOM_STRING" == "" ]]; then
    echoerror "Error generating random string to docker servide name"
fi

# Update compose file
WORKDIR=$DESTINATION_FOLDER"/"$DOMAIN
run_function update_compose_file $RANDOM_STRING

# Update .env file
WORKDIR=$DESTINATION_FOLDER"/"$DOMAIN
run_function update_env_file $RANDOM_STRING

# Check NEW_URL
if [[ $NEW_URL != "" ]]; then

    # Set new url to wp-config and debug to true if applicable
    UPDATE_URL=true
    run_function update_wp_config $UPDATE_URL $SITE_URL

    # Rename Folder
    cd $DESTINATION_FOLDER
    mv $DOMAIN $NEW_URL
    cd - > /dev/null 2>&1

    # Set DOMAIN to the current NEW URL
    DOMAIN=$NEW_URL
else
    # If user set --wp-debug option update the wp-config.php
    if [[ "$WP_DEBUG" == true ]]; then 
        run_function update_wp_config
    fi
fi

# Fix permissions
WORKDIR=$DESTINATION_FOLDER"/"$DOMAIN
run_function fix_folder_permission

# Check if it should Start new environment
if [[ "$NO_START" != true ]]; then
    run_function start_compose $DESTINATION_FOLDER $DOMAIN
    
    WORKDIR=$DESTINATION_FOLDER"/"$DOMAIN

    # Check if cloned services is running before changing database info
    run_function check_service_running $DESTINATION_FOLDER $DOMAIN
    run_function wpcli_check_db_running $DESTINATION_FOLDER $DOMAIN
    
    if [[ "$SERVICE_RUNNING" == true ]]; then
        # Copy Active Plugins
        run_function plugins_list_active

        # Stop all running plugins
        run_function plugins_deactivate_all

        # Update URL in the Database
        run_function update_site_url_db

        # Restart previous active plugins
        run_function plugins_activate_list "$PLUGINS_ACTIVE_LIST"
    else
        echoerror "For some reson the cloned site was not started correctly. Please check the files in the $WORKDIR and try to start manually."
    fi
fi

exit 0

