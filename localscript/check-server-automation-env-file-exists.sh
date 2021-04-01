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
# This script has one main objective:
# 1. Check if the .env file already exists for server-automation
#-----------------------------------------------------------------------

check_server_automation_env_file_exists()
{
    local LOCAL_SCRIPT_PATH

    LOCAL_SCRIPT_PATH=${SCRIPT_PATH:-$(pwd)}

    [[ "$DEBUG" == true ]] && echo "Check if '.env' file exists for the server-automation."

    if [[ -e $LOCAL_SCRIPT_PATH/../.env ]]; then
        SERVER_AUTOMATION_ENV_FILE_EXISTS=true
    fi
}

