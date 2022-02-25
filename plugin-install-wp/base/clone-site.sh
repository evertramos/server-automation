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

# Script to clone folder

clone_site()
{
    if [ "$DEBUG" = true ]; then
        echo "Cloning folder from: "$SOURCE_FOLDER" to "$DESTINATION_FOLDER
    fi

    mkdir -p $DESTINATION_FOLDER

    sudo cp -R $SOURCE_FOLDER"/compose" $DESTINATION_FOLDER
    sudo cp -R $SOURCE_FOLDER"/data" $DESTINATION_FOLDER

    # Update Permissions
    GROUP="$(id -g -n)"
    sudo chown $USER"."$GROUP -R $DESTINATION_FOLDER"/compose"
    sudo chown $USER"."$GROUP $DESTINATION_FOLDER"/data/site/wordpress-core"
    sudo chown $USER"."$GROUP -R $DESTINATION_FOLDER"/data/site/wordpress-core/wp-config.php"
    sudo chown "www-data.www-data" -R $DESTINATION_FOLDER"/data/site/wp-content"
}

