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
# 1. Update all variables in .env file for fresh start script
#
# You must/might inform the parameters below:
# 1. Path where .env is located
# 2. [optional] (default: ) n/a
#
#-----------------------------------------------------------------------

local_update_env_file()
{
    local LOCAL_FILE_PATH

    LOCAL_FILE_PATH=${1:-null}

    [[ $LOCAL_FILE_PATH == "" || $LOCAL_FILE_PATH == null ]] && echoerror "You must inform the required argument(s) to the function: '${FUNCNAME[0]}'"

    [[ "$DEBUG" == true ]] && echo "Updating all variables in .env file for nginx-proxy (file: ${LOCAL_FILE_PATH})"

    # Basic
    run_function env_update_variable $LOCAL_FILE_PATH "BASE_SERVER_PATH" "$LOCAL_BASE_SERVER_PATH"
    run_function env_update_variable $LOCAL_FILE_PATH "SITES_FOLDER" "$LOCAL_SITES_FOLDER"
    run_function env_update_variable $LOCAL_FILE_PATH "CLONE_FOLDER" "$LOCAL_CLONE_FOLDER"
    run_function env_update_variable $LOCAL_FILE_PATH "BACKUP_FOLDER" "$LOCAL_BACKUP_FOLDER"
    run_function env_update_variable $LOCAL_FILE_PATH "LOG_FOLDER" "$LOCAL_LOG_FOLDER"

    # Proxy
    run_function env_update_variable $LOCAL_FILE_PATH "PROXY_OPTION" "$LOCAL_PROXY_OPTION"
    run_function env_update_variable $LOCAL_FILE_PATH "PROXY_FOLDER" "$LOCAL_PROXY_FOLDER"
    run_function env_update_variable $LOCAL_FILE_PATH "PROXY_COMPOSE_FOLDER" "$LOCAL_PROXY_COMPOSE_FOLDER"
    run_function env_update_variable $LOCAL_FILE_PATH "PROXY_DATA_FOLDER" "$LOCAL_PROXY_DATA_FOLDER"

    # Backup
    run_function env_update_variable $LOCAL_FILE_PATH "BACKUP_SERVER" "$LOCAL_BACKUP_SERVER"

    # IPs
    run_function env_update_variable $LOCAL_FILE_PATH "IPv4" "$LOCAL_IPv4"
    [[ "$ACTIVATE_IPV6" == true ]] && run_function env_update_variable $LOCAL_FILE_PATH "IPv6" "$LOCAL_IPv6"

    # DNS Provider
    run_function env_update_variable $LOCAL_FILE_PATH "API_PROVIDER" "$LOCAL_API_PROVIDER"
    run_function env_update_variable $LOCAL_FILE_PATH "API_KEY" "$LOCAL_API_KEY"

    return 0
}
