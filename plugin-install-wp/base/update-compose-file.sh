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


update_compose_file()
{
    local LOCAL_CONTAINER_DB LOCAL_CONTAINER_WP

    if [ ! -z $1 ]; then
        LOCAL_CONTAINER_DB=$1"-db"
        LOCAL_CONTAINER_WP=$1"-site"
    else
        LOCAL_CONTAINER_DB="clone-"$CONTAINER_DB_NAME
        LOCAL_CONTAINER_WP="clone-"$CONTAINER_WP_NAME
    fi

    if [ "$DEBUG" = true ]; then
        echo "Substitute the DB and Site Container name with DB ["$LOCAL_CONTAINER_DB"] Site["$LOCAL_CONTAINER_WP"]"
    fi

    cd $DESTINATION_FOLDER"/compose"
    source .env
    sed -i -e "s/$CONTAINER_DB_NAME/$LOCAL_CONTAINER_DB/g" docker-compose.yml
    sed -i -e "s/$CONTAINER_WP_NAME/$LOCAL_CONTAINER_WP/g" docker-compose.yml
    cd - > /dev/null 2>&1
}

