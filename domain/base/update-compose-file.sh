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

#if [ "$DEBUG" = true ]; then

update_compose_file()
{
    cd $DESTINATION_FOLDER"/compose"
    source .env
    sed -i -e "s/$CONTAINER_DB_NAME/clone$CONTAINER_DB_NAME/g" docker-compose.yml
    sed -i -e "s/$CONTAINER_WP_NAME/clone$CONTAINER_WP_NAME/g" docker-compose.yml
    cd -
}

