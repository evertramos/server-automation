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
    
    if [ "$DEBUG" = true ]; then
        echo "Update .env file"
    fi
    
    if [ ! -z "$NEW_URL" ]; then
        DOMAIN=$NEW_URL
    fi

    cd $DESTINATION_FOLDER"/compose"
    sed -i "/DOMAINS=/c\DOMAINS=$DOMAIN" .env
    sed -i "/CONTAINER_DB_NAME=/c\CONTAINER_DB_NAME=clone_db_${DOMAIN//.}" .env
    sed -i "/CONTAINER_WP_NAME=/c\CONTAINER_WP_NAME=clone_site_${DOMAIN//.}" .env
    cd -
}

