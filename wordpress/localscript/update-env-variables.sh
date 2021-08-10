#-----------------------------------------------------------------------
#
# Server Automation - https://github.com/evertramos/server-automation
#
# Developed by
#   Evert Ramos <evert.ramos@gmail.com>
#
# Copyright Evert Ramos
#
#-----------------------------------------------------------------------
#
# Be careful when editing this file, it is part of a bigger script!
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# This function has one main objective:
# 1. Update all variables in .env file for new site
#
# You must/might inform the parameters below:
# 1. Full path to the env file
# 2. [optional] (default: ) n/a
#
#-----------------------------------------------------------------------

local_update_env_variables()
{
    local LOCAL_FULL_PATH 

    LOCAL_FULL_PATH=${1:-null}

    [[ $LOCAL_FULL_PATH == "" || $LOCAL_FULL_PATH == null ]] && echoerror "You must inform the required argument(s) to the function: '${FUNCNAME[0]}'"

    [[ "$DEBUG" == true ]] && echo "Updating all variables in .env file for a new site (file: ${LOCAL_FULL_PATH})"

    if [[ ! -f "${PROXY_COMPOSE_FOLDER%/}/.env" ]]; then
        RESPONSE_LOCAL_UPDATE_ENV_VARIABLES="Proxy .env file not found at '${PROXY_COMPOSE_FOLDER%/}/.env'"
        return 0
    else
        source ${PROXY_COMPOSE_FOLDER%/}"/.env"
    fi

    # Project Name
    run_function env_update_variable $LOCAL_FULL_PATH "COMPOSE_PROJECT_NAME" "$LOCAL_COMPOSE_PROJECT_NAME" ".env" true
    [[ "$REPONSE_ENV_UPDATE_VARIABLE" != "" ]] && RESPONSE_LOCAL_UPDATE_ENV_VARIABLES=$REPONSE_ENV_UPDATE_VARIABLE && return 0

    # Proxy options
    run_function env_update_variable $LOCAL_FULL_PATH "DOCKER_WORDPRESS_NETWORK" "$NETWORK"
    if [[ "$WITH_WWW" == true ]]; then
        #run_function docker_update_env_file_domain "$TEMP_SITE_FOLDER_RESTORE/$LOCAL_TAR_DIR_NAME_RESTORE_FILE/compose/.env" $ARG_NEW_URL $WITH_WWW
        run_function env_update_variable $LOCAL_FULL_PATH "DOCKER_WORDPRESS_DOMAINS" "$LOCAL_NEW_URL,www.$LOCAL_NEW_URL"
    else
        run_function env_update_variable $LOCAL_FULL_PATH "DOCKER_WORDPRESS_DOMAINS" "$LOCAL_NEW_URL"
    fi
    run_function env_update_variable $LOCAL_FULL_PATH "DOCKER_WORDPRESS_LETSENCRYPT_EMAIL" "$LOCAL_LETSENCRYPT_EMAIL"

    # Database options
    run_function env_update_variable $LOCAL_FULL_PATH "DOCKER_WORDPRESS_DB_IMAGE" "$LOCAL_DB_IMAGE"
    run_function env_update_variable $LOCAL_FULL_PATH "DOCKER_WORDPRESS_DB_VERSION" "$LOCAL_DB_VERSION"
    run_function env_update_variable $LOCAL_FULL_PATH "DOCKER_WORDPRESS_DB_FILES" "./../data/db"
    run_function env_update_variable $LOCAL_FULL_PATH "DOCKER_WORDPRESS_MYSQL_ROOT_PASSWORD" "$LOCAL_MYSQL_ROOT_PASSWORD"
    run_function env_update_variable $LOCAL_FULL_PATH "DOCKER_WORDPRESS_MYSQL_DATABASE" "$LOCAL_MYSQL_DATABASE"
    run_function env_update_variable $LOCAL_FULL_PATH "DOCKER_WORDPRESS_MYSQL_USER" "$LOCAL_MYSQL_USER"
    run_function env_update_variable $LOCAL_FULL_PATH "DOCKER_WORDPRESS_MYSQL_PASSWORD" "$LOCAL_MYSQL_PASSWORD"
    run_function env_update_variable $LOCAL_FULL_PATH "DOCKER_WORDPRESS_DB_CONTAINER_NAME" "$LOCAL_CONTAINER_DB_NAME"

    # WordPress options
    run_function env_update_variable $LOCAL_FULL_PATH "DOCKER_WORDPRESS_SITE_IMAGE" "$LOCAL_SITE_IMAGE"
    run_function env_update_variable $LOCAL_FULL_PATH "DOCKER_WORDPRESS_SITE_VERSION" "$LOCAL_SITE_VERSION"
    run_function env_update_variable $LOCAL_FULL_PATH "DOCKER_WORDPRESS_SITE_FILES" "./../data/site"
    run_function env_update_variable $LOCAL_FULL_PATH "DOCKER_WORDPRESS_SITE_CONTAINER_NAME" "$LOCAL_CONTAINER_SITE_NAME"
#    run_function env_update_variable $LOCAL_FULL_PATH "WORDPRESS_TABLE_PREFIX" ""

    return 0
}
