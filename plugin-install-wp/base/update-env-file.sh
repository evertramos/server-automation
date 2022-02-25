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

# Script to

update_env_file()
{
    local SUBDOMAIN LOCAL_DOMAIN LOCAL_CONTAINER_DB LOCAL_CONTAINER_WP
    
    if [ ! -z $1 ]; then
        LOCAL_CONTAINER_DB=$1"-db"
        LOCAL_CONTAINER_WP=$1"-site"
    else
        LOCAL_CONTAINER_DB="clone-"$CONTAINER_DB_NAME
        LOCAL_CONTAINER_WP="clone-"$CONTAINER_WP_NAME
    fi

    if [[ "$DEBUG" = true ]]; then
        echo "Update .env file"
    fi
    
    if [[ ! -z "$NEW_URL" ]]; then
        LOCAL_DOMAIN=$NEW_URL
    fi
    
    cd $DESTINATION_FOLDER"/compose"

    # Get the Old URL for search and replace
    source .env
    OLD_URL=${DOMAINS#*=}i

    sed -i "/DOMAINS=/c\DOMAINS=$LOCAL_DOMAIN" .env
    sed -i "/CONTAINER_DB_NAME=/c\CONTAINER_DB_NAME=${LOCAL_CONTAINER_DB//.}" .env
    sed -i "/CONTAINER_WP_NAME=/c\CONTAINER_WP_NAME=${LOCAL_CONTAINER_WP//.}" .env

    # Initial container name set up for the subdomain without parameter to this fucntion (@CHECK)
#    SUBDOMAIN=$(echo $DOMAIN | awk -F"." '{print $1}')
#    sed -i "/DOMAINS=/c\DOMAINS=$DOMAIN" .env
#    sed -i "/CONTAINER_DB_NAME=/c\CONTAINER_DB_NAME=clone-db-${SUBDOMAIN//.}" .env
#    sed -i "/CONTAINER_WP_NAME=/c\CONTAINER_WP_NAME=clone-site-${SUBDOMAIN//.}" .env

    cd - > /dev/null 2>&1
}

