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

# Script to Update the docker-compose.yml file

update_compose_file()
{
    local LOCAL_PREFIX LOCAL_REPLACE_NAME LOCAL_CONTAINER_DB LOCAL_CONTAINER_WP LOCAL_COMPOSE_PATH

    if [[ ! -z $1 ]]; then
        LOCAL_PREFIX=$1
    else
        LOCAL_PREFIX="clone-"
    fi
    
    if [[ ! -z $2 ]] && [[ "$2" == true ]]; then
        LOCAL_REPLACE_NAME=true
    else
        LOCAL_REPLACE_NAME=false
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
   
    if [[ "$LOCAL_REPLACE_NAME" == true ]]; then
        LOCAL_CONTAINER_DB=$LOCAL_PREFIX"-db"
        LOCAL_CONTAINER_WP=$LOCAL_PREFIX"-site"
    else 
        LOCAL_CONTAINER_DB=$LOCAL_PREFIX$CONTAINER_DB_NAME
        LOCAL_CONTAINER_WP=$LOCAL_PREFIX$CONTAINER_WP_NAME
    fi

    if [[ "$DEBUG" == true ]]; then
        echo "Substitute the DB and Site Service name with DB ["$LOCAL_CONTAINER_DB"] Site["$LOCAL_CONTAINER_WP"]"
    fi
    
    sed -i -e "s/$CONTAINER_DB_NAME/$LOCAL_CONTAINER_DB/g" docker-compose.yml
    sed -i -e "s/$CONTAINER_WP_NAME/$LOCAL_CONTAINER_WP/g" docker-compose.yml
    cd - > /dev/null 2>&1
}

