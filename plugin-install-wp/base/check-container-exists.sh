# This file is part of a bigger script!
#
# Be careful when editing it

# ----------------------------------------------------------------------
#   
# Script devoloped to only Everet Ramos
#
# Developed by
#   Evert Ramos <evert.ramos@gmail.com>     
#
# Copyright Evert Ramos with usage right granted to only Everet Ramos
#
# ----------------------------------------------------------------------

# Script to check if container exists

check_container_exists()
{
    local LOCAL_CONTAINER_DB LOCAL_CONTAINER_WP

    LOCAL_CONTAINER_DB=$DOCKER_PREFIX"-db"
    LOCAL_CONTAINER_WP=$DOCKER_PREFIX"-site"

    if [[ "$DEBUG" = true ]]; then
        echo "Checking if exist any container with the string '"$DOCKER_PREFIX"'"
    fi
   
    if [[ ! "$(docker ps -a -q -f name=$LOCAL_CONTAINER_DB)" ]] && [[ ! "$(docker ps -a -q -f name=$LOCAL_CONTAINER_WP)" ]]; then
        CONTAINER_EXIST=false
    else
        CONTAINER_EXIST=true
    fi 
}

