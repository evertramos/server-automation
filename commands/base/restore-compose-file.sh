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

# Script to Restore the docker-compose.yml file

restore_compose_file()
{
    local LOCAL_PREFIX LOCAL_REPLACE_NAME LOCAL_CONTAINER_DB LOCAL_CONTAINER_WP LOCAL_COMPOSE_PATH

    if [[ ! -z $1 ]]; then
        LOCAL_PREFIX=$1
    else
        LOCAL_PREFIX="clone-"
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

    cd $LOCAL_COMPOSE_PATH
    source .env
   
    LOCAL_CONTAINER_DB=${CONTAINER_DB_NAME//$LOCAL_PREFIX/}
    LOCAL_CONTAINER_WP=${CONTAINER_WP_NAME//$LOCAL_PREFIX/}

    if [[ "$DEBUG" == true ]]; then
        echo "Restore the DB and Site Service name with DB ["$LOCAL_CONTAINER_DB"] Site["$LOCAL_CONTAINER_WP"]"
    fi
    
    sed -i -e "s/$CONTAINER_DB_NAME/$LOCAL_CONTAINER_DB/g" docker-compose.yml
    sed -i -e "s/$CONTAINER_WP_NAME/$LOCAL_CONTAINER_WP/g" docker-compose.yml
    cd - > /dev/null 2>&1
}

