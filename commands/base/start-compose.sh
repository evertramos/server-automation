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

# Script to start compose at the $DESTINATION_FOLDER

start_compose()
{
    local LOCAL_PATH LOCAL_DOMAIN
    
    if [[ ! -z $1 ]]; then
        LOCAL_PATH=$1
    else
        LOCAL_PATH=$DESTINATION_FOLDER
    fi

    if [[ ! -z $2 ]]; then
        LOCAL_DOMAIN=$2
    else
        LOCAL_DOMAIN=$DOMAIN
    fi

    if [[ "$DEBUG" == true ]]; then
        echo "Starting the site '"$LOCAL_DOMAIN"' at '"$LOCAL_PATH"'"
    fi

    # Check if SOURCE_FOLDER exists
    run_function check_folder_exists $LOCAL_PATH"/"$LOCAL_DOMAIN

    if [[ "$FOLDER_EXIST" != true ]]; then
        echoerror "We could not find the path '"$LOCAL_PATH"/"$LOCAL_DOMAIN"' in order to start the services."

    else
        LOCAL_COMPOSE_PATH=$LOCAL_PATH"/"$LOCAL_DOMAIN"/compose"
    fi

    # Check if services already running
    check_service_running $LOCAL_PATH $LOCAL_DOMAIN

    # If new url was not set we must check if --no-start
    if [[ "$SERVICE_RUNNING" == true ]]; then
        echowarning "The site '$LOCAL_DOMAIN' is running at '$LOCAL_PATH/$LOCAL_DOMAIN'. Please check and start manually. BE INFORMED the Clonning was done as expected!"
    else
        cd $LOCAL_COMPOSE_PATH
        docker-compose up -d
        cd - > /dev/null 2>&1
    fi    
}
