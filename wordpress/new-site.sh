#!/bin/bash

#-----------------------------------------------------------------------
#
# WordPress script - create a new site
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
shopt -s nullglob globstar
# =) unless you have read the following with good care! =)
# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html

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
        ARG_NEW_URL="${2}"
        if [[ $ARG_NEW_URL == "" ]]; then 
            echoerror "Invalid option for -u";
            break;
        fi
        shift 2
        ;;
        -nu)
        ARG_NEW_URL="${2}"
        if [[ $ARG_NEW_URL == "" ]]; then
            echoerror "Invalid option for -nu";
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
        --git-repo=*)
        ARG_GIT_REPO="${1#*=}"
        if [[ $ARG_GIT_REPO == "" ]]; then 
            echoerror "Invalid option for --git-repo";
            break;
        fi
        shift 1
        ;;
        --git-tag=*)
        ARG_GIT_TAG="${1#*=}"
        if [[ $ARG_GIT_TAG == "" ]]; then 
            echoerror "Invalid option for --git-tag";
            break;
        fi
        shift 1
        ;;
        --site-image=*)
        ARG_SITE_IMAGE="${1#*=}"
        if [[ $ARG_SITE_IMAGE == "" ]]; then 
            echoerror "Invalid option for --site-image";
            break;
        fi
        shift 1
        ;;
        --site-version=*)
        ARG_SITE_VERSION="${1#*=}"
        if [[ $ARG_SITE_VERSION == "" ]]; then 
            echoerror "Invalid option for --site-version";
            break;
        fi
        shift 1
        ;;
        --db-image=*)
        ARG_DB_IMAGE="${1#*=}"
        if [[ $ARG_DB_IMAGE == "" ]]; then 
            echoerror "Invalid option for --db-image";
            break;
        fi
        shift 1
        ;;
        --db-version=*)
        ARG_DB_VERSION="${1#*=}"
        if [[ $ARG_DB_VERSION == "" ]]; then 
            echoerror "Invalid option for --db-version";
            break;
        fi
        shift 1
        ;;
        # This will be an improvement if needed (might use same db for multiples sites as well): db-host|user|pass
        # --db-host=*)
        # ARG_DB_HOST="${1#*=}"
        # if [[ $ARG_DB_HOST == "" ]]; then 
        #     echoerror "Invalid option for --db-host";
        #     break;
        # fi
        # shift 1
        # ;;
        # --db-user=*)
        # ARG_DB_USER="${1#*=}"
        # if [[ $ARG_DB_USER == "" ]]; then 
        #     echoerror "Invalid option for --db-user";
        #     break;
        # fi
        # shift 1
        # ;;
        # --db-pass=*)
        # ARG_DB_PASS="${1#*=}"
        # if [[ $ARG_DB_PASS == "" ]]; then 
        #     echoerror "Invalid option for --db-pass";
        #     break;
        # fi
        # shift 1
        # ;;
        # --letsencrypt-email=*)
        # ARG_LETSENCRYPT_EMAIL="${1#*=}"
        # if [[ $ARG_LETSENCRYPT_EMAIL == "" ]]; then
        #     echoerror "Invalid option for --letsencrypt-email";
        #     break;
        # fi
        # shift 1
        # ;;
        -csut)
        ARG_COMPOSE_SERVICE_UNIQUE_TAG="${2}"
        if [[ $ARG_COMPOSE_SERVICE_UNIQUE_TAG == "" ]]; then 
            echoerror "Invalid option for -csut";
            break;
        fi
        shift 2
        ;;
        --compose-service-unique-tag=*)
        ARG_COMPOSE_SERVICE_UNIQUE_TAG="${1#*=}"
        if [[ $ARG_COMPOSE_SERVICE_UNIQUE_TAG == "" ]]; then 
            echoerror "Invalid option for --compose-service-unique-tag";
            break;
        fi
        shift 1
        ;;
        # This will be an improvement if needed (same db for multiples sites: db-host|user|pass)
        # --activate-tls)
        # ACTIVATE_TLS=true
        # shift 1
        # ;;
        --disable-letsencrypt)
        DISABLE_LETSENCRYPT=true
        shift 1
        ;;
        --skip-docker-image-check)
        SKIP_DOCKER_IMAGE_CHECK=true
        shift 1
        ;;
        --skip-output-colors)
        BASESCRIPT_SKIP_COLOR=true
        shift 1
        ;;
        --verify-dns)
        VERIFY_DNS=true
        shift 1
        ;;
        --with-www)
        WITH_WWW=true
        shift 1
        ;;
        --pid-tag=*)
        ARG_PID_TAG="${1#*=}"
        if [[ $ARG_PID_TAG == "" ]]; then
            echoerror "Invalid option for --pid-tag";
            break;
        fi
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
        usage_new_site
        exit 0
        ;;
        *)
        echoerror "Unknown argument: $1" false
        usage_new_site
        exit 0
        ;;
    esac
done

#-----------------------------------------------------------------------
# Initial check - DO NOT CHANGE SETTINGS BELOW
#-----------------------------------------------------------------------

# Check if there is an .env file in local folder
run_function check_local_env_file

# Specific PID File if needs to run multiple scripts
LOCAL_NEW_PID_FILE=${PID_FILE_NEW_SITE:-".new_site.pid"}
if [[ $ARG_PID_TAG == "" ]]; then
  NEW_PID_FILE=${LOCAL_NEW_PID_FILE}
else
  NEW_PID_FILE=".${ARG_PID_TAG}-${LOCAL_NEW_PID_FILE:1}"
fi

# Run initial check function
run_function starts_initial_check $NEW_PID_FILE

# Save PID
system_save_pid $NEW_PID_FILE

# DO NOT CHANGE ANY OPTIONS ABOVE THIS LINE!

#-----------------------------------------------------------------------
# [function] Undo script actions
#-----------------------------------------------------------------------
local_undo_restore()
{
    echoerror "It seems something went wrong running '$SCRIPT_NAME'.\nWe will try to UNDO all actions done by this script.\nPlease make sure everything was back in place as when you started." false

    # If any service was started make sure to stop it
    if [[ "$ACTION_DOCKER_COMPOSE_STARTED" == true ]]; then
        [[ "$SILENT" != true ]] && echowarning "[undo] Starting docker-compose service '$LOCAL_SITE_FULL_PATH'."
        run_function docker_compose_stop "${LOCAL_SITE_FULL_PATH%/}/compose"
        ACTION_DOCKER_COMPOSE_STARTED=false
    fi

    # If site folder was created
    if [[ "$ACTION_SITE_PATH_CREATED" == true ]]; then
        [[ "$SILENT" != true ]] && echowarning "[undo] Creating site folder '$LOCAL_SITE_FULL_PATH'."
        # Remove folder
        run_function system_safe_delete_folder $LOCAL_SITE_FULL_PATH ${BASE_SERVER_PATH} true
        ACTION_SITE_PATH_CREATED=false
    fi

    # If site domain was created
    if [[ "$ACTION_SITE_URL_CREATED" == true ]]; then
        [[ "$SILENT" != true ]] && echowarning "[undo] Creating site domain '$LOCAL_NEW_URL'."
        run_function domain_delete_domain_dns $LOCAL_NEW_URL
        ACTION_SITE_URL_CREATED=false
        if [[ "$WITH_WWW" == true ]]; then
            run_function domain_delete_domain_dns "www.$LOCAL_NEW_URL"
        fi
    fi

    exit 0
}

#-----------------------------------------------------------------------
# [function] Docker images and version check
#-----------------------------------------------------------------------
local_check_docker_hub_image_version() {
  local LOCAL_DOCKER_IMAGE_NAME LOCAL_DOCKER_IMAGE_VERSION

  LOCAL_DOCKER_IMAGE_NAME=${1:-null}
  LOCAL_DOCKER_IMAGE_VERSION=${2:-null}

  # Check image exists
  run_function dockerhub_check_image_exists $LOCAL_DOCKER_IMAGE_NAME

  if [[ "$DOCKERHUB_IMAGE_EXISTS" != true ]]; then
    echoerror "It seems the image '$LOCAL_DOCKER_IMAGE_NAME' does not exist in docker hub (https://hub.docker.com) or the site is down. Wait a few minutes and try again." false
    local_undo_restore
  fi

  # Check if image and version exists in docker hub
  run_function dockerhub_check_image_exists $LOCAL_DOCKER_IMAGE_NAME $LOCAL_DOCKER_IMAGE_VERSION

  if [[ "$DOCKERHUB_IMAGE_EXISTS" != true ]]; then
    echoerror "It seems the image '$LOCAL_DOCKER_IMAGE_NAME:$LOCAL_DOCKER_IMAGE_VERSION' does not exist in docker hub (https://hub.docker.com) or the site is down. Wait a few minutes and try again." false
    local_undo_restore
  fi
}

#-----------------------------------------------------------------------
# Check if the .env file was already configured for Server-Automation
#-----------------------------------------------------------------------
# @todo - update this function to server-automation .env file if not present it must be configured before running this script
# [?] this is done by the env function - check if needed
run_function check_server_automation_env_file_exists

# Result from function above
if [[ "$SERVER_AUTOMATION_ENV_FILE_EXISTS" != true ]]; then
  [[ "$SILENT" != true ]] && echowarning \
    "It seems you are running server-automation for the first time! \
    We will first need to run You must configure the server-automation '.env' file before continue!"
fi

#-----------------------------------------------------------------------
# Arguments validation and variables fulfillment
#
# In the 'new-site.sh' script the DESTINATION_FOLDER is where
# the new site will be placed (SITES_FOLDER in base .env)
#-----------------------------------------------------------------------

# Check if Sites Folder is set (--destination) or SITES_FOLDER from base .env is set
if [[ $ARG_DESTINATION_FOLDER == "" ]] && [[ $SITES_FOLDER == "" ]]; then 
    echoerror "It seems you did not set the option SITES_FOLDER in your base .env file. If you intend to use this script without this settings please use --destination='' option to inform where your site should be located."
else
    DESTINATION_FOLDER=${ARG_DESTINATION_FOLDER:-$SITES_FOLDER}
    
    # Check if folder exists
    run_function check_folder_exists $DESTINATION_FOLDER

    # Result from folder exists function
    if [[ "$FOLDER_EXIST" == false ]]; then
        [[ "$SILENT" != true ]] && echowarning "You have set the destination folder to: \
          \n'$DESTINATION_FOLDER' \
          \nThis folder does not exist, we will create it for you. \
          \nThis action will not be undone by this script in case of failure."
        run_function common_create_folder $DESTINATION_FOLDER
    fi
fi

#-----------------------------------------------------------------------
# Site URL (-u|--new-url=|ARG_NEW_URL|NEW_URL)
#-----------------------------------------------------------------------
if [[ $ARG_NEW_URL == "" ]]; then
    # Ask for the new URL 
    run_function common_read_user_input "Please enter the URL for the Site:"

    NEW_URL=$USER_INPUT_RESPONSE
else
    NEW_URL=${ARG_NEW_URL}
fi

# Clean up url
run_function domain_get_domain_from_url $NEW_URL
LOCAL_NEW_URL=$DOMAIN_URL_RESPONSE

#-----------------------------------------------------------------------
# Docker Compose Service Name - unique tag (--compose-service-unique-tag|-csut)
#-----------------------------------------------------------------------
if [[ $ARG_COMPOSE_SERVICE_UNIQUE_TAG != "" ]]; then
    COMPOSE_UNIQUE_TAG=$ARG_COMPOSE_SERVICE_UNIQUE_TAG
else
    # Get Random string for clone service name
    run_function common_generate_random_string
    if [[ "$RANDOM_STRING" == 0 ]] || [[ "$RANDOM_STRING" == "" ]]; then
        echoerror "Error generating random string to docker servide name"
    fi

    COMPOSE_UNIQUE_TAG=$RANDOM_STRING
fi

#-----------------------------------------------------------------------
# Check site URL folder at destination
#-----------------------------------------------------------------------
LOCAL_SITE_FULL_PATH=${DESTINATION_FOLDER%/}"/"$(echo ${LOCAL_NEW_URL} | cut -f1 -d",")

# Check if folder exists
run_function check_folder_exists $LOCAL_SITE_FULL_PATH

# Result from folder exists function
if [[ "$FOLDER_EXIST" == false ]]; then
    # Create folder if does not exist
    run_function common_create_folder $LOCAL_SITE_FULL_PATH
    ACTION_SITE_PATH_CREATED=true
else
    # Stop execution if folder already exist
    ACTION_SITE_PATH_CREATED=false
    echoerror "The destination folder already exists. Please check the following path '$LOCAL_SITE_FULL_PATH'." false
    local_undo_restore
fi

#-----------------------------------------------------------------------
# Site options (--site-image | --site-version)
#-----------------------------------------------------------------------
if [[ $ARG_SITE_IMAGE != "" ]]; then
    LOCAL_SITE_IMAGE=${ARG_SITE_IMAGE}
else
    LOCAL_SITE_IMAGE=${SITE_IMAGE:-"wordpress"}
fi

#-----------------------------------------------------------------------
# Check if image exists in docker hub
#-----------------------------------------------------------------------
if [[ $ARG_SITE_VERSION != "" ]]; then
    LOCAL_SITE_VERSION=${ARG_SITE_VERSION}
else
    if [[ $SITE_VERSION != "" ]]; then
        LOCAL_SITE_VERSION=${SITE_VERSION}
    else
        # List versions from docker hub
        if [[ "$REPLY_YES" == true ]]; then
            LOCAL_SITE_VERSION="latest"
        else
            run_function dockerhub_list_tags $LOCAL_SITE_IMAGE
            run_function select_one_option_from_array "${DOCKERHUB_LIST_TAGS[*]}" "Please select a tag for the image '$LOCAL_SITE_IMAGE' (the list below comes from https://hub.docker.com):"
            
            [[ $SELECT_ONE_OPTION_NAME == "" ]] && echowarning "Once you did not select any option, 'latest' will be used."
            LOCAL_SITE_VERSION=${SELECT_ONE_OPTION_NAME:-"latest"}
        fi
    fi
fi

#-----------------------------------------------------------------------
# Check if image and version exists in docker hub
#-----------------------------------------------------------------------
[[ "$SKIP_DOCKER_IMAGE_CHECK" != true ]] && [[ ! "$REPLY_YES" == true ]] && local_check_docker_hub_image_version $LOCAL_SITE_IMAGE $LOCAL_SITE_VERSION

#-----------------------------------------------------------------------
# Database options (--db-image | --db-version)
#-----------------------------------------------------------------------
if [[ $ARG_DB_IMAGE != "" ]]; then
    LOCAL_DB_IMAGE=${ARG_DB_IMAGE}
else
    LOCAL_DB_IMAGE=${DB_IMAGE:-"mariadb"}
fi

#-----------------------------------------------------------------------
# Check if image exists in docker hub
#-----------------------------------------------------------------------
if [[ $ARG_DB_VERSION != "" ]]; then
    LOCAL_DB_VERSION=${ARG_DB_VERSION}
else
    if [[ $DB_VERSION != "" ]]; then
        LOCAL_DB_VERSION=${DB_VERSION}
    else
        # List versions from docker hub
        if [[ "$REPLY_YES" == true ]]; then
            LOCAL_DB_VERSION="latest"
        else
            run_function dockerhub_list_tags $LOCAL_DB_IMAGE
            run_function select_one_option_from_array "${DOCKERHUB_LIST_TAGS[*]}" "Please select a tag for the image '$LOCAL_DB_IMAGE' (the list below comes from https://hub.docker.com):"
            
            [[ $SELECT_ONE_OPTION_NAME == "" ]] && echowarning "Once you did not select any option, 'latest' will be used."
            LOCAL_DB_VERSION=${SELECT_ONE_OPTION_NAME:-"latest"}
        fi
    fi
fi

#-----------------------------------------------------------------------
# Check if image and version exists in docker hub
#-----------------------------------------------------------------------
[[ "$SKIP_DOCKER_IMAGE_CHECK" != true ]] && [[ ! "$REPLY_YES" == true ]] && local_check_docker_hub_image_version $LOCAL_DB_IMAGE $LOCAL_DB_VERSION

#-----------------------------------------------------------------------
# Site git repo and tag/branch (--git-repo | --git-tag)
#-----------------------------------------------------------------------
if [[ $ARG_GIT_REPO != "" ]]; then
    LOCAL_GIT_REPO=${ARG_GIT_REPO}
else
    LOCAL_GIT_REPO=${SITE_REPO:-null}
fi
if [[ $ARG_GIT_TAG != "" ]]; then
    LOCAL_GIT_TAG=${ARG_GIT_TAG}
else
    LOCAL_GIT_TAG=${SITE_REPO_BRANCH:-"master"}
fi

if [[ "$LOCAL_GIT_REPO" == null ]]; then
    echoerror "There is no git repo set. Please update the .env file or add --git-repo option.", false
    local_undo_restore
fi 

#-----------------------------------------------------------------------
# Domain creation
#
# Parameters: --verify-dns
#-----------------------------------------------------------------------
if [[ "$VERIFY_DNS" == true ]]; then
    run_function domain_create_domain_if_not_exist $LOCAL_NEW_URL false

    ACTION_SITE_URL_CREATED=${DOMAIN_CREATED:-false}

    if [[ "$domain_create_domain_dns_ERROR" == true ]]; then
        echo "DOMAIN_ALREADY_ACTIVE_IN_PROXY: $DOMAIN_ALREADY_ACTIVE_IN_PROXY"
        echo "ACTION_SITE_URL_CREATED: ${DOMAIN_CREATED:-false}"
        # Manually set to remove domain informed
        ACTION_SITE_URL_CREATED=${DOMAIN_CREATED:-false}
        echoerror "There was an issue to create this DNS. Please check. Rolling back actions." false
        local_undo_restore
    fi

    if [[ "$DOMAIN_ALREADY_ACTIVE_IN_PROXY" == true ]]; then
        echo "DOMAIN_ALREADY_ACTIVE_IN_PROXY: $DOMAIN_ALREADY_ACTIVE_IN_PROXY"
        echo "ACTION_SITE_URL_CREATED: ${DOMAIN_CREATED:-false}"
        # Manually set to remove domain informed
        ACTION_SITE_URL_CREATED=${DOMAIN_CREATED:-false}
        echoerror "This URL is already running in this server proxy. Please check. Rolling back actions." false
        local_undo_restore
    fi

    if [[ "$WITH_WWW" == true ]]; then
        run_function domain_create_domain_if_not_exist "www.$LOCAL_NEW_URL" false

        ACTION_SITE_URL_CREATED=${DOMAIN_CREATED:-false}

        if [[ "$domain_create_domain_dns_ERROR" == true ]]; then
            echo "DOMAIN_ALREADY_ACTIVE_IN_PROXY: $DOMAIN_ALREADY_ACTIVE_IN_PROXY"
            echo "ACTION_SITE_URL_CREATED: ${DOMAIN_CREATED:-false}"
            # Manually set to remove domain informed
            ACTION_SITE_URL_CREATED=${DOMAIN_CREATED:-false}
            echoerror "There was an issue to create this DNS with 'www' option. Please check. Rolling back actions." false
            local_undo_restore
        fi

        if [[ "$DOMAIN_ALREADY_ACTIVE_IN_PROXY" == true ]]; then
            echo "DOMAIN_ALREADY_ACTIVE_IN_PROXY: $DOMAIN_ALREADY_ACTIVE_IN_PROXY"
            echo "ACTION_SITE_URL_CREATED: ${DOMAIN_CREATED:-false}"
            # Manually set to remove domain informed
            ACTION_SITE_URL_CREATED=${DOMAIN_CREATED:-false}
            echoerror "This URL is already running in this server proxy. Please check. Rolling back actions." false
            local_undo_restore
        fi
    fi
fi

#-----------------------------------------------------------------------
# Clone the repo
#-----------------------------------------------------------------------
run_function git_clone_repo $LOCAL_GIT_REPO $LOCAL_SITE_FULL_PATH $LOCAL_GIT_TAG "compose"
if [[ $RESPONSE_GIT_CLONE_REPO != "" ]]; then
    echowarning "$RESPONSE_GIT_CLONE_REPO"
    local_undo_restore
fi

#-----------------------------------------------------------------------
# Generate all variables for substitution in .env and docker-composer files
#-----------------------------------------------------------------------

# Get project name from the URL
#run_function domain_get_main_name_from_url $LOCAL_NEW_URL
#LOCAL_SITE_NAME="$DOMAIN_MAIN_NAME_FROM_URL"
LOCAL_SITE_NAME="${LOCAL_NEW_URL%.*}"
# @TODO - check fix above to get the project name if there is subdomains this will break
# update https://github.com/evertramos/basescript/blob/e6c9e98286d3b40ab5de11278d2fd4fca1b35ea7/domain/domain-get-main-name-from-url.sh
# even with top level domain with two letter this should work - fix that!


# Get first subdomain if not 'www'
LOCAL_SITE_SUBDOMAIN="${LOCAL_NEW_URL%%.*}"

if [[ "$LOCAL_SITE_SUBDOMAIN" != "www" ]] && [[ "$LOCAL_SITE_SUBDOMAIN" != "${LOCAL_SITE_NAME%%.*}" ]]; then
    LOCAL_PROJECT_NAME="${LOCAL_SITE_NAME}_${LOCAL_SITE_SUBDOMAIN}"
else
    LOCAL_PROJECT_NAME="${LOCAL_SITE_NAME}"
fi

# User Password
# Get Random string for clone service name
run_function common_generate_random_string 12
if [[ "$RANDOM_STRING" == 0 ]] || [[ "$RANDOM_STRING" == "" ]]; then
    RANDOM_STRING="$COMPOSE_UNIQUE_TAG-AAsdrqw1214j-$COMPOSE_UNIQUE_TAG"
fi

# Set the local env variables [@TODO - Update to argument variables if needed]
LOCAL_COMPOSE_PROJECT_NAME="$LOCAL_PROJECT_NAME-$COMPOSE_UNIQUE_TAG"
LOCAL_CONTAINER_DB_NAME="$LOCAL_PROJECT_NAME-db-$COMPOSE_UNIQUE_TAG"
LOCAL_MYSQL_ROOT_PASSWORD=${DB_ROOT_PASSWORD:-$RANDOM_STRING$COMPOSE_UNIQUE_TAG}
LOCAL_MYSQL_DATABASE=$LOCAL_SITE_NAME
LOCAL_MYSQL_USER=${LOCAL_SITE_NAME:0:9}"_user"
LOCAL_MYSQL_PASSWORD=$RANDOM_STRING
LOCAL_CONTAINER_SITE_NAME="$LOCAL_PROJECT_NAME-site-$COMPOSE_UNIQUE_TAG"
LOCAL_LETSENCRYPT_EMAIL=${ARG_LETSENCRYPT_EMAIL:-$LETSENCRYPT_EMAIL}

# @todo - como verificar se setá rodando? ahh depois do composer pronto .....

#-----------------------------------------------------------------------
# Check if site and db container's name are already running
#-----------------------------------------------------------------------
run_function docker_check_container_is_running "$LOCAL_CONTAINER_SITE_NAME"
if [[ "$DOCKER_CONTAINER_IS_RUNNING" == true ]]; then
    echowarning "It seems the container '$LOCAL_CONTAINER_SITE_NAME' is alreay in use in this server. Please try again or update the unique tag option."
    local_undo_restore
fi
run_function docker_check_container_is_running "$LOCAL_CONTAINER_DB_NAME"
if [[ "$DOCKER_CONTAINER_IS_RUNNING" == true ]]; then
    echowarning "It seems the container '$LOCAL_CONTAINER_DB_NAME' is alreay in use in this server. Please try again or update the unique tag option."
    local_undo_restore
fi

#-----------------------------------------------------------------------
# Create/Update .env file
#-----------------------------------------------------------------------
run_function local_update_env_variables "${LOCAL_SITE_FULL_PATH%/}/compose"

if [[ $RESPONSE_LOCAL_UPDATE_ENV_VARIABLES != "" ]]; then
    echo "$RESPONSE_LOCAL_UPDATE_ENV_VARIABLES"
    local_undo_restore
fi

#-----------------------------------------------------------------------
# Create/Update docker-compose file
#-----------------------------------------------------------------------
run_function local_update_docker_compose_file "${LOCAL_SITE_FULL_PATH%/}/compose"

if [[ $RESPONSE_LOCAL_UPDATE_DOCKER_COMPOSE_FILE != "" ]]; then
    echo "$RESPONSE_LOCAL_UPDATE_DOCKER_COMPOSE_FILE"
    local_undo_restore
fi

#-----------------------------------------------------------------------
# Start docker-composer services for the new site
#-----------------------------------------------------------------------
run_function docker_compose_start "${LOCAL_SITE_FULL_PATH%/}/compose"

if [[ "$ERROR_DOCKER_COMPOSE_START" == true ]]; then
    echoerror "There was an error starting the service at '${LOCAL_SITE_FULL_PATH%/}/compose'"
    ACTION_DOCKER_COMPOSE_STARTED=true
    local_undo_restore
fi

#-----------------------------------------------------------------------
# Show data for the user to take notes
#-----------------------------------------------------------------------
echosuccess "Your site was started successfully! Follow some useful information:"
echoline "LOCAL_SITE_FULL_PATH: $LOCAL_SITE_FULL_PATH"
echoline "LOCAL_CONTAINER_SITE_NAME: $LOCAL_CONTAINER_SITE_NAME"
echoline "LOCAL_CONTAINER_DB_NAME: $LOCAL_CONTAINER_DB_NAME"
echoline "LOCAL_MYSQL_DATABASE: $LOCAL_MYSQL_DATABASE"
echoline "LOCAL_MYSQL_USER: $LOCAL_MYSQL_USER"
echoline "LOCAL_MYSQL_PASSWORD: $LOCAL_MYSQL_PASSWORD"

echowarning "The new site might take a few minutes to be ready. Please wait..."
echowarning "If you get database connection error, wait a couple more minutes. Database might take some time to end its creation. You can check the DB container running the follow:"
echoline "docker logs $LOCAL_CONTAINER_DB_NAME"

exit 0
