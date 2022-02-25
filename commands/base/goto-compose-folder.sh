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

# Script to go to compose folder (find it or error)

goto_compose_folder()
{
    local LOCAL_COMPOSE_PATH

    if [[ "$DEBUG" = true ]]; then
        echo "Finding the Compose folder at the workdir '$WORKDIR'."
    fi

    check_folder_exists $WORKDIR"/compose"

    if [[ $FOLDER_EXIST == false ]]; then
        check_folder_exists $WORKDIR"/"$DOMAIN"/compose"

        if [[ $FOLDER_EXIST == false ]]; then
        
            check_folder_exists $WORKDIR"/"$NEW_URL"/compose"

            if [[ $FOLDER_EXIST == false ]]; then
                echoerror "The docker-compose.yml file was not found for '$DOMAIN' neither '$NEW_URL' at '$WORKDIR'"
            else
                LOCAL_COMPOSE_PATH=$WORKDIR"/"$NEW_URL"/compose"
            fi
        else
            LOCAL_COMPOSE_PATH=$WORKDIR"/"$DOMAIN"/compose"
        fi
    else
        LOCAL_COMPOSE_PATH=$WORKDIR"/compose"
    fi
    
    COMPOSE_FOLDER_RESPONSE=$LOCAL_COMPOSE_PATH
}
