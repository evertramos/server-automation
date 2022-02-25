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
# 1. Check if container exists
#
# You must/might inform the parameters below:
# 1. Container name
# 2. [optional] (default: ) n/a
#
#-----------------------------------------------------------------------

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
