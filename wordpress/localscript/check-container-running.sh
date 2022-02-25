#-----------------------------------------------------------------------
#
# Basescript function
#
# The basescript functions were designed to work as abstract function,
# so it could be used in many different contexts executing specific job
# always remembering Unix concept DOTADIW - "Do One Thing And Do It Well"
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
# Basescript - https://github.com/evertramos/basescript
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# This function has one main objective:
# 1. Check if container is running
#
# You must/might inform the parameters below:
# 1. Container name
# 2. [optional] (default: )
#
#-----------------------------------------------------------------------

check_container_running()
{
    local LOCAL_CONTAINER_NAME LOCAL_COMPOSE_PATH LOCAL_DB_RUNNING LOCAL_SITE_RUNNING LOCAL_RESULTS
    
    LOCAL_CONTAINER_NAME="${1:-}"
    
    if [[ $LOCAL_CONTAINER_NAME == "" ]]; then

        goto_compose_folder
        LOCAL_COMPOSE_PATH=$COMPOSE_FOLDER_RESPONSE

        cd $LOCAL_COMPOSE_PATH
        source .env
        
        [[ "$DEBUG" == true ]] && echo "Checking if the containers '"$CONTAINER_DB_NAME"' and '"$CONTAINER_WP_NAME"' are running"
        
        LOCAL_DB_RUNNING=$(docker ps --filter name=$CONTAINER_DB_NAME --filter status=running --format "table {{.Status}}" | grep "Up" | wc -l)
        LOCAL_SITE_RUNNING=$(docker ps --filter name=$CONTAINER_WP_NAME --filter status=running --format "table {{.Status}}" | grep "Up" | wc -l)
        LOCAL_RESULTS=$((LOCAL_DB_RUNNING + LOCAL_SITE_RUNNING))
        cd - > /dev/null 2>&1

    else
        if [[ "$DEBUG" == true ]]; then
            echo "Checking if the container '"$LOCAL_CONTAINER_NAME"' is running"
        fi

        LOCAL_RESULTS=$(docker ps --filter name=$LOCAL_CONTAINER_NAME --filter status=running --format "table {{.Status}}" | grep "Up" | wc -l)
    fi

    # Check results
    if [[ $LOCAL_RESULTS > 0 ]]; then
        CONTAINER_RUNNING=true
    else 
        CONTAINER_RUNNING=false
    fi
}

