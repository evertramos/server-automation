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

# Script to restore the .env file

restore_env_file()
{
    local LOCAL_PREFIX SUBDOMAIN LOCAL_DOMAIN LOCAL_CONTAINER_DB LOCAL_CONTAINER_WP LOCAL_ENV_PATH
   
    if [[ ! -z $1 ]]; then
        LOCAL_PREFIX=$1
    else
        LOCAL_PREFIX="clone-"
    fi

    if [[ "$DEBUG" == true ]]; then
        echo "Update .env file"
    fi
    
    if [[ ! -z "$DOMAIN" ]]; then
        LOCAL_DOMAIN=$DOMAIN
    fi
    
    check_folder_exists $WORKDIR"/compose"

    if [[ $FOLDER_EXIST == false ]]; then
        check_folder_exists $WORKDIR"/"$DOMAIN"/compose"

        if [[ $FOLDER_EXIST == false ]]; then
        
            check_folder_exists $WORKDIR"/"$NEW_URL"/compose"

            if [[ $FOLDER_EXIST == false ]]; then
                echoerror "The docker-compose.yml file was not found for '$DOMAIN' neither '$NEW_URL' at '$WORKDIR'"
            else
                LOCAL_ENV_PATH=$WORKDIR"/"$NEW_URL"/compose"
            fi
        else
            LOCAL_ENV_PATH=$WORKDIR"/"$DOMAIN"/compose"
        fi
    else
        LOCAL_ENV_PATH=$WORKDIR"/compose"
    fi
    
    cd $LOCAL_ENV_PATH

    # Get the Old URL for search and replace
    source .env
    OLD_URL=${DOMAINS#*=}

    LOCAL_CONTAINER_DB=${CONTAINER_DB_NAME//$LOCAL_PREFIX/}
    LOCAL_CONTAINER_WP=${CONTAINER_WP_NAME//$LOCAL_PREFIX/}
 
    sed -i "/CONTAINER_DB_NAME=/c\CONTAINER_DB_NAME=${LOCAL_CONTAINER_DB//.}" .env
    sed -i "/CONTAINER_WP_NAME=/c\CONTAINER_WP_NAME=${LOCAL_CONTAINER_WP//.}" .env

    sed -i "/DOMAINS=/c\DOMAINS=$LOCAL_DOMAIN" .env

    cd - > /dev/null 2>&1
}

