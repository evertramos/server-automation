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

# Script to Update the URL in the database

update_site_url_db()
{
    local LOCAL_COMPOSE_PATH

    if [[ $NEW_URL == "" ]]; then
        NEW_URL=$DOMAIN
    fi

    if [[ "$DEBUG" == true ]]; then
        echowarning "Updating the URL in the DB from '$OLD_URL' to '$NEW_URL'. This may take a few minutes depending on the size of the database. Please wait..."
    fi

    check_folder_exists $WORKDIR"/compose"

    if [[ $FOLDER_EXIST == false ]]; then
        check_folder_exists $WORKDIR"/"$DOMAIN"/compose"

        if [[ $FOLDER_EXIST == false ]]; then
        
            check_folder_exists $WORKDIR"/"$NEW_URL"/compose"

            if [[ $FOLDER_EXIST == false ]]; then
                echoerror "The docker-compose.yml file was not found for '$DOMAIN' neither '$NEW_URL' at '$WORKDIR'"
            else
                LOCAL_COMPOSE_PATH=$WORKDIR"/"$DOMAIN"/compose"
            fi
        else
            LOCAL_COMPOSE_PATH=$WORKDIR"/"$DOMAIN"/compose"
        fi
    else
        LOCAL_COMPOSE_PATH=$WORKDIR"/compose"
    fi

    cd $LOCAL_COMPOSE_PATH
    docker-compose run --rm wpcli search-replace $OLD_URL $NEW_URL
    cd - > /dev/null 2>&1
}
