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

# Script to check if the compose file is up and running

check_compose_up()
{
    local LOCAL_CONTAINERS_RUNNING LOCAL_DESTINATION_FOLDER

    if [[ ! -z $1 ]]; then
        LOCAL_DESTINATION_FOLDER=$1"/compose"
    else
        LOCAL_DESTINATION_FOLDER=$DESTINATION_FOLDER"/compose"
    fi

    if [[ "$DEBUG" == true ]]; then
        echo "Checking if the services/cotnainers are up and running for this folder: ["$LOCAL_DESTINATION_FOLDER"]"
    fi

    cd $LOCAL_DESTINATION_FOLDER
    source .env
    LOCAL_CONTAINERS_RUNNING=$(docker-compose ps -q | wc -l)
    if [[ $LOCAL_CONTAINERS_RUNNING < 1 ]]; then
        echoerror "Your containers for the compose files at ["$LOCAL_DESTINATION_FOLDER"] seems to be stopped. Please start this environment before installing the plugins."
    fi
    cd - > /dev/null 2>&1
}

