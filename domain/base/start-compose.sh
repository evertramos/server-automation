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
    if [ "$DEBUG" = true ]; then
        echo "Starting the site "$DOMAIN
    fi

    cd $DESTINATION_FOLDER"/compose"
    docker-compose up -d
    cd -
}
