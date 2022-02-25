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
    if [ "$DEBUG" = true ]; then
        echo "Updating the URL in the DB from $OLD_URL to $NEW_URL"
        echo "This may take a few minutes, depending on the size of the database."
    fi

    cd $DESTINATION_FOLDER"/compose"
    pwd
    echo "docker-compose run --rm wpcli search-replace $OLD_URL $NEW_URL"
    docker-compose run --rm wpcli search-replace $OLD_URL $NEW_URL
    cd - > /dev/null 2>&1
}
